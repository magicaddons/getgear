-- Prevent a full 1-60 gear audit from launching thousands of
-- GetItemInfo / ITEM_DATA_LOAD_RESULT request loops during obsolete checks.
local root=(arg and arg[1]) or "."
local requests={}
local addon={level=60,db={overlay={filterObsolete=true}}}
addon.RequestItemDataOnce=function(_,id)
    requests[id]=(requests[id] or 0)+1
    return true
end
GetInventoryItemLink=function(_,slot)
    if slot==5 then return "item:1111" end
end
C_Item={
    GetItemInfo=function(item)
        if item=="item:1111" then
            return "Equipped Test Armor","item:1111",2,60
        end
        return nil
    end,
    GetItemStats=function() return nil end,
}
assert(loadfile(root.."/GearCompare.lua"))("GetGear",addon)
for id=9000000,9004999 do
    local gear={itemID=id,slot="Chest",targetLevel=10,
        fromGeneratedCache=true,notes=""}
    assert(addon:GetObsoleteGearReason(gear)==nil,
        "Uncached item cannot be conclusively obsolete")
end
local total=0
for _,count in pairs(requests) do total=total+count end
assert(total==0,"Bulk obsolete scan must not request 5,000 item records: "..total)

local old={itemID=7000,slot="Chest",targetLevel=10,notes=""}
assert(addon:GetObsoleteGearReason(old)==nil)
assert(requests[7000]==1,
    "Existing small curated dataset should retain item refresh behavior")
local visible={itemID=9000001,slot="Chest",targetLevel=60,fromGeneratedCache=true}
addon:GetGearComparison(visible)
assert(requests[9000001]==1,
    "A visible generated item may request its tooltip on demand")
print("PASS: 5000 bulk obsolete candidates issue zero item-load requests; visible lazy lookup works")
