-- Keep default class equipment informative, not censored by source research gaps.
local a={}
local chunk=assert(loadfile(((arg and arg[1]) or ".").."/GearRelevance.lua"))
chunk("GetGear",a)
a.db={overlay={showAllValidGear=false}}
a.level=25
local item={itemID=981234,name="Sample",targetLevel=25,availableLevel=25,
    armorType="Mail",statRole="physical",sourceType="World drop (route unverified)"}
assert(a:ShouldDisplayGear(item,"WARRIOR","available"),
    "Source uncertainty incorrectly removed an otherwise valid Warrior item")
item.sourceType="Source not documented"
assert(a:ShouldDisplayGear(item,"WARRIOR","available"),
    "Missing research must not silently hide class-equippable gear")
item.sourceType="Vendor (availability unverified)"
assert(a:ShouldDisplayGear(item,"WARRIOR","available"),
    "Unknown vendor location must not prevent a gear entry")
item.itemID=24358
assert(not a:ShouldDisplayGear(item,"WARRIOR","available"),
    "Known QA/internal item leaked back into the catalogue")
item.itemID=981234
item.statRole="spell"
assert(not a:ShouldDisplayGear(item,"WARRIOR","available"),
    "Unrelated pure spell bonuses should still be conservatively suppressed")
item.statRole="physical"
item.targetLevel=20
assert(not a:ShouldDisplayGear(item,"WARRIOR","available"),
    "Five-level older-item cutoff changed")
assert(a:ShouldDisplayGear(item,"WARRIOR","earlier"),
    "Earlier Gear should retain still-eligible older items")
print("PASS Beta7 class-wide source-uncertainty visibility, QA veto, role, and older boundary")
