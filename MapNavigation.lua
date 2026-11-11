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
    if explicit and valid(explicit) then return explicit end
    local maps=(GetGear.AcquisitionNavigationData or {}).maps or {}
    for _, id in ipairs(maps[zone] or {}) do if valid(id) then return id end end
    for _, id in ipairs(fallbackMaps[zone] or {}) do if valid(id) then return id end end
    -- New researched zones do not require another UI-specific ID table.
    discoverMaps()
    local id=mapNameIndex[cleanName(zone)]
    if id then return valid(id) end
end

local entranceIndex
function GetGear:ResetAcquisitionNavigation()
    entranceIndex=nil;mapNameIndex=nil
    if self.ClearAcquisitionMapMarker then self:ClearAcquisitionMapMarker() end
end
local aliases={stockade="stormwindstockade",sunkentemple="templeofatalhakkar"}
local function dungeonKey(name) local key=cleanName(name);return aliases[key] or key end
local function position(point)
    if not point then return end
    local x,y
    if type(point.GetXY)=="function" then x,y=call(point.GetXY,point) else x,y=point.x,point.y end
    if normalized(x) and normalized(y) then return x*100,y*100 end
end
local function dungeonEntrance(name)
    if not C_EncounterJournal or type(C_EncounterJournal.GetDungeonEntrancesForMap)~="function" then return end
    if not entranceIndex then
        entranceIndex={}
        local maps,roots={},{}
        for zone in pairs((GetGear.AcquisitionNavigationData or {}).maps or {}) do
            local id=resolveMap(zone);if id then maps[id]=true end
        end
        for zone in pairs(fallbackMaps) do local id=resolveMap(zone);if id then maps[id]=true end end
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
            for _, entry in ipairs(call(C_EncounterJournal.GetDungeonEntrancesForMap,id) or {}) do
                local x,y=position(entry.position)
                if x and entry.name then
                    local info=mapInfo(id)
                    entranceIndex[dungeonKey(entry.name)]={zone=info and info.name,uiMapID=id,x=x,y=y,
                        clientVerified=true,verification="client",label=entry.name.." entrance",kind="dungeon"}
                end
            end
        end
    end
    return entranceIndex[dungeonKey(name)]
end

local marker,activeTarget,elapsed=nil,nil,0
local function hideMarker() if marker then marker:Hide() end end
local function refreshMarker()
    if not marker or not activeTarget or not WorldMapFrame or not WorldMapFrame:IsShown() then hideMarker();return end
    local target=activeTarget
    if call(WorldMapFrame.GetMapID,WorldMapFrame)~=target.uiMapID then hideMarker();return end
    local canvas=call(WorldMapFrame.GetCanvas,WorldMapFrame)
    if not canvas then hideMarker();return end
    local width,height=canvas:GetWidth(),canvas:GetHeight()
    if width<=0 or height<=0 then hideMarker();return end
    marker:SetParent(canvas);marker:ClearAllPoints()
    if marker.SetFrameLevel and canvas.GetFrameLevel then marker:SetFrameLevel(canvas:GetFrameLevel()+20) end
    local precise=percentage(target.x) and percentage(target.y) and target.verification~="legacy-reference"
    if precise then
        marker:SetSize(22,26);marker:SetPoint("CENTER",canvas,"TOPLEFT",width*target.x/100,-height*target.y/100)
        marker.icon:Show();marker.area:Hide()
    elseif target.bounds then
        local b=target.bounds
        if not (percentage(b.xMin) and percentage(b.xMax) and percentage(b.yMin) and percentage(b.yMax)) then hideMarker();return end
        marker:SetSize(math.max(2,width*(b.xMax-b.xMin)/100),math.max(2,height*(b.yMax-b.yMin)/100))
        marker:SetPoint("TOPLEFT",canvas,"TOPLEFT",width*b.xMin/100,-height*b.yMin/100)
        marker.icon:Hide();marker.area:Show()
    else hideMarker();return end
    marker.label:SetText("GetGear: "..(target.label or target.zone or "Destination")..(precise and "" or " (published area)"))
    marker:Show()
