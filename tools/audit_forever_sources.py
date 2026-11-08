#!/usr/bin/env python3
"""Reproducible, conservative, per-item GetGear source/material audit.

Uses independent, public Forever client extracts; does NOT equate client item
existence with live dungeon loot or vendor/trainer availability. No user data.
Reports and candidate-only Lua fixes are written to --out; never edits add-on.
"""
import argparse, collections, csv, datetime, hashlib, json, pathlib, re, urllib.request, urllib.error, time
from urllib.parse import quote

BASE = "https://raw.githubusercontent.com"
SOURCES = {
    "everloot_recipes": f"{BASE}/Everloot/everloot/main/web/src/data/game-data/client-recipes.json",
    "everloot_encounters": f"{BASE}/Everloot/everloot/main/web/src/data/game-data/client-encounters.json",
    "maf_professions": f"{BASE}/MAF2414/wow-forever-talents/main/docs/professions-data.json",
    "independent_sources": f"{BASE}/nobody174/wow-forever/main/bis/sources.json",
    "ahledger_armor": "https://ahledger.com/api/catalog?class=armor",
    "ahledger_weapon": "https://ahledger.com/api/catalog?class=weapon",
    "ahledger_recipe": "https://ahledger.com/api/catalog?class=recipe",
    "ahledger_trade_goods": "https://ahledger.com/api/catalog?class=trade-goods",
}
PROFESSIONS={"Blacksmithing","Leatherworking","Tailoring","Enchanting","Engineering","Alchemy","Cooking","First Aid"}
CLASSES=("PRIEST","MAGE","WARLOCK","DRUID","ROGUE","HUNTER","SHAMAN","WARRIOR","PALADIN")

def pull(url):
    req=urllib.request.Request(url,headers={"User-Agent":"GetGear-DataQualityAudit/1.0 (github.com/magicaddons/getgear)","Accept":"application/json"})
    with urllib.request.urlopen(req,timeout=35) as res:
        data=res.read(15_000_000)
    return json.loads(data),{"url":url,"bytes":len(data),"sha256":hashlib.sha256(data).hexdigest()}

def norm(v):
    return re.sub(r"\s+"," ",str(v or "").strip()).casefold()

def public_pages(url, field, cap=40000):
    """Traverse public paginated evidence, respecting each endpoint's next URL."""
    rows=[];pages=0;seen=set();meta={}
    while url and url not in seen and len(rows)<cap and pages<80:
        seen.add(url)
        obj,source=pull(url)
        if not isinstance(obj,dict) or not isinstance(obj.get(field),list):break
        rows.extend(obj[field]);pages+=1
        meta={"asOf":obj.get("dataAsOf"),"total":obj.get("total"),
              "pages":pages,"lastUrl":url,"attribution":obj.get("attribution")}
        url=obj.get("next")
    meta["downloaded"]=len(rows)
    meta["complete"]=url is None
    return rows,meta

def ahledger_recipes():
    """Acquisition labels and recipe reagents from an independent catalogue."""
    rows=[];statuses={}
    for profession in ("Blacksmithing","Leatherworking","Tailoring",
                       "Enchanting","Engineering","Alchemy","Cooking","First Aid"):
        url=("https://api.ahledger.com/v1/crafting/forever.normal.alliance.us"
             "?all=1&limit=2000&profession="+quote(profession))
        try:
            obj,meta=pull(url)
            found=[r for r in obj.get("recipes",[]) if isinstance(r,dict)]
            statuses[profession]={"count":len(found),"url":meta["url"]}
            rows.extend(found)
        except Exception as exc:statuses[profession]={"error":str(exc)}
    return rows,statuses

def asid(v):
    if isinstance(v,bool): return None
    if isinstance(v,int): return v if v>0 else None
    if isinstance(v,str) and v.isdigit():return int(v)
    if isinstance(v,dict):
        for k in ("itemID","itemId","item_id","id","outputItemID"):
            if k in v:
                z=asid(v[k])
                if z:return z
    if isinstance(v,(list,tuple)) and v:return asid(v[0])
    return None

