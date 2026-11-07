local addonName, GetGear = ...

-- v0.13.0-beta2: display-only, conservative suitability rules for the broad
-- October 2026 Forever beta item cache. Do not rewrite acquired/hidden IDs.
-- Hand-reviewed GetGear recommendations always retain their prior visibility.
-- Source-verified equippability is distinct from suitability for the default
-- leveling view. 'Show all valid equipment' lifts suitability/novelty filters
-- but NEVER lifts explicit QA or placeholder exclusions.

local EXCLUDED_IDS = {
    [24358]=true, -- QATest +1000 Spell Dmg Ring: internal test item
}
local NOVELTY_IDS = {
    [21524]=true, -- Red Winter Hat (Winter Veil costume)
    [21525]=true, -- Green Winter Hat
}
local NO_SPELL_GEAR = {WARRIOR=true, ROGUE=true, HUNTER=true}
local NO_MANA_GEAR = {WARRIOR=true, ROGUE=true}
local CLOTH_CASTER = {PRIEST=true, MAGE=true, WARLOCK=true}
local CLOTH_NONSTANDARD = {WARRIOR=true, ROGUE=true, HUNTER=true}
local HYBRID_CASTER = {PALADIN=true, DRUID=true, SHAMAN=true}

function GetGear:IsHardExcludedGear(gear)
    if not gear then return false end
    local id = gear.itemID
    if EXCLUDED_IDS[id] then return true end
    -- Restored Cloth/Leather/Mail/Plate starter placeholder sets and a few
    -- anonymous 'Restored' jewelry/weapons. Do NOT ban all 'Restored' items:
    -- level-50 Restored PvP sets are separate, legitimate candidates.
    if type(id)=="number" and id>=281685 and id<=281729 then return true end
    local name = type(gear.name)=="string" and gear.name:lower() or ""
    if name:match("^qatest[%s%p]") or name:match("^qa%s+test[%s%p]")
        or name:match("^gm%s+test[%s%p]") then return true end
    return false
end

function GetGear:ShouldDisplayGear(gear, classToken, mode)
    if not gear or gear.bagUpgrade then return true end
    if self:IsHardExcludedGear(gear) then return false end
    -- Preserve history even when its source later becomes classified as
    -- novelty or off-spec; allow unhide/restore without changing saved state.
    if mode=="completed" or mode=="hidden" then return true end
    if not gear.fromGeneratedCache then return true end
    local opts=self.db and self.db.overlay
    if opts and opts.showAllValidGear==true then return true end

    if NOVELTY_IDS[gear.itemID] then return false end
    -- A beta-cache entry with no documented route is a valid client item,
    -- not automatically a reachable leveling objective. Available via
    -- the expanded catalogue until a player-observed route is added.
    if gear.sourceType=="Source not documented" then return false end

    classToken = classToken or self.classToken
    if not classToken then return true end
    local armor=gear.armorType
    if armor=="Cloth" then
        if CLOTH_NONSTANDARD[classToken] then return false end
        -- Hybrid healers may prefer strong cloth spell gear; keep it only
        -- when the source tooltip positively identifies caster benefits.
        if HYBRID_CASTER[classToken] and gear.statRole~="spell"
            and gear.statRole~="mixed" and gear.statRole~="mana" then return false end
    elseif armor=="Leather" then
        -- Low-level physical-stat leather may be a genuine Warrior upgrade.
        -- Paladins can also use caster or melee leather; don't force them
        -- into a single spec or hide an actual hybrid choice.
        if classToken=="WARRIOR"
            and gear.statRole~="physical" and gear.statRole~="mixed" then return false end
        if classToken=="PALADIN"
            and gear.statRole~="physical" and gear.statRole~="spell"
            and gear.statRole~="mixed" and gear.statRole~="mana" then return false end
    end
    -- Do not make a BiS choice. Only suppress clear single-role conflicts;
    -- unknown/mixed/utility/resistance equipment stays visible.
    local role=gear.statRole
    if role=="spell" and NO_SPELL_GEAR[classToken] then return false end
    -- Hunters use mana and benefit from Intellect; unlike Warriors/Rogues,
    -- never hide a Hunter upgrade merely for being Intellect/Spirit gear.
    if role=="mana" and NO_MANA_GEAR[classToken] then return false end
    if role=="physical" and CLOTH_CASTER[classToken] then return false end
    return true
end
