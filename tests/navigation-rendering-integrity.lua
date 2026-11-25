-- Native level/geometry contract model; it cannot prove actual GPU output.
local root=arg[1]or'.';local dir=arg[0]:match('^(.*[/])')or'tests/'
local file=assert(io.open(dir..'navigation-marker-system.lua'));local source=file:read('*a');file:close()
local prefix=source:sub(1,assert(source:find('local canvas=frame()',1,true))-1)
local body=[=[
local basic=frame
local function factors(point)
 return point:find('LEFT')and 0 or point:find('RIGHT')and 1 or .5,
        point:find('TOP')and 1 or point:find('BOTTOM')and 0 or .5
end
frame=function()
 local f=basic();f.shown=true;f.level=10;f.strata='HIGH';f.alpha=1;f.height=14
 function f:GetParent()return self.parent end
 function f:GetEffectiveScale()return self.scale*(self.parent and self.parent:GetEffectiveScale()or 1)end
 function f:GetEffectiveAlpha()return self.alpha*(self.parent and self.parent:GetEffectiveAlpha()or 1)end
 function f:GetAlpha()return self.alpha end;function f:SetAlpha(v)self.alpha=v end
 function f:IsVisible()return self.shown and(not self.parent or self.parent:IsVisible())end
 function f:SetFrameLevel(v)self.level=v end;function f:GetFrameLevel()return self.level end
 function f:SetFrameStrata(v)self.strata=v end;function f:GetFrameStrata()return self.strata end
 function f:SetAllPoints(relative)self.all=relative or self.parent end
 function f:GetWidth()return self.all and self.all:GetWidth()or self.width end
 function f:GetHeight()return self.all and self.all:GetHeight()or self.height end
 function f:SetTexture(v)self.texture=v end;function f:GetTexture()return self.texture end
 function f:GetText()return self.text end
 function f:GetPoint()if self.point then return (table.unpack or unpack)(self.point)end end
 function f:GetLeft()
  if self.all then return self.all:GetLeft()*self.all:GetEffectiveScale()/self:GetEffectiveScale()end
  if not self.point then return self.left or 0 end
  local p=self.point;local ax=factors(p[1]);local rx=factors(p[3]);local r=p[2]
  return (r:GetLeft()+r:GetWidth()*rx)*r:GetEffectiveScale()/self:GetEffectiveScale()+(p[4]or 0)-self:GetWidth()*ax
 end
 function f:GetBottom()
  if self.all then return self.all:GetBottom()*self.all:GetEffectiveScale()/self:GetEffectiveScale()end
  if not self.point then return self.bottom or 0 end
  local p=self.point;local _,ay=factors(p[1]);local _,ry=factors(p[3]);local r=p[2]
  return (r:GetBottom()+r:GetHeight()*ry)*r:GetEffectiveScale()/self:GetEffectiveScale()+(p[5]or 0)-self:GetHeight()*ay
 end
 function f:CreateTexture()local child=frame();child.parent=self;return child end
 f.CreateFontString=f.CreateTexture
 return f
end
-- FrameXML's manager starts at 2000, and exploration is a native pin above
-- that baseline. The old Child+100 is mathematically obscured at these levels.
local topMost,topRange=2810,1
WorldMapFrame=frame();WorldMapFrame.scale=.8
local canvas=frame();canvas.parent=WorldMapFrame;canvas.scale=.6956087215218
canvas.width=1200.0000610352;canvas.height=668;canvas.left=180;canvas.bottom=90
local viewport=frame();viewport.parent=WorldMapFrame;viewport.left=100;viewport.bottom=50
viewport.width=1000;viewport.height=620
WorldMapFrame.ScrollContainer=viewport;viewport.Child=canvas
function WorldMapFrame:GetCanvas()return canvas end
function WorldMapFrame:GetCanvasContainer()return viewport end
function WorldMapFrame:GetCanvasScale()return canvas.scale end
function WorldMapFrame:GetMapID()return self.mapID end
function WorldMapFrame:GetPinFrameLevelsManager()return{GetValidFrameLevel=function(_,kind,index)assert(kind=='PIN_FRAME_LEVEL_TOPMOST');return topMost+math.min(index or 1,topRange)-1 end}end
local infos={};for zone,ids in pairs(a.AcquisitionNavigationData.maps)do for _,id in ipairs(ids)do infos[id]={name=zone,mapType=3}end end
C_Map={GetMapInfo=function(id)return infos[id]end,OpenWorldMap=function(id)WorldMapFrame.mapID=id end,
 SetUserWaypoint=function()error('native waypoint write')end,ClearUserWaypoint=function()error('native waypoint clear')end}
a.db={overlay={},hidden={},status={}};a.classToken='PRIEST';a.level=31
local bags={};for _,g in ipairs(a.QuestBagCatalogue)do bags[g.itemID]=g end
local directionCalls=0
a.ShowAcquisitionDirections=function()directionCalls=directionCalls+1 end
for _,id in ipairs({250523,250519}) do
 local g=a.ItemCatalog[id];local t=assert(a:GetAcquisitionMapTarget(g))
 assert(not t.x and t.instructions:find('disagree',1,true))
 local ok,mode=a:OpenAcquisitionMap(g,t.id)
 assert(ok and mode=='directions' and not a:GetAcquisitionMarkerState(),'unresolved vendor precision must not be rendered as an exact marker')
end
assert(directionCalls==2)
local cases={{a.ItemCatalog[228175],'npc:256732','Alynsia'},{a.ItemCatalog[228176],'npc:256732','Alynsia'},
 {bags[2082],nil,nil},{a.ItemCatalog[4835],'npc:2679','Wenna Silkbeard'},
 {a.ItemCatalog[7057],'npc:1346','Georgio Bolero'}}
local checked=0
for _,case in ipairs(cases)do
 local gear=assert(case[1]);local choice
 for _,t in ipairs(a:GetAcquisitionNavigationChoices(gear))do if (not case[2]or t.source==case[2])and t.x and not t.chainUnresolved then choice=t;break end end
 assert(choice,'reported route has no precise destination: '..gear.name)
 for _,uiScale in ipairs({.64,.8,1.2})do for _,zoom in ipairs({.05,.6956087215218,1,4})do
  WorldMapFrame.scale=uiScale;canvas.scale=zoom
  assert(a:OpenAcquisitionMap(gear,choice.id))
  local t,pin=a:GetAcquisitionMarkerState()
  assert(pin.level>2001 and pin.level>topMost,'owned pin was occluded by exploration/native overlays')
  local expectedX=(canvas:GetLeft()+canvas:GetWidth()*t.x/100)*canvas:GetEffectiveScale()
  local expectedY=(canvas:GetBottom()+canvas:GetHeight()*(1-t.y/100))*canvas:GetEffectiveScale()
  assert(math.abs((pin:GetLeft()+pin:GetWidth()/2)*pin:GetEffectiveScale()-expectedX)<.00001)
  assert(math.abs((pin:GetBottom()+pin:GetHeight()/2)*pin:GetEffectiveScale()-expectedY)<.00001)
  assert(pin.icon:IsVisible()and pin.label:IsVisible()and pin.icon:GetEffectiveAlpha()==1)
  if case[3]then assert(pin.label.text==case[3])end
  local d=a:GetAcquisitionMarkerDiagnostics()
  local dx,dy=d.positionErrorPixels:match('dx=([%d.-]+) dy=([%d.-]+)')
  assert(d.iconParent==d.labelParent and math.abs(tonumber(dx))<.01 and math.abs(tonumber(dy))<.01)
  assert(d.markerRect~='unavailable'and d.iconRect~='unavailable'and d.labelRect~='unavailable')
  checked=checked+1
 end end
end
-- Bounds are explicitly areas, regardless of size. No corner masquerades as
-- an NPC destination; source names remain intact and uncertainty is separate.
local fixture={itemID=999991,name='Area'}
a.AcquisitionNavigationData.items['999991']={routes={{kind='vendor',source='npc:1347'}}}
assert(a:OpenAcquisitionMap(fixture))
local t,pin=a:GetAcquisitionMarkerState()
assert(t.locationKind=='conflicting-evidence'and not pin.icon:IsShown()and pin.area:IsShown())
assert(pin.label.point[1]=='CENTER'and pin.label.text=='Alexandra Bolero'and pin.qualifier:IsShown())
-- A pan can leave a logically visible frame fully outside the viewport.
-- Diagnostics must expose that condition without moving native waypoints.
canvas.left=-100000;a:RefreshAcquisitionMapMarker()
local d=a:GetAcquisitionMarkerDiagnostics()
assert(d.markerVisible and d.markerIntersectsViewport==false and d.labelIntersectsViewport==false)
canvas.left=180;canvas.width=0;a:RefreshAcquisitionMapMarker()
assert(a:GetAcquisitionMarkerDiagnostics().placementFailure=='canvas-size-invalid')
canvas.width=1200;topMost=4500;topRange=200;a:RefreshAcquisitionMapMarker()
assert(pin.level==4700,'custom registered overlay level range was ignored')
WorldMapFrame.GetPinFrameLevelsManager=nil;a:RefreshAcquisitionMapMarker();assert(pin.level>=2100)
print('PASS rendering integrity: '..checked..' reported-route scale/zoom combinations, native exploration and registered custom overlay levels, pixel geometry, texture/label alpha and attachment, area semantics, viewport diagnostics; synthetic only')
]=]
assert(load(prefix..body,'navigation rendering integrity','t',_G))()