def ingredients(seq):
    out=collections.Counter()
    if not isinstance(seq,list): return None
    for row in seq:
        if isinstance(row,(list,tuple)) and len(row)>=2:
            ident=asid(row[0]);amount=row[1]
        elif isinstance(row,dict):
            ident=next((asid(row[k]) for k in ("itemID","itemId","id","reagentId","item") if asid(row.get(k))),None)
            amount=next((row[k] for k in ("qty","count","quantity","amount","required") if k in row),None)
        else: return None
        try: amount=int(amount)
        except (ValueError,TypeError):return None
        if not ident or amount<1:return None
        out[ident]+=amount
    return dict(sorted(out.items()))

def encoded(reagents):
    return ";".join(f"{k}:{v}" for k,v in sorted((reagents or {}).items()))

def parse_encoded(raw):
    d=collections.Counter()
    if not raw:return {}
    for pair in raw.split(";"):
        try:
            a,b=pair.split(":");d[int(a)]+=int(b)
        except Exception:return {}
    return dict(sorted(d.items()))

def write_csv(path,rows,fields):
    with path.open("w",encoding="utf-8",newline="") as fh:
        w=csv.DictWriter(fh,fieldnames=fields,extrasaction="ignore")
        w.writeheader()
        for row in rows:w.writerow(row)

def match_everloot(item,ever_by_spell,ever_by_output):
    spell=asid(item.get("recipeSpellID"))
    result=asid(item.get("id"))
    if spell and spell in ever_by_spell:
        choices=[x for x in ever_by_spell[spell] if x["output"]==result]
        if len(choices)==1:return choices[0],"spell+result"
        if len(choices)>1:return None,"ambiguous-spell+result"
    choices=[x for x in ever_by_output.get(result,[]) if x["profession"]==item["profession"]]
    if len(choices)==1:return choices[0],"unique-result+profession"
    if len(choices)>1:return None,"ambiguous-result"
    return None,"not-in-recipe-extract"

def method(item):
    prof=item["profession"]
    if not prof:return "not-crafted"
    learning=norm(item.get("recipeLearnMethod"))
    acq=norm(item.get("recipeAcquisitionKind"))
    kind=norm(item.get("acquisitionKind"))
    if acq=="drop" or "dropped plans" in kind or "dropped pattern" in kind:
        return "dropped recipe"
    if item.get("recipeVendor"):
        return "vendor recipe"
    if learning=="trainer":return "trainer (teaching unverified)"
    if learning=="initial":return "initial profession"
    if learning in ("pattern","plans"):
        return "plans/pattern; source unresolved"
    return "recipe teaching unresolved"

