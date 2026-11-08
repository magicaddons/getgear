local addonName, GetGear = ...

-- One set of visibility rules for all catalogue items, regardless of origin.
-- These are relevance/availability heuristics, NOT best-in-slot rankings.
-- "Show all valid equipment" lifts conservative presentation filters but
-- never allows QA/internal placeholder records.

local NOVELTY = {[21524]=true,[21525]=true}
local NO_SPELL = {WARRIOR=true,ROGUE=true,HUNTER=true}
local NO_MANA = {WARRIOR=true,ROGUE=true}
local CLOTH_CASTER = {PRIEST=true,MAGE=true,WARLOCK=true}
-- Default guide prioritises each class's intended body armour, NOT every
-- armour type that the client permits it to equip. Ring, cloak, trinket and
-- weapon slots are outside this preference rule. "Show all valid equipment"
-- still exposes all proficiency-eligible, non-QA choices.
local BODY_ARMOR = {Cloth=true,Leather=true,Mail=true,Plate=true}
local CLOTH_CLASSES = {PRIEST=true,MAGE=true,WARLOCK=true}
local LEATHER_CLASSES = {ROGUE=true,DRUID=true}
local MAIL_TO_PLATE = {WARRIOR=true,PALADIN=true}
local LEATHER_TO_MAIL = {HUNTER=true,SHAMAN=true}
local EXEMPT_BODY_SLOTS = {Back=true,Shirt=true,Tabard=true}
-- Add only verified item-specific exceptions here, never loose role exceptions.
local ARMOR_EXCEPTIONS = {}
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
    -- Preview spans all levels independently of the current character:
    -- reference each item's own target level so level-1 mail and level-40
    -- plate can coexist in the same 1-60 class preview. Upcoming equipment
    -- similarly uses its future target, not the player's present armour skill.
    local armorLevel=(mode=="preview" or mode=="upcoming")
        and (gear.targetLevel or gear.availableLevel)
        or self.level or gear.targetLevel or gear.availableLevel
    local preferred
    if CLOTH_CLASSES[classToken] then
        preferred="Cloth"
    elseif LEATHER_CLASSES[classToken] then
        preferred="Leather"
    elseif MAIL_TO_PLATE[classToken] then
        preferred=(armorLevel and armorLevel>=40) and "Plate" or "Mail"
    elseif LEATHER_TO_MAIL[classToken] then
        preferred=(armorLevel and armorLevel>=40) and "Mail" or "Leather"
    end
    if preferred and BODY_ARMOR[armor] and not EXEMPT_BODY_SLOTS[gear.slot]
        and armor~=preferred and not (ARMOR_EXCEPTIONS[classToken]
            and ARMOR_EXCEPTIONS[classToken][gear.itemID]) then
        return false
    end
    -- Explicit nonexclusive spell-power is a stronger signal than a broad
    -- "mixed" role (which can also be Strength + Spirit). A warrior, rogue
    -- or hunter normally gains nothing from passive spell damage. Preserve
    -- real hybrids for Paladin, Shaman and Druid.
    if NO_SPELL[classToken] and type(gear.statFlags)=="table"
        and gear.statFlags.spellPower==true then return false end
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
