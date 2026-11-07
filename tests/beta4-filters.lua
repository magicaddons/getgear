-- Beta4: age/role/relevance applied uniformly to all equipment sources.
local root=(arg and arg[1]) or "."
local addon={}
local skip={["Core.lua"]=true,["UI.lua"]=true,["AltInventory.lua"]=true}
for file in assert(io.open(root.."/GetGear.toc")):read("*a"):gmatch("[^\r\n]+") do
    if file:match("%.lua$") and not skip[file] then
        local chunk=assert(loadfile(root.."/"..file))
        local ok,err=pcall(chunk,"GetGear",addon)
        assert(ok,file..": "..tostring(err))
    end
end
addon.db={status={},hidden={},overlay={filterObsolete=false,showAllValidGear=false,
    hideUncraftableCrafts=false},detail={}}
addon.IsGearEquipped=function()return false end
addon.GetObsoleteGearReason=function()return nil end
UnitClass=function()return "Warrior","WARRIOR" end
UnitFactionGroup=function()return "Alliance" end
UnitRace=function()return "Night Elf","NightElf" end
addon.level=15;assert(addon:SelectCurrentGuide()>1000)
local function contains(mode,id)
    for _,r in ipairs(addon:GetItems(mode)) do
        if r.itemID==id then return true,r end
    end
    return false
end
for _,id in ipairs({5957,2303,7166,2852}) do
    assert(not contains("available",id),"Level-15 Warrior still recommended early gear "..id)
    assert(contains("earlier",id),"Level-15 earlier gear missing "..id)
end
assert(not contains("available",2572),"Intellect-only Red Linen Robe leaked into Warrior")
assert(not contains("earlier",2572),"Off-role cloth should not be presented as Warrior earlier gear")
assert(contains("available",3489),"Level-12 Thick War Axe should still be current at 15")
assert(not contains("available",3473),"Level-8 Runed Copper Pants should have aged out at 15")
assert(contains("earlier",3473),"Level-8 pants must remain in Earlier Gear")
local quest=assert(addon.ItemCatalog[2933])
assert(quest.earliestPracticalLevel and quest.earliestPracticalLevel>=28)
assert(not contains("available",2933),"Late quest reward must not be presented too early")
assert(contains("upcoming",2933)==false,"Late quest must not be in the next five levels at 15")
addon.level=13
assert(contains("available",3489))
addon.level=16
-- At level 16, target 12 is still 4 levels behind.
assert(contains("available",3489))
addon.level=17
assert(not contains("available",3489) and contains("earlier",3489),
       "Rolling boundary must apply at precisely five levels")
addon.level=15

-- Default excludes unusual/off-role; expanded mode restores class-equippable
-- items but never explicit QA or internal restored placeholders.
addon.db.overlay.showAllValidGear=true
assert(contains("available",5957) and contains("available",2303) and contains("available",7166))
assert(contains("available",2572),"Expanded view should restore Warrior-equippable robe")
assert(not contains("available",24358) and not contains("available",281685))
addon.db.overlay.showAllValidGear=false

-- User progress still works with fresh Beta4 keys and no old migrations.
addon.db.hidden.item_3489=true
assert(contains("hidden",3489) and not contains("available",3489))
addon.db.hidden.item_3489=nil
addon.db.status.item_3489="acquired"
assert(contains("completed",3489) and not contains("available",3489))
addon.db.status.item_3489=nil

-- A synthetic crafted item tests the same five-level boundary in materials
-- scopes without relying on the character's actual profession.
local older={itemID=980001,id="item_980001",name="Test old craft",targetLevel=10,
    availableLevel=10,slot="Legs",statRole="physical",armorType="Mail",
    sourceType="Blacksmithing",reagents={{itemID=980002,amount=7,name="Test material"}}}
addon.Gear[#addon.Gear+1]=older
local function material(scope,id)
    for _,r in ipairs(addon:GetAggregateMaterials(scope)) do
        if r.itemID==id then return r.amount end
    end
    return nil
end
assert(material("tracked",980002)==nil,"Tracked materials include aged gear")
assert(material("all",980002)==7,"All scope must retain older crafted item")
addon.Gear[#addon.Gear]=nil

local activePreview=addon:GetPreviewRecommendations("MAGE")
assert(#activePreview>1000,"Read-only class preview not available")
print("PASS Beta4 Warrior lvl15 excludes all four reported items; aged/role gates, late quests, boundary, status, all-valid, materials and preview")
