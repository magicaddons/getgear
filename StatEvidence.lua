local addonName, GetGear = ...
-- Add independent stat dimensions to the catalogue after all imported
-- source records are loaded. This is not a new exclusive item role.
-- Flags represent explicit bonuses seen in published Forever tooltips.
-- Missing evidence never means a bonus is absent.
local BITS={spellPower=1,healing=2,mana=4,physical=8,defense=16}
local matched=0
for itemID,mask in pairs(GetGear.GeneratedStatFlags or {}) do
    local item=GetGear.ItemCatalog and GetGear.ItemCatalog[itemID]
    if item and type(mask)=="number" then
        local flags=item.statFlags or {}
        for name,bit in pairs(BITS) do
            if math.floor(mask/bit)%2==1 then flags[name]=true end
        end
        item.statFlags=flags
        item.statFlagsEvidence="forever-client-tooltip"
        matched=matched+1
    end
end
GetGear.StatFlagEvidence={matched=matched,bits=BITS}
