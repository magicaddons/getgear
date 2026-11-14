-- AH2: native map initialization is asynchronous. These are API doubles,
-- not a claim that the actual Forever map has rendered correctly.
local root=arg[1]or'.';local a={};assert(loadfile(root..'/AcquisitionNavigation.lua'))('GetGear',a)
local function frame()
 local f={shown=true,width=1000,height=800,hooks={}}
 function f:Show()self.shown=true;if self.hooks.OnShow then self.hooks.OnShow(self)end end
 function f:Hide()self.shown=false;if self.hooks.OnHide then self.hooks.OnHide(self)end end
 function f:IsShown()return self.shown end
 function f:HookScript(k,fn)self.hooks[k]=fn end
 function f:SetScript(k,fn)self.hooks[k]=fn end
 function f:GetWidth()return self.width end;function f:GetHeight()return self.height end
 function f:SetSize(w,h)self.width=w;self.height=h end
 function f:SetParent(p)self.parent=p end;function f:ClearAllPoints()end
 function f:SetPoint(...)self.point={...}end
 function f:EnableMouse()end;function f:SetFrameLevel()end;function f:GetFrameLevel()return 1 end
 function f:CreateTexture()return setmetatable({},{__index=function()return function()end end})end
 f.CreateFontString=f.CreateTexture
 return f
end
local canvas=frame();WorldMapFrame=frame();local canvasReady=true;local mapID=52
WorldMapFrame.GetCanvas=function()return canvasReady and canvas or nil end
WorldMapFrame.GetMapID=function()return mapID end
local created=0;CreateFrame=function()created=created+1;return frame()end
local nativeWrites=0
C_Map={GetMapInfo=function(id)return{name=id==52 and'Westfall'or id==21 and'Silverpine Forest'or'Ashenvale',mapID=id,parentMapID=0}end,
 OpenWorldMap=function(id)mapID=id;WorldMapFrame:Show()end,
 SetUserWaypoint=function()nativeWrites=nativeWrites+1 end,ClearUserWaypoint=function()nativeWrites=nativeWrites+1 end}
local m={items={},sources={['npc:1']={name='VendorA',locations={{zone='Westfall',uiMapID=52,x=40,y=50,verification='published-reference'}}},
 ['npc:2']={name='VendorB',locations={{zone='Westfall',uiMapID=52,x=70,y=60,verification='published-reference'}}}},quests={},chains={},maps={Westfall={52},['Silverpine Forest']={21}}}
a.AcquisitionNavigationData=m
local function gear(id,routes)m.items[tostring(id)]={routes=routes};return{itemID=id,name='Fixture'..id}end
local one=gear(1,{{kind='vendor',source='npc:1'}});local two=gear(2,{{kind='vendor',source='npc:2'}})
local messages=0;a.ShowAcquisitionDirections=function()messages=messages+1 end
assert(loadfile(root..'/MapNavigation.lua'))('GetGear',a)
canvas.width=0
local ok,mode=a:OpenAcquisitionMap(one);assert(ok and mode=='map-pending')
local active,pin=a:GetAcquisitionMarkerState();assert(active and not pin:IsShown())
canvas.width=1000;WorldMapFrame.hooks.OnUpdate(WorldMapFrame,.2);assert(pin:IsShown()and pin.point[4]==400)
-- Browsing another map after a successful draw must not open a popup later.
mapID=21;WorldMapFrame.hooks.OnUpdate(WorldMapFrame,4);assert(not pin:IsShown()and messages==0)
mapID=52;WorldMapFrame.hooks.OnUpdate(WorldMapFrame,.2);assert(pin:IsShown())
canvasReady=false;ok,mode=a:OpenAcquisitionMap(one);assert(mode=='map-pending')
WorldMapFrame.hooks.OnUpdate(WorldMapFrame,3.2);assert(messages==1 and a:GetAcquisitionMarkerState(),'fallback directions do not erase a pending target')
-- A second click replaces the pending destination; delayed readiness cannot
-- resurrect the old one. Only one GetGear-owned marker is created.
a:OpenAcquisitionMap(two);canvasReady=true;WorldMapFrame.hooks.OnUpdate(WorldMapFrame,.2)
assert(a:GetAcquisitionMarkerState().label=='VendorB'and pin.point[4]==700 and created==1)
WorldMapFrame:Hide();assert(not a:GetAcquisitionMarkerState()and not pin:IsShown())
WorldMapFrame:Show();assert(not pin:IsShown(),'normal reopen does not resurrect a closed destination')
-- ScrollContainer fallback and late map-ID transitions.
WorldMapFrame.GetCanvas=nil;WorldMapFrame.ScrollContainer={Child=canvas};a:OpenAcquisitionMap(one);assert(pin:IsShown())
C_Map.OpenWorldMap=function()mapID=21;WorldMapFrame:Show()end
ok,mode=a:OpenAcquisitionMap(two);assert(mode=='map-pending');mapID=52;WorldMapFrame.hooks.OnUpdate(WorldMapFrame,.2);assert(pin:IsShown())
C_Map.OpenWorldMap=function(id)mapID=id;WorldMapFrame:Show()end
m.instanceEntrances={['Shadowfang Keep']={entrances={{id='main',zone='Silverpine Forest',x=42.6,y=66.6,label='Published SFK approach',verification='published-reference'}}}}
m.instanceEntranceAliases={['Shadowfang Keep']='Shadowfang Keep'}
local dungeon=gear(3,{{kind='dungeon',dungeon='Shadowfang Keep',boss='Arugal'},{kind='dungeon',dungeon='Shadowfang Keep',boss='Another source'}})
assert(#a:GetAcquisitionNavigationChoices(dungeon)==1,'same practical entrance consolidates multiple sources')
ok,mode=a:OpenAcquisitionMap(dungeon);assert(mode=='map'and mapID==21 and a:GetAcquisitionMarkerState().x==42.6,'published entrance works without encounter API')
C_EncounterJournal={GetDungeonEntrancesForMap=function(id)if id==21 then return{{name='Shadowfang Keep',position={x=.44,y=.67}}}end return{}end}
a:ResetAcquisitionNavigation();a:OpenAcquisitionMap(dungeon);assert(a:GetAcquisitionMarkerState().clientVerified and a:GetAcquisitionMarkerState().x==44,'valid native entrance precedes reference approach')
-- Genuinely distinct gates remain separate, including selection of the second.
m.instanceEntrances['Shadowfang Keep'].entrances[2]={id='back',zone='Silverpine Forest',x=60,y=70,label='Distinct gate',verification='published-reference'}
local choices=a:GetAcquisitionNavigationChoices(dungeon);assert(#choices==2 and a:GetAcquisitionMapTarget(dungeon).chooseFirst)
a.ShowAcquisitionChoices=function(self,_,c)self.choices=c end
ok,mode=a:OpenAcquisitionMap(dungeon);assert(mode=='choices')
a:OpenAcquisitionMap(dungeon,choices[2].id);assert(a:GetAcquisitionMarkerState().x==60,'generic native entry cannot redirect a distinct requested gate')
assert(nativeWrites==0,'native waypoint unchanged')
print('PASS AH2 map readiness:delayed/zero canvas,late map IDs,refresh/resize/close/reopen,repeated destinations,published fallback/native priority/distinct gates/one marker;live rendering unverified')
