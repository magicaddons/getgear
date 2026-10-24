local addonName, GetGear = ...

-- WoW Forever 1.60.1 build 70450; Alliance Druid level 1-30 pilot.
-- Item identity and required levels are sourced from Forever beta client
-- records (ForeverDB). Pattern locations have NOT been inferred from Classic.
-- Class quest rewards explicitly marked classic-reference are unconfirmed
-- for Forever. The 'All' planning profile includes mutually exclusive sets.
assert(GetGear:RegisterGuide("DRUID", {
    faction="Alliance", status="research-preview", label="Druid",
}), "Could not register Alliance Druid guide")

local CAT = {"Feral Cat"}
local BEAR = {"Feral Bear"}
local FERAL = {"Feral Cat","Feral Bear"}
local CASTER = {"Balance","Restoration"}
local BALANCE = {"Balance"}
local HEAL = {"Restoration"}
local ALL = {"Balance","Feral Cat","Feral Bear","Restoration"}

local function Mat(id,name,count) return {itemID=id,name=name,amount=count} end
local LEATHER=2318; local THREAD=2320; local HIDE=4231
local function AddCraft(id,name,slot,requiredLevel,skill,bind,stats,specs,priority,reagents,note,goalLevel)
    -- Shared item facts are registered only once. Existing caster data is never
    -- overwritten; recommendation metadata remains class-specific.
    if not GetGear.ItemCatalog[id] then
        local instructions = "Craft through Leatherworking (skill " .. tostring(skill) .. "). "
        if skill==1 then
            instructions="Learned automatically with Leatherworking (skill 1). "
        end
        if bind=="BoP" then
            instructions=instructions .. "Binds when picked up: this character must have Leatherworking and craft it personally. "
        else
            instructions=instructions .. "BoE: an eligible leatherworker can craft it, or check the Auction House. "
        end
        if skill~=1 then
            instructions=instructions .. "This Forever-client recipe is confirmed, but the exact trainer, vendor or drop that teaches it has not been independently verified. Check your recipe list before travelling."
        end
        assert(GetGear:RegisterItem({
            itemID=id,name=name,slot=slot,availableLevel=requiredLevel,
            sourceType="Leatherworking",source=(skill==1 and "Leatherworking 1: automatically learned" or "Leatherworking recipe (learning source unconfirmed)"),
            zone="Leatherworking / Auction House (BoE only)",
            profession="Leatherworking",professionSkillRequired=skill,
            confidence="client",acquisitionKind="Crafting",acquisitionConfidence="client",
            instructions=instructions,
            notes=stats..". "..(note or ""),
            reagents=reagents,sourceURL="https://foreverdb.net/item/"..id,
        }),"Could not register Druid gear item "..id)
    end
    assert(GetGear:AddRecommendation("DRUID",{
        itemID=id,targetLevel=goalLevel or requiredLevel,focus="All",specs=specs,
        notes=(note or stats)..(bind=="BoP" and " Bind on pickup: requires your own Leatherworking." or ""),
    }),"Could not register Druid recommendation "..id)
end

local function AddQuest(id,name,slot,level,source,zone,stats,specs,notes)
    assert(GetGear:RegisterItem({
        itemID=id,name=name,slot=slot,availableLevel=level,
        sourceType="Quest",source=source.." (Classic reward reference)",zone=zone,
        confidence="classic-reference",acquisitionConfidence="classic-reference",
        acquisitionKind="Quest reward",sourceURL="https://foreverdb.net/item/"..id,
        instructions="Classic Druid quest records list "..name.." as a reward from "..source..". " ..
            "The quest reward has NOT been observed in WoW Forever; verify with the quest giver before relying on it.",
        notes=stats..". "..notes,
    }))
    assert(GetGear:AddRecommendation("DRUID",{
        itemID=id,targetLevel=level,focus="All",specs=specs,
        notes="Classic-only quest reward; verify current Forever quest rewards before pursuing.",
    }))
end

-- Level 3-10: accessible, tradeable low-level leather, then new caster boots.
-- Full reagents shown only when checked against Forever Leatherworking recipes.
AddCraft(5957,"Handstitched Leather Vest","Chest",3,1,"BoE","+1 Agility",ALL,"Optional",{
    Mat(LEATHER,"Light Leather",3),Mat(THREAD,"Coarse Thread",1)},
    "This recipe is learned automatically at Leatherworking 1; replace this item quickly.")
