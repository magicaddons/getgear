-- Catalogue-wide material names before character selection, plus late/generated
-- recipes, bag materials and the existing asynchronous item-data refresh path.
local root=(arg and arg[1]) or "."
local addon={}
for file in io.lines(root.."/GetGear.toc") do
    if file:match("%.lua$") and file~="Core.lua" and file~="UI.lua" and file~="AltInventory.lua" then
        assert(loadfile(root.."/"..file))("GetGear",addon)
    end
end
assert(#addon.Gear==0,"name resolution must work before SelectCurrentGuide")
local clientQueries,requests=0,0
C_Item={GetItemNameByID=function() clientQueries=clientQueries+1;error("known names must not query the cache") end,
    RequestLoadItemDataByID=function() requests=requests+1 end}
addon.db={schemaVersion=4,status={},hidden={},overlay={dependencyExpanded={},showAllValidGear=true},detail={}}
addon.GetMaterialCount=function() return 0 end
local known,recipes,occurrences={},0,0
local function valid(name) return type(name)=="string" and name:match("%S") and not name:lower():match("^item%s+%d+$") end
for _,gear in pairs(addon.ItemCatalog) do
    for _,mat in ipairs(gear.reagents or {}) do
        if valid(mat.name) then
            known[mat.itemID]=known[mat.itemID] or {}
            known[mat.itemID][mat.name]=true
        end
        occurrences=occurrences+1
    end
end
for id,names in pairs(known) do
    assert(names[addon:MaterialName(id)],"canonical material name lost or assigned to the wrong ID: "..id)
end
local all={}
for id,gear in pairs(addon.ItemCatalog) do
    if gear.reagents and #gear.reagents>0 then
        recipes=recipes+1
        local record=setmetatable({id="material_test_"..id,targetLevel=1},{__index=gear})
        all[#all+1]=record
        for _,mat in ipairs(addon:GetCraftingMaterialRows(record,true)) do
            assert(valid(mat.name),"direct or nested material became placeholder: "..mat.itemID)
        end
    end
end
assert(recipes==1254 and occurrences==4857)
assert(clientQueries==0 and requests==0,"catalogue/intermediate names depended on item-cache availability")
addon.Gear=all;addon.level=60
addon.ShouldDisplayGear=function() return true end
addon.ShouldDisplayCraftedGear=function() return true end
addon.HasEligibleAcquisitionSource=function() return true end
addon.ShouldShowOverlayStatChanges=function() return true end
addon.ShouldShowOverlayWorldBoEDrops=function() return true end
addon.ShouldShowOverlayAcquisition=function() return true end
addon.GetObsoleteGearReason=function() return nil end
addon.IsGearEquipped=function() return false end
for _,scope in ipairs({"all","tracked"}) do
    for _,mat in ipairs(addon:GetAggregateMaterials(scope)) do assert(valid(mat.name),"aggregate name lost") end
    for _,mat in ipairs(addon:GetCombinedMaterialRows(scope)) do assert(valid(mat.name),"combined/nested name lost") end
end
addon.GetProfessionSkill=function() return 150 end
local snapshot={}
for i=1,4 do snapshot[i]={index=i,slots=4,replaceable=true} end
local bag=assert(addon:GetBagUpgradePlan(snapshot,{}))
assert(#bag.reagents>0)
for _,mat in ipairs(bag.reagents) do assert(valid(mat.name),"bag recipe name lost") end
assert(clientQueries==0 and requests==0)
-- New generated records can be indexed without selecting a character.
addon.ItemCatalog[999000]={reagents={{itemID=999001,name="Future Catalogue Reagent",amount=2}}}
addon:IndexMaterialNames()
assert(addon:MaterialName(999001)=="Future Catalogue Reagent")
addon.ItemCatalog[999000].reagents[1].name="Item 999001"
addon:IndexMaterialNames()
addon.MaterialNames={[999001]="Item 999001"}
assert(addon:MaterialName(999001)=="Future Catalogue Reagent","placeholder overwrote known name")
-- Names carried by late recipe/aggregate records and UI/tooltips use one resolver.
local late={id="late",reagents={{itemID=999002,name="Late Recipe Reagent",amount=3}}}
assert(addon:GetCraftingMaterialRows(late)[1].name=="Late Recipe Reagent")
assert(addon:MaterialName(999003,"Late Display Reagent")=="Late Display Reagent")
assert(addon:MaterialName(999003,"Item 999003")=="Late Display Reagent")
local ui=assert(io.open(root.."/UI.lua")):read("*a")
assert(ui:find("GetGear:MaterialName(mat.itemID,mat.name)",1,true),"rendering bypasses shared resolver")
assert(ui:find("GetGear:MaterialName(part[1])",1,true),"nested tooltip bypasses shared resolver")
local tooltipLines={}
local tooltip={SetOwner=function() end,SetItemByID=function() end,
    AddLine=function(_,text) tooltipLines[#tooltipLines+1]=text end,
    AddDoubleLine=function() end,Show=function() end}
local body=assert(ui:match("local function ShowItemTooltip%(button%)(.-)\nend\n\nlocal function HideItemTooltip"))
local env=setmetatable({GetGear=addon,C_Item=C_Item,GameTooltip=tooltip},{__index=_G})
local showTooltip=assert(load("return function(button)"..body.."\nend","material tooltip","t",env))()
showTooltip({itemID=999002,material={name="Item 999002",amount=3,recipe={inputs={{999001,2}}}}})
local tooltipText=table.concat(tooltipLines,"\n")
assert(tooltipText:find("Material: Late Recipe Reagent",1,true),"known root tooltip name lost on empty client cache")
assert(tooltipText:find("2 x Future Catalogue Reagent",1,true),"nested tooltip name lost")
local cached={}
C_Item.GetItemNameByID=function(id) clientQueries=clientQueries+1;return cached[id] end
local callbacks={}
C_Timer={After=function(_,fn) callbacks[#callbacks+1]=fn end}
local refreshed=0
addon.RefreshAll=function() refreshed=refreshed+1 end
assert(addon:MaterialName(999010)=="Item 999010")
assert(addon:MaterialName(999010)=="Item 999010" and requests==1,"unknown names must request once")
cached[999010]="Now Cached Reagent"
addon:OnItemDataLoadResult(999010,true)
assert(#callbacks==1);callbacks[1]()
assert(refreshed==1 and addon:MaterialName(999010)=="Now Cached Reagent")
C_Item.GetItemNameByID=function() return "Item 999011" end
assert(addon:MaterialName(999011)=="Item 999011")
C_Item.GetItemNameByID=function() return "Resolved After Placeholder" end
assert(addon:MaterialName(999011)=="Resolved After Placeholder","placeholder was permanently cached")
print("PASS material resolution: all1254 recipes/4857 catalogue ingredients, nested/aggregate/bag/tooltip paths, empty guide, late generated/input names, placeholder protection, cache-miss and item-data refresh")
