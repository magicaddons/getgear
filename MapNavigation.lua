local addonName, GetGear = ...

-- Runtime map navigation only. Source/quest/coordinate evidence is in
-- ResearchedItemFacts; the historical patch layers are not executed.
local mapIDs = {
    ["Dun Morogh"]={27,1426,1245},
    ["Orgrimmar"]={85,1454,1250},
    ["Redridge Mountains"]={49,1433,1260},
    ["Westfall"]={52,1436,1262},
    ["Darnassus"]={89,1457,1324},
    ["Ironforge"]={87,1455,1265},
    ["Loch Modan"]={48,1432,1259},
    ["The Barrens"]={10,1413,11},
    ["Blackfathom Deeps"]={},
    ["Ashenvale"]={63,1440},
    ["Razorfen Kraul"]={},
    ["Tirisfal Glades"]={18,1420},
    ["Wetlands"]={56,1437},
    ["Silverpine Forest"]={21,1421},
    ["Arathi Highlands"]={14,1417},
}


local function ResolveUiMapID(zone)
    if not C_Map or type(C_Map.GetMapInfo)~="function" then return nil end
    local options=mapIDs[zone]
    if not options then return nil end
    for _, candidate in ipairs(options) do
        local info=C_Map.GetMapInfo(candidate)
        if info and info.name and info.name:lower()==zone:lower() then return candidate end
    end
    return nil
end

function GetGear:GetAcquisitionMapTarget(gear)
    local dest=gear and gear.acquisitionLocation
    if type(dest)~="table" or not dest.zone then return nil end
    -- Location may still be useful as a zone-only map opening.
    return dest
end

function GetGear:OpenAcquisitionMap(gear)
    local dest=self:GetAcquisitionMapTarget(gear)
    if not dest then return false end
    if type(InCombatLockdown)=="function" and InCombatLockdown() then
        if self.Say then self.Say("Open the map after leaving combat.") end
        return false
    end
    local id=ResolveUiMapID(dest.zone)
    if not id then
        if self.Say then self.Say("Could not identify Forever map for "..dest.zone.."; check location in the item description.") end
        return false
    end
    local placed=false
    if dest.x and dest.y and C_Map and type(C_Map.SetUserWaypoint)=="function"
       and UiMapPoint and type(UiMapPoint.CreateFromCoordinates)=="function" then
        local allowed=not C_Map.CanSetUserWaypointOnMap or C_Map.CanSetUserWaypointOnMap(id)
        if allowed then
            local pt=UiMapPoint.CreateFromCoordinates(id,dest.x/100,dest.y/100)
            if pt then
                -- The API may return no value on success; a nil return is
                -- not evidence of failure. A protected call also guards
                -- beta-client differences in the waypoint signature.
                local ok, result=pcall(C_Map.SetUserWaypoint,pt)
                placed=ok and result~=false
            end
        end
    end
    if C_Map and type(C_Map.OpenWorldMap)=="function" then
        C_Map.OpenWorldMap(id)
    elseif WorldMapFrame and type(WorldMapFrame.SetMapID)=="function" then
        if type(ToggleWorldMap)=="function" and not WorldMapFrame:IsShown() then ToggleWorldMap() end
        WorldMapFrame:SetMapID(id)
    else
        if self.Say then self.Say("Map-opening API unavailable in this client.") end
        return false
    end
    if self.Say then
        local spot=dest.spot or dest.zone
        local coord=dest.x and (" ("..string.format("%.1f",dest.x)..", "..string.format("%.1f",dest.y)..")") or ""
        self.Say("Map: "..spot..coord..(dest.quality=="classic-reference" and " [Classic coordinates: confirm in Forever]" or "")..(placed and " - waypoint set." or " - zone opened (no waypoint available)."))
    end
    return true
end