AddCraft(2303,"Handstitched Leather Pants","Legs",5,15,"BoE","+1 Agility",ALL,"Optional",{
    Mat(LEATHER,"Light Leather",4),Mat(THREAD,"Coarse Thread",1)},
    "Starter leather protection, not a long-term objective.")
AddCraft(2300,"Embossed Leather Vest","Chest",7,40,"BoE","+2 Stamina",ALL,"Optional",{
    Mat(LEATHER,"Light Leather",8),Mat(THREAD,"Coarse Thread",4)},
    "Useful stamina if readily available; do not delay leveling for it.")
AddCraft(252427,"Moonglow Boots","Feet",10,35,"BoP","+5 Spell Power, +4 Stamina",CASTER,"High",{
    Mat(LEATHER,"Light Leather",12),Mat(HIDE,"Cured Light Hide",2),
    Mat(5498,"Small Lustrous Pearl",1)},
    "Spell-focused early footwear; requires personal Leatherworking.")
AddCraft(4242,"Embossed Leather Pants","Legs",10,75,"BoE","+3 Spell Power, +2 Stamina",CASTER,"Medium",{
    Mat(LEATHER,"Light Leather",6),Mat(HIDE,"Cured Light Hide",1),
    Mat(THREAD,"Coarse Thread",2)},
    "Tradeable early caster option.")

-- Level 15-22: sourced gear only. Level-15 rare leather Armor recipes
-- (Defender/Wisdom/Stormrider and their related family) have no observed
-- live beta acquisition source; excluded pending reproducible confirmation.
AddCraft(4244,"Hillman's Leather Vest","Chest",15,75,"BoE","+4 Spell Power, +4 Stamina",CASTER,"Optional",nil,
    "Tradeable caster alternative if not investing in the new BoP leather sets.")
AddCraft(252494,"Brawler's Leather Gloves","Hands",15,75,"BoP","+4 Agility, +3 Stamina, +4 Strength",CAT,"Medium",nil,
    "Physical damage alternative; compare with Defender's Gloves for Bear.")
AddCraft(252496,"Defender's Leather Gloves","Hands",15,75,"BoP","+4 Stamina, +4 Strength; bonus armor",BEAR,"High",nil,
    "Defensive hands when tanking.")
AddCraft(252498,"Stormrider's Leather Gloves","Hands",15,75,"BoP","+4 Intellect, +5 Spell Power, +3 Stamina",BALANCE,"High",nil,
    "Dedicated Balance hands; recipe pattern source remains to verify.")
AddCraft(20575,"Black Whelp Tunic","Chest",15,75,"BoE","+5 Intellect, +3 Spell Power",CASTER,"Optional",{
    Mat(2319,"Medium Leather",8),Mat(7286,"Black Whelp Scale",8),
    Mat(HIDE,"Cured Light Hide",1),Mat(2321,"Fine Thread",2)},
    "Tradeable alternative if useful material stock is available.")
AddCraft(252441,"Defender's Leather Boots","Feet",17,85,"BoP","+5 Stamina, +5 Strength; bonus armor",FERAL,"High",nil,
    "Physical Druid footwear; defensive priority is higher for Bear.")
AddCraft(252443,"Stormrider's Leather Boots","Feet",17,85,"BoP","+5 Intellect, +6 Spell Power, +4 Stamina",BALANCE,"High",nil,
    "High-value early Balance boots.")
AddCraft(6468,"Deviate Scale Belt","Waist",18,90,"BoE","+6 Stamina, +5 Agility, +3 Strength",FERAL,"High",{
    Mat(6471,"Perfect Deviate Scale",10),Mat(6470,"Deviate Scale",10),
    Mat(2321,"Fine Thread",2)},
    "BoE leatherworking piece; source of the pattern may differ from Classic.")
AddCraft(252445,"Defender's Leather Pants","Legs",20,105,"BoP","+4 Agility, +6 Stamina, +9 Strength",FERAL,"High",nil,
    "Solid Cat/Bear choice, especially while self-leveling Leatherworking.")
