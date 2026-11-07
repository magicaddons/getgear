local addonName, GetGear = ...

-- A single, class-wide equipment index. Source-specific research belongs in
-- ResearchedItemFacts.lua and EquipmentCache.lua; no editorial class/spec
-- recommendations are executed at runtime.
local CLASSES={"PRIEST","MAGE","WARLOCK","DRUID","ROGUE","HUNTER","SHAMAN","WARRIOR","PALADIN"}
local BITS={}
for i,class in ipairs(CLASSES) do BITS[class]=2^(i-1) end
GetGear.GuideDefinitions={}
GetGear.EquipmentByClass={}
for _,class in ipairs(CLASSES) do
    GetGear.GuideDefinitions[class]={faction="Alliance",label=class}
    GetGear.EquipmentByClass[class]={}
end

local allObjectives=0
for itemID,eligibility in pairs(GetGear.EquipmentEligibility or {}) do
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
