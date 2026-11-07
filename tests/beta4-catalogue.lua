-- Beta 4 unified catalogue and class eligibility audit.
local root=(arg and arg[1]) or "."
local addon={}
local skip={["Core.lua"]=true,["UI.lua"]=true,["AltInventory.lua"]=true}
local toc=assert(io.open(root.."/GetGear.toc")):read("*a")
for file in toc:gmatch("[^\r\n]+") do
    if file:match("%.lua$") then
        local chunk,err=loadfile(root.."/"..file)
        assert(chunk,file..": "..tostring(err))
        if not skip[file] then
            local ok,result=pcall(chunk,"GetGear",addon)
            assert(ok,file..": "..tostring(result))
        end
    end
end
local audit=assert(addon.CatalogueAudit)
assert(audit.items==7707, "Missing original researched/cache items: "..tostring(audit.items))
assert(audit.researched==259 and audit.manualOnly==29,"Research merger changed")
assert(audit.objectives>30000 and audit.objectives<40000,"Class masks too sparse/dense")
assert(addon.GeneratedForeverGear.eligibility==7678)
assert(addon.Recommendations==nil and addon.Specializations==nil,
       "Old editorial recommendations or specialization table is still active")
assert(addon.AddRecommendation==nil and addon.NextSpecialization==nil)
local count,maskCount=0,0
for id,item in pairs(addon.ItemCatalog) do
    count=count+1
    assert(item.itemID==id and type(item.name)=="string" and item.name~="",
           "Broken item identity "..tostring(id))
    local e=assert(addon.EquipmentEligibility[id],"No eligibility for "..id)
    assert(type(e[1])=="number" and e[1]>0 and type(e[2])=="number")
    maskCount=maskCount+1
end
assert(count==7707 and maskCount==count)
local classes={"PRIEST","MAGE","WARLOCK","DRUID","ROGUE","HUNTER","SHAMAN","WARRIOR","PALADIN"}
for _,class in ipairs(classes) do
    local list=assert(addon.EquipmentByClass[class],"Missing "..class)
    assert(#list>=1000,class.." equipment coverage unexpectedly sparse")
    local seen={}
    for _,row in ipairs(list) do
        assert(not seen[row.itemID],"Duplicate equipment card "..class.."/"..row.itemID)
        seen[row.itemID]=true
        assert(row.targetLevel>=1 and row.targetLevel<=60)
        assert(row.id=="item_"..row.itemID)
        assert(row.specs==nil and row.focus==nil,
               "Editorial spec/focus selection leaked to unified equipment")
    end
end
local function find(class,id)
    for _,item in ipairs(addon.EquipmentByClass[class]) do
        if item.itemID==id then return item end
    end
end
assert(find("WARRIOR",2572),"Warrior can physically equip cloth; relevance filter should decide")
assert(find("WARRIOR",5957) and find("WARRIOR",2303))
assert(find("WARRIOR",7166),"Copper Dagger must remain discoverable as valid gear")
assert(find("WARRIOR",3473) and find("WARRIOR",3489))
-- The Warlock quest Orb grants BOTH Fire and Shadow bonuses; school-exclusive
-- metadata would mislead future talent-aware filtering.
assert(addon.ItemCatalog[6898] and addon.ItemCatalog[6898].schoolOnly==nil,
       "Mixed Fire/Shadow Orb of Soran'ruk is incorrectly labelled Fire-only")
assert(find("WARRIOR",3473).targetLevel==8)
assert(find("WARRIOR",3489).targetLevel==12)
assert(find("HUNTER",3473).targetLevel==40,"Hunter Mail proficiency at 40")
assert(find("SHAMAN",3473).targetLevel==40,"Shaman Mail proficiency at 40")
assert(not find("ROGUE",14154) and not find("MAGE",14154))
assert(find("PRIEST",14154) and find("WARLOCK",14153))
assert(not find("WARRIOR",14154))
assert(find("WARRIOR",2933).targetLevel>=28,
       "Seal of Wrynn should be acquired late, despite a lower equip requirement")
local pants=assert(addon.ItemCatalog[3473])
assert(pants.profession=="Blacksmithing" and pants.reagents and #pants.reagents>0)
local axe=assert(addon.ItemCatalog[3489])
assert(axe.profession=="Blacksmithing" and axe.reagents and #axe.reagents>0)
local trap=assert(addon.ItemCatalog[252495])
local ingredients={}
for _,r in ipairs(trap.reagents or {}) do ingredients[r.itemID]=r.amount end
assert(ingredients[2318]==12 and ingredients[4231]==3 and
       ingredients[249427]==2 and ingredients[2321]==1 and ingredients[6470]==2,
       "Trapper's Leather Gloves verified ingredients lost")
assert(addon.ItemCatalog[2933].acquisitionLocation or
       addon.ItemCatalog[2933].questStart,
       "Original Seal of Wrynn quest chain location discarded")
local ui=assert(io.open(root.."/UI.lua")):read("*a")
local core=assert(io.open(root.."/Core.lua")):read("*a")
for _,bad in ipairs({"GetSpecializationChoices","previewSpecButton","specButton",
    "NextSpecialization","preview.spec"}) do
    assert(not ui:find(bad,1,true),"Legacy spec UI survived: "..bad)
end
assert(not core:find('command == "spec"',1,true),
    "Legacy specialization slash command survived")
assert(core:find("schemaVersion~=4",1,true),"Progress schema reset missing")
assert(not toc:find("GeneratedForeverGear.lua",1,true),
    "Legacy recommendation-importer still shipped")
print(string.format(
    "PASS Beta4 canonical catalogue: %d records, %d class entries, 9 classes, 259 research overrides, quest/gates, 0 spec profiles",
    count,audit.objectives))
