-- Development-only Beta 7 acquisition evidence regression; no WoW client required.
local root=(arg and arg[1]) or "."
local addon={}
local toc=assert(io.open(root.."/GetGear.toc")):read("*a")
local cacheAt,enrichAt,engineAt
for file in toc:gmatch("[^\r\n]+") do
    if file:match("%.lua$") then
        if file=="EquipmentCache.lua" then cacheAt=cacheAt or 0 end
        if file=="SourceEnrichment.lua" then enrichAt=enrichAt or 0 end
        if file=="GuideEngine.lua" then engineAt=engineAt or 0 end
    end
end
local positions={}
local seq=0
local skips={["Core.lua"]=true,["UI.lua"]=true,["AltInventory.lua"]=true}
for file in toc:gmatch("[^\r\n]+") do
    if file:match("%.lua$") then
        seq=seq+1
        positions[file]=seq
        if not skips[file] then
            local chunk,err=loadfile(root.."/"..file)
            assert(chunk,file..": "..tostring(err))
            local ok,result=pcall(chunk,"GetGear",addon)
            assert(ok,file..": "..tostring(result))
        end
    end
end
assert(positions["EquipmentCache.lua"] and positions["SourceEnrichment.lua"] and positions["GuideEngine.lua"])
assert(positions["EquipmentCache.lua"]<positions["SourceEnrichment.lua"]
    and positions["SourceEnrichment.lua"]<positions["GuideEngine.lua"],
    "Apply enrichment after cache and before class index")
local total=0
for id in pairs(addon.ItemCatalog) do
    assert(addon.EquipmentEligibility[id], "No eligibility for "..id)
    total=total+1
end
assert(total==7707,"Beta 7 source-only patch changed catalogue item count")
assert(addon.Beta7Reconciliation.verifiedSourcePatches==8)
local function checkMats(id,expected)
    local item=assert(addon.ItemCatalog[id])
    local actual={}
    for _,r in ipairs(item.reagents or {}) do
        assert(type(r.amount)=="number" and r.amount>0 and type(r.itemID)=="number")
        assert(not actual[r.itemID],"Duplicated reagent "..r.itemID.." for "..id)
        actual[r.itemID]=r.amount
    end
    for ingredient,amount in pairs(expected) do
        assert(actual[ingredient]==amount,
            "Incorrect reagent for "..id.."/"..ingredient)
        actual[ingredient]=nil
    end
    assert(next(actual)==nil,"Unexpected reagent for "..id)
end
local veteran=assert(addon.ItemCatalog[250513])
assert(veteran.name=="Veteran's Chain Belt")
assert(veteran.profession=="Blacksmithing" and veteran.professionSkillRequired==45)
assert(veteran.recipeVendor=="Stondry Darkhammer" and veteran.recipeSpellID==1252262)
assert(veteran.bindingStatus=="bop")
assert(veteran.acquisitionLocation.zone=="Redridge Mountains"
    and veteran.acquisitionLocation.x==8.01 and veteran.acquisitionLocation.y==74.81)
checkMats(250513,{[2840]=12,[3470]=4,[249427]=2,[5498]=2})
-- The old catalogue called item 220606 an Atal'Hakkar dungeon drop.
-- Forever's recipe + Formula item identify the finished relic as Enchanting.
local idol=assert(addon.ItemCatalog[220606])
assert(idol.sourceType=="Enchanting" and idol.profession=="Enchanting")
assert(idol.recipeSpellID==1249128 and idol.recipePatternItemID==249529)
assert(idol.professionSkillRequired==300 and idol.recipeLearnMethod=="pattern")
assert(idol.recipeVendor=="Alynsia" and idol.recipeVendorCost==240)
assert(idol.bindingStatus=="bop" and idol.recipeVendorCurrency=="Merchant's Favor")
checkMats(220606,{[14344]=2,[16203]=4,[16204]=6,[249431]=8,
                   [249430]=4,[249409]=2,[11291]=4})
