-- Real packaged source/data; native map API doubles do not prove game rendering.
local root=arg[1] or '.'
local a={};local created={};local side='Alliance';local level=30
UnitFactionGroup=function()return side end
UnitLevel=function()return level end
UnitClass=function()return 'Warrior','WARRIOR',1 end
local function frame()
 local f={shown=true,width=3000,height=2000,scale=1,scripts={},hooks={}}
 function f:SetScript(k,fn)self.scripts[k]=fn end
 function f:HookScript(k,fn)self.hooks[k]=fn end
 function f:Show()self.shown=true;if self.hooks.OnShow then self.hooks.OnShow(self)end end
 function f:Hide()self.shown=false;if self.hooks.OnHide then self.hooks.OnHide(self)end end
 function f:IsShown()return self.shown end
 function f:SetSize(w,h)self.width=w;self.height=h end
 function f:GetWidth()return self.width end;function f:GetHeight()return self.height end
 function f:SetScale(v)self.scale=v end;function f:GetScale()return self.scale end
 function f:SetParent(v)self.parent=v end;function f:ClearAllPoints()self.point=nil end
 function f:SetPoint(...)self.point={...}end
 function f:EnableMouse()end;function f:SetFrameLevel()end;function f:SetFrameStrata()end
 function f:GetFrameLevel()return 10 end;function f:GetFrameStrata()return 'HIGH' end
 function f:SetText(v)self.text=v end;function f:SetWidth(w)self.width=w end
 function f:SetAllPoints()end;function f:SetTexture()end;function f:SetColorTexture()end
 f.CreateTexture=frame;f.CreateFontString=frame
 return f
