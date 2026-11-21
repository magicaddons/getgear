local root=arg[1] or '.';local a={}
for _,f in ipairs({'GuideState.lua','StatPriorities.lua','GearRelevance.lua'})do assert(loadfile(root..'/'..f))('GetGear',a)end
local eventFrame
CreateFrame=function()local f={RegisterEvent=function()end,SetScript=function(self,key,fn)self[key]=fn end};eventFrame=f;return f end
SlashCmdList={};UnitLevel=function()return 15 end
assert(loadfile(root..'/Core.lua'))('GetGear',a)
local first={schemaVersion=4,status={item_123='skipped'},hidden={item_456=true},overlay={showAllValidGear=true,visible=false},detail={scale=0.9},
    statPriorities={mode='custom',priority='ITEM_MOD_SPIRIT_SHORT',weights={ITEM_MOD_SPIRIT_SHORT=5,ITEM_MOD_INTELLECT_SHORT=3,ITEM_MOD_STAMINA_SHORT=1}}}
GetGear_CharacterDB=first;eventFrame.OnEvent(nil,'ADDON_LOADED','GetGear')
assert(a.db==first and a:GetStatPriorityMode()=='custom' and a.db.statPriorities.weights.ITEM_MOD_SPIRIT_SHORT==5)
assert(a.db.status.item_123=='skipped' and a.db.hidden.item_456 and a.db.overlay.showAllValidGear and a.db.detail.scale==0.9)
GetGear_CharacterDB={schemaVersion=4};eventFrame.OnEvent(nil,'ADDON_LOADED','GetGear')
assert(a:GetStatPriorityMode()=='balanced','older schema4 saves receive a non-destructive Balanced default')
a:SetStatPriorityMode('priority');a:SetPriorityStat('ITEM_MOD_INTELLECT_SHORT')
GetGear_CharacterDB=first;eventFrame.OnEvent(nil,'ADDON_LOADED','GetGear')
assert(a:GetStatPriorityMode()=='custom' and a.db.statPriorities.priority=='ITEM_MOD_SPIRIT_SHORT','other character preferences are independent')
a.classToken='PRIEST'
-- Execute the complete real settings section, including display callbacks and
-- field focus events. Geometry is synthetic; real font/client rendering is not.
local frames={};local methods={}
for _,key in ipairs({'SetFrameStrata','SetFrameLevel','SetToplevel','SetAutoFocus','SetMaxLetters','SetMinMaxValues','SetValueStep','SetObeyStepOnDrag','EnableMouseWheel'}) do methods[key]=function()end end
methods.SetSize=function(self,w,h)self.width=w;self.height=h end
methods.SetWidth=function(self,w)self.width=w end;methods.SetHeight=function(self,h)self.height=h end
methods.GetWidth=function(self)return self.width end;methods.GetHeight=function(self)return self.height end
methods.SetPoint=function(self,...)self.point={...}end
methods.ClearAllPoints=function(self)self.point=nil end
methods.SetText=function(self,text)self.text=text;if self.OnTextChanged then self.OnTextChanged(self,false)end end
methods.GetText=function(self)return self.text end
methods.SetTextColor=function(self,...)self.color={...}end
methods.SetEnabled=function(self,value)self.enabled=value end
methods.SetScript=function(self,key,fn)self[key]=fn end
methods.HookScript=function(self,key,fn)local old=self[key];self[key]=function(...)if old then old(...)end;fn(...)end end
methods.Show=function(self)self.shown=true end
methods.Hide=function(self)local shown=self.shown;self.shown=false;if shown and self.OnHide then self.OnHide(self)end end
methods.SetShown=function(self,value)if value then self:Show()else self:Hide()end end
methods.IsShown=function(self)return self.shown and(not self.parent or self.parent:IsShown())end
methods.ClearFocus=function(self)if self.focused then self.focused=false;if self.OnEditFocusLost then self.OnEditFocusLost(self)end end end
methods.SetChecked=function(self,value)self.checked=value end;methods.GetChecked=function(self)return self.checked end
methods.SetValue=function(self,value)self.value=value end
methods.GetFrameLevel=function()return 1 end
methods.SetScale=function(self,value)self.scale=value end
methods.SetClampedToScreen=function(self,value)self.clamped=value end
methods.RegisterEvent=function(self,event)self.events[event]=true end
methods.SetScrollChild=function(self,child)self.child=child end
methods.SetVerticalScroll=function(self,value)self.scroll=value end
methods.GetVerticalScroll=function(self)return self.scroll or 0 end
local function frame(kind,name,parent)
    local f=setmetatable({kind=kind,name=name,parent=parent,shown=true,enabled=true,scale=1,events={}}, {__index=methods})
    frames[#frames+1]=f;return f
end
local allRefresh,overlayRefresh=0,0
a.RefreshAll=function()allRefresh=allRefresh+1 end;a.RefreshOverlay=function()overlayRefresh=overlayRefresh+1 end
a.ToggleOverlay=function()a.db.overlay.visible=not a.db.overlay.visible end
local parent=frame('Frame');parent:SetSize(1920,1080)
local ui=assert(io.open(root..'/UI.lua')):read('*a')
local start=assert(ui:find('local settings = CreateFrame',1,true))
local finish=assert(ui:find('function GetGear:InitializeUI()',start,true))
local section=ui:sub(start,finish-1)
assert(not section:lower():find('(click)',1,true),'stat-priority instruction suffixes must be removed')
local controls=assert(load(section..'\nreturn {settings=settings,priority=priorityUI,checks=displayChecks,newCheck=NewCheck,reset=resetPriorities}',
    'real settings UI','t',setmetatable({GetGear=a,UIParent=parent,UISpecialFrames={},window=frame('Frame'),overlay=frame('Frame'),
    CreateFrame=frame,HideItemTooltip=function()end,
    NewText=function(owner,_,width)local f=frame('FontString',nil,owner);f.width=width;return f end,
    NewButton=function(owner,text,width,height)local f=frame('Button',nil,owner);f:SetText(text);f:SetSize(width,height or 23);return f end,
},{__index=_G})))()
local function show()a:ShowSettings()end
local function click(mode)
    local button=assert(controls.priority.modes[mode]);assert(button.enabled,'selected mode is already active')
    button.OnClick(button)
end
local function edit(key,text,how)
    local field=assert(controls.priority.weights[key]).edit
    field.focused=true;field:SetText(text)
    if how=='blur'then field:ClearFocus()elseif how~='pending'then field.OnEnterPressed(field)end
    return field
end
local function copy(value)if type(value)~='table'then return value end;local out={};for k,v in pairs(value)do out[k]=copy(v)end;return out end
local function same(x,y)
    if type(x)~=type(y)then return false end;if type(x)~='table'then return x==y end
    for k,v in pairs(x)do if not same(v,y[k])then return false end end
    for k in pairs(y)do if x[k]==nil then return false end end;return true
end
show()
local expectedChecks={
    {'Count armour-only improvements','countArmorOnlyUpgrades','overlay'},
    {'Filter clearly outclassed earlier gear','filterObsolete','all'},
    {"Hide crafted gear I can't make",'hideUncraftableCrafts','all'},
    {'Hide gear without positive stat changes','hideWithoutPositiveStats','overlay'},
    {'Hide green BoE world drops from tracker','hideGreenBoEWorldDrops','overlay'},
    {'Hide tracker automatically during combat','hideInCombat','overlay'},
    {'Lock overlay position','locked','none'},
    {'Recommend ordinary bag upgrades','bagUpgrades','all'},
    {'Show all valid equipment (including off-spec)','showAllValidGear','all'},
}
assert(#controls.checks==#expectedChecks)
for i,expected in ipairs(expectedChecks)do
    local actual=controls.checks[i];assert(actual.label==expected[1],'checkboxes must sort by the complete visible label')
    assert(actual.checkbox.point[1]=='TOPLEFT'and actual.checkbox.point[3]==-292-(i-1)*33)
    assert(actual.checkbox.checked==a.db.overlay[expected[2]],'saved checkbox value must stay attached to its label')
    local old=copy(a.db.overlay);local beforeAll,beforeOverlay=allRefresh,overlayRefresh
    actual.checkbox:SetChecked(not old[expected[2]]);actual.checkbox.OnClick(actual.checkbox)
    old[expected[2]]=not old[expected[2]];assert(same(old,a.db.overlay),'reordering must not change setting keys or other preferences')
    assert(allRefresh-beforeAll==(expected[3]=='all'and 1 or 0))
    assert(overlayRefresh-beforeOverlay==(expected[3]=='overlay'and 1 or 0))
    actual.checkbox:SetChecked(not actual.checkbox:GetChecked());actual.checkbox.OnClick(actual.checkbox)
end
local descriptions={balanced='Uses class and talent-aware stat priorities.',priority='Gives your chosen stat greater importance.',custom='Set your own stat weights.'}
local labels={balanced='Balanced',priority='Priority',custom='Advanced'}
for mode,button in pairs(controls.priority.modes)do assert(button.text==labels[mode])end
local function checkMode(mode)
    assert(a:GetStatPriorityMode()==mode and controls.priority.help.text==descriptions[mode])
    assert(not controls.priority.modes[mode].enabled)
    assert(controls.priority.stat:IsShown()==(mode=='priority'))
    assert(controls.priority.scroll:IsShown()==(mode=='custom'))
end
checkMode('custom')
local spirit='ITEM_MOD_SPIRIT_SHORT';local intellect='ITEM_MOD_INTELLECT_SHORT';local stamina='ITEM_MOD_STAMINA_SHORT'
assert(controls.priority.weights[spirit].edit:GetText()=='5')
for _,text in ipairs({'','-1','1000.1','abc','1e999','nan'})do
    edit(spirit,text);assert(first.statPriorities.weights[spirit]==5,'invalid values must leave the saved weight unchanged')
    assert(controls.priority.message.text:find('were not changed',1,true))
end
local field=controls.priority.weights[spirit].edit;field.OnEscapePressed(field)
assert(field:GetText()=='5' and controls.priority.message.text=='')
for _,value in ipairs({0,1000,0.125,7.5})do
    local before=copy(first.statPriorities.weights);edit(spirit,tostring(value),'blur')
    before[spirit]=value;assert(same(first.statPriorities.weights,before),'one field must edit exactly one stat')
end
edit(intellect,'4','pending');edit(stamina,'2','pending')
click('balanced');checkMode('balanced')
assert(first.statPriorities.weights[intellect]==4 and first.statPriorities.weights[stamina]==2,'mode switches commit pending valid fields')
local saved=copy(first.statPriorities.weights)
click('priority');checkMode('priority')
local previous=first.statPriorities.priority;controls.priority.stat.OnClick()
assert(first.statPriorities.priority~=previous and same(saved,first.statPriorities.weights))
click('custom');checkMode('custom');assert(same(saved,first.statPriorities.weights))
assert(controls.priority.weights[spirit].edit:GetText()=='7.5')
edit(spirit,'8','pending');controls.settings:Hide();assert(first.statPriorities.weights[spirit]==8)
show();assert(controls.priority.weights[spirit].edit:GetText()=='8','close/reopen must preserve edits')
edit(spirit,'9','pending');show();assert(first.statPriorities.weights[spirit]==9,'reopening an already open window must not discard a valid pending edit')
-- Simulate another character arriving before the previous input loses focus.
local oldField=edit(spirit,'99','pending')
local second={schemaVersion=4,status={other='acquired'},overlay={},detail={},statPriorities={mode='custom',priority=intellect,weights={[spirit]=2,[intellect]=6}}}
GetGear_CharacterDB=second;eventFrame.OnEvent(nil,'ADDON_LOADED','GetGear')
oldField.OnEditFocusLost(oldField)
assert(second.statPriorities.weights[spirit]==2 and first.statPriorities.weights[spirit]==9,'a stale field must not write into either character during switching')
show();assert(controls.priority.weights[spirit].edit:GetText()=='2')
edit(intellect,'10');assert(second.statPriorities.weights[intellect]==10 and first.statPriorities.weights[intellect]==4)
GetGear_CharacterDB=first;eventFrame.OnEvent(nil,'ADDON_LOADED','GetGear');show()
assert(controls.priority.weights[spirit].edit:GetText()=='9')
local untouched={status=copy(first.status),hidden=copy(first.hidden),overlay=copy(first.overlay),detail=copy(first.detail)}
controls.reset.OnClick();checkMode('balanced')
assert(next(first.statPriorities.weights)==nil)
for key,before in pairs(untouched)do assert(same(before,first[key]),'defaults reset must preserve '..key)end
-- Every supported stat has a dedicated field, including all28 with no class
-- restriction. Bounds are layout arithmetic, not measured client font metrics.
for _,class in ipairs({'PRIEST','MAGE','WARLOCK','DRUID','ROGUE','HUNTER','SHAMAN','WARRIOR','PALADIN',false})do
    a.classToken=class or nil;a:SetStatPriorityMode('custom');show()
    local supported={};local count=0
    for _,definition in ipairs(a:GetSupportedPriorityStats())do supported[definition[1]]=true end
    for key,widget in pairs(controls.priority.weights)do
        assert(widget.edit:IsShown()==(supported[key]==true))
        assert(widget.label:IsShown()==(supported[key]==true))
        if supported[key]then
            count=count+1;assert(widget.label.text~='')
            local x,y=widget.edit.point[2],-widget.edit.point[3]
            assert(x>=0 and x+widget.edit.width<=325 and y>=0 and y+widget.edit.height<=420,'all current fields fit the two-column viewport')
            assert(widget.edit:GetText()==tostring(a.db.statPriorities.weights[key]or 0))
        end
    end
    assert(count==#a:GetSupportedPriorityStats())
    assert(not controls.priority.stat:IsShown(),'Advanced must never require a stat-selection button')
end
controls.priority.content:SetHeight(480)
controls.priority.scroll.OnMouseWheel(controls.priority.scroll,-99);assert(controls.priority.scroll:GetVerticalScroll()==60)
controls.priority.scroll.OnMouseWheel(controls.priority.scroll,99);assert(controls.priority.scroll:GetVerticalScroll()==0)
for _,resolution in ipairs({{800,600},{1024,768},{1280,720},{1920,1080}})do for _,uiScale in ipairs({0.7,1,1.5})do
    parent:SetSize(resolution[1]/uiScale,resolution[2]/uiScale);show()
    local effective=controls.settings.scale*uiScale
    assert(780*effective<=resolution[1]-24*uiScale+0.001)
    assert(692*effective<=resolution[2]-24*uiScale+0.001)
end end
parent:SetSize(800,600);controls.settings.OnEvent();assert(controls.settings.scale<1)
assert(controls.settings.clamped and controls.settings.events.DISPLAY_SIZE_CHANGED and controls.settings.events.UI_SCALE_CHANGED)
controls.newCheck(controls.settings,'A future display option',function()end)
assert(controls.checks[1].label=='A future display option','future registrations automatically maintain alphabetical order')
assert(first.status.item_123=='skipped' and first.hidden.item_456)
print('PASS settings UI:nine sorted checkboxes/unchanged callbacks/three concise modes/all28 stat inputs/nine classes/focus-invalid-range edits/mode-character persistence/reset/12 scaled layouts;synthetic rendering only')
