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
model.chains["11"]={steps={10,11},routeVerified=true,prerequisitesVerified=false}
local chain=plan(2,{{kind="quest",questID=11}})
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
local vendor=plan(4,{{kind="vendor",source="npc:1",offer={cost={12345}}}})
assert(addon:GetAcquisitionMapTarget(vendor).role=="Equipment vendor")
local recipe=plan(5,{{kind="recipe_vendor",source="npc:2",bookItemID=900,offer={avail=1,cost={100}}}})
assert(addon:GetAcquisitionDirections(recipe):find("Limited listing",1,true))
local aca=plan(6,{{kind="recipe_vendor",source="npc:1",cost=240,currency="Merchant's Favor",offer={standing=6,reqfaction=3000}}})
assert(addon:GetAcquisitionDirections(aca):find("240 Merchant's Favor",1,true))
assert(addon:GetAcquisitionDirections(aca):find("Honored",1,true))
local wrapped=plan(14,{{kind="vendor",source="npc:1",offer={cost={{0,{{515,12}},{}}}}}})
assert(addon:GetAcquisitionDirections(wrapped):find("12 currency #515",1,true),"primary wrapped currency price")
local prices=plan(15,{{kind="vendor",source="npc:1",offer={cost={{100,{},{}},{0,{},{{9249,1}}}}}}})
assert(addon:GetAcquisitionDirections(prices):find("0g 1s 0c OR 1 item #9249",1,true),"alternative prices are not summed")
local boss=plan(7,{{kind="dungeon",dungeon="The Deadmines",boss="Boss fixture"}})
local dungeonRecipe=plan(8,{{kind="dungeon",dungeon="The Deadmines",boss="Boss fixture",recipe=true,bookItemID=901}})
assert(addon:GetAcquisitionMapTarget(boss).kind=="dungeon")
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
assert(addon:GetAcquisitionMapTarget(addon.ItemCatalog[250513]),"ACA plans retain researched navigation")
local lamp=addon:GetAcquisitionMapTarget(addon.ItemCatalog[9359])
assert(lamp and lamp.source=="object:142184" and lamp.bounds and not lamp.x,"new researched Captain's Chest remains an area, not a fake point")
assert(addon:GetAcquisitionDirections(addon.ItemCatalog[9359]):find("9249",1,true),"new source preserves exact key context")
assert(addon:GetAcquisitionDirections(addon.ItemCatalog[2042]):find("#65",1,true),"actual seven-stage Defias travel route")
assert(addon:GetAcquisitionDirections(addon.ItemCatalog[5780]):find("limited%-stock"),"actual reviewed limited recipe vendor")
print("PASS acquisition navigation: 13 source scenarios, character progress, shared compact/guide pin, API fallbacks, one-marker lifecycle, native waypoint preserved, 7707 catalogue IDs/36341 class objectives; rendering requires manual client tests")
