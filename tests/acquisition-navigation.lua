-- Behavioral fixtures are synthetic; the final section audits actual catalogue data.
local root=(arg and arg[1]) or "."
local addon={}
local function loadModule(name) assert(loadfile(root.."/"..name))("GetGear",addon) end
loadModule("AcquisitionNavigation.lua")
local model={items={},sources={},quests={},chains={},maps={Westfall={52}}}
addon.AcquisitionNavigationData=model
local function actor(id,name,zone,x,y)
    model.sources[id]={name=name,locations=zone and {{zone=zone,x=x,y=y,verification="published-reference"}} or {}}
end
actor("npc:1","First NPC","Westfall",40,50)
actor("npc:2","Second NPC","Westfall",60,70)
actor("npc:3","Unknown NPC")
local function plan(id,routes) model.items[tostring(id)]={routes=routes};return {itemID=id,name="Fixture #"..id} end
model.quests["10"]={questID=10,name="Simple quest",starts={"npc:1"},ends={"npc:1"}}
model.quests["11"]={questID=11,name="Second stage",starts={"npc:2"},ends={"npc:1"}}
local simple=plan(1,{{kind="quest",questID=10}})
assert(addon:GetAcquisitionMapTarget(simple).source=="npc:1","simple quest starts at quest giver")
model.quests["10"].requiredItems={{itemID=1000,name="Provided husk",quantity=1,provided=true},{itemID=1001,name="Collected fragment",quantity=2}}
local inputs=addon:GetAcquisitionDirections(simple)
assert(inputs:find("Provided by quest: 1 Provided husk",1,true) and inputs:find("Required item: 2 Collected fragment",1,true),"quest-provided deliveries remain distinct from external collection requirements")
model.quests["10"].sourceRequirements={"Published source profession: Tailoring; exact access threshold unresolved."}
assert(addon:GetAcquisitionMapTarget(simple).requirements:find("Tailoring",1,true),"source profession is visible without changing gear eligibility")
model.chains["11"]={steps={10,11},routeVerified=true,prerequisitesVerified=false}
local chain=plan(2,{{kind="quest",questID=11}})
model.quests["10"].requiredItems={}
assert(not addon:GetAcquisitionDirections(chain):find("requires physical items",1,true),"an empty published input list must not claim an item hand-in")
assert(addon:GetAcquisitionMapTarget(chain).questID==10,"unknown progress uses beginning")
C_QuestLog={IsQuestFlaggedCompleted=function(id) return id==10 end,IsOnQuest=function() return false end}
assert(addon:GetAcquisitionMapTarget(chain).questID==11,"next incomplete character stage")
assert(addon:GetAcquisitionDirections(chain):find("prerequisite/unlock rules remain unverified",1,true))
C_QuestLog.IsOnQuest=function(id) return id==11 end
C_QuestLog.GetNextWaypoint=function() return 52,.25,.35 end
C_QuestLog.GetNextWaypointText=function() return "Current client objective" end
C_Map={GetMapInfo=function(id) return {name="Westfall",mapID=id,parentMapID=0} end}
assert(addon:GetAcquisitionMapTarget(chain).kind=="active_quest")
C_QuestLog=nil
addon.AcquisitionNavigationData.quests[26]={questID=26,name="Disputed event source",starts={"npc:1"},ends={"npc:2"}}
local disputedContainer=plan(26,{{kind="quest_container",questID=26,containerItemID=906,directionsOnly=true,
    instructions="Published source locations conflict; current event access unverified."}})
local disputedTarget=addon:GetAcquisitionMapTarget(disputedContainer)
assert(disputedTarget.kind=="directions" and disputedTarget.questID==26 and not disputedTarget.x,"written-only quest containers retain exact quest identity without promoting disputed coordinates")
local split=plan(3,{{kind="quest",questID=11}})
model.chains["11"]=nil
local seenStart,seenEnd=false,false
for _, t in ipairs(addon:GetAcquisitionNavigationChoices(split)) do
    seenStart=seenStart or t.source=="npc:2" and t.role=="Quest start"
    seenEnd=seenEnd or t.source=="npc:1" and t.role=="Quest turn-in"
end
assert(seenStart and seenEnd,"different starting and turn-in NPCs")
model.quests["12"]={questID=12,name="Document quest",reqlevel=50,side=1,starts={},ends={"npc:1"},
    starterItems={{itemID=901,name="Starter document"}},starterZone="Westfall",starterInstructions="Obtain and read the document; current unlocks unverified.",
    requiredItems={{itemID=901,name="Starter document",quantity=1,provided=true,startsQuest=true}}}
local documentQuest=plan(15,{{kind="quest",questID=12}})
local documentTarget=addon:GetAcquisitionMapTarget(documentQuest)
assert(documentTarget.kind=="directions" and documentTarget.label=="Starter document" and not documentTarget.x and not documentTarget.bounds,"unknown quest progress opens starter directions before the turn-in, without inventing a starting NPC or point")
local documentDirections=addon:GetAcquisitionDirections(documentQuest)
assert(documentDirections:find("Quest starter item",1,true) and not documentDirections:find("Provided by quest",1,true),"a supplied objective flag must not imply a free quest-starting item")
C_QuestLog={IsOnQuest=function(id)return id==12 end}
for _,target in ipairs(addon:GetAcquisitionNavigationChoices(documentQuest)) do assert(target.role~="Quest starter item","an accepted quest need not be started again") end
C_QuestLog={IsOnQuest=function()return false end,IsQuestFlaggedCompleted=function(id)return id==12 end}
local finishedDocument=addon:GetAcquisitionMapTarget(documentQuest)
assert(finishedDocument and finishedDocument.role=='Completed quest — turn-in reference' and finishedDocument.source=='npc:1','direct single-quest completion allows a known return reference without inventing a starting-item origin or repeat availability')
C_QuestLog=nil
model.instances={['Fixture dungeon']=true}
model.quests['15']={questID=15,name='Book starter fixture',starts={},ends={'npc:2'},
    starterItems={{itemID=901,name='Quest book'}},starterZone='Fixture dungeon',starterInstructions='Obtain and read the published book; current availability unverified.'}
