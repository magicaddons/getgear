local _, GetGear = ...

-- Shared, read-only acquisition plans. Character quest progress is queried,
-- never inferred from equipment status or another character's completion.
local function data() return GetGear.AcquisitionNavigationData or {items={},sources={},quests={},chains={}} end
local function get(t,id) return t and (t[id] or t[tostring(id)]) end
local function call(fn,...)
    if type(fn)~="function" then return end
    local ok,a,b,c=pcall(fn,...)
    if ok and not (type(issecretvalue)=="function" and (issecretvalue(a) or issecretvalue(b) or issecretvalue(c))) then return a,b,c end
end
local function onQuest(id) return C_QuestLog and call(C_QuestLog.IsOnQuest,id)==true end
local function chooseQuest(goal)
    local chain=get(data().chains,goal)
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

local function sourceLocations(actor,q,key)
    local zone=q and q.actorZones and q.actorZones[key]
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
        local restricted=route.offer and route.offer.side
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
        local key=table.concat({target.role or "",target.questID or "",target.source or "",target.zone or "",target.x or "",target.y or "",target.dungeon or "",target.label or ""},"|")
        if not seen[key] then seen[key]=true;target.id=key;choices[#choices+1]=target end
    end
    local function source(key,role,q,route,preferred)
        local actor=model.sources[key] or {}
        local locations=sourceLocations(actor,q,key)
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
            add({kind="dungeon",dungeon=route.dungeon,label=route.dungeon.." entrance",boss=route.boss,
                 role=route.recipe and "Obtain recipe in dungeon" or "Dungeon entrance",instructions=route.instructions,
                 verification=route.verification,bookItemID=route.bookItemID})
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
    return choices
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
        if target.kind~="dungeon" or not target.entranceOnly or target.dungeon~=selected.dungeon then sameEntrance=false;break end
    end
    selected.choiceCount=sameEntrance and 1 or #useful
    selected.chooseFirst=not sameEntrance and #useful>1 and not selected.preferred
    selected.spot=selected.label
    return selected
end

function GetGear:GetAcquisitionDirections(gear)
    local out={}
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
                out[#out+1]="Quest route (ordered published stages):"
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
                            out[#out+1]="   "..(role=="starts" and "Start: " or "Turn-in: ")..(a.name or key)..(loc and " — "..loc.zone or " — location unresolved")
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
        if target.boss and target.boss~="" then line=line.."; inside, find "..target.boss..". Boss-floor position/access requirements unverified." end
        if target.requirements and target.requirements~="" then line=line.."\n"..target.requirements end
        if target.instructions and target.instructions~="" then line=line.."\n"..target.instructions end
        out[#out+1]=line
    end
    if #out>0 then out[#out+1]="Published locations do not confirm current NPC presence, stock, loot or access. Quest completion does not confirm which reward was acquired." end
    return table.concat(out,"\n")
end
