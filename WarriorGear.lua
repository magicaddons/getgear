local addonName, GetGear = ...

-- GetGear v0.10.0: Alliance Warrior 1-30, Protection first; Arms and Fury
-- receive independent weapon/offensive routes. Item facts are from the
-- WoW Forever 1.60.1 beta item/recipe client as indexed by ForeverDB.
-- Where Forever dungeon loot/quest rewards are unobserved, they are marked
-- classic-reference (Optional and excluded from level-up notifications).
assert(GetGear:RegisterGuide("WARRIOR", {
    faction="Alliance", status="research-preview", label="Warrior",
}), "Could not register Alliance Warrior guide")

local PROT={"Protection"}
local ARMS={"Arms"}
local FURY={"Fury"}
local DAMAGE={"Arms","Fury"}
local ALL={"Arms","Fury","Protection"}

local function Mat(id,name,n) return {itemID=id,name=name,amount=n} end
local function Rec(id,level,priority,specs,note)
    assert(GetGear:AddRecommendation("WARRIOR",{
        itemID=id,targetLevel=level,focus="All",
        specs=specs,notes=note,
    }),"Duplicate/missing Warrior recommendation: "..tostring(id))
end

local function Craft(id,name,slot,required,skill,bind,stats,specs,priority,reagents,note,goal)
    if not GetGear.ItemCatalog[id] then
        local bop=(bind=="BoP")
        local intro="Forge with Blacksmithing (skill "..tostring(skill).."). "
        if bop then
            intro=intro.."BIND ON PICKUP: this character must personally have Blacksmithing and craft this piece. You cannot buy it finished or commission another blacksmith to craft it. "
        else
            intro=intro.."Tradeable item: self-craft, ask a blacksmith, or check the Auction House. "
        end
        intro=intro.."Item and recipe are in the Forever client. Check an available trainer/recipe source in-game before traveling; specific instruction sources are not independently verified."
        assert(GetGear:RegisterItem({
            itemID=id,name=name,slot=slot,availableLevel=required,
            sourceType="Blacksmithing",source="Blacksmithing "..tostring(skill).." recipe",
            zone=bop and "Blacksmithing (must craft personally)" or "Blacksmithing / player trade / Auction House",
            profession="Blacksmithing",professionSkillRequired=skill,
            confidence="client",acquisitionKind="Crafting",acquisitionConfidence="client",
            instructions=intro,notes=stats..". "..(note or ""),
            reagents=reagents,sourceURL="https://foreverdb.net/item/"..id,
        }),"Could not register Warrior item "..tostring(id))
    end
    Rec(id,goal or required,priority,specs,(note or stats)..(bind=="BoP" and
       " BoP; only pursue if THIS Warrior has Blacksmithing." or
       " Tradeable: other blacksmiths/AH possible."))
end

local function Unconfirmed(id,name,slot,required,goal,kind,source,zone,stats,specs,note,races)
    if not GetGear.ItemCatalog[id] then
        assert(GetGear:RegisterItem({
            itemID=id,name=name,slot=slot,availableLevel=required,
            sourceType=kind,source=source.." (Classic-only acquisition reference)",zone=zone,
            confidence="classic-reference",acquisitionKind=kind,
            acquisitionConfidence="classic-reference",
            instructions="Forever client contains the item, but this "..kind:lower().." route has not been observed in Forever. Classic records suggest "..source..". Confirm the reward/drop in-game; never assume Classic rates or quest rewards apply.",
            notes=stats..". "..(note or ""),sourceURL="https://foreverdb.net/item/"..id,
        }),"Could not register Warrior unconfirmed item "..id)
    end
    assert(GetGear:AddRecommendation("WARRIOR",{
        itemID=id,targetLevel=goal,specs=specs,races=races,
        notes="UNCONFIRMED Classic acquisition route. "..(note or "Verify in Forever before pursuing."),
    }),"Could not add unconfirmed Warrior item "..id)
end

-- EARLY LEVELS: modest tradeable mail, weapon options; avoid treating the
-- late-20s BoP mail set as something a non-blacksmith can purchase.
Craft(10421,"Rough Copper Vest","Chest",2,1,"BoE","+1 Stamina",ALL,"Optional",{
    Mat(2840,"Copper Bar",4)},"Early chest only; replace quickly.")
