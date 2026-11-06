local addonName, GetGear = ...

-- Optional, per-character display filter. Recommendations are intentionally
-- profession-agnostic unless the player explicitly enables this setting.
-- A dungeon/quest/vendor item stays visible even if it also has a crafting
-- route: the player can still obtain the finished item without crafting it.
local CRAFT_PROFESSIONS = {
    Tailoring=true,
    Leatherworking=true,
    Blacksmithing=true,
    Engineering=true,
    Enchanting=true,
}

local function CraftingProfession(gear)
    if not gear or gear.bagUpgrade then return nil end
    if CRAFT_PROFESSIONS[gear.profession] then return gear.profession end
    if CRAFT_PROFESSIONS[gear.sourceType] then return gear.sourceType end
    return nil
end

function GetGear:ShouldDisplayCraftedGear(gear)
    local opts = self.db and self.db.overlay
    if not opts or opts.hideUncraftableCrafts ~= true then return true end

    local profession = CraftingProfession(gear)
    if not profession then return true end

    -- An unavailable professions API is an unknown state, not proof that
    -- the player lacks the profession. Fail open until the client is ready.
    if type(GetProfessions) ~= "function"
        or type(GetProfessionInfo) ~= "function"
        or type(self.GetProfessionSkill) ~= "function" then
        return true
    end
    local skill = self:GetProfessionSkill(profession)
    if type(skill) ~= "number" then return false end

    -- These values are recipe *learning* minima. Use only confirmed values:
    -- do not confuse yellow/green/grey skill-ups with actual requirements.
    local needed = gear.professionSkillRequired
    if type(needed) == "number"
        and gear.recipeLearnSkillEvidence ~= "unverified"
        and gear.recipeLearnSkillProvisional ~= true
        and skill < needed then
        return false
    end

    local learned = self.GetRecipeKnowledge and self:GetRecipeKnowledge(gear)
    if learned == true then return true end

    -- Pattern-only crafts need the separately learned pattern. An unscanned
    -- recipe is unknown rather than known, so a strict opt-in filter hides it
    -- until the profession window supplies positive evidence.
    if gear.recipeLearnMethod == "pattern"
        or gear.professionLearnSource == "Pattern" then
        return false
    end

    -- For trainer/initial recipes, the current client only confirms positives,
    -- not negatives, when the crafting window has not been scanned. Keep
    -- these provisionally visible rather than mislabeling unknown as missing.
    return true
end
