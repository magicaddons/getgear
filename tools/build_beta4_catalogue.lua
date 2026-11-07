-- Build the single canonical GetGear item catalogue from the final effective
-- state of the legacy modules. This is a BUILD TOOL, never shipped to WoW.
-- It executes the old data modules once in an isolated Lua process and writes
-- flattened immutable item facts + class equippability metadata.
local root=arg[1] or "."
local output=arg[2] or "CatalogueFacts.lua"
local schoolPath=arg[3] or "tools/beta4_schools.tsv"
local addon={}
local classes={"PRIEST","MAGE","WARLOCK","DRUID","ROGUE","HUNTER","SHAMAN","WARRIOR","PALADIN"}
local bits={}
for i,name in ipairs(classes) do bits[name]=2^(i-1) end
local toc=assert(io.open(root.."/GetGear.toc")):read("*a")
for line in toc:gmatch("[^\r\n]+") do
    if line:match("%.lua$") then
        local chunk,err=loadfile(root.."/"..line)
        assert(chunk,line..": "..tostring(err))
        local ok,result=pcall(chunk,"GetGear",addon)
        assert(ok,line..": "..tostring(result))
        if line=="GeneratedForeverGear.lua" then break end
    end
end
local items=assert(addon.ItemCatalog)
local recommendations=assert(addon.Recommendations)
-- The cache rows carry EQUIPPABILITY masks, not editorial recommendations.
-- Parse the generated Lua source as a Lua literal; never reinterpret
-- hand-authored recommendation lists as class proficiency.
local generated=assert(io.open(root.."/GeneratedForeverGear.lua")):read("*a")
local literal=assert(generated:match("local rows = (%b{})"),"generated cache row table absent")
local fn,err=load("return "..literal,"catalogue-masks","t",{})
assert(fn,err)
local cacheRows=fn()
local eligibility={}
for _,row in ipairs(cacheRows) do
    eligibility[row[1]]={mask=row[7],equipLevel=row[3],
        armorType=row[5],statRole=row[11],sourceCode=row[6]}
end
-- Source-vetted item targets can describe *access* rather than minimum equip
-- level: e.g. Seal of Wrynn has a low equip level but a long quest chain.
-- Keep the earliest documented practical objective as a separate field.
local manualMasks,practical={},{}
for class,recs in pairs(recommendations) do
    for _,r in ipairs(recs) do
        manualMasks[r.itemID]=manualMasks[r.itemID] or 0
        if math.floor(manualMasks[r.itemID]/bits[class])%2==0 then
            manualMasks[r.itemID]=manualMasks[r.itemID]+bits[class]
        end
        local f=items[r.itemID]
        local source=f and ((f.acquisitionKind or "").." "..(f.sourceType or "")) or ""
        if source:lower():find("quest",1,true) or source:lower():find("dungeon",1,true)
            or source:lower():find("reputation",1,true) then
            local level=tonumber(r.targetLevel)
            if level and level>=1 and level<=60 then
                local old=practical[r.itemID]
                if not old or level<old then practical[r.itemID]=level end
            end
        end
    end
end
local schools={}
local f=io.open(schoolPath,"r")
if f then
    for line in f:lines() do
        local id,school=line:match("^(%d+)\t([A-Za-z]+)$")
        if id and (school=="Fire" or school=="Frost" or school=="Arcane") then
            schools[tonumber(id)]=school
        end
    end
    f:close()
end
local manualOnly,missing,acquisition,schoolCount=0,0,0,0
for id,item in pairs(items) do
    local e=eligibility[id]
    if not e then
        manualOnly=manualOnly+1
        -- The original researched class coverage is *fallback evidence* only
        -- for items missing from the dated client cache; it must never limit
        -- an item present in the equipment cache.
        e={mask=manualMasks[id] or 0,
           equipLevel=tonumber(item.availableLevel) or 1,
           armorType=item.armorType or "",
           statRole=item.statRole or "utility",sourceCode=0}
        eligibility[id]=e
    end
    if not e.mask or e.mask==0 then missing=missing+1 end
    item.armorType=e.armorType~="" and e.armorType or item.armorType
    item.statRole=e.statRole~="" and e.statRole or item.statRole or "utility"
    item.availableLevel=math.max(1,math.min(60,tonumber(e.equipLevel) or tonumber(item.availableLevel) or 1))
    local target=practical[id]
    if target and target>item.availableLevel then
        item.earliestPracticalLevel=target
        acquisition=acquisition+1
    end
    local school=schools[id]
    if school then item.schoolOnly=school; schoolCount=schoolCount+1 end
    item.fromGeneratedCache=nil -- cache/curation provenance is not a display veto.
end
assert(manualOnly<100,"manual-only backlog needs review: "..manualOnly)
assert(missing==0,"items missing class eligibility: "..missing)
local function keyOrder(a,b)
    if type(a)==type(b) then return a<b end
    return type(a)=="number"
end
local function serialize(value,seen,depth)
    local t=type(value)
    if t=="nil" then return "nil" end
    if t=="number" then assert(value==value,"NaN");return tostring(value) end
    if t=="boolean" then return tostring(value) end
    if t=="string" then return string.format("%q",value) end
    assert(t=="table","Unexpected nonserializable data: "..t)
    assert(not seen[value],"cyclic metadata")
    assert(depth<18,"unexpected deeply nested item fact")
    seen[value]=true
    local keys={}
    for k in pairs(value) do keys[#keys+1]=k end
    table.sort(keys,keyOrder)
    local parts={}
    for _,k in ipairs(keys) do
        local kt=type(k)
        assert(kt=="number" or kt=="string","invalid item fact key "..kt)
        parts[#parts+1]="["..serialize(k,seen,depth+1).."]="..serialize(value[k],seen,depth+1)
    end
    seen[value]=nil
    return "{"..table.concat(parts,",").."}"
end
local out=assert(io.open(output,"w"))
out:write("local addonName, GetGear = ...\n")
out:write("-- Canonical effective Forever gear facts, produced by tools/build_beta4_catalogue.lua.\n")
out:write("-- Source: existing researched fields and the 2026-10-21 Forever beta cache.\n")
out:write("-- Individual acquisition confidence is retained; no claim of live drops.\n")
out:write("GetGear.ItemCatalog={\n")
local ids={}
for id in pairs(items) do ids[#ids+1]=id end
table.sort(ids)
for _,id in ipairs(ids) do
    out:write(" [",id,"]=",serialize(items[id],{},0),",\n")
end
out:write("}\nGetGear.EquipmentEligibility={\n")
for _,id in ipairs(ids) do
    local e=eligibility[id]
    -- Mask and restrictions are equipment facts, not spec profiles.
    out:write(" [",id,"]={",e.mask,",",e.equipLevel,",",
        string.format("%q",e.armorType or ""),"},\n")
end
out:write("}\n")
out:write("GetGear.Gear={}\n")
out:write("GetGear.CatalogueAudit={items=",#ids,",manualOnly=",manualOnly,
    ",acquisitionLevels=",acquisition,",schoolOnly=",schoolCount,"}\n")
out:close()
print("CANONICAL PASS items="..#ids.." manualOnly="..manualOnly..
    " acquisitionLevels="..acquisition.." schoolOnly="..schoolCount..
    " originalRecommendations="..(function()
        local n=0;for _,list in pairs(recommendations) do n=n+#list end
        return n
    end)())
