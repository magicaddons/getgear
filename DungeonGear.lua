local addonName, GetGear = ...

-- GetGear v0.8.1: level-30-cap dungeon boss loot audit for Alliance casters.
-- All loot IDs/stats were checked against Forever client item records.
-- "observed" means a player-reported Forever boss drop, NOT a reliable drop rate.
-- "classic-reference" means only the boss source is inherited from Classic.
-- Recommendations use realistic suggested farming levels, NOT the minimum
-- item equip level. Existing item IDs and per-character progress stay intact.

local wetlandsEntrance = {
    zone="Wetlands", x=47.8, y=56.3,
    spot="Excavation Site: Wetlands portal (approach from Thelgen Rock)",
    quality="reported", -- community beta coordinate; verify in game
}
local shadowfangZone = {
    zone="Silverpine Forest", spot="Shadowfang Keep dungeon in Silverpine Forest",
    quality="zone-only",
}
local lordaeronZone = {
    zone="Tirisfal Glades", spot="Ruins of Lordaeron above Undercity (hostile access for Alliance)",
    quality="zone-only",
}
local blackfathomEntrance = {
    zone="Ashenvale", x=14.5, y=14.6,
    spot="Blackfathom Deeps outer ruins at Zoram Strand",
    quality="forever",
}
local razorfenEntrance = {
    zone="The Barrens", x=42.3, y=89.9,
    spot="Razorfen Kraul entrance", quality="forever",
}

local function Register(id, name, slot, requiredLevel, dungeon, boss, effects, confidence, instructions, location, notes)
    local observed = confidence == "observed"
    assert(GetGear:RegisterItem({
        itemID=id, name=name, slot=slot, availableLevel=requiredLevel,
        sourceType="Dungeon", source=boss .. (observed and " (Forever drop observed)" or " (Classic boss reference)"),
        zone=dungeon, instructions=instructions, notes=notes or effects,
        confidence=observed and "observed" or "classic-reference",
        acquisitionKind="Dungeon boss drop", acquisitionConfidence=confidence,
        acquisitionLocation=location,
        sourceURL="https://foreverdb.net/item/" .. tostring(id),
    }), "Could not register dungeon item " .. tostring(id))
end

local function Recommend(class, id, level, priority, focus, notes, specs)
    local rec = {
        itemID=id, targetLevel=level, focus=focus or "All", notes=notes,
    }
    if specs then rec.specs=specs end
    assert(GetGear:AddRecommendation(class, rec),
        "Duplicate or missing " .. class .. " recommendation " .. tostring(id))
end

local function ForAll(id, level, priority, notes)
    Recommend("PRIEST",id,level,priority,"All",notes)
    Recommend("WARLOCK",id,level,priority,"All",notes)
    Recommend("MAGE",id,level,priority,"All",notes)
end

-- Ruins of Lordaeron: Rath'mael observed in one recorded kill.
Register(271215,"Coldspire Staff","Two-Hand Staff",19,
    "Ruins of Lordaeron","Rath'mael","+32 Frost Damage; +13 Frost Resistance",
    "observed",
    "Observed from Rath'mael in Ruins of Lordaeron. The dungeon is above Undercity in Horde-controlled territory; arranging an Alliance run is a substantial detour. One recorded drop does not establish a drop rate.",
    lordaeronZone,
    "Strong Frost-specific staff. Compare with both current main-hand and off-hand gear.")
Recommend("MAGE",271215,23,"Medium","Frost",
    "Powerful Frost weapon, but Alliance travel and group access make it optional to pursue early.")

-- Shadowfang Keep: Commander Springvale drop observed in Forever.
Register(273643,"Worgenbane Talisman","Trinket",21,
    "Shadowfang Keep","Commander Springvale","+2 mana per 5 seconds; use: stun a worgen for 4 seconds",
    "observed",
    "Observed on Commander Springvale in Shadowfang Keep. The use effect works on worgen. Consider this situational rather than mandatory caster equipment.",
    shadowfangZone,
    "Mana regeneration trinket with useful niche crowd-control utility.")
ForAll(273643,24,"Optional","Useful mana regeneration and worgen utility if running Shadowfang Keep.")

-- Excavation Site: Wetlands: player-recorded bosses; very small loot samples.
Register(273024,"Glinteye Slippers","Feet",26,
    "Excavation Site: Wetlands","Saltspine","+7 Spell Power; +9 Stamina; +6 Spirit",
    "observed",
    "Observed from Saltspine in Excavation Site: Wetlands (a level 26-31 dungeon). The community-reported portal is on a hill above Whelgar's Excavation, approached via a path near Thelgen Rock. Do not treat one reported drop as a guaranteed drop.",
    wetlandsEntrance,
    "Strong non-Tailoring alternative. Compare it with school-specific crafted boots before farming.")
ForAll(273024,29,"High","Useful general-purpose boots, especially if you are not crafting specialized Tailoring footwear.")

