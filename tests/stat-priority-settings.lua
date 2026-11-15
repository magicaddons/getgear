local root=arg[1] or '.';local a={}
for _,f in ipairs({'StatPriorities.lua','GearRelevance.lua'})do assert(loadfile(root..'/'..f))('GetGear',a)end
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
-- Execute the real settings control callbacks using synthetic frames.
local frames={};local methods={}
for _,key in ipairs({'SetPoint','SetSize','SetAutoFocus','SetMaxLetters','ClearFocus'})do methods[key]=function()end end
methods.SetText=function(self,text)self.text=text end;methods.GetText=function(self)return self.text end
methods.SetEnabled=function(self,value)self.enabled=value end
methods.SetScript=function(self,key,fn)self[key]=fn end
local function frame(name)local f=setmetatable({name=name},{__index=methods});frames[#frames+1]=f;return f end
local ui=assert(io.open(root..'/UI.lua')):read('*a')
local panel=assert(ui:match('(local priorityTitle=.-)\nlocal closeSettings='))
local refresh=assert(load(panel..'\nreturn RefreshPrioritySettings','priority settings','t',setmetatable({
    GetGear=a,settings=frame(),CreateFrame=function(_,name)return frame(name)end,
    NewText=function()return frame()end,NewButton=function(_,text)local f=frame();f.text=text;return f end,
},{__index=_G})))()
refresh()
local function button(prefix)for _,f in ipairs(frames)do if f.text and f.text:find(prefix,1,true)==1 and f.OnClick then return f end end;error(prefix)end
local edit;for _,f in ipairs(frames)do if f.name=='GetGear_StatWeight'then edit=f end end
assert(edit and edit.enabled)
edit:SetText('-1');button('Apply weight').OnClick();assert(first.statPriorities.weights.ITEM_MOD_SPIRIT_SHORT==5)
edit:SetText('7.5');edit.OnEnterPressed();assert(first.statPriorities.weights.ITEM_MOD_SPIRIT_SHORT==7.5)
button('Restore Balanced').OnClick();assert(a:GetStatPriorityMode()=='balanced' and not edit.enabled)
button('Mode:').OnClick();assert(a:GetStatPriorityMode()=='priority')
local previous=a.db.statPriorities.priority;button('Priority:').OnClick();assert(a.db.statPriorities.priority~=previous)
button('Mode:').OnClick();assert(a:GetStatPriorityMode()=='custom' and edit.enabled)
assert(first.status.item_123=='skipped' and first.hidden.item_456,'UI callbacks never reset progress')
print('PASS settings:actual Core saved-variable loading/two characters/older settings plus real mode/stat/weight/reset callbacks;synthetic UI only')