end
CreateFrame=function()local f=frame();created[#created+1]=f;return f end
for file in io.lines(root..'/GetGear.toc')do
 if file:match('%.lua$')and file~='Core.lua'and file~='UI.lua'and file~='AltInventory.lua'then assert(loadfile(root..'/'..file))('GetGear',a)end
end
a.db={overlay={},hidden={},status={}};a.level=level;a.classToken='WARRIOR'
local infos={};for zone,ids in pairs(a.AcquisitionNavigationData.maps)do
 for _,id in ipairs(ids)do infos[id]={name=zone,mapID=id,parentMapID=0,mapType=3}end
end
local canvas=frame();canvas.scale=.2
WorldMapFrame=frame();WorldMapFrame.scripts.OnUpdate=function()end
local nativeUpdate=WorldMapFrame.scripts.OnUpdate
WorldMapFrame.GetCanvas=function()return canvas end
WorldMapFrame.GetCanvasScale=function()return canvas.scale end
WorldMapFrame.GetMapID=function(self)return self.mapID end
local waypoint={uiMapID=123,position={x=.2,y=.7}}
C_Map={GetMapInfo=function(id)return infos[id]end,GetBestMapForUnit=function()return nil end,
 OpenWorldMap=function(id)WorldMapFrame.mapID=id;WorldMapFrame:Show()end,
 GetUserWaypoint=function()return waypoint end,
 SetUserWaypoint=function()error('native waypoint write')end,ClearUserWaypoint=function()error('native waypoint clear')end}
local directions=0
a.ShowAcquisitionDirections=function(self,g,t,anchor,reason)directions=directions+1;self.reason=reason end
a.ShowAcquisitionChoices=function(self,g,choices)self.choices=choices end
local bootFrame,bootOpen=WorldMapFrame,C_Map.OpenWorldMap
local bootGear;for _,g in ipairs(a.QuestBagCatalogue)do if g.itemID==2082 then bootGear=g end end
assert(bootGear);local bootID=a:GetAcquisitionMapTarget(bootGear).id
WorldMapFrame=nil;local queuedMap
C_Map.OpenWorldMap=function(id)queuedMap=id end
local bootOK,bootMode=a:OpenAcquisitionMap(bootGear,bootID)
assert(bootOK and bootMode=='map-pending'and not select(2,a:GetAcquisitionMarkerState()):IsShown())
WorldMapFrame=bootFrame;WorldMapFrame.mapID=queuedMap
a:RefreshAcquisitionMapMarker()
assert(select(2,a:GetAcquisitionMarkerState()):IsShown(),'first marker recovers after native map addon creation')
C_Map.OpenWorldMap=bootOpen
local function click(g,id)
 local ok,mode=a:OpenAcquisitionMap(g,id)
 if mode=='choices'then assert(a.choices and #a.choices>1);ok,mode=a:OpenAcquisitionMap(g,a.choices[1].id)end
 assert(ok and mode=='map',tostring(g.name)..': '..tostring(mode)..' '..tostring(a.reason))
 local t,pin=a:GetAcquisitionMarkerState();assert(pin:IsShown()and pin.parent==canvas)
 local x,y=t.x,t.y;if not x then x,y=t.bounds.xMin,t.bounds.yMin end
 assert(math.abs(pin.point[4]*pin.scale/canvas.width-x/100)<.000001)
 assert(math.abs(-pin.point[5]*pin.scale/canvas.height-y/100)<.000001)
 assert(math.abs(pin.scale*canvas.scale-1)<.000001,'pin compensates actual canvas zoom')
 if t.x then assert(pin.width==28 and pin.height==32,'constant icon size before inherited scales')end
 return t,pin
end
-- Reported examples resolve through the same code as equipment and recipes.
local examples={};for _,g in ipairs(a.QuestBagCatalogue)do
 if g.name=="Wizbang's Gunnysack"or g.name=='Hunting Satchel'or g.name=='Deviate Hide Pack'then examples[g.name]=g;click(g)end
end
assert(examples["Wizbang's Gunnysack"]and examples['Hunting Satchel']and examples['Deviate Hide Pack'])
local dev=a:GetAcquisitionMapTarget(examples['Deviate Hide Pack'])
assert(dev.questID==1486 and dev.approachOnly and dev.coordinateScope=='continent-only')
assert(dev.publishedEntrance and dev.zone=='The Barrens'and dev.x~=51.8,'continent sentinel is not a precise local NPC pin')
local stockade;for _,g in pairs(a.ItemCatalog)do
 if g.slot=='Hands'then for _,t in ipairs(a:GetAcquisitionNavigationChoices(g))do
  if t.dungeon=='Stormwind Stockade'then stockade=g;local resolved=click(g,t.id)
   assert(resolved.zone=='Stormwind City'and resolved.coordinateKind=='outdoor-entrance-approach');break end
 end end
 if stockade then break end
end
assert(stockade,'catalogue Hands/Stockade reproduction')
for alias,canonical in pairs(a.AcquisitionNavigationData.instanceEntranceAliases)do
 assert(a:GetAcquisitionInstanceName(alias)==canonical,'instance alias lost: '..alias)
end
for _,id in ipairs({273811,273817,273820})do
 local g=assert(a.ItemCatalog[id]);local found=false
 for _,t in ipairs(a:GetAcquisitionNavigationChoices(g))do
  if t.kind=='dungeon'and t.dungeon=='Stormwind Stockade'then
   local resolved=click(g,t.id);assert(resolved.zone=='Stormwind City'and resolved.publishedEntrance)
   found=true
  end
 end
 assert(found,'named-drop alias must retain reviewed city entrance: '..id)
end
-- Every catalogue slot and route type with usable reviewed data uses the adapter.
local slots,kinds,seen={}, {},{};local clicks=0
for _,g in pairs(a.ItemCatalog)do
 for _,t in ipairs(a:GetAcquisitionNavigationChoices(g))do
  if (t.x and t.y or t.bounds)and not t.chainUnresolved and t.verification~='legacy-reference'and a.AcquisitionNavigationData.maps[t.zone]then
   local key=(g.slot or '?')..'|'..(t.acquisitionRoute and t.acquisitionRoute.kind or t.kind)
   if not seen[key]then seen[key]=true;click(g,t.id);clicks=clicks+1;slots[g.slot or '?']=true;kinds[t.acquisitionRoute and t.acquisitionRoute.kind or t.kind]=true end
  end
 end
end
-- The current catalogue has four Back records, with no reviewed point/area
-- routes. Exercise that slot through the shared adapter without inventing a
-- location for those real items; the catalogue audit retains their data gaps.
local back={};for k,v in pairs(examples['Hunting Satchel'])do back[k]=v end
back.slot='Back';click(back);slots.Back=true
for _,slot in ipairs({'Head','Neck','Shoulder','Back','Chest','Wrist','Hands','Waist','Legs','Feet','Ring','Trinket','Main Hand','Off Hand','Ranged'})do
 -- The catalogue uses Shoulders/Wrists plural where appropriate.
 assert(slots[slot]or slots[slot..'s'],'uncovered catalogue slot '..slot)
end
assert(kinds.quest and kinds.dungeon and kinds.vendor and kinds.trainer and kinds.recipe_vendor)
local g=examples['Hunting Satchel'];local t,pin=click(g);local first=pin
local driver=created[2];assert(driver and not driver.scripts.OnUpdate)
local function pump(dt)
 if driver.scripts.OnUpdate then driver.scripts.OnUpdate(driver,dt) else a:RefreshAcquisitionMapMarker() end
end
for _,s in ipairs({.05,.2,.7,1,2,4})do canvas.scale=s;pump(.2);click(g)end
canvas.width=1500;pump(.2);click(g)
WorldMapFrame:Hide();assert(not pin:IsShown());WorldMapFrame:Show();assert(pin:IsShown())
WorldMapFrame.mapID=-99;pump(4);assert(not pin:IsShown()and directions==0)
WorldMapFrame.mapID=t.uiMapID;pump(.2);assert(pin:IsShown())
canvas.width=0;local ok,mode=a:OpenAcquisitionMap(g);assert(ok and mode=='map-pending')
pump(3.1);assert(directions==1 and a.reason:find('not confirmed',1,true))
canvas.width=1500;pump(.2);assert(pin:IsShown())
assert(first==select(2,a:GetAcquisitionMarkerState())and #created==2,'one marker plus one independent driver')
assert(WorldMapFrame.scripts.OnUpdate==nativeUpdate and waypoint==C_Map.GetUserWaypoint(),'other map scripts/waypoint preserved')
-- A known mismatching explicit map must not borrow another map's coordinate space.
local zone=t.zone;local wrong=987654;infos[wrong]={name='Different city',mapID=wrong}
assert(not a:ResolveAcquisitionMapID(zone,wrong))
assert(not a:ResolveAcquisitionMapID('Unresolved test zone'))
local original=C_Map.OpenWorldMap;C_Map.OpenWorldMap=function()error('restricted API')end
ok,mode=a:OpenAcquisitionMap(g);assert(mode=='directions'and not a:GetAcquisitionMarkerState())
C_Map.OpenWorldMap=original
-- First native open can precede creation of WorldMapFrame itself, not merely
-- a ready canvas. The latest destination must survive that loading boundary.
local nativeMap=WorldMapFrame;WorldMapFrame=nil
C_Map.OpenWorldMap=function()end
ok,mode=a:OpenAcquisitionMap(g);assert(ok and mode=='map-pending'and not pin:IsShown())
local pending=a:GetAcquisitionMarkerState();assert(pending and pending.uiMapID)
WorldMapFrame=nativeMap;WorldMapFrame.mapID=pending.uiMapID
pump(.2);assert(pin:IsShown()and pin.parent==canvas)
C_Map.OpenWorldMap=original
for _,f in ipairs({'Alliance','Horde'})do side=f;for _,n in ipairs({1,15,30,60})do level=n;click(examples['Deviate Hide Pack'])end end
a:ClearAcquisitionMapMarker();assert(not pin:IsShown()and not a:GetAcquisitionMarkerState())
print('PASS shared marker system: actual bag/Hands-Stockade examples, '..clicks..' slot/route pairs, inverse zoom/native anchor math, incomplete/mismatched maps, async driver, close/reopen/resize/repeated clicks, both factions/levels, owned lifecycle and untouched waypoint; synthetic rendering only')
