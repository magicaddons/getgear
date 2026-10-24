local addonName, GetGear = ...

-- GetGear v0.11.0: researched WoW Forever Alliance level 1-30 preview.
-- Specs are manual profiles. Classic-only sources and unknown recipe routes are flagged.
assert(GetGear:RegisterGuide("HUNTER", {faction="Alliance",status="research-preview",label="Hunter"}), "Could not register HUNTER guide")

local specs = {
    ALL={"Beast Mastery","Marksmanship","Survival"},
    SURV={"Survival"},
}
local function Rec(id,level,profile,note,race)
    assert(GetGear:AddRecommendation("HUNTER", {itemID=id,targetLevel=level,
        specs=specs[profile], notes=note, races=race,
    }), "Missing or duplicate HUNTER recommendation "..id)
end

Rec(5957,3,"ALL","Tradeable leather starter chest.",nil)
Rec(2303,5,"ALL","Affordable leather legs.",nil)
Rec(2300,7,"ALL","Tradeable early leather chest.",nil)
Rec(5596,11,"ALL","Crown of the Earth observed as Forever quest reward; Night Elf route only.",{"NightElf"})
Rec(2903,16,"ALL","A Hunter's Boast is a Classic-only quest reference; verify live Forever.",nil)
Rec(252494,15,"ALL","Agility-heavy Brawler gloves, BoP personal Leatherworking.",nil)
Rec(252495,15,"ALL","Trapper hybrid gloves, BoP personal Leatherworking.",nil)
Rec(252439,17,"ALL","Agility-heavy Brawler boots; personal Leatherworking.",nil)
Rec(252504,20,"ALL","Brawler hood, BoP personal Leatherworking.",nil)
Rec(252501,20,"ALL","Trapper +Agility pants, BoP personal Leatherworking.",nil)
Rec(252508,22,"ALL","Brawler tunic +Agility; BoP personal Leatherworking.",nil)
Rec(252509,22,"ALL","Alternative Trapper hybrid tunic; BoP personal Leatherworking.",nil)
Rec(6469,19,"ALL","Venomstrike Bow from Lord Serpentis is Classic-only loot reference.",nil)
Rec(250603,20,"SURV","Tradeable Blacksmithing Bronze Dory polearm, +8 Agility. Survival option.",nil)
Rec(273819,23,"SURV","Observed Stockade polearm; use as two-hander for Survival melee, not ranged DPS.",nil)
Rec(2280,24,"ALL","Observed Stockade Staff +10 Agility; stat stick with strong melee ability.",nil)
Rec(273829,26,"ALL","Observed Stockade crossbow +12 Ranged AP, 15.2 DPS. Top priority ranged upgrade.",nil)
Rec(252512,25,"ALL","Brawler +Agility helm, personal Leatherworking.",nil)
Rec(7352,22,"ALL","Tradeable leather shoulders.",nil)
Rec(7348,20,"ALL","Fletcher's Gloves: +14 Critical Strike but -15 Parry. Tradeable offensive choice with a serious avoidance penalty.",nil)
Rec(252521,30,"ALL","Stalker belt with Agility, Intellect and Stamina; BoP personal Leatherworking.",nil)
Rec(252520,30,"SURV","Skulker Strength/Agility alternative for melee-heavy Survival, BoP.",nil)
Rec(18948,27,"ALL","Tradeable late bracers.",nil)
Rec(273034,27,"ALL","Observed gloves; compare Agility and effect.",nil)
Rec(2933,29,"ALL","Seal of Wrynn quest chain goal is late 20s.",nil)

-- Practical vendor and tradeable alternatives. Vendor inventories here are
-- Classic references unless a Forever player observation exists.
Rec(2506,3,"ALL","Hornwood Recurve Bow: inexpensive weapon-merchant bow; exact Forever vendor inventory not independently confirmed.",nil)
Rec(11304,14,"ALL","Fine Longbow: +4 Attack Power Forever variant. Tradeable; Classic bowyer inventory, verify seller in beta.",nil)
Rec(3026,16,"ALL","Reinforced Bow: baseline vendor bow if dungeon/quest choices unavailable; Classic merchant source not verified in Forever.",nil)
Rec(3027,20,"ALL","Heavy Recurve Bow: basic vendor alternative around level 20. Check its in-client DPS; vendor location Classic-reference.",nil)
Rec(7374,30,"ALL","Dusky Leather Armor: +14 Agility, BoE level-30 chest; attainable through trade/crafter when Leatherworking 175 recipe is learned.",nil)
