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
C_QuestLog=nil
model.instances={['Fixture dungeon']=true}
model.sources['npc:instance']={name='Friendly quest giver',locations={{zone='Fixture dungeon',verification='published-reference'}}}
model.quests['13']={questID=13,name='Dungeon quest fixture',starts={'npc:instance'},ends={'npc:instance'}}
local dungeonQuestTarget=addon:GetAcquisitionMapTarget(plan(16,{{kind='quest',questID=13}}))
assert(dungeonQuestTarget.kind=='dungeon' and dungeonQuestTarget.role=='Quest start' and dungeonQuestTarget.boss==nil,'an in-dungeon quest giver uses entrance navigation without being relabelled a boss')
local vendor=plan(4,{{kind="vendor",source="npc:1",offer={cost={12345}}}})
assert(addon:GetAcquisitionMapTarget(vendor).role=="Equipment vendor")
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
assert(not addon:GetAcquisitionMapTarget(addon.ItemCatalog[13022]),"uncorroborated sparse Classic bow references must not create a current farm pin")
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
    noteFirst=noteFirst or target.questID==4264 and target.role=='Quest starter item' and target.kind=='directions' and not target.x
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
print("PASS acquisition navigation: 14 source scenarios, character progress, shared compact/guide pin, API fallbacks, one-marker lifecycle, native waypoint preserved, 7707 catalogue IDs/36341 class objectives; rendering requires manual client tests")