end
local function installMarker(target)
    if not WorldMapFrame or type(CreateFrame)~="function" or type(WorldMapFrame.GetCanvas)~="function" then return false end
    if not marker then
        marker=CreateFrame("Frame",nil,WorldMapFrame)
        marker:EnableMouse(false)
        marker.icon=marker:CreateTexture(nil,"OVERLAY");marker.icon:SetAllPoints();marker.icon:SetTexture("Interface\\AddOns\\GetGear\\MapPin")
        marker.area=marker:CreateTexture(nil,"OVERLAY");marker.area:SetAllPoints();marker.area:SetColorTexture(1,0.75,0.15,0.28)
        marker.label=marker:CreateFontString(nil,"OVERLAY","GameFontNormalSmall");marker.label:SetPoint("BOTTOM",marker,"TOP",0,2);marker.label:SetWidth(250)
        marker:SetScript("OnUpdate",function(_,dt) elapsed=elapsed+dt;if elapsed>=0.1 then elapsed=0;refreshMarker() end end)
        if type(WorldMapFrame.HookScript)=="function" then
            WorldMapFrame:HookScript("OnHide",function() activeTarget=nil;hideMarker() end)
            WorldMapFrame:HookScript("OnUpdate",function(_,dt)
                if activeTarget and not marker:IsShown() then
                    elapsed=elapsed+dt;if elapsed>=0.1 then elapsed=0;refreshMarker() end
                end
            end)
        end
    end
    activeTarget=target;refreshMarker()
    return marker:IsShown()
end

function GetGear:OpenAcquisitionMap(gear,destination,anchor,choose)
    local choices={}
    for _, target in ipairs(self:GetAcquisitionNavigationChoices(gear)) do
        if not target.missingLocation then choices[#choices+1]=target end
    end
    local target
    if destination then
        for _, candidate in ipairs(choices) do if candidate.id==destination or candidate==destination then target=candidate;break end end
    else target=self:GetAcquisitionMapTarget(gear) end
    if not target then return false,"missing" end
    if (choose or target.chooseFirst) and #choices>1 and self.ShowAcquisitionChoices then
        self:ShowAcquisitionChoices(gear,choices,anchor);return true,"choices"
    end
    local function directions(reason)
        self:ClearAcquisitionMapMarker()
        if self.ShowAcquisitionDirections then self:ShowAcquisitionDirections(gear,target,anchor,reason);return true,"directions" end
        if self.Say then self.Say(reason or self:GetAcquisitionDirections(gear)) end
        return false,"directions-unavailable"
    end
    if type(InCombatLockdown)=="function" and InCombatLockdown() then
        return directions("Map navigation is unavailable during combat. Directions are still available.")
    end
    if target.kind=="dungeon" then
        local entrance=dungeonEntrance(target.dungeon)
        if not entrance then return directions("A precise entrance is not available from this client. No marker was guessed.") end
        local copy={};for k,v in pairs(target) do copy[k]=v end
        for k,v in pairs(entrance) do copy[k]=v end
        target=copy
    end
    local id=target.clientVerified and target.uiMapID or resolveMap(target.zone,target.uiMapID)
    if not id then return directions("The destination map could not be identified safely. No marker was placed.") end
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
        elseif type(ToggleWorldMap)=="function" and not WorldMapFrame:IsShown() then pcall(ToggleWorldMap) end
        local ok,result=pcall(WorldMapFrame.SetMapID,WorldMapFrame,id);opened=ok and result~=false
    end
    if not opened then return directions("Map-opening API unavailable; use these directions.") end
    local shown=installMarker(target)
    if not shown then
        return directions("Map opened. A precise marker is unavailable; use the published directions.")
    end
    return true,"map"
end

function GetGear:ClearAcquisitionMapMarker() activeTarget=nil;hideMarker() end
function GetGear:GetAcquisitionMarkerState() return activeTarget,marker end
