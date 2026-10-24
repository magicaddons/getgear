local addonName, GetGear = ...

-- GetGear v0.11.0: researched WoW Forever Alliance level 1-30 preview.
-- Specs are manual profiles. Classic-only sources and unknown recipe routes are flagged.
assert(GetGear:RegisterGuide("ROGUE", {faction="Alliance",status="research-preview",label="Rogue"}), "Could not register ROGUE guide")

local specs = {
    ALL={"Assassination","Combat","Subtlety"},
    DAGGER={"Assassination","Subtlety"},
    COMBAT={"Combat"},
}
local function Rec(id,level,profile,note,race)
    assert(GetGear:AddRecommendation("ROGUE", {itemID=id,targetLevel=level,
        specs=specs[profile], notes=note, races=race,
    }), "Missing or duplicate ROGUE recommendation "..id)
end

Rec(5957,3,"ALL","Inexpensive leather starter vest; tradeable.",nil)
Rec(2303,5,"ALL","Entry-level leather trousers.",nil)
Rec(2300,7,"ALL","Next tradeable leather chest.",nil)
Rec(7166,6,"DAGGER","Crafted entry dagger for Backstab; item is tradeable.",nil)
Rec(2845,8,"COMBAT","Axe is usable by Forever Rogue; Combat alternative.",nil)
Rec(2850,19,"COMBAT","One-hand sword for Sinister Strike; best available melee DPS matters.",nil)
Rec(252494,15,"ALL","Brawler Agility gloves; only if THIS Rogue can personally Leatherwork.",nil)
Rec(252439,17,"ALL","BoP Brawler boots, personal Leatherworking only.",nil)
Rec(252504,20,"ALL","Brawler hood, personal Leatherworking only.",nil)
Rec(252445,20,"ALL","Defender pants for survivability; personal Leatherworking only.",nil)
Rec(252501,20,"ALL","Trapper hybrid pants as alternative to defensive options, personal Leatherworking.",nil)
Rec(5540,18,"DAGGER","Tradeable crafted dagger. Keep two daggers for late Assassination Mutilate.",nil)
Rec(3490,20,"DAGGER","Tradeable Deadly Bronze Poniard +4 Agility, weapon suitable for Mutilate later.",nil)
Rec(6681,27,"DAGGER","OPTIONAL: Thornspike drop location is Classic-only, verify before farming.",nil)
Rec(3850,30,"COMBAT","Tradeable crafted end-cap Combat sword; check current weapon DPS.",nil)
Rec(5192,17,"COMBAT","OPTIONAL: Deadmines Mr. Smite loot is Classic-reference, not observed Forever.",nil)
Rec(252508,22,"ALL","BoP Brawler chest, needs THIS Rogue Leatherworking; Agility priority.",nil)
Rec(273805,21,"ALL","Observed Targorr Stockade leather chest, alternative to personally crafted gear.",nil)
Rec(7352,22,"ALL","Tradeable leather shoulders; verify stats vs existing shoulders.",nil)
Rec(7348,20,"ALL","Fletcher's Gloves: +14 Critical Strike but -15 Parry. An offensive tradeoff; avoid for survivability/tank-style gear.",nil)
Rec(2933,29,"ALL","Seal of Wrynn is a later quest-chain goal, not a realistic level-16 pickup.",nil)
Rec(273034,27,"ALL","Observed dungeon gloves; check item armor/stat suitability.",nil)
Rec(252512,25,"ALL","Brawler helm: personal Leatherworking.",nil)
Rec(252520,30,"ALL","Skulker belt: BoP, personal Leatherworking at skill 150.",nil)
Rec(273829,26,"ALL","Observed Stockade crossbow, ranged slot stats; compare against thrown.",nil)
Rec(274092,21,"ALL","Stockade thrown weapon observed; precise dropper uncertain.",nil)
Rec(3849,27,"COMBAT","Tradeable crafted sword alternative if no stronger drop.",nil)
Rec(18948,27,"ALL","Tradeable leather bracers for late leveling.",nil)
Rec(6468,18,"ALL","Optional Deviate Scale Belt, reward choice is exclusive; consult existing details.",nil)

-- Independent off-hand objectives use distinct stable SavedVariables keys.
-- The main-hand copies retain their v0.11.1 item_#### keys.
assert(GetGear:AddRecommendation("ROGUE", {itemID=7166, targetLevel=10,
    id="item_7166_offhand", slot="Off Hand", specs=specs.DAGGER,
    notes="OPTIONAL second Copper Dagger for Dual Wield at 10. Same item requires a second copy; compare off-hand DPS."}),"Rogue Copper Dagger off-hand")
assert(GetGear:AddRecommendation("ROGUE", {itemID=5540, targetLevel=18,
    id="item_5540_offhand", slot="Off Hand", specs=specs.DAGGER,
    notes="OPTIONAL second Pearl-handled Dagger. Tradeable; equip a second copy off hand; watch speed for Mutilate."}),"Rogue Pearl-handled Dagger off-hand")
assert(GetGear:AddRecommendation("ROGUE", {itemID=3490, targetLevel=20,
    id="item_3490_offhand", slot="Off Hand", specs=specs.DAGGER,
    notes="OPTIONAL second Deadly Bronze Poniard (BoE). Acquiring two copies is not mandatory; compare other offhands."}),"Rogue Poniard off-hand")
assert(GetGear:AddRecommendation("ROGUE", {itemID=2850, targetLevel=20,
    id="item_2850_offhand", slot="Off Hand", specs=specs.COMBAT,
    notes="OPTIONAL second Bronze Shortsword for Combat offhand. Forever version is a tradeable one-hand sword with +3 Agility; keep original sword objective as main hand."}),"Rogue Bronze Shortsword offhand")
Rec(7374,30,"ALL","Dusky Leather Armor: tradeable BoE +14 Agility chest at 30. Leatherworking 175; AH/crafter possible, actual trainer route not yet verified.",nil)
