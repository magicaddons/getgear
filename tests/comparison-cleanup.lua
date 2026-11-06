-- Regression for GetGear comparison display: status text must not drown out stat/DPS deltas.
-- Run: lua5.4 tests/comparison-cleanup.lua .
local root=(arg and arg[1]) or "."
local src=assert(io.open(root.."/GearCompare.lua")):read("*a")
local druidSrc=assert(io.open(root.."/DruidGear.lua")):read("*a")
for _,phrase in ipairs({"Warrior: compare weapon DPS", "Feral: also compare weapon DPS",
    "Feral forms: check weapon DPS", "Enchantments, on-use effects and weapon DPS",
    "stat deltas are incomplete", "Compare damage school/effects manually",
    "Verify speed, damage school and effects manually"}) do
    assert(not src:find(phrase,1,true),"Generic comparison warning reappeared: "..phrase)
end
assert(not druidSrc:find("Form weapon DPS needs in-game comparison",1,true))
assert(not druidSrc:find("Feral weapon DPS matters; check the equipped tooltip",1,true))

local candidateID=12345
local linkMain,linkOff="item:11111","item:22222"
local stats={
    ["item:12345"]={ITEM_MOD_STRENGTH_SHORT=2, ITEM_MOD_STAMINA_SHORT=2,
        ITEM_MOD_DAMAGE_PER_SECOND_SHORT=7.7},
    [linkMain]={ITEM_MOD_STRENGTH_SHORT=1,ITEM_MOD_STAMINA_SHORT=1,
        RESISTANCE0_NAME=6,ITEM_MOD_DAMAGE_PER_SECOND_SHORT=1},
    [linkOff]={RESISTANCE0_NAME=4},
}
C_Item={GetItemStats=function(link) return stats[link] end}
GetInventoryItemLink=function(_,slot)
    if slot==16 then return linkMain end
    if slot==17 then return linkOff end
end
local addon={db={overlay={filterObsolete=false}}}
assert(loadfile(root.."/GearCompare.lua"))("GetGear",addon)
local gear={itemID=candidateID,slot="Two-Hand Sword",name="Comparison Test Weapon"}

local function check(className, spec)
    addon.classToken=className
    addon.GetSpecialization=function()return spec or "All" end
    local short,visible=addon:ComparisonInline(gear,false)
    assert(visible and short:find("Vs Main Hand + Off Hand",1,true),
        className.." missing comparison scope")
    for _,delta in ipairs({"+1 Strength","+1 Stamina","-10 Armor","+6.7 Weapon DPS"}) do
        assert(short:find(delta,1,true),className.." missing "..delta)
    end
    local detail,detVisible=addon:ComparisonInline(gear,true)
    assert(detVisible and detail:find("7.7",1,true) and detail:find("+6.7",1,true),
        className.." lost detailed weapon DPS comparison")
    local tip={lines={}}
    function tip:AddLine(value)self.lines[#self.lines+1]=value end
    function tip:AddDoubleLine(left,right)self.lines[#self.lines+1]=left.." "..right end
    addon:AppendComparisonTooltip(tip,gear)
    local tooltip=table.concat(tip.lines,"\n")
    assert(tooltip:find("Gear comparison",1,true) and tooltip:find("Weapon DPS",1,true),
        className.." lost comparison tooltip")
    for _,output in ipairs({short,detail,tooltip}) do
        local lower=output:lower()
        for _,warning in ipairs({"manually","stat deltas are incomplete",
            "stat deltas are insufficient","not fully compared","warrior:","feral:"}) do
            assert(not lower:find(warning,1,true),className.." repeated boilerplate: "..warning)
        end
    end
end

check("WARRIOR","Arms")
check("WARRIOR","Fury")
check("WARRIOR","Protection")
check("DRUID","Feral Cat")
check("DRUID","Feral Bear")
check("MAGE","Frost")
check("PRIEST","Shadow")
check("HUNTER","Marksmanship")
check("ROGUE","Combat")

print("PASS comparison cleanup: 9 class/spec cases, unchanged Strength/Stamina/Armor/Weapon DPS changes, no repeated warnings")