AddCraft(252502,"Stormrider's Leather Pants","Legs",20,105,"BoP","+6 Intellect, +10 Spell Power, +4 Spirit, +4 Stamina",BALANCE,"High",nil,
    "Balance leg upgrade; uses Forever-specific caster leather stats.")
AddCraft(252503,"Wisdom's Leather Pants","Legs",20,105,"BoP","+6 Intellect, +7 Spell Damage, +20 Healing, +4 Spirit, +4 Stamina",HEAL,"High",nil,
    "Restoration leg upgrade; healing and damage hybrid.")
AddCraft(252504,"Brawler's Leather Hood","Head",20,100,"BoP","+10 Stamina, +8 Agility",FERAL,"High",nil,
    "Feral-focused leather head before later dungeon-drop helms.")
AddCraft(252507,"Wisdom's Leather Hood","Head",20,100,"BoP","+6 Spell Damage, +17 Healing, +10 Stamina",HEAL,"High",nil,
    "Healing-focused head while leveling.")
AddCraft(252448,"Totemic Leather Hood","Head",20,100,"BoP","+9 Spell Power, +10 Stamina",BALANCE,"High",nil,
    "Balance head; later replaced by the Totemic Helm.")
AddCraft(7352,"Earthen Leather Shoulders","Shoulder",22,110,"BoE","+7 Stamina",FERAL,"Medium",nil,
    "Straightforward tradeable leather shoulders, especially for Bear.")
AddCraft(252450,"Defender's Leather Tunic","Chest",22,110,"BoP","+6 Agility, +8 Stamina, +6 Strength; strong armor",FERAL,"High",nil,
    "Feral chest upgrade over the level-15 Defender armor.")
AddCraft(252510,"Stormrider's Leather Tunic","Chest",22,110,"BoP","+6 Intellect, +10 Spell Power, +5 Spirit, +6 Stamina",BALANCE,"High",nil,
    "Top tier leather caster chest through the beta cap.")

-- ACA-stocked Restoration chest, not the unlocated level-15 Wisdom's Armor.
AddCraft(252511,"Wisdom's Leather Tunic","Chest",22,110,"BoP",
    "+6 Intellect, +6 Spirit, +5 Stamina, +6 Spell Damage, +18 Healing",HEAL,"High",{
    Mat(2319,"Medium Leather",10),Mat(4233,"Cured Medium Hide",3),
    Mat(249427,"Pristine Leather",6),Mat(2321,"Fine Thread",3),
    Mat(5498,"Small Lustrous Pearl",6)},
    "Restoration chest; Pattern: Wisdom's Leather Tunic is sold by Daniel Stitchsong for 30 Merchant's Favor.")

-- Level 25-30: crafted cap objectives and dungeon-drop helms, with later acquisition correction module.
AddCraft(252457,"Defender's Leather Kilt","Legs",25,125,"BoP","+7 Agility, +9 Stamina, +7 Strength; 58 bonus armor",FERAL,"High",nil,
    "A Feral leveling priority for its combined physical stats and bonus armor.")
AddCraft(252512,"Brawler's Leather Helm","Head",25,130,"BoP","+10 Agility, +13 Stamina",FERAL,"High",nil,
    "Feral-focused leather helm for the 25-30 bracket.")
AddCraft(252456,"Totemic Leather Helm","Head",25,130,"BoP","+12 Spell Power, +13 Stamina",BALANCE,"High",nil,
    "Strong late-beta Balance item with Forever-specific spell power.")
AddCraft(252515,"Wisdom's Leather Helm","Head",25,130,"BoP","+7 Spell Damage, +21 Healing, +13 Stamina",HEAL,"High",nil,
    "Restoration alternative, requiring personal Leatherworking.")
AddCraft(252519,"Wisdom's Leather Leggings","Legs",25,125,"BoP","+7 Intellect, +7 Spell Damage, +21 Healing, +7 Spirit, +6 Stamina",HEAL,"High",nil,
    "Late-20s healing leggings, compare with older Wisdom's Pants.")
