local addonName, GetGear = ...

-- v0.5.4: acquisition audit. Existing record IDs, material recipes and character
-- SavedVariables are intentionally unchanged. Coordinates are normalized zone
-- coordinates (0-100), never instance-interior coordinates.
-- Acquisition coordinates: verified via Forever-specific reporting where possible.
-- 'classic-reference' points are visibly labelled as provisional.
local data = {
    -- Azeroth Commerce Authority vendor: these are NOT Filigreed patterns.
    [253895] = { kind="vendor", pattern="Pattern: Shadow Boots" },
    [253889] = { kind="vendor", pattern="Pattern: Pristine Boots" },
    [253919] = { kind="vendor", pattern="Pattern: Shadow Gloves" },
    [253913] = { kind="vendor", pattern="Pattern: Pristine Gloves" },
    [253931] = { kind="vendor", pattern="Pattern: Shadow Sash" },
    [253925] = { kind="vendor", pattern="Pattern: Pristine Sash" },
    [253955] = { kind="vendor", pattern="Pattern: Shadow Circlet" },
    [253967] = { kind="vendor", pattern="Pattern: Shadow Gown" },
    [253961] = { kind="vendor", pattern="Pattern: Pristine Gown" },
    [253987] = { kind="vendor", pattern="Pattern: Pristine Leggings" },
    [253993] = { kind="vendor", pattern="Pattern: Shadow Leggings" },
    -- New 140 skill tailored footwear is trainable (Forever trainer spell lists).
    [254007] = {kind="trainer",learn="Black Slippers",skillHint="Learn Black Slippers at Tailoring 140 from a qualified Tailoring trainer. Crafting requires a Spinning Wheel."},

    -- The Filigreed patterns DROP in dungeons. They are not sold by Mivin.
    [253907] = {kind="filigreed",pattern="Pattern: Filigreed Shadow Gown", info="Reported drops include Wailing Caverns and Shadowfang Keep; boss-specific rates remain uncertain."},
    [253901] = {kind="filigreed",pattern="Pattern: Filigreed Pristine Gown", info="Dungeon-drop pattern. Exact boss/location not confirmed; check dungeon loot before planning a farm."},
    [253943] = {kind="filigreed",pattern="Pattern: Filigreed Shadow Leggings", info="Reported in Blackfathom Deeps and The Stockade (rare boss drops; not guaranteed)."},
    [253981] = {kind="filigreed",pattern="Pattern: Filigreed Shadow Circlet", info="Reported in Blackfathom Deeps, The Stockade, Scarlet Monastery and Razorfen Kraul (rare drops)."},

    -- Trainer recipes; use Ironforge trainer as an optional navigation target.
    [4318] = {kind="trainer", learn="Gloves of Meditation", skillHint="Check Tailoring trainer's offered recipes; require sufficient skill."},
    [5542] = {kind="trainer", learn="Pearl-clasped Cloak", skillHint="Taught by a Tailoring trainer."},
    [4320] = {kind="trainer", learn="Spidersilk Boots", skillHint="Taught by a Tailoring trainer."},

    -- Acquisition routes. Targets are where to START, not the final hand-in.
    [7001] = {kind="quest", start="In Search of Thaelrid", startNote="Dawnwatcher Shaedlass, Craftsmen's Terrace, Darnassus; then find Thaelrid in Blackfathom Deeps for Blackfathom Villainy.", location={zone="Darnassus", x=55.4,y=25.0, spot="Dawnwatcher Shaedlass", quality="forever"}},
    [2042] = {kind="quest", start="The Defias Brotherhood", startNote="Gryan Stoutmantle at Sentinel Hill. Complete the chain and defeat VanCleef for the reward choice; verify the actual reward in Forever.", location={zone="Westfall",x=56.3,y=47.5,spot="Gryan Stoutmantle",quality="forever"}},
    [2933] = {kind="quest", start="The Unsent Letter", startNote="The chain starts from An Unsent Letter, dropped by Edwin VanCleef in the Deadmines. The ring is awarded much later, after the Stockade quest chain.", location={zone="Westfall",x=42.5,y=71.5,spot="Deadmines surface entrance (VanCleef drops the starter)",quality="forever"}},
    [279898] = {kind="quest", start="Important Heirlooms", startNote="Thom Filch near Hall of Thanes in Ironforge. Collect Dwarven Heirlooms; reward choice includes Dwarven Tome.", location={zone="Ironforge",x=32.0,y=45.0,spot="Thom Filch",quality="forever"}},
    [1449] = {kind="quest", start="WANTED: Chok'sul",startNote="Wanted notice at Thelsamar, Loch Modan; reward observed in Forever, coordinates inherited from Classic and require field confirmation.",location={zone="Loch Modan",x=37.3,y=46.5,spot="WANTED notice",quality="classic-reference"}},
    [8071] = {kind="quest", start="Deviate Eradication",startNote="Ebru inside the cave system above Wailing Caverns. The map pin shows the surface cave entrance, not the questgiver itself.",location={zone="The Barrens",x=45.97,y=36.34,spot="Wailing Caverns cave entrance (Ebru is inside)",quality="classic-reference"}},

    -- Dungeon buttons navigate to surface entrances, not an interior boss pin.
    [5198] = {kind="dungeon", entrance="Deadmines"},
    [5202] = {kind="dungeon", entrance="Deadmines"},
    [6903] = {kind="dungeon", entrance="Blackfathom Deeps"},
    [6908] = {kind="dungeon", entrance="Blackfathom Deeps"},
    [6695] = {kind="dungeon", entrance="Razorfen Kraul"},
    [7684] = {kind="dungeon", entrance="Scarlet Monastery"},
    [7709] = {kind="dungeon", entrance="Scarlet Monastery"},
    [23169] = {kind="dungeon", entrance="Scarlet Monastery"},
    [20099] = {kind="reputation", location={zone="Arathi Highlands",x=46.0,y=45.2,spot="Samuel Hawke, League of Arathor quartermaster",quality="classic-reference"},info="Requires League of Arathor Honored; quartermaster position is a Classic reference."},
}

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

