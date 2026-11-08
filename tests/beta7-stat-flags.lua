-- Verify nonexclusive Forever stat dimensions without relying on WoW's item
-- cache or overfiltering useful hybrid gear.
local root=(arg and arg[1]) or "."
local addon={}
local toc=assert(io.open(root.."/GetGear.toc")):read("*a")
local positions={}
local seq=0
local skip={["Core.lua"]=true,["UI.lua"]=true,["AltInventory.lua"]=true}
for path in toc:gmatch("[^\r\n]+") do
    if path:match("%.lua$") then
        seq=seq+1;positions[path]=seq
        if not skip[path] then
            local chunk,err=loadfile(root.."/"..path)
            assert(chunk,path..": "..tostring(err))
            local ok,result=pcall(chunk,"GetGear",addon)
            assert(ok,path..": "..tostring(result))
        end
    end
end
assert(positions["EquipmentCache.lua"]<positions["GeneratedStatFlags.lua"]
    and positions["GeneratedStatFlags.lua"]<positions["StatEvidence.lua"]
    and positions["StatEvidence.lua"]<positions["GuideEngine.lua"]
    and positions["GuideEngine.lua"]<positions["GearRelevance.lua"],
    "Stat flags must load after imported data and before filtering")
assert(addon.CatalogueAudit.items==7707)
assert(addon.StatFlagEvidence.matched>=4500,
    "Insufficient independently sourced Forever tooltip flag coverage")
local function item(id,flags)
    local facts=assert(addon.ItemCatalog[id],"item absent "..id)
    assert(facts.statFlagsEvidence=="forever-client-tooltip")
    for key,want in pairs(flags) do
        assert(facts.statFlags[key]==want,
            "Bad Forever flag "..id.."/"..key.." expected "..tostring(want))
    end
    return facts
end
local shirt=item(250492,{spellPower=true,physical=true})
local silver=item(250522,{spellPower=true,physical=true})
local protector=item(250490,{spellPower=true,defense=true})
local protectorSilver=item(250520,{spellPower=true,defense=true})
item(250517,{spellPower=true,physical=true})
item(250502,{spellPower=true,physical=true})
item(250491,{spellPower=true,mana=true})
item(250501,{spellPower=true,healing=true})
local veteran=item(250488,{physical=true})
local guardSilver=item(250519,{physical=true})
local harness=item(3313,{physical=true,mana=true})
local tunic=item(252509,{physical=true,mana=true})
assert(not veteran.statFlags.spellPower)
assert(not guardSilver.statFlags.spellPower)
assert(not harness.statFlags.spellPower)
assert(not tunic.statFlags.spellPower)
assert(shirt.statRole=="mixed" and silver.statRole=="mixed",
    "Keep original mixed classification for compatibility")
addon.db={overlay={showAllValidGear=false}}
local function check(id,level,class,expected)
    addon.level=level;addon.classToken=class
    local obj=assert(addon.ItemCatalog[id])
    local result=addon:ShouldDisplayGear(obj,class,"available")
    assert(result==expected,
        class.." item "..id.." level "..level..": "..tostring(result)
        .." expected "..tostring(expected))
end
check(250492,15,"WARRIOR",false)
check(250522,22,"WARRIOR",false)
check(250490,15,"WARRIOR",false)
check(250520,22,"WARRIOR",false)
check(250488,15,"WARRIOR",true)
check(250519,22,"WARRIOR",true)
check(250492,15,"PALADIN",true)
check(250522,22,"PALADIN",true)
check(250490,15,"PALADIN",true)
check(250520,22,"PALADIN",true)
check(3313,13,"ROGUE",true)
check(3313,13,"HUNTER",true)
check(252509,22,"ROGUE",true)
check(252509,22,"DRUID",true)
-- All nine classes must respect identical independent flags, never "mixed"
-- as an exclusive spell/caster classification.
local armor={
    WARRIOR="Mail",ROGUE="Leather",HUNTER="Leather",
    PALADIN="Mail",SHAMAN="Leather",DRUID="Leather",
    PRIEST="Cloth",MAGE="Cloth",WARLOCK="Cloth",
}
local reject={WARRIOR=true,ROGUE=true,HUNTER=true}
for class,preferred in pairs(armor) do
    addon.level=20;addon.classToken=class
    local mixed={itemID=999000,id="test_999000",name="Mixed Hybrid Sample",
        availableLevel=20,targetLevel=20,slot="Chest",armorType=preferred,
        statRole="mixed",statFlags={physical=true,mana=true,spellPower=true}}
    assert(addon:ShouldDisplayGear(mixed,class,"available")==not reject[class],
        "Class spell-power veto differs for "..class)
    mixed.statFlags={physical=true,mana=true}
    assert(addon:ShouldDisplayGear(mixed,class,"available")==true,
        "Physical + mana without spell power must remain available to "..class)
    mixed.statFlags=nil
    assert(addon:ShouldDisplayGear(mixed,class,"available")==true,
        "Unknown stat flags must not exclude all mixed gear for "..class)
end
addon.level=15;addon.classToken="WARRIOR"
addon.db.overlay.showAllValidGear=true
assert(addon:ShouldDisplayGear(shirt,"WARRIOR","available"),
    "Show all valid equipment must recover explicit spell-power gear")
addon.db.overlay.showAllValidGear=false
assert(not addon:ShouldDisplayGear({itemID=24358,statFlags={}}, "WARRIOR","available"),
    "QA/internal hard exclusions must persist")
print("PASS Forever stat flags: "..addon.StatFlagEvidence.matched..
      " independently typed 1-60 items, Crusader/Protector variants, 9 classes, hybrid examples and all-valid override")
