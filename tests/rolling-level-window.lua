-- GetGear Beta 3: imported equipment uses a dynamic five-level lookback.
-- At character level 15, level 10 is Earlier Gear; level 11 is available.
-- Reviewed objectives and SavedVariables are never moved/deleted.
local root=(arg and arg[1]) or "."
local addon={}
local skipped={["Core.lua"]=true,["UI.lua"]=true,["AltInventory.lua"]=true}
local toc=assert(io.open(root.."/GetGear.toc")):read("*a")
for path in toc:gmatch("[^\r\n]+") do
    if path:match("%.lua$") then
        local chunk,err=loadfile(root.."/"..path)
        assert(chunk,path..": "..tostring(err))
        if not skipped[path] then
            local ok,result=pcall(chunk,"GetGear",addon)
            assert(ok,path..": "..tostring(result))
        end
    end
end

local function objective(id,level,generated)
    return {id="item_"..id,itemID=id,name="Lookback gear "..id,
        slot="Legs",availableLevel=level,targetLevel=level,
        fromGeneratedCache=generated,sourceType="Crafted gear (recipe details unverified)",
        statRole="physical",armorType="Mail",
        reagents={{itemID=id+100000,amount=1,name="Test reagent "..id}}}
end
local lv10=objective(950010,10,true)
local lv11=objective(950011,11,true)
local lv15=objective(950015,15,true)
local lv16=objective(950016,16,true)
local lv20=objective(950020,20,true)
local lv21=objective(950021,21,true)
local reviewed=objective(950005,5,false)
local hidden=objective(950030,5,true)
local acquired=objective(950031,4,true)
local bag={id="bag_test",itemID=950032,name="Bag upgrade",targetLevel=1,
    slot="Bag",bagUpgrade=true}
addon.Gear={lv10,lv11,lv15,lv16,lv20,lv21,reviewed,hidden,acquired}
addon.db={status={[acquired.id]="acquired"},hidden={[hidden.id]=true},
    overlay={showAllValidGear=false,filterObsolete=false,hideUncraftableCrafts=false},
    specialization="All"}
addon.classToken="WARRIOR"
addon.level=15
addon.IsGearEquipped=function() return false end
addon.GetObsoleteGearReason=function() return nil end
addon.GetBagPlanningObjectives=function() return {bag} end

local function has(mode,id)
    for _,row in ipairs(addon:GetItems(mode)) do
        if row.itemID==id then return true end
    end
    return false
end
assert(addon:IsOlderImportedGear(lv10),"Level 10 must age out at 15")
assert(not addon:IsOlderImportedGear(lv11),"Level 11 must remain available at 15")
assert(not addon:IsOlderImportedGear(reviewed),"Reviewed gear must not age out")
assert(has("earlier",lv10.itemID),"Aged-out item must be in Earlier Gear")
assert(not has("available",lv10.itemID),"Aged-out item leaked into Available Now")
assert(not has("tracker",lv10.itemID),"Aged-out item leaked into compact tracker")
assert(has("available",lv11.itemID),"Level-11 item should remain available")
assert(has("available",lv15.itemID),"Current-level item missing")
assert(has("upcoming",lv16.itemID),"Level-16 item missing from Upcoming")
assert(has("upcoming",lv20.itemID),"Level-20 item missing from Upcoming (+5)")
assert(not has("upcoming",lv21.itemID),"Level-21 item leaked past +5 boundary")
assert(has("tracker",lv20.itemID),"Tracker must still include the next 5 levels")
assert(has("available",reviewed.itemID),"Curated level-5 gear must remain visible at 15")
assert(not has("earlier",reviewed.itemID),"Curated gear should not age out automatically")
assert(has("hidden",hidden.itemID),"Hidden history must remain accessible")
assert(has("completed",acquired.itemID),"Acquired history must remain accessible")

local function mats(scope)
    local keys={}
    for _,row in ipairs(addon:GetAggregateMaterials(scope)) do
        keys[row.itemID]=row.amount
    end
    return keys
end
local tracked=mats("tracked")
assert(not tracked[lv10.itemID+100000],"Tracked material tally includes aged-out craft")
assert(tracked[lv11.itemID+100000]==1,"Tracked craft is missing")
local all=mats("all")
assert(all[lv10.itemID+100000]==1,"All materials must include Earlier Gear")
assert(all[lv11.itemID+100000]==1)

-- The cutoff is recalculated at each level change, not written into history.
addon.level=14
assert(not addon:IsOlderImportedGear(lv10),"Level-10 gear remains available at level 14")
assert(has("available",lv10.itemID))
addon.level=16
assert(addon:IsOlderImportedGear(lv11),"Level-11 gear moves to Earlier at level 16")
assert(not has("available",lv11.itemID) and has("earlier",lv11.itemID))
addon.level=20
assert(addon:IsOlderImportedGear(lv15),"Level-15 item must age out at level 20")
assert(has("earlier",lv15.itemID))

-- Expanded view deliberately restores old imported items to Available.
addon.level=15
addon.db.overlay.showAllValidGear=true
assert(not addon:IsOlderImportedGear(lv10))
assert(has("available",lv10.itemID),"Show all must restore level-10 equipment")
assert(not has("earlier",lv10.itemID),"Expanded view must not age out items")
assert(addon:ShouldDisplayGear(lv10,"WARRIOR","preview"),
    "Full Preview Guide must still support older imported equipment")
addon.db.overlay.showAllValidGear=false
assert(addon:ShouldDisplayGear(lv10,"WARRIOR","preview"),
    "Level lookback is for live guide, not historical/full Preview Guide")
assert(addon.db.status[acquired.id]=="acquired" and addon.db.hidden[hidden.id]==true,
    "Level filtering must not mutate saved statuses")
assert(has("bags",bag.itemID),"Bag upgrades must be unaffected")

local ui=assert(io.open(root.."/UI.lua")):read("*a")
assert(ui:find("older imported gear in Earlier Gear",1,true),
    "Earlier Gear text should explain lookback")
print("PASS: Beta3 level-15 cutoff (10 excluded, 11 retained), live leveling, Earlier Gear, +5 Upcoming, curated/history, materials, show-all and Preview")
