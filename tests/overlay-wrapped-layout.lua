-- Execute the real row factory/header/body with synthetic variable font metrics.
-- This checks geometry and refresh integration; it cannot certify live rendering.
local root=arg[1] or '.'
local source=assert(io.open(root..'/UI.lua')):read('*a')
local function section(first,last)
    local begin=assert(source:find(first,1,true));return source:sub(begin,assert(source:find(last,begin,true))-1)
end
local metrics={glyph=6,line=12}
local methods={}
local function frame(parent)return setmetatable({parent=parent,width=316,height=46,shown=true,text='',scripts={}}, {__index=methods})end
function methods:SetSize(w,h)self.width=w;self.height=h end
function methods:SetWidth(w)self.width=w end
function methods:SetHeight(h)self.height=h end
function methods:GetWidth()return self.width end
function methods:GetHeight()return self.height end
function methods:SetText(t)self.text=t end
function methods:SetPoint(...)self.point={...}end
function methods:ClearAllPoints()self.point=nil end
function methods:SetAllPoints()self.allPoints=true end
function methods:SetColorTexture()end
function methods:RegisterForClicks()end
function methods:SetHighlightTexture()end
function methods:SetTexture(value)self.texture=value end
function methods:SetScript(k,f)self.scripts[k]=f end
function methods:SetEnabled(value)self.enabled=value end
function methods:SetShown(value)self.shown=value end
function methods:Show()self.shown=true end
function methods:Hide()self.shown=false end
function methods:IsShown()return self.shown end
function methods:CreateTexture()return frame(self)end
function methods:GetStringHeight()
    local lines=0
    for line in (self.text..'\n'):gmatch('(.-)\n')do
        lines=lines+math.max(1,math.ceil(#line*metrics.glyph/self.width))
    end
    return lines*metrics.line
end
local rows,content={},frame()
local addon={}
function addon:IsItemStarred()return false end
function addon:ComparisonInline(g)return g.change or '',g.change~=nil end
function addon:GetAcquisitionSummary(g)return g.summary end
function addon:GetCraftingMaterialRows(g)return g.reagents or {} end
function addon:IsCraftMaterialsUnknown(g)return g.unknownMaterials end
local env=setmetatable({GetGear=addon,self=addon,opacity=0.8,overlayRows=rows,objContent=content,
    CreateFrame=function(_,_,parent)return frame(parent)end,
    NewText=function(parent,_,width)local f=frame(parent);f.width=width;return f end,
    NewButton=function(parent,text,w,h)local f=frame(parent);f:SetText(text);f:SetSize(w,h);return f end,
    NewIcon=function(parent,size)local f=frame(parent);f:SetSize(size,size);return f end,
    NewProfessionIcon=function(parent,size)local f=frame(parent);f:SetSize(size,size);return f end,
    NewAcquisitionPin=function(parent,size)local f=frame(parent);f:SetSize(size,size);return f end,HideItemTooltip=function()end,
    AssignAcquisitionPin=function(pin,g)pin.shown=g.pin end,SetItemIcon=function()end,
    DescribeOverlay=function()return 'Additional expanded acquisition instructions with prerequisites.'end,
    UpdateProfessionSkill=function()return false end,
    NewReagent=function(parent)return {frame=frame(parent)}end,
    UpdateReagent=function(widget,_,_,y)widget.frame:Show();widget.y=y end,
},{__index=_G})
local measure=section('local function MeasureText(', '\nlocal function NewButton(')
local helpers=section('local wishlistUI =', 'wishlistUI.detailGroups=')
local factory=section('local OVERLAY_IDENTITY_TOP =', '\nlocal matHeader =')
local header=section('local function ShowOverlayMaterialHeader(', '\nfunction GetGear:RefreshOverlay(')
local body=section('                local r = overlayRows[i] or NewOverlayRow(i)', '\n            end\n        end\n    end\n    for i=(opts.objectivesCollapsed')
local render=assert(load(measure..helpers..factory..header..'\nreturn function(gear,opts)\nlocal i,totalY=1,0\n'..body..'\nreturn r,totalY\nend','real overlay rows','t',env))()
local function y(f)return -f.point[#f.point]end
local cases=0
for _,width in ipairs({254,290,316,534})do
 for _,font in ipairs({0.8,1,1.35})do
  content.width=width;metrics.glyph=6*font;metrics.line=12*font
  for _,name in ipairs({'Mace','Blackened Defias Leggings',string.rep('Long wrapped item title ',6)})do
   for _,state in ipairs({'ordinary','expanded','minimized','materials','unknown'})do
    for _,pin in ipairs({false,true})do
     local g={id='fixture',name=name,targetLevel=14,itemID=10400,pin=pin,
        change='+5 Intellect, -3 Stamina, +3 Spell Damage, +3 Spell Healing, -1 Agility, +5 Armor',
        summary='Source: published enemy and acquisition location, with access still unverified.'}
     if state=='materials'then g.reagents={{},{}}elseif state=='unknown'then g.unknownMaterials=true end
     local opts={expanded={fixture=state=='expanded'},minimized={fixture=state=='minimized'}}
     local row,total=render(g,opts)
     assert(y(row.expand)==32 and y(row.icon)==39,'identity keeps the tightened gap below action strip')
     for _,action in ipairs({row.star,row.pin,row.minimize,row.hide})do
      if action:IsShown()then
       assert(y(action)+action.height<=27,'action strip dimensions changed')
       for _,scale in ipairs({0.64,0.8,1,1.25,1.5})do
        local function px(value)return math.floor(value*scale+0.5)end
        assert(px(y(row.expand))-px(y(action)+action.height)>=3,'scaled action/identity separation lost')
        assert(px(y(row.icon))==px(y(row.expand)+7),'scaled icon/title alignment changed')
       end
       assert(-action.point[4]+action.width<=width,'action exceeds row width')
      end
     end
     assert(row.name.width==width-52,'actions unnecessarily narrowed the name')
     local bottom=32+y(row.sub)+math.ceil(row.sub:GetStringHeight())
     assert(y(row.sub)>=7+math.ceil(row.name:GetStringHeight())+7,'level overlaps wrapped title')
     assert(row.f.width==width and row.bg.allPoints,'first/reused rows need current width and full background')
     assert(32+row.expand.height>=bottom and row.f.height>=32+row.expand.height,'title click target must cover header')
     assert(total==row.f.height+4,'scroll extent must include the entire row')
     if state=='minimized'then assert(not row.comparison.shown and not row.desc.shown and row.f.height==32+row.expand.height)
     else
      assert(y(row.comparison)>=bottom+10,'comparison overlaps header')
      assert(y(row.desc)>=y(row.comparison)+math.ceil(row.comparison:GetStringHeight())+14,'source overlaps comparison')
      assert(row.f.height>=y(row.desc)+math.ceil(row.desc:GetStringHeight()),'row clips source')
      if state=='materials'then
       assert(y(row.matTitle)>=y(row.desc)+math.ceil(row.desc:GetStringHeight())+5)
       assert(row.f.height>=row.mats[2].y+28,'last material exceeds background')
      end
     end
     cases=cases+1
    end
   end
  end
 end
end
content.width=316;metrics.glyph=6;metrics.line=12
local r=render({id='fixture',name='Mace',targetLevel=14},{expanded={},minimized={fixture=true}})
assert(y(r.sub)==26 and r.f.height==79,'ordinary header retains the separate action strip with a 2px tighter gap')
assert(source:find('local nextY = contentY',1,true) and source:find('totalY=totalY+headerHeight+4',1,true))
assert(source:find('function overlay:afterResize()',1,true) and source:find('"UI_SCALE_CHANGED"',1,true))
print('PASS wrapped overlay: '..cases..' title/width/font/state/pin combinations at five pixel scales; real geometry, click/background/scroll extents, materials and reuse')