local hoof=assert(addon.ItemCatalog[274490])
assert(hoof.name=="Centaur Hoofwarmers" and hoof.profession=="Leatherworking")
assert(hoof.professionSkillRequired==165 and hoof.recipeSpellID==1294289
    and hoof.recipePatternItemID==274491 and hoof.recipeLearnMethod=="pattern")
assert(hoof.bindingStatus=="boe" and hoof.recipeVendorCurrency=="Carved Centaur Totem")
assert(hoof.instructions:find("15 Carved Centaur Totems",1,true)
    and hoof.instructions:find("60 totems",1,true)
    and hoof.instructions:find("wearer need not learn Leatherworking",1,true))
assert(hoof.recipeVendorCost==nil and hoof.acquisitionLocation==nil,
    "Two standing-dependent vendors must not become one false global price or waypoint")
checkMats(274490,{[4304]=12,[8343]=2})
assert(addon:GetAcquisitionSummary(idol):find("Alynsia",1,true))
assert(not addon:GetAcquisitionSummary(idol):find("dungeon",1,true))

local golem=assert(addon.ItemCatalog[271098])
assert(golem.name=="Golemguard Chest" and golem.sourceType=="Dungeon")
assert(golem.source:find("Plunder",1,true) and golem.zone=="The Hall of Thanes")
assert(golem.acquisitionLocation==nil,"Do not invent a dungeon map waypoint")
local chest=assert(addon.ItemCatalog[2864])
assert(chest.name=="Runed Copper Breastplate")
assert(chest.profession=="Blacksmithing" and chest.recipeSpellID==2667)
assert(chest.professionSkillRequired==55 and chest.recipeLearnMethod=="pattern")
checkMats(2864,{[2840]=12,[1210]=1,[3470]=2})
-- Reviewed early dungeon drops must not be mislabelled as bosses.
local leggings=assert(addon.ItemCatalog[1943])
assert(leggings.sourceType=="Dungeon trash" and leggings.source:find("Goblin Shipbuilder",1,true))
assert(leggings.acquisitionConfidence=="classic-reference")
assert(addon:GetAcquisitionSummary(leggings):find("The Deadmines",1,true))
assert(addon:GetAcquisitionSummary(leggings):find("Trash:",1,true))
local cutlass=assert(addon.ItemCatalog[1951])
assert(cutlass.sourceType=="Dungeon trash" and cutlass.source:find("Defias Pirate",1,true))
assert(cutlass.source:find("Defias Squallshaper",1,true))
assert(addon:GetAcquisitionSummary(cutlass):find("The Deadmines",1,true))

-- A crafted item can require dropped plans without being a dungeon EQUIPMENT drop.
local guards=assert(addon.ItemCatalog[250489])
assert(guards.profession=="Blacksmithing" and guards.professionSkillRequired==80)
assert(guards.recipeLearnMethod=="pattern" and guards.recipePatternItemID==251341)
assert(guards.recipeAcquisitionKind=="Drop" and guards.bindingStatus=="bop")
checkMats(250489,{[2841]=4,[3470]=2,[1210]=2})
assert(addon:GetAcquisitionSummary(guards):find("Dropped plans",1,true))
assert(addon:GetAcquisitionSummary({profession="Blacksmithing",recipeLearnMethod="pattern",recipeVendor="Stondry Darkhammer"}):find("Stondry Darkhammer",1,true))
assert(addon:GetAcquisitionSummary({sourceType="Dungeon (loot table unverified)",source="Dungeon (loot table unverified)",zone="The Deadmines"}):find("dungeon loot",1,true))

local classes={"PRIEST","MAGE","WARLOCK","DRUID","ROGUE","HUNTER","SHAMAN","WARRIOR","PALADIN"}
for _,class in ipairs(classes) do
    assert(#(addon.EquipmentByClass[class] or {})>=1000,
        "Lost unified class catalogue for "..class)
end
assert(addon.ItemCatalog[6898].schoolOnly==nil,"Mixed-school Orb was changed")
print("PASS Beta 7 evidence overlay: 7707 unchanged identities, nine classes, 8 corrected items, explicit trash/recipe provenance, map/mat evidence")