local bookStarter=addon:GetAcquisitionMapTarget(plan(31,{{kind='quest',questID=15}}))
assert(bookStarter and bookStarter.kind=='dungeon' and bookStarter.dungeon=='Fixture dungeon' and bookStarter.role=='Quest starter item' and not bookStarter.x,'a quest book in an independently known dungeon uses entrance navigation without a guessed book-floor point')
model.sources['npc:instance']={name='Friendly quest giver',locations={{zone='Fixture dungeon',verification='published-reference'}}}
model.quests['13']={questID=13,name='Dungeon quest fixture',starts={'npc:instance'},ends={'npc:instance'}}
local dungeonQuestTarget=addon:GetAcquisitionMapTarget(plan(16,{{kind='quest',questID=13}}))
assert(dungeonQuestTarget.kind=='dungeon' and dungeonQuestTarget.role=='Quest start' and dungeonQuestTarget.boss==nil,'an in-dungeon quest giver uses entrance navigation without being relabelled a boss')
model.quests['14']={questID=14,name='Escort fixture',starts={'npc:2'},ends={'npc:1'},
    objectiveZone='Fixture dungeon',objectiveInstructions='Escort the NPC,then return to the published turn-in.'}
local escort=plan(30,{{kind='quest',questID=14}})
C_QuestLog={IsOnQuest=function(id)return id==14 end}
local escortTarget=addon:GetAcquisitionMapTarget(escort)
assert(escortTarget.kind=='dungeon' and escortTarget.role=='Published active quest objective' and not escortTarget.x,'unknown active escort progress uses published instance guidance,not an assumed completed turn-in')
local savedMap=C_Map
C_Map={GetMapInfo=function()return{name='Westfall'}end}
C_QuestLog.GetNextWaypoint=function()return 52,.25,.5 end
assert(addon:GetAcquisitionMapTarget(escort).clientVerified,'a valid native objective retains priority over published guidance and quest-giver references')
C_QuestLog.GetNextWaypoint=nil;C_QuestLog.IsComplete=function()return true end
local ready=addon:GetAcquisitionMapTarget(escort)
assert(ready.role=='Quest turn-in' and ready.source=='npc:1','a reliable completed-objective flag can prefer the actual turn-in')
C_QuestLog.IsComplete=function()error('unsupported client API')end
assert(addon:GetAcquisitionMapTarget(escort).kind=='dungeon','an unsupported completion API cannot invent completed progress')
C_QuestLog.IsComplete=nil;C_QuestLog.GetNextWaypoint=function()return 0,.25,.5 end
assert(not addon:GetAcquisitionMapTarget(escort).clientVerified,'invalid native map IDs fall back to published guidance')
C_QuestLog.GetNextWaypoint=nil;model.quests['14'].objectiveSource='npc:2'
assert(addon:GetAcquisitionMapTarget(escort).source=='npc:2','a published delivery or conversation objective can use its actual NPC')
assert(addon:GetAcquisitionDirections(escort):find('Escort the NPC',1,true),'the detailed guide retains published objective instructions')
model.quests['14'].acquisitionDetails={'Guide-only qualified alternative sources.'}
assert(addon:GetAcquisitionDirections(escort):find('Guide-only qualified alternative sources.',1,true),'long source details belong in the full guide')
for _,target in ipairs(addon:GetAcquisitionNavigationChoices(escort)) do
    assert(not (target.instructions or ''):find('Guide-only',1,true),'long source notes must not expand compact map tooltips')
end
C_QuestLog=nil;C_Map=savedMap
local vendor=plan(4,{{kind="vendor",source="npc:1",offer={cost={12345}},sourceRequirements={"Requires Silverwing Sentinels - Exalted"}}})
assert(addon:GetAcquisitionMapTarget(vendor).role=="Equipment vendor")
assert(addon:GetAcquisitionMapTarget(vendor).requirements:find("Silverwing Sentinels - Exalted",1,true),"the compact pin retains a published vendor reputation requirement")
assert(addon:GetAcquisitionDirections(vendor):find("Silverwing Sentinels - Exalted",1,true),"the guide uses the same published vendor requirement")
local recipe=plan(5,{{kind="recipe_vendor",source="npc:2",bookItemID=900,offer={avail=1,cost={100}}}})
local boughtContainer=plan(17,{{kind="vendor_container",source="npc:2",containerItemID=902,offer={avail=1,cost={72000}},
    instructions="Recover the receipt book before shopping; current stock and rolls unverified."}})
assert(addon:GetAcquisitionMapTarget(boughtContainer).role=="Container vendor","the destination is a container vendor, not direct gear stock")
local boughtDirections=addon:GetAcquisitionDirections(boughtContainer)
assert(boughtDirections:find("not guaranteed equipment",1,true) and boughtDirections:find("receipt book",1,true),"random contents and vendor unlock directions remain explicit")
model.quests["20"]={questID=20,name="Alliance route fixture",side=1,starts={"npc:1"},ends={"npc:1"}}
model.quests["21"]={questID=21,name="Horde route fixture",side=2,starts={"npc:2"},ends={"npc:2"}}
local factions=plan(18,{{kind="quest",questID=20},{kind="quest",questID=21}})
local savedFaction=UnitFactionGroup
UnitFactionGroup=function()return "Horde" end
for _,target in ipairs(addon:GetAcquisitionNavigationChoices(factions)) do assert(target.questID==21,"known Horde character sees the compatible quest source") end
assert(not addon:GetAcquisitionDirections(factions):find("Alliance route fixture",1,true),"compact choices and detailed navigation filter the same source paths")
UnitFactionGroup=function()return "Alliance" end
assert(addon:GetAcquisitionMapTarget(factions).questID==20,"known Alliance character uses its own source")
local foreignVendor=plan(19,{{kind="vendor",source="npc:2",offer={side=2}}})
assert(not addon:GetAcquisitionMapTarget(foreignVendor),"an explicitly other-faction-only vendor is not an actionable destination")
UnitFactionGroup=function()return "Horde" end
C_QuestLog={IsOnQuest=function(id)return id==20 end}
local activeForeign=false
for _,target in ipairs(addon:GetAcquisitionNavigationChoices(factions)) do activeForeign=activeForeign or target.questID==20 end
assert(activeForeign,"reliable active-quest evidence overrides a stale published faction restriction")
C_QuestLog=nil
model.quests["22"]={questID=22,name="Shared stage fixture",side=3,starts={"npc:1"},ends={"npc:1"}}
model.chains["20"]={steps={22,20},routeVerified=true,prerequisitesVerified=false}
C_QuestLog={IsOnQuest=function(id)return id==22 end}
for _,target in ipairs(addon:GetAcquisitionNavigationChoices(factions)) do assert(target.questID~=22,"an active Both-faction stage cannot establish access to the opposite final reward path") end
C_QuestLog=nil;model.chains["20"]=nil
UnitFactionGroup=function()return "Unknown" end
local unknownA,unknownH=false,false
for _,target in ipairs(addon:GetAcquisitionNavigationChoices(factions)) do unknownA=unknownA or target.questID==20;unknownH=unknownH or target.questID==21 end
assert(unknownA and unknownH,"unknown faction retains qualified alternatives instead of guessing")
UnitFactionGroup=savedFaction
local savedClass=UnitClass
model.quests["20"].reqclass=3 -- Published Warrior/Paladin quest mask, not gear eligibility.
model.quests["21"].reqclass=128 -- Mage class ID8 in the client quest mask.
UnitClass=function()return "Mage","MAGE",8 end
for _,target in ipairs(addon:GetAcquisitionNavigationChoices(factions)) do assert(target.questID==21,"known Mage sees the compatible quest source even with unknown faction") end
local classContainer=plan(23,{{kind="quest_container",questID=20,containerItemID=903}})
assert(not addon:GetAcquisitionMapTarget(classContainer),"quest-class access also applies to random-container acquisition, not the gear wearer")
UnitClass=function()return "Warrior","WARRIOR",1 end
assert(addon:GetAcquisitionMapTarget(classContainer),"Warrior can navigate the published Warrior/Paladin source")
UnitClass=function()return "Paladin","PALADIN",2 end
assert(addon:GetAcquisitionMapTarget(classContainer),"Paladin is independently admitted by the same quest mask")
UnitClass=function()return "Mage","MAGE",8 end
C_QuestLog={IsOnQuest=function(id)return id==20 end}
assert(addon:GetAcquisitionMapTarget(classContainer),"actual active quest can override stale published class access")
model.chains["20"]={steps={22,20},routeVerified=true,prerequisitesVerified=false}
C_QuestLog={IsOnQuest=function(id)return id==22 end}
assert(not addon:GetAcquisitionMapTarget(classContainer),"an unrestricted shared stage does not prove access to a class-restricted final reward")
C_QuestLog=nil;model.chains["20"]=nil
UnitClass=nil
assert(addon:GetAcquisitionMapTarget(classContainer),"missing class API keeps qualified source information without guessing")
UnitClass=savedClass;model.quests["20"].reqclass=nil;model.quests["21"].reqclass=nil
local npcContainer=plan(24,{{kind="npc_container",source="npc:2",containerItemID=904,directionsOnly=true,verification="legacy-reference",
    instructions="Published Classic NPC-to-box-to-gear relation; current acquisition unverified."}})