AddCraft(3719,"Hillman's Cloak","Back",25,150,"BoE","+5 Spell Power, +4 Stamina",CASTER,"Medium",nil,
    "Tradeable cloak; Leatherworking recipe access still needs checking.")
AddCraft(18948,"Barbaric Bracers","Wrist",27,130,"BoE","+6 Stamina, +4 Strength, +4 Agility",FERAL,"Medium",nil,
    "Tradeable late-20s wrist upgrade; stats differ from Classic.")
AddCraft(7348,"Fletcher's Gloves","Hands",20,125,"BoE","+14 Critical Strike, -15 Parry",CAT,"Optional",nil,
    "Offensive crit with a parry penalty; do not prioritize for tanking.")
AddCraft(252460,"Warden's Leather Belt","Waist",30,150,"BoP","+6 Agility, +9 Stamina, +6 Strength; strong armor",FERAL,"High",nil,
    "Cap-level Feral objective, Leatherworking 150 required.")
AddCraft(252522,"Skycaller's Leather Belt","Waist",30,150,"BoP","+6 Intellect, +10 Spell Power, +4 Spirit, +6 Stamina",BALANCE,"High",nil,
    "Cap-level Balance crafted belt.")
AddCraft(252523,"Mender's Leather Belt","Waist",30,150,"BoP","+6 Intellect, +6 Spell Damage, +19 Healing, +6 Spirit, +4 Stamina",HEAL,"High",nil,
    "Cap-level Restoration crafted belt.")

-- Classic-reward routes are speculative: the client contains the items,
-- but the route and reward have not been observed in Forever. Kept Optional.
AddQuest(15866,"Veildust Medicine Bag","Off Hand",14,
    "Curing the Sick (Night Elf Druid class quest)","Darkshore / Moonglade",
    "+1 Spirit, +1 Intellect; on-use mana regeneration",CASTER,
    "Requires a compatible one-handed weapon; quest may be different for Skyborne.")
AddQuest(16608,"Aquarius Belt","Waist",16,
    "Aquatic Form (Night Elf Druid quest)","Moonglade / Darnassus",
    "+2 Stamina, +2 Intellect",ALL,
    "Classic Night Elf route; no Forever player-confirmed quest reward.")

-- First verified level-20 Druid relic craft; its recipe learning source is
-- not currently reported, so do not direct players to an invented trainer.
assert(GetGear:RegisterItem({
    itemID=249396,name="Mystic Mushroom",slot="Relic",availableLevel=20,
    sourceType="Enchanting",source="Enchanting 130 recipe (learning source unverified)",
    zone="Enchanting / recipe source unknown",profession="Enchanting",professionSkillRequired=130,
    confidence="client",acquisitionKind="Crafting",acquisitionConfidence="client",
    instructions="Mystic Mushroom is an Enchanting 130 craft and binds on pickup. " ..
        "The Druid must have Enchanting to craft it. The exact recipe trainer/drop is not yet verified in Forever.",
    notes="Druid relic: increases Spirit by 5%. Unknown recipe source; do not farm an assumed location.",
    sourceURL="https://foreverdb.net/item/249396",
}))
assert(GetGear:AddRecommendation("DRUID",{
    itemID=249396,targetLevel=20,specs=CASTER,
    notes="Optional spirit-scaling idol if personally leveling Enchanting. No confirmed recipe learning location.",
}))

