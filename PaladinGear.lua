local addonName, GetGear = ...

-- GetGear v0.11.0: researched WoW Forever Alliance level 1-30 preview.
-- Specs are manual profiles. Classic-only sources and unknown recipe routes are flagged.
assert(GetGear:RegisterGuide("PALADIN", {faction="Alliance",status="research-preview",label="Paladin"}), "Could not register PALADIN guide")

local specs = {
    ALL={"Protection","Holy","Retribution"},
    PROT={"Protection"},
    HOLY={"Holy"},
    RET={"Retribution"},
}
local function Rec(id,level,profile,note,race)
    assert(GetGear:AddRecommendation("PALADIN", {itemID=id,targetLevel=level,
        specs=specs[profile], notes=note, races=race,
    }), "Missing or duplicate PALADIN recommendation "..id)
end

Rec(10421,2,"ALL","Basic tradeable mail starter.",nil)
Rec(2852,4,"ALL","Early tradeable mail pants.",nil)
Rec(3471,5,"ALL","Tradeable mail chest; Strength aids soloing.",nil)
Rec(2844,4,"PROT","One-handed mace with shield; weapon DPS for threat.",nil)
Rec(7955,6,"RET","Two-hander to keep kills quick, not for dungeon tank setup.",nil)
Rec(6214,11,"RET","Tradeable two-handed mace.",nil)
Rec(6730,11,"ALL","Tradeable Stamina mail chest.",nil)
Rec(250514,12,"PROT","BoP Guard Belt: Protection personal Blacksmithing.",nil)
Rec(2857,13,"ALL","Tradeable Blacksmithing waist alternative.",nil)
Rec(250509,15,"PROT","Guard tank gloves; personally craft only.",nil)
Rec(250511,15,"HOLY","Acolyte Holy gloves, personally craft only.",nil)
Rec(250508,15,"RET","Veteran Strength/Agility gloves, personally craft only.",nil)
Rec(250505,17,"PROT","BoP Protector tank boots personal Blacksmithing.",nil)
Rec(250506,17,"HOLY","BoP Acolyte healer boots personal Blacksmithing.",nil)
Rec(250503,17,"RET","Veteran offensive boots personal Blacksmithing.",nil)
Rec(3480,17,"ALL","Tradeable Stamina and Strength shoulders.",nil)
Rec(7956,20,"RET","Strong tradeable 2H melee mace; not for shields.",nil)
Rec(3491,20,"PROT","Tradeable 1H mace plus shield for tank play.",nil)
Rec(250530,20,"PROT","BoP Protector Silvered tank helm personal Blacksmithing.",nil)
Rec(250531,20,"HOLY","BoP Acolyte Silvered heal helm personal Blacksmithing.",nil)
Rec(250528,20,"RET","BoP Veteran Silvered offensive helm personal Blacksmithing.",nil)
Rec(250520,22,"PROT","BoP Protector Silvered chest: personal Blacksmithing; +Def/Stamina/Spell Power.",nil)
Rec(250521,22,"HOLY","BoP Acolyte Silvered chest: personal Blacksmithing; +Healing.",nil)
Rec(250518,22,"RET","BoP Veteran Silvered offensive chest personal Blacksmithing.",nil)
Rec(2870,24,"RET","Tradeable offensive chest alternative to BoP crafted.",nil)
Rec(250525,25,"PROT","BoP Protector Silvered tank legs personal Blacksmithing.",nil)
Rec(250526,25,"HOLY","BoP Acolyte Silvered healing legs personal Blacksmithing.",nil)
Rec(250523,25,"RET","BoP Veteran Silvered legs personal Blacksmithing.",nil)
Rec(250500,25,"PROT","Alternative BoP tank helm if Silvered not learned.",nil)
Rec(250501,25,"HOLY","Alternative BoP Holy helm if Silvered not learned.",nil)
Rec(250502,25,"RET","Crusader Spell Power/Strength helm; personally forged.",nil)
Rec(249397,20,"ALL","Paladin relic: BoP Enchanting craft; only pursue with personal Enchanting 130.",nil)
Rec(250558,30,"PROT","BoP Warder tank belt, plans learning source uncertain.",nil)
Rec(250559,30,"HOLY","BoP Prefect healer belt, plans learning source uncertain.",nil)
Rec(250556,30,"RET","BoP Officer offensive belt: personal Blacksmithing.",nil)
Rec(13245,24,"PROT","Shield option with Classic-only Kresh boss association; verify in beta.",nil)
Rec(6223,30,"PROT","Classic-only Darkshire quest reward association; verify in Forever.",nil)
Rec(2933,29,"ALL","Long Stormwind quest chain goal; late 20s.",nil)
Rec(273030,28,"ALL","Observed dungeon ring. Compare stat priorities.",nil)

-- The following options explicitly distinguish beta-observed rewards and
-- Classic-only quest associations. Do not announce the latter as guaranteed.
Rec(6953,22,"RET","OPTIONAL Verigan's Fist, Paladin-only 2H mace, 25.6 DPS and Holyfire proc. The Test of Righteousness acquisition is Classic-only; verify live quest before farming.",nil)
Rec(270027,25,"RET","Ursine Hammer is one of the player-observed What Comes Around... reward choices (one-player report). Mutually exclusive with Lucine Longsword/Hardened Root Staff.",nil)
Rec(5541,23,"PROT","Iridescent Hammer, tradeable one-hand mace (+3 Strength/+3 Stamina); crafted Blacksmithing and can pair with shield. Recipe learning source still check in beta.",nil)
Rec(2816,28,"HOLY","OPTIONAL Holy healer mace, +68 Healing. Jargba boss drop in Razorfen Kraul is CLASSIC-ONLY loot-table reference; check in Forever before farming.",nil)
