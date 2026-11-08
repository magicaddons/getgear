#!/usr/bin/env python3
"""Generate reviewable Forever Beta 7 acquisition facts from a frozen source snapshot.

Inputs are a dated Forever client cache, a dated client recipe export and EG Link
player-contributed observations. This never claims live stock, drop rates, quest
access, recipe learn skill or a boss kill merely from a client record.
Generated Lua overlays the original cache; reviewed GetGear facts have priority
except exact reagent conflicts, which are flagged and corrected to dated spells.
"""
import argparse
import collections
import csv
import json
import pathlib
import re

ROW = re.compile(r'^\s*\{(\d+),"((?:\\.|[^"\\])*)",(\d+),"((?:\\.|[^"\\])*)","((?:\\.|[^"\\])*)",(\d+),(\d+),"((?:\\.|[^"\\])*)",(\d+),(true|false),"((?:\\.|[^"\\])*)"\},', re.M)
CATEGORIES = {1:"other",2:"drop",3:"vendor",4:"quest",5:"crafted",6:"dungeon",7:"pvp"}
def read(p):
    return json.loads(pathlib.Path(p).read_text(encoding="utf-8"))
def quote(v):
    return json.dumps(str(v), ensure_ascii=True)
def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--source",required=True,type=pathlib.Path)
    ap.add_argument("--equipment-cache",required=True,type=pathlib.Path)
    ap.add_argument("--out",required=True,type=pathlib.Path)
    args=ap.parse_args()
    args.out.mkdir(parents=True,exist_ok=True)
    matches=ROW.findall(args.equipment_cache.read_text(encoding="utf-8"))
    rows={int(v[0]):dict(id=int(v[0]),name=v[1],level=int(v[2]),sourceCode=int(v[5]),sourceLabel=v[7]) for v in matches}
    if len(rows)!=7678:raise ValueError("Expected 7,678 dated equipment-cache records, found "+str(len(rows)))
    cache={v["itemId"]:v for v in read(args.source/"ForeverCache.json")}
    tome=read(args.source/"ForeverTomeRecipes.json")
    names={i["id"]:i["name"] for i in tome["items"] if i.get("id") and i.get("name")}
    names.update({i["itemId"]:i["name"] for i in cache.values() if i.get("name")})
    professions={p["id"]:p["name"] for p in tome["professions"]}
    outputs=collections.defaultdict(list)
    for recipe in tome["recipes"]:
        for out in recipe.get("outputs",[]):
            if out.get("itemId"):outputs[out["itemId"]].append(recipe)
    observedVendors=collections.defaultdict(dict)
    observedQuests=collections.defaultdict(dict)
    observedDrops=collections.defaultdict(set)
    for file in sorted((args.source/"eg").glob("*/vendors.json")):
        build=file.parent.name
        for npcId,npc in read(file).get("vendors",{}).items():
            for entry in npc.get("entries",{}).values():
                iid=entry.get("itemId")
                if iid in rows and rows[iid]["sourceCode"]==3 and npc.get("name"):
                    observedVendors[iid][npcId]=(npc["name"],build,entry.get("sources",0))
    for file in sorted((args.source/"eg").glob("*/quests.enUS.json")):
        build=file.parent.name
        for qid,quest in read(file).get("quests",{}).items():
            title=quest.get("title","")
            if not title or re.search(r"\btest\b|dummy|placeholder|debug",title,re.I):continue
            for category in ("items","choices"):
                for reward in quest.get("rewards",{}).get(category,[]):
                    iid=reward.get("itemId")
                    if iid in rows and rows[iid]["sourceCode"]==4:
                        observedQuests[iid][qid]=(title,build,quest.get("sources",0))
    for file in sorted((args.source/"eg").glob("*/loot.json")):
        build=file.parent.name
        for key,entry in read(file).get("sources",{}).items():
            if key.startswith("npc:"):
                for textId,detail in entry.get("items",{}).items():
                    iid=int(textId)
                    if iid in rows and rows[iid]["sourceCode"] in (2,6):
                        observedDrops[iid].add(key+"@"+build)
    recipes,acquisition,audit=[],[],[]
    selected=collections.Counter()
    exceptions=[]
    for iid,row in sorted(rows.items()):
        category=CATEGORIES[row["sourceCode"]]
        rec=dict(itemId=iid,name=row["name"],category=category,sourceLabel=row["sourceLabel"],confidence="unverified",evidence="dated Forever client cache",gap="",generated=False)
        if category=="crafted":
            candidates=outputs.get(iid,[])
            if not candidates:raise AssertionError(f"No client recipe for crafted item {iid}: {row['name']}")
            if len(candidates)>1:
                if iid!=217287 or not any(c["id"]==14810 for c in candidates):
                    raise AssertionError(f"Unexpected multiple recipe variants for {iid}")
                chosen=next(c for c in candidates if c["id"]==14810)
                exceptions.append(dict(itemId=iid,name=row["name"],selectedSpell=14810,alternatives=[dict(spellId=c["id"],reagents=c.get("reagents")) for c in candidates]))
                rec["gap"]="Other recipe spell 439134 has different inputs; selected default 14810"
            else:chosen=candidates[0]
            materials=sorted((part["itemId"],part["quantity"]) for part in chosen.get("reagents",[]))
            if not materials or any(q<=0 or mid not in names for mid,q in materials):
                raise AssertionError(f"Unknown reagent or invalid material count for {iid}")
            profession=professions.get(chosen["professionId"])
            if not profession:raise AssertionError(f"Unrecognized profession for {iid}")
            recipes.append((iid,profession,chosen["id"],[(mid,names[mid],q) for mid,q in materials]))
            selected["crafted"]+=1
            rec.update(confidence="published-client-recipe",evidence="ForeverTome client recipe 2026-10-31",generated=True)
            if not rec["gap"]:rec["gap"]="Learning source/threshold not verified"
        elif category=="dungeon":
            # Upstream bossNames also contains regular trash mobs; do not assert boss status.
            bosses=sorted({s for s in cache.get(iid,{}).get("bossNames",[]) if s and "unknown" not in s.lower()})
            if bosses:
                acquisition.append((iid,6," / ".join(bosses)))
                selected["dungeon"]+=1
                rec.update(confidence="client-reference",evidence="Forever client cache 2026-10-21",generated=True)
                rec["gap"]="Named dungeon enemy is a client reference, not observed live loot"
            else:rec["gap"]="Specific dungeon enemy unverified"
        elif category=="vendor":
            vendors=sorted({name for name,build,src in observedVendors.get(iid,{}).values()})
            if vendors:
                acquisition.append((iid,3," / ".join(vendors[:4])))
                selected["vendor"]+=1
                rec.update(confidence="observed-sampled-vendor-window",evidence="EG Link Forever player observations Nov 2026",generated=True)
                rec["gap"]="Live stock/faction/access not verified"
            else:rec["gap"]="Vendor unknown in observed client sessions"
        elif category=="quest":
            quests=sorted({name for name,build,src in observedQuests.get(iid,{}).values()})
            if quests:
                acquisition.append((iid,4," / ".join(quests[:4])))
                selected["quest"]+=1
                rec.update(confidence="client-reference",evidence="EG Link cached Forever quest rewards",generated=True)
                rec["gap"]="Quest eligibility, chain/faction not verified"
            else:rec["gap"]="Quest ID and accessibility unverified"
        elif category=="drop":
            rec["gap"]="No named world-drop source"
        else:rec["gap"]="Source identity unavailable"
        if iid in observedDrops:rec["liveLootObservationGroups"]=len(observedDrops[iid])
        audit.append(rec)
    assert selected["crafted"]==1244 and selected["dungeon"]==447 and selected["vendor"]==56 and selected["quest"]==27,dict(selected)
    lines=[
        "local addonName, GetGear = ...",
        "-- GENERATED evidence from frozen source export: not a confirmed live drop catalogue.",
        "-- Do not infer learning skill, player faction, vendor availability, or item binding.",
        "local recipes = {"
    ]
    for iid,prof,spell,materials in recipes:
        inputs=",".join("{"+str(mid)+","+quote(name)+","+str(q)+"}" for mid,name,q in materials)
        lines.append(f" [{iid}]={{{quote(prof)},{spell},{{{inputs}}}}},")
    lines.append("}")
    lines.append("local acquisition = {")
    for iid,kind,label in acquisition:
        lines.append(f" [{iid}]={{{kind},{quote(label)}}},")
    lines.extend([
        "}",
        "local counts={recipe=0,dungeonEnemy=0,vendor=0,quest=0,reagentConflicts=0,reagentCorrections=0}",
        "for id, record in pairs(recipes) do",
        ' local item=assert(GetGear.ItemCatalog[id],"Missing Beta7 item "..id)',
        " local profession,spell,inputs=record[1],record[2],record[3]",
        " if not item.profession then item.profession=profession end",
        " if not item.recipeSpellID then item.recipeSpellID=spell end",
        ' if type(item.reagents)~="table" or #item.reagents==0 then',
        "  local materials={}",
        "  for _,r in ipairs(inputs) do materials[#materials+1]={itemID=r[1],name=r[2],amount=r[3]} end",
        "  item.reagents=materials;counts.recipe=counts.recipe+1",
        " else",
        "  local expected,actual={},{}",
        "  for _,r in ipairs(inputs) do expected[r[1]]=r[3] end",
        "  for _,r in ipairs(item.reagents) do actual[r.itemID]=r.amount end",
        "  local conflict=false",
        "  for id,qty in pairs(expected) do if actual[id]~=qty then conflict=true;break end end",
        "  if not conflict then for id in pairs(actual) do if not expected[id] then conflict=true;break end end end",
        "  if conflict then",
        "   counts.reagentConflicts=counts.reagentConflicts+1",
        "   local corrected={}",
        "   for _,r in ipairs(inputs) do corrected[#corrected+1]={itemID=r[1],name=r[2],amount=r[3]} end",
        "   item.reagents=corrected;counts.reagentCorrections=counts.reagentCorrections+1",
        '   item.reagentEvidence="2026-10-31 Forever client recipe; previous hand-reviewed input differs"',
        "  end",
        " end",
        ' if item.sourceType=="Crafted gear (recipe details unverified)" then',
        "  item.sourceType=profession",
        '  item.source=profession.." recipe (learning source unverified)"',
        '  item.acquisitionKind="Crafting"',
        '  item.acquisitionConfidence="published-client-recipe"',
        '  item.recipeLearnSkillEvidence="unverified"',
        " end",
        "end",
        "for id,src in pairs(acquisition) do",
        ' local item=assert(GetGear.ItemCatalog[id],"Missing source item "..id)',
        " local kind,label=src[1],src[2]",
        ' if kind==6 and item.sourceType=="Dungeon (loot table unverified)" then',
        '  item.source="Dungeon enemy: "..label.." (dated client reference; live loot unverified)"',
        '  item.acquisitionKind="Dungeon enemy (client reference)"',
        '  item.acquisitionConfidence="client";counts.dungeonEnemy=counts.dungeonEnemy+1',
        ' elseif kind==3 and item.sourceType=="Vendor (availability unverified)" then',
        '  item.source="Seen sold by "..label.." (sampled Forever vendor window; verify faction and stock)"',
        '  item.acquisitionKind="Vendor (observed inventory)"',
        '  item.acquisitionConfidence="reported";counts.vendor=counts.vendor+1',
        ' elseif kind==4 and item.sourceType=="Quest reward (eligibility unverified)" then',
        '  item.source="Quest reward: "..label.." (client record; eligibility unverified)"',
        '  item.acquisitionKind="Quest (client reference)"',
        '  item.acquisitionConfidence="client";counts.quest=counts.quest+1',
        " end",
        "end",
        "GetGear.Beta7GeneratedEvidence=counts",
        'assert(counts.recipe>=1000,"Crafting source coverage lost")',
    ])
    (args.out/"GeneratedBeta7Evidence.lua").write_text("\n".join(lines)+"\n",encoding="utf-8")
    summary=dict(baseCache=len(rows),totalCatalogueWithManual=7707,sourceCategoryCounts=dict(collections.Counter(r["category"] for r in audit)),enrichedByCategory=dict(selected),remainingVendorUnknown=1495-selected["vendor"],remainingQuestUnknown=231-selected["quest"],remainingDungeonBossUnknown=554-selected["dungeon"],multipleRecipeVariants=exceptions,sourceFrozen="2026-11-08 source export; vendor/quest sessions limited",reliabilityNotes=["Client cache does not prove live obtainability","Profession skill colours are not learn minima","Alliance eligibility for observed quests/vendors unverified"])
    (args.out/"Beta7-audit-summary.json").write_text(json.dumps(summary,indent=2)+"\n",encoding="utf-8")
    with (args.out/"Beta7-item-level-audit.csv").open("w",newline="",encoding="utf-8") as fp:
        w=csv.DictWriter(fp,fieldnames=["itemId","name","category","sourceLabel","confidence","evidence","gap","generated","liveLootObservationGroups"],extrasaction="ignore")
        w.writeheader()
        for record in audit:w.writerow(record)
    print(json.dumps(summary,indent=2))
if __name__=="__main__":main()