-- Weapon objectives: beta item data confirmed; sources kept conservative.
assert(GetGear:RegisterItem({
    itemID=13045,name="Viscous Hammer",slot="Two-Hand Mace",availableLevel=30,
    sourceType="World drop",source="Tradeable world item / Auction House",
    zone="Auction House; enemy drop source not confirmed in Forever",
    confidence="client",acquisitionKind="World drop / player trade",
    acquisitionConfidence="classic-reference",sourceURL="https://foreverdb.net/item/13045",
    instructions="Search your realm's Auction House: this BoE mace has appeared in Forever player AH scans. " ..
        "Specific world monsters and lockbox drops are Classic references, NOT confirmed beta sources. Check price before buying.",
    notes="Two-handed mace: 30.2 weapon DPS, +34 Attack Power, +3 Strength, +6 Stamina. " ..
        "Very expensive on some beta realms. Feral weapon DPS matters; check the equipped tooltip.",
}))
assert(GetGear:AddRecommendation("DRUID",{
    itemID=13045,targetLevel=30,specs=FERAL,
    notes="Expensive world-drop/AH alternative, not required for leveling. Form weapon DPS needs in-game comparison.",
}))
assert(GetGear:RegisterItem({
    itemID=9449,name="Manual Crowd Pummeler",slot="Two-Hand Mace",availableLevel=29,
    sourceType="Dungeon",source="Crowd Pummeler 9-60 (Classic boss-reference)",
    zone="Gnomeregan",confidence="classic-reference",
    acquisitionConfidence="classic-reference",acquisitionKind="Dungeon boss drop",
    sourceURL="https://foreverdb.net/item/9449",
    instructions="Classic loot assigns this weapon to Crowd Pummeler 9-60 in Gnomeregan. " ..
        "The Forever item exists, but the boss drop rate and actual Forever boss assignment are not verified. " ..
        "Do not treat the Classic 40% rate as valid for Forever.",
    notes="29.0 weapon DPS, +16 Strength, +5 Agility; on-use +50% attack speed for 30 seconds. " ..
        "Feral interactions with the on-use effect need testing in Forever.",
}))
assert(GetGear:AddRecommendation("DRUID",{
    itemID=9449,targetLevel=30,specs=FERAL,
    notes="Classic-only boss drop; do not farm without corroboration of the Forever source and effect.",
}))

-- Shared Forever dungeon items already registered by DungeonGear.lua.
-- These remain optional for Druid where accessibility or performance is mixed.
local function Reuse(id,level,priority,specs,notes)
    assert(GetGear.ItemCatalog[id],"DungeonGear.lua must load before DruidGear.lua: "..id)
    assert(GetGear:AddRecommendation("DRUID",{
        itemID=id,targetLevel=level,focus="All",specs=specs,notes=notes,
    }),"Duplicate shared Druid dungeon item "..id)
end
Reuse(273024,29,"Medium",CASTER,
    "Observed Forever Saltspine boots; cloth is usable, but compare with role-specific crafted leather footwear.")
Reuse(273030,30,"High",CASTER,
    "Observed Forever Relic Guardian ring, useful for Balance spell power and Restoration mana regeneration.")
Reuse(273031,30,"Optional",HEAL,
    "Forever-observed healing ring from difficult City of Dalaran dungeon; weigh access against improvement.")
Reuse(273052,30,"Optional",HEAL,
    "Observed healing off-hand from City of Dalaran; requires a one-handed main-hand weapon.")
Reuse(273643,24,"Optional",CASTER,
    "Observed Shadowfang Keep utility trinket, useful for mana regeneration and worgen control.")

-- An early, speculative but useful class-agnostic weapon from existing records.
-- Its Classic quest reward is deliberately labelled unconfirmed.
assert(GetGear.ItemCatalog[2042],"Staff of Westfall base record missing")
assert(GetGear:AddRecommendation("DRUID",{
    itemID=2042,targetLevel=18,specs=CASTER,
    notes="Classic Westfall quest reward, not confirmed in Forever; convenient caster weapon if available.",
}))

-- Added only after independent Forever quest-cache observation; the weapon
-- is not a raw-DPS guarantee inside Cat/Bear form.
assert(GetGear:AddRecommendation("DRUID", {itemID=270027, targetLevel=25,
    specs=FERAL, notes="OPTIONAL Ursine Hammer; player-observed choice from What Comes Around... (single report). Cat/Bear weapon DPS scaling must be judged in-game; prioritize stats, not raw 2H DPS."}), "Druid Ursine Hammer")
assert(GetGear:AddRecommendation("DRUID", {itemID=7374, targetLevel=30,
    specs=FERAL, notes="Optional tradeable +14 Agility chest at 30, without requiring personal Leatherworking. Compare Bear armor and Stamina."}), "Druid Dusky Leather Armor")
assert(GetGear:AddRecommendation("DRUID", {itemID=2816, targetLevel=28,
    specs={"Restoration"}, notes="OPTIONAL powerful +68 Healing one-hand mace. Jargba/RFK drop association is only from Classic; verify Forever loot before farming."}),"Druid healer scepter")
