-- GetGear 1-60 staging regression.
-- Run from repository root: lua5.4 tests/level60-staging-regression.lua .
local root=(arg and arg[1]) or "."
local addon={}
local skips={["Core.lua"]=true,["UI.lua"]=true,["AltInventory.lua"]=true}
local toc=assert(io.open(root.."/GetGear.toc")):read("*a")
local fileCount=0
for file in toc:gmatch("[^\r\n]+") do
    if file:match("%.lua$") then
        local chunk,err=loadfile(root.."/"..file)
        assert(chunk,file..": "..tostring(err))
        fileCount=fileCount+1
        if not skips[file] then
            local ok,result=pcall(chunk,"GetGear",addon)
            assert(ok,file..": "..tostring(result))
        end
    end
end
assert(fileCount>=35,"missing original modules")
assert(addon.GetPreviewRecommendations,"missing preview")
assert(addon.RegisterItem and addon.AddRecommendation,"missing catalogue API")
for class,list in pairs(addon.Recommendations) do
    local ids={}
    for _,rec in ipairs(list) do
        assert(not ids[rec.id],class.." duplicate progress ID: "..tostring(rec.id))
        ids[rec.id]=true
    end
end

-- Exercise large datasets to ensure AddRecommendation uses indexed duplicate
-- checks without breaking default IDs, existing items or main/offhand rules.
assert(addon:RegisterItem({itemID=9000001,name="Synthetic 1-60 regression item",
    slot="Chest",availableLevel=31}),"could not create synthetic item")
assert(addon:AddRecommendation("PRIEST",{itemID=9000001,targetLevel=31}),
    "missing synthetic 31+ recommendation")
assert(not addon:AddRecommendation("PRIEST",{itemID=9000001,targetLevel=31}),
    "duplicate default ID accepted")
assert(addon:GetPreviewRecommendations("PRIEST","All"),"missing class view")
local added=0
for i=1,1200 do
    local id=9000001+i
    assert(addon:RegisterItem({itemID=id,name="Synthetic item "..i,
        slot="Chest",availableLevel=31+(i%30)}))
    assert(addon:AddRecommendation("PRIEST",{itemID=id,targetLevel=31+(i%30)}))
    added=added+1
end
local all=addon:GetPreviewRecommendations("PRIEST","All")
assert(#all>=added+1,"31-60 entries missing from preview")
for _,rec in ipairs(all) do
    assert(rec.targetLevel>=1 and rec.targetLevel<=60,"out-of-range item in test")
end
local function Read(path)
    local f=assert(io.open(root.."/"..path))
    local s=f:read("*a"); f:close(); return s
end
local ui=Read("UI.lua")
assert(ui:find("DETAIL_PAGE_SIZE = 40",1,true),"detail UI not paged")
assert(ui:find("math.min(60, preview.level+delta)",1,true),
    "preview plus still capped below level 60")
assert(ui:find("math.min(60, math.floor(chosen))",1,true),
    "typed preview level still capped below level 60")
assert(ui:find("local overlayCap = 32",1,true),"overlay not capped")
print("PASS: level 60 preview framework, indexed recommendations, 1200-item stress case, bounded rows")
