-- Offline regression for default-on, overlay-only confirmed stat filtering.
-- Run: lua5.4 tests/overlay-stat-filter.lua .
local root=(arg and arg[1]) or "."
local addon={}
assert(loadfile(root.."/GearCompare.lua"))("GetGear",addon)
assert(loadfile(root.."/GuideState.lua"))("GetGear",addon)
addon.db={overlay={hideWithoutPositiveStats=true,filterObsolete=false,
    countArmorOnlyUpgrades=false},
    status={},hidden={}}
addon.GetObsoleteGearReason=function() return nil end
addon.level=10
local statData={
    ["item:100"]={ITEM_MOD_STRENGTH_SHORT=10,ITEM_MOD_STAMINA_SHORT=8,
        ITEM_MOD_ARMOR_SHORT=100},
    ["item:101"]={ITEM_MOD_STRENGTH_SHORT=8,ITEM_MOD_STAMINA_SHORT=8}, -- negative only
    ["item:102"]={ITEM_MOD_STRENGTH_SHORT=10,ITEM_MOD_STAMINA_SHORT=8}, -- unchanged
    ["item:103"]={ITEM_MOD_STRENGTH_SHORT=11,ITEM_MOD_STAMINA_SHORT=6}, -- mixed
    ["item:104"]={ITEM_MOD_STRENGTH_SHORT=12,ITEM_MOD_STAMINA_SHORT=8}, -- positive only
    ["item:200"]={ITEM_MOD_STRENGTH_SHORT=3},
    ["item:201"]={ITEM_MOD_STRENGTH_SHORT=8},
    ["item:202"]={ITEM_MOD_STRENGTH_SHORT=5},
    ["item:203"]={ITEM_MOD_STRENGTH_SHORT=2},
    -- A caster downgrades every primary stat but gains 35 ordinary armor.
    ["item:106"]={ITEM_MOD_STRENGTH_SHORT=8,ITEM_MOD_STAMINA_SHORT=6,
        ITEM_MOD_ARMOR_SHORT=135},
    ["item:107"]={ITEM_MOD_STRENGTH_SHORT=8,ITEM_MOD_STAMINA_SHORT=6,
        RESISTANCE0_NAME=135}, -- second known client key
    ["item:108"]={ITEM_MOD_STRENGTH_SHORT=11,ITEM_MOD_STAMINA_SHORT=6,
        ITEM_MOD_ARMOR_SHORT=135}, -- real improvement despite negative stamina
    ["item:109"]={ITEM_MOD_STRENGTH_SHORT=10,ITEM_MOD_STAMINA_SHORT=8,
        ITEM_MOD_ARMOR_SHORT=135}, -- only armor differs
    ["item:110"]={ITEM_MOD_STRENGTH_SHORT=10,ITEM_MOD_STAMINA_SHORT=8,
        RESISTANCE2_NAME=5}, -- Frost resistance is NOT ordinary armor
    ["item:111"]={ITEM_MOD_STRENGTH_SHORT=8,ITEM_MOD_STAMINA_SHORT=6,
        ITEM_MOD_ARMOR_SHORT=135,RESISTANCE2_NAME=5},
}
C_Item={GetItemStats=function(link) return statData[link] end}
GetInventoryItemLink=function(_,slot)
    if slot==7 then return "item:100" end
    if slot==11 then return "item:200" end
    if slot==12 then return "item:201" end
end
local requests=0
addon.RequestItemDataOnce=function() requests=requests+1 end
local function item(id,slot)
    return {id="item_"..id,itemID=id,slot=slot or "Legs",targetLevel=10,
        name="Synthetic "..id,reagents={{itemID=10000+id,name="Mat "..id,amount=1}}}
end
local negative,flat,mixed,positive,unknown =
    item(101),item(102),item(103),item(104),item(105)
assert(addon:ShouldShowOverlayStatChanges(negative)==false,"Negative-only must hide")
assert(addon:ShouldShowOverlayStatChanges(flat)==false,"No changes must hide")
assert(addon:ShouldShowOverlayStatChanges(mixed)==true,"Any positive delta must show")
assert(addon:ShouldShowOverlayStatChanges(positive)==true,"Positive-only must show")
assert(addon:ShouldShowOverlayStatChanges(unknown)==true,"Unknown stats must not disappear")
local armorOnly=item(106)
local armorAlias=item(107)
local realGain=item(108)
local pureArmor=item(109)
local resistance=item(110)
local armorPlusResistance=item(111)
for _,class in ipairs({"PRIEST","MAGE","WARLOCK","WARRIOR","PALADIN",
    "DRUID","ROGUE","HUNTER","SHAMAN"}) do
    addon.classToken=class
    assert(addon:ShouldShowOverlayStatChanges(armorOnly)==false,
        class.." must not show armor gain as the only positive")
    assert(addon:ShouldShowOverlayStatChanges(armorAlias)==false,
        class.." must also exclude RESISTANCE0_NAME positive")
    assert(addon:ShouldShowOverlayStatChanges(pureArmor)==false,
        class.." must hide otherwise unchanged armor-only gear")
    assert(addon:ShouldShowOverlayStatChanges(realGain)==true,
        class.." must preserve positive non-armor changes")
    assert(addon:ShouldShowOverlayStatChanges(resistance)==true,
        class.." should keep positive Frost resistance")
    assert(addon:ShouldShowOverlayStatChanges(armorPlusResistance)==true)
