-- Physical label rectangles on the existing renderer, at edges and scales.
local dir=arg[0]:match('^(.*[/])')or'tests/'
local function read(name)local f=assert(io.open(dir..name));local s=f:read('*a');f:close();return s end
local base=read('navigation-marker-system.lua')
local prefix=base:sub(1,assert(base:find('local canvas=frame()',1,true))-1)
local rendering=assert(read('navigation-rendering-integrity.lua'):match('local body=%[=%[(.*)%]=%]'))
local geometry=rendering:sub(1,assert(rendering:find('local cases=',1,true))-1)
local body=[=[
local original=frame
frame=function()
 local f=original()
 function f:GetStringWidth()return math.min(self.width,#(self.text or'')*6)end
 function f:SetWidth(w)self.width=w end
 return f
end
-- Fresh marker objects must use the richer font metrics above.
local fixture={itemID=999992,name='Boundary fixture'}
a.AcquisitionNavigationData.items['999992']={routes={{kind='vendor',source='npc:999992'}}}
a.AcquisitionNavigationData.sources['npc:999992']={name='Short name',kind='npc',locations={}}
local actor=a.AcquisitionNavigationData.sources['npc:999992']
local checked=0
for _,uiScale in ipairs({.64,1,1.5})do for _,zoom in ipairs({.5,1,2})do
 WorldMapFrame.scale=uiScale;canvas.scale=zoom;canvas.left=0;canvas.bottom=0;canvas.width=1000;canvas.height=620
 viewport.left=0;viewport.bottom=0;viewport.width=1000*zoom;viewport.height=620*zoom
 for _,name in ipairs({'Short name',string.rep('Long NPC ',8)})do
  actor.name=name
  for _,x in ipairs({.1,12,50,88,99.9})do for _,y in ipairs({.1,50,99.9})do
   actor.locations={{zone='Redridge Mountains',uiMapID=1433,x=x,y=y,verification='published-reference'}}
   assert(a:OpenAcquisitionMap(fixture))
   local t,pin=a:GetAcquisitionMarkerState()
   local left=pin.label:GetLeft()*pin.label:GetEffectiveScale()
   local bottom=pin.label:GetBottom()*pin.label:GetEffectiveScale()
   local width=pin.label:GetWidth()*pin.label:GetEffectiveScale()
   local height=pin.label:GetHeight()*pin.label:GetEffectiveScale()
   local right=viewport:GetWidth()*viewport:GetEffectiveScale()
   local top=viewport:GetHeight()*viewport:GetEffectiveScale()
   assert(left>=-.001 and left+width<=right+.001,'label clips horizontal viewport')
   assert(bottom>=-.001 and bottom+height<=top+.001,'label clips vertical viewport')
   local centre=(pin:GetLeft()+pin:GetWidth()/2)*pin:GetEffectiveScale()
   local expected=math.max(0,math.min(right-width,centre-width/2))
   assert(math.abs(left-expected)<.001,'label displacement is not minimal')
   if name=='Short name'then assert(pin.label:GetWidth()<=62,'fixed empty label space caused unnecessary displacement')
   else assert(pin.label:GetWidth()==250,'long label inherited the previous short label width')end
   assert(t.x==x and t.y==y and pin.level>2001 and pin.icon:IsVisible(),'cosmetic fit changed marker')
   checked=checked+1
  end end
  for _,xy in ipairs({{.1,.1},{50,50},{99.9,99.9}})do
   local x,y=xy[1],xy[2]
   actor.locations={{zone='Redridge Mountains',uiMapID=1433,
    bounds={xMin=x,xMax=x+.01,yMin=y,yMax=y+.01},verification='published-reference',locationKind='published-region'}}
   assert(a:OpenAcquisitionMap(fixture))
   local t,pin=a:GetAcquisitionMarkerState()
   assert(not t.x and pin.area:IsShown()and not pin.icon:IsShown(),'area became a precise point')
   for _,label in ipairs({pin.label,pin.qualifier})do
    local scale=label:GetEffectiveScale()
    local l,b=label:GetLeft()*scale,label:GetBottom()*scale
    assert(l>=-.001 and l+label:GetWidth()*scale<=viewport:GetWidth()*viewport:GetEffectiveScale()+.001,'area label/qualifier clips horizontally')
    assert(b>=-.001 and b+label:GetHeight()*scale<=viewport:GetHeight()*viewport:GetEffectiveScale()+.001,'area label/qualifier clips vertically')
   end
   checked=checked+1
  end
 end
end end
-- Mivin remains a published region: a small rectangle is not an exact point.
local m=a.AcquisitionNavigationData.sources['npc:256735'].locations[1]
assert(not m.x and m.bounds.xMin==10 and m.bounds.xMax==10 and m.bounds.yMin==72.4 and m.bounds.yMax==72.8)
print('PASS label boundaries: '..checked..' edge/corner/interior/scale cases, minimal displacement, no clipping, precise marker unchanged and Mivin uncertainty preserved; synthetic font metrics only')
]=]
assert(load(prefix..geometry..body,'label boundaries','t',_G))()
