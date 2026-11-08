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
-- Shared state isn't mutated by the presentation-only filter.
assert(addon.db.overlay.hideGreenBoEWorldDrops==true)
print("PASS green-BoE overlay: world-drop default, route exceptions, live override, provisional fallback and settings")
