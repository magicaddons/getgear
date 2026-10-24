local addonName, GetGear = ...
-- WoW Forever 1.60.1, Warlock pilot (Alliance) — 2026-10-19.
-- Original Priest records remain intact; recommendations reuse catalog facts.
-- Source evidence: ForeverDB client extraction for items, WoW-Professions
-- for ACA patterns; quest-chain NPC/drops are explicitly qualified below.
GetGear:RegisterGuide("WARLOCK", {faction="Alliance", status="research-preview", label="Warlock"})

local aca = {zone="Redridge Mountains",x=10.0,y=73.0,
             spot="Mivin Shadowweave, Azeroth Commerce Authority",quality="forever"}
local function Mat(id, name, qty) return {itemID=id, name=name, amount=qty} end
local function VendorItem(id,name,slot,level,skill,focus,reagents,detail)
    assert(GetGear:RegisterItem({
        itemID=id,name=name,slot=slot,availableLevel=level,sourceType="Tailoring",
        source="Pattern: "..name.." - Azeroth Commerce Authority",
        zone="Three Corners, Redridge Mountains",confidence="client",
        acquisitionKind="Vendor",acquisitionConfidence="forever",
        acquisitionLocation=aca,profession="Tailoring",professionSkillRequired=skill,
        instructions="Purchase Pattern: "..name.." from Mivin Shadowweave at Three Corners, Redridge Mountains (10.0, 73.0) for 30 Merchant's Favor. Then craft with Tailoring.",
        notes=detail,reagents=reagents,sourceURL="https://foreverdb.net/item/"..id,
    }))
end
local function DropPattern(id,name,slot,level,skill,focus,reagents,detail)
    assert(GetGear:RegisterItem({
        itemID=id,name=name,slot=slot,availableLevel=level,sourceType="Tailoring",
        source="Pattern: "..name.." - dungeon drop / Auction House",
        zone="Dungeon loot / Auction House (if tradeable)",confidence="client",
        acquisitionKind="Dungeon pattern drop",acquisitionConfidence="reported",
        profession="Tailoring",professionSkillRequired=skill,
        instructions="Obtain Pattern: "..name.." as dungeon loot, or check the Auction House for a tradable copy. Specific boss/drop rates are not verified for this variant. The crafted gear binds on pickup; Mivin Shadowweave does not sell this pattern.",
        notes=detail,reagents=reagents,sourceURL="https://foreverdb.net/item/"..id,
    }))
end
local boltWool=2997; local boltSilk=4305; local boltMage=4339
local fineThread=2321; local cerulean=249409; local fireOil=6371
local astral=11082; local silken=4291; local silver=2842
-- Item IDs, skills, amounts from Forever-specific item + recipe records.
VendorItem(253893,"Flame Boots","Feet",12,60,"Destruction",{
    Mat(boltWool,"Bolt of Woolen Cloth",8),Mat(cerulean,"Cerulean Dye",2),
    Mat(fineThread,"Fine Thread",2),Mat(fireOil,"Fire Oil",1)},"+6 Fire damage")
DropPattern(253905,"Filigreed Flame Gown","Chest",15,75,"Destruction",{
    Mat(boltWool,"Bolt of Woolen Cloth",8),Mat(cerulean,"Cerulean Dye",2),
    Mat(fineThread,"Fine Thread",4),Mat(fireOil,"Fire Oil",2)},"+9 Fire damage; specific pattern drop not fully corroborated")
VendorItem(253917,"Flame Gloves","Hands",15,75,"Destruction",{
    Mat(boltWool,"Bolt of Woolen Cloth",6),Mat(cerulean,"Cerulean Dye",3),
    Mat(fineThread,"Fine Thread",4),Mat(fireOil,"Fire Oil",2)},"+7 Fire damage")
VendorItem(253929,"Flame Sash","Waist",17,85,"Destruction",{
    Mat(boltSilk,"Bolt of Silk Cloth",8),Mat(cerulean,"Cerulean Dye",3),
    Mat(fineThread,"Fine Thread",4),Mat(fireOil,"Fire Oil",3)},"+7 Fire damage")
DropPattern(253941,"Filigreed Flame Leggings","Legs",20,100,"Destruction",{
    Mat(boltSilk,"Bolt of Silk Cloth",8),Mat(cerulean,"Cerulean Dye",2),
    Mat(fineThread,"Fine Thread",4),Mat(fireOil,"Fire Oil",4)},"+11 Fire damage")
