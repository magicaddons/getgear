#!/usr/bin/env python3
"""Build independent stat flags from WoW Forever item tooltip HTML, not statRole."""
import argparse,csv,hashlib,html,json,pathlib,re,urllib.request
from html.parser import HTMLParser

SOURCE_URL="https://raw.githubusercontent.com/Napalmsteak/WoW-Classic-Item-Caches/main/Forever%20Cache.json"
CATALOGUE=pathlib.Path("docs/source-audit-1-60/all_items.csv")
OUTPUT=pathlib.Path("GeneratedStatFlags.lua")
REPORT=pathlib.Path("docs/source-audit-1-60/STAT_FLAGS.md")
BITS={"spellPower":1,"healing":2,"mana":4,"physical":8,"defense":16}
SCHOOL_BITS={"Fire":1,"Frost":2,"Shadow":4,"Holy":8,"Arcane":16,"Nature":32}

def school_facts(raw):
    """Passive offensive schools, separate from generic power and healing.

    A proc dealing fire damage is not passive fire spell power. Attributes
    alongside a school bonus do not make that bonus generic spell power.
    """
    parser=Plain();parser.feed(raw)
    text=re.sub(r"\s+"," ",parser.get()).lower()
    base=re.split(r"\b(?:equip:|use:|chance on hit:)",text)[0]
    passive=[base]+re.findall(r"\bequip:\s*(.*?)(?=\bequip:|\buse:|\bchance on hit:|\bsell price:|$)",text)
    mask=0;generic=False;healing=False
    for effect in passive:
        school_phrase=re.search(r"increases?.*?\bdamage(?: done)? by\s+(.*?)\s+spells\b",effect)
        healing=healing or bool(re.search(r"(?:\+\s*\d+\s+healing|increases?.*\bhealing\b)",effect))
        generic=generic or bool(re.search(r"\bspell power\b|\+\s*\d+\s+spell damage\b",effect))
        generic=generic or bool(re.search(r"increases?.*\bdamage\b.*\b(?:magical|all) spells\b",effect))
        generic=generic or bool(re.search(r"increases?.*\bdamage(?: and healing)? done by spells and effects\b",effect))
        for school,bit in SCHOOL_BITS.items():
            s=school.lower()
            if (re.search(r"\+\s*\d+\s+"+s+r"\s+(?:spell\s+)?damage\b",effect)
                or school_phrase and re.search(r'\b'+s+r'\b',school_phrase[1])):
                if not mask&bit:mask+=bit
    # Do not rule out utility weapons when a use/cast effect is not represented
    # by the passive stat flags. Physical on-hit procs alone are not caster stats.
    utility=bool(re.search(r'\buse:|\b(?:spellcast|spell cast|when you cast|healing spell)|\bspells? have a chance',text))
    if not mask and not generic and not healing and len(passive)>1:
        utility=True # e.g. spell hit/crit or an unfamiliar passive effect
    return [mask,bool(generic),bool(healing),utility]

class Plain(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True);self.parts=[]
    def handle_data(self,data):self.parts.append(data)
    def handle_starttag(self,tag,attrs):
        if tag=="br":self.parts.append("\n")
    def handle_endtag(self,tag):
        if tag in ("td","tr","p","table"):self.parts.append("\n")
    def get(self):return html.unescape("".join(self.parts))

def download(url):
    req=urllib.request.Request(url,headers={"User-Agent":"GetGear-StatEvidenceAudit/1.0","Accept":"application/json"})
    with urllib.request.urlopen(req,timeout=60) as resp:raw=resp.read(26000000)
    return json.loads(raw),hashlib.sha256(raw).hexdigest()

def norm(value):return re.sub(r"[^a-z0-9]","",str(value or "").lower())

def has_stat(text,label):
    return re.search(r"\+\s*\d+\s+"+label+r"\b",text,re.I) is not None

def flags_from_tooltip(raw):
    parser=Plain();parser.feed(raw)
    normalized=re.sub(r"\s+"," ",parser.get()).lower()
    # Distinguish passive spell-power boosts from cast procs/use-effects.
    effects=re.findall(r"\bEquip:\s*(.*?)(?=\bEquip:|\bUse:|\bChance on hit:|\bSell Price:|$)",
                       normalized,re.S|re.I)
    spell=has_stat(normalized,r"(?:spell\s+power|spell\s+damage)")
    healing=has_stat(normalized,r"(?:healing(?:\s+power)?)")
    for effect in effects:
        if re.search(r"\bspell\s+power\b",effect):spell=True
        if (re.search(r"\b(?:increases?|increased)\b",effect)
            and re.search(r"\b(?:damage|damaging)\b",effect)
            and re.search(r"\b(?:spell|spells|magical|magic)\b",effect)
            and re.search(r"\b(?:by\s+up\s+to|by|to)\b",effect)):
            spell=True
        if (re.search(r"\b(?:healing|heals)\b",effect)
            and re.search(r"\b(?:increases?|increased)\b",effect)):
            healing=True
    mana=bool(re.search(r"\+\s*\d+\s+(?:intellect|spirit|mana)\b",normalized)
            or re.search(r"(?:restores|regenerates)\s+\d+\s+mana\b",normalized))
    physical=bool(re.search(r"\+\s*\d+\s+(?:strength|agility|attack\s+power)\b",normalized)
                  or re.search(r"\b(?:melee|ranged)\s+attack\s+power\b",normalized))
    defense=bool(re.search(r"(?:defense|defence|dodge|parry|block)\s+(?:rating|skill|chance)?\s*\+?\d+",normalized)
                or re.search(r"\+\s*\d+\s+(?:defense|defence|dodge|parry|block)\b",normalized))
    return sum(BITS[name] for name,ok in
               (("spellPower",spell),("healing",healing),("mana",mana),
                ("physical",physical),("defense",defense)) if ok)

