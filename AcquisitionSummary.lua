local addonName, GetGear = ...
-- Compact, human-readable acquisition hints. This module does not invent
-- boss identities or upgrade rankings. Specific reviewed facts take precedence.
-- A confidence caveat is retained wherever the underlying route is unverified.

function GetGear:GetAcquisitionSummary(gear)
    if not gear or gear.bagUpgrade then return nil end
    if self.GetRecipeAcquisitionKind and self:GetRecipeAcquisitionKind(gear)=="broad-book-drop" then
        return "Recipe: broad/random-drop examples, not farm directions. See Guide for other routes; trade/Auction House if tradeable (listings unknown)."
    end
    if type(gear.sourceSummary)=="string" and gear.sourceSummary~="" then
        return "Source: "..gear.sourceSummary
    end
    if gear.profession then
        local learning=gear.recipeLearnMethod
        if gear.recipeAcquisitionKind=="Drop" then
            return "Recipe: dropped plans/pattern (live source unverified)"
        end
        if learning=="pattern" then
            if type(gear.recipeVendor)=="string" and gear.recipeVendor~="" then
                return "Recipe: vendor - "..gear.recipeVendor
            end
            return "Recipe: plans/pattern (acquisition unverified)"
        end
        -- Trainer recipes are already identified beside MATERIALS.
        return nil
    end
    local category=tostring(gear.sourceType or ""):lower()
    local kind=tostring(gear.acquisitionKind or ""):lower()
    if category:find("dungeon",1,true) or kind:find("dungeon",1,true) then
        local zone=gear.zone
        if type(zone)~="string" or zone=="" or zone=="Source not yet confirmed" then
            return "Source: dungeon loot (location unverified)"
        end
        local source=tostring(gear.source or "")
        local enemy=source:match("^Boss:%s*(.-)%s*%(")
            or source:match("^Dungeon enemy:%s*(.-)%s*%(")
        if enemy and enemy~="" then
            -- Source imports use a generic boss field that sometimes refers
            -- to regular trash enemies; do not assert boss status here.
            return "Source: "..zone.." | Enemy: "..enemy.." (route unverified)"
        end
        return "Source: "..zone.." | dungeon loot (route unverified)"
    end
    return nil
end
