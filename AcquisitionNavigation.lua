local _, GetGear = ...

-- Shared, read-only acquisition plans. Character quest progress is queried,
-- never inferred from equipment status or another character's completion.
local function data() return GetGear.AcquisitionNavigationData or {items={},sources={},quests={},chains={}} end
local function get(t,id) return t and (t[id] or t[tostring(id)]) end
-- Names are structured facts, never the result of splitting descriptive text.
-- In particular, a comma or parenthesis may be part of an NPC's real name.
function GetGear:GetAcquisitionNPCName(target)
    if not target then return end
    if type(target.npcName)=="string" and target.npcName~="" then return target.npcName end
    local key=target.source
    local actor=key and (data().sources or {})[key]
    if actor and (actor.kind=="npc" or tostring(key):match("^npc:%d+$")
        or tostring(key):match("^bagquest:%d+:1:%d+$")) then return actor.name end
    return (data().npcLabels or {})[(target.zone or '')..'|'..(target.label or '')]
end
-- BEGIN GENERATED NAVIGATION REVIEW
-- Published references only; native client entrances take precedence.
do
local model=GetGear.AcquisitionNavigationData
if model then
model.npcLabels={["Arathi Highlands|Samuel Hawke, League of Arathor quartermaster"]="Samuel Hawke",["Ironforge|Granny Finespindle, Leatherworking patterns"]="Granny Finespindle",["Ironforge|Granny Finespindle: Leatherworking patterns (verify stock)"]="Granny Finespindle",["Ironforge|Jormund Stonebrow, Tailoring trainer"]="Jormund Stonebrow",["Ironforge|Thom Filch"]="Thom Filch",["Redridge Mountains|Alynsia, ACA Enchanting formulas, Three Corners"]="Alynsia",["Redridge Mountains|Alynsia, ACA formula"]="Alynsia",["Redridge Mountains|Daniel Stitchsong, ACA Leatherworking patterns, Three Corners"]="Daniel Stitchsong",["Redridge Mountains|Mivin Shadowweave, Azeroth Commerce Authority"]="Mivin Shadowweave",["Redridge Mountains|Mivin Shadowweave, Three Corners"]="Mivin Shadowweave",["Redridge Mountains|Stondry Darkhammer, ACA Blacksmithing patterns, Three Corners"]="Stondry Darkhammer",["Redridge Mountains|Stondry Darkhammer, ACA plans"]="Stondry Darkhammer",["The Barrens|Doan Karhan"]="Doan Karhan",["Westfall|Gryan Stoutmantle"]="Gryan Stoutmantle"}
local definitions={["Ahn'Qiraj"]={["availability"]="client-listed-current-availability-unconfirmed",["canonicalName"]="Ahn'Qiraj",["entrances"]={},["evidence"]={["file"]="checkpoint8cd_working_evidence.json",["sha256"]="b184eb6baf5b8e338f6debb14c3f9af851198cc5f2caa3cd70e6c0c23570f263",["url"]="https://www.wowhead.com/forever/zone=3428"},["instructions"]="Published instance source. Open the client-resolved entrance if available;exact boss floor/wing,keys,current access and group requirements remain unverified. No invented floor coordinate.",["legacyApproachLabels"]={},["resolutionNote"]="Published route information exists; precise exterior coordinates remain under review. Published instance source. Open the client-resolved entrance if available;exact boss floor/wing,keys,current access and group requirements remain unverified. No invented floor coordinate."},["Ahn'Qiraj Temple"]={["availability"]="client-listed-current-availability-unconfirmed",["canonicalName"]="Ahn'Qiraj Temple",["entrances"]={},["evidence"]={},["instructions"]="Historical raid/client-listed data, current Forever availability unannounced in reviewed official roster. Keep separate from Ruins of Ahn'Qiraj; current exact portal/access remains unverified.",["legacyApproachLabels"]={},["resolutionNote"]="Published route information exists; precise exterior coordinates remain under review. Historical raid/client-listed data, current Forever availability unannounced in reviewed official roster. Keep separate from Ruins of Ahn'Qiraj; current exact portal/access remains unverified."},["Alcaz Prison"]={["availability"]="published-dungeon",["canonicalName"]="Alcaz Prison",["entrances"]={{["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=125720,["kind"]="published-forever-reference",["liveVerified"]=false,["retrieved"]="2026-11-18",["sha256"]="013deafde8c1823872b61eb57c81e39003125a8c3f0955ee6a0f9e6aa5218ffe",["url"]="https://www.wowhead.com/forever/guide/alcaz-prison-dungeon-overview-location-rewards"},["id"]="keep",["instructions"]="Published exterior reference. Verify exact portal position and current access in the Forever client.",["label"]="Alcaz Prison: keep approach",["uiMapID"]=1445,["verification"]="published-reference",["x"]=75,["y"]=15,["zone"]="Dustwallow Marsh"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Take the western landing onto Alcaz Island, go to the northern keep, and descend into its basement for the portal. The outdoor map point marks the keep approach, not a basement floor coordinate.",["legacyApproachLabels"]={}},["Blackfathom Deeps"]={["availability"]="published-dungeon",["canonicalName"]="Blackfathom Deeps",["entrances"]={{["areaID"]=331,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="main",["instructions"]="Along the Zoram Strand Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["label"]="Blackfathom Deeps — published outdoor approach",["uiMapID"]=1440,["verification"]="published-reference",["x"]=13.4,["y"]=12.8,["zone"]="Ashenvale"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Along the Zoram Strand Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check. Legacy GetGear outdoor reference14.5,14.6 and this guide13.4,12.8 describe qualified Zoram Strand approaches,not independent boss destinations;original source coordinates remain in the catalogue. The practical entrance selector uses the canonical guide approach. Current portal placement must be checked in game.",["legacyApproachLabels"]={"Blackfathom Deeps outer ruins, Zoram Strand"}},["Blackmaw Hold"]={["availability"]="published-dungeon",["canonicalName"]="Blackmaw Hold",["entrances"]={},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Behind the Furbolg Gates in North Azshara Published entrance region: Azshara. No trustworthy entrance coordinates in this full guide. Current opening/access unverified.",["legacyApproachLabels"]={},["resolutionNote"]="Published route information exists; precise exterior coordinates remain under review. Behind the Furbolg Gates in North Azshara Published entrance region: Azshara. No trustworthy entrance coordinates in this full guide. Current opening/access unverified."},["Blackrock Depths"]={["availability"]="published-dungeon",["canonicalName"]="Blackrock Depths",["entrances"]={{["areaID"]=51,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="main",["instructions"]="Inside Blackrock Mountain Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["label"]="Blackrock Depths — Blackrock Mountain (published approach)",["uiMapID"]=1427,["verification"]="published-reference",["x"]=35.2,["y"]=84.2,["zone"]="Searing Gorge"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Inside Blackrock Mountain Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["legacyApproachLabels"]={}},["Blackrock Spire"]={["availability"]="published-dungeon",["canonicalName"]="Blackrock Spire",["entrances"]={{["areaID"]=51,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="main",["instructions"]="Inside Blackrock Mountain Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["label"]="Blackrock Spire — Blackrock Mountain (published approach)",["uiMapID"]=1427,["verification"]="published-reference",["x"]=35.2,["y"]=84.2,["zone"]="Searing Gorge"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Inside Blackrock Mountain Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["legacyApproachLabels"]={}},["Blackwing Lair"]={["availability"]="client-listed-current-availability-unconfirmed",["canonicalName"]="Blackwing Lair",["entrances"]={},["evidence"]={["file"]="checkpoint8cd_working_evidence.json",["sha256"]="438cbb40e87c4a4af0e94519ee0517a0fe95b02fa3cfa542093b69ceaffd1c6d",["url"]="https://www.wowhead.com/forever/zone=2677"},["instructions"]="Published transport reference: obtain Blackhand's Command letter #18987 from Scarshield Quartermaster #9046 (Classic-qualified full join),read it to start #7761,minimum55/Both. Touch Drakkisath's Brand by General Drakkisath in Blackrock Spire for the Orb of Command teleport path. Raw brand0,0 is not a map point. Current mandatory attunement,alternative access and earlier unlocks unverified;client entrance only,not a boss floor point.",["legacyApproachLabels"]={},["resolutionNote"]="Published route information exists; precise exterior coordinates remain under review. Published transport reference: obtain Blackhand's Command letter #18987 from Scarshield Quartermaster #9046 (Classic-qualified full join),read it to start #7761,minimum55/Both. Touch Drakkisath's Brand by General Drakkisath in Blackrock Spire for the Orb of Command teleport path. Raw brand0,0 is not a map point. Current mandatory attunement,alternative access and earlier unlocks unverified;client entrance only,not a boss floor point."},["City of Dalaran"]={["availability"]="published-dungeon",["canonicalName"]="City of Dalaran",["entrances"]={{["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=165134,["kind"]="published-forever-reference",["liveVerified"]=false,["retrieved"]="2026-11-18",["sha256"]="a43292b6f18f636190999d2271f9ba56c87d8d7a3a7b4ed4389e1d48432836e7",["url"]="https://www.wowhead.com/forever/guide/city-of-dalaran-dungeon-overview-location-rewards"},["id"]="alterac-approach",["instructions"]="Published exterior reference. Verify exact portal position and current access in the Forever client.",["label"]="Dalaran: Alterac approach",["uiMapID"]=1416,["verification"]="published-reference",["x"]=8,["y"]=61.2,["zone"]="Alterac Mountains"},{["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=165134,["kind"]="published-forever-reference",["liveVerified"]=false,["retrieved"]="2026-11-18",["sha256"]="a43292b6f18f636190999d2271f9ba56c87d8d7a3a7b4ed4389e1d48432836e7",["url"]="https://www.wowhead.com/forever/guide/city-of-dalaran-dungeon-overview-location-rewards"},["id"]="silverpine-approach",["instructions"]="Published exterior reference. Verify exact portal position and current access in the Forever client.",["label"]="Dalaran: Silverpine approach",["uiMapID"]=1421,["verification"]="published-reference",["x"]=63.5,["y"]=64,["zone"]="Silverpine Forest"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Primary guide map pins distinguish Alterac Mountains 8,61.2 and Silverpine Forest 63.5,64. The guide contains contradictory faction wording; these are qualified approaches, not a guarantee of either faction's access. Review the Dalaran Sewer Key/teleport route in the client.",["legacyApproachLabels"]={}},["Deadmines"]={["availability"]="published-dungeon",["canonicalName"]="Deadmines",["entrances"]={{["areaID"]=40,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="main",["instructions"]="Inside a building in Moonbrook Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["label"]="Deadmines — published outdoor approach",["uiMapID"]=1436,["verification"]="published-reference",["x"]=42.4,["y"]=70.4,["zone"]="Westfall"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Inside a building in Moonbrook Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["legacyApproachLabels"]={}},["Dire Maul"]={["availability"]="published-dungeon",["canonicalName"]="Dire Maul",["entrances"]={{["areaID"]=357,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="east",["instructions"]="This is the shared outdoor approach, not the East portal. Continue inside following the East route; exact wing-door coordinates are not independently verified.",["label"]="Dire Maul: East — shared exterior approach",["routeInstructionsOnly"]=true,["uiMapID"]=1444,["verification"]="published-reference",["x"]=58.9,["y"]=41.5,["zone"]="Feralas"},{["areaID"]=357,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="west",["instructions"]="This is the shared outdoor approach, not the West portal. Continue inside following the West route; exact wing-door coordinates are not independently verified.",["label"]="Dire Maul: West — shared exterior approach",["routeInstructionsOnly"]=true,["uiMapID"]=1444,["verification"]="published-reference",["x"]=58.9,["y"]=41.5,["zone"]="Feralas"},{["areaID"]=357,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="north",["instructions"]="This is the shared outdoor approach, not the North portal. Continue inside following the North route; exact wing-door coordinates are not independently verified.",["label"]="Dire Maul: North — shared exterior approach",["routeInstructionsOnly"]=true,["uiMapID"]=1444,["verification"]="published-reference",["x"]=58.9,["y"]=41.5,["zone"]="Feralas"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check. The distinct wing choices retain the common outdoor approach and written route; no separate portal coordinates are invented.",["legacyApproachLabels"]={}},["Excavation Site: Wetlands"]={["availability"]="published-dungeon",["canonicalName"]="Excavation Site: Wetlands",["entrances"]={{["coordinateKind"]="exterior-portal-reference",["evidence"]={["bytes"]=131454,["kind"]="published-forever-reference",["liveVerified"]=false,["retrieved"]="2026-11-18",["sha256"]="2d522245ebbdb1071a394b49f1a50fa88cc227ff20973eec74e13598cfd5ccf3",["url"]="https://www.wowhead.com/forever/guide/excavation-site-wetlands-dungeon-overview-location-rewards"},["id"]="portal-reference",["instructions"]="Individual primary guide map area 11 explicitly labels this as Entrance to Excavation Site. Follow the new path uphill; this is distinct from the meeting stone.",["label"]="Excavation Site: entrance",["uiMapID"]=1437,["verification"]="published-reference",["x"]=47.8,["y"]=56.3,["zone"]="Wetlands"},{["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=131454,["kind"]="published-forever-reference",["liveVerified"]=false,["retrieved"]="2026-11-18",["sha256"]="2d522245ebbdb1071a394b49f1a50fa88cc227ff20973eec74e13598cfd5ccf3",["url"]="https://www.wowhead.com/forever/guide/excavation-site-wetlands-dungeon-overview-location-rewards"},["id"]="meeting-stone",["instructions"]="Individual primary guide labels this Meeting Stone and Entry. Begin the uphill road near Thelgen Rock/Dun Algaz; continue to the separate entrance.",["label"]="Excavation Site: meeting-stone approach",["uiMapID"]=1437,["verification"]="published-reference",["x"]=53.4,["y"]=65.3,["zone"]="Wetlands"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Near Thelgen Rock and Dun Algaz, take the new road up into the hills southeast of Whelgar excavation. The individual Wowhead map supplies two separate points omitted from the overview. ForeverDB 24.5,73.4 is an inferred portal-model match and conflicts; it is withheld.",["legacyApproachLabels"]={}},["Gnomeregan"]={["availability"]="published-dungeon",["canonicalName"]="Gnomeregan",["entrances"]={{["areaID"]=1,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="main",["instructions"]="Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["label"]="Gnomeregan — published outdoor approach",["uiMapID"]=1426,["verification"]="published-reference",["x"]=30.5,["y"]=36.3,["zone"]="Dun Morogh"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["legacyApproachLabels"]={}},["Hyjal Summit"]={["availability"]="announced-raid-client-acceptance-pending",["canonicalName"]="Hyjal Summit",["entrances"]={},["evidence"]={},["instructions"]="Official raid roster includes this raid. Mount Hyjal entrance is not established by the primary overview. Anonymous beta-comment coordinates 89,32 are unverified and are not accepted.",["legacyApproachLabels"]={},["resolutionNote"]="Published route information exists; precise exterior coordinates remain under review. Official raid roster includes this raid. Mount Hyjal entrance is not established by the primary overview. Anonymous beta-comment coordinates 89,32 are unverified and are not accepted."},["Krol'dok Stronghold"]={["availability"]="published-dungeon",["canonicalName"]="Krol'dok Stronghold",["entrances"]={{["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=125910,["kind"]="published-forever-reference",["liveVerified"]=false,["retrieved"]="2026-11-18",["sha256"]="12797a5050af2c3de7c207f2f4153720a3eec4cc98745520770d598a03af37d7",["url"]="https://www.wowhead.com/forever/guide/kroldok-stronghold-dungeon-overview-location-rewards"},["id"]="main",["instructions"]="Published exterior reference. Verify exact portal position and current access in the Forever client.",["label"]="Krol'dok Stronghold approach",["uiMapID"]=2548,["verification"]="published-reference",["x"]=39,["y"]=39,["zone"]="Riverglades"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="The primary guide map area 16591 labels an entrance at Riverglades 39,39, north of Sunnyglade near the closed city gates. Community guides place the cave around 37–37.5,37–37.9. Use the approach and verify the cave; no UI map ID is inferred from area ID 16591.",["legacyApproachLabels"]={}},["Maraudon"]={["availability"]="published-dungeon",["canonicalName"]="Maraudon",["entrances"]={{["areaID"]=405,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="orange",["instructions"]="This is the shared outdoor approach, not the Orange portal. Continue inside following the Orange route; exact wing-door coordinates are not independently verified.",["label"]="Maraudon: Orange — shared exterior approach",["routeInstructionsOnly"]=true,["uiMapID"]=1443,["verification"]="published-reference",["x"]=29.5,["y"]=57.8,["zone"]="Desolace"},{["areaID"]=405,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="purple",["instructions"]="This is the shared outdoor approach, not the Purple portal. Continue inside following the Purple route; exact wing-door coordinates are not independently verified.",["label"]="Maraudon: Purple — shared exterior approach",["routeInstructionsOnly"]=true,["uiMapID"]=1443,["verification"]="published-reference",["x"]=29.5,["y"]=57.8,["zone"]="Desolace"},{["areaID"]=405,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="inner-falls",["instructions"]="This is the shared outdoor approach, not the Inner falls portal. Continue inside following the Inner falls route; exact wing-door coordinates are not independently verified.",["label"]="Maraudon: Inner falls — shared exterior approach",["routeInstructionsOnly"]=true,["uiMapID"]=1443,["verification"]="published-reference",["x"]=29.5,["y"]=57.8,["zone"]="Desolace"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check. The distinct wing choices retain the common outdoor approach and written route; no separate portal coordinates are invented.",["legacyApproachLabels"]={}},["Molten Core"]={["availability"]="client-listed-current-availability-unconfirmed",["canonicalName"]="Molten Core",["entrances"]={},["evidence"]={["file"]="checkpoint8cd_working_evidence.json",["sha256"]="d08a56b77abe277d94c99faefb0624b7e7cd729197789edd6a931ee810ac9a21",["url"]="https://www.wowhead.com/forever/zone=2717"},["instructions"]="Published transport reference: Lothos Riftwaker in Blackrock Mountain (Burning Steppes area26.4–26.6,24.4–24.8). Attunement to the Core #7848,minimum55/Both,asks one Core Fragment from the Molten Core entry portal inside Blackrock Depths;return to Lothos. Current mandatory entry,other access paths and earlier unlocks unverified. Map action resolves the client instance entrance,not Lothos or a boss floor point.",["legacyApproachLabels"]={},["resolutionNote"]="Published route information exists; precise exterior coordinates remain under review. Published transport reference: Lothos Riftwaker in Blackrock Mountain (Burning Steppes area26.4–26.6,24.4–24.8). Attunement to the Core #7848,minimum55/Both,asks one Core Fragment from the Molten Core entry portal inside Blackrock Depths;return to Lothos. Current mandatory entry,other access paths and earlier unlocks unverified. Map action resolves the client instance entrance,not Lothos or a boss floor point."},["Naxxramas"]={["availability"]="client-listed-current-availability-unconfirmed",["canonicalName"]="Naxxramas",["entrances"]={},["evidence"]={["file"]="checkpoint8cd_working_evidence.json",["sha256"]="cacb85934882def5260f8f40071f6b828e0a4c72442ccd3427aecba408399657",["url"]="https://www.wowhead.com/forever/zone=3456"},["instructions"]="Published Naxxramas access reference: visit Archmage Angela Dosantos at Light's Hope Chapel,Eastern Plaguelands81.4–81.6,58.2. The Dread Citadel - Naxxramas alternatives,minimum60/Both: Honored9121 asks5 Arcane Crystals,2 Nexus Crystals,1 Righteous Orb and60gold;Revered9122 asks2 Arcane Crystals,1 Nexus Crystal and30gold;Exalted9123 waives the cost. Choose the reputation alternative,not all three quests. Published completion describes the rune portal in Plaguewood. Current mandatory attunement,acceptance,phase/access and your completion state are unverified;giver fullpage remains unread. Map action resolves a client entrance,not an invented portal or boss floor point.",["legacyApproachLabels"]={},["resolutionNote"]="Published route information exists; precise exterior coordinates remain under review. Published Naxxramas access reference: visit Archmage Angela Dosantos at Light's Hope Chapel,Eastern Plaguelands81.4–81.6,58.2. The Dread Citadel - Naxxramas alternatives,minimum60/Both: Honored9121 asks5 Arcane Crystals,2 Nexus Crystals,1 Righteous Orb and60gold;Revered9122 asks2 Arcane Crystals,1 Nexus Crystal and30gold;Exalted9123 waives the cost. Choose the reputation alternative,not all three quests. Published completion describes the rune portal in Plaguewood. Current mandatory attunement,acceptance,phase/access and your completion state are unverified;giver fullpage remains unread. Map action resolves a client entrance,not an invented portal or boss floor point."},["Onyxia's Lair"]={["availability"]="announced-raid-client-acceptance-pending",["canonicalName"]="Onyxia's Lair",["entrances"]={},["evidence"]={},["instructions"]="Official raid roster includes this raid. Dustwallow Marsh location is known, but the primary overview explicitly warns the entrance may have moved. Client-derived 52.9,77.71 is retained in the audit; exact current placement/access is unverified.",["legacyApproachLabels"]={},["resolutionNote"]="Published route information exists; precise exterior coordinates remain under review. Official raid roster includes this raid. Dustwallow Marsh location is known, but the primary overview explicitly warns the entrance may have moved. Client-derived 52.9,77.71 is retained in the audit; exact current placement/access is unverified."},["Ragefire Chasm"]={["availability"]="published-dungeon",["canonicalName"]="Ragefire Chasm",["entrances"]={{["areaID"]=1637,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="main",["instructions"]="Inside the Cleft of Shadow Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["label"]="Ragefire Chasm — published outdoor approach",["uiMapID"]=1454,["verification"]="published-reference",["x"]=52.0,["y"]=49.0,["zone"]="Orgrimmar"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Inside the Cleft of Shadow Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["legacyApproachLabels"]={}},["Razorfen Downs"]={["availability"]="published-dungeon",["canonicalName"]="Razorfen Downs",["entrances"]={{["areaID"]=17,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="main",["instructions"]="Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["label"]="Razorfen Downs — published outdoor approach",["uiMapID"]=1413,["verification"]="published-reference",["x"]=50.0,["y"]=92.0,["zone"]="The Barrens"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["legacyApproachLabels"]={}},["Razorfen Kraul"]={["availability"]="published-dungeon",["canonicalName"]="Razorfen Kraul",["entrances"]={{["areaID"]=17,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="main",["instructions"]="Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["label"]="Razorfen Kraul — published outdoor approach",["uiMapID"]=1413,["verification"]="published-reference",["x"]=42.6,["y"]=88.5,["zone"]="The Barrens"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["legacyApproachLabels"]={}},["Ruins of Ahn'Qiraj"]={["availability"]="client-listed-current-availability-unconfirmed",["canonicalName"]="Ruins of Ahn'Qiraj",["entrances"]={},["evidence"]={},["instructions"]="Historical raid/client-listed data, current Forever availability unannounced in reviewed official roster. Silithus Scarab Wall approaches are recorded, but no current portal or access is verified.",["legacyApproachLabels"]={},["resolutionNote"]="Published route information exists; precise exterior coordinates remain under review. Historical raid/client-listed data, current Forever availability unannounced in reviewed official roster. Silithus Scarab Wall approaches are recorded, but no current portal or access is verified."},["Ruins of Lordaeron"]={["availability"]="published-dungeon",["canonicalName"]="Ruins of Lordaeron",["entrances"]={{["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=130581,["kind"]="published-forever-reference",["liveVerified"]=false,["retrieved"]="2026-11-18",["sha256"]="337f6fb0e7bb1fc084e39d3a4a3d037f8c8110e64b15bbbbe00a6690e246c77a",["url"]="https://www.wowhead.com/forever/guide/ruins-of-lordaeron-dungeon-overview-location-rewards"},["id"]="courtyard",["instructions"]="Follow the ruined city above Undercity. This is the primary guide courtyard approach, not its separate Undercity-map reference at 70,10.",["label"]="Ruins of Lordaeron courtyard approach",["uiMapID"]=1420,["verification"]="published-reference",["x"]=65,["y"]=70,["zone"]="Tirisfal Glades"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Above Undercity in the ruined city. The primary guide labels a Tirisfal approach at 65,70; the published client-derived record gives 63.3,67.5. They remain distinct approach/entrance evidence; exact portal placement needs in-game comparison.",["legacyApproachLabels"]={}},["Scarlet Monastery"]={["availability"]="published-dungeon",["canonicalName"]="Scarlet Monastery",["entrances"]={{["areaID"]=85,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="graveyard",["instructions"]="This is the shared outdoor approach, not the Graveyard portal. Continue inside following the Graveyard route; exact wing-door coordinates are not independently verified.",["label"]="Scarlet Monastery: Graveyard — shared exterior approach",["routeInstructionsOnly"]=true,["uiMapID"]=1420,["verification"]="published-reference",["x"]=83.5,["y"]=32.0,["zone"]="Tirisfal Glades"},{["areaID"]=85,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="library",["instructions"]="This is the shared outdoor approach, not the Library portal. Continue inside following the Library route; exact wing-door coordinates are not independently verified.",["label"]="Scarlet Monastery: Library — shared exterior approach",["routeInstructionsOnly"]=true,["uiMapID"]=1420,["verification"]="published-reference",["x"]=83.5,["y"]=32.0,["zone"]="Tirisfal Glades"},{["areaID"]=85,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="armory",["instructions"]="This is the shared outdoor approach, not the Armory portal. Continue inside following the Armory route; exact wing-door coordinates are not independently verified.",["label"]="Scarlet Monastery: Armory — shared exterior approach",["routeInstructionsOnly"]=true,["uiMapID"]=1420,["verification"]="published-reference",["x"]=83.5,["y"]=32.0,["zone"]="Tirisfal Glades"},{["areaID"]=85,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="cathedral",["instructions"]="This is the shared outdoor approach, not the Cathedral portal. Continue inside following the Cathedral route; exact wing-door coordinates are not independently verified.",["label"]="Scarlet Monastery: Cathedral — shared exterior approach",["routeInstructionsOnly"]=true,["uiMapID"]=1420,["verification"]="published-reference",["x"]=83.5,["y"]=32.0,["zone"]="Tirisfal Glades"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check. The distinct wing choices retain the common outdoor approach and written route; no separate portal coordinates are invented.",["legacyApproachLabels"]={}},["Scholomance"]={["availability"]="published-dungeon",["canonicalName"]="Scholomance",["entrances"]={{["areaID"]=28,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="main",["instructions"]="Beneath Caer Darrow Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["label"]="Scholomance — published outdoor approach",["uiMapID"]=1422,["verification"]="published-reference",["x"]=69.8,["y"]=76.0,["zone"]="Western Plaguelands"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Beneath Caer Darrow Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["legacyApproachLabels"]={}},["Shadowfang Keep"]={["availability"]="published-dungeon",["canonicalName"]="Shadowfang Keep",["entrances"]={{["areaID"]=130,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="main",["instructions"]="Above Pyrewood Village Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["label"]="Shadowfang Keep — published outdoor approach",["uiMapID"]=1421,["verification"]="published-reference",["x"]=42.6,["y"]=66.6,["zone"]="Silverpine Forest"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Above Pyrewood Village Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["legacyApproachLabels"]={}},["Shaper's Terrace"]={["availability"]="published-dungeon",["canonicalName"]="Shaper's Terrace",["entrances"]={{["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["file"]="docs/navigation-overhaul/research/search-8.json",["fingerprintScope"]="committed search retrieval response, not provider HTML",["kind"]="indexed-published-excerpt",["liveVerified"]=false,["retrieved"]="2026-11-18",["sha256"]="016fa0a532fc9608d40b1b2cc3f5a5a62b024b8cf46d868cf815af924689ca41",["url"]="https://www.warcrafttavern.com/forever/guides/shapers-terrace/"},["id"]="refuge-approach",["instructions"]="Published guide coordinate corroborated by LFCarry. Approach above Marshal's Refuge; the full provider page was inaccessible, so treat this as a qualified approach requiring current-client comparison.",["label"]="Shaper's Terrace: Marshal's Refuge hill approach",["uiMapID"]=1449,["verification"]="published-reference",["x"]=48.1,["y"]=6.1,["zone"]="Un'Goro Crater"}},["evidence"]={},["instructions"]="Northern Un'Goro Crater, hill overlooking Marshal's Refuge, published 48.1,6.1. Warcraft Tavern indexed text and LFCarry agree. Full primary page and actual client verification remain pending.",["legacyApproachLabels"]={}},["Stormwind Stockade"]={["availability"]="published-dungeon",["canonicalName"]="Stormwind Stockade",["entrances"]={{["coordinateKind"]="exterior-portal-reference",["evidence"]={["bytes"]=80215,["kind"]="published-forever-reference",["liveVerified"]=false,["retrieved"]="2026-11-18",["sha256"]="030010e1b29d696535f14e0abea65320c325b74d00c7ecc22baf4218403963b0",["url"]="https://foreverdb.net/dungeon/34-stormwind-stockade"},["id"]="main",["instructions"]="Published exterior reference. Verify exact portal position and current access in the Forever client.",["label"]="Stormwind Stockade entrance reference",["uiMapID"]=1453,["verification"]="published-reference",["x"]=50.35,["y"]=66.18,["zone"]="Stormwind City"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Published Forever-client-derived entrance on UI map 1453, corroborated by Azeroth DB 50.4,66.2. The overview 41.0,57.0 conflicts and is retained only in the audit. Owner in-game placement remains pending.",["legacyApproachLabels"]={}},["Stratholme"]={["availability"]="published-dungeon",["canonicalName"]="Stratholme",["entrances"]={{["areaID"]=139,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="main",["instructions"]="Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["label"]="Stratholme — Living Side Entrance (published approach)",["uiMapID"]=1423,["verification"]="published-reference",["x"]=30.9,["y"]=15.2,["zone"]="Eastern Plaguelands"},{["areaID"]=139,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="service",["instructions"]="Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check. Published Undead-side gate requires Key to the City; current access unverified.",["label"]="Stratholme — Undead Side Entrance (published approach)",["uiMapID"]=1423,["verification"]="published-reference",["x"]=48.3,["y"]=21.8,["zone"]="Eastern Plaguelands"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["legacyApproachLabels"]={}},["The Barrow Deeps"]={["availability"]="announced-raid-client-acceptance-pending",["canonicalName"]="The Barrow Deeps",["entrances"]={},["evidence"]={},["instructions"]="Official raid roster includes this raid. Three approaches connect Mount Hyjal, Winterspring and Blackmaw Hold. The primary overview gives no precise entrances; anonymous beta coordinates are not accepted.",["legacyApproachLabels"]={},["resolutionNote"]="Published route information exists; precise exterior coordinates remain under review. Official raid roster includes this raid. Three approaches connect Mount Hyjal, Winterspring and Blackmaw Hold. The primary overview gives no precise entrances; anonymous beta coordinates are not accepted."},["The Drowned City"]={["availability"]="published-dungeon",["canonicalName"]="The Drowned City",["entrances"]={{["coordinateKind"]="cave-entrance-reference",["evidence"]={["bytes"]=146187,["kind"]="published-forever-reference",["liveVerified"]=false,["retrieved"]="2026-11-18",["sha256"]="d56fe778e0712bed3a94eb2c57b7cb616bb88ff5a45ad1581e8586b2f49b8262",["url"]="https://www.wowhead.com/forever/guide/the-drowned-city-dungeon-overview-location-rewards"},["id"]="sea-cave",["instructions"]="Published exterior reference. Verify exact portal position and current access in the Forever client.",["label"]="Drowned City: sea-cave approach",["uiMapID"]=1434,["verification"]="published-reference",["x"]=21,["y"]=28,["zone"]="Stranglethorn Vale"}},["evidence"]={},["instructions"]="Off the coast of Stranglethorn Vale, south of Haunted Isle; the primary guide labels 21,28 on area 33. Swim to the cave in the ocean. Nearby community references round to 21,27; this is a sea-cave approach, not an interior boss point.",["legacyApproachLabels"]={}},["The Hall of Thanes"]={["availability"]="published-dungeon",["canonicalName"]="The Hall of Thanes",["entrances"]={{["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=113616,["kind"]="published-forever-reference",["liveVerified"]=false,["retrieved"]="2026-11-18",["sha256"]="be2a009f5285c8b642acd154fe8ebec6bb19c74a1e158202c29da59d80a4a55e",["url"]="https://www.wowhead.com/forever/guide/hall-of-thanes-dungeon-overview-location-rewards"},["id"]="high-seat",["instructions"]="This marks the High Seat, not the underground portal. Take the open door to Old Ironforge on the left after entering the High Seat; follow stairs to the bottom.",["label"]="High Seat approach to Hall of Thanes",["uiMapID"]=1455,["verification"]="published-reference",["x"]=42,["y"]=55,["zone"]="Ironforge"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="The primary guide identifies the High Seat at Ironforge 42,55. This is a building approach; the portal below uses a different position. Conflicting underground projections are not used as precise outdoor portal pins.",["legacyApproachLabels"]={}},["The Temple of Atal'Hakkar"]={["availability"]="published-dungeon",["canonicalName"]="The Temple of Atal'Hakkar",["entrances"]={{["areaID"]=8,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="main",["instructions"]="Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["label"]="The Temple of Atal'Hakkar — published outdoor approach",["uiMapID"]=1435,["verification"]="published-reference",["x"]=69.6,["y"]=53.2,["zone"]="Swamp of Sorrows"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["legacyApproachLabels"]={}},["Uldaman"]={["availability"]="published-dungeon",["canonicalName"]="Uldaman",["entrances"]={{["areaID"]=3,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="main",["instructions"]="Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["label"]="Uldaman — published outdoor approach",["uiMapID"]=1418,["verification"]="published-reference",["x"]=42.6,["y"]=10.8,["zone"]="Badlands"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["legacyApproachLabels"]={}},["Upper Blackrock Spire"]={["availability"]="published-dungeon",["canonicalName"]="Upper Blackrock Spire",["entrances"]={{["areaID"]=51,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="main",["instructions"]="Inside Blackrock Mountain Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["label"]="Upper Blackrock Spire — Blackrock Mountain (published approach)",["uiMapID"]=1427,["verification"]="published-reference",["x"]=35.2,["y"]=84.2,["zone"]="Searing Gorge"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Inside Blackrock Mountain Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["legacyApproachLabels"]={}},["Wailing Caverns"]={["availability"]="published-dungeon",["canonicalName"]="Wailing Caverns",["entrances"]={{["areaID"]=17,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="main",["instructions"]="Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["label"]="Wailing Caverns: cave approach",["uiMapID"]=1413,["verification"]="published-reference",["x"]=45.5,["y"]=35.5,["zone"]="The Barrens"},{["coordinateKind"]="exterior-portal-reference",["evidence"]={["bytes"]=111118,["kind"]="published-forever-reference",["liveVerified"]=false,["retrieved"]="2026-11-18",["sha256"]="347852dddfc81255d5b5820b8a85378cc41a554e74f157ad0ba5348f88ee5e8f",["url"]="https://foreverdb.net/dungeon/43-wailing-caverns"},["id"]="portal-reference",["instructions"]="Published exterior reference. Verify exact portal position and current access in the Forever client.",["label"]="Wailing Caverns: instance portal",["uiMapID"]=1413,["verification"]="published-reference",["x"]=47.69,["y"]=34.98,["zone"]="The Barrens"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check. Nalpak is in the elevated cave near the mouth; his exact local position is not established. His source marker retains the exterior approach, not the native dungeon portal.",["legacyApproachLabels"]={},["sourceApproachID"]="main"},["Zul'Farrak"]={["availability"]="published-dungeon",["canonicalName"]="Zul'Farrak",["entrances"]={{["areaID"]=440,["coordinateKind"]="outdoor-entrance-approach",["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["id"]="main",["instructions"]="Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["label"]="Zul'Farrak — published outdoor approach",["uiMapID"]=1446,["verification"]="published-reference",["x"]=39.5,["y"]=21.3,["zone"]="Tanaris"}},["evidence"]={["bytes"]=170481,["kind"]="full-published-forever-guide",["liveVerified"]=false,["sha256"]="92b8ae6529de34cccd643c7f7a7b4b139f464a91560e069e2efcb0728290dbe1",["url"]="https://www.wowhead.com/forever/guide/dungeons-overview-locations-details"},["instructions"]="Published outdoor entrance approach; continue inside using the written dungeon/wing instructions. This is not a verified current portal, boss floor or live access check.",["legacyApproachLabels"]={}},["Zul'Gurub"]={["availability"]="client-listed-current-availability-unconfirmed",["canonicalName"]="Zul'Gurub",["entrances"]={},["evidence"]={["file"]="checkpoint8cd_working_evidence.json",["sha256"]="85192b7b35711657bf6744260ed1b18944921412ba301890546dd8b40a2d01fa",["url"]="https://www.wowhead.com/forever/zone=1977"},["instructions"]="Published instance source. Open the client-resolved entrance if available;exact boss floor/wing,keys,current access and group requirements remain unverified. No invented floor coordinate.",["legacyApproachLabels"]={},["resolutionNote"]="Published route information exists; precise exterior coordinates remain under review. Published instance source. Open the client-resolved entrance if available;exact boss floor/wing,keys,current access and group requirements remain unverified. No invented floor coordinate."}}
for name,definition in pairs(definitions)do model.instanceEntrances[name]=definition;model.instances[name]=true end
for alias,name in pairs({["AQ20"]="Ruins of Ahn'Qiraj",["AQ40"]="Ahn'Qiraj Temple",["Ahn'Qiraj"]="Ahn'Qiraj",["Ahn'Qiraj Temple"]="Ahn'Qiraj Temple",["Alcaz Prison"]="Alcaz Prison",["Barrow Deeps"]="The Barrow Deeps",["Blackfathom Deeps"]="Blackfathom Deeps",["Blackmaw Hold"]="Blackmaw Hold",["Blackrock Depths"]="Blackrock Depths",["Blackrock Spire"]="Blackrock Spire",["Blackwing Lair"]="Blackwing Lair",["City of Dalaran"]="City of Dalaran",["Deadmines"]="Deadmines",["Dire Maul"]="Dire Maul",["Dire Maul East"]="Dire Maul",["Dire Maul North"]="Dire Maul",["Dire Maul West"]="Dire Maul",["Dire Maul: East"]="Dire Maul",["Dire Maul: North"]="Dire Maul",["Dire Maul: West"]="Dire Maul",["Drowned City"]="The Drowned City",["Excavation Site"]="Excavation Site: Wetlands",["Excavation Site: Wetlands"]="Excavation Site: Wetlands",["Gnomeregan"]="Gnomeregan",["Hall of Thanes"]="The Hall of Thanes",["Halls of Thanes"]="The Hall of Thanes",["Hyjal Summit"]="Hyjal Summit",["Krol'Dok Stronghold"]="Krol'dok Stronghold",["Krol'dok Stronghold"]="Krol'dok Stronghold",["Krol’dok Stronghold"]="Krol'dok Stronghold",["LBRS"]="Blackrock Spire",["Lower Blackrock Spire"]="Blackrock Spire",["Maraudon"]="Maraudon",["Maraudon: Inner falls"]="Maraudon",["Maraudon: Orange"]="Maraudon",["Maraudon: Purple"]="Maraudon",["Molten Core"]="Molten Core",["Naxxramas"]="Naxxramas",["Onyxia's Lair"]="Onyxia's Lair",["Onyxia’s Lair"]="Onyxia's Lair",["Ragefire Chasm"]="Ragefire Chasm",["Razorfen Downs"]="Razorfen Downs",["Razorfen Kraul"]="Razorfen Kraul",["Ruins of Ahn'Qiraj"]="Ruins of Ahn'Qiraj",["Ruins of Lordaeron"]="Ruins of Lordaeron",["Scarlet Monastery"]="Scarlet Monastery",["Scarlet Monastery: Armory"]="Scarlet Monastery",["Scarlet Monastery: Cathedral"]="Scarlet Monastery",["Scarlet Monastery: Graveyard"]="Scarlet Monastery",["Scarlet Monastery: Library"]="Scarlet Monastery",["Scholomance"]="Scholomance",["Shadowfang Keep"]="Shadowfang Keep",["Shaper's Terrace"]="Shaper's Terrace",["Shaper’s Terrace"]="Shaper's Terrace",["Stockade"]="Stormwind Stockade",["Stockades"]="Stormwind Stockade",["Stormwind Stockade"]="Stormwind Stockade",["Stratholme"]="Stratholme",["Sunken Temple"]="The Temple of Atal'Hakkar",["Temple of Ahn'Qiraj"]="Ahn'Qiraj Temple",["Temple of Atal'Hakkar"]="The Temple of Atal'Hakkar",["The Barrow Deeps"]="The Barrow Deeps",["The Deadmines"]="Deadmines",["The Drowned City"]="The Drowned City",["The Hall of Thanes"]="The Hall of Thanes",["The Shaper's Terrace"]="Shaper's Terrace",["The Stockade"]="Stormwind Stockade",["The Stockades"]="Stormwind Stockade",["The Temple of Atal'Hakkar"]="The Temple of Atal'Hakkar",["UBRS"]="Upper Blackrock Spire",["Uldaman"]="Uldaman",["Upper Blackrock Spire"]="Upper Blackrock Spire",["Wailing Caverns"]="Wailing Caverns",["Wetlands Excavation Site"]="Excavation Site: Wetlands",["Zul'Farrak"]="Zul'Farrak",["Zul'Gurub"]="Zul'Gurub"})do model.instanceEntranceAliases[alias]=name end
end
end
-- END GENERATED NAVIGATION REVIEW
-- Skill, book learning and acquisition certainty are independent. A documented
-- minimum survives missing source geography and multi-source loot tables.
function GetGear:GetNormalizedRecipeData(gear)
    if not gear or not gear.profession then return end
    local fact=get(data().recipeRequirements,gear.itemID) or {}
    local extra=get(self.RecipeEvidence,gear.itemID) or {}
    local crafting=extra.craftingSkill or fact.recipeMinimumSkill
    local learning=extra.learningSkill or fact.bookLearningSkill
    if not learning and type(fact.trainerLearningSkills)=="table" and #fact.trainerLearningSkills==1 then learning=fact.trainerLearningSkills[1] end
    if not learning and gear.recipeLearnSkillEvidence~="unverified" then learning=gear.professionSkillRequired end
    local acquisitions=(get(data().items,gear.itemID) or {}).routes or {}
    local sources={};local confidence="unverified"
    for _,route in ipairs(acquisitions) do
        local kind=({trainer="trainer",recipe_vendor="vendor",vendor="vendor",quest="quest",
            recipe_drop="drop",world_drop="world_drop",reputation="reputation"})[route.kind]
        if route.kind=="dungeon" then
            kind=route.sourceRole=="boss" and "dungeon_boss" or route.sourceRole=="trash" and "dungeon_trash" or "dungeon_drop"
        end
        local certainty=(route.verification=="published-reference" or route.verification=="client") and "documented"
            or route.verification=="legacy-reference" and "probable" or "unverified"
        sources[#sources+1]={kind=kind or "unknown",confidence=certainty,route=route}
        if certainty=="documented" or certainty=="probable" and confidence=="unverified" then confidence=certainty end
    end
    if #(extra.documentedDrops or {})>0 then confidence="documented" end
    return {profession=gear.profession,craftingSkill=crafting,learningSkill=learning,
        skillConfidence=(crafting or learning) and "documented" or "unverified",
        sourceConfidence=confidence,sources=sources,
        books=extra.books or {},documentedDrops=extra.documentedDrops or {},
        evidence=extra.evidence or fact.evidence or {},acquisitions=acquisitions}

end
function GetGear:GetRecipeSkillRequirement(gear)
    if not gear then return end
    local extra=get(self.RecipeEvidence,gear.itemID) or {}
    if type(extra.craftingSkill)=="number" then return extra.craftingSkill,"recipe minimum" end
    local fact=get(data().recipeRequirements,gear.itemID) or {}
    if type(fact.recipeMinimumSkill)=="number" then return fact.recipeMinimumSkill,"recipe minimum" end
    if type(fact.trainerLearningSkills)=="table" and #fact.trainerLearningSkills==1 then
        return fact.trainerLearningSkills[1],"learning minimum"
    end
    if type(fact.bookLearningSkill)=="number" then return fact.bookLearningSkill,"book learning minimum" end
    if type(extra.learningSkill)=="number" then return extra.learningSkill,"book learning minimum" end
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

-- Item requirements and per-offer access are separate from travel and stats.
-- The overlay is generated from name-locked publication evidence; missing facts
-- remain unknown. Never infer faction from item/NPC names or zone ownership.
local function factionFacts(gear)
    local registry=GetGear.FactionEligibilityData or {}
    return gear and (gear.factionEligibility or get(registry.items,gear.itemID)) or {}
end
local function raceRestrictionAllows(ids,raceID)
    if not raceID or type(ids)~="table" or #ids==0 then return true end
    local uncertain=false
    for _,id in ipairs(ids) do
        if type(id)~="number" or id~=id or id<1 or id==math.huge or id~=math.floor(id) then uncertain=true
        elseif id==raceID then return true end
    end
    return uncertain
end

function GetGear:IsFactionUseEligible(gear,context)
    if not gear then return true end
    local fact=factionFacts(gear)
    local faction=context and context.faction or not context and call(UnitFactionGroup,"player")
    local side=faction=="Alliance" and 1 or faction=="Horde" and 2
    if side and (fact.side==1 or fact.side==2) and fact.side~=side then
        return false,"Published item faction requirement does not match this character"
    end
    local raceID=context and context.raceID
    if not context then
        local _,token,id=call(UnitRace,"player")
        raceID=id or ({Human=1,Orc=2,Dwarf=3,NightElf=4,Scourge=5,Undead=5,Tauren=6,Gnome=7,Troll=8})[token]
    end
    if not raceRestrictionAllows(fact.races,raceID) then
        return false,"Published item race requirement does not match this character"
    end
    return true
end

function GetGear:GetGearBindingStatus(gear)
    if not gear then return end
    local getter=C_Item and C_Item.GetItemInfo or GetItemInfo
    local cached=not (C_Item and type(C_Item.IsItemDataCachedByID)=="function")
        or call(C_Item.IsItemDataCachedByID,gear.itemID)==true
    if cached and type(getter)=="function" then
        local result={pcall(getter,gear.itemID)}
        if result[1] and result[2] and not (type(issecretvalue)=="function" and issecretvalue(result[15])) then
            if result[15]==1 then return "bop" elseif result[15]==2 then return "boe" end
        end
    end
    return gear.bindingStatus or factionFacts(gear).binding
end

function GetGear:GetIndependentAcquisitionAccess(gear,context)
    if not gear or not self:IsFactionUseEligible(gear,context) then return end
    if gear.profession and not context and self.GetRecipeKnowledge and self:GetRecipeKnowledge(gear)==true then return "learned" end
    if self:GetGearBindingStatus(gear)=="boe" then return "tradeable" end
end

function GetGear:GetAcquisitionRouteFactionSide(gear,route)
    local registry=self.FactionEligibilityData or {}
    if route.kind=="quest" or route.kind=="quest_container" then
        local goal=get(data().quests,route.questID) or {}
        if goal.side==1 or goal.side==2 or goal.side==3 then return goal.side end
        return get(registry.quests,route.questID)
    end
    local restricted=route.serviceSide or route.offer and route.offer.side
    if restricted then return restricted end
    if route.kind=="vendor" or route.kind=="recipe_vendor" or route.kind=="trainer" or route.kind=="vendor_container" then
        local actor=data().sources[route.source] or {}
        if actor.serviceSide then return actor.serviceSide end
        local origin=route.bookItemID or (route.kind=="recipe_vendor" or route.kind=="trainer") and gear and gear.recipePatternItemID or gear and gear.itemID
        local offers=get(registry.offers,origin) or {}
        return offers[route.source]
    end
end

function GetGear:GetPreviewAcquisitionContext(classToken)
    -- A class preview is faction-aware but does not pretend an alternate class
    -- has this character's race or active quest overrides. No saves are changed.
    return {faction=call(UnitFactionGroup,"player"),classToken=classToken}
end

local function routesForCharacter(model,plan,context,gear)
    gear=gear or GetGear.ItemCatalog and plan and get(GetGear.ItemCatalog,plan.itemID)
    if gear and not GetGear:IsFactionUseEligible(gear,context) then return {} end
    local routes=plan and plan.routes or {}
    local faction=context and context.faction or not context and call(UnitFactionGroup,"player")
    local side=faction=="Alliance" and 1 or faction=="Horde" and 2
    local _,_,classID=call(UnitClass,"player")
    if context then
        classID=({WARRIOR=1,PALADIN=2,HUNTER=3,ROGUE=4,PRIEST=5,SHAMAN=7,MAGE=8,WARLOCK=9,DRUID=11})[context.classToken]
    end
    local classBit=type(classID)=="number" and classID>=1 and classID<=32 and classID==math.floor(classID) and 2^(classID-1)
    local raceID=context and context.raceID
    if not context then
        local _,raceToken,id=call(UnitRace,"player")
        raceID=id or ({Human=1,Orc=2,Dwarf=3,NightElf=4,Scourge=5,Tauren=6,Gnome=7,Troll=8})[raceToken]
    end
    local useful={}
    for _,route in ipairs(routes) do
        local restricted=GetGear:GetAcquisitionRouteFactionSide(gear,route)
        local classMask
        local raceAllowed=true
        local activeSide,activeClass=false,false
        if route.kind=="quest" or route.kind=="quest_container" then
            local goal=get(model.quests,route.questID) or {}
            classMask=type(goal.reqclass)=="number" and goal.reqclass>0 and goal.reqclass==math.floor(goal.reqclass) and goal.reqclass
            raceAllowed=raceRestrictionAllows(goal.raceIDs,raceID)
            activeSide=not context and onQuest(route.questID);activeClass=activeSide
            if not activeSide and ((restricted==1 or restricted==2) or classMask) then
                local chain=get(model.chains,route.questID)
                for _,id in ipairs(chain and chain.steps or {}) do
                    local q=get(model.quests,id) or {}
                    if not context and onQuest(id) then
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
        local attribution=factionFacts(gear).acquisitionSide
        local sharedSource=route.kind=="dungeon" or (route.kind=="named_drop" or route.kind=="npc_container"
            or route.kind=="object" or route.kind=="fishing") and route.verification and route.verification~="legacy-reference"
        local attributedAccess=not side or attribution~=1 and attribution~=2 or attribution==side
            or restricted==side or restricted==3 or activeSide or sharedSource
        if sideAllowed and classAllowed and raceAllowed and attributedAccess then useful[#useful+1]=route end
    end
    return useful
end

-- Source access is independent of item proficiency and travel convenience.
-- Unknown routes remain unknown; no zone or distance creates a faction veto.
function GetGear:GetEligibleAcquisitionRoutes(gear,context)
    local plan=gear and (gear.acquisitionPlan or get(data().items,gear.itemID))
    if not self:IsFactionUseEligible(gear,context) then return {},true end
    local faction=context and context.faction or not context and call(UnitFactionGroup,"player")
    local side=faction=="Alliance" and 1 or faction=="Horde" and 2
    local attribution=factionFacts(gear).acquisitionSide
    local attributed=side and (attribution==1 or attribution==2) and attribution~=side
    if not plan then return {},attributed and true or false end
    return routesForCharacter(data(),plan,context,gear),#(plan.routes or {})>0 or attributed and true or false
end

function GetGear:GetIndependentCraftAccess(gear,context)
    if gear and gear.profession then return self:GetIndependentAcquisitionAccess(gear,context) end
end

function GetGear:HasEligibleAcquisitionSource(gear,context)
    if not self:IsFactionUseEligible(gear,context) then return false end
    local routes,known=self:GetEligibleAcquisitionRoutes(gear,context)
    if not known or #routes>0 then return true end
    -- Only consult learned-recipe/binding data when the direct routes fail.
    -- Ordinary catalogue scans do not need item-info queries for future gear.
    return self:GetIndependentAcquisitionAccess(gear,context)~=nil
end

function GetGear:GetAcquisitionMinimumLevel(gear)
    -- A recipe-book quest minimum is not the finished item's equip/access
    -- minimum. Personal crafting and commissioned BoEs have separate rules.
    if gear and (gear.bagUpgrade or gear.profession) then return end
    local routes=self:GetEligibleAcquisitionRoutes(gear)
    local minimum
    for _,route in ipairs(routes) do
        if route.kind~="quest" and route.kind~="quest_container" then return end
        local q=get(data().quests,route.questID)
        if not q or type(q.reqlevel)~="number" then return end
        minimum=math.min(minimum or q.reqlevel,q.reqlevel)
    end
    return minimum
end

function GetGear:GetFactionAcquisitionDescription(gear)
    local usable,reason=self:IsFactionUseEligible(gear)
    if not usable then return reason end
    local plan=gear and (gear.acquisitionPlan or get(data().items,gear.itemID))
    if not plan or #(plan.routes or {})==0 then return end
    local eligible=routesForCharacter(data(),plan,nil,gear)
    if #eligible==#plan.routes then return end
    if #eligible==0 then
        local craft=self:GetIndependentAcquisitionAccess(gear)
        if craft=="learned" then
            return "Recipe already learned; use the crafting requirements and materials. No new recipe book is needed."
        elseif craft=="tradeable" then
            return (gear.profession and "The known recipe produces a bind-on-equip item. Commissioning or trading the finished item" or "This verified bind-on-equip item can be traded; acquisition")
                .." is possible if an offer is available; no current offer is confirmed. No published direct acquisition route is eligible for this character."
        end
        return "No published acquisition route is eligible for this character. Source access is separate from equipment proficiency."
    end
    local names={}
    for _,route in ipairs(eligible) do
        local q=get(data().quests,route.questID)
        local actor=data().sources[route.source] or {}
        names[#names+1]=q and q.name or actor.name or route.dungeon or route.label or route.kind
    end
    local text="Eligible sources: "..table.concat(names,"; ")..". Published references; current access/stock/loot unverified."
    if gear.recipePatternItemID then text=text.." Recipe book: #"..gear.recipePatternItemID.."." end
    if self.GetCompactAcquisitionRequirements then
        for _,requirement in ipairs(self:GetCompactAcquisitionRequirements(gear)) do text=text.."\n"..requirement end
    end
    return text
end

function GetGear:GetAcquisitionInstanceDefinition(name)
    local model=data()
    local canonical=(model.instanceEntranceAliases or {})[name] or name
    return (model.instanceEntrances or {})[canonical],canonical
end

function GetGear:GetAcquisitionInstanceName(name)
    local definition,canonical=self:GetAcquisitionInstanceDefinition(name)
    return (definition or (data().instances or {})[canonical]) and canonical or nil
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
    for _,requirement in ipairs((get(self.RecipeEvidence,gear and gear.itemID) or {}).learningRequirements or {}) do
        out[#out+1]="Learn: "..requirement
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
    local disputed=gear.recipeLearningAvailability=="disputed"
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
    local routes=routesForCharacter(model,plan,nil,gear)
    local normalized=self:GetNormalizedRecipeData(gear)
    local drops=normalized.documentedDrops
    local other=false
    for _,route in ipairs(routes) do if route.kind~="dungeon" and route.kind~="recipe_drop" and route.kind~="legacy" then other=true end end
    if #drops>0 and not other then
        local allDungeons=true
        for _,drop in ipairs(drops) do if not drop.dungeons then allDungeons=false;break end end
        local source=allDungeons and (#drops>1 and "Dungeon drop (multiple sources)" or "Dungeon drop")
            or (#drops>1 and "Drop (multiple documented sources)" or "Documented drop")
        return "Recipe: "..source.." ("..gear.profession..(minimum and " "..minimum or "; skill unverified").."); live drops unverified"
    end
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
            local source=route.sourceRole=="trash" and "Dungeon trash drop — "..route.dungeon
                or route.sourceRole=="boss" and "Boss drop — "..(route.enemyName or route.boss or route.dungeon)
                or ((route.enemyName or route.boss) and (route.enemyName or route.boss)~="" and (route.enemyName or route.boss).." — " or "")..route.dungeon.." drop"
            return qualified(source,route,"; drop/access unverified")
        elseif route.kind=="world_drop" then
            return qualified("World drop",route,"; live drops unverified")
        elseif route.kind=="reputation" then
            return qualified("Reputation reward",route,"; access unverified")
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
    local routes=routesForCharacter(data(),plan,nil,gear)
    local summary=compactRecipeSummary(self,gear)
    local routine=summary and summary:find('Recipe: '..gear.profession..' trainer',1,true)==1
    if not routine and plan and #(plan.routes or {})>0 and #routes==0 then
        summary="Recipe: no known source route for this character; see Guide"
        local access=self:GetIndependentCraftAccess(gear)
        if access=="learned" then summary="Recipe already learned; no new book needed"
        elseif access=="tradeable" then summary="Recipe learning route unavailable; finished BoE: commission/trade if available" end
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
    if gear and gear.bagFromInventory then return "Owned bag: equip from inventory or retrieve from bank; no new quest needed." end
    if gear and gear.profession then return self:GetCompactRecipeSummary(gear) end
    local model=data();local plan=gear and gear.acquisitionPlan or get(model.items,gear and gear.itemID)
    if plan and #(plan.routes or {})>0 and #routesForCharacter(model,plan,nil,gear)==0 then
        if self:GetIndependentAcquisitionAccess(gear)=="tradeable" then
            return "Source: trade/Auction House for a verified BoE item if offered; listings unknown. No direct source is eligible; see Guide."
        end
        return 'Source: no known route for this character; see Guide'
    end
    local practicality=self:GetAcquisitionPracticality(gear)
    if practicality.remoteOriginal and practicality.alternative=="tradeable" then
        return "Source: trade/Auction House for a verified BoE item if offered; listings unknown. Original drop/vendor route: Guide."
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
    for _,route in ipairs(routesForCharacter(model,plan,nil,gear)) do
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
    if gear.bagFromInventory then return {} end
    local model=data()
    local plan=gear.acquisitionPlan or get(model.items,gear.itemID)
    if not plan and type(gear.acquisitionLocation)=="table" then
        plan={routes={{kind="legacy",location=gear.acquisitionLocation,label=gear.acquisitionLocation.spot}}}
    end
    if not plan then return {} end
    local routes=routesForCharacter(model,plan,nil,gear)
    local choices,seen={},{}
    local currentRoute,currentQuestContext
    local function add(target)
        -- Instance NPCs/objects and dungeon loot share the same exterior
        -- entrance resolver. Interior actor coordinates are never portal pins.
        if target.kind=="dungeon" and not target.publishedEntrance and target.role~="Published active quest objective" then
            local definition,canonical=GetGear:GetAcquisitionInstanceDefinition(target.dungeon)
            local entrances=definition and definition.entrances or {}
            if #entrances>0 then
                for _,entrance in ipairs(entrances) do
                    if not target.approachOnly or not definition.sourceApproachID or entrance.id==definition.sourceApproachID then
                    local copy={};for k,v in pairs(target) do copy[k]=v end
                    copy.dungeon=canonical;copy.publishedEntrance=entrance;copy.entranceID=entrance.id
                    copy.zone=entrance.zone;copy.x=entrance.x;copy.y=entrance.y;copy.bounds=nil
                    copy.uiMapID=entrance.uiMapID;copy.multipleEntrances=#entrances>1
                    copy.coordinateKind=entrance.coordinateKind
                    copy.verification=entrance.verification or target.verification
                    copy.instructions=(copy.instructions or '')..'\nExterior entrance approach, not an interior source position. '..(definition.instructions or '')
                    add(copy)
                    end
                end
                return
            end
        end
        target.acquisitionRoute=currentRoute
        target.questContext=currentQuestContext
        local b=target.bounds
        local footprint=b and table.concat({b.xMin or'',b.xMax or'',b.yMin or'',b.yMax or''},',')or''
        local key=target.kind=='dungeon' and target.entranceOnly and ('entrance|'..target.dungeon..'|'..(target.entranceID or'main'))
            or table.concat({target.role or "",target.questID or "",target.source or "",target.zone or "",target.uiMapID or "",target.x or "",target.y or "",footprint,target.dungeon or "",target.label or ""},"|")
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
                local entrance=route.entranceOnly and GetGear:GetAcquisitionInstanceName(loc.zone)
                local instructions=route.instructions
                if context and context.instructions then instructions=(instructions and instructions.."\n" or "")..context.instructions end
                add({kind=entrance and "dungeon" or "directions",dungeon=entrance or nil,
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
            local instance=loc.dungeonApproach or GetGear:GetAcquisitionInstanceName(loc.zone)
            local context=(model.instanceDetails or {})[instance or loc.zone]
            local instructions=route.instructions
            if loc.instructions then instructions=(instructions and instructions.."\n" or "")..loc.instructions end
            if context and context.instructions then instructions=(instructions and instructions.."\n" or "")..context.instructions end
            add({kind=instance and "dungeon" or route.kind,dungeon=instance or nil,
                 entranceOnly=instance and route.entranceOnly and true or nil,
                 boss=instance and route.boss or nil,source=key,label=actor.name or key,zone=loc.zone,uiMapID=not instance and loc.uiMapID or nil,
                 x=not instance and loc.x or nil,y=not instance and loc.y or nil,bounds=not instance and loc.bounds or nil,verification=loc.verification,role=role,
                 questID=q and q.questID,questName=q and q.name,requirements=requirements,preferred=preferred,
                 instructions=instructions,bookItemID=route.bookItemID,chainUnresolved=unresolved,
                 approachOnly=loc.dungeonApproach~=nil,coordinateScope=loc.coordinateScope})
        end
    end
    local questRoutes=0
    for _, route in ipairs(routes) do if route.kind=="quest" or route.kind=="quest_container" then questRoutes=questRoutes+1 end end
    for _, route in ipairs(routes) do
        currentRoute=route
        currentQuestContext=nil
        if route.kind=="quest" or route.kind=="quest_container" then
            local id,state=chooseQuest(route.questID)
            local stage=onQuest(id) and (call(C_QuestLog.IsComplete,id)==true and 'turn-in' or 'active')
                or state=='completed' and 'completed' or 'not-on-quest'
            currentQuestContext=table.concat({route.questID,id,stage},':')
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
                            local instance=self:GetAcquisitionInstanceName(q.objectiveZone)
                            add({kind=instance and "dungeon" or "directions",dungeon=instance or nil,
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
                    local instance=self:GetAcquisitionInstanceName(q.starterZone)
                    add({kind=instance and "dungeon" or "directions",dungeon=instance or nil,
                         questID=id,questName=q.name,role="Quest starter item",label=item.name,
                         zone=q.starterZone,instructions=q.starterInstructions,requirements=requirements,
                         verification="published-reference",preferred=questRoutes==1})
                end
                if not q.starterItems or #q.starterItems==0 then
                    local instance=self:GetAcquisitionInstanceName(q.starterZone)
                    add({kind=instance and "dungeon" or "directions",dungeon=instance or nil,
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
            add({kind=route.kind,label=route.label or loc.spot or loc.zone,npcName=route.npcName or loc.npcName,zone=loc.zone,x=loc.x,y=loc.y,
                 bounds=loc.bounds,uiMapID=loc.uiMapID,verification=loc.verification or (loc.quality=="classic-reference" and "legacy-reference" or "published-reference"),
                 role=route.kind=="trainer" and "Recipe trainer" or route.kind=="recipe_vendor" and "Recipe vendor" or "Acquisition location",
                 requirements=offerText(route),instructions=route.instructions})
        end
    end
    local side,map,zone,level=travelContext()
    local trainerPreferred,trainerRank
    for index,target in ipairs(choices) do
        target.practicality,target.practicalPreferred=self:GetAcquisitionRoutePracticality(gear,target.acquisitionRoute,nil,target)
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

-- Recommendation convenience is separate from source eligibility. This is a
-- low-level travel heuristic, not a route/distance claim or a zone blacklist.
local TRAVEL_SIDE={
    ["The Barrens"]=2,["Silverpine Forest"]=2,["Durotar"]=2,["Mulgore"]=2,["Tirisfal Glades"]=2,
    ["Westfall"]=1,["Loch Modan"]=1,["Darkshore"]=1,["Elwynn Forest"]=1,["Dun Morogh"]=1,["Teldrassil"]=1,
}
for zone,side in pairs(HOME_SIDE) do TRAVEL_SIDE[zone]=side end
local ORDINARY_TRAVEL={named_drop=true,npc_container=true,object=true,vendor=true,vendor_container=true,
    recipe_drop=true,recipe_vendor=true,trainer=true}

function GetGear:GetAcquisitionRoutePracticality(gear,route,context,target)
    if not route then return "unknown" end
    -- Shared dungeons, accessible neutral quests and active quest guidance are
    -- deliberate destinations. Unknown prerequisites are never a travel veto.
    if route.kind=="dungeon" or route.kind=="quest" or route.kind=="quest_container" then return "practical" end
    if not ORDINARY_TRAVEL[route.kind] then return "unknown" end
    local side,_,zone,level=travelContext()
    if context then
        side=context.faction=="Alliance" and 1 or context.faction=="Horde" and 2
        zone=context.zone;level=context.level
    end
    if not side or type(level)~="number" then return "unknown" end
    if level>=30 then return "practical" end
    local actor=data().sources[route.source] or {}
    local service=route.serviceSide or route.offer and route.offer.side or actor.serviceSide
    -- Neutral/unknown sellers may be in shared settlements (e.g. Ratchet).
    -- Zone ownership cannot establish that their service is inconvenient.
    if (route.kind=="vendor" or route.kind=="vendor_container" or route.kind=="recipe_vendor"
        or route.kind=="trainer") and service~=1 and service~=2 then return "unknown" end
    local locations=target and {target} or route.location and {route.location} or actor.locations or {}
    if #locations==0 then return "unknown" end
    local uncertain=false
    for _,loc in ipairs(locations) do
        if zone and loc.zone==zone then return "practical",true end
        if loc.neutral==true or (data().instances or {})[loc.zone] or loc.kind=="dungeon" then return "practical" end
        local owner=TRAVEL_SIDE[loc.zone]
        local reliable=loc.verification and loc.verification~="legacy-reference"
        if owner==side and reliable then return "practical",true end
        if not owner or not reliable then uncertain=true end
    end
    return uncertain and "unknown" or "inconvenient"
end

function GetGear:GetAcquisitionPracticality(gear,context)
    if not gear or gear.bagUpgrade then return {status="practical"} end
    local routes,known=self:GetEligibleAcquisitionRoutes(gear,context)
    if known and #routes==0 and not self:GetIndependentAcquisitionAccess(gear,context) then return {status="ineligible"} end
    local inconvenient,unknown=false,not known
    for _,route in ipairs(routes) do
        local status=self:GetAcquisitionRoutePracticality(gear,route,context)
        if status=="practical" then return {status="practical",route=route} end
        if status=="unknown" then unknown=true else inconvenient=true end
    end
    -- Learned recipes and verified tradeable finished items are independent
    -- alternatives; no availability or current auction listing is invented.
    local craft=self:GetIndependentAcquisitionAccess(gear,context)
    if craft then
        return {status="practical",alternative=craft or "tradeable",remoteOriginal=inconvenient and not unknown}
    end
    if unknown or not inconvenient then return {status="unknown"} end
    return {status="inconvenient",reason="Only known ordinary sources require low-level travel into opposing territory; browse alternatives in Guide."}
end

-- Keep a substantial known upgrade or an independently confirmed empty slot.
-- Missing stats, effects or equipment data cannot prove an upgrade is trivial.
function GetGear:IsMinorAcquisitionUpgrade(gear)
    if not self.GetWeightedUpgradeEvaluation then return false end
    local effects=((gear.notes or "").." "..(gear.benefitsText or "")):lower()
    for _,term in ipairs({"equip:","on use","on-use","proc","chance on hit","set bonus","special effect"}) do
        if effects:find(term,1,true) then return false end
    end
    local comparison=self:GetGearComparison(gear,true)
    if not comparison or comparison.message or #(comparison.groups or {})==0 then return false end
    for _,group in ipairs(comparison.groups) do
        if group.emptySlot then return false end
        local score=self:ScoreComparisonGroup(gear,group)
        if score==nil then return false end
        local baseline=0
        for _,row in ipairs(group.rows or {}) do
            if type(row.old)~="number" then return false end
            baseline=baseline+math.max(0,row.old)*self:GetStatWeight(row.key,gear)
        end
        -- Only changed stats enter this lower-bound baseline, so missing
        -- unchanged attributes make this exception more generous, never stricter.
        -- A relative threshold also respects Advanced weights expressed on
        -- very small/large scales. A zero baseline cannot prove a minor gain.
        if score>0 and (baseline<=0 or score>baseline*0.25) then return false end
    end
    return true
end

function GetGear:GetAcquisitionOverlayExclusion(gear)
    if not gear or gear.bagUpgrade then return end
    local usable,reason=self:IsFactionUseEligible(gear)
    if not usable then return reason end
    if not self:HasEligibleAcquisitionSource(gear) then return "No published source route for this character's faction/class" end
    local policy=get(data().availability,gear.itemID)
    if policy and policy.overlayEligible==false then return policy.reason or "Current Forever availability unconfirmed" end
    local plan=gear.acquisitionPlan or get(data().items,gear.itemID)
    if not plan or #(plan.routes or {})==0 then return end
    if not self:HasEligibleAcquisitionSource(gear) then return "No published source route for this character's faction/class" end
    local minimum=self:GetAcquisitionMinimumLevel(gear)
    local level=call(UnitLevel,"player") or self.level
    if minimum and type(level)=="number" and minimum>level+5 then
        return "Published quest minimum is outside the next five levels"
    end
    if not (self.db and self.db.overlay and self.db.overlay.showAllValidGear) then
        local assessment=self:GetAcquisitionPracticality(gear)
        if assessment.status=="inconvenient" and self:IsMinorAcquisitionUpgrade(gear) then return assessment.reason end
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
    -- Shared dungeons/quests remain accessible, but are not evidence of a
    -- more convenient journey. Only a known local/friendly ordinary source
    -- may displace the established selection; unknown routes retain order.
    local function convenienceRank(target)
        return (target.preferred or target.clientVerified
            or target.practicalPreferred and not target.futureLevel and not target.chainUnresolved) and 0 or 1
    end
    for _,target in ipairs(useful) do
        local rank,previous=convenienceRank(target),convenienceRank(selected)
        if rank<previous or rank==previous and target.preferred and not selected.preferred then selected=target end
    end
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
    if gear and gear.bagFromInventory then return "Equip your existing bag from inventory or retrieve it from the bank; no acquisition waypoint is required." end
    local out={}
    local minimum,kind=self:GetRecipeSkillRequirement(gear)
    if minimum then out[#out+1]="Published "..kind..": "..(gear.profession or "profession").." "..minimum.."; not a yellow/green/grey skill-up threshold." end
    local normalized=self:GetNormalizedRecipeData(gear)
    if normalized and normalized.learningSkill and normalized.learningSkill~=minimum then
        out[#out+1]="Published book-learning minimum: "..gear.profession.." "..normalized.learningSkill.."; separate from the recipe/crafting minimum."
    end
    if normalized then
        local broad=#normalized.documentedDrops>40
        local omitted=0
        for _,drop in ipairs(normalized.documentedDrops) do
            if not broad or drop.dungeons then
                out[#out+1]="Recipe book #"..drop.bookItemID..": "..drop.name.." (#"..drop.npcID..")"..
                    (drop.dungeons and " — "..table.concat(drop.dungeons,", ") or " — published drop; location/classification unresolved")
            else omitted=omitted+1 end
        end
        if omitted>0 then
            out[#out+1]=omitted.." additional published enemy-drop examples; not a targeted farm. Full source list:"
            for _,book in ipairs(normalized.books) do out[#out+1]=book.evidence.url end
        end
    end
    local learning=get(data().recipeRequirements,gear and gear.itemID) or {}
    if learning.bookLearningSkill and learning.bookLearningSkill~=minimum then
        out[#out+1]="Published book-learning minimum: "..(gear.profession or "profession").." "..learning.bookLearningSkill.."; separate from the recipe/crafting minimum."
    end
    if self:GetRecipeAcquisitionKind(gear)=="broad-book-drop" then
        out[#out+1]="Physical pattern: broad/random published drop references, not a targeted farm. Listed enemy/zone examples do not confirm current loot. If tradeable, consider the Auction House or player trade; current listings are unknown."
    end
    local plan=gear and gear.acquisitionPlan or get(data().items,gear and gear.itemID)
    for _, route in ipairs(routesForCharacter(data(),plan,nil,gear)) do
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
                            local playerSide=travelContext()
                            if not side or not playerSide or side==playerSide then
                                out[#out+1]="   "..(role=="starts" and "Start: " or "Turn-in: ")..(a.name or key)..(side and (side==1 and " (Alliance route)" or " (Horde route)") or "")..(loc and " — "..loc.zone or " — location unresolved")
                            end
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
