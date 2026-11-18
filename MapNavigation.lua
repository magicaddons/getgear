local _, GetGear = ...

-- Forever 1.60.1 native map APIs, with guarded fallbacks. One GetGear-owned
-- canvas marker is reused; the player's native waypoint is never touched.
local fallbackMaps = {
    ["Dun Morogh"]={27,1426,1245}, ["Orgrimmar"]={85,1454,1250},
    ["Redridge Mountains"]={49,1433,1260}, ["Westfall"]={52,1436,1262},
    ["Darnassus"]={89,1457,1324}, ["Ironforge"]={87,1455,1265},
    ["Loch Modan"]={48,1432,1259}, ["The Barrens"]={10,1413,11},
    ["Ashenvale"]={63,1440}, ["Tirisfal Glades"]={18,1420},
    ["Wetlands"]={56,1437}, ["Silverpine Forest"]={21,1421}, ["Arathi Highlands"]={14,1417},
}
local function cleanName(name) return tostring(name or ""):lower():gsub("^the%s+",""):gsub("[^%w]","") end
local function call(fn,...)
    if type(fn)~="function" then return end
    local ok,a,b,c=pcall(fn,...)
    if ok and not (type(issecretvalue)=="function" and (issecretvalue(a) or issecretvalue(b) or issecretvalue(c))) then return a,b,c end
end
local function percentage(n) return type(n)=="number" and n>=0 and n<=100 end
local function normalized(n) return type(n)=="number" and n>=0 and n<=1 end
local function mapInfo(id) return C_Map and call(C_Map.GetMapInfo,id) end
local mapNameIndex
local function discoverMaps()
    if mapNameIndex then return end
    mapNameIndex={}
    local seeds,roots={},{}
    for _, candidates in pairs((GetGear.AcquisitionNavigationData or {}).maps or {}) do
        for _, id in ipairs(candidates) do seeds[id]=true end
    end
    for _, candidates in pairs(fallbackMaps) do for _, id in ipairs(candidates) do seeds[id]=true end end
    local player=C_Map and call(C_Map.GetBestMapForUnit,"player")
    if player then seeds[player]=true end
    for id in pairs(seeds) do
        local current,seen=id,{}
        for _=1,16 do
            local info=mapInfo(current)
            if not info then break end
            mapNameIndex[cleanName(info.name)]=current
            if not info.parentMapID or info.parentMapID==0 or seen[current] then roots[current]=true;break end
            seen[current]=true;current=info.parentMapID
        end
    end
    for id in pairs(roots) do
        for i,info in ipairs(C_Map and call(C_Map.GetMapChildrenInfo,id,nil,true) or {}) do
            if i>2048 then break end
            if info.mapID and info.name then mapNameIndex[cleanName(info.name)]=info.mapID end
        end
    end
end
local function resolveMap(zone,explicit)
    local function valid(id)
        local info=mapInfo(id)
        if type(info)=="table" and cleanName(info.name)==cleanName(zone) then return id end
    end
    -- A known explicit ID defines the coordinate space. Never reinterpret its
    -- coordinates on a similarly named city/zone map when the name disagrees.
    if explicit then return valid(explicit) end
    local maps=(GetGear.AcquisitionNavigationData or {}).maps or {}
    for _, id in ipairs(maps[zone] or {}) do if valid(id) then return id end end
    for _, id in ipairs(fallbackMaps[zone] or {}) do if valid(id) then return id end end
    -- New researched zones do not require another UI-specific ID table.
    discoverMaps()
    local id=mapNameIndex[cleanName(zone)]
    if id then return valid(id) end
    mapNameIndex=nil -- map data may not be available on the first click
end

function GetGear:ResolveAcquisitionMapID(zone,explicit) return resolveMap(zone,explicit) end

local entranceIndex
function GetGear:ResetAcquisitionNavigation()
    entranceIndex=nil;mapNameIndex=nil
    if self.ClearAcquisitionMapMarker then self:ClearAcquisitionMapMarker() end
end
local aliases={stockade="stormwindstockade",sunkentemple="templeofatalhakkar"}
local function dungeonKey(name) local canonical=((GetGear.AcquisitionNavigationData or {}).instanceEntranceAliases or {})[name] or name;local key=cleanName(canonical);return aliases[key] or key end
local function position(point)
    if not point then return end
    local x,y
    if type(point.GetXY)=="function" then x,y=call(point.GetXY,point) else x,y=point.x,point.y end
    if normalized(x) and normalized(y) then return x*100,y*100 end