Craft(2853,"Copper Bracers","Wrist",2,1,"No bind","35 armor",ALL,"Optional",{
    Mat(2840,"Copper Bar",2)},"Inexpensive temporary wrist armor.")
Craft(2852,"Copper Chain Pants","Legs",4,40,"BoE","+1 Stamina",ALL,"Optional",{
    Mat(2840,"Copper Bar",4)},"An inexpensive early mail option; skill 40 is required.")
Craft(3469,"Copper Chain Boots","Feet",4,20,"BoE","+1 Stamina",ALL,"Optional",{
    Mat(2840,"Copper Bar",8)},"Entry-level mail footwear.")
Craft(3471,"Copper Chain Vest","Chest",5,30,"BoE","+1 Strength; 108 armor",ALL,"Medium",nil,
    "Cheap tradeable alternative to crafted BoP gear.")
Craft(2844,"Copper Mace","Main Hand",4,15,"No bind","3.8 weapon DPS",PROT,"Medium",{
    Mat(2840,"Copper Bar",6),Mat(2880,"Weak Flux",1),Mat(2589,"Linen Cloth",2)},
    "Use with a shield; check actual weapon DPS before replacing a better quest reward.")
Craft(2845,"Copper Axe","Main Hand",4,20,"No bind","3.8 weapon DPS",PROT,"Optional",nil,
    "Alternative to Copper Mace, not a second mandatory upgrade.")
Craft(7955,"Copper Claymore","Two-Hand Sword",6,30,"BoE","7.7 weapon DPS, +1 Strength, +1 Stamina",DAMAGE,"Medium",{
    Mat(2840,"Copper Bar",10),Mat(2880,"Weak Flux",2),
    Mat(3470,"Rough Grinding Stone",1),Mat(2318,"Light Leather",1)},
    "Slow two-hander for Arms and early Fury; don't use as a Protection shield upgrade.")
Craft(3488,"Copper Battle Axe","Two-Hand Axe",8,35,"BoE","9.0 weapon DPS, +3 Stamina",DAMAGE,"Medium",{
    Mat(2840,"Copper Bar",12),Mat(2880,"Weak Flux",2),
    Mat(774,"Malachite",2),Mat(3470,"Rough Grinding Stone",2),Mat(2318,"Light Leather",2)},
    "Offensive two-hander; prioritize actual weapon damage rather than just stats.")
Craft(6214,"Heavy Copper Maul","Two-Hand Mace",11,65,"BoE","10.8 weapon DPS, +4 Strength",DAMAGE,"Medium",{
    Mat(2840,"Copper Bar",12),Mat(2880,"Weak Flux",2),Mat(2318,"Light Leather",2)},
    "Can also be a leveling weapon if switching out of defensive setup.")
Craft(6730,"Ironforge Chain","Chest",11,80,"BoE","151 armor, +4 Stamina",ALL,"Medium",nil,
    "Tradeable survivability chest; learning source still unverified.")
Craft(2857,"Runed Copper Belt","Waist",13,80,"BoE","91 armor, +3 Strength, +2 Stamina",ALL,"Medium",nil,
    "Affordable tradeable belt if BoP Guard's Belt is unavailable.")
Craft(2854,"Runed Copper Bracers","Wrist",14,90,"BoE","72 armor, +2 Strength, +2 Stamina",ALL,"Medium",nil,
    "Tradeable early wrist upgrade verified in the Forever client.")

-- Forever-exclusive BoP Guard/Veteran pieces with confirmed ACA pattern routes.
-- Withheld: early (not Silvered) Chain Shirts/Leggings and 25 Chain Helms
-- while their actual recipe learning sources are not demonstrably reproducible.
-- Later Silvered items and documented tradeable alternatives are retained.
Craft(250514,"Guard's Chain Belt","Waist",12,45,"BoP","+3 Defense, +4 Stamina, +4 Strength",PROT,"High",nil,
    "High-value early tank belt if personally training Blacksmithing.")
