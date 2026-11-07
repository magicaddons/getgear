#!/usr/bin/env python3
"""Build conservative, inspectable school-only damage metadata from a dated
Forever client cache. Never classify mixed/generic spellpower as school-only."""
import argparse
import hashlib
import html
import json
import pathlib
import re
import urllib.request

UPSTREAM = ("https://raw.githubusercontent.com/Napalmsteak/"
            "WoW-Classic-Item-Caches/main/Forever%20Cache.json")
ROOT=pathlib.Path(__file__).resolve().parents[1]
def main():
    p=argparse.ArgumentParser()
    p.add_argument("--output",type=pathlib.Path,required=True)
    a=p.parse_args()
    raw=urllib.request.urlopen(urllib.request.Request(
        UPSTREAM,headers={"User-Agent":"GetGear beta4 data audit"}),timeout=75).read(30_000_000)
    digest=hashlib.sha256(raw).hexdigest()
    generated=(ROOT/"GeneratedForeverGear.lua").read_text(encoding="utf8")
    assert digest in generated,("Source snapshot changed. Refuse to merge evidence "
                                "from a different cache revision: "+digest)
    source=json.loads(raw)
    classes={}
    count=0
    for rec in source:
        if rec.get("itemExpansion")!="Forever":
            continue
        item_id=rec.get("itemId")
        if not isinstance(item_id,int):
            continue
        text=html.unescape(re.sub(r"<[^>]*>"," ",rec.get("tooltipHtml") or ""))
        text=re.sub(r"\s+"," ",text)
        found=set()
        # Use the affected school in an explicit DAMAGE modifier, not the
        # item name, set bonus description or an unrelated resistance line.
        for pattern in (
            r"\+\s*\d+\s+(Fire|Frost|Arcane)\s+(?:Spell\s+)?Damage\b",
            r"damage done by (Fire|Frost|Arcane) spells?(?: and effects)?\b",
            r"(?:(?:Fire|Frost|Arcane)\s+)?spell damage for (Fire|Frost|Arcane)\b",
        ):
            found.update(x.title() for x in re.findall(pattern,text,re.I))
        if len(found)!=1:
            continue
        # A robe that also supplies generic caster stats, healing, resistance
        # or another school's bonus is a mixed-purpose item and must remain.
        neutral=r"(?:\+\s*\d+\s*(?:Intellect|Spirit|Stamina|Strength|Agility|Spell Power|Healing|Mana)\b|" \
                r"all spells?\b|damage done by spells\b|healing done\b|" \
                r"\+\s*\d+\s*(?:Fire|Frost|Arcane|Shadow|Nature|Holy)\s+Resistance\b|" \
                r"attack power\b|mana per 5\b|spell hit\b|spell critical\b|" \
                r"\+\s*\d+\s*(?:Shadow|Nature|Holy)\s+(?:Spell\s+)?Damage\b)"
        if re.search(neutral,text,re.I):
            continue
        classes[item_id]=next(iter(found))
        count+=1
    a.output.parent.mkdir(parents=True,exist_ok=True)
    a.output.write_text("".join(f"{id}\t{classes[id]}\n" for id in sorted(classes)),encoding="utf8")
    print(f"SCHOOL HINTS PASS source_sha={digest} exact_pure_school_items={count}")
    for key in ("Fire","Frost","Arcane"):
        print(key,":",sum(x==key for x in classes.values()))
if __name__=="__main__":
    main()
