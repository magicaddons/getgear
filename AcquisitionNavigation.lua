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
    if chain and chain.routeVerified then
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
    if route.cost and route.currency then out[#out+1]=tostring(route.cost).." "..route.currency end
    local cost=offer.cost
    if type(cost)=="table" then
        if type(cost[1])=="number" and cost[1]>0 then
            local n=cost[1];out[#out+1]=string.format("%dg %ds %dc",math.floor(n/10000),math.floor(n/100)%100,n%100)
        end
        for _, p in ipairs(type(cost[2])=="table" and cost[2] or {}) do
            local info=C_CurrencyInfo and call(C_CurrencyInfo.GetCurrencyInfo,p[1])
            out[#out+1]=tostring(p[2]).." "..(type(info)=="table" and info.name or "currency #"..tostring(p[1]))
        end
        for _, p in ipairs(type(cost[3])=="table" and cost[3] or {}) do out[#out+1]=tostring(p[2]).." item #"..tostring(p[1]) end
    end
    if type(offer.avail)=="number" and offer.avail>0 then out[#out+1]="Limited listing; live stock unverified" end
    if type(offer.standing)=="number" and offer.standing>0 then
        local rank=({"Hated","Hostile","Unfriendly","Neutral","Friendly","Honored","Revered","Exalted"})[offer.standing]
        out[#out+1]="Requires "..(rank or "standing "..offer.standing).." with faction #"..tostring(offer.reqfaction or "unknown")
    end
    if offer.side==1 or offer.side==2 then out[#out+1]=(offer.side==1 and "Alliance" or "Horde").." source access" end
    return table.concat(out,"; ")
end

function GetGear:GetAcquisitionNavigationChoices(gear)
    if not gear then return {} end
    local model=data()
    local plan=get(model.items,gear.itemID)
    if not plan and type(gear.acquisitionLocation)=="table" then
        plan={routes={{kind="legacy",location=gear.acquisitionLocation,label=gear.acquisitionLocation.spot}}}
    end
    if not plan then return {} end
    local choices,seen={},{}
    local function add(target)
        local key=table.concat({target.role or "",target.questID or "",target.source or "",target.zone or "",target.x or "",target.y or "",target.dungeon or "",target.label or ""},"|")
        if not seen[key] then seen[key]=true;target.id=key;choices[#choices+1]=target end
    end
    local function source(key,role,q,route,preferred)
        local actor=model.sources[key] or {}
        local locations=actor.locations or {}
        local unresolved=q and #(q.relatedQuests or {})>0 and not get(model.chains,route.questID)
        if #locations==0 then
            add({kind="directions",source=key,label=actor.name or key,role=role,questID=q and q.questID,
                 instructions="Exact location has not been established."..(route.instructions and "\n"..route.instructions or ""),missingLocation=true,requirements=offerText(route)})
        end
        for _, loc in ipairs(locations) do
            local instance=(model.instances or {})[loc.zone]
            add({kind=instance and "dungeon" or route.kind,dungeon=instance and loc.zone or nil,
                 boss=instance and (actor.name or key) or nil,source=key,label=actor.name or key,zone=loc.zone,uiMapID=loc.uiMapID,
                 x=loc.x,y=loc.y,bounds=loc.bounds,verification=loc.verification,role=role,
                 questID=q and q.questID,questName=q and q.name,requirements=offerText(route),preferred=preferred,
                 instructions=route.instructions,bookItemID=route.bookItemID,chainUnresolved=unresolved})
        end
    end
    local questRoutes=0
    for _, route in ipairs(plan.routes or {}) do if route.kind=="quest" then questRoutes=questRoutes+1 end end
    for _, route in ipairs(plan.routes or {}) do
        if route.kind=="quest" then
            local id,state=chooseQuest(route.questID)
            local q=get(model.quests,id) or {questID=id,starts={},ends={}}
            if onQuest(id) then
                local mapID,x,y=call(C_QuestLog.GetNextWaypoint,id)
                if type(mapID)=="number" and type(x)=="number" and type(y)=="number" and x>=0 and x<=1 and y>=0 and y<=1 then
                    local info=C_Map and call(C_Map.GetMapInfo,mapID)
                    add({kind="active_quest",questID=id,questName=q.name,role="Active quest objective",
                         label=call(C_QuestLog.GetNextWaypointText,id) or q.name or "Quest #"..id,
                         uiMapID=mapID,zone=info and info.name,x=x*100,y=y*100,
                         clientVerified=true,verification="client",preferred=questRoutes==1})
                end
            end
            for _, key in ipairs(q.starts or {}) do source(key,state=="completed" and "Completed quest — start reference" or state=="incomplete" and "Next uncompleted published stage" or "Quest start",q,route,questRoutes==1 and state~="completed") end
            for _, key in ipairs(q.ends or {}) do source(key,"Quest turn-in",q,route,false) end
        elseif route.kind=="dungeon" then
            add({kind="dungeon",dungeon=route.dungeon,label=route.dungeon.." entrance",boss=route.boss,
                 role=route.recipe and "Obtain recipe in dungeon" or "Dungeon entrance",instructions=route.instructions,
                 verification=route.verification,bookItemID=route.bookItemID})
        elseif route.source then
            source(route.source,route.kind=="recipe_vendor" and "Recipe vendor" or route.kind=="recipe_drop" and "Obtain recipe book" or route.kind=="trainer" and "Recipe trainer" or route.kind=="crafting_requirement" and "Special crafting location" or route.kind=="unlock" and "Acquisition unlock" or route.kind=="vendor" and "Equipment vendor" or route.kind=="object" and "Acquisition object" or "Published named source",nil,route,false)
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
    selected.choiceCount=#useful;selected.chooseFirst=#useful>1 and not selected.preferred
    selected.spot=selected.label
    return selected
end

function GetGear:GetAcquisitionDirections(gear)
    local out={}
    local plan=get(data().items,gear and gear.itemID)
    for _, route in ipairs(plan and plan.routes or {}) do
        if route.kind=="quest" then
            local id,state,chain=chooseQuest(route.questID)
            if chain then
                out[#out+1]="Quest route (ordered published stages):"
                if chain.instructions then out[#out+1]=chain.instructions end
                if not chain.prerequisitesVerified then out[#out+1]="Exact prerequisite/unlock rules remain unverified; this route does not prove quest availability." end
                for i, stepID in ipairs(chain.steps or {}) do
                    local q=get(data().quests,stepID) or {}
                    out[#out+1]=i..". "..(q.name or "Quest").." (#"..stepID..")"..(stepID==id and (state=="unknown" and " — start here; progress unknown" or " — "..state) or "")
                    if q.reqlevel then out[#out+1]="   Minimum quest level: "..q.reqlevel end
                    for _, role in ipairs({"starts","ends"}) do
                        for _, key in ipairs(q[role] or {}) do
                            local a=data().sources[key] or {}
                            out[#out+1]="   "..(role=="starts" and "Start: " or "Turn-in: ")..(a.name or key)..((a.locations or {})[1] and " — "..a.locations[1].zone or " — location unresolved")
                        end
                    end
                end
            else
                local q=get(data().quests,id) or {}
                out[#out+1]="Quest: "..(q.name or "#"..id).." (#"..id.."). Earlier prerequisites are not established unless listed below."
            end
            local q=get(data().quests,id) or {}
            if q.reqlevel then out[#out+1]="Published quest minimum level: "..q.reqlevel end
            if q.side==1 or q.side==2 then out[#out+1]="Published quest access: "..(q.side==1 and "Alliance" or "Horde") end
            for _, key in ipairs(q.objectives or {}) do
                local actor=data().sources[key] or {}
                local loc=(actor.locations or {})[1]
                out[#out+1]="Quest objective: "..(actor.name or key)..(loc and " — "..loc.zone or " — location unresolved")
            end
            if route.bookItemID then out[#out+1]="Quest reward is recipe book #"..route.bookItemID..", not the finished equipment." end
            if q.requiredItems then
                out[#out+1]="This quest requires physical items; see acquisition evidence below for quantities and current requirements."
            end
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
