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
if arg[2]=="instances"then io.write(json(addon.AcquisitionNavigationData.instanceDetails),"\n");return end
if arg[2]=="sources"then io.write(json(addon.AcquisitionNavigationData.sources),"\n");return end
local items={}
for id,g in pairs(addon.ItemCatalog)do if g.profession then
 local f={};for _,key in ipairs({'itemID','name','profession','recipeSpellID','recipePatternItemID','recipeLearnMethod','professionSkillRequired','recipeLearnSkillEvidence','sourceSummary','recipeAcquisitionKind'})do f[key]=g[key]end
 f.requirements=addon.AcquisitionNavigationData.recipeRequirements[tostring(id)]
 f.normalized=addon:GetNormalizedRecipeData(g)
 f.minimum=addon:GetRecipeSkillRequirement(g)
 f.summary=addon:GetAcquisitionSummary(g)
 f.plan=addon.AcquisitionNavigationData.items[tostring(id)]
 items[tostring(id)]=f
end end
io.write(json(items),'\n')
