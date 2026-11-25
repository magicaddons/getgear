-- Real TOC/UI callbacks; deterministic frames reused from the UI regression.
local root=arg[1]or'.'
local dir=arg[0]:match('^(.*[/])')or'tests/'
local f=assert(io.open(dir..'beta4-slot-ui.lua'));local source=f:read('*a');f:close()
local prefix=source:sub(1,assert(source:find('local addon={',1,true))-1)
local body=[=[
local root=arg[1]or'.'
function methods:RegisterEvent(e)self.events=self.events or{};self.events[e]=true end
SlashCmdList={};GetRealmName=function()return'Test Realm'end
GetRealmID=function()return 42 end
UnitFactionGroup=function()return'Alliance'end
UnitLevel=function()return 31 end
C_Timer={After=function()end}
local containerReads=0
C_Container={GetContainerNumSlots=function(id)containerReads=containerReads+1;return id==0 and 16 or 0 end,
 GetContainerItemInfo=function()containerReads=containerReads+1 end}
C_Item={GetItemNameByID=function(id)return id==2589 and'Linen Cloth'or'Copper Bar'end}
GetGear_AccountDB={characters={
 ['TestRealm:Alt']={faction='Alliance',bank={[2589]=5},bankAt=123},
 ['Test Realm:Enemy']={faction='Horde',bags={[2840]=9}},
 ['Test Realm:Unknown']={bank={[2840]=2}},
}}
GetGear_CharacterDB={schemaVersion=4,status={kept='skipped'},hidden={kept=true},overlay={},detail={}}
local addon={}
for line in io.lines(root..'/GetGear.toc')do
 if line:match('%.lua$')then assert(loadfile(root..'/'..line))('GetGear',addon)end
end
for _,frame in ipairs(frames)do
 if frame.events and frame.events.ADDON_LOADED then frame.scripts.OnEvent(frame,'ADDON_LOADED','GetGear')end
end
local calls=0
for _,method in ipairs({'GetItems','GetCombinedMaterialRows','ScanBags','ScanBank'})do
 local owner=method:find('Scan')and addon.AltInventory or addon
 local old=owner[method];owner[method]=function(...)calls=calls+1;return old(...)end
end
addon:ShowUI();addon:ShowAltInventoryBrowser();calls=0;containerReads=0
local scope,status
for _,frame in ipairs(frames)do
 if frame.kind=='Button'and frame.text=='Scope: Same realm/faction'then scope=frame end
end
assert(scope)
for _,frame in ipairs(frames)do
 if frame.parent==scope.parent and frame.text:find('unresolved character',1,true)then status=frame end
end
assert(status,'unknown legacy metadata must be visible to user')
local function shownItem(name)
 for _,frame in ipairs(frames)do if frame.text==name and frame:IsShown()then return true end end
 return false
end
assert(shownItem('Linen Cloth')and not shownItem('Copper Bar'))
local function clickScope()scope.scripts.OnClick(scope)end
for _=1,20 do
 clickScope();assert(scope.text=='Scope: Current character' and not shownItem('Linen Cloth'))
 clickScope();assert(scope.text=='Scope: Eligible alts' and shownItem('Linen Cloth'))
 clickScope();assert(scope.text=='Scope: Other / unknown realm/faction' and shownItem('Copper Bar')and not shownItem('Linen Cloth'))
 clickScope();assert(scope.text=='Scope: All saved characters*' and shownItem('Linen Cloth')and shownItem('Copper Bar'))
 -- Four individual records, then the default again.
 for _=1,5 do clickScope()end
 assert(scope.text=='Scope: Same realm/faction' and shownItem('Linen Cloth'))
end
assert(calls==0 and containerReads==0,'scope switching collected inventory or rebuilt unrelated data')
-- Existing design: browser choices are transient and reopen starts in eligible.
clickScope();addon:ShowAltInventoryBrowser();assert(scope.text=='Scope: Same realm/faction')
assert(addon.db.status.kept=='skipped' and addon.db.hidden.kept)
print('PASS inventory browser UI: 180 scope clicks immediately render correct records, no container reads/snapshots/recommendation/material rebuilds, unknown identity notice and intended transient reopen default; synthetic only')
]=]
assert(load(prefix..body,'inventory browser UI','t',_G))()
