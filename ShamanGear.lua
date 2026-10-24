local addonName, GetGear = ...

-- GetGear v0.11.0: researched WoW Forever Alliance level 1-30 preview.
-- Specs are manual profiles. Classic-only sources and unknown recipe routes are flagged.
assert(GetGear:RegisterGuide("SHAMAN", {faction="Alliance",status="research-preview",label="Shaman"}), "Could not register SHAMAN guide")

local specs = {
    ALL={"Elemental","Enhancement","Restoration"},
    ELEHEAL={"Elemental","Restoration"},
    ELE={"Elemental"},
    HEAL={"Restoration"},
    ENH={"Enhancement"},
}
local function Rec(id,level,profile,note,race)
    assert(GetGear:AddRecommendation("SHAMAN", {itemID=id,targetLevel=level,
        specs=specs[profile], notes=note, races=race,
    }), "Missing or duplicate SHAMAN recommendation "..id)
end

Rec(5957,3,"ALL","Entry tradeable leather chest; Shamans do not gain mail until 40.",nil)
Rec(2303,5,"ALL","Entry leather pants.",nil)
Rec(2300,7,"ALL","Tradeable leather vest.",nil)
Rec(4242,10,"ELEHEAL","+3 Spell Power and +2 Stamina; not an Enhancement physical-DPS upgrade.",nil)
Rec(2844,4,"ELEHEAL","One-handed mace plus shield while leveling; prioritize mana and caster stats.",nil)
Rec(252427,10,"ELEHEAL","Moonglow Boots give Spell Power; caster-only BoP personal Leatherworking. Verify pattern learning before committing.",nil)
Rec(4244,15,"ELEHEAL","+4 Spell Power and +4 Stamina; caster chest, not an Enhancement damage upgrade.",nil)
Rec(252496,15,"ENH","Defender Strength/Stamina gloves, personal Leatherworking.",nil)
Rec(252498,15,"ELEHEAL","Stormrider spell-focused gloves, personal Leatherworking.",nil)
Rec(252495,15,"ENH","Trapper hybrid gloves, alternative personally crafted.",nil)
Rec(252443,17,"ELEHEAL","Stormrider boots for Elemental/Restoration, personal Leatherworking.",nil)
Rec(252441,17,"ENH","Defender boots for Enhancement, personal Leatherworking.",nil)
Rec(252507,20,"HEAL","Wisdom healer hood, personal Leatherworking.",nil)
Rec(252448,20,"ELEHEAL","Totemic hood: +9 Spell Power / +10 Stamina, for caster builds; personally crafted BoP.",nil)
Rec(252504,20,"ENH","Brawler alternative helm.",nil)
Rec(252502,20,"ELE","Stormrider spell pants, BoP personally crafted.",nil)
Rec(252503,20,"HEAL","Wisdom healing pants, BoP personally crafted.",nil)
Rec(252501,20,"ENH","Trapper hybrid pants with Intellect; personal Leatherworking.",nil)
Rec(249398,20,"ALL","Enchanting-only BoP relic with mana regeneration; don't assume the formula is sold anywhere.",nil)
Rec(252510,22,"ELE","Stormrider caster chest; personal Leatherworking.",nil)
Rec(252511,22,"HEAL","Wisdom healing chest; personal Leatherworking.",nil)
Rec(252509,22,"ENH","Trapper hybrid chest +Agility/+Intellect, BoP personally crafted.",nil)
-- Coldspire Staff (271215) has FROST-SPECIFIC spell damage, not generic Spell Power
-- or healing; it is not a meaningful all-purpose Elemental/Restoration goal.
Rec(2280,24,"ENH","Observed Kam Deepfury staff; 23.8 DPS and Agility/Intellect.",nil)
Rec(252456,25,"ELEHEAL","Totemic helm: +12 Spell Power / +13 Stamina; recipe learning route unknown, never assume Daniel sells it.",nil)
Rec(252515,25,"HEAL","Wisdom healer helm BoP personal Leatherworking.",nil)
Rec(252519,25,"HEAL","Wisdom healer leggings BoP personal Leatherworking.",nil)
Rec(252459,30,"ENH","Prowler belt +Strength/+Agility/+Intellect; BoP personal Leatherworking.",nil)
Rec(252522,30,"ELE","Skycaller Elemental belt; personal Leatherworking.",nil)
Rec(252523,30,"HEAL","Mender Restoration belt; personal Leatherworking.",nil)
Rec(273030,28,"ELEHEAL","Observed ring, compare its actual caster stats.",nil)
Rec(2933,29,"ALL","Late-20s Seal of Wrynn quest chain.",nil)

-- Do not recommend unverified two-hand axe/mace proficiencies for Shaman.
Rec(5541,23,"ENH","Tradeable Iridescent Hammer for a one-hand + shield Enhancement option. +3 Strength/+3 Stamina, recipe source requires checking.",nil)
Rec(13245,20,"ELEHEAL","OPTIONAL Kresh's Back defensive shield; Kresh in Wailing Caverns is Classic-only boss source, not observed Forever.",nil)
Rec(6223,30,"ELEHEAL","OPTIONAL Crest of Darkshire shield; associated Darkshire quest is Classic-only source reference. Check quest rewards first.",nil)
Rec(2816,28,"HEAL","OPTIONAL Restoration healing mace, +68 Healing. Loot source is Classic-reference only; verify Jargba/Razorfen Kraul in Forever.",nil)
