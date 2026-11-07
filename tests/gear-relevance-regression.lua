-- Beta 2 class-relevance sanity checks. No live client required.
local root=(arg and arg[1]) or "."
local addon={}
local skipped={["Core.lua"]=true,["UI.lua"]=true,["AltInventory.lua"]=true}
local toc=assert(io.open(root.."/GetGear.toc")):read("*a")
assert(toc:find("GearRelevance.lua",1,true),"gear relevance filter not loaded")
for path in toc:gmatch("[^\r\n]+") do
    if path:match("%.lua$") then
        local chunk,err=loadfile(root.."/"..path)
        assert(chunk,path..": "..tostring(err))
        if not skipped[path] then
            local ok,result=pcall(chunk,"GetGear",addon)
            assert(ok,path..": "..tostring(result))
        end
    end
end
addon.db={status={},hidden={},specialization="All",
    overlay={showAllValidGear=false,filterObsolete=false,hideUncraftableCrafts=false}}
addon.GetObsoleteGearReason=function()return nil end
addon.IsGearEquipped=function()return false end
local function synthetic(id,armor,role)
    return {itemID=id,name="Synthetic relevance test",availableLevel=10,
        targetLevel=10,slot="Chest",fromGeneratedCache=true,
        armorType=armor,statRole=role}
end
local cloth=synthetic(910000,"Cloth","spell")
assert(not addon:ShouldDisplayGear(cloth,"WARRIOR"))
assert(not addon:ShouldDisplayGear(cloth,"ROGUE"))
assert(not addon:ShouldDisplayGear(cloth,"HUNTER"))
assert(addon:ShouldDisplayGear(cloth,"PALADIN"),
    "Holy Paladins must retain spellpower cloth options")
assert(addon:ShouldDisplayGear(cloth,"DRUID") and addon:ShouldDisplayGear(cloth,"SHAMAN"))
assert(addon:ShouldDisplayGear(cloth,"PRIEST"))
local physicalLeather=synthetic(910001,"Leather","physical")
assert(addon:ShouldDisplayGear(physicalLeather,"WARRIOR"),
    "Physical-stat leather can still be a genuine early Warrior upgrade")
assert(addon:ShouldDisplayGear(physicalLeather,"PALADIN"))
local casterLeather=synthetic(910002,"Leather","spell")
assert(not addon:ShouldDisplayGear(casterLeather,"WARRIOR"))
assert(addon:ShouldDisplayGear(casterLeather,"DRUID"))
assert(addon:ShouldDisplayGear(casterLeather,"PALADIN"))
local physicalRing={itemID=910003,name="Physical ring",slot="Ring",
    fromGeneratedCache=true,statRole="physical"}
local casterRing={itemID=910004,name="Spellpower ring",slot="Ring",
    fromGeneratedCache=true,statRole="spell"}
assert(not addon:ShouldDisplayGear(physicalRing,"MAGE"))
assert(not addon:ShouldDisplayGear(casterRing,"WARRIOR"))
assert(addon:ShouldDisplayGear(casterRing,"MAGE"))
local manaMail=synthetic(910007,"Mail","mana")
assert(addon:ShouldDisplayGear(manaMail,"HUNTER"),
    "Hunters use mana and must retain Intellect-only gear")
assert(addon:ShouldDisplayGear(manaMail,"SHAMAN"))
assert(not addon:ShouldDisplayGear(manaMail,"WARRIOR"),
    "Unmixed mana-only Mail is not a normal Warrior upgrade")
local unknownSource={itemID=910008,name="Unverified early item",slot="Ring",
    sourceType="Source not documented",fromGeneratedCache=true,statRole="utility"}
assert(not addon:ShouldDisplayGear(unknownSource,"WARRIOR"),
    "Source-less client artifacts must not dominate default view")
local genericDrop={itemID=910009,name="Generic world-drop candidate",slot="Ring",
    sourceType="World drop (route unverified)",fromGeneratedCache=true,statRole="physical"}
assert(not addon:ShouldDisplayGear(genericDrop,"WARRIOR"),
    "Unconfirmed random world drops should be opt-in")
local observedDrop={itemID=910010,name="Player-observed world drop",slot="Ring",
    sourceType="World drop",confidence="observed",statRole="physical"}
assert(addon:ShouldDisplayGear(observedDrop,"WARRIOR"),
    "Reviewed/observed drops must remain visible")
local utility={itemID=910005,name="Resist-all trinket",slot="Trinket",
    fromGeneratedCache=true,statRole="utility"}