VendorItem(253953,"Flame Circlet","Head",20,100,"Destruction",{
    Mat(boltSilk,"Bolt of Silk Cloth",10),Mat(cerulean,"Cerulean Dye",4),
    Mat(fireOil,"Fire Oil",4),Mat(astral,"Greater Astral Essence",2),
    Mat(silken,"Silken Thread",2),Mat(silver,"Silver Bar",1)},"+11 Fire damage")
VendorItem(253965,"Flame Gown","Chest",22,110,"Destruction",{
    Mat(boltSilk,"Bolt of Silk Cloth",12),Mat(cerulean,"Cerulean Dye",6),
    Mat(fireOil,"Fire Oil",6),Mat(astral,"Greater Astral Essence",2),
    Mat(silken,"Silken Thread",2),Mat(silver,"Silver Bar",2)},"+13 Fire damage")
DropPattern(253979,"Filigreed Flame Circlet","Head",25,125,"Destruction",{
    Mat(boltSilk,"Bolt of Silk Cloth",8),Mat(cerulean,"Cerulean Dye",2),
    Mat(fineThread,"Fine Thread",4),Mat(fireOil,"Fire Oil",6)},"+14 Fire damage")
VendorItem(253991,"Flame Leggings","Legs",25,125,"Destruction",{
    Mat(boltSilk,"Bolt of Silk Cloth",14),Mat(cerulean,"Cerulean Dye",8),
    Mat(fineThread,"Fine Thread",3),Mat(fireOil,"Fire Oil",8),
    Mat(astral,"Greater Astral Essence",3),Mat(silver,"Silver Bar",2)},"+14 Fire damage")
assert(GetGear:RegisterItem({itemID=254005,name="Fiery Slippers",slot="Feet",availableLevel=30,
    sourceType="Tailoring",source="Source unconfirmed: Fiery Slippers",zone="Tailoring recipe source unknown / Spinning Wheel",
    instructions="Recipe requires Tailoring skill 140 and crafting at a Spinning Wheel. The learning source has not been confirmed in the live Forever beta; do not assume it is sold or taught by a particular NPC.",
    notes="+13 Fire damage. Crafted gear binds on pickup.",confidence="client",
    profession="Tailoring",professionSkillRequired=140,
    reagents={Mat(boltMage,"Bolt of Mageweave",8),Mat(cerulean,"Cerulean Dye",2),
              Mat(7077,"Heart of Fire",2),Mat(8343,"Heavy Silken Thread",4),
              Mat(249430,"Magenta Dye",2)},
    sourceURL="https://foreverdb.net/item/254005",acquisitionKind="Crafting (pattern source unverified)",
    acquisitionConfidence="client"}))
assert(GetGear:RegisterItem({itemID=15109,name="Staff of Soran'ruk",slot="Two-Hand",availableLevel=20,
    sourceType="Quest",source="The Orb of Soran'ruk (Warlock quest reward)",
    zone="The Barrens / Blackfathom Deeps / Shadowfang Keep",
    instructions="Start The Orb of Soran'ruk with Doan Karhan in The Barrens (49.3, 57.3). Quest ID and upgraded reward exist in the Forever client; the start location and objectives use Classic reference data. Classic objective sources: three Soran'ruk Fragments in Blackfathom Deeps and one Large Soran'ruk Fragment in Shadowfang Keep; confirm objective drops in your client. CHOOSE this staff OR the Orb of Soran'ruk, not both.",
    notes="Warlock-only. +14 Stamina, +34 Shadow damage and +34 Fire damage; strong choice for any spec. The client lists quest level 25; minimum acceptance level 20 is a Classic reference, not verified in this beta. Pickup coordinates are Classic references; the Forever item stats are verified.",
    confidence="client",acquisitionKind="Quest start",acquisitionConfidence="classic-reference",
    acquisitionLocation={zone="The Barrens",x=49.3,y=57.3,spot="Doan Karhan",quality="classic-reference"},
    sourceURL="https://foreverdb.net/item/15109"}))
assert(GetGear:RegisterItem({itemID=6898,name="Orb of Soran'ruk",slot="Off Hand",availableLevel=20,
    sourceType="Quest",source="The Orb of Soran'ruk (Warlock quest reward)",
    zone="The Barrens / Blackfathom Deeps / Shadowfang Keep",
    instructions="Same Warlock quest as Staff of Soran'ruk. Start with Doan Karhan in The Barrens (49.3, 57.3); the two rewards are mutually exclusive. Choose this off-hand only if you want to keep a suitable one-handed weapon.",
    notes="Warlock-only. +9 Shadow damage and +9 Fire damage, plus a use effect. Choose staff OR orb.",
    confidence="client",acquisitionKind="Quest start",acquisitionConfidence="classic-reference",
    acquisitionLocation={zone="The Barrens",x=49.3,y=57.3,spot="Doan Karhan",quality="classic-reference"},
    sourceURL="https://foreverdb.net/item/6898"}))