Register(273030,"Ring of Power Regulation","Ring",28,
    "Excavation Site: Wetlands","Relic Guardian","+6 Spell Power; +3 mana per 5 seconds",
    "observed",
    "Observed from Relic Guardian in Excavation Site: Wetlands. Both ring slots can be compared; this is not a guaranteed drop. The beta entrance location is community-reported.",
    wetlandsEntrance,
    "Excellent general caster ring for the late-20s dungeon bracket.")
ForAll(273030,30,"High","General spell-power ring with mana regeneration; good for all three cloth classes.")

-- City of Dalaran: level 28-35, with few player kills logged. The portal is
-- inside Dalaran City; there is no reliable surface-zone waypoint, so no pin.
local dalaranNote = "City of Dalaran is a demanding level 28-35 dungeon near the level-30 beta cap. Its Alliance entrance is inside Dalaran: descend to the Underbelly, find the tavern, then enter the gate/tunnel beside it. No reliable world-map waypoint is assigned. "

Register(273031,"Runemender's Seal","Ring",27,
    "City of Dalaran","Arcane Anomaly","+9 Healing Power; +3 Spell Damage; +7 Spirit; +4 Stamina",
    "observed",
    dalaranNote .. "Observed from Arcane Anomaly in limited Forever dungeon kill records; rates are not established.",
    nil,"Healing-oriented ring; separate ring-slot comparisons apply.")
Recommend("PRIEST",273031,30,"High","Healing",
    "Strong for Holy/Discipline at 30, but difficult dungeon access.",{"Holy","Discipline"})
Recommend("WARLOCK",273031,30,"Optional","All",
    "Situational survival/mana ring; dungeon effort is high relative to DPS gains.")
Recommend("MAGE",273031,30,"Optional","All",
    "Alternative ring if running Dalaran; not a priority over damage-focused options.")

Register(273034,"Ephemeral Grips","Hands",27,
    "City of Dalaran","Arcane Anomaly","+7 Stamina; +7 Intellect; +9 Arcane and +9 Shadow Damage",
    "observed",
    dalaranNote .. "Observed in Arcane Anomaly dungeon loot logs and the current item page; not an assured drop.",
    nil,"Best suited to Arcane and Shadow-oriented casters; less appealing to pure Fire/Frost builds.")
Recommend("PRIEST",273034,30,"High","Shadow",
    "Powerful Shadow hands upgrade if you can clear this dungeon at the beta cap.")
Recommend("WARLOCK",273034,30,"High","Affliction",
    "Strong Shadow gloves for Affliction or Demonology; harder to get than crafted options.",
    {"Affliction","Demonology"})
Recommend("MAGE",273034,30,"High","Arcane",
    "Strong Arcane gloves; compare against your Pearly gear and other alternatives.")

Register(273036,"Graveweave Bindings","Wrist",26,
    "City of Dalaran","Atrexis the Grave Knight","+5 Spell Power; +2 mana per 5 seconds; +6 Strength",
    "observed",
    dalaranNote .. "Player dungeon records list Atrexis as the drop source, but the item's individual page has not yet reconciled that location. Treat the assignment as provisional despite the observed dungeon log.",
    nil,"Universal spell-power bracers; Strength has little caster value.")
ForAll(273036,30,"Optional","A niche wrist upgrade from a difficult dungeon; source listed in observed logs but with cross-page inconsistency.")

Register(273051,"Violet Sorcerer's Mantle","Shoulder",30,
    "City of Dalaran","Shade of the Archmage","+9 Intellect; +4 Spell Penetration",
    "observed",
    dalaranNote .. "Observed from Shade of the Archmage in Forever. Part of Violet Sorcerer's Vestments; assess any set bonus separately.",
    nil,"PvP/Arcane-minded option; not automatically better than spell-power shoulders.")
Recommend("MAGE",273051,30,"Optional","Arcane",
    "Potential PvP or set-piece option; +4 spell penetration is situational.")

Register(273052,"Ponderous Orb","Off Hand",30,
    "City of Dalaran","Shade of the Archmage","+11 Healing Power; +4 Spell Damage; +8 Spirit; +2 Intellect",
    "observed",
    dalaranNote .. "Observed from Shade of the Archmage. Requires a compatible one-handed weapon; a two-handed staff prevents off-hand use.",
    nil,"Excellent healing off-hand at 30 when paired with a suitable main-hand.")
Recommend("PRIEST",273052,30,"High","Healing",
    "Strong Holy/Discipline off-hand, but only useful with an eligible main-hand.",
    {"Holy","Discipline"})

-- Classic boss references: Forever item stats confirmed, exact boss-source
-- observation not yet recorded. Optional and not used for level-up alerts.
Register(6392,"Belt of Arugal","Waist",23,
    "Shadowfang Keep","Archmage Arugal","+9 Spell Power; +3 Intellect; +5 Spirit; +2 Agility",
    "classic-reference",
    "Classic loot lists Archmage Arugal in Shadowfang Keep. Item stats have changed in Forever; this exact boss drop has not been independently observed in the beta. Check before farming.",
    shadowfangZone,
    "Good universal caster belt if the Classic boss source remains valid.")
