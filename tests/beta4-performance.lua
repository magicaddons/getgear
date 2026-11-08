-- Beta4 offline sanity/stress guard for 1–60 gear, item-cache requests
-- and bounded UI. This intentionally tests the NEW simplified TOC.
local root=(arg and arg[1]) or "."
local addon={}
local skip={["Core.lua"]=true,["UI.lua"]=true,["AltInventory.lua"]=true}
local t0=os.clock()
local toc=assert(io.open(root.."/GetGear.toc")):read("*a")
local loaded=0
for path in toc:gmatch("[^\r\n]+") do
    if path:match("%.lua$") then
        loaded=loaded+1
        local c,e=loadfile(root.."/"..path)
        assert(c,path..": "..tostring(e))
        if not skip[path] then
            local ok,err=pcall(c,"GetGear",addon)
            assert(ok,path..": "..tostring(err))
        end
    end
end
assert(loaded>=15 and loaded<=22,
    "Unexpected active addon file count "..loaded)
local loadTime=os.clock()-t0
assert(addon.CatalogueAudit.objectives>30000)
local requests=0
C_Item={RequestLoadItemDataByID=function()requests=requests+1 end}
addon.IsGearEquipped=function()return false end
addon.GetObsoleteGearReason=function()return nil end
addon.GetBagPlanningObjectives=function()return {} end
UnitFactionGroup=function()return "Alliance" end
UnitRace=function()return "Human","Human" end
local start=os.clock()
local classCount=0
for _,cls in ipairs({"PRIEST","MAGE","WARLOCK","DRUID","ROGUE","HUNTER","SHAMAN","WARRIOR","PALADIN"}) do
    UnitClass=function()return cls,cls end
    addon.classToken=cls
    addon.db={overlay={filterObsolete=false,hideUncraftableCrafts=false,showAllValidGear=false},
        status={},hidden={}}
    for _,level in ipairs({1,15,30,45,60}) do
        addon.level=level
        assert(addon:SelectCurrentGuide()>1000)
        local available=addon:GetItems("available")
        local earlier=addon:GetItems("earlier")
        local future=addon:GetItems("upcoming")
        local tracker=addon:GetItems("tracker")
        for _,item in ipairs(available) do
            assert(item.targetLevel<=level and item.targetLevel>level-5)
        end
        for _,item in ipairs(future) do
            assert(item.targetLevel>level and item.targetLevel<=level+5)
        end
        for _,item in ipairs(tracker) do
            assert(item.targetLevel<=level+5)
        end
        classCount=classCount+1
    end
end
assert(requests==0,
    "Bulk enumeration must not request item-cache loads: "..requests)
local elapsed=os.clock()-start
assert(loadTime<20 and elapsed<20,
    "Potential client performance regression load="..loadTime.." scan="..elapsed)
local ui=assert(io.open(root.."/UI.lua")):read("*a")
assert(ui:find("DETAIL_PAGE_SIZE = 40",1,true))
assert(ui:find("local overlayCap = 32",1,true),
    "Compact overlay lost its 32-record frame cap")
print(string.format(
    "PASS Beta4 stress: %d Lua files, %d class/level checks, 0 item-cache requests, load %.2fs, filtering %.2fs",
    loaded,classCount,loadTime,elapsed))
