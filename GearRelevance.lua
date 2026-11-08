local addonName, GetGear = ...

-- One set of visibility rules for all catalogue items, regardless of origin.
-- These are relevance/availability heuristics, NOT best-in-slot rankings.
-- "Show all valid equipment" lifts conservative presentation filters but
-- never allows QA/internal placeholder records.

local NOVELTY = {[21524]=true,[21525]=true}
local NO_SPELL = {WARRIOR=true,ROGUE=true,HUNTER=true}
local NO_MANA = {WARRIOR=true,ROGUE=true}
local CLOTH_CASTER = {PRIEST=true,MAGE=true,WARLOCK=true}
local CLOTH_NONSTANDARD = {WARRIOR=true,ROGUE=true,HUNTER=true}
local HYBRID_HEALER = {DRUID=true,SHAMAN=true,PALADIN=true}
local LOOKBACK = 5

function GetGear:IsHardExcludedGear(gear)
    if not gear then return false end
    local id=gear.itemID
    if id==24358 or (type(id)=="number" and id>=281685 and id<=281729) then
        return true
    end
    local name=type(gear.name)=="string" and gear.name:lower() or ""
    return name:match("^qatest[%s%p]")~=nil
        or name:match("^qa%s+test[%s%p]")~=nil
        or name:match("^gm%s+test[%s%p]")~=nil
end

-- This applies equally to pre-2026 researched and bulk-generated items.
-- targetLevel reflects the better of equip-level and known practical access,
-- so later quest-chain rewards do not expire before they can be obtained.
function GetGear:IsOlderGear(gear,characterLevel)
    if not gear or gear.bagUpgrade then return false end
    local opts=self.db and self.db.overlay
    if opts and opts.showAllValidGear==true then return false end
    local target=gear.targetLevel or gear.availableLevel
    local current=characterLevel or self.level
    return type(target)=="number" and type(current)=="number"
        and target<=current-LOOKBACK
end

function GetGear:ShouldDisplayGear(gear,classToken,mode)
    if not gear or gear.bagUpgrade then return true end
    if self:IsHardExcludedGear(gear) then return false end
    if mode=="completed" or mode=="hidden" then return true end
    local opts=self.db and self.db.overlay
    if opts and opts.showAllValidGear==true then return true end
    -- Full preview and explicitly All-materials are browsing scopes; neither
    -- is restricted by the player character's current level.
    if mode~="earlier" and mode~="preview" and mode~="materials-all"
        and self:IsOlderGear(gear) then return false end
    if NOVELTY[gear.itemID] then return false end
    -- Source uncertainty is not an equipment/proficiency veto. Unknown
    -- world-drop or acquisition routes remain visible with their existing
    -- unverified-source labels; users choose whether to pursue them.
    -- This keeps the default catalogue class-wide rather than turning
    -- research coverage into a silent recommendation whitelist.

    classToken=classToken or self.classToken
    if not classToken then return true end
    local armor=gear.armorType
    local role=gear.statRole

    if armor=="Cloth" then
        if CLOTH_NONSTANDARD[classToken] then return false end
        if HYBRID_HEALER[classToken] and role~="spell"
            and role~="mana" and role~="mixed" then return false end
    elseif armor=="Leather" then
        if classToken=="WARRIOR" and role~="physical"
            and role~="mixed" then return false end
        if classToken=="PALADIN" and role~="physical"
            and role~="spell" and role~="mana" and role~="mixed" then
            return false
        end
    end
    if role=="spell" and NO_SPELL[classToken] then return false end
    if role=="mana" and NO_MANA[classToken] then return false end
    if role=="physical" and CLOTH_CASTER[classToken] then return false end

    -- Optional read-only talent awareness only vetoes an EXCLUSIVE school
    -- modifier, never items with generic spellpower, Intellect, healing,
    -- defensive stats, resistances or hybrid utility.
    if classToken=="MAGE" and mode~="preview"
        and type(gear.schoolOnly)=="string"
        and self.GetDominantTalentTree then
        local active=self:GetDominantTalentTree()
        if active and active~=gear.schoolOnly then return false end
    end
    return true
end