def dungeon_source(item,boss_names):
    source_type=norm(item.get("sourceType"))
    acq_kind=norm(item.get("acquisitionKind"))
    if "dungeon" not in source_type and "dungeon" not in acq_kind:return "not-dungeon"
    if "trash" in source_type or "trash" in acq_kind:return "trash (reference)"
    source=item.get("source","")
    enemy=""
    for pattern in (r"^Boss:\s*(.+?)\s*\(",r"^Dungeon enemy:\s*(.+?)\s*\("):
        m=re.search(pattern,source,re.I)
        if m:enemy=m.group(1).strip();break
    if not enemy:return "dungeon; enemy unresolved"
    names=[norm(s) for s in re.split(r"\s*/\s*",enemy)]
    if names and all(n in boss_names for n in names):
        return "named client encounter (boss route unverified)"
    return "named dungeon enemy; boss/trash unresolved"

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--catalogue",required=True)
    ap.add_argument("--out",required=True)
    args=ap.parse_args()
    out=pathlib.Path(args.out);out.mkdir(parents=True,exist_ok=True)
    with open(args.catalogue,encoding="utf-8",newline="") as f:
        items=list(csv.DictReader(f,delimiter="\t"))
    assert len(items)==7707, f"Expected 7707 items, saw {len(items)}"
    assert len({x["id"] for x in items})==len(items)
    evidence={};provenance={};failures={}
    for key,url in SOURCES.items():
        try:
            data,source=pull(url);evidence[key]=data;provenance[key]=source
            print("AUDIT SOURCE",key,source["bytes"],source["sha256"][:12],flush=True)
        except Exception as exc:
            failures[key]=str(exc)
            print("AUDIT SOURCE UNAVAILABLE",key,str(exc),flush=True)
    observed_edges=[];observed_meta={};npc_facts={}
    try:
        observed_edges,observed_meta=public_pages(
            "https://everloot.app/api/edges?evidence=observed&limit=500","edges")
        print("AUDIT OBSERVED EDGES",len(observed_edges),observed_meta.get("complete"),flush=True)
        provenance["everloot_observed_edges"]={
            "url":"https://everloot.app/api/edges?evidence=observed&limit=500",
            "rows":len(observed_edges),"asOf":observed_meta.get("asOf"),
            "complete":observed_meta.get("complete"),"licence":"CC BY-SA 4.0"}
    except Exception as exc:failures["everloot_observed_edges"]=str(exc)
    try:
        sightings,sight_meta=public_pages(
            "https://everloot.app/api/corpus/public?kinds=npc_sighting&limit=500",
            "records",cap=40000)
        for sight in sightings:
            if not isinstance(sight,dict):continue
            npc=asid(sight.get("npcId"))
            if npc and isinstance(sight.get("name"),str) and sight["name"]:
                if npc not in npc_facts:npc_facts[npc]=sight
        provenance["everloot_npc_sightings"]={
            "url":"https://everloot.app/api/corpus/public?kinds=npc_sighting&limit=500",
            "rows":len(sightings),"asOf":sight_meta.get("asOf"),
            "complete":sight_meta.get("complete"),"licence":"CC BY-SA 4.0"}
    except Exception as exc:failures["everloot_npc_sightings"]=str(exc)
    observed_by_item=collections.defaultdict(list)
    for edge in observed_edges:
        if (isinstance(edge,dict) and edge.get("evidence")=="observed"
                and edge.get("fromKind")=="item"):
            observed_by_item[asid(edge.get("fromId"))].append(edge)
    ahl_recipes,ahl_status=ahledger_recipes()
    provenance["ahledger_crafting"]={
        "url":"https://api.ahledger.com/v1/crafting/forever.normal.alliance.us",
        "reciperecords":len(ahl_recipes),"professions":ahl_status}
    ahl_by_spell=collections.defaultdict(list);ahl_by_result=collections.defaultdict(list)
    for rec in ahl_recipes:
        recipe=rec.get("recipe") or {};result=rec.get("result") or {}
        if asid(recipe.get("spellId")):ahl_by_spell[asid(recipe["spellId"])].append(rec)
        if asid(result.get("id")):ahl_by_result[asid(result["id"])].append(rec)
    # Source absence NEVER counts as evidence that a recipe or loot is absent.
    ever_by_spell=collections.defaultdict(list);ever_by_output=collections.defaultdict(list)
    ever=evidence.get("everloot_recipes",{})
    for pf in ever.get("professions",[]):
        prof=pf.get("name","")
        for r in pf.get("recipes",[]):
            if not isinstance(r,list) or len(r)<6:continue
            rid=asid(r[0]);output=asid(r[1]);reag=ingredients(r[5])
            if not rid or not output or reag is None:continue
            rec={"spell":rid,"output":output,"profession":prof,"skill":r[2],"reagents":reag}
            ever_by_spell[rid].append(rec);ever_by_output[output].append(rec)
    # Separate, older Forever client extraction. Helpful corroboration, not
    # sufficient reason to overwrite current-client ingredient differences.
    maf=evidence.get("maf_professions",{})
    maf_by_spell={};maf_names={}
    for key,obj in maf.get("items",{}).items():
        if isinstance(obj,dict) and obj.get("name"):maf_names[asid(key)]=obj["name"]
    for r in maf.get("records",[]):
        if not isinstance(r,dict):continue
        spell=asid(r.get("id"))
        if spell and r.get("kind")=="recipe":
            maf_by_spell[spell]=r
        elif spell and r.get("outputs") and r.get("reagents"):
            maf_by_spell[spell]=r
    # Independent published dungeon-encounter NAMES, not evidence of loot.
    encounters=evidence.get("everloot_encounters",{}).get("instances",{})
    boss_names={norm(e.get("name")) for rows in encounters.values() for e in rows if isinstance(e,dict) and e.get("name")}
    # Independent item names from a newer Forever build.
    catalog={}
    for cat in ("ahledger_armor","ahledger_weapon","ahledger_recipe","ahledger_trade_goods"):
        for r in evidence.get(cat,{}).get("rows",[]):
            if isinstance(r,list) and len(r)>2 and asid(r[0]):
                catalog[int(r[0])]=r[1]
    # Existing independent source explanations (mostly Classic leads).
    independent=evidence.get("independent_sources",{}).get("items",{})
    issues=collections.Counter();methods=collections.Counter();dungeons=collections.Counter()
    match_kind=collections.Counter();source_group=collections.Counter();class_counts=collections.Counter()
    recipes=[];all_rows=[];unresolved=[];fixes=[];major_conflicts=[]
    for item in items:
        item_id=int(item["id"])
        listed_classes=item["classes"].split(",") if item.get("classes") else []
        for token in listed_classes:class_counts[token.split(":")[0]]+=1
        prof=item.get("profession","")
        source_type=item.get("sourceType","")
        acq=item.get("acquisitionConfidence","")
        route="unverified"
        if acq in ("observed","forever","published-forever-dungeon-journal","reported"):
            route="published or observed; review source"
        if acq in ("classic-reference","client","published-client-recipe"):
            route="client/Classic lead only"
        if source_type.startswith("Source not") or "unverified" in source_type.lower():
            route="unresolved route"
        source_group[source_type or "Unknown"]+=1
        d=dungeon_source(item,boss_names);dungeons[d]+=1
        m=method(item)
        flags=[]
        if route=="unresolved route":flags.append("acquisition_route_unverified")
        if d in ("dungeon; enemy unresolved","named dungeon enemy; boss/trash unresolved"):
            flags.append("dungeon_enemy_or_role_unresolved")
        if item_id not in catalog: flags.append("not_in_independent_catalogue_or_hidden")
        elif norm(catalog[item_id])!=norm(item["name"]):
            flags.append("independent_name_disagreement")
        if prof:
            methods[m]+=1
            if m in ("plans/pattern; source unresolved","recipe teaching unresolved"):
                flags.append("recipe_learning_source_unresolved")
            existing=parse_encoded(item.get("reagents",""))
            match,why=match_everloot(item,ever_by_spell,ever_by_output)
            match_kind[why]+=1
            expected=match["reagents"] if match else None
            same=expected is not None and expected==existing
            maf_rec=maf_by_spell.get(match["spell"] if match else asid(item.get("recipeSpellID")))
            maf_inputs=ingredients(maf_rec.get("reagents")) if maf_rec else None
            maf_agrees=maf_inputs is not None and expected is not None and maf_inputs==expected
            if not existing:flags.append("crafting_materials_unavailable")
            elif expected is not None and not same:
                flags.append("independent_materials_disagreement")
            if not match:flags.append("no_independent_current_recipe_match")
            if expected is not None and existing!=expected:
                record={"itemID":item_id,"name":item["name"],"profession":prof,
                    "spellID":match["spell"],"match":why,"current":existing,
                    "proposed":expected,"maf_agrees":maf_agrees,
                    "action":"review-conflict" if existing else "fill-missing"}
                fixes.append(record)
                if existing:major_conflicts.append(record)
            recipes.append({
                "itemID":item_id,"name":item["name"],"profession":prof,
                "method":m,"spellID":item.get("recipeSpellID",""),
                "clientMatch":why,"currentReagents":encoded(existing),
                "independentReagents":encoded(expected),
                "materialStatus":("confirmed" if same else "missing" if not existing
                                   else "disagreement" if expected is not None else "uncorroborated"),
                "MAFCorroboratesCurrent":("yes" if maf_agrees else "no/unknown"),
                "issues":";".join(sorted(set(flags))),
            })
        external=independent.get(str(item_id),{})
        if isinstance(external,dict) and external.get("src"):
            independent_note=external["src"]
        else:independent_note=""
        for fl in set(flags):issues[fl]+=1
        row={"itemID":item_id,"name":item["name"],"level":item["level"],
            "slot":item["slot"],"classes":item["classes"],"sourceType":source_type,
            "source":item.get("source",""),"zone":item.get("zone",""),
            "sourceEvidence":acq,"routeStatus":route,"dungeonClassification":d,
            "recipeMethod":m,"recipeSpellID":item.get("recipeSpellID",""),
            "reagentCount":len(parse_encoded(item.get("reagents",""))),
            "independentName":catalog.get(item_id,""),
            "independentSourceLead":independent_note,
            "issues":";".join(sorted(set(flags))),
        }
        all_rows.append(row)
        if flags:unresolved.append(row)
    # Proposed overrides are NOT applied automatically; they require source
    # reconciliation and in-game testing first.
    fixes.sort(key=lambda r:r["itemID"])
    (out/"material_candidates.json").write_text(json.dumps(fixes,indent=2,ensure_ascii=False)+"\n",encoding="utf8")
    with (out/"material_candidates.lua").open("w",encoding="utf8") as f:
        f.write("-- AUDIT CANDIDATES ONLY; NOT IN GetGear.toc. Review each before enabling.\n")
        f.write("-- Ingredients from Everloot's Forever client extract (build 70790).\nreturn {\n")
        for entry in fixes:
            if entry["action"]!="fill-missing":continue
            rows=[]
            for matid,qty in entry["proposed"].items():
                name=maf_names.get(matid) or catalog.get(matid)
                if not name:break
                safe=str(name).replace("\\","\\\\").replace('"','\\"')
                rows.append(f'{{itemID={matid},name="{safe}",amount={qty}}}')
            if len(rows)!=len(entry["proposed"]):continue
            f.write(f'  [{entry["itemID"]}]={{reagents={{{",".join(rows)}}}}},\n')
        f.write("}\n")
    all_fields=list(all_rows[0].keys())
    write_csv(out/"all_items.csv",all_rows,all_fields)
    write_csv(out/"unresolved_items.csv",unresolved,all_fields)
    write_csv(out/"recipes.csv",recipes,list(recipes[0]))
    (out/"provenance.json").write_text(json.dumps({"sources":provenance,"unavailable":failures},indent=2)+"\n")
    # Explicitly scope what was and was NOT established.
    lines=[
        "# GetGear 1–60 source and recipe audit (development only)","",
        "This is a **machine-assisted census**, not a claim that every drop or vendor route was personally verified in the live realm.",
        f"Generated UTC: {datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='seconds')}.","",
        "## Coverage",
        f"- Catalogue records checked: **{len(items):,}/7,707**; unique IDs: {len({r['id'] for r in items}):,}.",
        f"- Items with one or more outstanding flags: **{len(unresolved):,}**.",
        f"- Crafting entries checked: **{len(recipes):,}**.",
        f"- Recipe material candidates requiring changes: **{len(fixes):,}** (missing: {sum(x['action']=='fill-missing' for x in fixes):,}; conflicts: {len(major_conflicts):,}).",
        f"- Independent current-client recipe matches: **{sum(v for k,v in match_kind.items() if k in ('spell+result','unique-result+profession')):,}**.",
        f"- Independent item-name catalogue matches: **{sum(1 for row in all_rows if row['independentName']):,}**.",
        "",
        "## Nine-class eligibility checks",
    ]
    for c in CLASSES:lines.append(f"- {c}: {class_counts[c]:,} class-item objectives")
    lines.extend(["","## Recipe acquisition categories"])
    for k,v in methods.most_common():lines.append(f"- {k}: {v:,}")
    lines.extend(["","## Dungeon classifications"])
    for k,v in dungeons.most_common():lines.append(f"- {k}: {v:,}")
    lines.extend(["","## Outstanding issue counts"])
    for k,v in issues.most_common():lines.append(f"- {k}: {v:,}")
    lines.extend(["","## Interpretation and limitations",
        "- Equipment existence and client encounter names are not proof that a named mob drops the item on the live server.",
        "- A client dungeon encounter name identifies a recognised boss/encounter, not confirmation of that boss's item loot table.",
        "- The Everloot recipe dataset is a separate 1.60.1.70790 client extract; MAF2414 is an older independent extract. Both are informative but neither proves live trainer/vendor/recipe-drop access.",
        "- Material conflict records are retained for manual verification; no automatically inferred recipe learning skill or drop chance is promoted to verified.",
        "- A record absent from an independent catalogue may be hidden, phased or unrevealed, not nonexistent.",
        "- Source notes from nobody174 are reference leads, often explicitly labelled Classic data.",
        "- All generated material Lua changes are **candidate-only**, not added to the addon load order.",
        "- Automated tests validate Lua/code structure; actual overlay, crafting, boss drops and vendor availability require in-client confirmation.",
        "",
        "## Files",
        "- [Complete per-item audit](all_items.csv) (every item ID and class eligibility)",
        "- [Unresolved item queue](unresolved_items.csv)",
        "- [Recipe evidence and material comparison](recipes.csv)",
        "- [Candidate material corrections](material_candidates.json)",
        "- [Candidate-only Lua reagent entries](material_candidates.lua)",
        "- [Evidence provenance and failed lookups](provenance.json)",
        "",
        "## Independent references and attribution",
        "- [Everloot](https://github.com/Everloot/everloot) — client recipe and dungeon encounter extracts; game data © Blizzard.",
        "- [MAF2414 WoW Forever professions research](https://github.com/MAF2414/wow-forever-talents) — older independent client recipe cross-check.",
        "- [AHledger](https://ahledger.com/data) — newer Forever item catalog and observed-data methodology.",
        "- [Road to Forever](https://github.com/nobody174/wow-forever) — independently documented item acquisition leads.",
        "- [ForeverDB](https://foreverdb.net/developers) — additional acquisition research, its bulk API requires approval/key and was **not** queried.",
    ])
    if failures:
        lines.extend(["","## Unavailable sources at run time"])
        for k,v in sorted(failures.items()):lines.append(f"- {k}: `{v}`")
    (out/"README.md").write_text("\n".join(lines)+"\n",encoding="utf8")
    assert all(class_counts[c]>=1000 for c in CLASSES),f"Class completeness regression: {class_counts}"
    assert len(recipes)>=1250 and len(all_rows)==7707
    print(f"AUDIT DONE items={len(all_rows)} unresolved={len(unresolved)} recipes={len(recipes)} candidates={len(fixes)} conflicts={len(major_conflicts)}",flush=True)
    print("CLASS COUNTS",dict(class_counts),flush=True)
    print("ISSUES",dict(issues),flush=True)
    print("METHODS",dict(methods),flush=True)
    print("DUNGEONS",dict(dungeons),flush=True)
    print("MATCHES",dict(match_kind),flush=True)
if __name__=="__main__":main()
