-- Offline generator input. Does not load UI, run the client, or build an addon.
local root = arg[1] or "."
local addon = {}
local skip = { ["Core.lua"]=true, ["UI.lua"]=true, ["AltInventory.lua"]=true,
    ["MapNavigation.lua"]=true, ["AcquisitionNavigationData.lua"]=true }
local toc = assert(io.open(root.."/GetGear.toc")):read("*a")
for file in toc:gmatch("[^\r\n]+") do
    if file:match("%.lua$") and not skip[file] then
        assert(loadfile(root.."/"..file))("GetGear", addon)
    end
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
local fields = { "itemID", "name", "slot", "sourceType", "source", "zone", "instructions",
    "sourceSummary", "sourceURL", "acquisitionKind", "acquisitionConfidence", "acquisitionLocation",
    "profession", "recipeLearnMethod", "recipePatternItemID", "recipeVendor", "recipeVendorCost",
    "recipeVendorCurrency", "recipeLearningSourceURL", "professionSkillRequired", "questStart" }
local items = {}
for id, gear in pairs(addon.ItemCatalog) do
    local record = { eligibility = (addon.EffectiveEquipmentEligibility or addon.EquipmentEligibility)[id] }
    for _, field in ipairs(fields) do record[field] = gear[field] end
    items[tostring(id)] = record
end
io.write(json(items), "\n")
