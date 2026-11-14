local addonName, GetGear = ...

-- A single, class-wide equipment index. Source-specific research belongs in
-- ResearchedItemFacts.lua and EquipmentCache.lua; no editorial class/spec
-- recommendations are executed at runtime.
local CLASSES={"PRIEST","MAGE","WARLOCK","DRUID","ROGUE","HUNTER","SHAMAN","WARRIOR","PALADIN"}
local BITS={}
for i,class in ipairs(CLASSES) do BITS[class]=2^(i-1) end
-- Potential class proficiencies, never the individual player's trained skills.
-- Keep one-/two-handed and offhand weapon permissions distinct. Raw imported
-- masks remain available as source evidence; the effective mask intersects
-- those restrictions with these structural permissions before any relevance.
local function classes(names)
    local out={};for name in names:gmatch('%S+') do out[name]=true end;return out
end
local TWO_HAND={
    Mace=classes('WARRIOR PALADIN DRUID SHAMAN'),
    Axe=classes('WARRIOR PALADIN HUNTER SHAMAN'),
    Sword=classes('WARRIOR PALADIN HUNTER'),
    Staff=classes('WARRIOR HUNTER SHAMAN DRUID PRIEST MAGE WARLOCK'),
    Polearm=classes('WARRIOR PALADIN HUNTER DRUID'),
}
local WEAPONS={
    Sword=classes('WARRIOR PALADIN ROGUE HUNTER MAGE WARLOCK'),
    Axe=classes('WARRIOR PALADIN ROGUE HUNTER SHAMAN'),
    Mace=classes('WARRIOR PALADIN ROGUE SHAMAN PRIEST DRUID'),
    Dagger=classes('WARRIOR ROGUE HUNTER PRIEST SHAMAN DRUID MAGE WARLOCK'),
    ['Fist Weapon']=classes('WARRIOR ROGUE HUNTER DRUID SHAMAN'),
    Bow=classes('WARRIOR ROGUE HUNTER'),Gun=classes('WARRIOR ROGUE HUNTER'),
    Crossbow=classes('WARRIOR ROGUE HUNTER'),Thrown=classes('WARRIOR ROGUE HUNTER'),
    Wand=classes('PRIEST MAGE WARLOCK'),
}
local DUAL_WIELD=classes('WARRIOR ROGUE HUNTER SHAMAN')
local ARMOR={Cloth=classes('PRIEST MAGE WARLOCK DRUID ROGUE HUNTER SHAMAN WARRIOR PALADIN'),
    Leather=classes('DRUID ROGUE HUNTER SHAMAN WARRIOR PALADIN'),
    Mail=classes('HUNTER SHAMAN WARRIOR PALADIN'),Plate=classes('WARRIOR PALADIN'),
    Shield=classes('WARRIOR PALADIN SHAMAN'),Idol=classes('DRUID'),Libram=classes('PALADIN'),Totem=classes('SHAMAN')}
function GetGear:CanClassEquipGear(gear,class)
    if not gear or gear.bagUpgrade or not BITS[class] then return true end
    local e=self.EquipmentEligibility and self.EquipmentEligibility[gear.itemID]
    if e and math.floor(e[1]/BITS[class])%2~=1 then return false end
    local subtype=gear.armorType or e and e[3]
    local slot=gear.slot or ''
    local allowed
    if slot:find('^Two%-Hand') then
        local kind=slot:match('^Two%-Hand (.+)$') or subtype
        allowed=TWO_HAND[kind]
    elseif WEAPONS[subtype] then
        allowed=WEAPONS[subtype]
        if slot=='Off Hand' and not DUAL_WIELD[class] then return false end
    elseif subtype~='Held In Off-hand' then allowed=ARMOR[subtype] end
    return not allowed or allowed[class]==true -- unfamiliar evidence stays open