local npcContainerTarget=addon:GetAcquisitionMapTarget(npcContainer)
assert(npcContainerTarget.kind=="directions" and not npcContainerTarget.x and npcContainerTarget.role=="Container drop source","legacy container loot opens qualified directions without a current NPC-farm point")
model.sources["npc:4"]={name="Multi-region reference",locations={
    {zone="Westfall",x=20,y=30},{zone="Redridge Mountains",x=40,y=50}}}
local multiRegion=plan(27,{{kind="named_drop",source="npc:4",directionsOnly=true,verification="legacy-reference"}})
local regionChoices=addon:GetAcquisitionNavigationChoices(multiRegion)
assert(#regionChoices==2 and regionChoices[1].zone=="Westfall" and regionChoices[2].zone=="Redridge Mountains","written references retain every independently published region")
for _,target in ipairs(regionChoices) do assert(target.kind=="directions" and not target.x and not target.bounds,"historical regions must not become current farm points") end
assert(addon:GetAcquisitionDirections(multiRegion):find("Redridge Mountains",1,true),"the full guide retains subsequent regions")
model.instances["Fixture raid"]=true
model.sources["npc:5"]={name="Raid source",locations={{zone="Fixture raid",uiMapID=999,x=20,y=30}}}
local instanceSource=plan(28,{{kind="named_drop",source="npc:5"}})
local instanceTarget=addon:GetAcquisitionMapTarget(instanceSource)
assert(instanceTarget.kind=="dungeon" and instanceTarget.dungeon=="Fixture raid" and not instanceTarget.x and not instanceTarget.y and not instanceTarget.uiMapID,"instance source coordinates are not an entrance or an accurate floor target; use the existing client entrance resolver")
model.sources["npc:6"]={name="Another raid source",locations={{zone="Fixture raid",x=70,y=80}}}
local sharedEntrance=plan(29,{
    {kind="named_drop",source="npc:5",directionsOnly=true,verification="legacy-reference",entranceOnly=true},
    {kind="named_drop",source="npc:6",directionsOnly=true,verification="legacy-reference",entranceOnly=true}})
local sharedTarget=addon:GetAcquisitionMapTarget(sharedEntrance)
assert(sharedTarget.kind=="dungeon" and sharedTarget.verification=="legacy-reference" and not sharedTarget.x,"a historical loot reference can locate a client-supplied instance entrance without claiming current NPC loot or coordinates")
assert(sharedTarget.choiceCount==1 and not sharedTarget.chooseFirst and #addon:GetAcquisitionNavigationChoices(sharedEntrance)==2,"one physical entrance opens directly while the guide retains every source")
assert(addon:GetAcquisitionDirections(npcContainer):find("not guaranteed finished equipment",1,true),"the NPC drops a box rather than guaranteeing its gear contents")
model.quests["25"]={questID=25,name="Unresolved starting volume",starts={},ends={"npc:1"},
    starterItems={{itemID=905,name="Starting volume"}},starterOriginUnresolved=true}
local unresolvedStarter=plan(25,{{kind="quest",questID=25}})
assert(not addon:GetAcquisitionMapTarget(unresolvedStarter),"an unknown item-start destination must not become a turn-in-only starting pin")
assert(addon:GetAcquisitionDirections(unresolvedStarter):find("turn-in NPC is not a starting destination",1,true))
C_QuestLog={IsOnQuest=function(id)return id==25 end}
assert(addon:GetAcquisitionMapTarget(unresolvedStarter).role=="Quest turn-in","a reliable accepted quest can use the verified turn-in destination")
C_QuestLog=nil
assert(addon:GetAcquisitionDirections(recipe):find("Limited listing",1,true))
local aca=plan(6,{{kind="recipe_vendor",source="npc:1",cost=240,currency="Merchant's Favor",offer={standing=6,reqfaction=3000}}})
assert(addon:GetAcquisitionDirections(aca):find("240 Merchant's Favor",1,true))
assert(addon:GetAcquisitionDirections(aca):find("Honored",1,true))
local wrapped=plan(14,{{kind="vendor",source="npc:1",offer={cost={{0,{{515,12}},{}}}}}})
assert(addon:GetAcquisitionDirections(wrapped):find("12 currency #515",1,true),"primary wrapped currency price")
addon.AcquisitionNavigationData.currencies={["515"]={name="Darkmoon Prize Ticket",verification="published-reference"}}
assert(addon:GetAcquisitionDirections(wrapped):find("12 Darkmoon Prize Ticket",1,true),"published currency name works without a retail currency API")
C_CurrencyInfo={GetCurrencyInfo=function() return {name=""} end}
assert(addon:GetAcquisitionDirections(wrapped):find("12 Darkmoon Prize Ticket",1,true),"empty client currency names retain the published fallback")
C_CurrencyInfo.GetCurrencyInfo=function() return {name="Localized ticket"} end
assert(addon:GetAcquisitionDirections(wrapped):find("12 Localized ticket",1,true),"valid client currency names take precedence")
C_CurrencyInfo=nil
local historical=plan(16,{{kind="named_drop",source="npc:1",directionsOnly=true,verification="legacy-reference",instructions="Current source unverified."}})
local historicalTarget=addon:GetAcquisitionMapTarget(historical)
assert(historicalTarget and historicalTarget.kind=="directions" and not historicalTarget.x and not historicalTarget.bounds,"historical written guidance must not expose a marker even when the NPC has coordinates")
local prices=plan(15,{{kind="vendor",source="npc:1",offer={cost={{100,{},{}},{0,{},{{9249,1}}}}}}})
assert(addon:GetAcquisitionDirections(prices):find("0g 1s 0c OR 1 item #9249",1,true),"alternative prices are not summed")
local boss=plan(7,{{kind="dungeon",dungeon="The Deadmines",boss="Boss fixture"}})
local dungeonRecipe=plan(8,{{kind="dungeon",dungeon="The Deadmines",boss="Boss fixture",recipe=true,bookItemID=901}})
assert(addon:GetAcquisitionMapTarget(boss).kind=="dungeon")
assert(addon:GetAcquisitionMapTarget(boss).boss=="Boss fixture","explicit researched boss information is retained")
assert(addon:GetAcquisitionMapTarget(dungeonRecipe).role=="Obtain recipe in dungeon")
local dungeonQuest=plan(9,{{kind="quest",questID=10},{kind="dungeon",dungeon="The Deadmines"}})
assert(addon:GetAcquisitionMapTarget(dungeonQuest).source=="npc:1","dungeon quest starts outside")
local multi=plan(10,{{kind="vendor",source="npc:1"},{kind="vendor",source="npc:2"}})
assert(addon:GetAcquisitionMapTarget(multi).chooseFirst)
local rare=plan(11,{{kind="named_drop",source="npc:2"}})
assert(addon:GetAcquisitionMapTarget(rare).source=="npc:2")
local random=plan(12,{})
assert(not addon:GetAcquisitionMapTarget(random),"generic random drop must not receive a pin")
local missing=plan(13,{{kind="vendor",source="npc:3"}})
assert(not addon:GetAcquisitionMapTarget(missing),"incomplete coordinates must not imply navigation")
assert(addon:GetAcquisitionDirections(missing):find("unresolved",1,true))
actor("zone:33","Fishing region","Westfall")
local fishing=plan(16,{{kind="fishing",source="zone:33"}})
assert(addon:GetAcquisitionMapTarget(fishing).role=="Fishing zone")

-- Exercise actual adapter lifecycle using frame/API doubles, never game rendering.
local frames=0
local function frame()
    local f={shown=true,width=1000,height=800,scripts={},hooks={}}
    function f:IsShown() return self.shown end
    function f:Show() self.shown=true end
    function f:Hide() self.shown=false;if self.hooks.OnHide then self.hooks.OnHide(self) end end
    function f:SetSize(w,h) self.width=w;self.height=h end
    function f:GetWidth() return self.width end
    function f:GetHeight() return self.height end
    function f:SetParent(parent) self.parent=parent end
    function f:ClearAllPoints() end
    function f:SetPoint(...) self.point={...} end
    function f:SetScript(k,fn) self.scripts[k]=fn end
    function f:HookScript(k,fn) self.hooks[k]=fn end
    function f:CreateTexture() return setmetatable({},{__index=function() return function() end end}) end
    f.CreateFontString=f.CreateTexture
    function f:EnableMouse() end
    return f
end
CreateFrame=function() frames=frames+1;return frame() end
WorldMapFrame=frame();local canvas=frame();local mapID=52
WorldMapFrame.GetCanvas=function() return canvas end
WorldMapFrame.GetMapID=function() return mapID end
C_Map.OpenWorldMap=function(id) mapID=id;WorldMapFrame:Show() end
C_Map.SetUserWaypoint=function() error("must preserve native waypoint") end
C_Map.ClearUserWaypoint=function() error("must preserve native waypoint") end
addon.ShowAcquisitionDirections=function(self,gear,target,anchor,reason) self.reason=reason end
addon.ShowAcquisitionChoices=function(self,gear,choices) self.choices=choices end
loadModule("MapNavigation.lua")
local fishOK,fishMode=addon:OpenAcquisitionMap(fishing)
assert(fishOK and fishMode=="directions" and frames==0,"zone-only fishing opens directions without a fake marker")
local ok,mode=addon:OpenAcquisitionMap(vendor);assert(ok and mode=="map")
local target,marker=addon:GetAcquisitionMarkerState();assert(target.x==40 and marker:IsShown())
assert(marker.point[4]==400 and marker.point[5]==-400,"normalized map-canvas position")
addon:OpenAcquisitionMap(rare);local _,same=addon:GetAcquisitionMarkerState();assert(marker==same and frames==1,"reuse one marker")
mapID=99;marker.scripts.OnUpdate(marker,.2);assert(not marker:IsShown(),"changing map hides marker")
mapID=52;WorldMapFrame.hooks.OnUpdate(WorldMapFrame,.2);assert(marker:IsShown(),"returning to destination restores marker")
canvas.width=500;marker.scripts.OnUpdate(marker,.2);assert(marker.point[4]==300,"resize repositions marker")
WorldMapFrame:Hide();assert(not addon:GetAcquisitionMarkerState() and not marker:IsShown(),"closing clears marker")
ok,mode=addon:OpenAcquisitionMap(multi);assert(ok and mode=="choices" and #addon.choices==2)
local id=addon.choices[2].id;ok,mode=addon:OpenAcquisitionMap(multi,id);assert(ok and mode=="map")
InCombatLockdown=function() return true end
ok,mode=addon:OpenAcquisitionMap(vendor);assert(mode=="directions" and addon.reason:find("combat"))
InCombatLockdown=nil
local entranceCalls=0
C_EncounterJournal={GetDungeonEntrancesForMap=function()
    entranceCalls=entranceCalls+1
    return {{name="The Deadmines",position={GetXY=function() return .4,.6 end}}}
end}
ok,mode=addon:OpenAcquisitionMap(boss);assert(mode=="map")
local calls=entranceCalls;addon:OpenAcquisitionMap(dungeonRecipe);assert(entranceCalls==calls,"entrance discovery cached")
model.sources["npc:2"].locations[1]={zone="Westfall",bounds={xMin=20,xMax=50,yMin=30,yMax=60},verification="published-reference"}
addon:OpenAcquisitionMap(rare);local _,area=addon:GetAcquisitionMarkerState()
assert(area:IsShown() and area.point[1]=="TOPLEFT" and area.width==150,"roaming area, not fake centroid pin")
model.sources["npc:2"].locations[1]={zone="Westfall",x=101,y=30,verification="published-reference"}
ok,mode=addon:OpenAcquisitionMap(rare);assert(mode=="directions" and not addon:GetAcquisitionMarkerState(),"bad coordinates never plotted")
model.sources["npc:2"].locations[1]={zone="Westfall",x=60,y=70,verification="published-reference"}
model.instances={FixtureDungeon=true}
model.sources["npc:2"].locations[1].zone="FixtureDungeon"
local inside=addon:GetAcquisitionMapTarget(rare);assert(inside.kind=="dungeon" and inside.dungeon=="FixtureDungeon","in-instance source redirects to entrance")
model.sources["npc:2"].locations[1].zone="Westfall"
addon:ResetAcquisitionNavigation();C_EncounterJournal=nil
ok,mode=addon:OpenAcquisitionMap(boss);assert(mode=="directions","no guessed entrance")
model.quests["10"].relatedQuests={999}
ok,mode=addon:OpenAcquisitionMap(simple);assert(mode=="directions" and addon.reason:find("not a verified chain starting point",1,true),"unknown earlier chain must not pretend final quest is actionable")
model.quests["10"].relatedQuests=nil
local popupHidden=0;addon.HideAcquisitionNavigation=function() popupHidden=popupHidden+1 end
addon:OpenAcquisitionMap(vendor);assert(popupHidden==1,"new map action closes stale directions popup")
C_Map.OpenWorldMap=nil
local globalCalls=0;OpenWorldMap=function(id) globalCalls=globalCalls+1;mapID=id;WorldMapFrame:Show() end
ok,mode=addon:OpenAcquisitionMap(vendor);assert(mode=="map" and globalCalls==1)
OpenWorldMap=nil;WorldMapFrame.SetMapID=function(self,id) mapID=id end
ShowUIPanel=function(f) f:Show() end
ok,mode=addon:OpenAcquisitionMap(vendor);assert(mode=="map")
WorldMapFrame.SetMapID=nil;ok,mode=addon:OpenAcquisitionMap(vendor);assert(mode=="directions")

-- Execute the real compact/detailed shared pin factory, checking both click paths.
local source=assert(io.open(root.."/UI.lua")):read("*a")
local block=assert(source:match("(local function NewAcquisitionPin.-)\n%-%- A single lazy popup"))
local pinFrame=frame();pinFrame.RegisterForClicks=function() end
local env=setmetatable({GetGear=addon,CreateFrame=function() return pinFrame end,HideItemTooltip=function() end},{__index=_G})
local factory=assert(load(block.."\nreturn NewAcquisitionPin,AssignAcquisitionPin","pins","t",env))
local make,assign=factory();local pin=make({},22);assign(pin,vendor);assert(pin:IsShown() and pin.width==22)
local observed
local original=addon.OpenAcquisitionMap
addon.OpenAcquisitionMap=function(self,gear,destination,anchor,choose) observed={gear,anchor,choose} end
pin.scripts.OnClick(pin,"LeftButton");assert(observed[1]==vendor and observed[2]==pin and not observed[3])
pin.scripts.OnClick(pin,"RightButton");assert(observed[3])
assign(pin,random);assert(not pin:IsShown())
addon.OpenAcquisitionMap=original
assert(source:find("local pin = NewAcquisitionPin(frame, 24)",1,true) and source:find("local pin=NewAcquisitionPin(f,22)",1,true))
assert(source:find("local directions=GetGear:GetAcquisitionDirections(gear)",1,true),"detailed guide shares model")

-- Full real catalogue: no identities, class masks or craft data modified by navigation.
addon={};C_Map=nil
local toc=assert(io.open(root.."/GetGear.toc")):read("*a")
local skip={["Core.lua"]=true,["UI.lua"]=true,["AltInventory.lua"]=true}
for path in toc:gmatch("[^\r\n]+") do if path:match("%.lua$") and not skip[path] then loadModule(path) end end
assert(addon.CatalogueAudit.items==7707 and addon.CatalogueAudit.objectives==36341)
assert(addon.AcquisitionNavigationData.audit.items==7707)
local start=os.clock();local destinations=0
for _,gear in pairs(addon.ItemCatalog) do if addon:GetAcquisitionMapTarget(gear) then destinations=destinations+1 end end
assert(os.clock()-start<5,"navigation lookup must stay cheap and make no API requests per row")
assert(destinations>1000)
assert(not addon:GetAcquisitionMapTarget(addon.ItemCatalog[1713]),"Ankh of Life remains a broad random drop")
assert(not addon:GetAcquisitionMapTarget(addon.ItemCatalog[8122]),"two sparse historical loot samples do not establish a dedicated Heraldic Headpiece farm")
assert(not addon:GetAcquisitionMapTarget(addon.ItemCatalog[5028]),"historical Sakrasis name/drop claims must not create a scepter destination")
assert(not addon:GetAcquisitionMapTarget(addon.ItemCatalog[285043]),"unknown Snarling Fang origin must not receive a misleading pin")
local historicalOmgorn=addon:GetAcquisitionMapTarget(addon.ItemCatalog[17055])
assert(historicalOmgorn and historicalOmgorn.kind=="directions" and historicalOmgorn.verification=="legacy-reference" and not historicalOmgorn.x and not historicalOmgorn.bounds,"Classic-only Changuk reference opens qualified written guidance without a current map target")
local bowContainer=false
for _,route in ipairs(addon.AcquisitionNavigationData.items["13022"].routes) do
    assert(route.kind=="quest_container" and route.containerItemID==21528,"sparse uncorroborated bow NPC references must not become a farm destination")
    bowContainer=true
end
assert(bowContainer,"a separately verified full-wrapper/quest reward join can add qualified container navigation without promoting the bow's old NPC claims")
local charr=addon:GetAcquisitionMapTarget(addon.ItemCatalog[18671])
assert(charr and charr.kind=="directions" and charr.verification=="legacy-reference" and not charr.x and not charr.bounds,"Classic item-side Baron Charr reference remains written-only despite a full reverse NPC positive")
local multicolored=addon.AcquisitionNavigationData.items["20692"]
assert(multicolored and multicolored.routes[1].kind=="quest_container" and multicolored.routes[1].containerItemID==20603,"container-only Multicolored Band retains its supported bag route rather than an invented enemy")
for _,route in ipairs(addon.AcquisitionNavigationData.items["10105"].routes) do
    if route.kind=="quest_container" and route.containerItemID==21513 then assert(route.directionsOnly,"disputed war-effort locations stay written-only in real catalogue data") end
end
local actualModel=addon.AcquisitionNavigationData
assert(actualModel.chains['6502'].steps[1]==4182 and actualModel.chains['6602'].steps[1]==4903 and not actualModel.chains['6502'].prerequisitesVerified and not actualModel.chains['6602'].prerequisitesVerified,'Drakefire navigation starts with the published full route, not only Haleh or Rexxar, while retaining prerequisite uncertainty')
for _,id in ipairs(actualModel.chains['6502'].steps) do assert(id~=99435,'SideNone same-name variant is not invented as another accepted prerequisite') end
local savedQuestAPI=C_QuestLog;C_QuestLog=nil
local helendisStart,goretoothDocument=false,false
for _,target in ipairs(addon:GetAcquisitionNavigationChoices(addon.ItemCatalog[16309])) do
    helendisStart=helendisStart or target.questID==4182 and target.source=='npc:9562' and target.role=='Quest start'
    goretoothDocument=goretoothDocument or target.questID==4903 and target.kind=='directions' and target.label=="Warlord Goretooth's Command" and not target.x
end
assert(helendisStart and goretoothDocument,'unknown progress gives the Alliance starting NPC and qualified Horde starter-document directions')
local completedEarly={};for _,id in ipairs({4182,4183,4184,4185,4186,4223,4224,4241,4242}) do completedEarly[id]=true end
C_QuestLog={IsQuestFlaggedCompleted=function(id)return completedEarly[id] or false end,IsOnQuest=function()return false end}
local noteFirst=false
for _,target in ipairs(addon:GetAcquisitionNavigationChoices(addon.ItemCatalog[16309])) do
    noteFirst=noteFirst or target.questID==4264 and target.role=='Quest starter item' and target.kind=='dungeon' and target.dungeon=='Blackrock Depths' and not target.x
    if target.source=='npc:9023' then assert(target.boss==nil,'Marshal Windsor is a quest actor, not a boss') end
end
assert(noteFirst,'reliable completion flags can lead to the note stage without inventing a note-giving NPC')
UnitFactionGroup=function()return "Horde" end
local hordeStarter=false
for _,target in ipairs(addon:GetAcquisitionNavigationChoices(addon.ItemCatalog[16309])) do
    assert(target.questID~=4182 and target.questID~=4264,"Horde navigation excludes the Alliance Drakefire path")
    hordeStarter=hordeStarter or target.questID==4903 and target.role=="Quest starter item"
end
assert(hordeStarter,"the compatible Horde starter-document route remains available")
UnitFactionGroup=function()return "Alliance" end
for _,target in ipairs(addon:GetAcquisitionNavigationChoices(addon.ItemCatalog[16309])) do assert(target.questID~=4903,"Alliance navigation excludes the Horde final reward route") end
UnitFactionGroup=savedFaction
C_QuestLog=savedQuestAPI
local vendorSeen=false
for _,target in ipairs(addon:GetAcquisitionNavigationChoices(addon.ItemCatalog[10095])) do
    vendorSeen=vendorSeen or target.source=='npc:12384' and target.role=='Container vendor' and target.zone=='Eastern Plaguelands'
end
assert(vendorSeen,'new exact grab-bag contents use Augustus through the shared container destination')
local grabDirections=addon:GetAcquisitionDirections(addon.ItemCatalog[10095])
assert(grabDirections:find("Receipt Book",1,true) and grabDirections:find("7g 20s 0c",1,true) and grabDirections:find("not guaranteed equipment",1,true),'full directions retain unlock, actual published offer and random-gear qualification')
local futureVendor=false
for _,target in ipairs(addon:GetAcquisitionNavigationChoices(addon.ItemCatalog[10381])) do futureVendor=futureVendor or target.source=='npc:12384' and target.role=='Container vendor' end
assert(futureVendor,'the same newly researched destination reaches another exact catalogue content without per-item authoring')
C_QuestLog=nil
local huumStart=false
for _,target in ipairs(addon:GetAcquisitionNavigationChoices(addon.ItemCatalog[13003])) do huumStart=huumStart or target.questID==8331 and target.source=='npc:15270' and target.role=='Quest start' end
assert(huumStart,'unknown progress for the initial Sack exchange starts with the published Huum itinerary')
local sackDirections=addon:GetAcquisitionDirections(addon.ItemCatalog[13003])
assert(sackDirections:find('Required item: 1 Abyssal Signet',1,true) and sackDirections:find('Required item: 3 Abyssal Signet',1,true),'one- and three-signets exchanges remain distinct source requirements')
assert(not actualModel.chains['8348'].prerequisitesVerified,'published Sack travel order must not become a verified mandatory prerequisite graph')
local chestFirst=false
for _,target in ipairs(addon:GetAcquisitionNavigationChoices(addon.ItemCatalog[13044])) do chestFirst=chestFirst or target.questID==8343 and target.source=='npc:15270' end
assert(chestFirst,'the distinct Chest of Spoils itinerary starts at Goldleaf Discovery, rather than assuming the Sack itinerary is its mandatory prerequisite')
local chestDirections=addon:GetAcquisitionDirections(addon.ItemCatalog[13044])
assert(chestDirections:find('Required item: 1 Abyssal Scepter',1,true) and chestDirections:find('Required item: 3 Abyssal Scepter',1,true),'scepter quantities remain separate from signets and alternative exchange fees')
assert(not actualModel.chains['8352'].prerequisitesVerified,'the Chest published travel sequence also retains mandatory-graph uncertainty')
assert(not addon:GetAcquisitionMapTarget(addon.ItemCatalog[18674]),"published-unavailable band with no accepted origin must not gain a fabricated destination")
UnitClass=function()return "Warrior","WARRIOR",1 end
local loraxSource,zigrisBox=false,false
for _,target in ipairs(addon:GetAcquisitionNavigationChoices(addon.ItemCatalog[10381])) do
    loraxSource=loraxSource or target.questID==5127 and target.source=="npc:10918"
    if target.source=="npc:9736" then
        assert(target.kind=="directions" and target.verification=="legacy-reference" and not target.x and target.zone=="Blackrock Spire","Classic Footlocker source uses written dungeon directions, not an exact current farm point")
        zigrisBox=true
    end
end
assert(loraxSource and zigrisBox,"new full source joins propagate through the same container model")
local demonDirections=addon:GetAcquisitionDirections(addon.ItemCatalog[10381])
assert(demonDirections:find("Provided by quest: 1 Blood Stained Pike",1,true) and demonDirections:find("Required item: 1 Soul Stained Pike",1,true),"provided quest tool and transformed return item are distinct from ordinary crafting")
assert(demonDirections:find("Required item: 1 Abyssal Crest",1,true) and demonDirections:find("Required item: 3 Abyssal Crest",1,true),"Bag crest alternatives remain distinct from Signet/Scepter exchanges")
UnitClass=function()return "Mage","MAGE",8 end
for _,target in ipairs(addon:GetAcquisitionNavigationChoices(addon.ItemCatalog[10381])) do assert(target.questID~=5127,"known Mage does not get the published Warrior/Paladin-only quest as an actionable source") end
UnitClass=savedClass
C_QuestLog=savedQuestAPI
local fanny=addon:GetAcquisitionMapTarget(addon.ItemCatalog[10096])
assert(fanny and fanny.questID==4286 and fanny.label=="Oralius" and fanny.zone=="Burning Steppes" and not fanny.x,"a full quest-to-container-to-gear join navigates the independently verified starting area, not an invented input farm")
local fannyDirections=addon:GetAcquisitionDirections(addon.ItemCatalog[10096])
assert(fannyDirections:find("container #11883",1,true) and fannyDirections:find("minimum level: 50",1,true) and fannyDirections:find("Alliance",1,true) and fannyDirections:find("Required item: 20 Dark Iron Fanny Pack",1,true),"indirect quest directions distinguish the random container, source level/faction and exact physical inputs from wearer eligibility")
for _,id in ipairs({4478,5029}) do
 local target=addon:GetAcquisitionMapTarget(addon.ItemCatalog[id])
 assert(target and target.bounds and not target.x,"new named rare routes retain published roaming areas rather than fake precise points")
end
for _,id in ipairs({18709,18710,18711,18712}) do
 local target=addon:GetAcquisitionMapTarget(addon.ItemCatalog[id])
 assert(target and target.source=="object:179697" and target.bounds and not target.x,"researched Arena bracers share the published chest area without a fake precise point")
end
assert(addon:GetAcquisitionDirections(addon.ItemCatalog[18712]):find("Arena Spoils possible contents",1,true),"independently positive wrapper route remains qualified as possible contents")
assert(not addon:GetAcquisitionDirections(addon.ItemCatalog[18711]):find("Arena Spoils possible contents",1,true),"a one-sided wrapper reference cannot become a positively verified container route")
assert(addon:GetAcquisitionMapTarget(addon.ItemCatalog[250513]),"ACA plans retain researched navigation")
local lamp=addon:GetAcquisitionMapTarget(addon.ItemCatalog[9359])
assert(lamp and lamp.source=="object:142184" and lamp.bounds and not lamp.x,"new researched Captain's Chest remains an area, not a fake point")
assert(addon:GetAcquisitionDirections(addon.ItemCatalog[9359]):find("9249",1,true),"new source preserves exact key context")
assert(addon:GetAcquisitionDirections(addon.ItemCatalog[2042]):find("#65",1,true),"actual seven-stage Defias travel route")
assert(addon:GetAcquisitionDirections(addon.ItemCatalog[5780]):find("limited%-stock"),"actual reviewed limited recipe vendor")
local fish=addon:GetAcquisitionMapTarget(addon.ItemCatalog[19808])
assert(fish and fish.kind=="fishing" and fish.zone=="Stranglethorn Vale" and not fish.x and not fish.bounds,"new fishing source is zone directions only")
local maskDirections=addon:GetAcquisitionDirections(addon.ItemCatalog[10025])
assert(maskDirections:find("#3379",1,true) and maskDirections:find("#3402",1,true) and maskDirections:find("Tailoring",1,true),"quest-unlocked recipe retains researched starting route and source requirements")
-- Actual shared Windsor data also serves the existing Drakefire acquisition,
-- even though this checkpoint's outside reward candidates remain inactive.
assert(actualModel.chains['4322'].steps[1]==4182 and actualModel.chains['4322'].routeVerified and not actualModel.chains['4322'].prerequisitesVerified,'reuse the completed published Windsor itinerary without claiming current mandatory prerequisites')
assert(not addon.ItemCatalog[12061] and not addon.ItemCatalog[12065],'outside candidate research must not silently activate equipment')
local beforeWindsorAPI,beforeWindsorFaction=C_QuestLog,UnitFactionGroup
UnitFactionGroup=function()return "Alliance" end
C_QuestLog={IsOnQuest=function(id)return id==4322 end}
local escort=addon:GetAcquisitionMapTarget(addon.ItemCatalog[16309])
assert(escort and escort.questID==4322 and escort.kind=='dungeon' and escort.dungeon=='Blackrock Depths' and escort.instructions:find('Escort Marshal Windsor',1,true) and not escort.x,'active escort without a native waypoint gives written dungeon guidance, not a premature outdoor turn-in')
C_QuestLog.IsComplete=function(id)return id==4322 end
local turnin=addon:GetAcquisitionMapTarget(addon.ItemCatalog[16309])
assert(turnin and turnin.source=='npc:9560' and turnin.role=='Quest turn-in','actual boolean completion can select Maxwell after the escort')
C_QuestLog.GetNextWaypoint=function()return 1428,.3,.4 end
C_QuestLog.GetNextWaypointText=function()return "Client Windsor objective" end
local native=addon:GetAcquisitionMapTarget(addon.ItemCatalog[16309])
assert(native and native.clientVerified and native.label=='Client Windsor objective','a valid client objective retains priority over published fallback and turn-in')
C_QuestLog,UnitFactionGroup=beforeWindsorAPI,beforeWindsorFaction
local windsorGuide=addon:GetAcquisitionDirections(addon.ItemCatalog[16309])
assert(windsorGuide:find('Escort Marshal Windsor',1,true) and windsorGuide:find('11464',1,true) and windsorGuide:find('11465',1,true),'same detailed guide retains escort instructions and distinct information item IDs')
-- Future candidate fixtures use actual researched quests without installing gear.
local beforeChainAPI=C_QuestLog
local temporaryGoals={5944,5466,5102}
for _,goal in ipairs(temporaryGoals) do
    assert(not actualModel.items[tostring(-goal)])
    actualModel.items[tostring(-goal)]={routes={{kind="quest",questID=goal}}}
end
C_QuestLog={IsOnQuest=function()return false end,IsQuestFlaggedCompleted=function(id)return id~=5944 and id~=5466 end}
local tirionFirst=addon:GetAcquisitionMapTarget({itemID=-5944})
assert(tirionFirst and tirionFirst.questID==5542 and tirionFirst.source=='npc:1855' and tirionFirst.zone=='Eastern Plaguelands','unverified parallel/terminal links cannot skip the full initial Tirion reference from completion flags')
local rasFirst=addon:GetAcquisitionMapTarget({itemID=-5466})
assert(rasFirst and rasFirst.questID==5382 and rasFirst.source=='npc:11216','qualified Ras itinerary starts at Eva when no reliable active stage is known')
C_QuestLog={IsOnQuest=function(id)return id==5944 end}
local taelan=addon:GetAcquisitionMapTarget({itemID=-5944})
assert(taelan and taelan.role=='Published active quest objective' and taelan.instructions:find('Escort Taelan',1,true),'an active Taelan escort uses objective guidance before a turn-in')
C_QuestLog.IsComplete=function()return true end
local lordTirion=addon:GetAcquisitionMapTarget({itemID=-5944})
assert(lordTirion and lordTirion.source=='npc:12126' and lordTirion.zone=='Western Plaguelands' and lordTirion.role=='Quest turn-in','primary terminal Tirion identity/location wins over a conflicting secondary initial-NPC turn-in')
C_QuestLog=nil
local command=addon:GetAcquisitionMapTarget({itemID=-5102})
assert(command and command.questID==5089 and command.role=='Quest starter item' and command.instructions:find('Overlord Wyrmthalak',1,true),'the Alliance Drakkisath route starts with the independently joined command document')
local commandText=addon:GetAcquisitionDirections({itemID=-5102})
assert(not commandText:find("Provided by quest: 1 General Drakkisath's Command",1,true),'provided-for does not grant the quest-starting command for free')
assert(actualModel.chains['5944'].parallelStartingReferences[3]==5544 and not actualModel.chains['5466'].routeVerified,'parallel starting tasks and the unverified Ras segment link remain explicit')
assert(not addon.ItemCatalog[13544] and not addon.ItemCatalog[13508],'research holds and a non-wearable utility do not silently become equipment')
for _,goal in ipairs(temporaryGoals) do actualModel.items[tostring(-goal)]=nil end
C_QuestLog=beforeChainAPI
-- Actual class-book, input transformation and quest-variant metadata.
local sourceGoals={7500,97169,7486,5526}
local savedSourceAPI=C_QuestLog
for _,goal in ipairs(sourceGoals) do
    assert(not actualModel.items[tostring(-goal)])
    actualModel.items[tostring(-goal)]={routes={{kind="quest",questID=goal}}}
end
C_QuestLog=nil
local cookbook=addon:GetAcquisitionMapTarget({itemID=-7500})
assert(cookbook and cookbook.role=='Quest starter item' and cookbook.kind=='dungeon' and cookbook.dungeon=='Dire Maul','a class quest book starts with obtaining/reading the book through the shared dungeon entrance')
local cookbookGuide=addon:GetAcquisitionDirections({itemID=-7500})
assert(cookbookGuide:find('Lorekeeper Kildrath',1,true) and cookbookGuide:find('possible book sources',1,true),'full guide retains the exact recipient and qualified multiple book sources')
assert(not cookbook.instructions:find('possible book sources',1,true),'long book-source alternatives remain outside the compact tooltip')
C_QuestLog={IsOnQuest=function()return false end,IsQuestFlaggedCompleted=function(id)return id==7500 end}
for _,target in ipairs(addon:GetAcquisitionNavigationChoices({itemID=-7500})) do
    assert(target.role~='Quest starter item','a reliable single-quest completion flag must not send the player to farm its starting book again; inactive candidate actors may be pruned')
end
assert(addon:GetAcquisitionDirections({itemID=-7500}):find('client reports this reward quest complete',1,true),'full guide labels completed reward references without assuming repeat availability')
C_QuestLog={IsOnQuest=function()return false end,IsQuestFlaggedCompleted=function(id)return id==7486 end}
local finishedHero=addon:GetAcquisitionMapTarget({itemID=-7486})
assert(finishedHero and finishedHero.questID==7486 and finishedHero.role:find('Completed quest',1,true),'direct goal completion needs no inference across unverified prerequisite links')
C_QuestLog=nil

assert(actualModel.quests['7498'].ends[1]=='npc:14383' and actualModel.quests['7501'].ends[1]=='npc:14382' and actualModel.quests['7504'].ends[1]=='npc:14381','identical reward names cannot collapse three different Lorekeeper recipients')
assert(actualModel.quests['97168'].side==1 and actualModel.quests['7667'].side==2 and actualModel.quests['97169'].side==nil,'new and legacy faction metadata remain distinct; Side None is not made Both')
assert(#actualModel.quests['97169'].starts==0 and #actualModel.quests['97168'].starts==0,'published delivery recipients do not become invented formal starting NPCs')
assert(actualModel.chains['97169'].steps[1]==97168 and actualModel.chains['8258'].steps[1]==7667,'same-name new and legacy stages cannot share completion identities')
C_QuestLog={IsOnQuest=function(id)return id==97169 end,IsComplete=function()return true end}
local eld=addon:GetAcquisitionMapTarget({itemID=-97169})
assert(eld and eld.source=='npc:258098' and eld.zone=='Ironforge' and eld.role=='Quest turn-in','explicit primary objective recipient plus independent NPC geography supports a published return destination')
C_QuestLog={IsOnQuest=function()return false end,IsQuestFlaggedCompleted=function(id)return id~=7486 end}
local duke=addon:GetAcquisitionMapTarget({itemID=-7486})
assert(duke and duke.questID==6804 and duke.source=='npc:13278','unverified Hydraxis cross-segment links cannot skip the initial reference from completion flags')
C_QuestLog={IsOnQuest=function(id)return id==7486 end}
local coffer=addon:GetAcquisitionMapTarget({itemID=-7486})
assert(coffer and coffer.source=='object:179551','the actual active coffer quest navigates its published objective despite an empty direct contents table')
C_QuestLog={IsOnQuest=function(id)return id==5527 end}
local relic=addon:GetAcquisitionMapTarget({itemID=-5526})
assert(relic and relic.zone=='Silithus' and relic.instructions:find('Southwind Village',1,true) and not relic.x,'unknown collection coordinates use written Southwind directions, not a fabricated object point')
assert(not addon.ItemCatalog[18398] and not addon.ItemCatalog[20133],'held supplemental and new variant rewards are not silently installed')
for _,goal in ipairs(sourceGoals) do actualModel.items[tostring(-goal)]=nil end
C_QuestLog=savedSourceAPI
print("PASS acquisition navigation: 14 source scenarios, character progress, shared compact/guide pin, API fallbacks, one-marker lifecycle, native waypoint preserved, 7707 catalogue IDs/36341 class objectives; rendering requires manual client tests")