assert(addon:ShouldDisplayGear(utility,"MAGE")
    and addon:ShouldDisplayGear(utility,"WARRIOR"),"Utility gear must not disappear")
local mixed={itemID=910006,name="Hybrid-stat ring",slot="Ring",
    fromGeneratedCache=true,statRole="mixed"}
for _,class in ipairs({"PRIEST","MAGE","WARLOCK","DRUID","ROGUE","HUNTER","SHAMAN","WARRIOR","PALADIN"}) do
    assert(addon:ShouldDisplayGear(mixed,class),"Hybrid ring filtered for "..class)
end
assert(addon:IsHardExcludedGear({itemID=24358,name="QATest +1000 Spell Dmg Ring"}))
assert(addon:IsHardExcludedGear({itemID=281685,name="Restored Cloth Helm"}))
assert(addon:IsHardExcludedGear({itemID=281701,name="Restored Mail Coif"}))
assert(not addon:IsHardExcludedGear({itemID=220874,
    name="Knight-Lieutenant's Restored Leather Helm"}),
    "Do not hide legitimate higher-level Restored PvP equipment")
for _,id in ipairs({21524,21525}) do
    local hat=assert(addon.ItemCatalog[id],"Winter Hat missing from full catalogue")
    assert(not addon:ShouldDisplayGear(hat,"WARRIOR"),
        "Winter Hat leaked into default levelling guide: "..id)
end
addon.db.overlay.showAllValidGear=true
assert(addon:ShouldDisplayGear(cloth,"WARRIOR"))
assert(addon:ShouldDisplayGear(casterRing,"WARRIOR"))
assert(addon:ShouldDisplayGear(physicalRing,"MAGE"))
assert(addon:ShouldDisplayGear(unknownSource,"WARRIOR"),
    "Expanded catalogue must retain unverified candidates")
assert(addon:ShouldDisplayGear(genericDrop,"WARRIOR"))
for _,id in ipairs({21524,21525}) do
    assert(addon:ShouldDisplayGear(addon.ItemCatalog[id],"WARRIOR"))
end
assert(not addon:ShouldDisplayGear({itemID=24358,name="QATest +1000 Spell Dmg Ring"},"WARRIOR"))
assert(not addon:ShouldDisplayGear({itemID=281685,name="Restored Cloth Helm"},"MAGE"))
addon.db.overlay.showAllValidGear=false
-- A previously acquired or manually hidden off-role item remains accessible
-- in history; no saved progress keys are changed.
assert(addon:ShouldDisplayGear(cloth,"WARRIOR","completed"))
assert(addon:ShouldDisplayGear(cloth,"WARRIOR","hidden"))
assert(not addon:ShouldDisplayGear({itemID=24358,name="QA Test"},"WARRIOR","hidden"))
-- Hand-verified GetGear data must not be removed by bulk stat heuristics.
assert(addon:ShouldDisplayGear({itemID=3473,name="Runed Copper Pants"},"WARRIOR"))
assert(addon:ShouldDisplayGear({itemID=3489,name="Thick War Axe"},"WARRIOR"))

UnitClass=function()return "Warrior","WARRIOR" end
UnitFactionGroup=function()return "Alliance" end
UnitRace=function()return "Night Elf","NightElf" end
addon.level=13
addon:SelectCurrentGuide()
local seen={}
for _,item in ipairs(addon:GetItems("available")) do seen[item.itemID]=true end
assert(seen[3473] and seen[3489],"Missing level-13 Warrior gear in default relevance mode")
assert(not seen[21524] and not seen[21525],"Holiday hats leaked into default guide")
assert(not seen[24358] and not seen[281685] and not seen[281701],
    "QA/restoration records leaked into default guide")
addon.db.overlay.showAllValidGear=true
local allSeen={}
for _,item in ipairs(addon:GetItems("available")) do allSeen[item.itemID]=true end
assert(allSeen[21524] and allSeen[21525],"Expanded catalogue did not restore novelty items")
assert(not allSeen[24358] and not allSeen[281685],
    "Expanded catalogue may not restore hard-excluded placeholders")
local ui=assert(io.open(root.."/UI.lua")):read("*a")
assert(ui:find("allValidGearCheck=NewCheck",1,true),"No Show all valid control")
assert(ui:find("ShouldDisplayGear(gear,preview.classToken",1,true),"Preview ignores relevance toggle")
assert(ui:find("allValidGearCheck:SetChecked",1,true),"Settings does not reflect saved toggle")
print("PASS: Beta2 QA exclusions, holiday hats, all-nine class relevance, hybrid/PvP allowances, show-all toggle, progress history, Warrior 13")
