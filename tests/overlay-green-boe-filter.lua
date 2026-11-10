-- Offline regression of default green Bind-on-Equip WORLD drop suppression.
-- Neither full-guide eligibility nor persistent statuses may be touched.
local root=(arg and arg[1]) or "."
local addon={}
local chunk=assert(loadfile(root.."/GearCompare.lua"))
assert(pcall(chunk,"GetGear",addon))
assert(type(addon.ShouldShowOverlayWorldBoEDrops)=="function")
addon.db={overlay={hideGreenBoEWorldDrops=true}}
local function world(id,patch)
    local gear={itemID=id,sourceType="World drop (route unverified)",
        acquisitionKind="World drop (route unverified)"}
    for k,v in pairs(patch or {}) do gear[k]=v end
    return gear
end
local function info(id)
    if id==1121 then -- known BoE green; standard GetItemInfo binding code 2
        return "Feet of the Lynx","item:1121",2,24,19,"Armor","Leather",1,"INVTYPE_FEET",123,10,4,2,2
    end
    if id==1300 then return "Lesser Staff","item:1300",3,24,19,"Weapon","Staff",1,"INVTYPE_2HWEAPON",0,30,2,10,2 end
    if id==1400 then return "BoP Green","item:1400",2,24,19,"Armor","Cloth",1,"INVTYPE_FEET",0,10,4,1,1 end
end
GetItemInfo=info
assert(addon:ShouldShowOverlayWorldBoEDrops(world(1121))==false,
    "Uncommon BoE world drop must be suppressed by default")
assert(addon:ShouldShowOverlayWorldBoEDrops(world(1300))==true,
    "Rare BoE world drops are not green")
assert(addon:ShouldShowOverlayWorldBoEDrops(world(1400))==true,
    "Bind-on-pickup green drops must not be suppressed")
assert(addon:ShouldShowOverlayWorldBoEDrops(world(1121,{sourceType="Dungeon boss drop"}))==true,
    "Dungeon BoEs remain available")
assert(addon:ShouldShowOverlayWorldBoEDrops(world(1121,{sourceType="Quest reward"}))==true,
    "Quest reward BoEs remain available")
assert(addon:ShouldShowOverlayWorldBoEDrops(world(1121,{zone="Drops, Quest Rewards"}))==true,
    "Imported world-drop records with an alternate quest route must remain visible")
assert(addon:ShouldShowOverlayWorldBoEDrops(world(1121,{source="Also in dungeon loot"}))==true,
    "A known dungeon source must beat an ambiguous world-drop label")
assert(addon:ShouldShowOverlayWorldBoEDrops(world(1121,{sourceType="Vendor"}))==true,
    "Vendor BoEs remain available")
assert(addon:ShouldShowOverlayWorldBoEDrops(world(1121,{profession="Tailoring"}))==true,
    "Crafted BoEs remain available")
assert(addon:ShouldShowOverlayWorldBoEDrops(world(1121,{reagents={{itemID=2589,amount=2}}}))==true,
    "Crafting-materials route beats world-drop classification")
assert(addon:ShouldShowOverlayWorldBoEDrops({bagUpgrade=true})==true)
addon.db.overlay.hideGreenBoEWorldDrops=false
assert(addon:ShouldShowOverlayWorldBoEDrops(world(1121))==true,"User override must work")
addon.db.overlay.hideGreenBoEWorldDrops=true
GetItemInfo=function() return nil end
addon.WorldDropGreenBoEIndex={[1121]=true}
assert(addon:ShouldShowOverlayWorldBoEDrops(world(1121))==false,
    "Provisional independently corroborated fallback should work when cache absent")
assert(addon:ShouldShowOverlayWorldBoEDrops(world(99999))==true,
    "Unknown metadata must not hide unverified items")
GetItemInfo=function() return "Changed item","item:1121",4,24,19,"Weapon","Staff",1,"INVTYPE_2HWEAPON",0,10,2,10,1 end
assert(addon:ShouldShowOverlayWorldBoEDrops(world(1121))==true,
    "Live client must override an obsolete Classic-reference fallback")
-- Exercise the actual shipped fallback too: current Forever publications
-- identify Adept's Gloves as Rare/BoP, unlike its older Classic metadata.
assert(loadfile(root.."/WorldDropBoEIndex.lua"))("GetGear",addon)
GetItemInfo=function() return nil end
assert(addon:ShouldShowOverlayWorldBoEDrops(world(4768))==true,
    "Uncached Adept's Gloves must not inherit the stale Classic green-BoE classification")
assert(addon:ShouldShowOverlayWorldBoEDrops(world(727))==false,
    "Other actual provisional green-BoE entries must remain suppressed")
GetItemInfo=function(id)
    if id==4768 then
        return "Adept's Gloves","item:4768",2,17,12,"Armor","Cloth",1,"INVTYPE_HAND",0,0,4,1,2
    end
end
assert(addon:ShouldShowOverlayWorldBoEDrops(world(4768))==false,
    "Loaded green-BoE client facts must still override a published fallback exclusion")
-- Shared state isn't mutated by the presentation-only filter.
assert(addon.db.overlay.hideGreenBoEWorldDrops==true)
local ui=assert(io.open(root.."/UI.lua")):read("*a")
local core=assert(io.open(root.."/Core.lua")):read("*a")
local toc=assert(io.open(root.."/GetGear.toc")):read("*a")
local statsFilter=assert(ui:find("self:ShouldShowOverlayStatChanges(gear)",1,true))
local boeFilter=assert(ui:find("self:ShouldShowOverlayWorldBoEDrops(gear)",1,true))
local overlayCap=assert(ui:find("local overlayCap = 32",1,true))
assert(statsFilter<overlayCap and boeFilter<overlayCap,
    "Combined overlay filters must apply BEFORE the 32-objective cap")
assert(ui:find("Hide green BoE world drops from tracker",1,true)
    and ui:find("greenBoECheck:SetChecked",1,true),
    "Reversible green BoE setting missing")
assert(core:find("o.hideGreenBoEWorldDrops = true",1,true),
    "Green BoE filtering must default on for existing and new characters")
assert(toc:find("WorldDropBoEIndex.lua",1,true),"Item fallback index not loaded")
local state=assert(io.open(root.."/GuideState.lua")):read("*a")
assert(state:find("self:ShouldShowOverlayWorldBoEDrops(gear)",1,true),
    "Tracked crafting materials must match BoE-filtered objectives")
print("PASS green-BoE overlay: world-drop default, route exceptions, live override, provisional fallback and settings")
