local addonName, GetGear = ...
-- Beta 7 evidence reconciliation (development only).
-- Applied after the dated client cache and the 259 hand-reviewed records.
-- Never replace class masks, item identities or level gates.
-- These three fixes use published Forever-specific item/recipe/dungeon evidence.
-- "Published" does not mean personally observed in the live client.

local patches = {
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
