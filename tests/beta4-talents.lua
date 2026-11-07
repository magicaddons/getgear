-- Beta4 read-only C_Traits talent inference and Mage school-exclusive filter.
local root=(arg and arg[1]) or "."
local addon={}
local skip={["Core.lua"]=true,["UI.lua"]=true,["AltInventory.lua"]=true}
for file in assert(io.open(root.."/GetGear.toc")):read("*a"):gmatch("[^\r\n]+") do
    if file:match("%.lua$") and not skip[file] then
        local ok,err=pcall(assert(loadfile(root.."/"..file)),"GetGear",addon)
        assert(ok,file..": "..tostring(err))
    end
end
addon.classToken="MAGE";addon.level=35
addon.db={overlay={filterObsolete=false,showAllValidGear=false},
    status={},hidden={}}
local groupIDs={Arcane=501,Fire=502,Frost=503}
local talents={Arcane=0,Fire=6,Frost=2}
C_ClassTalents={GetActiveConfigID=function()return 111 end}
C_Traits={
    GetConfigInfo=function(configID)
        assert(configID==111)
        return {type=4,treeIDs={1112},name="Mage"}
    end,
    GetGroupDisplayInfoByTreeID=function(treeID)
        assert(treeID==1112)
        return {
            {groupID=501,displayName="Arcane",orderIndex=1},
            {groupID=502,displayName="Fire",orderIndex=2},
            {groupID=503,displayName="Frost",orderIndex=3},
        }
    end,
    GetGroupCurrencyInfo=function(configID,ids)
        assert(configID==111 and #ids==3)
        local result={}
        for name,id in pairs(groupIDs) do
            if talents[name]>0 then
                result[#result+1]={traitNodeGroupID=id,
                    currencyInfos={{traitCurrencyID=3820,spent=talents[name]}}}
            end
        end
        return result
    end,
}
assert(addon:RefreshTalentAwareness()=="Fire","Fire-dominant tree not recognized")
local function sample(school,otherStats)
    return {itemID=999000,name="Exclusive school test",targetLevel=35,
        slot="Ring",armorType="Jewelry",statRole="spell",
        schoolOnly=school,sourceType="Crafted gear (recipe details unverified)",
        notes=otherStats}
end
assert(addon:ShouldDisplayGear(sample("Fire"),"MAGE","available"))
assert(not addon:ShouldDisplayGear(sample("Frost"),"MAGE","available"))
assert(not addon:ShouldDisplayGear(sample("Arcane"),"MAGE","available"))
assert(addon:ShouldDisplayGear(sample(nil,"+10 Intellect +12 Spell Power"),"MAGE","available"),
    "Generic caster equipment must not be hidden by talent inference")
assert(addon:ShouldDisplayGear(sample("Frost"),"MAGE","preview"),
    "Read-only class preview must retain all schools")
addon.db.overlay.showAllValidGear=true
assert(addon:ShouldDisplayGear(sample("Frost"),"MAGE","available"),
    "All-valid must restore even school-exclusive off-build gear")
addon.db.overlay.showAllValidGear=false

-- No confident lead = fail OPEN to every legitimate school.
talents={Arcane=3,Fire=4,Frost=3}
assert(addon:RefreshTalentAwareness()==nil,"Close split must be ambiguous")
assert(addon:ShouldDisplayGear(sample("Frost"),"MAGE","available"))
talents={Arcane=0,Fire=1,Frost=0}
assert(addon:RefreshTalentAwareness()==nil,"One low-level point is not a confirmed build")
C_Traits.GetGroupCurrencyInfo=nil
assert(addon:RefreshTalentAwareness()==nil,"Missing API must fail open")
C_Traits=nil
assert(addon:RefreshTalentAwareness()==nil,"Missing trait namespace must fail open")
addon.classToken="WARLOCK"
assert(addon:ShouldDisplayGear(sample("Frost"),"WARLOCK","available"),
    "Warlocks are intentionally NOT forced into a single school")
addon.classToken="SHAMAN"
assert(addon:ShouldDisplayGear(sample("Fire"),"SHAMAN","available"),
    "Shaman elemental/physical hybrids must remain broadly eligible")
addon.classToken="PALADIN"
assert(addon:ShouldDisplayGear(sample("Arcane"),"PALADIN","available"),
    "Paladin spellpower combinations should not be spec-restricted")

local hints=addon.PureSchoolBonus or {}
local schools,count={},0
for id,name in pairs(hints) do
    assert(addon.ItemCatalog[id],"School-only hint missing actual equipment "..id)
    schools[name]=true;count=count+1
end
assert(count>=10 and schools.Fire and schools.Arcane,
    "Conservative school metadata absent from compact catalogue: "..count)
assert(not hints[6898],"Mixed Fire/Shadow Warlock quest item must not be school-exclusive")
print("PASS Beta4 C_Traits Fire/Frost/Arcane dominance, mixed stat safety, ambiguity and API fallback, expanded/preview and conservative pure-school items")
