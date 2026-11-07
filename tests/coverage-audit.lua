-- Inspect the scope of each class guide without inventing missing items.
-- Run: lua5.4 tests/coverage-audit.lua .
local root=(arg and arg[1]) or "."
local addon={}
local skips={["Core.lua"]=true,["UI.lua"]=true,["AltInventory.lua"]=true}
local toc=assert(io.open(root.."/GetGear.toc")):read("*a")
for file in toc:gmatch("[^\r\n]+") do
    if file:match("%.lua$") and not skips[file] then
        assert(assert(loadfile(root.."/"..file))("GetGear",addon))
    end
end
local classes={"PRIEST","MAGE","WARLOCK","DRUID","WARRIOR","ROGUE","PALADIN","HUNTER","SHAMAN"}
local columns={"Class","1-15","16-30","31-45","46-60","Unknown source","Total"}
print(table.concat(columns,"\t"))
local overall=0
for _,class in ipairs(classes) do
    local buckets={0,0,0,0}
    local unverified=0
    local slotCounts={}
    local list=assert(addon.Recommendations[class],"no guide for "..class)
    for _,r in ipairs(list) do
        local item=assert(addon.ItemCatalog[r.itemID],class.." missing item: "..r.itemID)
        local level=r.targetLevel or item.availableLevel
        assert(type(level)=="number" and level>=1 and level<=60,
            class.." invalid targetLevel: "..tostring(level))
        buckets[level<=15 and 1 or level<=30 and 2 or level<=45 and 3 or 4] =
            buckets[level<=15 and 1 or level<=30 and 2 or level<=45 and 3 or 4]+1
        if item.confidence=="classic-reference" or item.acquisitionConfidence=="classic-reference"
            or item.confidence==nil then unverified=unverified+1 end
        slotCounts[item.slot or "(unknown)"]=(slotCounts[item.slot or "(unknown)"] or 0)+1
    end
    overall=overall+#list
    print(table.concat({class,buckets[1],buckets[2],buckets[3],buckets[4],unverified,#list},"\t"))
end
print("TOTAL RECOMMENDATIONS\t"..overall)
print("Caution: zero coverage is a missing-guide signal, not proof the game has no items.")
