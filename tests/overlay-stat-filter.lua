-- Offline regression for default-on, overlay-only confirmed stat filtering.
-- Run: lua5.4 tests/overlay-stat-filter.lua .
local root=(arg and arg[1]) or "."
local addon={}
assert(loadfile(root.."/GearCompare.lua"))("GetGear",addon)
assert(loadfile(root.."/GuideState.lua"))("GetGear",addon)
addon.db={overlay={hideWithoutPositiveStats=true,filterObsolete=false},
    status={},hidden={}}
addon.GetObsoleteGearReason=function() return nil end
addon.level=10
local statData={
    ["item:100"]={ITEM_MOD_STRENGTH_SHORT=10,ITEM_MOD_STAMINA_SHORT=8},
    ["item:101"]={ITEM_MOD_STRENGTH_SHORT=8,ITEM_MOD_STAMINA_SHORT=8}, -- negative only
    ["item:102"]={ITEM_MOD_STRENGTH_SHORT=10,ITEM_MOD_STAMINA_SHORT=8}, -- unchanged
    ["item:103"]={ITEM_MOD_STRENGTH_SHORT=11,ITEM_MOD_STAMINA_SHORT=6}, -- mixed
    ["item:104"]={ITEM_MOD_STRENGTH_SHORT=12,ITEM_MOD_STAMINA_SHORT=8}, -- positive only
    ["item:200"]={ITEM_MOD_STRENGTH_SHORT=3},
    ["item:201"]={ITEM_MOD_STRENGTH_SHORT=8},
    ["item:202"]={ITEM_MOD_STRENGTH_SHORT=5},
    ["item:203"]={ITEM_MOD_STRENGTH_SHORT=2},
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
addon.Gear={negative,flat,mixed,positive,unknown}
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
assert(hasMat(all,101) and hasMat(all,102),"All materials still include hidden-by-filter")
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
assert(core:find('o.hideWithoutPositiveStats = true',1,true),
    "New and existing characters should default to filtering")
print("PASS overlay stat filter: negative/zero/mixed/positive/unknown, ring alternatives, empty slot, bags, guide unchanged, materials, toggle and zero bulk requests")
