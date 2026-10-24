local addonName, GetGear = ...

-- v0.6.0: Share verified item facts across class guides while keeping the
-- recommendation (target level, playstyle) specific to each guide.
-- The existing Priest records are migrated in memory only; their stable IDs
-- and the SavedVariablesPerCharacter format are intentionally unchanged.
-- Shared acquisition instructions provide fallback for other classes; a
-- class recommendation may override them when its route differs.
local legacyPriest = GetGear.Gear or {}
GetGear.ItemCatalog = {}
GetGear.Recommendations = { PRIEST = {} }
GetGear.GuideDefinitions = {
    PRIEST = { faction = "Alliance", status = "research-preview", label = "Priest" },
}

local recommendationFields = {
    id=true, targetLevel=true, focus=true,
    instructions=true, notes=true, specs=true,
}
for _, record in ipairs(legacyPriest) do
    local id = record.itemID
    if type(id) == "number" and not GetGear.ItemCatalog[id] then
        local item = {}
        for key, value in pairs(record) do
            if not recommendationFields[key] or key == "instructions" then item[key] = value end
        end
        GetGear.ItemCatalog[id] = item
        GetGear.Recommendations.PRIEST[#GetGear.Recommendations.PRIEST + 1] = {
            itemID = id,
            id = record.id, -- preserve saved status, hidden and minimized keys
            targetLevel = record.targetLevel,
            focus = record.focus or "All",
            instructions = record.instructions,
            notes = record.notes,
        }
    end
end
legacyPriest = nil
GetGear.Gear = {}

-- Future class guide modules can register verified shared item records and
-- their own class-specific recommendations without modifying the UI.
function GetGear:RegisterGuide(classToken, config)
    if type(classToken) ~= "string" or type(config) ~= "table" then return false end
    self.GuideDefinitions[classToken] = config
    if not self.Recommendations[classToken] then self.Recommendations[classToken] = {} end
    return true
end

function GetGear:RegisterItem(item)
    if type(item) ~= "table" or type(item.itemID) ~= "number" then return false end
    if self.ItemCatalog[item.itemID] then return false end
    self.ItemCatalog[item.itemID] = item
    return true
end

