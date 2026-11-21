-- Presentation-slot regression: lua5.4 tests/beta4-slot-filters.lua .
local root=(arg and arg[1]) or "."
local addon={}
for path in io.lines(root.."/GetGear.toc") do
    if path:match("%.lua$") and path~="UI.lua" and path~="Core.lua" and path~="AltInventory.lua" then
        assert(loadfile(root.."/"..path))("GetGear",addon)
    end
end
local classes={"PRIEST","MAGE","WARLOCK","DRUID","ROGUE","HUNTER","SHAMAN","WARRIOR","PALADIN"}
local expected={Head="head",Neck="neck",Shoulder="shoulders",Back="back",Chest="chest",
    Wrist="wrists",Hands="hands",Waist="waist",Legs="legs",Feet="feet",Ring="rings",Trinket="trinkets",
    ["Main Hand"]="weapons",["Off Hand"]="offhand",["Two-Hand"]="weapons",
    ["Two-Hand Staff"]="weapons",["Two-Hand Sword"]="weapons",["Two-Hand Mace"]="weapons",
    ["Two-Hand Axe"]="weapons",["Two-Hand Polearm"]="weapons",
    Ranged="ranged",Thrown="ranged",Wand="ranged",Relic="ranged",Bag="bags"}
local function clone(t)
    if type(t)~="table" then return t end
    local copy={}
    for k,v in pairs(t) do copy[k]=clone(v) end
    return copy
end
local function same(actual,want,path)
    path=path or "state"
    assert(type(actual)==type(want),path.." type changed")
    if type(actual)~="table" then assert(actual==want,path.." changed");return end
    for k,v in pairs(want) do same(actual[k],v,path.."."..tostring(k)) end
    for k in pairs(actual) do assert(want[k]~=nil,path.." added "..tostring(k)) end