ForAll(6392,26,"Optional","Potential +9 Spell Power belt; boss-drop source remains Classic-derived.")

Register(6697,"Batwing Mantle","Shoulder",29,
    "Razorfen Kraul","Blind Hunter","+6 Spell Power; +11 Intellect; +3 Agility",
    "classic-reference",
    "Classic loot associates this with the rare Blind Hunter in Razorfen Kraul. Forever stats are confirmed, but an observed Forever boss drop is not yet corroborated. Blind Hunter itself may not spawn every run.",
    razorfenEntrance,
    "Strong late-20s shoulders if the boss is present; do not make a special farm solely on unverified loot.")
ForAll(6697,30,"Optional","Useful alternative shoulders if a Razorfen Kraul run is already planned.")

-- Blackfathom Deeps: The older data treated Ghamoo-ra's Bind as Classic-only;
-- Forever dungeon kill logs now show it dropping from Ghamoo-ra.
local ghamoora = GetGear.ItemCatalog[6908]
if ghamoora then
    ghamoora.source="Ghamoo-ra (Forever drop observed)"
    ghamoora.instructions="Observed dropping from Ghamoo-ra in Blackfathom Deeps in Forever dungeon kill logs. Check the boss if already running the dungeon; small samples are not stable drop rates."
    ghamoora.confidence="observed"
    ghamoora.acquisitionConfidence="observed"
    ghamoora.notes="+8 Spell Power and +7 Stamina; useful general-purpose belt from an observed Forever dungeon drop."
end
for _, list in pairs(GetGear.Recommendations) do
    for _, rec in ipairs(list) do
        if rec.itemID == 6908 then
            rec.instructions = nil -- prefer the refreshed shared, observed-source instruction
            rec.notes = "Ghamoo-ra's Bind has now been observed dropping in Forever. Do not rely on Classic or tiny-sample drop percentages."
        end
    end
end

Register(1155,"Rod of the Sleepwalker","Two-Hand Staff",24,
    "Blackfathom Deeps","Twilight Lord Kelris","+11 Spirit; reduces the hit chance of Sleep effects against you by 5%",
    "observed",
    "Observed dropping from Twilight Lord Kelris in Blackfathom Deeps. Forever REMOVED the Classic +11 Intellect; its current stats are +11 Spirit and sleep-effect resistance, not a general spell-damage upgrade.",
    blackfathomEntrance,
    "Optional for Spirit or niche PvP resistance; not a recommended DPS farm.")
Recommend("PRIEST",1155,27,"Optional","All",
    "Niche defensive/Spirit staff; do not assume it retains Classic Intellect.")
Recommend("MAGE",1155,27,"Optional","All",
    "Niche staff only; Frost/Arcane crafted or dropped alternatives may be stronger.")
Recommend("WARLOCK",1155,27,"Optional","All",
    "Consider only for situational sleep resistance; not a general damage upgrade.")

-- Newly observed Filigreed pattern drops (the patterns themselves, not the
-- wearable cloth gear). These are examples, not exclusive guaranteed sources.
local patternFinds = {
    [253941]={boss="Lady Sarevess",dungeon="Blackfathom Deeps"},
    [253983]={boss="Geilhast",dungeon="Blackfathom Deeps"},
    [253981]={boss="Twilight Lord Kelris",dungeon="Blackfathom Deeps"},
    [253979]={boss="Aku'mai",dungeon="Blackfathom Deeps"},
}
for id,source in pairs(patternFinds) do
    local item=GetGear.ItemCatalog[id]
    if item then
        local pattern="Pattern: " .. (item.name or "Filigreed gear")
        item.source=pattern .. " - observed dungeon drop / AH if tradeable"
        item.zone="Blackfathom Deeps; other dungeon loot may also be possible"
        item.instructions=pattern .. " has been observed dropping from " .. source.boss ..
            " in " .. source.dungeon .. ". Other drop locations may exist. " ..
            "These small player samples are not reliable drop odds. Check the AH only if the pattern is tradeable; the finished armour binds on pickup."
        item.acquisitionConfidence="observed"
        item.acquisitionKind="Dungeon pattern drop"
        -- Existing items may have had vendor/other map pins; do not invent
        -- a boss interior pin. Their location is the dungeon entrance.
        item.acquisitionLocation=blackfathomEntrance
        for _, list in pairs(GetGear.Recommendations) do
            for _, rec in ipairs(list) do
                if rec.itemID==id then
                    rec.instructions=nil -- shared facts now contain observed-source guidance
                    rec.notes="Pattern observed in Blackfathom Deeps; other drop sources may exist. This is not a guaranteed boss drop."
                end
            end
        end
    end
end

GetGear.DungeonAuditVersion="0.8.1"
