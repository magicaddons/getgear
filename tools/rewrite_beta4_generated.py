#!/usr/bin/env python3
"""Convert existing compact Forever cache rows into a fact+eligibility loader.

Unlike Beta 3, this runtime performs NO editorial AddRecommendation calls.
It merges the cache into a small researched-facts overlay, then publishes
an equipability mask for each item. This file is generated into staging
until the Beta 4 cutover and is never mixed with the legacy cache loader.
"""
import argparse
import pathlib

REPLACEMENT=r'''
-- Compact generated equipment; this file must load AFTER ResearchedItemFacts.
-- Source is an October 2026 Forever beta-client snapshot, not live-drop proof.
local audit={newItems=0,eligibility=0}
GetGear.EquipmentEligibility=GetGear.EquipmentEligibility or {}
for _,r in ipairs(rows) do
    local id,name,level,slot,subtype,sourceCode,mask,label,phase,craftOnly,role =
        r[1],r[2],r[3],r[4],r[5],r[6],r[7],r[8],r[9],r[10],r[11]
    if not GetGear.ItemCatalog[id] then
        local description=SOURCES[sourceCode] or SOURCES[1]
        local zone=(label~='' and label or 'Source not yet confirmed')
        if phase>1 then zone=zone..' (future phase possible)' end
        GetGear.ItemCatalog[id]={
            itemID=id,name=name,availableLevel=level,slot=slot,
            armorType=subtype,statRole=role,
            sourceType=description,source=description,zone=zone,
            sourceURL='https://www.wowhead.com/forever/item='..id,
            confidence='client',acquisitionConfidence='classic-reference',
            acquisitionKind=description,craftOnly=craftOnly,
            notes=DEFAULT_NOTE,
            instructions='Client-indexed equipment; specific drop, quest, vendor,'
                ..' or recipe access is unverified in live WoW Forever.',
        }
        audit.newItems=audit.newItems+1
    end
    local facts=GetGear.ItemCatalog[id]
    if not facts.armorType then facts.armorType=subtype end
    if not facts.statRole then facts.statRole=role end
    if GetGear.PureSchoolBonus and GetGear.PureSchoolBonus[id] then
        facts.schoolOnly=GetGear.PureSchoolBonus[id]
    end
    GetGear.EquipmentEligibility[id]={mask,level,subtype}
    audit.eligibility=audit.eligibility+1
end
assert(audit.eligibility>7000,"Forever equipment cache unexpectedly sparse")
local total=0
for _ in pairs(GetGear.ItemCatalog) do total=total+1 end
assert(GetGear.CatalogueAudit and
       total==GetGear.CatalogueAudit.items,
       "Researched and generated catalogue totals disagree: "..total)
GetGear.GeneratedForeverGear=audit
'''
def main():
    p=argparse.ArgumentParser()
    p.add_argument("--input",type=pathlib.Path,required=True)
    p.add_argument("--output",type=pathlib.Path,required=True)
    a=p.parse_args()
    code=a.input.read_text(encoding="utf8")
    needle="local audit={newItems=0,newObjectives=0,existingItems=0,byClass={}}"
    assert code.count(needle)==1,"Unexpected legacy catalogue layout"
    prefix=code.split(needle,1)[0]
    assert "local rows = {" in prefix
    a.output.parent.mkdir(parents=True,exist_ok=True)
    a.output.write_text(prefix+REPLACEMENT,encoding="utf8")
    print("BETA4 GENERATED PASS compact rows preserved, editorial recommendations removed")
if __name__=="__main__":
    main()