end
addon.classToken="PRIEST"
addon.db.overlay.countArmorOnlyUpgrades=true
assert(addon:ShouldShowOverlayStatChanges(armorOnly)==true,
    "Opt-in must restore armor-only with other negative stats")
assert(addon:ShouldShowOverlayStatChanges(armorAlias)==true,
    "Opt-in must restore alternative armor key")
addon.db.overlay.countArmorOnlyUpgrades=false
assert(requests==0,"Bulk overlay filtering must never request uncached item data")
assert(addon:ShouldShowOverlayStatChanges({bagUpgrade=true})==true,"Bag objectives stay")
local ringUpgrade=item(202,"Ring")
local ringDowngrade=item(203,"Ring")
assert(addon:ShouldShowOverlayStatChanges(ringUpgrade)==true,
    "Positive against first ring must show despite downgrade against second")
assert(addon:ShouldShowOverlayStatChanges(ringDowngrade)==false,
    "Ring downgrade against both slots must hide")
-- No occupied comparison slot is UNKNOWN, not proof of zero advantage.
GetInventoryItemLink=function() return nil end
assert(addon:ShouldShowOverlayStatChanges(negative)==true,
    "Empty equipment slot must stay visible")
GetInventoryItemLink=function(_,slot)
    if slot==7 then return "item:100" end
    if slot==11 then return "item:200" end
    if slot==12 then return "item:201" end
end
addon.Gear={negative,flat,mixed,positive,unknown,armorOnly,armorAlias,
    realGain,pureArmor,resistance,armorPlusResistance}
local function has(rows,id)
    for _,r in ipairs(rows) do if r.itemID==id then return true end end
    return false
end
assert(has(addon:GetItems("tracker"),101) and has(addon:GetItems("available"),101),
    "Overlay filter must never remove catalogue/guide records")
local tracked=addon:GetAggregateMaterials("tracked")
local all=addon:GetAggregateMaterials("all")
local function hasMat(rows,id)
    for _,r in ipairs(rows) do if r.itemID==10000+id then return true end end
    return false
end
assert(not hasMat(tracked,101) and not hasMat(tracked,102)
    and hasMat(tracked,103) and hasMat(tracked,104) and hasMat(tracked,105),
    "Tracked material tally must match filtered overlay")
assert(hasMat(all,101) and hasMat(all,102)
    and hasMat(all,106) and hasMat(all,107) and hasMat(all,109),
    "All materials must include hidden-by-filter including armor-only items")
assert(not hasMat(tracked,106) and not hasMat(tracked,107)
    and not hasMat(tracked,109) and hasMat(tracked,108)
    and hasMat(tracked,110) and hasMat(tracked,111),
    "Tracked materials must follow armor-only meaningful-positive rule")
assert(has(addon:GetItems("tracker"),106)
    and has(addon:GetItems("available"),107),
    "Armor-only items remain in full guide and catalogue")
addon.db.overlay.countArmorOnlyUpgrades=true
assert(hasMat(addon:GetAggregateMaterials("tracked"),106),
    "Armor-only opt-in must restore tracked materials")
addon.db.overlay.countArmorOnlyUpgrades=false
addon.db.overlay.hideWithoutPositiveStats=false
assert(addon:ShouldShowOverlayStatChanges(negative)==true,"Toggle off restores")
assert(hasMat(addon:GetAggregateMaterials("tracked"),101),"Toggle restores tracked materials")
local ui=assert(io.open(root.."/UI.lua")):read("*a")
local core=assert(io.open(root.."/Core.lua")):read("*a")
assert(ui:find('self:ShouldShowOverlayStatChanges(gear)',1,true),
    "Overlay must apply filter before 32-row limit")
assert(ui:find('local overlayCap = 32',1,true),"Keep existing overlay limit")
assert(ui:find('Hide gear without positive stat changes',1,true),
    "Missing settings control")
assert(ui:find('Count armour-only improvements',1,true)
    and ui:find('armorOnlyCheck:SetChecked',1,true),
    "Missing armor-only opt-in control or saved setting binding")
assert(core:find('o.countArmorOnlyUpgrades = false',1,true),
    "Default on existing and new characters must be no armor-only")
assert(core:find('o.hideWithoutPositiveStats = true',1,true),
    "New and existing characters should default to filtering")
print("PASS overlay stat filter: nine classes, two armor keys, armor-only opt-in, other positives/resistance, negative/zero/unknown, rings, bags, guide, materials, toggle and zero bulk requests")