end
local function dungeonEntrance(name,target)
    -- A dungeon's native portal does not identify a nearby quest giver. Keep
    -- that source's separately reviewed cave/building approach when selected.
    if target and target.approachOnly and target.publishedEntrance then return target.publishedEntrance end
    if target and target.publishedEntrance and target.publishedEntrance.routeInstructionsOnly then return target.publishedEntrance end
    local api=C_EncounterJournal and C_EncounterJournal.GetDungeonEntrancesForMap
        or C_Map and C_Map.GetDungeonEntrancesForMap
    if type(api)~='function' then return target and target.publishedEntrance end
    if not entranceIndex then
        entranceIndex={}
        local maps,roots={},{}
        for zone in pairs((GetGear.AcquisitionNavigationData or {}).maps or {}) do
            local id=resolveMap(zone);if id then maps[id]=true end
        end
        for zone in pairs(fallbackMaps) do local id=resolveMap(zone);if id then maps[id]=true end end
        for _,definition in pairs((GetGear.AcquisitionNavigationData or {}).instanceEntrances or {})do
            for _,entry in ipairs(definition.entrances or {})do local id=resolveMap(entry.zone,entry.uiMapID);if id then maps[id]=true end end
        end
        local current=C_Map and call(C_Map.GetBestMapForUnit,"player")
        if current then maps[current]=true end
        for id in pairs(maps) do
            local last,visited=id,{}
            for _=1,16 do
                local info=mapInfo(last)
                if not info or not info.parentMapID or info.parentMapID==0 or visited[last] then break end
                visited[last]=true;last=info.parentMapID
            end
            roots[last]=true
        end
        for root in pairs(roots) do
            for _, info in ipairs(C_Map and call(C_Map.GetMapChildrenInfo,root,Enum and Enum.UIMapType and Enum.UIMapType.Zone,true) or {}) do
                if info.mapID then maps[info.mapID]=true end
            end
        end
        local ordered={}
        for id in pairs(maps) do ordered[#ordered+1]=id end
        table.sort(ordered)
        -- Bounded once per session, on explicit navigation, never per UI row.
        for i=1,math.min(#ordered,256) do
            local id=ordered[i]
            for _, entry in ipairs(call(api,id) or {}) do
                local x,y=position(entry.position)
                local info=mapInfo(id)
                local dungeonType=Enum and Enum.UIMapType and Enum.UIMapType.Dungeon or 4
                if x and entry.name and type(info)=='table' and type(info.name)=='string'
                    and info.mapType~=dungeonType
                    and not ((GetGear.AcquisitionNavigationData or {}).instances or {})[info.name] then
                    local key=dungeonKey(entry.name)
                    entranceIndex[key]=entranceIndex[key] or {}
                    entranceIndex[key][#entranceIndex[key]+1]={zone=info and info.name,uiMapID=id,x=x,y=y,
                        clientVerified=true,verification="client",label=entry.name.." entrance",kind="dungeon"}
                end
            end
        end
    end
    local published=target and target.publishedEntrance
    local candidates=entranceIndex[dungeonKey(name)] or {}
    for _,entry in ipairs(candidates)do
        -- For a named multi-entrance destination, a generic client record
        -- must match that outdoor location, not silently pick another wing.
        if not published or cleanName(entry.zone)==cleanName(published.zone)and
            (not target.multipleEntrances or (entry.x-published.x)^2+(entry.y-published.y)^2<=4) then return entry end
    end
    return published
end

local marker,activeTarget,elapsed,driver=nil,nil,0,nil
local hookedCanvases=setmetatable({},{__mode="k"})
local attachMapHooks
local function stopReadiness()
    if driver then driver:SetScript("OnUpdate",nil);driver:Hide() end
end
local hookedMaps=setmetatable({},{__mode="k"})
local markerStatus,markerReason
local pendingAge,pendingNotified,pendingGear,pendingAnchor=0,false,nil,nil
local pendingMapRequested=false
-- Primary marker text names the destination. Coordinate precision and source
-- qualifications stay on the target, in the pin tooltip and in the full guide.
function GetGear:GetAcquisitionMarkerLabel(target)
    if not target then return "Destination" end
    local npc=self.GetAcquisitionNPCName and self:GetAcquisitionNPCName(target)
    if npc then return npc end
    local label=target.label or target.zone or "Destination"
    if target.kind=="dungeon" and target.dungeon then
        label=target.multipleEntrances and target.publishedEntrance and target.publishedEntrance.label
            or target.multipleEntrances and target.label or target.dungeon
    end
    for _,suffix in ipairs({" (published approach)"," (published area)"," (published reference)"," (legacy reference)"}) do
        if label:sub(-#suffix)==suffix then label=label:sub(1,-#suffix-1) end
    end
    label=label:gsub("%s*%([^)]*Classic%-only reference%)$","")
    return label
end
local function hideMarker() if marker then marker:Hide() end end
local placementReason
local function placementFailed(reason)
    placementReason=reason;hideMarker()
end
local function frameLevel(canvas)
    -- MapCanvas levels are absolute (native pins start near 2000), not a
    -- small offset from Child. Exploration is itself a native pin and can
    -- occlude a perfectly shown/visible frame at Child+100.
    local manager=call(WorldMapFrame.GetPinFrameLevelsManager,WorldMapFrame)
    -- A custom topmost definition may reserve a range, not a single level.
    -- The native manager clamps this index to the end of that range.
    local top=manager and call(manager.GetValidFrameLevel,manager,'PIN_FRAME_LEVEL_TOPMOST',9000)
    local base=call(canvas.GetFrameLevel,canvas) or 0
    return math.max(base+1,type(top)=='number' and top+1 or 2100)
end
local function fitLabel(precise)
    local viewport=call(WorldMapFrame.GetCanvasContainer,WorldMapFrame) or WorldMapFrame.ScrollContainer
    if not viewport then return end
    local vs,ls,ms=call(viewport.GetEffectiveScale,viewport),call(marker.label.GetEffectiveScale,marker.label),call(marker.GetEffectiveScale,marker)
    if not(vs and ls and ms)or vs<=0 or ls<=0 or ms<=0 then return end
    -- Fit the actual text, not a mostly empty fixed-width 250px box. Retain
    -- wrapping for long names, bounded by the current physical viewport.
    local limit=math.min(250,viewport:GetWidth()*vs/ls)
    marker.label:SetWidth(math.max(1,limit))
    marker.qualifier:SetWidth(math.max(1,limit))
    local width=call(marker.label.GetStringWidth,marker.label)
    marker.label:SetWidth(math.max(1,math.min(limit,type(width)=='number'and width+2 or 250)))
    local qualifierWidth=call(marker.qualifier.GetStringWidth,marker.qualifier)
    marker.qualifier:SetWidth(math.max(1,math.min(limit,type(qualifierWidth)=='number'and qualifierWidth+2 or 250)))
    local vl,vb=call(viewport.GetLeft,viewport),call(viewport.GetBottom,viewport)
    local ml,mb=call(marker.GetLeft,marker),call(marker.GetBottom,marker)
    local ll,lb=call(marker.label.GetLeft,marker.label),call(marker.label.GetBottom,marker.label)
    if not (vs and ls and ms and vl and vb and ml and mb and ll and lb) then return end
    local vr,vt=(vl+viewport:GetWidth())*vs,(vb+viewport:GetHeight())*vs;vl=vl*vs;vb=vb*vs
    -- Do not float a label at the viewport edge for an off-screen destination.
    if (ml+marker:GetWidth())*ms<=vl or ml*ms>=vr or (mb+marker:GetHeight())*ms<=vb or mb*ms>=vt then return end
    local lr,lt=(ll+marker.label:GetWidth())*ls,(lb+marker.label:GetHeight())*ls;ll=ll*ls;lb=lb*ls
    if not precise then
        local ql=call(marker.qualifier.GetLeft,marker.qualifier)
        if ql then ll=math.min(ll,ql*ls);lr=math.max(lr,(ql+marker.qualifier:GetWidth())*ls)end
    end
    local bottom=lb-(precise and 0 or (marker.qualifier:GetHeight()+2)*ls)
    local dx=ll<vl and vl-ll or lr>vr and vr-lr or 0
    local dy=bottom<vb and vb-bottom or lt>vt and vt-lt or 0
    marker.label:SetPoint(precise and 'BOTTOM' or 'CENTER',marker,precise and 'TOP' or 'CENTER',dx/ls,(precise and 2 or 0)+dy/ls)
end
local function refreshMarker()
    if not marker or not activeTarget then return placementFailed('no-selection') end
    if not WorldMapFrame or not call(WorldMapFrame.IsShown,WorldMapFrame) then return placementFailed('map-hidden-or-unavailable') end
    local target=activeTarget
    if call(WorldMapFrame.GetMapID,WorldMapFrame)~=target.uiMapID then return placementFailed('different-map') end
    local canvas=call(WorldMapFrame.GetCanvas,WorldMapFrame)
        or WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer.Child
    if not canvas then return placementFailed('canvas-unavailable') end
    if type(canvas.IsVisible)=='function' and call(canvas.IsVisible,canvas)==false then return placementFailed('canvas-hidden') end
    local width,height=call(canvas.GetWidth,canvas),call(canvas.GetHeight,canvas)
    if type(width)~='number'or type(height)~='number'or width<=0 or height<=0 then return placementFailed('canvas-size-invalid') end
    -- Forever's MapCanvas applies its zoom to Child. Native pins compensate
    -- with inverse scale AND divide their anchor offsets by the pin scale.
    -- A plain 22px child can otherwise become only a few pixels wide.
    local canvasScale=call(WorldMapFrame.GetCanvasScale,WorldMapFrame) or call(canvas.GetScale,canvas) or 1
    if type(canvasScale)~='number' or canvasScale~=canvasScale or canvasScale<=0 or canvasScale==math.huge then return placementFailed('canvas-scale-invalid') end
    local scale=type(marker.SetScale)=='function' and 1/canvasScale or 1
    marker:SetParent(canvas);marker:ClearAllPoints()
    if marker.SetScale then marker:SetScale(scale) end
    if marker.SetFrameStrata then marker:SetFrameStrata(call(canvas.GetFrameStrata,canvas) or call(WorldMapFrame.GetFrameStrata,WorldMapFrame) or 'HIGH') end
    if marker.SetFrameLevel then marker:SetFrameLevel(frameLevel(canvas)) end
    local precise=percentage(target.x) and percentage(target.y) and target.verification~="legacy-reference"
    if precise then
        marker:SetSize(28,32);marker:SetPoint("CENTER",canvas,"TOPLEFT",width*target.x/100/scale,-height*target.y/100/scale)
        marker.icon:ClearAllPoints();marker.icon:SetAllPoints();marker.icon:Show();marker.area:Hide()
        marker.qualifier:Hide()
    elseif target.bounds then
        local b=target.bounds
        if not (percentage(b.xMin) and percentage(b.xMax) and percentage(b.yMin) and percentage(b.yMax) and b.xMin<=b.xMax and b.yMin<=b.yMax) then return placementFailed('bounds-invalid') end
        marker:SetSize(math.max(2,width*(b.xMax-b.xMin)/100/scale),math.max(2,height*(b.yMax-b.yMin)/100/scale))
        marker:SetPoint("TOPLEFT",canvas,"TOPLEFT",width*b.xMin/100/scale,-height*b.yMin/100/scale)
        -- A region has no precise destination. Shade its actual footprint and
        -- label its centre as an area; never put an NPC pin at a box corner.
        marker.icon:Hide();marker.area:Show()
        marker.qualifier:SetText(target.locationKind=='conflicting-evidence' and 'Conflicting published locations' or target.locationKind=='roaming' and 'Published roaming area' or 'Approximate published area')
        marker.qualifier:Show()
    else return placementFailed('coordinates-unavailable') end
    marker.label:SetText(GetGear:GetAcquisitionMarkerLabel(target))
    marker.label:ClearAllPoints()
    marker.label:SetPoint(precise and 'BOTTOM' or 'CENTER',marker,precise and 'TOP' or 'CENTER',0,precise and 2 or 0)
    marker.label:Show()
    if marker.SetAlpha then marker:SetAlpha(1) end
    if marker.icon.SetAlpha then marker.icon:SetAlpha(1) end
    if marker.icon.SetVertexColor then marker.icon:SetVertexColor(1,1,1,1) end
    placementReason=nil
    marker:Show();fitLabel(precise);pendingAge=0;markerStatus="map";markerReason=nil
    stopReadiness();return true
end
-- Observe the native canvas lifecycle. Never replace Blizzard scripts or
-- enlist another addon's pin pool; these hooks only position our owned frame.
local function observeMethod(object,name,callback)
    if type(hooksecurefunc)=="function" and type(object[name])=="function" then
        pcall(hooksecurefunc,object,name,callback)
    end
end
attachMapHooks=function()
    local map=WorldMapFrame
    if not map then return end
    if not hookedMaps[map] and type(map.HookScript)=="function" then
        hookedMaps[map]=true
        map:HookScript('OnHide',function() hideMarker();stopReadiness() end)
        map:HookScript('OnShow',function() attachMapHooks();refreshMarker() end)
        map:HookScript('OnSizeChanged',function() attachMapHooks();refreshMarker() end)
        local function changed() attachMapHooks();refreshMarker() end
        for _,name in ipairs({'SetMapID','OnMapChanged','OnCanvasScaleChanged',
            'OnCanvasSizeChanged','OnCanvasPanChanged','RefreshAllDataProviders','ReapplyPinFrameLevels'}) do observeMethod(map,name,changed) end
    end
    local canvas=call(map.GetCanvas,map) or map.ScrollContainer and map.ScrollContainer.Child
    if canvas and not hookedCanvases[canvas] and type(canvas.HookScript)=="function" then
        hookedCanvases[canvas]=true
        canvas:HookScript('OnSizeChanged',function() refreshMarker() end)
        canvas:HookScript('OnShow',function() refreshMarker() end)
        observeMethod(canvas,'SetScale',function() refreshMarker() end)
    end
end
local function requestPendingMap()
    if pendingMapRequested or not activeTarget or not WorldMapFrame then return end
    if call(WorldMapFrame.GetMapID,WorldMapFrame)~=activeTarget.uiMapID
        and type(WorldMapFrame.SetMapID)=='function' then
        pendingMapRequested=true
        call(WorldMapFrame.SetMapID,WorldMapFrame,activeTarget.uiMapID)
    end
end
local function tick(_,dt)
    -- Bounded first-open readiness only. Once rendered there is no polling,
    -- even when the player browses another map or zooms/pans for a long time.
    if not activeTarget then stopReadiness();return end
    pendingAge=pendingAge+(dt or 0);elapsed=elapsed+(dt or 0)
    if elapsed<0.1 then return end
    elapsed=0;attachMapHooks();requestPendingMap()
    if refreshMarker() then return end
    if pendingAge>=3 then
        stopReadiness()
        if not pendingNotified then
            pendingNotified=true;markerStatus="map-pending"
            markerReason="The GetGear marker has not been displayed: the destination map or its canvas is not ready. Use these directions; placement is not confirmed."
            if GetGear.ShowAcquisitionDirections and pendingGear then
                GetGear:ShowAcquisitionDirections(pendingGear,activeTarget,pendingAnchor,markerReason)
            elseif GetGear.Say then GetGear.Say(markerReason) end
        end
    end
end
local function installMarker(target,gear,anchor)
    if type(CreateFrame)~="function" then return false end
    if not marker then
        -- The native map addon may still be loading after OpenWorldMap. Keep
        -- an owned hidden frame and independent driver until it materializes.
        marker=CreateFrame("Frame",nil,WorldMapFrame or UIParent)
        marker:EnableMouse(false)
        marker.icon=marker:CreateTexture(nil,"OVERLAY");marker.icon:SetAllPoints();marker.icon:SetTexture("Interface\\AddOns\\GetGear\\MapPin")
        marker.area=marker:CreateTexture(nil,"OVERLAY");marker.area:SetAllPoints();marker.area:SetColorTexture(1,0.75,0.15,0.28)
        marker.label=marker:CreateFontString(nil,"OVERLAY","GameFontNormalSmall");marker.label:SetPoint("BOTTOM",marker,"TOP",0,2);marker.label:SetWidth(250)
        if marker.label.SetTextColor then marker.label:SetTextColor(1,0.85,0.25,1) end
        if marker.label.SetShadowColor then marker.label:SetShadowColor(0,0,0,1);marker.label:SetShadowOffset(1,-1) end
        marker.qualifier=marker:CreateFontString(nil,'OVERLAY','GameFontNormalSmall')
        marker.qualifier:SetPoint('TOP',marker.label,'BOTTOM',0,-2);marker.qualifier:SetWidth(250)
    end
    -- An independent event frame handles native addon loading before the map
    -- exists. Readiness work is bounded; later changes are entirely event driven.
    if not driver then
        driver=CreateFrame("Frame")
        if driver.RegisterEvent then
            for _,event in ipairs({'ADDON_LOADED','UI_SCALE_CHANGED','DISPLAY_SIZE_CHANGED'}) do
                pcall(driver.RegisterEvent,driver,event)
            end
        end
        driver:SetScript('OnEvent',function()
            if activeTarget then attachMapHooks();refreshMarker() end
        end)
    end
    attachMapHooks()
    activeTarget=target;pendingGear=gear;pendingAnchor=anchor
    pendingAge=0;pendingNotified=false;pendingMapRequested=false;elapsed=0;markerStatus="map-pending";markerReason=nil
    -- Some map-opening surfaces show the frame before consuming the map ID.
    -- Request it once through the native frame when available, including after
    -- lazy loading, without redirecting later browsing or adding idle polling.
    requestPendingMap()
    local shown=refreshMarker()
    if not shown then driver:SetScript('OnUpdate',tick);driver:Show() end
    return true,shown
end

function GetGear:OpenAcquisitionMap(gear,destination,anchor,choose)
    if self.HideAcquisitionNavigation then self:HideAcquisitionNavigation() end
    local choices={}
    for _, target in ipairs(self:GetAcquisitionNavigationChoices(gear)) do
        if not target.missingLocation then choices[#choices+1]=target end
    end
    local target
    if destination then
        for _, candidate in ipairs(choices) do if candidate.id==destination or candidate==destination then target=candidate;break end end
    else target=self:GetAcquisitionMapTarget(gear) end
    if not target then
        self:ClearAcquisitionMapMarker()
        if self.ShowAcquisitionDirections and gear then
            self:ShowAcquisitionDirections(gear,nil,anchor,"This acquisition destination is no longer available. Review the current sources and select a location again.")
            return true,"directions"
        end
        return false,"missing"
    end
    if (choose or target.chooseFirst) and #choices>1 and self.ShowAcquisitionChoices then
        self:ClearAcquisitionMapMarker()
        self:ShowAcquisitionChoices(gear,choices,anchor);return true,"choices"
    end
    local function directions(reason)
        self:ClearAcquisitionMapMarker()
        if self.ShowAcquisitionDirections then self:ShowAcquisitionDirections(gear,target,anchor,reason);return true,"directions" end
        if self.Say then self.Say(reason or self:GetAcquisitionDirections(gear)) end
        return false,"directions-unavailable"
    end
    if target.chainUnresolved then
        return directions("The complete quest route is unresolved. The listed quest NPC is not a verified chain starting point; review the known stages before travelling.")
    end
    if target.kind=="fishing" and not target.x and not target.bounds then
        return directions("A published fishing zone is known, but no precise spot or school is established. Use these qualified directions; no marker was guessed.")
    end
    if type(InCombatLockdown)=="function" and InCombatLockdown() then
        return directions("Map navigation is unavailable during combat. Directions are still available.")
    end
    if target.kind=="dungeon" then
        local entrance=dungeonEntrance(target.dungeon,target)
        if not entrance then
            local definition=self:GetAcquisitionInstanceDefinition(target.dungeon)
            return directions(definition and definition.resolutionNote or 'No trustworthy outdoor entrance point is available from the client or reviewed references. Use the qualified instance directions; no portal or boss position was guessed.')
        end
        local copy={};for k,v in pairs(target) do copy[k]=v end
        -- An entrance's local ID (usually "main") is not the selected source
        -- ID. Keep both identities, including after native-coordinate upgrades,
        -- so regenerating choices on QUEST_LOG_UPDATE can find this selection.
        for k,v in pairs(entrance) do
            if k~="id" and k~="label" and k~="kind" then copy[k]=v end
        end
        copy.entranceID=entrance.id or copy.entranceID
        target=copy
    end
    local id=target.clientVerified and target.uiMapID or resolveMap(target.zone,target.uiMapID)
    if not id then return directions("The destination map could not be identified safely. No marker was placed.") end
    local b=target.bounds
    local point=percentage(target.x)and percentage(target.y)and(target.x~=0 or target.y~=0)and target.verification~='legacy-reference'
    local area=b and percentage(b.xMin)and percentage(b.xMax)and percentage(b.yMin)and percentage(b.yMax)and b.xMin<=b.xMax and b.yMin<=b.yMax
    if not point and not area then return directions('The published destination has written directions but no trustworthy marker coordinates. No point was guessed.') end
    target.uiMapID=id
    hideMarker();activeTarget=nil
    local opened=false
    if C_Map and type(C_Map.OpenWorldMap)=="function" then
        local ok,result=pcall(C_Map.OpenWorldMap,id);opened=ok and result~=false
    end
    if not opened and type(OpenWorldMap)=="function" then
        local ok,result=pcall(OpenWorldMap,id);opened=ok and result~=false
    end
    if not opened and WorldMapFrame and type(WorldMapFrame.SetMapID)=="function" then
        if type(ShowUIPanel)=="function" then pcall(ShowUIPanel,WorldMapFrame)
        elseif type(ToggleWorldMap)=="function" and not WorldMapFrame:IsShown() then pcall(ToggleWorldMap)
        elseif type(WorldMapFrame.Show)=="function" then pcall(WorldMapFrame.Show,WorldMapFrame) end
        local ok,result=pcall(WorldMapFrame.SetMapID,WorldMapFrame,id);opened=ok and result~=false
    end
    if not opened then return directions("Map-opening API unavailable; use these directions.") end
    local installed,shown=installMarker(target,gear,anchor)
    if not installed then
        return directions("Map opened. A precise marker is unavailable; use the published directions.")
    end
    return true,shown and "map" or "map-pending"
end

function GetGear:ClearAcquisitionMapMarker()
    activeTarget=nil;pendingGear=nil;pendingAnchor=nil;pendingAge=0;pendingNotified=false;markerStatus=nil;markerReason=nil;hideMarker()
    stopReadiness()
end

-- QUEST_LOG_UPDATE can fire simply from opening the map. It is not the end
-- of a vendor/drop/craft acquisition session, nor proof of quest progression.
function GetGear:RevalidateAcquisitionMapMarker()
    if not activeTarget or not activeTarget.questID or not pendingGear then return end
    local context=activeTarget.questContext
    if context and (context:match(':active$') or context:match(':turn%-in$')) then
        local on=C_QuestLog and call(C_QuestLog.IsOnQuest,activeTarget.questID)
        if type(on)~='boolean' then return end -- unavailable is not abandonment
        if on and context:match(':turn%-in$') and type(call(C_QuestLog.IsComplete,activeTarget.questID))~='boolean' then return end
    elseif context and context:match(':completed$') then
        if type(C_QuestLog and call(C_QuestLog.IsQuestFlaggedCompleted,activeTarget.questID))~='boolean' then return end
    end
    for _,choice in ipairs(self:GetAcquisitionNavigationChoices(pendingGear)) do
        if choice.id==activeTarget.id and choice.questContext==activeTarget.questContext then
            if activeTarget.kind=='active_quest' and activeTarget.label~=choice.label then
                activeTarget.label=choice.label
                if marker then marker.label:SetText(self:GetAcquisitionMarkerLabel(activeTarget)) end
            end
            return
        end
    end
    self:ClearAcquisitionMapMarker()
end
function GetGear:RefreshAcquisitionMapMarker() attachMapHooks();return refreshMarker() end
function GetGear:GetAcquisitionMarkerState() return activeTarget,marker,markerStatus,markerReason end

local function read(object,method) return object and call(object[method],object) end
local function identity(object)
    if not object then return 'nil' end
    return read(object,'GetDebugName') or read(object,'GetName') or tostring(object)
end
local function rectangle(object)
    local l,b,w,h=read(object,'GetLeft'),read(object,'GetBottom'),read(object,'GetWidth'),read(object,'GetHeight')
    local s=read(object,'GetEffectiveScale')
    if type(l)=='number' and type(b)=='number' and type(w)=='number' and type(h)=='number' and type(s)=='number' then
        return {l=l*s,b=b*s,r=(l+w)*s,t=(b+h)*s}
    end
end
local function rectText(r)
    return r and string.format('left=%.2f bottom=%.2f right=%.2f top=%.2f (screen pixels)',r.l,r.b,r.r,r.t) or 'unavailable'
end
local function intersects(a,b)
    if a and b then return a.l<b.r and a.r>b.l and a.b<b.t and a.t>b.b end
end
local function regionDiagnostics(d,prefix,region,viewport)
    d[prefix..'Shown']=read(region,'IsShown');d[prefix..'Visible']=read(region,'IsVisible')
    d[prefix..'Alpha']=read(region,'GetAlpha');d[prefix..'EffectiveAlpha']=read(region,'GetEffectiveAlpha')
    d[prefix..'Parent']=identity(read(region,'GetParent'))
    d[prefix..'Rect']=rectText(rectangle(region))
    d[prefix..'IntersectsViewport']=intersects(rectangle(region),viewport)
    d[prefix..'AnchorCount']=read(region,'GetNumPoints')
end
function GetGear:GetAcquisitionMarkerDiagnostics()
    local map=WorldMapFrame
    local canvas=map and (call(map.GetCanvas,map) or map.ScrollContainer and map.ScrollContainer.Child)
    local viewport=map and (call(map.GetCanvasContainer,map) or map.ScrollContainer or map)
    local viewRect=rectangle(viewport)
    local b=activeTarget and activeTarget.bounds
    local d={status=markerStatus or "none",reason=markerReason,mapID=map and call(map.GetMapID,map),
        selectionID=activeTarget and activeTarget.id,entranceID=activeTarget and activeTarget.entranceID,
        source=activeTarget and activeTarget.source,questID=activeTarget and activeTarget.questID,
        label=activeTarget and self:GetAcquisitionMarkerLabel(activeTarget),
        destinationMapID=activeTarget and activeTarget.uiMapID,zone=activeTarget and activeTarget.zone,
        markerShown=marker and call(marker.IsShown,marker) or false,
        markerVisible=marker and call(marker.IsVisible,marker),canvasVisible=canvas and call(canvas.IsVisible,canvas),
        canvasWidth=canvas and call(canvas.GetWidth,canvas),canvasHeight=canvas and call(canvas.GetHeight,canvas),
        canvasScale=map and call(map.GetCanvasScale,map) or canvas and call(canvas.GetScale,canvas),
        markerScale=marker and call(marker.GetScale,marker),placementFailure=placementReason,
        x=activeTarget and activeTarget.x,y=activeTarget and activeTarget.y,
        bounds=b and string.format('x=%.2f..%.2f y=%.2f..%.2f',b.xMin,b.xMax,b.yMin,b.yMax),
        locationKind=activeTarget and activeTarget.locationKind,
        canvas=identity(canvas),canvasRect=rectText(rectangle(canvas)),viewport=identity(viewport),viewportRect=rectText(viewRect),
        canvasEffectiveScale=read(canvas,'GetEffectiveScale'),markerEffectiveScale=read(marker,'GetEffectiveScale'),
        markerParent=identity(read(marker,'GetParent')),markerRect=rectText(rectangle(marker)),
        markerIntersectsViewport=intersects(rectangle(marker),viewRect),
        markerAlpha=read(marker,'GetAlpha'),markerEffectiveAlpha=read(marker,'GetEffectiveAlpha'),
        markerStrata=read(marker,'GetFrameStrata'),markerLevel=read(marker,'GetFrameLevel'),
        canvasStrata=read(canvas,'GetFrameStrata'),canvasLevel=read(canvas,'GetFrameLevel'),
        texture=marker and read(marker.icon,'GetTexture'),
        visualAcceptance='unverified; visibility flags do not prove unobscured pixels'}
    if marker and type(marker.GetPoint)=='function' then
        local ok,point,relative,relativePoint,x,y=pcall(marker.GetPoint,marker,1)
        if ok then d.anchor=tostring(point)..' -> '..identity(relative)..':'..tostring(relativePoint)..' '..tostring(x)..','..tostring(y) end
    end
    if marker then
        regionDiagnostics(d,'icon',marker.icon,viewRect);regionDiagnostics(d,'label',marker.label,viewRect)
        regionDiagnostics(d,'area',marker.area,viewRect)
        d.labelText=read(marker.label,'GetText')
        d.iconAttached=read(marker.icon,'GetParent')==marker;d.labelAttached=read(marker.label,'GetParent')==marker
        d.iconWidth=read(marker.icon,'GetWidth');d.iconHeight=read(marker.icon,'GetHeight')
        local layer,sublevel=call(marker.icon.GetDrawLayer,marker.icon)
        d.iconDrawLayer=layer and layer..':'..tostring(sublevel)
        local manager=map and call(map.GetPinFrameLevelsManager,map)
        d.nativeTopLevel=manager and call(manager.GetValidFrameLevel,manager,'PIN_FRAME_LEVEL_TOPMOST',9000)
        local cr,mr=rectangle(canvas),rectangle(marker)
        if cr and mr and activeTarget and activeTarget.x and activeTarget.y then
            local dx=(mr.l+mr.r)/2-(cr.l+(cr.r-cr.l)*activeTarget.x/100)
            local dy=(mr.b+mr.t)/2-(cr.t-(cr.t-cr.b)*activeTarget.y/100)
            d.positionErrorPixels=string.format('dx=%.2f dy=%.2f',dx,dy)
        end
    end
    return d
end
