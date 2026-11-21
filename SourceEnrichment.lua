local addonName, GetGear = ...
-- Beta 7 evidence reconciliation (development only).
-- Applied after the dated client cache and the 259 hand-reviewed records.
-- Never replace class masks, item identities or level gates.
-- Corrections include published Forever-specific item/recipe/dungeon evidence
-- and clearly labelled Classic-reference dungeon trash sources.
-- "Published" does not mean personally observed in the live client.

local patches = {
    [1943] = { -- Goblin Mail Leggings: ordinary Deadmines mob, not a boss
        sourceType = "Dungeon trash",
        source = "The Deadmines - Goblin Shipbuilder (trash; Classic loot reference)",
        sourceSummary = "The Deadmines | Trash: Goblin Shipbuilder (Classic ref.)",
        zone = "The Deadmines",
        acquisitionKind = "Dungeon trash drop",
        acquisitionConfidence = "classic-reference",
        sourceURL = "https://www.wowhead.com/forever/item=1943/goblin-mail-leggings",
        instructions = "Goblin Shipbuilder is an ordinary enemy in The Deadmines, not a boss. The listed drop source comes from Classic loot references; confirm the drop on Forever before targeted farming.",
    },
    [1951] = { -- Blackwater Cutlass: Classic-reference regular enemies
        sourceType = "Dungeon trash",
        source = "The Deadmines - Defias Pirate / Defias Squallshaper (trash; Classic loot reference)",
        sourceSummary = "The Deadmines | Trash: Defias Pirate / Squallshaper (Classic ref.)",
        zone = "The Deadmines",
        acquisitionKind = "Dungeon trash drop",
        acquisitionConfidence = "classic-reference",
        sourceURL = "https://www.wowhead.com/forever/item=1951/blackwater-cutlass",
        instructions = "Classic loot tables list Defias Pirate and Defias Squallshaper as drops in The Deadmines. These are ordinary enemies, not bosses. Specific live Forever loot rates remain unverified.",
    },
    [250489] = { -- Guard's Chain Shirt: dropped Blacksmithing plans, NOT a trainer recipe
        sourceType = "Blacksmithing",
        source = "Plans: Guard's Chain Shirt (dropped recipe; live source not verified)",
        sourceSummary = "Blacksmithing | Dropped plans (low-level dungeon loot; source unverified)",
        zone = "Dropped plans / Blacksmithing",
        profession = "Blacksmithing",
        professionSkillRequired = 80,
        recipeLearnMethod = "pattern",
        recipePatternItemID = 251341,
        recipeLearnSkillEvidence = "published-forever-plan",
        recipeLearningSourceURL = "https://www.wowhead.com/forever/item=251341/plans-guards-chain-shirt",
        recipeAcquisitionKind = "Drop",
        recipeDropSource = "Published low-level dungeon loot references; not confirmed live",
        acquisitionKind = "Crafted gear - dropped plans",
        acquisitionConfidence = "published-forever",
        bindingStatus = "bop",
        bindingEvidence = "published-forever-item-tooltip",
        instructions = "Learn Plans: Guard's Chain Shirt at Blacksmithing 80. The plans are a drop, NOT trainer-taught; reported dungeon mobs and their drop chances still require live Forever verification. The finished chest binds on pickup, so the intended wearer must craft it.",
    },
    [250513] = { -- Veteran's Chain Belt
        profession = "Blacksmithing",
        professionSkillRequired = 45, -- PLAN LEARNING MINIMUM, not yellow at 85
        recipeSpellID = 1252262,
        recipeLearnMethod = "pattern",
        recipeLearnSkillEvidence = "published-forever-plan",
        recipeLearningEvidence = "Forever plans tooltip and ACA vendor listing; live stock not observed",
        recipeLearningSourceURL = "https://www.wowhead.com/forever/item=251365/plans-veterans-chain-belt",
        recipeVendor = "Stondry Darkhammer",
        recipeVendorCost = 30,
        recipeVendorCurrency = "Merchant's Favor",
        sourceType = "Blacksmithing",
        source = "Plans: Veteran's Chain Belt - Stondry Darkhammer (ACA)",
        zone = "Three Corners, Redridge Mountains",
        sourceURL = "https://www.wowhead.com/forever/item=251365/plans-veterans-chain-belt",
        acquisitionKind = "Recipe vendor",
        acquisitionConfidence = "published-forever",
        acquisitionLocation = {
            zone = "Redridge Mountains", spot = "Stondry Darkhammer, ACA plans",
            x = 8.01, y = 74.81, quality = "forever",
        },
        acquisitionLocationConfidence = "published-forever",
        bindingStatus = "bop",
        bindingEvidence = "published-forever-item-tooltip",
        instructions = "Buy Plans: Veteran's Chain Belt from Stondry Darkhammer, the Azeroth Commerce Authority blacksmith in Redridge Mountains (8.01, 74.81), for 30 Merchant's Favor. Learn the plans at Blacksmithing 45. The finished item binds on pickup, so the intended wearer must be the blacksmith. Verify live vendor availability.",
        notes = "Published Forever recipe and materials; 85 is the first yellow skill-up threshold, NOT the plan-learning requirement.",
        reagents = {
            {itemID=2840, name="Copper Bar", amount=12},
            {itemID=3470, name="Rough Grinding Stone", amount=4},
            {itemID=249427, name="Pristine Leather", amount=2},
            {itemID=5498, name="Small Lustrous Pearl", amount=2},
        },
    },
    [220606] = { -- Idol of the Dream: finished gear is crafted, not Temple of Atal'Hakkar loot
        sourceType = "Enchanting",
        source = "Formula: Idol of the Dream - Alynsia (ACA vendor; live stock unverified)",
        sourceSummary = "Enchanting | Formula: Idol of the Dream - Alynsia (ACA; live stock unverified)",
        zone = "Three Corners, Redridge Mountains",
        sourceURL = "https://www.wowhead.com/forever/item=220606",
        profession = "Enchanting",
        professionSkillRequired = 300,
        recipeSpellID = 1249128,
        recipeLearnMethod = "pattern",
        recipePatternItemID = 249529,
        recipeLearnSkillEvidence = "published-forever-plan",
        recipeLearningEvidence = "Forever recipe and formula tooltips plus published ACA vendor reference; live stock unverified",
        recipeLearningSourceURL = "https://www.wowhead.com/forever/item=249529/formula-idol-of-the-dream",
        recipeAcquisitionKind = "Vendor",
        recipeVendor = "Alynsia",
        recipeVendorCost = 240,
        recipeVendorCurrency = "Merchant's Favor",
        acquisitionKind = "Crafted gear - recipe vendor",
        acquisitionConfidence = "published-forever",
        bindingStatus = "bop",
        bindingEvidence = "published-forever-item-tooltip",
        acquisitionLocation = {
            zone = "Redridge Mountains", spot = "Alynsia, ACA formula",
            x = 10.71, y = 71.94, quality = "published-forever",
        },
        acquisitionLocationConfidence = "published-forever",
        instructions = "Crafted using Enchanting 300, NOT a Temple of Atal'Hakkar equipment drop. Published Forever references list Formula: Idol of the Dream (#249529) from Alynsia (ACA) at Three Corners for 240 Merchant's Favor; the formula requires Honored reputation. Live stock and current reputation gates remain unverified. The finished idol binds on pickup.",
        reagents = {
            {itemID=14344, name="Large Brilliant Shard", amount=2},
            {itemID=16203, name="Greater Eternal Essence", amount=4},
            {itemID=16204, name="Illusion Dust", amount=6},
            {itemID=249431, name="Viridian Dye", amount=8},
            {itemID=249430, name="Magenta Dye", amount=4},
            {itemID=249409, name="Cerulean Dye", amount=2},
            {itemID=11291, name="Star Wood", amount=4},
        },
    },
    [274490] = { -- Centaur Hoofwarmers: newly verified craft omitted from the original recipe inventory
        sourceType = "Leatherworking",
        source = "Pattern: Centaur Hoofwarmers - Molkar / Gorhak (published vendors; live stock unverified)",
        sourceSummary = "Leatherworking | Molkar / Gorhak pattern (published; stock/access unverified)",
        zone = "Desolace",
        sourceURL = "https://www.wowhead.com/forever/spell=1294289",
        profession = "Leatherworking",
        professionSkillRequired = 165, -- pattern learning requirement, not an equip or skill-up threshold
        recipeSpellID = 1294289,
        recipeLearnMethod = "pattern",
        recipePatternItemID = 274491,
        recipeLearnSkillEvidence = "published-forever-pattern",
        recipeLearningEvidence = "Exact Forever pattern/spell/reagent and two merchant inventory joins; live stock/access unverified",
        recipeLearningSourceURL = "https://www.wowhead.com/forever/item=274491",
        recipeAcquisitionKind = "Vendor",
        recipeVendor = "Molkar / Gorhak (different standing and currency costs)",
        recipeVendorCurrency = "Carved Centaur Totem",
        acquisitionKind = "Crafted gear - recipe vendor",
        acquisitionConfidence = "published-forever",
        bindingStatus = "boe",
        bindingEvidence = "published-forever-item-tooltip",
        instructions = "Published craft: learn Pattern: Centaur Hoofwarmers (#274491) at Leatherworking 165; use 12 Thick Leather and 2 Heavy Silken Thread. Matched book sellers in Desolace: Molkar (#253140), 35.6,92, Honored Gelkis, 15 Carved Centaur Totems (#254432); Gorhak (#253139), 66.2,79.4, Exalted Magram, 60 totems. Each seller lists its own standing condition; do not require both rival clans for one purchase. Current stock, phase, access and currency supply unverified. The pattern binds on pickup, but the finished boots bind on equip and can be traded; the wearer need not learn Leatherworking merely to equip them.",
        reagents = {
            {itemID=4304, name="Thick Leather", amount=12},
            {itemID=8343, name="Heavy Silken Thread", amount=2},
        },
    },
    [271098] = { -- Golemguard Chest
        sourceType = "Dungeon",
        source = "Plunder - The Hall of Thanes",
        zone = "The Hall of Thanes",
        sourceURL = "https://www.wowhead.com/forever/dungeon-journal/the-hall-of-thanes/plunder",
        acquisitionKind = "Dungeon boss drop",
        acquisitionConfidence = "published-forever-dungeon-journal",
        instructions = "Golemguard Chest is listed on Plunder's loot table. Plunder is the third boss in The Hall of Thanes. The listed source does not establish a live drop percentage.",
        notes = "Source: Forever Dungeon Journal; current drop rate is unverified.",
    },
    [2864] = { -- Runed Copper Breastplate
        profession = "Blacksmithing",
        professionSkillRequired = 55, -- published Forever plan-use requirement
        recipeSpellID = 2667,
        recipeLearnMethod = "pattern",
        recipeLearnSkillEvidence = "published-forever-plan",
        recipeLearningEvidence = "Forever plans/recipe tooltips; creature-specific live drops unverified",
        recipeLearningSourceURL = "https://www.wowhead.com/forever/item=2881/plans-runed-copper-breastplate",
        sourceType = "Blacksmithing",
        source = "Plans: Runed Copper Breastplate (world drop)",
        zone = "World drop / player trade / Auction House",
        sourceURL = "https://www.wowhead.com/forever/spell=2667/runed-copper-breastplate",
        acquisitionKind = "Crafting - dropped plans",
        acquisitionConfidence = "published-forever",
        instructions = "Craft using Plans: Runed Copper Breastplate, a tradable world-drop plan (not a trainer recipe). Forever plan data reports Blacksmithing 55 to learn it. Specific live creature drop rates and locations are not verified; search the Auction House or obtain the plans from another player.",
        notes = "Published Forever recipe, reagents and plan requirement; do not confuse 95 yellow / 115 green / 135 grey with the learning minimum. Some third-party mirrors show older skill requirements.",
        reagents = {
            {itemID=2840, name="Copper Bar", amount=12},
            {itemID=1210, name="Shadowgem", amount=1},
            {itemID=3470, name="Rough Grinding Stone", amount=2},
        },
    },
}
local updated=0
for id, changes in pairs(patches) do
    local item=assert(GetGear.ItemCatalog and GetGear.ItemCatalog[id],
        "Beta 7 correction references unknown item "..tostring(id))
    assert(GetGear.EquipmentEligibility and GetGear.EquipmentEligibility[id],
        "Beta 7 correction lacks client equipability "..tostring(id))
    for field, value in pairs(changes) do
        assert(field~="itemID" and field~="availableLevel" and field~="slot",
            "Beta 7 source correction must not rewrite equipment identity/gates")
        item[field]=value
    end
    updated=updated+1
end
GetGear.Beta7Reconciliation = {verifiedSourcePatches=updated, status="partial"}