def main():
    args=argparse.ArgumentParser()
    args.add_argument('--input',type=pathlib.Path,help='Pinned full Forever tooltip cache; no network when supplied')
    options=args.parse_args()
    assert CATALOGUE.exists(),"Full GetGear catalogue audit required"
    with CATALOGUE.open(encoding="utf8",newline="") as f:cats=list(csv.DictReader(f))
    assert len(cats)==7707,(len(cats),"unexpected catalogue")
    if options.input:
        raw=options.input.read_bytes();data=json.loads(raw);digest=hashlib.sha256(raw).hexdigest()
    else:data,digest=download(SOURCE_URL)
    assert isinstance(data,list) and len(data)>10000
    source={x["itemId"]:x for x in data if isinstance(x,dict)
            and isinstance(x.get("itemId"),int)}
    flags={};schools={};reasons={}
    for row in cats:
        iid=int(row["itemID"]);item=source.get(iid)
        problem=None
        if not item:problem="not_in_tooltip_source"
        elif norm(item.get("name"))!=norm(row["name"]):problem="name_differs"
        elif not item.get("tooltipHtml"):problem="no_tooltip"
        if problem:
            reasons[problem]=reasons.get(problem,0)+1
            continue
        flags[iid]=flags_from_tooltip(item["tooltipHtml"])
        schools[iid]=school_facts(item['tooltipHtml'])
    fixtures={
      250492:{"spellPower":True,"physical":True},
      250522:{"spellPower":True,"physical":True},
      250490:{"spellPower":True,"defense":True},
      250520:{"spellPower":True,"defense":True},
      250488:{"spellPower":False,"physical":True},
      250519:{"spellPower":False,"physical":True},
      250517:{"spellPower":True,"physical":True},
      250502:{"spellPower":True,"physical":True},
      3313:{"spellPower":False,"mana":True,"physical":True},
      252509:{"spellPower":False,"mana":True,"physical":True},
      250491:{"spellPower":True,"mana":True},
      250501:{"spellPower":True,"healing":True},
    }
    examples=[]
    for iid,wanted in fixtures.items():
        assert iid in flags,f"Missing independent tooltip evidence {iid}"
        mask=flags[iid]
        for key,expected in wanted.items():
            assert bool(mask & BITS[key])==expected,(iid,key,expected,mask)
        examples.append((iid,source[iid]["name"],mask))
    OUTPUT.write_text(
        "local addonName, GetGear = ...\n"
        "-- Generated from independently published Forever tooltip HTML.\n"
        "-- Never infer spell-power flags from a generic mixed statRole.\n"
        "-- Evidence is Forever, not Classic Era; it can still predate live changes.\n"
        f"-- Source SHA256 {digest}\n"
        "GetGear.GeneratedStatFlags = {\n"
        + "".join("    "+", ".join(f"[{iid}]={mask}" for iid,mask in
                sorted(flags.items())[i:i+12])+",\n"
                for i in range(0,len(flags),12))
        + "}\n"
        + "-- Passive offensive-school mask (Fire1,Frost2,Shadow4,Holy8,Arcane16,Nature32), generic damage, healing, unclassified/use utility.\n"
        + "-- Exact name-matched full tooltip; missing records remain unknown. No proc-school inference.\n"
        + "GetGear.GeneratedSchoolStats = {\n"
        + ''.join(f' [{iid}]={{{row[0]},{str(row[1]).lower()},{str(row[2]).lower()},{str(row[3]).lower()}}},\n' for iid,row in sorted(schools.items()))
        + "}\n",encoding="utf8")
    counts={name:sum(bool(mask & bit) for mask in flags.values())
            for name,bit in BITS.items()}
    REPORT.write_text(
        "# Independent stat flags for WoW Forever\n\n"
        "Flags are independent and nonexclusive. An item can have physical, mana, "
        "healing, spell-power and defense bonuses simultaneously. "
        "A missing flag or missing source does not mean that a bonus is absent.\n\n"
        f"- Source: [{SOURCE_URL}]({SOURCE_URL})\n"
        f"- SHA256: {digest}\n"
        f"- Catalogue records: {len(cats):,}\n"
        f"- Name-matched Forever tooltips: {len(flags):,}\n"
        f"- No matching tooltip evidence: {len(cats)-len(flags):,}\n"
        + "".join(f"- {k}: {v}\n" for k,v in sorted(reasons.items()))
        + "".join(f"- {k} flag present: {v:,}\n" for k,v in counts.items())
        + "\n## Representative checked items\n\n"
        "| Item ID | Name | Bitmask |\n|---:|---|---:|\n"
        + "".join(f"| {iid} | {name} | {mask} |\n" for iid,name,mask in examples)
        + "\n## Interpretation\n\n"
        "- The spellPower flag means an explicit passive increase to spell/magic damage.\n"
        "- Spell resistance, spell crit, spell-on-hit procs, and Intellect or Spirit alone do not trigger spellPower.\n"
        "- Warrior, Rogue and Hunter have a default presentation veto for explicit spellPower.\n"
        "- Paladin, Shaman and Druid continue to see appropriate hybrid equipment.\n"
        "- Show all valid equipment bypasses these relevance rules, never QA exclusions.\n"
        "- Generated flags are loaded after the original item cache so it cannot overwrite them.\n"
        "- Regenerate this index from newer Forever data before future bulk releases.\n",
        encoding="utf8")
    print("PASS Forever independent stat flags",len(flags),"covering",len(cats),
          "items",counts,"unmatched",reasons)
    print("FIXTURES",examples)
if __name__=="__main__":main()