function GetGear:AddRecommendation(classToken, recommendation)
    if type(recommendation) ~= "table" or type(recommendation.itemID) ~= "number"
        or type(recommendation.targetLevel) ~= "number" then return false end
    if not self.GuideDefinitions[classToken] or not self.ItemCatalog[recommendation.itemID] then return false end
    local list = self.Recommendations[classToken]
    for _, previous in ipairs(list) do
        -- Two separate copies of a one-handed weapon may be objectives for
        -- main and off hand. A distinct persisted ID and slot are mandatory.
        if previous.itemID == recommendation.itemID then
            local facts = self.ItemCatalog[recommendation.itemID]
            local oldSlot = previous.slot or facts.slot
            local newSlot = recommendation.slot or facts.slot
            if oldSlot == newSlot or not recommendation.id
                or recommendation.id == previous.id then return false end
        end
        if recommendation.id and previous.id == recommendation.id then return false end
    end
    local entry = {}
    for key, value in pairs(recommendation) do
        if key ~= "priority" then entry[key] = value end
    end
    if not entry.id then entry.id = "item_" .. tostring(recommendation.itemID) end
    if not entry.focus then entry.focus = "All" end
    list[#list+1] = entry
    return true
end

-- These are manual planning profiles, not assumptions about unlocked talents or
-- the Forever beta's specialization API. 'All' preserves the legacy Priest list.
GetGear.Specializations = {
    PRIEST = {"All", "Shadow", "Holy", "Discipline"},
    MAGE = {"All", "Arcane", "Fire", "Frost"},
    PALADIN = {"All", "Protection", "Holy", "Retribution"},
    WARRIOR = {"All", "Arms", "Fury", "Protection"},
    ROGUE = {"All", "Assassination", "Combat", "Subtlety"},
    DRUID = {"All", "Balance", "Feral Cat", "Feral Bear", "Restoration"},
    HUNTER = {"All", "Beast Mastery", "Marksmanship", "Survival"},
    SHAMAN = {"All", "Elemental", "Enhancement", "Restoration"},
    WARLOCK = {"All", "Affliction", "Demonology", "Destruction"},
}

local function CharacterIdentity()
    local name, token
    if type(UnitClass) == "function" then name, token = UnitClass("player") end
    local faction = type(UnitFactionGroup) == "function" and UnitFactionGroup("player") or nil
    local race
    if type(UnitRace) == "function" then
        local localized, english = UnitRace("player")
        race = english or localized
    end
    return name, token, faction, race
end

function GetGear:GetSpecializationChoices(classToken)
    return self.Specializations[classToken or self.classToken] or {"All"}
end

function GetGear:GetSpecialization()
    local spec = self.db and self.db.specialization or "All"
    local choices = self:GetSpecializationChoices()
    for _, choice in ipairs(choices) do
        if choice == spec then return spec end
    end
    return "All"
end

local function InList(value, list)
    if type(list) ~= "table" then return true end
    for _, candidate in ipairs(list) do if candidate == value then return true end end
    return false
end

local function MatchesProfile(recommendation, classToken, spec, faction, race, previewIgnoreRace)
    -- Optional restrictions for future Alliance/Horde- and race-specific quests.
    if not InList(faction, recommendation.factions) then return false end
    if not previewIgnoreRace and not InList(race, recommendation.races) then return false end
    if spec == "All" then return true end
    if type(recommendation.specs)=="table" then
        return InList(spec,recommendation.specs)
    end
    local focus = recommendation.focus or "All"
    if focus == "All" or focus == spec then return true end
    -- Old Priest records used the umbrella label Healing for both specs.
    if classToken == "PRIEST" and focus == "Healing" then
        return spec == "Holy" or spec == "Discipline"
    end
    return false
end

function GetGear:SelectCurrentGuide()
    local className, classToken, faction, race = CharacterIdentity()
    self.className, self.classToken, self.faction, self.race = className, classToken, faction, race
    local guide = self.GuideDefinitions[classToken]
    local recommendations = self.Recommendations[classToken]
    local spec = self:GetSpecialization()
    local active = {}

    if guide and recommendations and (not guide.faction or guide.faction == faction) then
        for _, recommendation in ipairs(recommendations) do
            if MatchesProfile(recommendation, classToken, spec, faction, race) then
                local facts = self.ItemCatalog[recommendation.itemID]
                if facts then
                    local entry = {}
                    for key,value in pairs(recommendation) do entry[key]=value end
                    setmetatable(entry, {__index=facts})
                    active[#active+1]=entry
                end
            end
        end
    end
    self.Gear = active
    return #active
end

-- Preview creates independent, unsaved recommendation records without ever
-- changing the live character's self.Gear, class, level or SavedVariables.
-- No race selector in v0.11.1: show race-specific gear with explicit caveats
-- in the detailed view rather than silently hiding it on other-class previews.
function GetGear:GetPreviewRecommendations(classToken, spec)
    local guide = self.GuideDefinitions and self.GuideDefinitions[classToken]
    local recommendations = self.Recommendations and self.Recommendations[classToken]
    if not guide or not recommendations then return {} end
    local validSpec = false
    for _, choice in ipairs(self:GetSpecializationChoices(classToken)) do
        if choice == spec then validSpec = true; break end
    end
    if not validSpec then spec = "All" end
    local result = {}
    local previewFaction = "Alliance" -- all v0.11.0 guides are Alliance-only
    if guide.faction and guide.faction ~= previewFaction then return result end
    for _, recommendation in ipairs(recommendations) do
        if MatchesProfile(recommendation, classToken, spec, previewFaction, nil, true) then
            local facts = self.ItemCatalog[recommendation.itemID]
            if facts then
                local entry = {}
                for key, value in pairs(recommendation) do entry[key] = value end
                setmetatable(entry, {__index=facts})
                result[#result+1] = entry
            end
        end
    end
    return result
end

function GetGear:SetSpecialization(value)
    if not self.db or type(value) ~= "string" then return false end
    local choices = self:GetSpecializationChoices()
    local chosen
    for _, choice in ipairs(choices) do
        if choice:lower() == value:lower() then chosen = choice; break end
    end
    if not chosen then return false end
    self.db.specialization = chosen
    self:SelectCurrentGuide()
    if self.RefreshAll then self:RefreshAll() end
    return true
end

function GetGear:NextSpecialization()
    local choices = self:GetSpecializationChoices()
    local current = self:GetSpecialization()
    for i, choice in ipairs(choices) do
        if choice == current then
            return self:SetSpecialization(choices[(i % #choices) + 1])
        end
    end
    return self:SetSpecialization("All")
end

function GetGear:GetGuideEmptyMessage()
    if not self.classToken then return "Waiting for character information..." end
    local definition = self.GuideDefinitions[self.classToken]
    if definition and definition.faction and self.faction ~= definition.faction then
        return (self.className or self.classToken) .. " guide is currently " .. definition.faction .. "-only; other faction routes require verification."
    end
    if not self.GuideDefinitions[self.classToken] then
        return (self.className or self.classToken) .. " gear guide is not researched yet. Priest data will not be shown."
    end
    return "No recommendations for this profile and level. Try All specs or other tabs."
end

function GetGear:GetCatalogSize()
    local count = 0
    for _ in pairs(self.ItemCatalog) do count=count+1 end
    return count
end
