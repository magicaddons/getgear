local _, GetGear = ...

-- Territory classifications are referenced in docs/RECOMMENDATION_HANDOVER.md.
-- The cutoff is OUR optional travel policy, never a game access requirement.
-- Contested/neutral zones and dungeons deliberately have no hostile cutoff.
GetGear.LevelingTerritories = {
    ["Durotar"]={side=2,cutoff=20}, ["Mulgore"]={side=2,cutoff=20},
    ["Tirisfal Glades"]={side=2,cutoff=20},
    ["Silverpine Forest"]={side=2,cutoff=30}, ["The Barrens"]={side=2,cutoff=30},
    ["Elwynn Forest"]={side=1,cutoff=20}, ["Dun Morogh"]={side=1,cutoff=20},
    ["Teldrassil"]={side=1,cutoff=20}, ["Westfall"]={side=1,cutoff=30},
    ["Loch Modan"]={side=1,cutoff=30}, ["Darkshore"]={side=1,cutoff=30},
    ["Orgrimmar"]={side=2,cutoff=20}, ["Thunder Bluff"]={side=2,cutoff=20},
    ["Undercity"]={side=2,cutoff=20}, ["Stormwind"]={side=1,cutoff=20},
    ["Stormwind City"]={side=1,cutoff=20}, ["Ironforge"]={side=1,cutoff=20},
    ["Darnassus"]={side=1,cutoff=20},
}
local CLASS_ID={WARRIOR=1,PALADIN=2,HUNTER=3,ROGUE=4,PRIEST=5,SHAMAN=7,MAGE=8,WARLOCK=9,DRUID=11}
local RACE_ID={Human=1,Orc=2,Dwarf=3,NightElf=4,Scourge=5,Undead=5,Tauren=6,Gnome=7,Troll=8}
local function call(fn,...)
    if type(fn)~="function" then return nil end
    local ok,v=pcall(fn,...);if ok then return v end
end
local function lookup(t,key) return t and (t[key] or t[tostring(key)]) end
local function completed(id)
    local value=C_QuestLog and call(C_QuestLog.IsQuestFlaggedCompleted,id)
    if type(value)=="boolean" then return value end
    return call(IsQuestFlaggedCompleted,id)
end
function GetGear:GetAcquisitionNavigationModel()
    local base=self.AcquisitionNavigationData or {items={},sources={},quests={},chains={}}
    local extra=self.BagNavigation
    if not extra then return base end
    if self._bagModelBase~=base or self._bagModelExtra~=extra then
        local model=setmetatable({},{__index=base})
        for _,key in ipairs({"sources","quests","chains"}) do
            model[key]=setmetatable({},{__index=function(_,id)
                return lookup(extra[key],id) or lookup(base[key],id)
            end})
        end
        self._bagModel,self._bagModelBase,self._bagModelExtra=model,base,extra
    end
    return self._bagModel
end

function GetGear:GetItemAcquisitionPlan(gear)
    if not gear then return nil end
    if gear.acquisitionRoutes then return {routes=gear.acquisitionRoutes} end
    local plan=lookup(self.AcquisitionNavigationData and self.AcquisitionNavigationData.items,gear.itemID)
    if plan then return plan end
    local location=gear.acquisitionLocation
    if location then
        return {routes={{kind=gear.sourceType=="Dungeon" and "dungeon" or "legacy",
            dungeon=gear.sourceType=="Dungeon" and gear.zone or nil,location=location,
            label=location.spot,side=gear.sourceFaction,minimumLevel=gear.sourceMinimumLevel}}}
    end
end