local entrances = {
    ["Deadmines"] = {zone="Westfall",x=42.5,y=71.5,spot="Deadmines surface entrance, Moonbrook",quality="forever"},
    ["Blackfathom Deeps"] = {zone="Ashenvale",x=14.5,y=14.6,spot="Blackfathom Deeps outer ruins, Zoram Strand",quality="forever"},
    ["Razorfen Kraul"] = {zone="The Barrens",x=42.3,y=89.9,spot="Razorfen Kraul dungeon entrance",quality="forever"},
    -- Source confirms zone but currently not an exact sufficiently reliable coordinate.
    ["Scarlet Monastery"] = {zone="Tirisfal Glades",spot="Scarlet Monastery, northeast Tirisfal Glades",quality="zone-only"},
}

local merchant = {zone="Redridge Mountains",x=10.0,y=73.0,spot="Mivin Shadowweave, Three Corners",quality="forever"}
local tailor = {zone="Ironforge",x=43.1,y=29.4,spot="Jormund Stonebrow, Tailoring trainer",quality="classic-reference"}

local audited = {}
for _,gear in ipairs(GetGear.Gear) do
    local details=data[gear.itemID]
    if details then
        audited[#audited+1]=gear.itemID
        local kind=details.kind
        if kind=="vendor" then
            gear.source=details.pattern .. " - Azeroth Commerce Authority"
            gear.zone="Three Corners, Redridge Mountains"
            gear.instructions="Buy "..details.pattern.." from Mivin Shadowweave at Three Corners (10.0, 73.0) for 30 Merchant's Favor, then craft with Tailoring. No additional reputation rank listed for this pattern."
            gear.acquisitionLocation=merchant
            gear.acquisitionKind="Vendor"
            gear.acquisitionConfidence="forever"
            -- Clear older notes that incorrectly describe a known vendor pattern
            -- as unconfirmed. Acquisition details belong in instructions.
            if gear.notes then
                gear.notes=gear.notes:gsub("; the pattern source needs confirmation%.", ".")
                gear.notes=gear.notes:gsub(", if the pattern is available%.", ".")
            end
        elseif kind=="filigreed" then
            gear.source=details.pattern .. " - dungeon drop / Auction House"
            gear.zone="Dungeon loot / Auction House (if tradeable)"
            gear.instructions="Obtain "..details.pattern.." from dungeon loot; also check the Auction House for a tradable copy. "..details.info.." This is not an Azeroth Commerce Authority vendor pattern. The crafted equipment binds on pickup."
            gear.acquisitionKind="Dungeon pattern drop"
            gear.acquisitionConfidence="reported"
            if gear.notes then
                gear.notes=gear.notes:gsub("recipe acquisition not confirmed", "specific dungeon boss drop not confirmed")
            end
            -- Do not misdirect to a particular boss: no reliable fixed starter.
        elseif kind=="trainer" then
            gear.source="Tailoring trainer: "..details.learn
            gear.zone="Tailoring trainers; Ironforge option"
            gear.instructions=details.skillHint .. " Jormund Stonebrow in Ironforge is an Alliance trainer option."
            gear.acquisitionLocation=tailor
            gear.acquisitionKind="Trainer"
            gear.acquisitionConfidence="classic-reference"
        elseif kind=="quest" then
            gear.source=details.start
            gear.instructions=details.startNote
            gear.acquisitionLocation=details.location
            gear.acquisitionKind="Quest start"
            gear.acquisitionLocationConfidence=details.location.quality
            -- A questgiver/map pin is navigation, not proof of this reward.
            gear.acquisitionConfidence=(gear.confidence=="classic-reference")
                and "classic-reference" or (gear.confidence or "unknown")
            gear.questStart=details.start
        elseif kind=="dungeon" then
            gear.acquisitionLocation=entrances[details.entrance]
            gear.acquisitionKind="Dungeon entrance"
            gear.acquisitionLocationConfidence=entrances[details.entrance] and entrances[details.entrance].quality
            -- The boss drop's existing evidence tier is authoritative, not
            -- the reliability of the dungeon's entrance coordinates.
            gear.acquisitionConfidence=gear.confidence or "unknown"
        elseif kind=="reputation" then
            gear.acquisitionLocation=details.location
            gear.acquisitionKind="Reputation vendor"
            gear.acquisitionLocationConfidence=details.location.quality
            gear.acquisitionConfidence=gear.confidence or "unknown"
            gear.instructions=details.info
        end
    else
        -- Preserve original source information without implying that an
        -- item being present in the client verifies its acquisition source.
        gear.acquisitionKind=gear.sourceType
        gear.acquisitionConfidence=gear.confidence or "unknown"
    end
end
GetGear.AcquisitionAudit = { updated=audited, version="0.5.4" }

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
