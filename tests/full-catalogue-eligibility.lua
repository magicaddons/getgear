-- Source-caveated full-range catalogue regression: equipment proficiency,
-- character equip levels, class locks, all-spec defaults and saved status IDs.
-- This test runs offline against the same TOC order as the game.
local root=(arg and arg[1]) or "."
local addon={}
local skip={["Core.lua"]=true,["UI.lua"]=true,["AltInventory.lua"]=true}
local toc=assert(io.open(root.."/GetGear.toc")):read("*a")
assert(toc:find("GeneratedForeverGear.lua",1,true),
    "Full catalogue was removed from the development build")
for file in toc:gmatch("[^\r\n]+") do
    if file:match("%.lua$") and not skip[file] then
        local chunk,err=loadfile(root.."/"..file)
        assert(chunk,file..": "..tostring(err))
        local ok,result=pcall(chunk,"GetGear",addon)
        assert(ok,file..": "..tostring(result))
    end
end
assert(addon.GeneratedForeverGear and addon.GeneratedForeverGear.newItems>7000)
local expected={
    [3473]={WARRIOR=8,PALADIN=8,HUNTER=40,SHAMAN=40},
    [3489]={WARRIOR=12,PALADIN=12,HUNTER=12,ROGUE=12,SHAMAN=12},
    [14153]={WARLOCK=57},
    [14154]={PRIEST=57},
    [10020]={PRIEST=40,MAGE=40,WARLOCK=40,DRUID=40,ROGUE=40,
             HUNTER=40,SHAMAN=40,WARRIOR=40,PALADIN=40},
}
for id,eligibility in pairs(expected) do
    assert(addon.ItemCatalog[id],"missing equipment facts: "..id)
    for class,recs in pairs(addon.Recommendations) do
        local match
        for _,r in ipairs(recs) do
            if r.itemID==id then
                assert(not match,"duplicate item "..id.." for "..class)
                match=r
            end
        end
        local level=eligibility[class]
        assert((match~=nil)==(level~=nil),
            class.." incorrect eligibility for item "..id)
        if match then
            assert(match.targetLevel==level,
                class.." item "..id.." must appear from level "..level)
            assert(match.specs==nil and match.focus=="All",
                class.." item "..id.." must be available to all specs")
        end
    end
end
-- Class-specific old objective IDs are never re-keyed when a broad cache
-- provides a second copy of the same item ID.
local ids={}
for _,r in ipairs(addon.Recommendations.WARRIOR) do
    assert(not ids[r.id],"duplicate saved ID")
    ids[r.id]=true
end
assert(ids.item_3473 and ids.item_3489)
addon.db={status={},hidden={},overlay={filterObsolete=false,
    hideUncraftableCrafts=false},specialization="All"}
addon.IsGearEquipped=function()return false end
addon.GetObsoleteGearReason=function()return nil end
UnitClass=function()return "Warrior","WARRIOR" end
UnitFactionGroup=function()return "Alliance" end
UnitRace=function()return "Night Elf","NightElf" end
addon.level=13
addon:SelectCurrentGuide()
local found={}
for _,r in ipairs(addon:GetItems("available")) do found[r.itemID]=true end
assert(found[3473] and found[3489],"Level 13 Warrior missing equipment")
addon.db.status.item_3473="acquired"
addon.db.hidden.item_3489=true
found={}
for _,r in ipairs(addon:GetItems("completed")) do found[r.itemID]=true end
assert(found[3473],"Original saved acquisition no longer displays")
found={}
for _,r in ipairs(addon:GetItems("hidden")) do found[r.itemID]=true end
assert(found[3489],"Original saved hidden state no longer displays")
print("PASS: 1-60 class locks, Rogue axes, level-40 mail gating, class-wide gear and stable progress IDs")
