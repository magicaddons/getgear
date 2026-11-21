-- Execute the real UI and its callbacks against measured, stateful frame mocks.
-- These checks are UI evidence, not a replacement for the Forever renderer.
local root=(arg and arg[1]) or "."
local frames={}
local methods={}
local function new(kind,name,parent)
    local frame=setmetatable({kind=kind,name=name,parent=parent,children={},points={},scripts={},shown=true,width=300,height=250,text="",level=1}, {__index=methods})
    if parent then parent.children[#parent.children+1]=frame end
    frames[#frames+1]=frame
    if name then _G[name]=frame end
    return frame
end
function methods:SetSize(w,h) self.width=w;self.height=h end
function methods:SetWidth(w) self.width=w end
function methods:SetHeight(h) self.height=h end
function methods:GetWidth() return self.width end
function methods:GetHeight() return self.height end
function methods:SetPoint(...) self.points[#self.points+1]={...} end
function methods:ClearAllPoints() self.points={} end
function methods:SetText(text) self.text=tostring(text) end
function methods:GetText() return self.text end
function methods:GetStringWidth() return #self.text*6 end
function methods:GetStringHeight()
    return math.max(1,math.ceil(#self.text*6/math.max(1,self.width)))*12
end
function methods:SetScript(event,fn) self.scripts[event]=fn end
function methods:HookScript(event,fn)
    local prev=self.scripts[event]
    self.scripts[event]=function(...) if prev then prev(...) end;fn(...) end
end
function methods:Show() self.shown=true end
function methods:Hide()
    local was=self.shown;self.shown=false
    if was and self.scripts.OnHide then self.scripts.OnHide(self) end
end
function methods:IsShown() return self.shown and (not self.parent or self.parent:IsShown()) end
function methods:CreateTexture(name) return new("Texture",name,self) end
function methods:CreateFontString(name) return new("FontString",name,self) end
function methods:GetFrameLevel() return self.level end
function methods:SetFrameLevel(n) self.level=n end
function methods:GetEffectiveScale() return 1 end
function methods:GetLeft() return 0 end
function methods:GetTop() return 800 end
function methods:SetScrollChild(child) self.child=child end
function methods:SetVerticalScroll(value) self.offset=value end
function methods:GetVerticalScroll() return self.offset or 0 end
function methods:SetEnabled(value) self.enabled=value end
function methods:SetChecked(value) self.checked=value end
function methods:GetChecked() return self.checked end
local noop=function() end
for _,method in ipairs({"SetAllPoints","SetFrameStrata","SetClampedToScreen","EnableMouse","SetColorTexture",
    "SetJustifyH","SetJustifyV","SetMovable","SetToplevel","RegisterForDrag","SetNormalTexture",
    "SetHighlightTexture","SetPushedTexture","SetAutoFocus","SetNumeric","SetMaxLetters","SetTextColor",
    "SetResizable","SetResizeBounds","SetTexture","SetVertexColor","SetDesaturated","SetMinMaxValues",
    "SetValueStep","SetObeyStepOnDrag","SetValue","SetScale","ClearFocus","Raise","StartMoving",
    "StopMovingOrSizing","StartSizing","EnableMouseWheel","RegisterForClicks",
    "SetTextInsets","SetTextColor","SetAlpha","SetBackdrop","SetBackdropColor","SetBackdropBorderColor",
    "SetDisabledTexture","SetNormalFontObject","SetHighlightFontObject","SetDisabledFontObject"}) do methods[method]=noop end
function methods:SetShown(value) if value then self:Show() else self:Hide() end end
function methods:GetEffectiveScale() return 1 end
function methods:GetScript(event) return self.scripts[event] end
CreateFrame=function(kind,name,parent,template)
    local f=new(kind,name,parent)
    if template=="UICheckButtonTemplate" then f.Text=new("FontString",nil,f) end
    return f
end
UIParent=new("Frame","UIParent");Minimap=new("Frame","Minimap")
UISpecialFrames={}
UnitName=function() return "Test" end
UnitClass=function() return "Warrior","WARRIOR" end
UnitRace=function() return "Human","Human" end

local addon={level=60,classToken='WARRIOR',className='Warrior',activeTab='available'}
for f in io.lines(root..'/GetGear.toc')do
 if f:match('%.lua$')and f~='Core.lua'and f~='UI.lua'and f~='AltInventory.lua'then assert(loadfile(root..'/'..f))('GetGear',addon)end
end
UnitFactionGroup=function()return 'Alliance'end;UnitLevel=function()return 60 end
local list,slots={},{}
for _,g in ipairs(addon.EquipmentByClass.WARRIOR)do
 local t=addon:GetAcquisitionMapTarget(g)
 if t and(t.x or t.bounds)and not slots[g.slot]then list[#list+1]=g;slots[g.slot]=true end
end
for _,g in ipairs(addon.QuestBagCatalogue)do
 if g.itemID==918 then local b={};for k,v in pairs(g)do b[k]=v end;b.id='navigation_bag';b.bagUpgrade=true;b.quantity=1;b.bagSlots=g.slots;b.oldSlots={4};b.capacityGain=g.slots-4;b.slot='Bag';list[#list+1]=b end
end
addon.Gear=list
addon.db={status={},hidden={},overlay={visible=true,height=900,expanded={},minimized={},dependencyExpanded={},dependencyCollapsed={}},detail={}}
addon.GetItems=function()return list end
addon.IsGearEquipped=function()return false end
addon.GetObsoleteGearReason=function()return nil end
addon.ShouldShowOverlayStatChanges=function()return true end
addon.ShouldShowOverlayWorldDrop=function()return true end
addon.ShouldShowOverlayAcquisition=function()return true end
addon.GetCraftingMaterialRows=function()return{}end
addon.GetCombinedMaterialRows=function()return{}end
addon.GetUndocumentedCrafts=function()return{}end
addon.ComparisonInline=function()return '',true end
assert(loadfile(root..'/UI.lua'))('GetGear',addon)
local calls=0;local open=addon.OpenAcquisitionMap
-- Exercise the real button callback boundary; map math/lifecycle is covered
-- separately using the same packaged OpenAcquisitionMap implementation.
addon.OpenAcquisitionMap=function(self,g,destination,anchor,choose)
 calls=calls+1;assert(g and anchor and anchor.gear==g and destination==nil)
 assert(self:GetAcquisitionMapTarget(g),'button cannot outlive its usable source')
 return true,'tested-shared-adapter'
end
addon:InitializeUI();addon:ShowUI()
local filters=0;local checked=0
for _,filter in ipairs(addon.EquipmentSlotFilters)do
 addon:SetEquipmentSlotFilter('overlay',filter[1]);addon:SetEquipmentSlotFilter('detail',filter[1]);addon:RefreshAll()
 for _,g in ipairs(list)do
  if addon:MatchesEquipmentSlotFilter(g,filter[1])then
   local found=false
   for _,f in ipairs(frames)do
    if f.gear==g and f.destination and f:IsShown()and f.scripts.OnClick then
     local expected=addon:GetAcquisitionMapTarget(g)
     assert(f.destination.id==expected.id and f.destination.zone==expected.zone)
     f.scripts.OnClick(f,'LeftButton');found=true;checked=checked+1
    end
   end
   -- Overlay has a 32-row cap; detail independently exposes these small sets.
   assert(found,'visible equipment/slot lost its real acquisition pin: '..tostring(g.name)..'/'..filter[1])
  end
 end
 filters=filters+1
end
assert(filters==#addon.EquipmentSlotFilters and filters==17 and checked>20 and calls==checked)
assert(addon.OpenAcquisitionMap~=open)
print('PASS navigation UI: real assignment and left-click callbacks in overlay/guide across all17 slot selectors and '..checked..' visible source buttons; marker rendering checked separately with API doubles')
