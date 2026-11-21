-- Real cumulative TOC/Core/UI with deterministic timers and stateful frames.
-- `baseline` disables workload assertions for before/after comparisons.
local root=arg[1] or '.'
local baseline=arg[2]=='baseline'
local dir=arg[0]:match('^(.*[/])') or 'tests/'
local file=assert(io.open(dir..'beta4-slot-ui.lua'));local source=file:read('*a');file:close()
local prefix=source:sub(1,assert(source:find('local addon={',1,true))-1)
local body=[=[
local root=arg[1] or '.';local baseline=arg[2]=='baseline'
local now,queue=0,{}
function methods:RegisterEvent(event)self.events=self.events or {};self.events[event]=true end
SlashCmdList={};GetRealmName=function()return 'Test Realm'end
UnitFactionGroup=function()return 'Alliance'end;UnitLevel=function()return 31 end
UnitClass=function()return 'Priest','PRIEST',5 end
GetTime=function()return now end;time=function()return 1000+now end
debugprofilestop=function()return os.clock()*1000 end
local amount=1
C_Item={GetItemCount=function()return amount end}
C_Container={GetContainerNumSlots=function(id)return id==0 and 16 or 4 end,
 GetContainerItemInfo=function(_,slot)if slot==1 then return {itemID=2589,stackCount=amount}end end}
C_Timer={After=function(delay,fn)queue[#queue+1]={at=now+delay,fn=fn}end}
local function advance(seconds)
 local deadline=now+seconds
 while true do
  table.sort(queue,function(a,b)return a.at<b.at end)
  if not queue[1] or queue[1].at>deadline then break end
  local task=table.remove(queue,1);now=task.at;task.fn()
 end
 now=deadline
end
local addon={}
for line in io.lines(root..'/GetGear.toc')do
 if line:match('%.lua$')then assert(loadfile(root..'/'..line))('GetGear',addon)end
end
local function event(name,...)
 for _,frame in ipairs(frames)do
  if frame.events and frame.events[name] and frame.scripts.OnEvent then frame.scripts.OnEvent(frame,name,...)end
 end
end
GetGear_CharacterDB={schemaVersion=4,status={},hidden={},overlay={visible=true},detail={}}
local calls={}
for _,name in ipairs({'GetItems','GetRecommendationRecord','HasEligibleAcquisitionSource',
 'GetEligibleAcquisitionRoutes','GetGearComparison','GetObsoleteGearReason','GetProfessionSkill',
 'GetCombinedMaterialRows','GetUndocumentedCrafts','RefreshOverlay','RefreshUI'})do
 local original=assert(addon[name]);addon[name]=function(...)calls[name]=(calls[name] or 0)+1;return original(...)end
end
local textWrites=0
local setText=methods.SetText
function methods:SetText(...)textWrites=textWrites+1;return setText(self,...)end
event('ADDON_LOADED','GetGear');advance(2)
local function reset()calls={};textWrites=0 end
local function measure(label,fn)
 reset();collectgarbage('collect')
 local mem=collectgarbage('count');local started=os.clock();local frameCount=#frames
 fn()
 local elapsed=(os.clock()-started)*1000
 if not baseline then
  if label=='detail + overlay' then
   assert(calls.RefreshUI==2 and calls.RefreshOverlay==1,'combined scenario changed execution path')
   assert((calls.HasEligibleAcquisitionSource or 0)<=650,'combined source work regressed')
   assert((calls.GetEligibleAcquisitionRoutes or 0)<=700,'combined route work regressed')
   assert((calls.GetObsoleteGearReason or 0)<=550,'combined comparison work regressed')
  elseif label~='ordinary movement idle' then
   local refreshes=calls.RefreshOverlay or 0
   assert((calls.HasEligibleAcquisitionSource or 0)<=450*refreshes,'source workload regressed: '..label)
   assert((calls.GetEligibleAcquisitionRoutes or 0)<=500*refreshes,'route workload regressed: '..label)
   assert((calls.GetObsoleteGearReason or 0)<=400*refreshes,'comparison workload regressed: '..label)
  end
 end
 print(string.format('MEASURE %s: %.3fms; net heap %.1fKiB; records=%d sourceChecks=%d routes=%d comparisons=%d obsolete=%d professions=%d aggregate=%d undocumented=%d textWrites=%d newFrames=%d',
  label,elapsed,collectgarbage('count')-mem,calls.GetRecommendationRecord or 0,
  calls.HasEligibleAcquisitionSource or 0,calls.GetEligibleAcquisitionRoutes or 0,
  calls.GetGearComparison or 0,calls.GetObsoleteGearReason or 0,calls.GetProfessionSkill or 0,
  calls.GetCombinedMaterialRows or 0,calls.GetUndocumentedCrafts or 0,textWrites,#frames-frameCount))
 -- Fingerprint ordered recommendations and exact ingredient quantities against
 -- the reviewed Alliance-access correction, rather than accepting an empty result.
 local measuredCalls=calls;calls={}
 local hash=7
 local function digest(text)for i=1,#text do hash=(hash*31+text:byte(i))%1000000007 end end
 for _,mode in ipairs({'tracker','available','upcoming','earlier','hidden','completed','bags'})do
  digest(mode)
  for _,g in ipairs(addon:GetItems(mode))do digest(g.id..':'..g.targetLevel..';')end
 end
 for _,scope in ipairs({'tracked','all'})do
  digest(scope)
  for _,m in ipairs(addon:GetCombinedMaterialRows(scope))do digest(m.itemID..':'..m.amount..':'..m.name..';')end
 end
 assert(hash==591227800,'Alliance-access fingerprint changed: '..label..' '..hash)
 print('SIGNATURE '..label..' '..hash)
 calls=measuredCalls
end
measure('warm overlay x10',function()for _=1,10 do addon:RefreshOverlay()end end)
measure('one loot',function()amount=2;event('BAG_UPDATE_DELAYED');advance(.2)end)
measure('rapid loot x12',function()for i=1,12 do amount=i;event('BAG_UPDATE_DELAYED')end;advance(.2)end)
measure('mining + skill',function()event('CHAT_MSG_SKILL');event('BAG_UPDATE_DELAYED');advance(.2)end)
measure('movement zones x10',function()for _=1,10 do event('ZONE_CHANGED')end end)
measure('ordinary movement idle',function()advance(5)end)
assert(not next(calls),'idle movement scheduled catalogue/UI work')
measure('collapsed materials',function()addon.db.overlay.materialsCollapsed=true;addon:RefreshOverlay()end)
if not baseline then assert(not calls.GetCombinedMaterialRows,'collapsed totals still aggregate')end
addon.db.overlay.materialsCollapsed=false
measure('slot changes x3',function()for _,slot in ipairs({'head','rings','all'})do addon:SetEquipmentSlotFilter('overlay',slot);addon:RefreshOverlay()end end)
measure('open close x3',function()for _=1,3 do addon:ToggleOverlay();addon:ToggleOverlay()end end)
measure('priority settings',function()addon:SetStatPriorityMode('priority');addon:SetPriorityStat('ITEM_MOD_INTELLECT_SHORT');addon:SetStatPriorityMode('balanced')end)
measure('equipment',function()event('PLAYER_EQUIPMENT_CHANGED',16);event('UNIT_INVENTORY_CHANGED','player');advance(.2)end)
measure('profession',function()event('SKILL_LINES_CHANGED');event('TRADE_SKILL_SHOW')end)
local gear=assert(addon:GetItems('tracker')[1])
measure('hide restore',function()addon:SetHidden(gear,true);assert(addon:IsHidden(gear));addon:SetHidden(gear,false);assert(not addon:IsHidden(gear))end)
measure('detail + overlay',function()addon:ShowUI();addon:RefreshAll();GetGear_MainWindow:Hide()end)
-- A warmed combined refresh is a distinct workload from ShowUI + RefreshAll.
GetGear_MainWindow:Show();addon:RefreshAll()
local function combined(shared)
 reset()
 for _=1,10 do
  if shared then addon:RefreshAll()else addon:RefreshUI();addon:RefreshOverlay()end
 end
 return calls.GetEligibleAcquisitionRoutes or 0,calls.HasEligibleAcquisitionSource or 0
end
local separateRoutes,separateSources=combined(false)
local sharedRoutes,sharedSources=combined(true)
assert(calls.RefreshUI==10 and calls.RefreshOverlay==10 and calls.GetItems==20)
if not baseline then
 assert(sharedRoutes<separateRoutes and sharedSources<separateSources,'guide/overlay did not share calculation work')
end
print(string.format('SHARED separate routes=%d sources=%d; shared routes=%d sources=%d',separateRoutes,separateSources,sharedRoutes,sharedSources))
GetGear_MainWindow:Hide()
-- Repeated UI refreshes must retain pooled objects and recommendation contents.
local function ids(list)local out={};for _,g in ipairs(list)do out[#out+1]=g.id..':'..g.targetLevel end;return table.concat(out,',')end
local before=ids(addon:GetItems('tracker'));local frameCount=#frames
for _=1,3 do addon:RefreshOverlay()end
assert(ids(addon:GetItems('tracker'))==before and #frames==frameCount)
-- Include total-material expansion/collapse after an inventory change.
addon.db.overlay.materialsCollapsed=true;reset();addon:RefreshOverlay()
if not baseline then assert(not calls.GetCombinedMaterialRows)end
amount=99;event('BAG_UPDATE_DELAYED');advance(.2)
addon.db.overlay.materialsCollapsed=false;reset();addon:RefreshOverlay()
assert(calls.GetCombinedMaterialRows==1 and addon:GetMaterialCount(2589)==99)
-- A single collection-paused refresh is a Lua heap-growth proxy, not a client
-- allocation counter. Never pause GC in production; instrumentation stays opt-in.
collectgarbage('collect');collectgarbage('stop')
local heap=collectgarbage('count');addon:RefreshOverlay()
local growth=collectgarbage('count')-heap
collectgarbage('restart');collectgarbage('collect')
print(string.format('HEAP one refresh with GC paused: %.1fKiB',growth))
if not baseline then assert(growth<3000,'refresh heap growth proxy regressed')end
addon:StartPerformanceCapture()
for _=1,10 do addon:RefreshOverlay()end
local profile=addon:StopPerformanceCapture()
for _,key in ipairs({'RefreshOverlay','GetItems','GetCombinedMaterialRows'})do
 local v=profile.samples[key]
 print(string.format('PROFILE %s calls=%d total=%.3fms',key,v.calls,v.milliseconds))
end
if not baseline then
 assert(profile.samples.ItemsEvaluation.calls==10 and profile.samples.OverlayObjectiveUI.calls==10)
 assert(profile.samples.RefreshOverlay.windowSamples==10 and #profile.refreshes==10 and next(profile.cache))
 addon:StartPerformanceCapture();event('BAG_UPDATE_DELAYED');advance(.2)
 local triggered=addon:StopPerformanceCapture()
 assert(triggered.samples.RefreshOverlay.triggers.BAG_UPDATE_DELAYED==1,'deferred event attribution lost')
end
print('PASS production overlay performance scenarios (synthetic; times are not client frame latency)')
]=]
assert(load(prefix..body,'overlay performance','t',_G))()
