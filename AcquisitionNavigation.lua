local _, GetGear = ...

-- Shared, read-only acquisition plans. Character quest progress is queried,
-- never inferred from equipment status or another character's completion.
local function data() return GetGear.AcquisitionNavigationData or {items={},sources={},quests={},chains={}} end
local function get(t,id) return t and (t[id] or t[tostring(id)]) end
function GetGear:GetRecipeSkillRequirement(gear)
    if not gear then return end
    local fact=get(data().recipeRequirements,gear.itemID) or {}
    if type(fact.recipeMinimumSkill)=="number" then return fact.recipeMinimumSkill,"recipe minimum" end
    if type(fact.trainerLearningSkills)=="table" and #fact.trainerLearningSkills==1 then
        return fact.trainerLearningSkills[1],"learning minimum"
    end
    if type(fact.bookLearningSkill)=="number" then return fact.bookLearningSkill,"book learning minimum" end
    if type(gear.professionSkillRequired)=="number" and gear.recipeLearnSkillEvidence~="unverified" then
        return gear.professionSkillRequired,"learning minimum"
    end
end
function GetGear:GetRecipeAcquisitionKind(gear)
    local fact=get(data().recipeRequirements,gear and gear.itemID) or {}
    return fact.broadBookDrop and "broad-book-drop" or nil
end
local function call(fn,...)
    if type(fn)~="function" then return end
    local ok,a,b,c=pcall(fn,...)
    if ok and not (type(issecretvalue)=="function" and (issecretvalue(a) or issecretvalue(b) or issecretvalue(c))) then return a,b,c end
end
-- Travel preferences are not item-faction restrictions. In particular, a
-- neutral drop in an opposing starting territory remains in the full guide.
local HOME_SIDE={
    ["Tirisfal Glades"]=2,["Durotar"]=2,["Mulgore"]=2,
    ["Elwynn Forest"]=1,["Dun Morogh"]=1,["Teldrassil"]=1,
    ["Stormwind City"]=1,["Stormwind"]=1,["Ironforge"]=1,["Darnassus"]=1,
    ["Orgrimmar"]=2,["Undercity"]=2,["Thunder Bluff"]=2,
}
local CAPITAL={ ["Stormwind City"]=1,["Stormwind"]=1,["Ironforge"]=1,["Darnassus"]=1,
    ["Orgrimmar"]=2,["Undercity"]=2,["Thunder Bluff"]=2 }
local function travelContext()
    local faction=call(UnitFactionGroup,"player")
    local side=faction=="Alliance" and 1 or faction=="Horde" and 2
    local map=C_Map and call(C_Map.GetBestMapForUnit,"player")
    local info=map and C_Map and call(C_Map.GetMapInfo,map)
    return side,map,type(info)=="table" and info.name,call(UnitLevel,"player") or GetGear.level
