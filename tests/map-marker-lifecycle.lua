-- Drive real Core events and native map method hooks. Synthetic APIs cannot
-- establish the installed client's rendering or coexistence with map addons.
local root=arg[1]or'.'
local testdir=arg[0]:match('^(.*[/])')or'tests/'
local fixture=assert(io.open(testdir..'full-toc-startup.lua')):read('*a')
local prefix=fixture:sub(1,assert(fixture:find('local n=0',1,true))-1)
local body=[=[
local captured={};local hooks=0;local positions=0
local create=CreateFrame
CreateFrame=function(...)local f=create(...);captured[#captured+1]=f;return f end
methods.RegisterEvent=function(self,e)self.events=self.events or {};self.events[e]=true end
methods.HookScript=function(self,e,fn)
 hooks=hooks+1;local prev=self.scripts[e]
 self.scripts[e]=function(...)if prev then prev(...)end;fn(...)end
end
methods.Show=function(self)local was=self.shown;self.shown=true;if not was and self.scripts.OnShow then self.scripts.OnShow(self)end end
methods.Hide=function(self)local was=self.shown;self.shown=false;if was and self.scripts.OnHide then self.scripts.OnHide(self)end end
methods.SetPoint=function(self,...)positions=positions+1;self.point={...}end
methods.SetParent=function(self,p)self.parent=p end
methods.SetScale=function(self,s)self.scale=s end
methods.GetScale=function(self)return self.scale or 1 end
hooksecurefunc=function(object,name,fn)
 hooks=hooks+1;local original=object[name]
 object[name]=function(...)local result=original(...);fn(...);return result end
end
for f in io.lines(root..'/GetGear.toc')do if f:match('%.lua$')then assert(loadfile(root..'/'..f))('GetGear',addon)end end
local core;for _,f in ipairs(captured)do if f.events and f.events.QUEST_LOG_UPDATE then core=f end end
assert(core)
local canvas=frame();canvas.scale=.2;canvas.width=2000
WorldMapFrame=frame();WorldMapFrame:Show()
function WorldMapFrame:GetCanvas()return canvas end
function WorldMapFrame:GetCanvasScale()return canvas:GetScale()end
function WorldMapFrame:GetMapID()return self.mapID end
function WorldMapFrame:SetMapID(id)self.mapID=id end
function WorldMapFrame:OnMapChanged()end
function WorldMapFrame:OnCanvasScaleChanged()end
function WorldMapFrame:OnCanvasSizeChanged()end
function WorldMapFrame:RefreshAllDataProviders()end
C_Map={GetMapInfo=function(id)return {name=id==52 and 'Westfall'or'Elsewhere'}end,
 OpenWorldMap=function(id)WorldMapFrame:SetMapID(id);WorldMapFrame:Show()end,
 SetUserWaypoint=function()error('native waypoint changed')end,ClearUserWaypoint=function()error('native waypoint changed')end}
local target={id='source-a',zone='Westfall',uiMapID=52,x=40,y=50,label='Fixture',verification='published-reference'}
addon.GetAcquisitionNavigationChoices=function()return{target}end
addon.GetAcquisitionMapTarget=function()return target end
addon.RefreshAll=function()end
local queued={};C_Timer={After=function(_,fn)queued[#queued+1]=fn end}
assert(addon:OpenAcquisitionMap({itemID=1}))
local active,pin=addon:GetAcquisitionMarkerState();assert(active and pin:IsShown())
local driver=captured[#captured];assert(driver.scripts.OnEvent and not driver.scripts.OnUpdate)
core.scripts.OnEvent(core,'QUEST_LOG_UPDATE')
assert(#queued==1);queued[1]()
assert(addon:GetAcquisitionMarkerState()==active and pin:IsShown(),'ordinary quest log refresh erased unrelated acquisition')
local oldHooks=hooks
for i=1,500 do
 WorldMapFrame:RefreshAllDataProviders();WorldMapFrame:OnCanvasScaleChanged()
end
assert(hooks==oldHooks and not driver.scripts.OnUpdate,'redraws accumulated hooks or polling')
WorldMapFrame:SetMapID(21);assert(not pin:IsShown()and addon:GetAcquisitionMarkerState()==active)
WorldMapFrame:SetMapID(52);assert(pin:IsShown())
canvas:SetScale(.5);assert(pin.scale==2 and pin.point[4]==400)
canvas=frame();canvas.scale=.25;canvas.width=1600
WorldMapFrame:RefreshAllDataProviders()
assert(pin.parent==canvas and pin:IsShown()and pin.point[4]==160)
WorldMapFrame:Hide();assert(not pin:IsShown());WorldMapFrame:Show();assert(pin:IsShown())
-- A real change to the selected quest stage ends its stale context; ordinary
-- quest updates preserve the exact same choice. Other sources never clear.
target.questID=123;addon:OpenAcquisitionMap({itemID=2});addon:RevalidateAcquisitionMapMarker();assert(pin:IsShown())
target={id='new-stage',questID=124,zone='Westfall',x=60,y=50,verification='published-reference'}
addon:RevalidateAcquisitionMapMarker();assert(not addon:GetAcquisitionMarkerState()and not pin:IsShown())
-- Readiness stops after three seconds. Later real events can recover a canvas.
canvas.width=0;addon:OpenAcquisitionMap({itemID=3});assert(driver.scripts.OnUpdate)
local directions=0;addon.ShowAcquisitionDirections=function()directions=directions+1 end
driver.scripts.OnUpdate(driver,3.1);assert(not driver.scripts.OnUpdate and directions==1)
canvas.width=1600;WorldMapFrame:OnCanvasSizeChanged();assert(pin:IsShown()and not driver.scripts.OnUpdate)
addon:ClearAcquisitionMapMarker();local finalPositions=positions
WorldMapFrame:RefreshAllDataProviders();assert(positions==finalPositions and not pin:IsShown())
print('PASS marker lifecycle: real debounced Core quest event, native redraw/zoom/map/floor/canvas replacement hooks, bounded first-open readiness, quest-stage invalidation, close/reopen, no recurring updates or accumulated hooks')
]=]
assert(load(prefix..body,'real marker and Core lifecycle','t',_G))()