function GetGear:IsAcquisitionRouteAllowed(route, model, options)
    options=options or {};model=model or self:GetAcquisitionNavigationModel()
    local faction=call(UnitFactionGroup,"player") or self.faction
    local side=faction=="Alliance" and 1 or faction=="Horde" and 2
    local class=self.classToken
    if not class and type(UnitClass)=="function" then local _,token=UnitClass("player");class=token end
    local q=(route.kind=="quest" or route.kind=="quest_container") and lookup(model.quests,route.questID) or {}
    q=q or {}
    local actor=lookup(model.sources,route.source)
    local requiredSide=route.side or route.serviceSide or route.offer and route.offer.side or q.side or actor and actor.serviceSide
    if side and (requiredSide==1 or requiredSide==2) and side~=requiredSide then return false,"Faction-exclusive source" end
    local mask=route.reqclass or q.reqclass
    if type(mask)=="number" and mask>0 and CLASS_ID[class] and math.floor(mask/2^(CLASS_ID[class]-1))%2~=1 then return false,"Class-exclusive source" end
    if route.races then
        local race=self.race
        if type(UnitRace)=="function" then local _,token=UnitRace("player");race=token or race end
        if race and not route.races[race] then return false,"Race-exclusive source" end
    end
    local raceMask=route.raceMask or q.reqrace
    if type(raceMask)=="number" and raceMask>0 then
        local race=self.race
        if type(UnitRace)=="function" then local _,token=UnitRace("player");race=token or race end
        local id=RACE_ID[race]
        if id and math.floor(raceMask/2^(id-1))%2~=1 then return false,"Race-exclusive source" end
    end
    local level=options.level or self.level or call(UnitLevel,"player") or 1
    local minimum=route.minimumLevel or q.reqlevel
    if not options.browse and type(minimum)=="number" and level<minimum then return false,"Source level requirement" end
    if route.oneTime and completed(route.questID)==true then return false,"Quest already completed" end
    if not options.browse then
        local offer=route.offer or {}
        if offer.reqfaction and type(offer.standing)=="number" and C_Reputation then
            local reputation=call(C_Reputation.GetFactionDataByID,offer.reqfaction)
            if type(reputation)=="table" and type(reputation.reaction)=="number" and reputation.reaction<offer.standing then
                return false,"Vendor reputation requirement"
            end
        end
        for _,id in ipairs(route.prerequisiteQuests or {}) do
            if completed(id)==false then return false,"Complete prerequisite quest #"..id end
        end
    end
    return true
end

function GetGear:IsAcquisitionRoutePractical(route, model)
    local opts=self.db and self.db.overlay
    if opts and opts.hideImpracticalSources==false then return true end
    if route.kind=="dungeon" or route.dungeon or route.travelExempt then return true end
    model=model or self:GetAcquisitionNavigationModel()
    local locations=route.location and {route.location} or route.locations
    local actor=lookup(model.sources,route.source)
    locations=locations or actor and actor.locations
    if not locations or #locations==0 then
        local q=lookup(model.quests,route.questID)
        local start=q and q.starts and q.starts[1]
        local giver=lookup(model.sources,start)
        locations=giver and giver.locations
    end
    if not locations or #locations==0 then return true end -- unknown geography isn't hostile
    local faction=call(UnitFactionGroup,"player") or self.faction
    local side=faction=="Alliance" and 1 or faction=="Horde" and 2
    local level=self.level or call(UnitLevel,"player") or 1
    local map=C_Map and call(C_Map.GetBestMapForUnit,"player")
    local info=map and C_Map and call(C_Map.GetMapInfo,map)
    for _,loc in ipairs(locations) do
        local territory=self.LevelingTerritories[loc.zone]
        if not side or not territory or territory.side==side or level>territory.cutoff
            or type(info)=="table" and info.name==loc.zone then return true end
    end
    return false
end

function GetGear:GetEligibleAcquisitionRoutes(gear, compact, options)
    local plan=self:GetItemAcquisitionPlan(gear)
    -- Legacy geography can inform convenience without replacing a detailed
    -- source description/map plan with an invented generic destination.
    if not plan and gear and self.LevelingTerritories[gear.zone] then
        plan={routes={{kind=gear.sourceType=="Dungeon" and "dungeon" or "legacy",
            location={zone=gear.zone},side=gear.sourceFaction}}}
    end
    if not plan or #(plan.routes or {})==0 then return nil end
    local results={}
    local finishedRoutes=0
    for _,route in ipairs(plan.routes) do
        -- Recipe learning belongs in navigation/craftability. A faction gate
        -- on a pattern isn't automatically a gate on the finished tradeable
        -- item. Keep uncertainty rather than inventing a commission route.
        local recipeRoute=gear.profession and (route.kind=="trainer" or route.kind=="recipe_vendor"
            or route.kind=="recipe_drop" or route.bookItemID or route.recipe)
        if not recipeRoute then
            finishedRoutes=finishedRoutes+1
            if self:IsAcquisitionRouteAllowed(route,nil,options) and (not compact or self:IsAcquisitionRoutePractical(route)) then results[#results+1]=route end
        end
    end
    if finishedRoutes==0 then return nil end
    return results
end

function GetGear:HasAccessibleAcquisition(gear, mode)
    local future=mode=="upcoming" or mode=="tracker" and (gear.targetLevel or 1)>(self.level or 1)
    local routes=self:GetEligibleAcquisitionRoutes(gear,false,{level=(self.level or 1)+(future and 5 or 0)})
    return routes==nil or #routes>0
end
