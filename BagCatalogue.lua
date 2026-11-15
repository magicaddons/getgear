local _, GetGear = ...

-- Ordinary inventory containers, kept separate from the equipment catalogue.
-- Published Forever references, not a live drop/stock guarantee. See the bag
-- audit for excluded variants, unknown unlocks and post-beta size changes.
local bags={}
GetGear.BagCatalogue=bags
local nav={quests={},sources={},chains={}}
GetGear.BagNavigation=nav
local function add(id,name,slots,level,routes,notes)
    bags[#bags+1]={itemID=id,name=name,bagSlots=slots,planningLevel=level,
        acquisitionRoutes=routes,notes=notes or "Published Forever source; current availability unverified.",
        sourceURL="https://www.wowhead.com/forever/item="..id}
end
local function quest(id,name,slots,level,qid,title,side,giver,zone,instructions,prerequisites)
    local key="bag-quest:"..qid
    nav.sources[key]={name=giver,locations={{zone=zone,verification="published-reference"}}}
    nav.quests[tostring(qid)]={questID=qid,name=title,reqlevel=level,side=side,
        starts={key},ends={key},objectiveZone=zone,objectiveInstructions=instructions,
        sourceRequirements={"One-time reward; exact additional unlocks need client confirmation."}}
    add(id,name,slots,level,{{kind="quest",questID=qid,side=side,minimumLevel=level,
        oneTime=true,prerequisiteQuests=prerequisites,source=key,
        location={zone=zone,spot=giver,quality="zone-only"},instructions=instructions}},instructions)
    bags[#bags].oneTime=true
end
quest(1537,"Old Blanchy's Feed Pouch",8,9,151,"Poor Old Blanchy",1,"Verna Furlbrow","Westfall",
    "Bring Verna Furlbrow eight Handfuls of Oats collected around Westfall farms. No mandatory prior quest is established by the published page.")
quest(270017,"Hunting Satchel",10,20,531,"Vyrin's Revenge",1,"Vyrin Swiftwind, Farstrider Lodge","Loch Modan",
    "Complete Vyrin's Revenge (#271): defeat Ol' Sooty and show his head to Daryl the Youngling, then return it to Vyrin (#531). Earlier hunting-task unlocks remain unverified. Published minimum-level fields conflict (15/20); plan from 20 and confirm in game.",{271})
quest(280088,"Soft Saber Sack",6,4,87288,"Soft Saber Pelts",1,"Aldria, Dolanaar","Teldrassil",
    "Bring Aldria six Soft Nightsaber Pelts from Nightsabers near Dolanaar. This is an ordinary bag, not a quiver.")
quest(279936,"Book Bag",6,6,91775,"Book Return",1,"Marshal Dughan, Goldshire","Elwynn Forest",
    "Follow the published Nibbled-On Book, Rascally Rodents, Mining Consultant, The Big Picture, Follow That Kobold!, Shhh! We're Hunting Kobolds, Book Return series. Return six Lost Books and Fun with Elementals to Marshal Dughan. Exact prerequisite IDs/race fields conflict and remain unverified; check quest availability. Reward #279936 is the bag; provided quest item #279935 is not a container.")
quest(276891,"Spidersilk Pouch",12,23,96260,"Stronger than Steel",2,"Yorn Grimtotem","Mulgore",
    "Collect three Crystalline Silk from Gloomrise Spinners in Stonetalon Mountains and return to Yorn Grimtotem. Choose the ordinary Spidersilk Pouch, not the reagent-only Spidersilk Sack.")
quest(277332,"Scuffed Shipping Crate",8,14,97253,"Parts and Pieces",nil,"Wrenix the Wretched, Ratchet","The Barrens",
    "Collect five Handfuls of Complicated Parts from the upper pirate camp south of Ratchet and return to Wrenix the Wretched. Both factions are listed; confirm the current quest minimum before travelling. Ratchet is a named neutral port.")
bags[#bags].acquisitionRoutes[1].travelExempt=true -- named neutral port, not all Barrens vendors
-- Keep conservative *planning* levels distinct from disputed game minima.
for _,bag in ipairs(bags) do
    local route=bag.acquisitionRoutes[1]
    if bag.itemID==270017 then
        route.minimumLevel=15;nav.quests["531"].reqlevel=15
    elseif bag.itemID==279936 or bag.itemID==277332 then
        route.minimumLevel=nil;nav.quests[tostring(route.questID)].reqlevel=nil
    end
end

-- A verified preceding stage, used for the Hunting Satchel prerequisite and
-- navigation without guessing progression through earlier hunting tasks.
nav.quests["271"]={questID=271,name="Vyrin's Revenge",reqlevel=15,side=1,
    starts={"bag-quest:531"},ends={},objectiveZone="Loch Modan",
    objectiveInstructions="Defeat Ol' Sooty; take his head to Daryl the Youngling at Farstrider Lodge."}
nav.chains["531"]={steps={271,531},ordered=true,routeVerified=true,prerequisitesVerified=false,
    instructions="Published two-stage Vyrin route. Earlier hunting-task unlocks require client confirmation."}

-- Generic dropped bags have no invented NPC, coordinates or guaranteed rate.
for _,r in ipairs({
    {805,"Small Red Pouch",6,1},{828,"Small Blue Pouch",6,1},
    {5571,"Small Black Pouch",6,1},{5572,"Small Green Pouch",6,1},
    {856,"Blue Leather Bag",8,9},{2657,"Red Leather Bag",8,9},
    {5573,"Green Leather Bag",8,9},{5574,"White Leather Bag",8,9},
    {804,"Large Blue Sack",10,19},{1725,"Large Knapsack",12,30},
    {1685,"Troll-hide Bag",14,39},{3914,"Journeyman's Backpack",14,39},
    {4500,"Traveler's Backpack",16,47},
}) do add(r[1],r[2],r[3],r[4],{{kind="world_drop",label="World drop / player trade"}}) end
add(3233,"Gnoll Hide Sack",8,10,{{kind="named_drop",label="Fedfennel",
    location={zone="Elwynn Forest",spot="Fedfennel",quality="zone-only"}}})
add(11742,"Wayfarer's Knapsack",16,48,{{kind="dungeon",dungeon="Blackrock Depths",boss="Ribbly Screwspigot"}})
add(17966,"Onyxia Hide Backpack",18,60,{{kind="dungeon",dungeon="Onyxia's Lair",boss="Onyxia"}})
add(4496,"Small Brown Pouch",6,1,{{kind="vendor",label="General supplies vendor"},{kind="world_drop",label="World drop / player trade"}})
add(4499,"Huge Brown Sack",12,30,{{kind="vendor",label="General supplies vendor"}})

-- Finished tradeable crafted bags remain options for non-crafters. Preserve
-- the four original planner recipes/material totals in BagUpgrades.lua.
for _,r in ipairs({
    {5081,"Kodo Hide Bag",6,10,"Leatherworking"},
    {5762,"Red Linen Bag",8,10,"Tailoring"},
    {4241,"Green Woolen Bag",10,20,"Tailoring"},
    {5763,"Red Woolen Bag",10,20,"Tailoring"},
    {5764,"Green Silk Pack",12,25,"Tailoring"},
    {5765,"Black Silk Pack",12,25,"Tailoring"},
    {10051,"Red Mageweave Bag",14,35,"Tailoring"},
    {14046,"Runecloth Bag",14,45,"Tailoring"},
    {14155,"Mooncloth Bag",18,55,"Tailoring"},
    {14156,"Bottomless Bag",20,60,"Tailoring"},
}) do
    add(r[1],r[2],r[3],r[4],{{kind="craft",label=r[5].." / player trade"}})
    bags[#bags].sourceType=r[5];bags[#bags].profession=r[5]
end
