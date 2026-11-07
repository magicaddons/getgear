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
    -- Generated Forever client data sometimes confirms that an item is
    -- crafted without identifying its profession or recipe. In the strict
    -- opt-in mode, UNKNOWN craftability must not become 'craftable'.
    if gear.craftOnly == true then return "__UNKNOWN_CRAFT__" end
    return nil
end

function GetGear:ShouldDisplayCraftedGear(gear)
    local opts = self.db and self.db.overlay
    if not opts or opts.hideUncraftableCrafts ~= true then return true end

    local profession = CraftingProfession(gear)
    if not profession then return true end
    if profession == "__UNKNOWN_CRAFT__" then return false end

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

    -- Opt-in strict mode: only show a craft when the recipe is positively
    -- known. The live API may not expose complete recipe information until
    -- the player opens their profession window. Unknown is NOT craftable.
    -- Existing GetRecipeKnowledge recognises recipe spell IDs and recipe
    -- names observed from the open profession window.
    local learned = self.GetRecipeKnowledge and self:GetRecipeKnowledge(gear)
    return learned == true
end
