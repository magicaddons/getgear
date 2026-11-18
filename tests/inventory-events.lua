-- Real TOC, Core events, ledger and UI; deterministic timers, synthetic frames.
-- Pass "baseline" as arg[2] to measure the pre-fix runtime without new limits.
local root=arg[1]or'.';local baseline=arg[2]=='baseline'
local dir=arg[0]:match('^(.*[/])')or'tests/'
local f=assert(io.open(dir..'beta4-slot-ui.lua'));local source=f:read('*a');f:close()
local prefix=source:sub(1,assert(source:find('local addon={',1,true))-1)
local body=[=[
local root=arg[1]or'.';local baseline=arg[2]=='baseline'
local now,queue,events=0,{},{}
function methods:RegisterEvent(event)self.events=self.events or{};self.events[event]=true end
SlashCmdList={};GetRealmName=function()return'Test Realm'end
UnitFactionGroup=function()return'Alliance'end;UnitLevel=function()return 31 end
UnitClass=function()return'Priest','PRIEST',5 end
GetTime=function()return now end;time=function()return 1000+now end
C_Timer={After=function(delay,fn)queue[#queue+1]={at=now+delay,fn=fn}end}
local function advance(seconds)
 local untilTime=now+seconds
 while true do
  table.sort(queue,function(a,b)return a.at<b.at end)
  if not queue[1]or queue[1].at>untilTime then break end
  local task=table.remove(queue,1);now=task.at;task.fn()
 end
 now=untilTime
end
local bagReads=0;local amount=1
C_Container={GetContainerNumSlots=function(id)return id==0 and 16 or 4 end,
 GetContainerItemInfo=function(_,slot)bagReads=bagReads+1;if slot==1 then return{itemID=2589,stackCount=amount}end end}
local addon={}
for line in io.lines(root..'/GetGear.toc')do
 if line:match('%.lua$')then assert(loadfile(root..'/'..line))('GetGear',addon)end
end
for _,frame in ipairs(frames)do if frame.events then events[#events+1]=frame end end
local function event(name,...)
 for _,frame in ipairs(events)do if frame.events[name]and frame.scripts.OnEvent then frame.scripts.OnEvent(frame,name,...)end end
end
GetGear_CharacterDB={schemaVersion=4,status={retained='skipped'},hidden={kept=true},
 overlay={visible=true,slotFilter='head'},detail={slotFilter='rings'}}
event('ADDON_LOADED','GetGear')
local calls={}
for _,name in ipairs({'GetItems','RefreshOverlay','RefreshUI','GetCombinedMaterialRows'})do
 local original=assert(addon[name]);addon[name]=function(...)calls[name]=(calls[name]or 0)+1;return original(...)end
end
local scans=0;local scan=addon.AltInventory.ScanBags
addon.AltInventory.ScanBags=function(...)scans=scans+1;return scan(...)end
local function reset()calls={};scans=0;bagReads=0 end
local function burst()
 for _=1,12 do event('UNIT_INVENTORY_CHANGED','player');event('PLAYER_EQUIPMENT_CHANGED',16);event('BAG_UPDATE_DELAYED')end
end
local function scenario(visible,detail)
 addon.db.overlay.visible=visible
 if detail then addon:ShowUI()else GetGear_MainWindow:Hide()end
 addon:RefreshOverlay();advance(2);reset();collectgarbage('collect')
 local mem=collectgarbage('count');local started=os.clock()
 burst();local synchronous=os.clock()-started;advance(.2)
 local elapsed=os.clock()-started;local memory=collectgarbage('count')-mem
 local rec=calls.GetItems or 0
 print(string.format('MEASURE inventory %s: 36 events; %d list scans, %d bag snapshots, %d slot reads; sync %.6fs total %.6fs heap delta %.1fKiB (GC-sensitive, synthetic)',
  detail and'detail+overlay'or visible and'overlay'or'hidden',rec,scans,bagReads,synchronous,elapsed,memory))
 if not baseline then
  assert((calls.RefreshOverlay or 0)<=1,'inventory storm rebuilt overlay repeatedly')
  assert((calls.RefreshUI or 0)<=(detail and 1 or 0),'inventory storm rebuilt guide repeatedly')
  assert(scans==1,'inventory storm repeated full bag scans')
  if not visible and not detail then assert(rec==0,'hidden UI enumerated recommendations')end
 end
 local c=GetGear_AccountDB.characters['Test Realm:Test'];assert(c.bags[2589]==6*amount,'ledger missed latest bag state')
end
scenario(true,false);scenario(false,false);scenario(true,true)
if not baseline then
 -- Timers use the latest state and a fixed deadline; sustained input cannot
 -- postpone refresh forever, and later bursts must still be delivered.
 reset();event('BAG_UPDATE_DELAYED');amount=3;advance(.2)
 assert(scans==1 and GetGear_AccountDB.characters['Test Realm:Test'].bags[2589]==18)
 event('BAG_UPDATE_DELAYED');advance(.2);assert(scans==2)
 -- A second event after the ledger deadline but before the UI deadline
 -- must be included in the snapshot consumed by that UI refresh.
 reset();amount=1;event('BAG_UPDATE_DELAYED');advance(.06)
 amount=4;event('BAG_UPDATE_DELAYED');advance(.04)
 assert(GetGear_AccountDB.characters['Test Realm:Test'].bags[2589]==24,'UI refreshed before the latest ledger state')
 local completed=scans;advance(.2);assert(scans==completed,'obsolete ledger timer rescanned')
 reset()
 for i=1,20 do amount=i;event('BAG_UPDATE_DELAYED');advance(.03)end
 advance(.2)
 assert((calls.RefreshOverlay or 0)>=5 and calls.RefreshOverlay<=7,'sustained events starved or flooded refreshes')
 assert(GetGear_AccountDB.characters['Test Realm:Test'].bags[2589]==120)
 reset();event('UNIT_INVENTORY_CHANGED','target');advance(.2);assert(not next(calls)and scans==0)
 -- Logout must synchronously record the final state even with queued work.
 amount=7;event('BAG_UPDATE_DELAYED');event('PLAYER_LOGOUT')
 assert(GetGear_AccountDB.characters['Test Realm:Test'].bags[2589]==42)
 advance(.2)
 -- Profiles are opt-in and do not mutate saved preferences.
 assert(not addon.performanceStats)
 addon:StartPerformanceCapture();reset();burst();advance(.2)
 local p=addon.performanceStats
 assert(p.events.BAG_UPDATE_DELAYED==12 and p.events.UNIT_INVENTORY_CHANGED==12)
 assert(p.samples.RefreshAll.calls==1 and p.samples.ScanBags.calls==1)
 assert(p.samples.RefreshAll.milliseconds>=0 and p.samples.ScanBags.milliseconds>=0)
 addon:StopPerformanceCapture();assert(not addon.performanceStats)
 -- Wrappers preserve multiple returns (including trailing nils), errors and
 -- method identity, and report unsupported memory APIs honestly.
 local real=addon.GetItems
 local stub=function()return'one',nil,'three',nil end
 addon.GetItems=stub;addon:StartPerformanceCapture()
 local function returned(...)assert(select('#',...)==4 and select(1,...)=='one'and select(3,...)=='three')end
 returned(addon:GetItems());addon:StopPerformanceCapture();assert(addon.GetItems==stub)
 local gc=collectgarbage;collectgarbage=nil;addon:StartPerformanceCapture()
 addon:GetItems();assert(not addon.performanceStats.samples.GetItems.memoryAvailable)
 addon:StopPerformanceCapture();collectgarbage=gc
 addon.GetItems=function()error('profile fixture failure')end;addon:StartPerformanceCapture()
 local ok,err=pcall(addon.GetItems,addon);assert(not ok and tostring(err):find('profile fixture failure',1,true))
 addon:StopPerformanceCapture();addon.GetItems=real
 -- Timer-free compatibility remains synchronous, with no lost updates.
 C_Timer=nil;reset();amount=2;event('BAG_UPDATE_DELAYED')
 assert(scans==1 and GetGear_AccountDB.characters['Test Realm:Test'].bags[2589]==12)
 assert(addon.db.status.retained=='skipped'and addon.db.hidden.kept)
 assert(addon.db.overlay.slotFilter=='head'and addon.db.detail.slotFilter=='rings')
 print('PASS inventory events: bounded refresh/ledger work, hidden/visible/detail, latest state, repeated bursts, target exclusion, synchronous logout, profiling and timer-free fallback; synthetic only')
end
]=]
assert(load(prefix..body,'inventory events','t',_G))()
