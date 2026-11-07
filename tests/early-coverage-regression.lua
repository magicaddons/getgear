-- Regression: all eligible early classes receive the two items previously
-- absent from GetGear. Source: Forever client equipment/recipe pages.
local root=(arg and arg[1]) or "."
local addon={}
local skip={["Core.lua"]=true,["UI.lua"]=true,["AltInventory.lua"]=true}
local toc=assert(io.open(root.."/GetGear.toc")):read("*a")
assert(toc:find("EarlyCoverage133.lua",1,true),"Missing EarlyCoverage133 module")
for path in toc:gmatch("[^\r\n]+") do
    if path:match("%.lua$") and not skip[path] then
        local chunk,err=loadfile(root.."/"..path)
        assert(chunk,path..": "..tostring(err))
        local ok,result=pcall(chunk,"GetGear",addon)
        assert(ok,path..": "..tostring(result))
    end
end
local expected={
    [3473]={level=8, classes={WARRIOR=true,PALADIN=true},
        mats={[2840]=8,[2320]=3,[3470]=3}},
    [3489]={level=12,classes={WARRIOR=true,PALADIN=true,HUNTER=true,ROGUE=true,SHAMAN=true},
        mats={[2840]=10,[2880]=2,[2842]=2,[3470]=2,[2318]=2}}
}
for itemID,rule in pairs(expected) do
    local facts=assert(addon.ItemCatalog[itemID],"Missing item "..itemID)
    assert(facts.availableLevel==rule.level,"Wrong equip level "..itemID)
    assert(facts.recipeLearnMethod=="trainer","Wrong source "..itemID)
    assert(facts.professionSkillRequired==nil,
        "Do not confuse recipe skill-up thresholds with learning minima: "..itemID)
    local actual={}
    for _,mat in ipairs(facts.reagents or {}) do
        assert(not actual[mat.itemID],"Duplicate reagent ID")
        actual[mat.itemID]=mat.amount
    end
    for matID,amount in pairs(rule.mats) do
        assert(actual[matID]==amount,"Wrong reagent "..matID.." for "..itemID)
    end
    for cls,list in pairs(addon.Recommendations) do
        local total=0
        for _,item in ipairs(list) do
            if item.itemID==itemID then
                total=total+1
                assert(item.targetLevel==rule.level,cls.." has incorrect target level "..itemID)
                assert(item.specs==nil and item.focus=="All",cls.." has spec-restricted "..itemID)
            end
        end
        local want=rule.classes[cls] and 1 or 0
        assert(total==want,cls.." expected "..want.." copies of "..itemID..", got "..total)
    end
end
-- Demonstrate that a level-13 Warrior can see both upgrades when missing,
-- without using the obsolete filter, professions or a spec-biased list.
UnitClass=function() return "Warrior","WARRIOR" end
UnitFactionGroup=function() return "Alliance" end
UnitRace=function() return "Night Elf","NightElf" end
addon.db={status={},hidden={},specialization="All",overlay={filterObsolete=true}}
addon.level=13
addon.IsGearEquipped=function()return false end
addon.GetObsoleteGearReason=function()return nil end
addon:SelectCurrentGuide()
local seen={}
for _,rec in ipairs(addon:GetItems("tracker")) do seen[rec.itemID]=true end
assert(seen[3473] and seen[3489],"Level-13 Warrior missing Runed Copper Pants or Thick War Axe")
print("PASS: Runed Copper Pants and Thick War Axe, 7 cross-class objectives, mats, level-13 Warrior")