Craft(250509,"Guard's Gloves","Hands",15,80,"BoP","+3 Defense, +5 Stamina, +5 Strength",PROT,"High",nil,
    "Early defensive gauntlets; check AH for alternatives if not a blacksmith.")
Craft(250508,"Veteran's Gloves","Hands",15,80,"BoP","+3 Agility, +5 Stamina, +5 Strength",DAMAGE,"High",nil,
    "Damage gloves; not required when focusing Protection.")
Craft(250504,"Guard's Boots","Feet",17,85,"BoP","+4 Defense, +5 Stamina, +5 Strength",PROT,"High",nil,
    "Defensive boots that persist through multiple dungeon levels.")
Craft(250503,"Veteran's Boots","Feet",17,85,"BoP","+4 Agility, +5 Stamina, +5 Strength",DAMAGE,"High",nil,
    "Offensive alternative to Guard's Boots.")
Craft(3480,"Rough Bronze Shoulders","Shoulder",17,110,"BoE","+4 Stamina, +3 Strength",ALL,"Medium",nil,
    "Convenient tradeable shoulders; compare against any already-equipped rare.")
Craft(2866,"Rough Bronze Cuirass","Chest",18,105,"BoE","+8 Stamina",PROT,"Medium",nil,
    "Tradeable tank chest alternative to the personally crafted Guard's Chain Shirt.")
Craft(2849,"Bronze Axe","Main Hand",18,85,"BoE","11.6 weapon DPS, +3 Strength",PROT,"Medium",nil,
    "Tradeable one-hander; a good shield-compatible DPS upgrade.")
Craft(2850,"Bronze Shortsword","Main Hand",19,95,"BoE","12.2 weapon DPS, +3 Agility",PROT,"Medium",nil,
    "One-handed alternative to Bronze Axe; pick one based on actual gear.")
Craft(3491,"Heavy Bronze Mace","Main Hand",20,130,"BoE","12.9 weapon DPS, +4 Strength",PROT,"High",nil,
    "Shield-compatible threat and soloing weapon. Do not assume stats-only comparison includes DPS.")
Craft(7956,"Bronze Warhammer","Two-Hand Mace",20,125,"BoE","16.9 weapon DPS, +6 Stamina, +6 Strength",DAMAGE,"High",nil,
    "Strong tradeable leveling two-hander for Arms or early Fury.")
Craft(250530,"Protector's Silvered Chain Helm","Head",20,95,"BoP","+7 Defense, +9 Stamina",PROT,"High",nil,
    "Defensive early helm, personally crafted.")
Craft(250528,"Veteran's Silvered Chain Helm","Head",20,95,"BoP","+9 Stamina, +10 Strength",DAMAGE,"High",nil,
    "Offensive early helm.")
Craft(250519,"Guard's Silvered Chain Shirt","Chest",22,110,"BoP","+7 Defense, +10 Stamina, +6 Strength",PROT,"High",nil,
    "Improved level-22 tank chest; offers a reliable vendor-recipe chest at level 22.")
Craft(250518,"Veteran's Silvered Chain Shirt","Chest",22,110,"BoP","+6 Agility, +7 Stamina, +10 Strength",DAMAGE,"High",nil,
    "ACA vendor pattern for a level-22 Arms/Fury chest.")
Craft(3482,"Silvered Bronze Boots","Feet",21,130,"BoE","+4 Strength, +4 Stamina, +3 Spirit",ALL,"Medium",nil,
    "Tradeable boots when self-forged BoP options are unavailable.")
Craft(2870,"Shining Silver Breastplate","Chest",24,145,"BoE","+14 Strength, +6 Stamina",DAMAGE,"Medium",nil,
    "Tradeable damage chest; prioritize threat/tank survival appropriately.")
Craft(250524,"Guard's Silvered Chain Leggings","Legs",25,125,"BoP","+8 Defense, +11 Stamina, +7 Strength",PROT,"High",nil,
    "Level-25 tank leggings, Armor/Defense and Stamina.")
