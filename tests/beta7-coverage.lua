-- Beta 7 full-client-cache evidence and source-boundary regression.
-- This is an offline data test, NOT proof of 2026 live availability.
local root=(arg and arg[1]) or "."
local a={}
for _,path in ipairs({
    "ResearchedItemFacts.lua",
    "EquipmentCache.lua",
    "GeneratedBeta7Evidence.lua",
    "SourceEnrichment.lua",
    "GuideEngine.lua",
}) do
    local fn,err=loadfile(root.."/"..path)
    assert(fn,path..": "..tostring(err))
    local ok,result=pcall(fn,"GetGear",a)
    assert(ok,path..": "..tostring(result))
end
local count=0
for id,item in pairs(a.ItemCatalog) do
    count=count+1
    assert(item.itemID==id and a.EquipmentEligibility[id],
        "Evidence index changed identity or eligibility: "..tostring(id))
    if item.reagents then
        for _,mat in ipairs(item.reagents) do
            assert(type(mat.itemID)=="number" and mat.itemID>0
                and type(mat.amount)=="number" and mat.amount>0
                and type(mat.name)=="string" and mat.name~="",
                "Invalid reagent for "..id)
        end
    end
end
assert(count==7707,"Catalogue changed from 7,707: "..count)
assert(a.CatalogueAudit.objectives==36341,"Class objectives changed")
local classes={"PRIEST","MAGE","WARLOCK","DRUID","ROGUE","HUNTER","SHAMAN","WARRIOR","PALADIN"}
for _,c in ipairs(classes) do
    assert(#(a.EquipmentByClass[c] or {})>=1000,c.." catalogue lost")
end
local report=assert(a.Beta7GeneratedEvidence)
-- Exact values from the frozen Nov 8 source snapshot, not an estimate.
assert(report.recipe==1060,"Missing expected 1,060 newly detailed crafts: "..tostring(report.recipe))
assert(report.reagentConflicts==43 and report.reagentCorrections==43,
    "Unexpected recipe discrepancy count: "..tostring(report.reagentConflicts))
assert(report.dungeonEnemy==415,"Dungeon enemy source regression "..tostring(report.dungeonEnemy))
assert(report.vendor==55,"Vendor source regression "..tostring(report.vendor))
assert(report.quest==27,"Quest source regression "..tostring(report.quest))
local function hasIngredient(id,ingredient,quantity)
    local item=assert(a.ItemCatalog[id])
    for _,mat in ipairs(item.reagents or {}) do
        if mat.itemID==ingredient then
            assert(mat.amount==quantity,"Wrong reagent quantity "..id.." / "..ingredient)
            return
        end
    end
    error("Missing reagent "..id.." / "..ingredient)
end
hasIngredient(3480,3478,1) -- Coarse Grinding Stone, not Heavy
hasIngredient(8203,4304,12) -- Thick Leather, not Heavy
hasIngredient(250518,3478,6) -- Coarse Grinding Stone
hasIngredient(2864,2840,12)
hasIngredient(2864,1210,1)
hasIngredient(2864,3470,2)
local belt=assert(a.ItemCatalog[250513])
assert(belt.recipeVendor=="Stondry Darkhammer")
assert(belt.professionSkillRequired==45 and belt.recipeSpellID==1252262)
local chest=assert(a.ItemCatalog[271098])
assert(chest.source:find("Plunder",1,true))
local copper=assert(a.ItemCatalog[2864])
assert(copper.recipeLearningSourceURL:find("item=2881",1,true))
local wand=assert(a.ItemCatalog[217287])
assert(wand.recipeSpellID==14810,"Greater Mystic Wand default variant changed")
print("PASS full Beta7: 7707 items, 36341 class objectives, nine classes, 1060 new recipes, 43 corrections, 415 named dungeon enemies (not necessarily bosses), 55 vendor, 27 quest")
