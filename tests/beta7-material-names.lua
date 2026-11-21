-- Confirm ingredient labels come from the complete canonical catalogue at
-- module load; GetGear.Gear is intentionally empty until ADDON_LOADED.
local root=(arg and arg[1]) or "."
local addon={}
local skip={["Core.lua"]=true,["UI.lua"]=true,["AltInventory.lua"]=true}
local toc=assert(io.open(root.."/GetGear.toc")):read("*a")
for path in toc:gmatch("[^\r\n]+") do
    if path:match("%.lua$") and not skip[path] then
        local chunk,err=loadfile(root.."/"..path)
        assert(chunk,err)
        local ok,reason=pcall(chunk,"GetGear",addon)
        assert(ok,path..": "..tostring(reason))
    end
end
assert(type(addon.Gear)=="table" and #addon.Gear==0,
    "Regression setup must load before character guide selection")
local expected={
    [2840]="Copper Bar",
    [3470]="Rough Grinding Stone",
    [249427]="Pristine Leather",
    [1210]="Shadowgem",
}
for id,name in pairs(expected) do
    assert(addon:MaterialName(id)==name,
        "Wrong name for "..id..": "..tostring(addon:MaterialName(id)))
end

addon.db={overlay={dependencyExpanded={}}}
local belt=assert(addon.ItemCatalog[250514],"Guard's Chain Belt missing")
local rows=addon:GetCraftingMaterialRows(belt)
local seen={}
for _,row in ipairs(rows) do seen[row.itemID]=row end
for id,name in pairs(expected) do
    assert(seen[id] and seen[id].name==name,
        "Material row resolved to an item ID instead of "..name)
end

-- Non-current classes' recipes must also have names. Check all documented
-- direct reagents and the resulting row name, never depending on C_Item data.
local materials,crafts=0,0
for id,item in pairs(addon.ItemCatalog) do
    if item.profession and type(item.reagents)=="table" and #item.reagents>0 then
        crafts=crafts+1
        for _,r in ipairs(item.reagents) do
            local actual=addon:MaterialName(r.itemID)
            assert(actual~="Item "..r.itemID and actual~="",
                "Unresolved ingredient name in recipe "..id..": "..r.itemID)
            materials=materials+1
        end
    end
end
assert(crafts>=1244 and materials>3000,
    "Expected full Beta7 recipe dataset, got "..crafts.." crafts and "..materials.." materials")
print("PASS Beta7 material names: belt names, all class recipes, "..crafts.." crafts, "..materials.." ingredients without client item cache")