end
GetGear.EffectiveEquipmentEligibility={}
GetGear.EquipmentEligibilityCorrections={}
for id,e in pairs(GetGear.EquipmentEligibility or {}) do
    local item=GetGear.ItemCatalog[id];local mask=0
    for _,class in ipairs(CLASSES) do
        if GetGear:CanClassEquipGear(item,class) then mask=mask+BITS[class] end
    end
    GetGear.EffectiveEquipmentEligibility[id]={mask,e[2],e[3]}
    if mask~=e[1] then GetGear.EquipmentEligibilityCorrections[id]={originalMask=e[1],effectiveMask=mask} end
end
GetGear.GuideDefinitions={}
GetGear.EquipmentByClass={}
for _,class in ipairs(CLASSES) do
    GetGear.GuideDefinitions[class]={faction="Alliance",label=class}
    GetGear.EquipmentByClass[class]={}
end

local allObjectives=0
for itemID,eligibility in pairs(GetGear.EffectiveEquipmentEligibility) do
    local facts=GetGear.ItemCatalog[itemID]
    assert(facts,"Eligibility refers to missing catalogue item "..itemID)
    local mask,rawLevel,armor=eligibility[1],eligibility[2],eligibility[3]
    assert(type(mask)=="number" and mask>0,"Missing class proficiency mask "..itemID)
    assert(type(rawLevel)=="number","Missing equip requirement "..itemID)
    for _,class in ipairs(CLASSES) do
        if math.floor(mask/BITS[class])%2==1 then
            local target=math.max(rawLevel,tonumber(facts.availableLevel) or 1)
            -- Classic/Forever mail and plate proficiency gates are separate
            -- from a low equip-level printed on an item's tooltip.
            if (armor=="Mail" and (class=="HUNTER" or class=="SHAMAN"))
                or armor=="Plate" then target=math.max(target,40) end
            if type(facts.earliestPracticalLevel)=="number" then
                target=math.max(target,facts.earliestPracticalLevel)
            end
            if target<=60 then
                local record={itemID=itemID,id="item_"..itemID,
                    targetLevel=target,slot=facts.slot}
                setmetatable(record,{__index=facts})
                local list=GetGear.EquipmentByClass[class]
                list[#list+1]=record
                allObjectives=allObjectives+1
            end
        end
    end
end
for _,list in pairs(GetGear.EquipmentByClass) do
    table.sort(list,function(a,b)
        if a.targetLevel~=b.targetLevel then return a.targetLevel<b.targetLevel end
        return a.itemID<b.itemID
    end)
end
GetGear.CatalogueAudit=GetGear.CatalogueAudit or {}
GetGear.CatalogueAudit.objectives=allObjectives

local function CharacterIdentity()
    local name,token
    if type(UnitClass)=="function" then name,token=UnitClass("player") end
    local faction=type(UnitFactionGroup)=="function" and UnitFactionGroup("player") or nil
    local race
    if type(UnitRace)=="function" then
        local localized,english=UnitRace("player")
        race=english or localized
    end
    return name,token,faction,race
end

function GetGear:SelectCurrentGuide()
    local name,token,faction,race=CharacterIdentity()
    self.className,self.classToken,self.faction,self.race=name,token,faction,race
    self.Gear=(faction=="Alliance" and self.EquipmentByClass[token]) or {}
    return #self.Gear
end

-- Read-only class preview. No manual spec tabs or progress mutations.
-- The preview UI alone chooses the browsing level and full-range mode.
function GetGear:GetPreviewRecommendations(classToken)
    return self.EquipmentByClass[classToken] or {}
end

function GetGear:GetGuideEmptyMessage()
    if not self.classToken then return "Waiting for character information..." end
    if self.faction~="Alliance" then
        return "GetGear currently has Alliance acquisition routes; Horde routes need separate verification."
    end
    if not self.EquipmentByClass[self.classToken] then
        return "No researched equipment available for this class."
    end
    return "No class-eligible equipment in this category; check Earlier Gear, Hidden or another level."
end

function GetGear:GetCatalogSize()
    return (self.CatalogueAudit and self.CatalogueAudit.items) or 0
end