end
local function sameList(a,b,generated)
    assert(#a==#b,"recommendation count changed")
    for i,item in ipairs(a) do
        if generated then
            -- Acquisition minima may create fresh presentation records on each
            -- engine call; compare their item/level ordering across calls.
            assert(item.id==b[i].id and item.itemID==b[i].itemID and item.targetLevel==b[i].targetLevel,
                "generated item/level order changed at "..i)
        else assert(item==b[i],"record identity/order changed at "..i) end
    end
end
local catalogBefore=clone(addon.ItemCatalog)
local indexesBefore=clone(addon.EquipmentByClass)
local requests=0
C_Item={RequestLoadItemDataByID=function() requests=requests+1 end}
local function checkList(items)
    local original={}
    for i,item in ipairs(items) do original[i]=item end
    for _,entry in ipairs(addon.EquipmentSlotFilters) do
        local slot=entry[1]
        local filtered,total=addon:FilterEquipmentSlots(items,slot)
        assert(total==#items and filtered~=items,"must return a fresh list and original count")
        local want={}
        for _,item in ipairs(items) do
            assert(expected[item.slot],"unclassified catalogue slot: "..tostring(item.slot))
            local matches=slot=="all" or expected[item.slot]==slot
                or (slot=="weapons" and item.slot=="Off Hand"
                    and ({Axe=true,Sword=true,Mace=true,Dagger=true,["Fist Weapon"]=true,["Fist Weapons"]=true})[item.armorType])
            if matches then want[#want+1]=item end
        end
        sameList(filtered,want)
        local seen={}
        for _,item in ipairs(filtered) do
            assert(not seen[item.id],"duplicated item within filtered list")
            seen[item.id]=true
        end
    end
    sameList(items,original)
end
-- Every catalogue record, including items outside the current recommendation window.
for _,class in ipairs(classes) do checkList(addon.EquipmentByClass[class]) end
-- Synthetic equip metadata: classification must never depend on item names.
local inventory={[1]=13,[2]=21,[3]=22,[4]=14,[5]=23,[6]=17}
C_Item.GetItemInventoryTypeByID=function(id) return inventory[id] end
local fixtures={
    {itemID=1,slot="Main Hand",weapons=true,offhand=true},
    {itemID=2,slot="Main Hand",weapons=true,offhand=false},
    {itemID=3,slot="Off Hand",weapons=true,offhand=true},
    {itemID=4,slot="Off Hand",armorType="Shield",weapons=false,offhand=true},
    {itemID=5,slot="Off Hand",armorType="Held In Off-hand",weapons=false,offhand=true},
    {itemID=6,slot="Two-Hand Sword",weapons=true,offhand=false},
}
for _,fixture in ipairs(fixtures) do
    fixture.name="Ring Trinket Shield Sword Bag Head (deliberately misleading)"
    for _,slot in ipairs({"weapons","offhand"}) do
        assert(addon:MatchesEquipmentSlotFilter(fixture,slot)==fixture[slot],"hand compatibility "..fixture.itemID)
    end
end
for _,slot in ipairs({"Ring","Trinket","Wand","Ranged","Thrown","Relic","Bag"}) do
    assert(addon:MatchesEquipmentSlotFilter({slot=slot},expected[slot]))
end
C_Item.GetItemInventoryTypeByID=function() error("metadata unavailable") end
assert(not addon:MatchesEquipmentSlotFilter({slot="Main Hand",itemID=1},"offhand"))
assert(addon:MatchesEquipmentSlotFilter({slot="Off Hand",itemID=1,armorType="Dagger"},"weapons"))
assert(not addon:MatchesEquipmentSlotFilter({slot="Off Hand",itemID=1,armorType="Shield"},"weapons"))
issecretvalue=function() return true end
C_Item.GetItemInventoryTypeByID=function() return 13 end
assert(not addon:MatchesEquipmentSlotFilter({slot="Main Hand",itemID=1},"offhand"))
issecretvalue=nil
C_Item.GetItemInventoryTypeByID=nil
local locations={[1]="INVTYPE_WEAPON",[2]="INVTYPE_WEAPONMAINHAND",[3]="INVTYPE_WEAPONOFFHAND",
    [4]="INVTYPE_SHIELD",[5]="INVTYPE_HOLDABLE",[6]="INVTYPE_2HWEAPON"}
C_Item.GetItemInfoInstant=function(id) return id,"misleading type","misleading subtype",locations[id] end
for _,fixture in ipairs(fixtures) do
    for _,slot in ipairs({"weapons","offhand"}) do
        assert(addon:MatchesEquipmentSlotFilter(fixture,slot)==fixture[slot],"instant equip-location fallback")
    end
end
GetItemInfoInstant=C_Item.GetItemInfoInstant
C_Item.GetItemInfoInstant=nil
assert(addon:MatchesEquipmentSlotFilter(fixtures[1],"offhand"),"legacy instant API fallback")
GetItemInfoInstant=nil
assert(#addon:FilterEquipmentSlots({{slot="Future Slot"}},"all")==1)
assert(#addon:FilterEquipmentSlots({{slot="Future Slot"}},"head")==0)
for _,bad in ipairs({false,17,"removed","HEAD",{}}) do
    assert(addon:NormalizeEquipmentSlotFilter(bad)=="all")
end
assert(addon:NormalizeEquipmentSlotFilter(nil)=="all")
assert(addon:EquipmentSlotCountText(8,117)=="Showing 8 of 117 recommendations")
assert(addon:EquipmentSlotCountText(50,117,32)=="Showing 32 of 117 (50 slot matches)")

-- Real visibility/eligibility, with only live inventory/talent APIs stubbed.
local faction,class,level="Alliance","PRIEST",1
UnitFactionGroup=function() return faction end
UnitClass=function() return class,class end
UnitRace=function() return "Human","Human" end
UnitLevel=function() return level end
local equipped={}
addon.IsGearEquipped=function(_,item) return equipped[item.id]==true end
addon.GetObsoleteGearReason=function() return nil end
local bags={{id="test_bag",itemID=4238,slot="Bag",bagUpgrade=true,targetLevel=1}}
addon.GetBagPlanningObjectives=function() return bags end
local scenarios,large=0,0
-- Full catalogue classification above covers every target level. Exercise the
-- real (source-aware) engine at representative levels and the 39/40 proficiency
-- boundary; repeating every unchanged view at all 60 levels exceeds the CI
-- budget without adding slot-classification coverage.
local levels={1,15,30,39,40,45,60}
for _,f in ipairs({"Alliance","Horde"}) do
    faction=f
    for _,c in ipairs(classes) do
        class=c
        addon:SelectCurrentGuide()
        addon.db={schemaVersion=4,overlay={showAllValidGear=false,slotFilter="all"},detail={slotFilter="all"},status={},hidden={}}
        equipped={}
        for i,item in ipairs(addon.Gear) do
            if i%127==0 then addon.db.hidden[item.id]=true
            elseif i%131==0 then addon.db.status[item.id]="acquired"
            elseif i%137==0 then addon.db.status[item.id]="skipped"
            elseif i%139==0 then equipped[item.id]=true end
        end
        for _,n in ipairs(levels) do
            level=n;addon.level=n
            local stateBefore=clone(addon.db)
            for _,mode in ipairs({"available","upcoming","earlier","completed","hidden","tracker","bags"}) do
                local unfiltered=addon:GetItems(mode)
                if #unfiltered>100 then large=large+1 end
                checkList(unfiltered)
                addon:SetEquipmentSlotFilter("overlay","chest")
                addon:SetEquipmentSlotFilter("detail","weapons")
                sameList(addon:GetItems(mode),unfiltered,true)
                addon:SetEquipmentSlotFilter("overlay","all")
                addon:SetEquipmentSlotFilter("detail","all")
            end
            -- Preview uses each class's own index, even for Horde/another live class.
            if n==1 or n==40 or n==60 then
                for _,previewClass in ipairs(classes) do
                    local list={}
                    for _,item in ipairs(addon:GetPreviewRecommendations(previewClass)) do
                        if item.targetLevel<=n and addon:ShouldDisplayGear(item,previewClass,"preview") then list[#list+1]=item end
                    end
                    checkList(list)
                end
            end
            same(addon.db,stateBefore)
            if n==1 or n==30 or n==60 then
                -- Aggregated inventory/material consumers retain their own
                -- complete recommendation inputs regardless of either UI.
                local aggregate=clone(addon:GetAggregateMaterials("tracked"))
                local combined=clone(addon:GetCombinedMaterialRows("tracked"))
                addon:SetEquipmentSlotFilter("overlay","head")
                addon:SetEquipmentSlotFilter("detail","offhand")
                same(addon:GetAggregateMaterials("tracked"),aggregate)
                same(addon:GetCombinedMaterialRows("tracked"),combined)
                addon:SetEquipmentSlotFilter("overlay","all")
                addon:SetEquipmentSlotFilter("detail","all")
            end
            scenarios=scenarios+1
        end
    end
end
assert(scenarios==126 and large>0,"missing class/faction/level or large-list coverage")
assert(requests==0,"presentation filtering requested item loads")

-- Exercise the real SavedVariables initializer and progress methods.
local events
CreateFrame=function()
    events={RegisterEvent=function() end,SetScript=function(self,key,fn) self[key]=fn end}
    return events
end
SlashCmdList={}
assert(loadfile(root.."/Core.lua"))("GetGear",addon)
local function loadCharacter(db)
    GetGear_CharacterDB=db
    -- ADDON_LOADED runs in a fresh Lua VM on reload/relog. Do not carry the
    -- previous matrix character's class into the existing priority defaults.
    addon.classToken=nil
    events.OnEvent(events,"ADDON_LOADED","GetGear")
    return addon.db
end
faction="Alliance";class="ROGUE";level=30
local old={schemaVersion=4,status={keep="skipped"},hidden={stay=true},
    overlay={scale=1.2,expanded={keep=true},materialScope="all"},detail={width=900}}
local db=loadCharacter(old)
assert(db==old and db.schemaVersion==4 and db.overlay.slotFilter=="all" and db.detail.slotFilter=="all")
assert(db.status.keep=="skipped" and db.hidden.stay and db.overlay.expanded.keep and db.overlay.scale==1.2 and db.detail.width==900)
addon:SetEquipmentSlotFilter("overlay","chest")
addon:SetEquipmentSlotFilter("detail","weapons")
local before=clone(db)
loadCharacter(db) -- /reload retains both preferences and unrelated values
same(db,before)
assert(addon:GetEquipmentSlotFilter("overlay")=="chest" and addon:GetEquipmentSlotFilter("detail")=="weapons")
local firstCharacter=db
loadCharacter(nil)
assert(addon:GetEquipmentSlotFilter("overlay")=="all" and addon:GetEquipmentSlotFilter("detail")=="all")
loadCharacter(firstCharacter)
assert(addon:GetEquipmentSlotFilter("overlay")=="chest" and addon:GetEquipmentSlotFilter("detail")=="weapons")
addon.db.overlay.slotFilter="retired";addon.db.detail.slotFilter={}
loadCharacter(addon.db)
assert(addon.db.overlay.slotFilter=="all" and addon.db.detail.slotFilter=="all")
local gear=assert(addon:GetItems("available")[1],"need an eligible recommendation for progress actions")
addon:SetEquipmentSlotFilter("overlay",expected[gear.slot])
addon:SetEquipmentSlotFilter("detail",expected[gear.slot])
addon:SetHidden(gear,true)
assert(addon:IsHidden(gear))
local function contains(items,item) for _,g in ipairs(items) do if g==item then return true end end return false end
assert(contains(addon:FilterEquipmentSlots(addon:GetItems("hidden"),expected[gear.slot]),gear))
assert(not contains(addon:GetItems("tracker"),gear))
addon:SetEquipmentSlotFilter("overlay","all")
loadCharacter(addon.db)
assert(addon:IsHidden(gear) and not contains(addon:GetItems("tracker"),gear))
addon:SetHidden(gear,false)
addon:SetStatus(gear,"skipped")
assert(contains(addon:FilterEquipmentSlots(addon:GetItems("completed"),expected[gear.slot]),gear))
addon:SetStatus(gear,nil)
assert(not addon:GetStatus(gear) and not addon:IsHidden(gear))
same(addon.ItemCatalog,catalogBefore,"catalogue")
same(addon.EquipmentByClass,indexesBefore,"class indexes")
print("PASS slot filters: entire catalogue/all target levels, 126 class/faction/boundary-level scenarios, all views, large lists, preview, metadata overlap/failure, independent character saves, Hide/Unhide and progress; 0 item loads")
