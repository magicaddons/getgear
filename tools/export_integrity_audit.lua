-- Export every crafted catalogue entry for independent requirement/source audit.
local root=arg[1]or'.';local addon={}
for file in io.lines(root..'/GetGear.toc')do
 if file:match('%.lua$')and file~='Core.lua'and file~='UI.lua'and file~='AltInventory.lua'then assert(loadfile(root..'/'..file))('GetGear',addon)end
end
local function json(value)
    local kind = type(value)
    if kind == "nil" then return "null" end
    if kind == "number" or kind == "boolean" then return tostring(value) end
    if kind == "string" then
        return '"'..value:gsub('[%z\1-\31\\"]', function(c)
            local escapes = { ['"']='\\"', ['\\']='\\\\', ['\n']='\\n', ['\r']='\\r', ['\t']='\\t' }
            return escapes[c] or string.format('\\u%04x', c:byte())
        end)..'"'
    end
    assert(kind == "table", "Unexpected export value")
    local array = #value > 0
    local keys, out = {}, {}
    for key in pairs(value) do keys[#keys+1] = key end
    table.sort(keys, function(a,b) return tostring(a)<tostring(b) end)
    if array then
        for _, v in ipairs(value) do out[#out+1] = json(v) end
    else
        for _, key in ipairs(keys) do out[#out+1] = json(tostring(key))..":"..json(value[key]) end
    end
    return (array and "[" or "{")..table.concat(out,",")..(array and "]" or "}")
end
local classes={}
for class,items in pairs(addon.EquipmentByClass) do
 classes[class]={}
 for _,g in ipairs(items) do classes[class][#classes[class]+1]=g.itemID end
end
local bags={}
for _,bag in ipairs(addon.QuestBagCatalogue or {}) do bags[tostring(bag.itemID)]=bag end
for _,bag in ipairs(addon.BagTiers or {}) do bags[tostring(bag.itemID)]=bag end
-- Synthetic empty bags expose the complete planning catalogue, not observations.
addon.level=60;addon.db={overlay={}}
UnitFactionGroup=function()return 'Alliance' end
C_Container={GetContainerNumSlots=function()return 4 end,GetContainerNumFreeSlots=function()return 0,0 end}
for _,bag in ipairs(addon:GetBagPlanningObjectives()) do bags[tostring(bag.itemID)]=bag end
io.write(json({items=addon.ItemCatalog,classes=classes,bags=bags,eligibility=addon.EquipmentEligibility,
 effectiveEligibility=addon.EffectiveEquipmentEligibility,model=addon.AcquisitionNavigationData,
 factions=addon.FactionEligibilityData,evidence=addon.AcquisitionEvidenceIndex}),"\n")
