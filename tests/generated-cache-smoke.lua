-- Smoke/stress harness for staged generated Forever data.
-- CI copies the addon into a temporary directory and adds generated Lua to its
-- TOC; the real published addon and normal regression counts stay untouched.
local root=(arg and arg[1]) or "."
local addon={}
local skip={["Core.lua"]=true,["UI.lua"]=true,["AltInventory.lua"]=true}
local toc=assert(io.open(root.."/GetGear.toc")):read("*a")
assert(toc:find("GeneratedForeverGear.lua",1,true),"staged cache not loaded")
local t0=os.clock()
for path in toc:gmatch("[^\r\n]+") do
    if path:match("%.lua$") and not skip[path] then
        local chunk,err=loadfile(root.."/"..path)
        assert(chunk,path..": "..tostring(err))
        local ok,res=pcall(chunk,"GetGear",addon)
        assert(ok,path..": "..tostring(res))
    end
end
local loadElapsed=os.clock()-t0
local audit=assert(addon.GeneratedForeverGear,"generated audit absent")
assert(audit.newItems>5000 and audit.newObjectives>20000,
    "generated import unexpectedly small: "..audit.newItems.." / "..audit.newObjectives)
local catalog=0
for _ in pairs(addon.ItemCatalog) do catalog=catalog+1 end
assert(catalog>7000)
-- Existing hand-verified data wins over the broad October cache.
assert(addon.ItemCatalog[3473].recipeYellowSkill==75)
assert(addon.ItemCatalog[3489].profession=="Blacksmithing")
assert(addon.ItemCatalog[14154].reagents and #addon.ItemCatalog[14154].reagents>=6)
local clsCount=0
for _,cls in ipairs({"PRIEST","MAGE","WARLOCK","DRUID","ROGUE","HUNTER","SHAMAN","WARRIOR","PALADIN"}) do
    local seen={}
    local list=assert(addon.Recommendations[cls])
    assert(#list>=300,cls.." generated recommendations too sparse")
    for _,r in ipairs(list) do
        assert(addon.ItemCatalog[r.itemID],cls.." missing item facts "..r.itemID)
        assert(not seen[r.id],cls.." duplicated objective "..tostring(r.id))
        seen[r.id]=true
        assert(r.targetLevel>=1 and r.targetLevel<=60)
    end
    clsCount=clsCount+#list
end
addon.db={specialization="All",status={},hidden={},overlay={filterObsolete=false,hideUncraftableCrafts=false}}
addon.IsGearEquipped=function() return false end
addon.GetObsoleteGearReason=function() return nil end
UnitClass=function() return "Warrior","WARRIOR" end
UnitFactionGroup=function() return "Alliance" end
UnitRace=function() return "Night Elf","NightElf" end
local t1=os.clock()
addon.level=13
addon:SelectCurrentGuide()
local current=addon:GetItems("available")
local seen={}
for _,r in ipairs(current) do seen[r.itemID]=true end
assert(seen[3473] and seen[3489],"Missing original level-13 Warrior gear under generated catalogue")
local upcoming=addon:GetItems("upcoming")
for _,r in ipairs(upcoming) do
    assert(r.targetLevel>13 and r.targetLevel<=18,"out-of-range upcoming recommendation")
end
addon.level=60
local late=addon:GetItems("available")
assert(#late>#current,"level-60 catalogue should be larger than level-13 catalogue")
local lookupElapsed=os.clock()-t1
assert(loadElapsed<20 and lookupElapsed<20,
    "offline performance regression: load "..loadElapsed.." lookups "..lookupElapsed)
print(string.format(
    "PASS: generated equipment %d new items, %d new class objectives, %d total objectives; load %.2fs, lookups %.2fs",
    audit.newItems,audit.newObjectives,clsCount,loadElapsed,lookupElapsed))
