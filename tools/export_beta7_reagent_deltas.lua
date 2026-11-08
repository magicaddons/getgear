-- Preserve every original-versus-generated crafting material disagreement.
-- Run: lua5.4 tools/export_beta7_reagent_deltas.lua . docs/BETA7-reagent-discrepancies.tsv
local root=(arg and arg[1]) or "."
local output=(arg and arg[2]) or "Beta7-reagent-discrepancies.tsv"
local a={}
for _,name in ipairs({"ResearchedItemFacts.lua","EquipmentCache.lua"}) do
    local fn,err=loadfile(root.."/"..name)
    assert(fn,err)
    local ok,result=pcall(fn,"GetGear",a)
    assert(ok,name..": "..tostring(result))
end
local function matIndex(list)
    local r={}
    for _,mat in ipairs(list or {}) do
        assert(type(mat.itemID)=="number" and type(mat.amount)=="number")
        r[mat.itemID]=mat.amount
    end
    return r
end
local previous={}
for id,item in pairs(a.ItemCatalog) do
    if type(item.reagents)=="table" and #item.reagents>0 then
        previous[id]={name=item.name,inputs=matIndex(item.reagents)}
    end
end
local fn,err=loadfile(root.."/GeneratedBeta7Evidence.lua")
assert(fn,err)
local ok,result=pcall(fn,"GetGear",a)
assert(ok,tostring(result))
local function formatMats(index)
    local keys={}
    for id in pairs(index) do keys[#keys+1]=id end
    table.sort(keys)
    local result={}
    for _,id in ipairs(keys) do result[#result+1]=id..":"..index[id] end
    return table.concat(result,",")
end
local ids={}
for id in pairs(previous) do ids[#ids+1]=id end
table.sort(ids)
local out=assert(io.open(output,"w"))
out:write("itemId\tname\tpreviousReagents\tnewClientReagents\n")
local changed=0
for _,id in ipairs(ids) do
    local before=previous[id]
    local after=assert(a.ItemCatalog[id])
    local b,e=formatMats(before.inputs),formatMats(matIndex(after.reagents))
    if b~=e then
        changed=changed+1
        out:write(id,"\t",before.name:gsub("[\t\r\n]"," "),"\t",b,"\t",e,"\n")
    end
end
out:close()
assert(changed==43,"Expected 43 frozen-source corrections, found "..changed)
assert(a.Beta7GeneratedEvidence.reagentConflicts==43)
print("PASS: 43 original/replacement ingredient lists preserved in "..output)
