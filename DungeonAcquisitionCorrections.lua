local addonName, GetGear = ...

-- Staged v0.12.10 acquisition corrections. Forever client crafting spells
-- are insufficient proof that the associated level-25 leather helm is
-- obtainable by a player through Leatherworking. Direct Forever dungeon
-- loot reports and finished-item drop indexes supersede those craft claims.
-- IMPORTANT: The level-20 *Hoods* are separate items with actual patterns.
-- Do not change their profession metadata or material lists.
local dungeonHelms = {
    [252512] = { -- Brawler's Leather Helm (NOT Brawler's Leather Hood 252504)
        url = "https://www.wowhead.com/forever/item=252512/brawlers-leather-helm",
        zone = "Blackfathom Deeps / The Stockade / Razorfen Kraul / Scarlet Monastery",
        source = "Dungeon boss drops (Forever reports)",
        confidence = "observed",
        instructions = "Bind on pickup. Obtained as a rare dungeon-boss drop, not by learning the Brawler's Leather Hood pattern. Wowhead Forever reports multiple bosses; a player specifically reports Interrogator Vishas in Scarlet Monastery Graveyard. Individual drop chances are unverified. No Leatherworking is needed to equip it.",
    },
    [252455] = { -- Defender's Leather Helm (NOT Defender's Leather Hood 252505)
        url = "https://www.wowhead.com/forever/item=252455/defenders-leather-helm",
        zone = "Blackfathom Deeps / The Stockade / Razorfen Kraul / Scarlet Monastery",
        source = "Dungeon boss drops (Forever reports)",
        confidence = "observed",
        instructions = "Bind on pickup. Obtained as a dungeon-boss drop; this is not the crafted Defender's Leather Hood. Players report Twilight Lord Kelris in Blackfathom Deeps and other dungeon bosses. Wowhead Forever indexes additional drops; exact chances are unverified. No Leatherworking is required to equip it.",
    },
    [252456] = { -- Totemic Leather Helm (NOT Totemic Leather Hood 252448)
        url = "https://www.wowhead.com/forever/item=252456/totemic-leather-helm",
        zone = "Dungeon bosses (multiple instances)",
        source = "Dungeon boss drops (Forever indexed)",
        confidence = "reported",
        instructions = "Bind on pickup. Wowhead Forever indexes this finished level-25 helm as a drop from multiple dungeon bosses. Do not confuse it with Pattern: Totemic Leather Hood (level 20). A client crafting spell exists, but no usable trainer recipe is established; do not collect crafting materials for this helm. Confirm the current boss table in game.",
    },
    [252515] = { -- Wisdom's Leather Helm (NOT Wisdom's Leather Hood 252507)
        url = "https://www.wowhead.com/forever/item=252515/wisdoms-leather-helm",
        zone = "Blackfathom Deeps / The Stockade / Razorfen Kraul / Scarlet Monastery",
        source = "Dungeon boss drops (Forever indexed)",
        confidence = "reported",
        instructions = "Bind on pickup. Wowhead Forever indexes the finished level-25 helm as a rare dungeon-boss drop, including bosses in Blackfathom Deeps and Razorfen Kraul. This is not the level-20 crafted Wisdom's Leather Hood. The database also exposes a client crafting spell; player access to that spell is unverified. No Leatherworking is needed to equip the dropped helm.",
    },
}

local replacementNotes = {
    [252512] = {
        HUNTER = "Agility/Stamina dungeon loot. Bind on pickup; no Leatherworking required.",
        ROGUE = "Agility/Stamina dungeon loot. Bind on pickup; no Leatherworking required.",
        DRUID = "Feral Agility/Stamina helm from dungeon bosses, not a Leatherworking craft.",
    },
    [252455] = {}, -- Currently registered in the catalogue but not recommended.
    [252456] = {
        DRUID = "Balance spell-power helm from dungeon loot; not a trainer craft.",
        SHAMAN = "Elemental/Restoration spell-power helm from dungeon bosses; not a trainer craft.",
    },
    [252515] = {
        DRUID = "Restoration healing helm from dungeon bosses; no crafting needed.",
        SHAMAN = "Restoration healing helm from dungeon bosses; no crafting needed.",
    },
}

GetGear.DungeonAcquisitionAudit = { correctedIDs = {}, recommendationNotes = 0, reviewedFamily = 6 }
for id, fact in pairs(dungeonHelms) do
    local item = assert(GetGear.ItemCatalog[id], "Missing level-25 helm " .. id)
    assert(item.profession == "Leatherworking" and item.availableLevel == 25,
        "Unexpected pre-correction helm state " .. id)
    -- Actual gear item is a dungeon drop. Clear all misleading craft UI,
    -- reagent totals, trainer badges, pattern pins and source assumptions.
    item.profession = nil
    item.professionSkillRequired = nil
    item.professionSkillEstimate = nil
    item.professionLearnSource = nil
    item.recipeLearnMethod = nil
    item.recipeLearnSkillEvidence = nil
    item.recipeLearnSkillProvisional = nil
    item.recipeLearningAvailability = nil
    item.recipeLearningSourceURL = nil
    item.recipeRequirementEvidenceURL = nil
    item.recipeMethodEvidence = nil
    item.recipeMethodCaution = nil
    item.recipeTrainerListProvenance = nil
    item.recipeSpellID = nil
    item.recipeVendor = nil
    item.reagents = nil
    item.acquisitionLocation = nil
    item.acquisitionLocationConfidence = nil
    item.sourceType = "Dungeon boss drop"
    item.acquisitionKind = "Dungeon boss drop"
    item.confidence = (fact.confidence == "observed") and "observed" or "client"
    item.acquisitionConfidence = fact.confidence
    item.itemSourceEvidence = fact.confidence
    item.source = fact.source
    item.zone = fact.zone
    item.instructions = fact.instructions
    item.notes = (item.notes or ""):gsub("[Pp]ersonal Leatherworking", "dungeon loot")
    item.sourceURL = fact.url
    item.sourceEvidenceURL = fact.url
    item.bindingStatus = "bop"
    item.bindingEvidence = "forever-client-item-tooltip"
    item.bindingEvidenceURL = fact.url
    item.acquisitionResearchNote = "Dungeon-drop evidence supersedes unverified client-only crafting spell."
    GetGear.DungeonAcquisitionAudit.correctedIDs[#GetGear.DungeonAcquisitionAudit.correctedIDs+1] = id
    for cls, recs in pairs(GetGear.Recommendations or {}) do
        for _, rec in ipairs(recs) do
            if rec.itemID == id then
                local note = replacementNotes[id] and replacementNotes[id][cls]
                assert(note, "Unexpected class recommendation for reclassified helm " .. id .. ": " .. cls)
                rec.notes = note
                rec.instructions = nil -- inherit corrected item facts
                GetGear.DungeonAcquisitionAudit.recommendationNotes =
                    GetGear.DungeonAcquisitionAudit.recommendationNotes + 1
            end
        end
    end
end

-- Explicitly protect the distinct level-20 crafted Hoods from mistaken
-- name-family merging; missing entries are not introduced here.
for _, id in ipairs({252504,252505,252448,252507}) do
    local hood = GetGear.ItemCatalog[id]
    if hood then
        assert(hood.profession == "Leatherworking" and hood.reagents and #hood.reagents > 0,
            "Level-20 Hood incorrectly converted to dungeon drop " .. id)
    end
end
