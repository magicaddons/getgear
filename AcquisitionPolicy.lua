local _, GetGear = ...
-- Source policy projections are built once at addon load. No network or polling.
local model=GetGear.AcquisitionNavigationData
local commerce=GetGear.CommercePolicyData or {sources={},offers={}}
local research=GetGear.ResearchPolicyData or {routes={},items={}}
local routeDisposition={}
for id,correction in pairs(research.questNameCorrections or {}) do
    local quest=model.quests[id]
    if quest and quest.name==correction.previous then quest.previousPublishedName=quest.name;quest.name=correction.value end
end
-- An unverified NPC alias must not duplicate a positively documented object in
-- the same quest role. Keep the original actor lists and source records for audit.
for _,quest in pairs(model.quests) do
    for _,field in ipairs({'starts','ends','objectives'}) do
        local original=quest[field] or {};local present={}
        for _,key in ipairs(original) do present[key]=true end
        local result,changed={},false
        for _,key in ipairs(original) do
            local alias=(research.sourceActorAliases or {})[key]
            if alias and present[alias.canonical] then changed=true else result[#result+1]=key end
        end
        if changed then
            quest.previousSourceActors=quest.previousSourceActors or {};quest.previousSourceActors[field]=original;quest[field]=result
        end
    end
end
for id,record in pairs(research.itemCorrections or {}) do
    local gear=GetGear.ItemCatalog[tonumber(id)]
    if gear then
        for field,change in pairs(record.fields) do
            if gear[field]==change.previous then
                if field=='name' then gear.previousPublishedName=gear.name end
                if field=='availableLevel' then gear.previousPublishedLevel=gear.availableLevel end
                gear[field]=change.value
            end
        end
    end
end
-- Class objectives were built earlier in TOC order. Raise their copied target
-- levels as well as the inherited item fact, preserving armour/practical gates.
for _,list in pairs(GetGear.EquipmentByClass or {}) do
    local changed=false
    for _,gear in ipairs(list) do
        local correction=(research.itemCorrections or {})[tostring(gear.itemID)]
        local level=correction and correction.fields.availableLevel
        if level then
            gear.targetLevel=math.max(gear.targetLevel,level.value);changed=true
        end
    end
    if changed then table.sort(list,function(a,b)if a.targetLevel~=b.targetLevel then return a.targetLevel<b.targetLevel end return a.itemID<b.itemID end) end
end
for id,states in pairs(research.routes) do
    local plan=model.items[id] or model.items[tostring(id)]
    for index,state in pairs(states) do
        local route=plan and plan.routes[tonumber(index)]
        if route then routeDisposition[route]=state end
    end
end

function GetGear:GetAcquisitionResearchDecision(gear,route)
    if routeDisposition[route]=='withheld-unapproved-evidence' then
        return false,'Historical acquisition evidence is outside the approved source policy'
    end
    return true
end

function GetGear:GetUnverifiedAcquisitionDescription(gear)
    local state=gear and research.items[tostring(gear.itemID)]
    if not state then return end
    local plan=gear.acquisitionPlan or model.items[tostring(gear.itemID)]
    if plan and #(plan.routes or {})>0 then return end
    if self:GetIndependentAcquisitionAccess(gear)=='learned' then return 'Recipe already learned; use the crafting requirements and materials.' end
    return gear.profession and 'Recipe: Alliance learning source remains unverified; historical evidence retained for audit.'
        or 'Acquisition source remains unverified under the approved research policy.'
end
local function side(context)
    local faction=context and context.faction or not context and type(UnitFactionGroup)=="function" and UnitFactionGroup("player")
    return faction=="Alliance" and 1 or faction=="Horde" and 2
end
local function currency(route,id)
    local cost=route.offer and route.offer.cost
    if type(cost)=='table' then
        local options=type(cost[1])=='table' and cost or {cost}
        for _,price in ipairs(options) do
            for _,entry in ipairs(type(price[2])=='table' and price[2] or {}) do
                if entry[1]==id then return true end
            end
        end
    end
    local published=(model.currencies or {})[tostring(id)] or (model.currencies or {})[id]
    return route.currencyID==id or published and route.currency==published.name
end
local SERVICE={vendor=true,recipe_vendor=true,trainer=true,vendor_container=true}
function GetGear:AcquisitionRouteUsesCurrency(route,id) return currency(route,id) end
local routeProjections={}
local verifiedCommerceBooks={}
function GetGear:HasVerifiedCommerceBook(gear,book)
    local books=gear and verifiedCommerceBooks[gear.itemID]
    return books and books[tostring(book or gear.recipePatternItemID)]==true or false
end
local function vendorName(route)
    local location=route.location or {}
    return location.npcName or (model.npcLabels or {})[(location.zone or '')..'|'..(route.label or location.spot or '')]
end
local function indexRouteProjections()
for id,plan in pairs(model.items) do
    local gear=GetGear.ItemCatalog[tonumber(id)]
    for _,route in ipairs(plan.routes or {}) do
        if not route.source and gear and gear.profession and (route.kind=='recipe_vendor' or route.kind=='vendor') then
            local book=route.bookItemID or gear.recipePatternItemID
            local offer=book and commerce.offers[tostring(book)]
            local name=vendorName(route)
            local actor=offer and commerce.sources[offer.source]
            if actor and name==actor.name and route.location and route.location.zone==actor.locations[1].zone then
                local copy={};for key,value in pairs(route) do copy[key]=value end
                copy.source=offer.source;copy.location=nil;copy.label=actor.name;copy.instructions=nil
                copy.bookItemID=book
                copy.verification='published-reference';copy.evidence={commerce.evidence,offer.bookEvidence,actor.npcEvidence}
                routeProjections[route]=copy
            end
        end
    end
end
end
function GetGear:ProjectAcquisitionRoute(gear,route) return routeProjections[route] or route end
-- Published individual vendor points supersede older beta coordinates. Frozen
-- source files and their historical evidence are preserved for the audit.
for key,record in pairs(commerce.sources) do
    local actor=model.sources[key]
    if actor then
        actor.previousCommerceLocations=actor.locations
        actor.locations=record.locations
    end
end
-- Add a learning alternative only when the current book explicitly teaches the
-- recorded spell AND names this exact output. A shared book never grants Horde
-- service. No vendor is inferred from a camp coordinate or a profession name.
for book,offer in pairs(commerce.offers) do
    for _,id in ipairs(offer.outputItemIDs or {}) do
        local gear=GetGear.ItemCatalog[id]
        local spellMatched=false
        for _,spell in ipairs(offer.taughtSpellIDs or {}) do if gear and spell==gear.recipeSpellID then spellMatched=true end end
        if gear and spellMatched and gear.profession==offer.profession then
            verifiedCommerceBooks[id]=verifiedCommerceBooks[id] or {};verifiedCommerceBooks[id][book]=true
        end
        if gear and (not gear.recipePatternItemID or gear.recipePatternItemID==tonumber(book)) and spellMatched and gear.profession==offer.profession then
            if not gear.recipePatternItemID then gear.recipePatternItemID=tonumber(book);gear.recipeBookEvidence=offer.bookEvidence end
            if not model.sources[offer.source] then
                local documented=commerce.sources[offer.source]
                model.sources[offer.source]={name=documented.name,kind='npc',locations=documented.locations,
                    serviceSide=1,evidence={commerce.evidence,documented.npcEvidence}}
            end
            local plan=model.items[tostring(id)] or {itemID=id,category='crafting',routes={}}
            model.items[tostring(id)]=plan
            local found=false
            for _,route in ipairs(plan.routes) do
                if route.source==offer.source and route.bookItemID==tonumber(book) then found=true end
                if not route.source and (route.kind=='recipe_vendor' or route.kind=='vendor') and vendorName(route)==commerce.sources[offer.source].name
                    and route.location and route.location.zone==commerce.sources[offer.source].locations[1].zone then found=true end
            end
            if not found then
                plan.routes[#plan.routes+1]={kind='recipe_vendor',source=offer.source,bookItemID=tonumber(book),recipe=true,
                    verification='published-reference',offer={cost={0,{{3402,offer.cost}},{}}},
                    evidence={commerce.evidence,offer.bookEvidence}}
            end
        end
    end
end
indexRouteProjections()
for key,indices in pairs(research.sourceLocationHolds or {}) do
    local actor=model.sources[key]
    if actor then
        actor.previousResearchLocations={}
        for index,loc in ipairs(actor.locations or {}) do actor.previousResearchLocations[index]=loc end
    end
    for _,index in ipairs(indices) do
        local old=actor and actor.locations[index]
        if old then
            local copy={};for k,v in pairs(old) do copy[k]=v end
            copy.x=nil;copy.y=nil;copy.bounds=nil;copy.originalBounds=nil
            copy.locationClass='unknown';copy.locationKind='unknown'
            copy.instructions='Location precision is unverified or conflicting under the approved research policy; zone reference only, no precise pin.'
            actor.locations[index]=copy
        end
    end
end
for name,indices in pairs(research.entranceHolds or {}) do
    local definition=model.instanceEntrances[name]
    if definition then
        local held={};for _,index in ipairs(indices) do held[index]=true end
        local retained={}
        for index,entrance in ipairs(definition.entrances or {}) do if not held[index] then retained[#retained+1]=entrance end end
        definition.previousResearchEntrances=definition.entrances;definition.entrances=retained
    end
end

function GetGear:GetAcquisitionServiceDecision(gear,route,context)
    route=self:ProjectAcquisitionRoute(gear,route)
    local playerSide=side(context)
    if playerSide~=1 then return true end
    if not SERVICE[route.kind] and not currency(route,3402) then return true end
    local actor=model.sources[route.source] or {}
    local reviewed=commerce.sources[route.source] or (commerce.opposingSources or {})[route.source]
    -- A conflict never grants service, including an Alliance-labelled offer on
    -- a conclusively Horde-only actor. Missing metadata never implies neutral.
    if route.serviceSide==2 or route.offer and route.offer.side==2 or actor.serviceSide==2
        or reviewed and reviewed.serviceSide==2 then return false,"Horde-exclusive or contradictory service affiliation" end
    if currency(route,3402) then
        local book=route.bookItemID or gear and gear.recipePatternItemID
        local offer=book and commerce.offers[tostring(book)]
        if not reviewed or reviewed.serviceSide~=1 or not offer or offer.source~=route.source or not self:HasVerifiedCommerceBook(gear,book) then
            return false,"Alliance commerce learning source remains unverified"
        end
        return true
    end
    return true
end

function GetGear:GetAcquisitionPolicyLocations(actor,key)
    return commerce.sources[key] and commerce.sources[key].locations or actor.locations or {}
end

function GetGear:GetCommerceLearningRequirements(gear)
    if side()~=1 or not gear then return end
    local offer=commerce.offers[tostring(gear.recipePatternItemID)]
    if not offer then return end
    local requirements={}
    if offer.reputation~='unverified-per-book' then requirements[#requirements+1]='Learn: Requires '..offer.reputation..' with Azeroth Commerce Authority' end
    if offer.learningSkillDisputed then
        requirements[#requirements+1]='Learning skill disputed: guide '..offer.learningSkill..', book '..offer.bookLearningSkill
    end
    return requirements
end

GetGear.AcquisitionPracticalityPolicy={
    supportedSides={[1]=true},
    ordinaryTerritories={['The Barrens']=2,Durotar=2,Mulgore=2,['Tirisfal Glades']=2,['Silverpine Forest']=2},
}
local ORDINARY={named_drop=true,npc_container=true,object=true,vendor=true,vendor_container=true,recipe_drop=true,recipe_vendor=true,trainer=true,legacy=true}
function GetGear:GetTerritoryAcquisitionPracticality(gear,route,context,target)
    local playerSide=side(context)
    local policy=self.AcquisitionPracticalityPolicy
    if not policy.supportedSides[playerSide] then return end
    -- Shared quest chains and dungeon entrances are deliberate exceptions.
    if route.kind=='dungeon' or route.kind=='quest' or route.kind=='quest_container' then return end
    if not ORDINARY[route.kind] then return end
    local actor=model.sources[route.source] or {}
    local locations=target and {target} or route.location and {route.location} or self:GetAcquisitionPolicyLocations(actor,route.source)
    if #locations==0 and route.sourceZone then locations={{zone=route.sourceZone}} end
    if #locations==0 then return end
    local allOpposing=true
    for _,loc in ipairs(locations) do
        local owner=policy.ordinaryTerritories[loc.zone]
        local shared=loc.neutral==true or loc.settlement=='Ratchet'
            or (model.instances or {})[loc.zone] or loc.kind=='dungeon'
        -- A seller's explicit shared service is a verified exception to this
        -- geography preference; missing service metadata is never neutral proof.
        local service=self:GetAcquisitionRouteFactionSide(gear,route)
        if service==3 and (route.kind=='vendor' or route.kind=='recipe_vendor' or route.kind=='vendor_container') then shared=true end
        if not owner or owner==playerSide or shared then allOpposing=false end
    end
    if allOpposing then return 'restricted-territory' end
end
