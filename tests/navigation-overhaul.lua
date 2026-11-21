-- Reuse the native-map API fixture; all choices and Core callbacks stay real.
local root=arg[1]or'.';local dir=arg[0]:match('^(.*[/])')or'tests/'
local source=assert(io.open(dir..'navigation-marker-system.lua')):read('*a')
local prefix=source:sub(1,assert(source:find('-- Reported examples',1,true))-1)
local body=[=[
local generated=0;local original=a.GetAcquisitionNavigationChoices
a.GetAcquisitionNavigationChoices=function(self,...)generated=generated+1;return original(self,...)end
local core
local create=CreateFrame
CreateFrame=function(...)local f=create(...)
 function f:RegisterEvent(e)self.events=self.events or {};self.events[e]=true end
 core=f;return f
end
SlashCmdList={}
assert(loadfile(root..'/Core.lua'))('GetGear',a)
assert(core.events.QUEST_LOG_UPDATE)
local queued={};C_Timer={After=function(_,fn)queued[#queued+1]=fn end}
a.RefreshAll=function()end;a.level=30
local function pulse()
 local n=#queued;core.scripts.OnEvent(core,'QUEST_LOG_UPDATE')
 assert(#queued==n+1);queued[#queued]()
end
local bags={};for _,g in ipairs(a.QuestBagCatalogue)do bags[g.itemID]=g end
-- Initial cache uncertainty may change "Quest start" to "Next uncompleted
-- published stage" without changing the selected stage, actor or destination.
C_QuestLog={IsOnQuest=function()return false end,IsQuestFlaggedCompleted=function()return nil end}
local cold=a:GetAcquisitionMapTarget(bags[918]);local coldTarget,coldPin=click(bags[918],cold.id)
C_QuestLog.IsQuestFlaggedCompleted=function()return false end
pulse();assert(a:GetAcquisitionMarkerState()and a:GetAcquisitionMarkerState().id==coldTarget.id and coldPin:IsShown(),'quest-cache wording changed the source identity')
C_QuestLog=nil
-- Actual choices regenerate on every event, including the selected approach's
-- application of a record whose local entrance ID is only "main".
for _,id in ipairs({918,2082})do
 local g=assert(bags[id]);local choice=a:GetAcquisitionMapTarget(g)
 local t,pin=click(g,choice.id);local originalID=t.id;local n=generated
 assert(originalID==choice.id and originalID~='main')
 for i=1,4 do pulse();assert(a:GetAcquisitionMarkerState()and pin:IsShown()and a:GetAcquisitionMarkerState().id==originalID)end
 assert(generated>n,'revalidation used cached/static choices')
end
-- A real stage change clears even if its old source remains as a reference
-- choice. A plain QUEST_LOG_UPDATE on the same stage must keep the marker.
local g=bags[2082];local initial=a:GetAcquisitionMapTarget(g);click(g,initial.id)
C_QuestLog={IsOnQuest=function(id)return id==initial.questID end,IsComplete=function()return false end}
pulse();assert(not a:GetAcquisitionMarkerState(),'accepting the selected quest did not end the starter context')
local active=a:GetAcquisitionMapTarget(g);click(g,active.id);pulse();assert(a:GetAcquisitionMarkerState())
C_QuestLog.IsComplete=function()return true end
pulse();assert(not a:GetAcquisitionMarkerState(),'ready-for-turn-in did not end the active-objective context')
C_QuestLog.IsComplete=function()return false end
active=a:GetAcquisitionMapTarget(g);click(g,active.id)
C_QuestLog.IsOnQuest=function()return false end
pulse();assert(not a:GetAcquisitionMarkerState(),'abandoning a quest retained its active context')
C_QuestLog=nil
-- A native objective's text/counter can update at the same waypoint. Neither
-- that text nor transient unavailable API data ends its selected context.
local objectiveText='Collect samples (0/3)'
C_QuestLog={IsOnQuest=function(id)return id==983 end,IsComplete=function()return false end,
 GetNextWaypoint=function()return 1439,.37,.44 end,GetNextWaypointText=function()return objectiveText end}
local native=a:GetAcquisitionMapTarget(bags[2082]);assert(native.kind=='active_quest')
local nativeTarget,nativePin=click(bags[2082],native.id)
objectiveText='Collect samples (1/3)';pulse()
assert(a:GetAcquisitionMarkerState()and nativePin:IsShown()and nativePin.label.text==objectiveText,'native objective text erased or failed to update its marker')
C_QuestLog.IsOnQuest=function()return nil end;pulse();assert(a:GetAcquisitionMarkerState()and nativePin:IsShown(),'unavailable quest data became abandonment')
C_QuestLog=nil
-- Original equipment examples and every analogous structured label resolve
-- through canonical names without splitting legitimate name punctuation.
for _,id in ipairs({250523,250519})do
 local item=assert(a.ItemCatalog[id]);local t,pin=click(item)
 assert(t.zone=='Redridge Mountains'and t.x==10.4 and t.y==74.7)
 assert(pin.label.text=='Stondry Darkhammer');pulse();assert(pin:IsShown())
end
assert(a:GetAcquisitionMarkerLabel({zone='Darnassus',label='Ellandrieth, general goods (Brown Leather Satchel)',npcName='Ellandrieth'})=='Ellandrieth')
local oldRace,oldContainer=UnitRace,C_Container
UnitRace=function()return'Night Elf','NightElf'end
C_Container={GetContainerNumSlots=function()return 4 end,GetContainerNumFreeSlots=function()return 0,0 end}
local satchel
for _,bag in ipairs(a:GetBagPlanningObjectives())do if bag.itemID==4498 then satchel=bag end end
assert(satchel,'reported vendor bag was not produced by real planning')
local satchelTarget,satchelPin=click(satchel)
assert(satchelPin.label.text=='Ellandrieth'and satchelTarget.label:find('Brown Leather Satchel',1,true),'vendor details were lost or leaked into the primary map label')
UnitRace,C_Container=oldRace,oldContainer
for _,name in ipairs({'Vendor, the Patient','Trainer (Retired)',"Va'yn Moongaze"})do
 a.AcquisitionNavigationData.sources['npc:987654']={kind='npc',name=name}
 assert(a:GetAcquisitionMarkerLabel({source='npc:987654',label=name..', service (item)'})==name)
end
local labels=0
for key,name in pairs(a.AcquisitionNavigationData.npcLabels)do
 local zone,label=key:match('^(.-)|(.*)$')
 assert(a:GetAcquisitionMarkerLabel({zone=zone,label=label})==name);labels=labels+1
end
-- Native portal upgrades preserve quest/source identity. A source near a
-- cavern mouth must retain its approach instead of jumping to the portal.
C_EncounterJournal={GetDungeonEntrancesForMap=function(id)
 if id==1413 then return{{name='Wailing Caverns',position={x=.4769,y=.3498}}}end
 if id==1453 then return{{name='The Stockade',position={x=.504,y=.662}}}end
 return{}
end}
a:ResetAcquisitionNavigation();local d=a:GetAcquisitionMapTarget(bags[918]);local t,pin=click(bags[918],d.id)
assert(t.id==d.id and t.x==45.5 and t.label=='Nalpak'and pin.label.text=='Nalpak');pulse();assert(pin:IsShown())
local helm=assert(a.ItemCatalog[250498]);for _,c in ipairs(a:GetAcquisitionNavigationChoices(helm))do
 if c.dungeon=='Stormwind Stockade'then local x=click(helm,c.id);assert(x.id==c.id and x.clientVerified and x.entranceID=='main')end
end
local greaves
for _,item in pairs(a.ItemCatalog)do if item.name=='Raptorclaw Greaves'then greaves=item;break end end
assert(greaves,'reported Raptorclaw Greaves missing from catalogue')
local excavationChoices=0
for _,c in ipairs(a:GetAcquisitionNavigationChoices(greaves))do
 if c.dungeon=='Excavation Site: Wetlands'then
  local x=click(greaves,c.id);assert(x.uiMapID==1437 and x.x~=24.5)
  assert(x.entranceID=='portal-reference'or x.entranceID=='meeting-stone');excavationChoices=excavationChoices+1
 end
end
assert(excavationChoices==2,'reported dungeon item lost its separate entrance and meeting-stone choices')
-- Every reviewed definition, alias and separately labelled entrance choice.
-- Missing coordinates must use written directions, never report a blank map.
local definitions,entrances,aliases,blockedEntrances=0,0,0,0
for name,definition in pairs(a.AcquisitionNavigationData.instanceEntrances)do
 definitions=definitions+1
 local item={itemID=-1,name=name,acquisitionPlan={routes={{kind='dungeon',dungeon=name}}}}
 local choices=a:GetAcquisitionNavigationChoices(item)
 if not a:IsAcquisitionRouteAccessible(item,item.acquisitionPlan.routes[1]) then
  assert(#choices==0 and not a:HasEligibleAcquisitionSource(item), 'capital dungeon leaked into navigation')
  blockedEntrances=blockedEntrances+#definition.entrances
 elseif #definition.entrances==0 then
  C_EncounterJournal=nil;a:ResetAcquisitionNavigation()
  local ok,mode=a:OpenAcquisitionMap(item,choices[1].id);assert(ok and mode=='directions'and not a:GetAcquisitionMarkerState())
 else
  assert(#choices==#definition.entrances)
  for _,c in ipairs(choices)do click(item,c.id);entrances=entrances+1 end
 end
end
for alias,name in pairs(a.AcquisitionNavigationData.instanceEntranceAliases)do
 assert(a:GetAcquisitionInstanceName(alias)==name);aliases=aliases+1
 local item={itemID=-1,name=alias,acquisitionPlan={routes={{kind='dungeon',dungeon=alias}}}}
 if a:IsAcquisitionRouteAccessible(item,item.acquisitionPlan.routes[1]) then
  assert(#a:GetAcquisitionNavigationChoices(item)>0)
 else assert(#a:GetAcquisitionNavigationChoices(item)==0) end
end
assert(definitions>=39 and entrances+blockedEntrances>=31 and blockedEntrances>0 and aliases>=60)
assert(not a:ResolveAcquisitionMapID('Westfall',987654),'unknown explicit frame borrowed coordinates from another map')
-- Identical numerical coordinates on different maps are distinct sources;
-- preserving them in the generator must survive runtime deduplication too.
a.AcquisitionNavigationData.sources['npc:987653']={name='Frame fixture',kind='npc',locations={
 {zone='Westfall',uiMapID=52,x=20,y=30,verification='published-reference'},
 {zone='Westfall',uiMapID=1436,x=20,y=30,verification='published-reference'}}}
local frameChoices=a:GetAcquisitionNavigationChoices({itemID=-2,name='Frame fixture',acquisitionPlan={routes={{kind='vendor',source='npc:987653'}}}})
assert(#frameChoices==2 and frameChoices[1].id~=frameChoices[2].id,'different coordinate frames collapsed into one source identity')
-- Opening may show a lazily initialized map without applying its map ID.
-- The frame fallback is bounded to pending placement; browsing stays free.
local nativeOpen=C_Map.OpenWorldMap
C_Map.OpenWorldMap=function()WorldMapFrame.mapID=999;WorldMapFrame:Show()end
WorldMapFrame.SetMapID=function(self,id)self.mapID=id end
local t,pin=click(bags[2082]);assert(t.uiMapID==1439 and pin:IsShown())
WorldMapFrame.mapID=999;a:RefreshAcquisitionMapMarker();assert(not pin:IsShown(),'navigation redirected later map browsing')
C_Map.OpenWorldMap=nativeOpen
local ok,mode=a:OpenAcquisitionMap(bags[2082],'stale-selection')
assert(ok and mode=='directions'and not a:GetAcquisitionMarkerState(),'stale choice failed silently')
print('PASS navigation overhaul: real route regeneration/Core events, quest acceptance/objective/turn-in changes, reported items, '..labels..' structured labels, '..definitions..' definitions/'..entrances..' entrances/'..aliases..' aliases, native upgrades, lazy-map fallback, no native waypoint writes; synthetic only')
]=]
assert(load(prefix..body,'navigation overhaul','t',_G))()