assert(GetGear:RegisterItem({itemID=4311,name="Heavy Woolen Cloak",slot="Back",availableLevel=16,
    sourceType="Tailoring",source="Heavy Woolen Cloak recipe — source to verify",
    zone="Auction House / Tailoring",profession="Tailoring",professionSkillRequired=80,
    instructions="The finished Heavy Woolen Cloak is Bind on Equip and can be purchased from a tailor or the Auction House. Tailoring recipe acquisition is not independently confirmed for Forever; check known trainers or pattern listings before farming.",
    notes="+4 Spell Power; pattern-drop source is not confirmed in Forever",confidence="client",
    reagents={Mat(boltWool,"Bolt of Woolen Cloth",3),Mat(fineThread,"Fine Thread",2),Mat(5498,"Small Lustrous Pearl",2)},
    sourceURL="https://foreverdb.net/item/4311"}))
assert(GetGear:RegisterItem({itemID=2277,name="Necromancer Leggings",slot="Legs",availableLevel=30,
    sourceType="World drop",source="World drop / Auction House",zone="World / Auction House",
    instructions="Rare BoE world drop. Check the Auction House; creature loot sources are still Classic references.",
    notes="+11 Intellect, +12 Stamina and +10 Shadow damage; expensive optional PvP alternative",confidence="client",
    sourceURL="https://foreverdb.net/item/2277"}))
-- Stable recommendation IDs ensure user completion/hide state is per-character.
-- Profile choices: common items appear in all, while specialized damage sets
-- appear only for a relevant build (All shows the union as a planning mode).
local function Add(id,level,priority,focus,note)
    local r={itemID=id,targetLevel=level,focus=focus or "All"}
    if note then r.notes=note end
    assert(GetGear:AddRecommendation("WARLOCK",r),"Duplicate/missing Warlock item "..tostring(id))
end
-- Strong early caster weapons (use universal skills, no race-specific source).
Add(247789,1,"High");Add(11287,5,"High");Add(11288,13,"High")
Add(253885,10,"Medium", "All", "General caster starter option; Tailoring 50")
-- Early Shadow and Fire Tailoring sets. These patterns are BoP crafted gear.
Add(253895,12,"High","Affliction");Add(253893,12,"High","Destruction")
Add(253907,15,"Optional","Affliction");Add(253905,15,"Optional","Destruction")
Add(253919,15,"High","Affliction");Add(253917,15,"High","Destruction")
Add(4311,16,"Optional","All")
Add(253931,17,"High","Affliction");Add(253929,17,"High","Destruction")
Add(1484,17,"Optional","All")
Add(5542,14,"Medium","All")
Add(5198,18,"Optional","All")
Add(2042,18,"Medium","All")
Add(253943,20,"High","Affliction");Add(253941,20,"High","Destruction")
Add(253955,20,"High","Affliction");Add(253953,20,"High","Destruction")
Add(4320,20,"Medium","All")
Add(8071,21,"Optional","All")
Add(253967,22,"High","Affliction");Add(253965,22,"High","Destruction")
Add(2549,22,"Optional","Affliction")
Add(6908,24,"Medium","All")
Add(7047,24,"High","Affliction")
Add(253979,25,"High","Destruction")
Add(253981,25,"High","Affliction")
Add(253993,25,"High","Affliction");Add(253991,25,"High","Destruction")
Add(15109,25,"High","All")
Add(6898,25,"Optional","All")
Add(279898,15,"Optional","All")
Add(7001,27,"Medium","All")
Add(19525,28,"Optional","All")
Add(20099,28,"Medium","All")
Add(254007,30,"High","Affliction");Add(254005,30,"High","Destruction")
Add(7709,30,"High","Affliction")
Add(2277,30,"Optional","Affliction")
Add(7684,30,"High","All")
Add(23169,30,"Medium","All")
-- Demonology shares Shadow progression, plus its class quest staff.
-- Instead of duplicating records, let the profile filter select Affliction picks.
-- Mark Shadow tailoring recommendations usable by both specs.
for _,rec in ipairs(GetGear.Recommendations.WARLOCK) do
    if rec.focus=="Affliction" then rec.specs={"Affliction","Demonology"} end
end
