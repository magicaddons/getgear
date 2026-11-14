-- Beta7 armor-priority regression. The primary recommendation lane should
-- show the intended class armor at each level, while "Show all valid" restores
-- otherwise class-equippable alternatives without restoring QA items.
local root=(arg and arg[1]) or "."
local a={}
for _,name in ipairs({"ResearchedItemFacts.lua","EquipmentCache.lua",
    "GeneratedBeta7Evidence.lua","SourceEnrichment.lua","GuideEngine.lua",
    "GearRelevance.lua"}) do
    local fn,err=loadfile(root.."/"..name);assert(fn,err)
    local ok,result=pcall(fn,"GetGear",a);assert(ok,name..": "..tostring(result))
end
a.db={overlay={showAllValidGear=false}}
a.level=13
local function sample(armor,level,slot)
    return {itemID=980001,name="Synthetic tier check",targetLevel=level,
        availableLevel=level,armorType=armor,slot=slot or "Chest",
        statRole="physical",sourceType="World drop (route unverified)"}
end
local function check(cls,level,allowed,blocked,role)
    a.level=level
    local item=sample(allowed,level)
    item.statRole=role or "physical"
    assert(a:ShouldDisplayGear(item,cls,"available"),
        cls.." at "..level.." should show "..allowed)
    item.armorType=blocked
    assert(not a:ShouldDisplayGear(item,cls,"available"),
        cls.." at "..level.." should not show "..blocked)
    a.db.overlay.showAllValidGear=true
    local forbidden=(cls=='ROGUE'or cls=='DRUID')and(blocked=='Mail'or blocked=='Plate')
        or (cls=='PRIEST'or cls=='MAGE'or cls=='WARLOCK')and blocked~='Cloth'
    assert(a:ShouldDisplayGear(item,cls,"available")==not forbidden,
        cls.." expanded mode lifts relevance,never physical armour permissions: "..blocked)
    a.db.overlay.showAllValidGear=false
end
for _,cls in ipairs({"WARRIOR","PALADIN"}) do
    check(cls,13,"Mail","Leather")
    check(cls,39,"Mail","Plate")
    check(cls,40,"Plate","Mail")
    check(cls,60,"Plate","Leather")
end
for _,cls in ipairs({"HUNTER","SHAMAN"}) do
    check(cls,13,"Leather","Cloth")
    check(cls,39,"Leather","Mail")
    check(cls,40,"Mail","Leather")
    check(cls,60,"Mail","Cloth")
end
for _,cls in ipairs({"ROGUE","DRUID"}) do
    check(cls,13,"Leather","Cloth")
    check(cls,60,"Leather","Mail")
end
for _,cls in ipairs({"PRIEST","MAGE","WARLOCK"}) do
    check(cls,13,"Cloth","Leather","spell")
    check(cls,60,"Cloth","Mail","spell")
end
-- The reported actual item, from the frozen 1-60 index.
local harness=assert(a.ItemCatalog[3313])
assert(harness.name=="Ceremonial Leather Harness")
assert(harness.armorType=="Leather" and harness.statRole=="mixed")
a.level=13
assert(not a:ShouldDisplayGear(harness,"WARRIOR","available"),
    "Actual Ceremonial Leather Harness incorrectly shown for Warrior")
assert(a:ShouldDisplayGear(harness,"HUNTER","available"),
    "Leather should remain the appropriate Hunter armor under level 40")
assert(a:ShouldDisplayGear(harness,"ROGUE","available"),
    "Leather should remain appropriate Rogue gear")
a.db.overlay.showAllValidGear=true
assert(a:ShouldDisplayGear(harness,"WARRIOR","available"),
    "Expanded mode no longer restores harness")
a.db.overlay.showAllValidGear=false
-- Historical preview takes each item's target level, not the live player
-- level. This must hold at the 39 -> 40 threshold.
a.level=60
assert(a:ShouldDisplayGear(sample("Mail",39),"WARRIOR","preview"))
assert(not a:ShouldDisplayGear(sample("Leather",39),"WARRIOR","preview"))
assert(a:ShouldDisplayGear(sample("Plate",40),"WARRIOR","preview"))
assert(not a:ShouldDisplayGear(sample("Mail",40),"WARRIOR","preview"))
assert(a:ShouldDisplayGear(sample("Leather",39),"HUNTER","preview"))
assert(a:ShouldDisplayGear(sample("Mail",40),"HUNTER","preview"))
-- At level 39, upcoming plate should not be incorrectly excluded.
a.level=39
assert(a:ShouldDisplayGear(sample("Plate",40),"WARRIOR","upcoming"))
-- Back-slot cloaks are not chest armor; rings and weapons are unaffected.
a.level=13
assert(a:ShouldDisplayGear(sample("Cloth",13,"Back"),"WARRIOR","available"))
assert(a:ShouldDisplayGear(sample("Jewelry",13,"Ring"),"WARRIOR","available"))
assert(a:ShouldDisplayGear(sample("Axe",13,"Main Hand"),"WARRIOR","available"))
-- Preserve hard QA veto under expanded browse.
a.db.overlay.showAllValidGear=true
local qa=sample("Plate",40);qa.itemID=24358
assert(not a:ShouldDisplayGear(qa,"WARRIOR","available"))
print("PASS Beta7 preferred armor for nine classes, 39/40 switch, preview, upcoming, cloaks, all-valid and item 3313")