end
local function onQuest(id) return C_QuestLog and call(C_QuestLog.IsOnQuest,id)==true end
local function chooseQuest(goal)
    local chain=get(data().chains,goal)
    if chain and chain.sideSteps then
        local side=call(UnitFactionGroup,"player")=="Alliance" and "1" or call(UnitFactionGroup,"player")=="Horde" and "2"
        if side and chain.sideSteps[side] then
            local selected={};for k,v in pairs(chain)do selected[k]=v end
            selected.steps=chain.sideSteps[side];chain=selected
        end
    end
    local steps=chain and chain.steps or {goal}
    for _, id in ipairs(steps) do if onQuest(id) then return id,"active",chain end end
    if C_QuestLog and call(C_QuestLog.IsQuestFlaggedCompleted,goal)==true then return goal,"completed",chain end
    if not chain or chain.routeVerified then
        for _, id in ipairs(steps) do
            local complete=C_QuestLog and call(C_QuestLog.IsQuestFlaggedCompleted,id)
            if type(complete)~="boolean" then return steps[1],"unknown",chain end
            if not complete then return id,"incomplete",chain end
        end
        return steps[#steps],"completed",chain
    end
    return steps[1],"unknown",chain
end
local function offerText(route)
    local out,offer={},route.offer or {}
    for _,text in ipairs(route.sourceRequirements or {}) do
        if type(text)=="string" and text~="" then out[#out+1]=text end
    end
    if route.cost and route.currency then out[#out+1]=tostring(route.cost).." "..route.currency end
    local cost=offer.cost
    if type(cost)=="table" then
        -- Primary item tables wrap price options; older records use one triple.
        -- Options are alternatives, never additional simultaneous fees.
        local variants=type(cost[1])=="table" and cost or {cost}
        local alternatives={}
        for _, price in ipairs(variants) do
            local parts={}
            if type(price[1])=="number" and price[1]>0 then
                local n=price[1];parts[#parts+1]=string.format("%dg %ds %dc",math.floor(n/10000),math.floor(n/100)%100,n%100)
            end
            for _, p in ipairs(type(price[2])=="table" and price[2] or {}) do
                if type(p)=="table" and p[1] and p[2] then
                    local info=C_CurrencyInfo and call(C_CurrencyInfo.GetCurrencyInfo,p[1])
                    local published=get(data().currencies,p[1])
                    local name=type(info)=="table" and info.name
                    if type(name)~="string" or name=="" then name=type(published)=="table" and published.name end
                    if type(name)~="string" or name=="" then name="currency #"..tostring(p[1]) end
                    parts[#parts+1]=tostring(p[2]).." "..name
                end
            end
            for _, p in ipairs(type(price[3])=="table" and price[3] or {}) do
                if type(p)=="table" and p[1] and p[2] then parts[#parts+1]=tostring(p[2]).." item #"..tostring(p[1]) end
            end
            if #parts>0 then alternatives[#alternatives+1]=table.concat(parts," + ") end
        end
        if #alternatives>0 then out[#out+1]=table.concat(alternatives," OR ") end
    end
    if type(offer.avail)=="number" and offer.avail>0 or type(offer.stock)=="number" and offer.stock>0 then out[#out+1]="Limited listing; live stock unverified" end
    if type(offer.standing)=="number" and offer.standing>0 then
        local rank=({"Hated","Hostile","Unfriendly","Neutral","Friendly","Honored","Revered","Exalted"})[offer.standing]
        out[#out+1]="Requires "..(rank or "standing "..offer.standing).." with faction #"..tostring(offer.reqfaction or "unknown")
    end
    if offer.side==1 or offer.side==2 then out[#out+1]=(offer.side==1 and "Alliance" or "Horde").." source access" end
    return table.concat(out,"; ")
end

local function appendQuestItems(out,q,prefix)
    if type(q.requiredItems)~="table" or next(q.requiredItems)==nil then return end
    local listed=false
    for _, item in ipairs(q.requiredItems) do
        if type(item)=="table" and type(item.name)=="string" and type(item.quantity)=="number" and item.quantity>0 then
            out[#out+1]=(prefix or "")..(item.startsQuest==true and "Quest starter item: " or item.provided==true and "Provided by quest: " or "Required item: ")..item.quantity.." "..item.name
            listed=true
        end
    end
    if not listed then out[#out+1]=(prefix or "").."This quest requires physical items; see acquisition evidence below for quantities and current requirements." end
end

local function sourceLocations(actor,q,key,route)
    local zone=q and q.actorZones and q.actorZones[key] or route and route.sourceZone
    if not zone then return actor.locations or {} end
    local locations={}
    for _,loc in ipairs(actor.locations or {}) do
        if loc.zone==zone then locations[#locations+1]=loc end
    end
    if #locations==0 then locations[1]={zone=zone,verification="published-reference"} end
    return locations
end

local function routesForCharacter(model,plan)
    local routes=plan and plan.routes or {}
    local faction=call(UnitFactionGroup,"player")
    local side=faction=="Alliance" and 1 or faction=="Horde" and 2
    local _,_,classID=call(UnitClass,"player")
    local classBit=type(classID)=="number" and classID>=1 and classID<=32 and classID==math.floor(classID) and 2^(classID-1)
    if not side and not classBit then return routes end
    local useful={}
    for _,route in ipairs(routes) do
        local restricted=route.serviceSide or route.offer and route.offer.side
        local classMask
        local activeSide,activeClass=false,false
        if route.kind=="quest" or route.kind=="quest_container" then
            local goal=get(model.quests,route.questID) or {}
            restricted=goal.side
            classMask=type(goal.reqclass)=="number" and goal.reqclass>0 and goal.reqclass==math.floor(goal.reqclass) and goal.reqclass
            activeSide=onQuest(route.questID);activeClass=activeSide
            if not activeSide and ((restricted==1 or restricted==2) or classMask) then
                local chain=get(model.chains,route.questID)
                for _,id in ipairs(chain and chain.steps or {}) do
                    local q=get(model.quests,id) or {}
                    if onQuest(id) then
                        -- Unrestricted/shared stages alone cannot establish
                        -- access to a restricted final reward path.
                        if (restricted==1 or restricted==2) and q.side==restricted then activeSide=true end
                        if classMask and q.reqclass==classMask then activeClass=true end
                    end
                end
            end
        end
        local sideAllowed=not side or activeSide or restricted~=1 and restricted~=2 or restricted==side
        local classAllowed=not classBit or not classMask or activeClass or math.floor(classMask/classBit)%2==1
        if sideAllowed and classAllowed then useful[#useful+1]=route end
    end
    return useful
end

function GetGear:GetAcquisitionInstanceDefinition(name)
    local model=data()
    local canonical=(model.instanceEntranceAliases or {})[name] or name
    return (model.instanceEntrances or {})[canonical],canonical
end

-- Compact context is derived from structured, character-accessible routes.
-- The original researched summary/provenance stays intact in the full guide.
function GetGear:GetCompactAcquisitionRequirements(gear)
    local source=gear and gear.sourceSummary or ""
    local out={}
    for tag,clause in tostring(source):gmatch("[Pp]ublished ([^:%.]+):%s*([^%.]+)") do
        if tag=="requirement" or tag=="gate" or tag=="book specialisation" or tag=="specialisation" or tag=="book requirement" or tag=="availability" then
            clause=clause:gsub("%s*%(live stock/access unverified%)",""):gsub("%s+$","")
            local standing,alliance,horde=clause:match('^(.-) reputation %(Alliance: ([^;]+); Horde: ([^;]+);')
            if standing then
                local side=call(UnitFactionGroup,'player')
                clause=standing..(side=='Alliance' and ' with '..alliance or side=='Horde' and ' with '..horde
                    or ' — Alliance: '..alliance..'; Horde: '..horde)..' (access unverified)'
            end
            out[#out+1]=(tag=="book specialisation" and "Learn: " or tag=="specialisation" and "Specialisation: " or "")..clause
        end
    end
    local tooltip=tostring(source):match('Exact tooltip requirement:%s*([^%.]+)')
    if tooltip then out[#out+1]='Requires: '..tooltip end
    return out
end

local function compactRecipeSummary(self,gear)
    if not gear or not gear.profession then return end
    local model=data();local plan=get(model.items,gear.itemID)
    local minimum=self:GetRecipeSkillRequirement(gear)
    local skill=minimum and (" ("..minimum..")") or " (skill unverified)"
    -- Some reviewed gates predate structured offers. Preserve their explicitly
    -- labelled clause verbatim rather than losing it during summarisation.
    local requirements=self:GetCompactAcquisitionRequirements(gear)
    local publishedRequirement=#requirements>0 and table.concat(requirements,"; ")
    local disputed=gear.recipeLearningAvailability=="disputed" or gear.recipeLearnMethod=="multiple"
    if disputed then return "Recipe: teaching method disputed; "..(publishedRequirement and publishedRequirement.."; " or "").."see Guide for trainer/pattern routes." end
    local historical=gear.acquisitionConfidence=="classic-reference" or gear.confidence=="classic-reference"
    -- A trainer's mere mention is not a standard teaching route. Require the
    -- existing explicit trainer method or multiple independently matched full
    -- teaching tables, a known minimum and no competing/restricted book route.
    local fact=get(model.recipeRequirements,gear.itemID) or {}
    local teachers,seen,spell,ordinary=0,{},nil,not historical and not gear.recipePatternItemID
        and not gear.recipeVendor and not fact.minimumDisputed and not publishedRequirement
        and gear.recipeLearnMethod~="pattern" and gear.recipeLearnMethod~="unknown"
    for _,route in ipairs(plan and plan.routes or {}) do
        if route.kind~="trainer" or route.verification~="published-reference"
            or not route.spellID or #(route.sourceRequirements or {})>0 or route.offer
            or route.cost or route.currency then ordinary=false end
        if route.spellID and spell and route.spellID~=spell then ordinary=false end
        spell=spell or route.spellID
        local actor=model.sources[route.source] or {}
        if route.kind=="trainer" and route.verification=="published-reference" and route.spellID
            and #(actor.evidence or {})>0 and not seen[route.source] then
            seen[route.source]=true;teachers=teachers+1
        end
    end
    local explicit=gear.recipeLearnMethod=="trainer" or gear.professionLearnSource=="Trainer"
    if ordinary and (explicit or teachers>=2 and minimum) then
        return "Recipe: "..gear.profession.." trainer"..skill
    end
    if gear.recipeLearnMethod=="initial" and ordinary then
        return "Recipe: learned with "..gear.profession..skill
    end
    if self:GetRecipeAcquisitionKind(gear)=="broad-book-drop" then
        return "Recipe: random drop; trade/Auction House if tradeable (listings unknown)."
    end
    local routes=routesForCharacter(model,plan)
    local function qualified(text,route,uncertainty)
        local requirements=offerText(route)
        if publishedRequirement and not requirements:find(publishedRequirement,1,true) then
            requirements=requirements..(requirements~="" and "; " or "")..publishedRequirement
        end
        return "Recipe: "..text.." ("..gear.profession..(minimum and " "..minimum or "; skill unverified")..")"
            ..(requirements~="" and "; "..requirements or "")
            ..((historical or route.verification=="legacy-reference")
                and "; Classic reference, verify in Forever" or uncertainty or "")
    end
    -- Prefer a meaningful named acquisition route; trainer alternatives are
    -- retained in the guide without allowing one reference to imply routine teaching.
    for _,route in ipairs(routes) do
        if route.kind=="recipe_vendor" or route.kind=="vendor" then
            local actor=model.sources[route.source] or {}
            local name=actor.name or route.label or route.location and route.location.spot
            if name then return qualified(name,route,"; stock/access unverified") end
        end
    end
    for _,route in ipairs(routes) do
        if route.kind=="quest" then
            local q=get(model.quests,route.questID) or {}
            local parts={q.name or "quest #"..tostring(route.questID)}
            if q.reqlevel then parts[#parts+1]="quest level "..q.reqlevel end
            if q.side==1 or q.side==2 then parts[#parts+1]=q.side==1 and "Alliance" or "Horde" end
            if type(q.reqclass)=="number" and q.reqclass>0 then
                local names={}
                for _,entry in ipairs({{1,'Warrior'},{2,'Paladin'},{3,'Hunter'},{4,'Rogue'},{5,'Priest'},{7,'Shaman'},{8,'Mage'},{9,'Warlock'},{11,'Druid'}}) do
                    if math.floor(q.reqclass/2^(entry[1]-1))%2==1 then names[#names+1]=entry[2] end
                end
                if #names>0 then parts[#parts+1]=table.concat(names,'/')..' quest access' end
            end
            for _,requirement in ipairs(q.sourceRequirements or {}) do
                if #requirement<=100 then parts[#parts+1]=requirement end
                for _,specialisation in ipairs({'Armorsmith','Weaponsmith','Master Axesmith','Master Swordsmith','Master Hammersmith','Tribal Leatherworking','Elemental Leatherworking','Dragonscale Leatherworking'}) do
                    if requirement:find(specialisation,1,true) then parts[#parts+1]=specialisation end
                end
            end
            return qualified(table.concat(parts,"; "),route,"; prerequisites/access: see Guide")
        elseif route.kind=="dungeon" then
            return qualified((route.boss and route.boss.." — " or "")..route.dungeon.." drop",route,"; drop/access unverified")
        elseif route.kind=="recipe_drop" then
            local actor=model.sources[route.source] or {}
            if actor.name then return qualified(actor.name.." drop",route,"; drop unverified") end
        end
    end
    for _,route in ipairs(routes) do
        if route.kind=="trainer" then
            local actor=model.sources[route.source] or {}
            if actor.name then return qualified(actor.name.." — trainer",route,"; teaching/access unverified") end
        end
    end
end

function GetGear:GetCompactRecipeSummary(gear)
    if not gear or not gear.profession then return end
    local plan=get(data().items,gear.itemID)
    local routes=routesForCharacter(data(),plan)
    local summary=compactRecipeSummary(self,gear)
    local routine=summary and summary:find('Recipe: '..gear.profession..' trainer',1,true)==1
    if not routine and plan and #(plan.routes or {})>0 and #routes==0 then
        summary="Recipe: no known source route for this character; see Guide"
    end
    if not summary and self.GetCompactLegacyAcquisitionSummary then summary=self:GetCompactLegacyAcquisitionSummary(gear) end
    if not summary then return end
    for _,requirement in ipairs(self:GetCompactAcquisitionRequirements(gear)) do
        if not summary:find(requirement,1,true) then summary=summary.."; "..requirement end
    end
    local kinds,methods={},0
    for _,route in ipairs(routes) do
        local kind=({recipe_vendor='vendor',vendor='vendor',trainer='trainer',recipe_drop='drop',dungeon='drop',quest='quest',object='object'})[route.kind]
        if kind and not kinds[kind] then kinds[kind]=true;methods=methods+1 end
    end
    if methods>1 and not summary:find('other routes',1,true) then summary=summary..'; other methods: Guide' end
    return summary
end

function GetGear:GetAcquisitionCompactSummary(gear)
    if gear and gear.profession then return self:GetCompactRecipeSummary(gear) end
    local model=data();local plan=get(model.items,gear and gear.itemID)
    if plan and #(plan.routes or {})>0 and #routesForCharacter(model,plan)==0 then
        return 'Source: no known route for this character; see Guide'
    end
    local target=self:GetAcquisitionMapTarget(gear)
    if target then
        local label=target.label or target.zone or 'location unresolved'
        local prefix='Source: '
        if target.questID then prefix='Quest: ';label=(target.questName or 'quest #'..target.questID)..' — '..label
        elseif target.kind=='dungeon' then label=(target.dungeon or label)..(target.boss and ' — '..target.boss or '') end
        local requirements=target.requirements or ''
        requirements=requirements:gsub('Published Alliance source;','Alliance source;'):gsub('Published Horde source;','Horde source;')
        if target.questID then
            local q=get(model.quests,target.questID) or {}
            local out={}
            if q.side==1 or q.side==2 then out[#out+1]=q.side==1 and 'Alliance' or 'Horde' end
            if type(q.reqclass)=='number' and q.reqclass>0 then out[#out+1]='Class-restricted' end
            for _,requirement in ipairs(q.sourceRequirements or {}) do
                if #requirement<=80 then out[#out+1]=requirement end
            end
            out[#out+1]=#(q.requiredItems or {})>0 and 'Items/unlocks: Guide' or 'Unlocks: Guide'
            requirements=table.concat(out,'; ')
        end
        local container=target.kind=='quest_container' or target.kind=='npc_container' or target.kind=='vendor_container'
        if target.questID then
            for _,route in ipairs(plan and plan.routes or {}) do
                if route.questID==target.questID and route.kind=='quest_container' then container=true end
            end
        end
        return prefix..label..(target.zone and target.kind~='dungeon' and ' — '..target.zone or '')
            ..(target.minimumLevel and '; quest level '..target.minimumLevel or '')
            ..(container and '; possible container contents' or '')
            ..(requirements~='' and '; '..requirements or '')..'; access unverified'
    end
    local out,seen={},{}
    for _,route in ipairs(routesForCharacter(model,plan)) do
        if (route.kind=='vendor' or route.kind=='recipe_vendor' or route.kind=='trainer')
            and (route.serviceSide or route.offer and route.offer.side) then
            local actor=model.sources[route.source] or {}
            local loc=(actor.locations or {})[1]
            if actor.name and loc and loc.zone and not seen[route.source] then
                seen[route.source]=true;out[#out+1]=actor.name..' — '..loc.zone..(offerText(route)~='' and ('; '..offerText(route))or'')
            end
        end
    end
    if #out>0 then
        local minimum=self:GetRecipeSkillRequirement(gear)
        local recipe=gear.profession and ((gear.recipePatternItemID and ('Pattern: #'..gear.recipePatternItemID..'; ')or'Recipe source: ')
            ..gear.profession..(minimum and (' '..minimum)or'')..'; ')or'Source: '
        return recipe..out[1]
            ..(#out>1 and ('; '..(#out-1)..' other qualified location(s)')or'')
            ..' (published reference; current stock/access unverified).'
    end
end

function GetGear:GetAcquisitionNavigationChoices(gear)
    if not gear then return {} end
    local model=data()
    local plan=get(model.items,gear.itemID)
    if not plan and type(gear.acquisitionLocation)=="table" then
        plan={routes={{kind="legacy",location=gear.acquisitionLocation,label=gear.acquisitionLocation.spot}}}
    end
    if not plan then return {} end
    local routes=routesForCharacter(model,plan)
    local choices,seen={},{}
    local function add(target)
        local b=target.bounds
        local footprint=b and table.concat({b.xMin or'',b.xMax or'',b.yMin or'',b.yMax or''},',')or''
        local key=target.kind=='dungeon' and target.entranceOnly and ('entrance|'..target.dungeon..'|'..(target.entranceID or'main'))
            or table.concat({target.role or "",target.questID or "",target.source or "",target.zone or "",target.x or "",target.y or "",footprint,target.dungeon or "",target.label or ""},"|")
        if seen[key] then
            local old=seen[key]
            if target.instructions and not (old.instructions or ''):find(target.instructions,1,true) then old.instructions=(old.instructions or '')..'\n'..target.instructions end
            if target.boss and not (old.boss or ''):find(target.boss,1,true) then old.boss=(old.boss and old.boss..', 'or'')..target.boss end
            if target.requirements and target.requirements~='' and not (old.requirements or ''):find(target.requirements,1,true) then
                old.requirements=(old.requirements and old.requirements~='' and old.requirements..'; Other published conditions: 'or'')..target.requirements
            end
        end
        if not seen[key] then seen[key]=target;target.id=key;choices[#choices+1]=target end
    end
    local function source(key,role,q,route,preferred)
        local side=travelContext()
        if q and q.actorSides and q.actorSides[key] and side and q.actorSides[key]~=side then return end
        local actor=model.sources[key] or {}
        local locations=sourceLocations(actor,q,key,route)
        local unresolved=q and #(q.relatedQuests or {})>0 and not get(model.chains,route.questID)
        local requirements=offerText(route)
        if q and #(q.sourceRequirements or {})>0 then
            requirements=(requirements~="" and requirements.."; " or "")..table.concat(q.sourceRequirements,"; ")
        end
        if route.directionsOnly==true then
            local writtenLocations=#locations>0 and locations or {{}}
            for _,loc in ipairs(writtenLocations) do
                local context=(model.instanceDetails or {})[loc.zone]
                local entrance=route.entranceOnly and (model.instances or {})[loc.zone]
                local instructions=route.instructions
                if context and context.instructions then instructions=(instructions and instructions.."\n" or "")..context.instructions end
                add({kind=entrance and "dungeon" or "directions",dungeon=entrance and loc.zone or nil,
                     entranceOnly=entrance and true or nil,source=key,label=actor.name or key,role=entrance and "Instance entrance" or role,
                     zone=loc.zone,verification=route.verification,
                     questID=q and q.questID,questName=q and q.name,preferred=preferred,
                     instructions=instructions,requirements=requirements})
            end
            return
        end
        if #locations==0 then
            add({kind="directions",source=key,label=actor.name or key,role=role,questID=q and q.questID,
                 instructions="Exact location has not been established."..(route.instructions and "\n"..route.instructions or ""),missingLocation=true,requirements=requirements})
        end
        for _, loc in ipairs(locations) do
            local instance=(model.instances or {})[loc.zone]
            local context=(model.instanceDetails or {})[loc.zone]
            local instructions=route.instructions
            if context and context.instructions then instructions=(instructions and instructions.."\n" or "")..context.instructions end
            add({kind=instance and "dungeon" or route.kind,dungeon=instance and loc.zone or nil,
                 entranceOnly=instance and route.entranceOnly and true or nil,
                 boss=instance and route.boss or nil,source=key,label=actor.name or key,zone=loc.zone,uiMapID=not instance and loc.uiMapID or nil,
                 x=not instance and loc.x or nil,y=not instance and loc.y or nil,bounds=not instance and loc.bounds or nil,verification=loc.verification,role=role,
                 questID=q and q.questID,questName=q and q.name,requirements=requirements,preferred=preferred,
                 instructions=instructions,bookItemID=route.bookItemID,chainUnresolved=unresolved})
        end
    end
    local questRoutes=0
    for _, route in ipairs(routes) do if route.kind=="quest" or route.kind=="quest_container" then questRoutes=questRoutes+1 end end
    for _, route in ipairs(routes) do
        if route.kind=="quest" or route.kind=="quest_container" then
            local id,state=chooseQuest(route.questID)
            local q=get(model.quests,id) or {questID=id,starts={},ends={}}
            if onQuest(id) then
                local nativeObjective=false
                local mapID,x,y=call(C_QuestLog.GetNextWaypoint,id)
                if type(mapID)=="number" and mapID>0 and type(x)=="number" and type(y)=="number" and x>=0 and x<=1 and y>=0 and y<=1 then
                    local info=C_Map and call(C_Map.GetMapInfo,mapID)
                    nativeObjective=true
                    add({kind="active_quest",questID=id,questName=q.name,role="Active quest objective",
                         label=call(C_QuestLog.GetNextWaypointText,id) or q.name or "Quest #"..id,
                         uiMapID=mapID,zone=info and info.name,x=x*100,y=y*100,
                         clientVerified=true,verification="client",preferred=questRoutes==1})
                end
                if not nativeObjective then
                    if call(C_QuestLog.IsComplete,id)==true then
                        for _,key in ipairs(q.ends or {}) do source(key,"Quest turn-in",q,route,questRoutes==1) end
                        if #(q.ends or {})==0 and q.turnInZone and q.turnInInstructions then
                            add({kind="directions",questID=id,questName=q.name,label=q.name or "Quest #"..id,
                                 role="Published return directions",zone=q.turnInZone,instructions=q.turnInInstructions,
                                 verification="published-reference",preferred=questRoutes==1})
                        end
                    elseif q.objectiveInstructions then
                        local instructions="Published objective guidance; current objective progress is not determined by GetGear.\n"..q.objectiveInstructions
                        if q.objectiveSource and model.sources[q.objectiveSource] then
                            local objectiveRoute={}
                            for key,value in pairs(route) do objectiveRoute[key]=value end
                            objectiveRoute.instructions=(route.instructions and route.instructions.."\n" or "")..instructions
                            source(q.objectiveSource,"Published active quest objective",q,objectiveRoute,questRoutes==1)
                        elseif q.objectiveZone then
                            local instance=(model.instances or {})[q.objectiveZone]
                            add({kind=instance and "dungeon" or "directions",dungeon=instance and q.objectiveZone or nil,
                                 questID=id,questName=q.name,label=q.name or "Quest #"..id,role="Published active quest objective",
                                 zone=q.objectiveZone,instructions=instructions,verification="published-reference",
                                 requirements=table.concat(q.sourceRequirements or {},"; "),preferred=questRoutes==1})
                        end
                    end
                end
            end
            if state~="completed" and not onQuest(id) and q.starterZone and q.starterInstructions then
                for _, item in ipairs(q.starterItems or {}) do
                    local requirements=q.reqlevel and "Quest minimum level: "..q.reqlevel or ""
                    if q.side==1 or q.side==2 then requirements=requirements..(requirements~="" and "; " or "")..(q.side==1 and "Alliance" or "Horde").." quest access" end
                    local instance=(model.instances or {})[q.starterZone]
                    add({kind=instance and "dungeon" or "directions",dungeon=instance and q.starterZone or nil,
                         questID=id,questName=q.name,role="Quest starter item",label=item.name,
                         zone=q.starterZone,instructions=q.starterInstructions,requirements=requirements,
                         verification="published-reference",preferred=questRoutes==1})
                end
                if not q.starterItems or #q.starterItems==0 then
                    local instance=(model.instances or {})[q.starterZone]
                    add({kind=instance and "dungeon" or "directions",dungeon=instance and q.starterZone or nil,
                         questID=id,questName=q.name,role="Published starting directions",label=q.name or "Quest #"..id,
                         zone=q.starterZone,instructions=q.starterInstructions,
                         verification="published-reference",preferred=questRoutes==1})
                end
            end
            if not q.starterOriginUnresolved or onQuest(id) or state=="completed" then
                for _, key in ipairs(q.starts or {}) do source(key,state=="completed" and "Completed quest — start reference" or state=="incomplete" and "Next uncompleted published stage" or "Quest start",q,route,questRoutes==1 and state~="completed") end
                for _, key in ipairs(q.ends or {}) do source(key,state=="completed" and "Completed quest — turn-in reference" or "Quest turn-in",q,route,false) end
            end
        elseif route.kind=="dungeon" then
            local context=(model.instanceDetails or {})[route.dungeon]
            local instructions=route.instructions
            if context and context.instructions then instructions=(instructions and instructions.."\n" or "")..context.instructions end
            local definition,canonical=self:GetAcquisitionInstanceDefinition(route.dungeon)
            if definition then instructions=(instructions or '')..'\n'..(definition.instructions or '') end
            local variants=definition and definition.entrances or {}
            if #variants==0 then variants={{}} end
            for _,entrance in ipairs(variants) do
                add({kind="dungeon",dungeon=canonical,label=entrance.label or (canonical.." entrance"),boss=route.boss,
                    entranceOnly=true,entranceID=entrance.id,publishedEntrance=entrance.zone and entrance or nil,
                    multipleEntrances=#variants>1,
                    zone=entrance.zone,x=entrance.x,y=entrance.y,coordinateKind=entrance.coordinateKind,
                    role=route.recipe and "Obtain recipe in dungeon" or "Dungeon entrance",instructions=instructions,
                    verification=entrance.verification or route.verification,bookItemID=route.bookItemID})
            end
        elseif route.source then
            source(route.source,route.kind=="recipe_vendor" and "Recipe vendor" or route.kind=="vendor_container" and "Container vendor" or route.kind=="npc_container" and "Container drop source" or route.kind=="recipe_drop" and "Obtain recipe book" or route.kind=="trainer" and "Recipe trainer" or route.kind=="crafting_requirement" and "Special crafting location" or route.kind=="unlock" and "Acquisition unlock" or route.kind=="fishing" and "Fishing zone" or route.kind=="vendor" and "Equipment vendor" or route.kind=="object" and "Acquisition object" or "Published named source",nil,route,false)
        elseif route.location then
            local loc=route.location
            add({kind=route.kind,label=route.label or loc.spot or loc.zone,zone=loc.zone,x=loc.x,y=loc.y,
                 bounds=loc.bounds,uiMapID=loc.uiMapID,verification=loc.verification or (loc.quality=="classic-reference" and "legacy-reference" or "published-reference"),
                 role=route.kind=="trainer" and "Recipe trainer" or route.kind=="recipe_vendor" and "Recipe vendor" or "Acquisition location",
                 requirements=offerText(route),instructions=route.instructions})
        end
    end
    local side,map,zone,level=travelContext()
    local trainerPreferred,trainerRank
    for index,target in ipairs(choices) do
        local q=target.questID and get(model.quests,target.questID)
        local minimum=q and q.reqlevel
        target.minimumLevel=type(minimum)=="number" and minimum or nil
        target.futureLevel=target.minimumLevel and type(level)=="number" and target.minimumLevel>level or false
        if target.futureLevel then target.preferred=false end
        local actor=target.source and model.sources[target.source] or {}
        local sameZone=(map and target.uiMapID==map) or zone and zone==target.zone
        target.opposingHome=side and HOME_SIDE[target.zone] and HOME_SIDE[target.zone]~=side
            and actor.serviceSide~=side and not sameZone or false
        if target.opposingHome then target.accessNote="Neutral/qualified source in opposing starting territory; travel may be inconvenient." end
        if target.futureLevel then
            target.accessNote=(target.accessNote and target.accessNote.." " or "").."Published quest minimum level: "..target.minimumLevel.."."
        end
        if target.role=="Recipe trainer" and side and actor.serviceSide==side and not target.futureLevel then
            local rank=sameZone and 0 or CAPITAL[target.zone]==side and 1 or 2
            -- Distance is used only within the identical published UI-map frame.
            local distance=0
            if sameZone and map==target.uiMapID and C_Map then
                local point=call(C_Map.GetPlayerMapPosition,map,"player")
                local x,y
                if point and type(point.GetXY)=="function" then x,y=call(point.GetXY,point) end
                if type(x)=="number" and type(y)=="number" and x>=0 and x<=1 and y>=0 and y<=1 then
                    local b=target.bounds
                    local tx=target.x or b and math.max(b.xMin,math.min(x*100,b.xMax))
                    local ty=target.y or b and math.max(b.yMin,math.min(y*100,b.yMax))
                    if tx and ty then distance=((x*100-tx)^2+(y*100-ty)^2)/100000 end
                end
            end
            rank=rank+distance
            if not trainerRank or rank<trainerRank then trainerPreferred=index;trainerRank=rank end
        end
    end
    if trainerPreferred then
        for _,target in ipairs(choices) do target.preferred=false end
        choices[trainerPreferred].preferred=true
    end
    return choices
end

function GetGear:GetAcquisitionOverlayExclusion(gear)
    if not gear or gear.bagUpgrade then return end
    local policy=get(data().availability,gear.itemID)
    if policy and policy.overlayEligible==false then return policy.reason or "Current Forever availability unconfirmed" end
    local plan=get(data().items,gear.itemID)
    if not plan or #(plan.routes or {})==0 then return end
    local side,_,_,level=travelContext()
    if not side then return end
    if #routesForCharacter(data(),plan)==0 then return "No published source route for this character's faction/class" end
    local current,hostile=0,0
    for _,target in ipairs(self:GetAcquisitionNavigationChoices(gear)) do
        if not target.missingLocation and not target.futureLevel then
            current=current+1
            if target.opposingHome then hostile=hostile+1 end
        end
    end
    if type(level)=="number" and level<=15 and current>0 and current==hostile then
        return "Only opposing starting-territory routes are currently practical-level candidates; alternatives remain in the guide"
    end
end
function GetGear:ShouldShowOverlayAcquisition(gear)
    return self:GetAcquisitionOverlayExclusion(gear)==nil
end

function GetGear:GetAcquisitionMapTarget(gear)
    local useful={}
    for _, target in ipairs(self:GetAcquisitionNavigationChoices(gear)) do
        if not target.missingLocation and (target.zone or target.kind=="dungeon" or target.clientVerified) then useful[#useful+1]=target end
    end
    if #useful==0 then return end
    local selected=useful[1]
    for _, target in ipairs(useful) do if target.preferred then selected=target;break end end
    local sameEntrance=selected.kind=="dungeon" and selected.entranceOnly==true
    for _,target in ipairs(useful) do
        if target.kind~="dungeon" or not target.entranceOnly or target.dungeon~=selected.dungeon or target.entranceID~=selected.entranceID then sameEntrance=false;break end
    end
    selected.choiceCount=sameEntrance and 1 or #useful
    selected.chooseFirst=not sameEntrance and #useful>1 and not selected.preferred
    selected.spot=selected.label
    return selected
end

function GetGear:GetAcquisitionDirections(gear)
    local out={}
    local minimum,kind=self:GetRecipeSkillRequirement(gear)
    if minimum then out[#out+1]="Published "..kind..": "..(gear.profession or "profession").." "..minimum.."; not a yellow/green/grey skill-up threshold." end
    local learning=get(data().recipeRequirements,gear and gear.itemID) or {}
    if learning.bookLearningSkill and learning.bookLearningSkill~=minimum then
        out[#out+1]="Published book-learning minimum: "..(gear.profession or "profession").." "..learning.bookLearningSkill.."; separate from the recipe/crafting minimum."
    end
    if self:GetRecipeAcquisitionKind(gear)=="broad-book-drop" then
        out[#out+1]="Physical pattern: broad/random published drop references, not a targeted farm. Listed enemy/zone examples do not confirm current loot. If tradeable, consider the Auction House or player trade; current listings are unknown."
    end
    local plan=get(data().items,gear and gear.itemID)
    for _, route in ipairs(routesForCharacter(data(),plan)) do
        if route.kind=="npc_container" then
            out[#out+1]="Possible equipment from container #"..route.containerItemID.."; the NPC drops the container, not guaranteed finished equipment."
        elseif route.kind=="vendor_container" then
            out[#out+1]="Possible equipment from container #"..route.containerItemID.."; the vendor sells the container, not guaranteed equipment."
        end
        if route.kind=="quest" or route.kind=="quest_container" then
            if route.kind=="quest_container" then
                out[#out+1]="Possible equipment from container #"..route.containerItemID.."; the quest rewards the container, not guaranteed equipment."
            end
            local id,state,chain=chooseQuest(route.questID)
            if state=="completed" then out[#out+1]="The client reports this reward quest complete; repeat availability is not determined." end
            if chain then
                out[#out+1]=chain.ordered==false and "Reported quest references (order unverified):" or "Quest route (ordered published stages):"
                if chain.instructions then out[#out+1]=chain.instructions end
                if not chain.prerequisitesVerified then out[#out+1]="Exact prerequisite/unlock rules remain unverified; this route does not prove quest availability." end
                for i, stepID in ipairs(chain.steps or {}) do
                    local q=get(data().quests,stepID) or {}
                    out[#out+1]=i..". "..(q.name or "Quest").." (#"..stepID..")"..(stepID==id and (state=="unknown" and " — start here; progress unknown" or " — "..state) or "")
                    if q.reqlevel then out[#out+1]="   Minimum quest level: "..q.reqlevel end
                    for _, item in ipairs(q.starterItems or {}) do out[#out+1]="   Quest starter item: "..item.name.." (#"..item.itemID..")" end
                    if q.starterInstructions then out[#out+1]="   "..q.starterInstructions end
                    if q.objectiveInstructions then out[#out+1]="   Objective: "..q.objectiveInstructions end
                    if q.turnInInstructions then out[#out+1]="   Return: "..q.turnInInstructions end
                    for _, detail in ipairs(q.acquisitionDetails or {}) do out[#out+1]="   "..detail end
                    for _, requirement in ipairs(q.sourceRequirements or {}) do out[#out+1]="   "..requirement end
                    appendQuestItems(out,q,"   ")
                    for _, role in ipairs({"starts","ends"}) do
                        for _, key in ipairs(q[role] or {}) do
                            local a=data().sources[key] or {}
                            local loc=sourceLocations(a,q,key)[1]
                            local side=q.actorSides and q.actorSides[key]
                            out[#out+1]="   "..(role=="starts" and "Start: " or "Turn-in: ")..(a.name or key)..(side and (side==1 and " (Alliance route)" or " (Horde route)") or "")..(loc and " — "..loc.zone or " — location unresolved")
                        end
                    end
                end
            else
                local q=get(data().quests,id) or {}
                out[#out+1]="Quest: "..(q.name or "#"..id).." (#"..id.."). Earlier prerequisites are not established unless listed below."
                for _, item in ipairs(q.starterItems or {}) do out[#out+1]="Quest starter item: "..item.name.." (#"..item.itemID..")" end
                if q.starterInstructions then out[#out+1]=q.starterInstructions end
                if q.objectiveInstructions then out[#out+1]="Objective: "..q.objectiveInstructions end
                if q.turnInInstructions then out[#out+1]="Return: "..q.turnInInstructions end
                for _, detail in ipairs(q.acquisitionDetails or {}) do out[#out+1]=detail end
                if q.starterOriginUnresolved then out[#out+1]="Starting item origin/location remains unverified. The turn-in NPC is not a starting destination." end
            end
            local q=get(data().quests,id) or {}
            if q.reqlevel then out[#out+1]="Published quest minimum level: "..q.reqlevel end
            for _, requirement in ipairs(q.sourceRequirements or {}) do out[#out+1]=requirement end
            if q.side==1 or q.side==2 then out[#out+1]="Published quest access: "..(q.side==1 and "Alliance" or "Horde") end
            for _, key in ipairs(q.objectives or {}) do
                local actor=data().sources[key] or {}
                local loc=sourceLocations(actor,q,key)[1]
                out[#out+1]="Quest objective: "..(actor.name or key)..(loc and " — "..loc.zone or " — location unresolved")
            end
            if route.bookItemID then out[#out+1]="Quest reward is recipe book #"..route.bookItemID..", not the finished equipment." end
            if not chain then appendQuestItems(out,q) end
        end
    end
    for _, target in ipairs(self:GetAcquisitionNavigationChoices(gear)) do
        local line=(target.role or "Destination")..": "..(target.label or "Unknown")
        if target.zone then line=line.." — "..target.zone end
        if type(target.x)=="number" and type(target.y)=="number" then line=line..string.format(" (%.1f, %.1f)",target.x,target.y)
        elseif target.bounds then local b=target.bounds;line=line..string.format("; published area x%.1f–%.1f, y%.1f–%.1f",b.xMin,b.xMax,b.yMin,b.yMax) end
        if target.missingLocation then line=line.." — exact location unresolved" end
        if target.accessNote then line=line.."\n"..target.accessNote end
        if target.boss and target.boss~="" then line=line.."; inside, find "..target.boss..". Boss-floor position/access requirements unverified." end
        if target.requirements and target.requirements~="" then line=line.."\n"..target.requirements end
        if target.instructions and target.instructions~="" then line=line.."\n"..target.instructions end
        out[#out+1]=line
    end
    if #out>0 then out[#out+1]="Published locations do not confirm current NPC presence, stock, loot or access. Quest completion does not confirm which reward was acquired." end
    return table.concat(out,"\n")
end
