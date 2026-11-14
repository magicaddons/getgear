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
for id,mask in pairs(GetGear.GeneratedHeldClassMasks or {}) do
    local item=GetGear.ItemCatalog and GetGear.ItemCatalog[id]
    if item and item.slot=='Off Hand' then
        item.verifiedHeldClassMask=mask
        item.heldClassEvidence='full-forever-tooltip-header'
    end
end
-- These independently parsed full-tooltip fields distinguish offensive school
-- specialisation from Intellect/Spirit, generic damage and actual healing.
local schools={Fire=1,Frost=2,Shadow=4,Holy=8,Arcane=16,Nature=32}
for id,row in pairs(GetGear.GeneratedSchoolStats or {}) do
    local item=GetGear.ItemCatalog and GetGear.ItemCatalog[id]
    if item then
        local known={}
        for name,bit in pairs(schools) do if math.floor(row[1]/bit)%2==1 then known[name]=true end end
        item.offensiveSchools=known
        item.genericSpellDamage=row[2]
        item.explicitHealing=row[3]
        item.casterUtility=row[4]
    end
end