Craft(250523,"Veteran's Silvered Chain Leggings","Legs",25,125,"BoP","+7 Agility, +8 Stamina, +11 Strength",DAMAGE,"High",nil,
    "Damage leg upgrade for Arms and Fury.")
Craft(3849,"Hardened Iron Shortsword","Main Hand",27,135,"BoE","16.7 weapon DPS, +5 Stamina",PROT,"High",nil,
    "Tradeable defensive one-hander; confirm limited supply recipe vendors in-game.")
Craft(3842,"Green Iron Leggings","Legs",26,155,"BoE","+8 Stamina, +8 Strength",ALL,"Medium",nil,
    "Tradeable late-20s mail when the BoP sets are inaccessible.")
Craft(250557,"Sentinel's Belt","Waist",30,150,"BoP","+7 Defense, +10 Stamina, +6 Strength",PROT,"High",nil,
    "End-of-beta Protection belt; do not imply this BoP item is purchasable.")
Craft(250556,"Officer's Belt","Waist",30,150,"BoP","+6 Agility, +7 Stamina, +10 Strength",DAMAGE,"High",nil,
    "Offensive cap-level belt requiring personally trained Blacksmithing.")

-- Classic quest/dungeon leads: item stats are Forever-client facts, but routes
-- are Classic records, not observed Forever drops. NOT level-up announced.
Unconfirmed(5443,"Gold-plated Buckler","Off Hand",17,18,"Dungeon boss drop",
    "Miner Johnson in Deadmines","Westfall / Deadmines",
    "509 armor, +5 Stamina, +2 Agility; Forever proc mitigates first physical hit after entering combat",
    PROT,"Don't assume Miner Johnson or 49% Classic loot rate is unchanged.")
Unconfirmed(13245,"Kresh's Back","Off Hand",18,19,"Dungeon boss drop",
    "Kresh in Wailing Caverns","The Barrens / Wailing Caverns",
    "528 armor, +5 Defense",PROT,
    "Useful shield if verified; no confirmed Forever drop rate.")
Unconfirmed(6970,"Furen's Favor","Off Hand",20,22,"Quest reward",
    "The Shieldsmith following The Rethban Gauntlet","Redridge Mountains / Stormwind City",
    "411 armor, +3 Strength",PROT,
    "Potential Alliance Warrior class quest reward; check actual quest first.")
Unconfirmed(6223,"Crest of Darkshire","Off Hand",30,30,"Quest reward",
    "Bride of the Embalmer","Duskwood",
    "661 armor, +7 Stamina, +2 Strength",PROT,
    "Check the Classic quest's actual Forever minimum level and reward before planning.")
Unconfirmed(6972,"Fire Hardened Hauberk","Chest",28,30,"Quest reward",
    "Furen's Armor (Warrior chain)","Stormwind City / Redridge Mountains",
    "+14 Stamina, +5 Strength, on-use rage",PROT,
    "Class quest follow-up only; availability and reward are not verified in Forever.")
Unconfirmed(7230,"Smite's Mighty Hammer","Two-Hand Mace",18,20,"Dungeon boss drop",
    "Mr. Smite in Deadmines","Westfall / Deadmines",
    "19.7 weapon DPS, +11 Strength, +4 Agility",DAMAGE,
    "Classic boss assignment unconfirmed. Strong if you happen to see it drop.")
Unconfirmed(5197,"Cookie's Tenderizer","Main Hand",16,18,"Dungeon boss drop",
    "Cookie in Deadmines","Westfall / Deadmines",
    "13.9 weapon DPS, +4 Spirit; attack debuff effect",PROT,
    "Compare with other 1H weapons, don't farm assuming Classic drop tables.")

-- A few class-agnostic dungeon sources are deliberately NOT borrowed from the
-- caster catalog: absence is better than recommending spell/healing gear.

-- Beta-observed quest reward, not guaranteed for every quest choice.
assert(GetGear:AddRecommendation("WARRIOR", {itemID=270027, targetLevel=25,
    specs={"Arms","Fury"}, notes="Ursine Hammer, player-observed What Comes Around... quest reward (one report); mutually exclusive with the other rewards, compare weapon DPS."}),"Warrior Ursine Hammer")
