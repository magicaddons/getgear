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
 print(string.format('MEASURE %s: %.3fms; net heap %.1fKiB; records=%d sourceChecks=%d routes=%d comparisons=%d obsolete=%d professions=%d aggregate=%d undocumented=%d textWrites=%d newFrames=%d',
  label,elapsed,collectgarbage('count')-mem,calls.GetRecommendationRecord or 0,
  calls.HasEligibleAcquisitionSource or 0,calls.GetEligibleAcquisitionRoutes or 0,
  calls.GetGearComparison or 0,calls.GetObsoleteGearReason or 0,calls.GetProfessionSkill or 0,
  calls.GetCombinedMaterialRows or 0,calls.GetUndocumentedCrafts or 0,textWrites,#frames-frameCount))
 -- Fingerprint ordered recommendations and exact ingredient quantities against
 -- the accepted .9 runtime, rather than accepting a faster empty result.
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
 assert(hash==232596664,'accepted .9 fingerprint changed: '..label..' '..hash)
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
-- Collapsed calculation budget accompanies the implementation checkpoint.
addon.db.overlay.materialsCollapsed=false
measure('slot changes x3',function()for _,slot in ipairs({'head','rings','all'})do addon:SetEquipmentSlotFilter('overlay',slot);addon:RefreshOverlay()end end)
measure('open close x3',function()for _=1,3 do addon:ToggleOverlay();addon:ToggleOverlay()end end)
measure('priority settings',function()addon:SetStatPriorityMode('priority');addon:SetPriorityStat('ITEM_MOD_INTELLECT_SHORT');addon:SetStatPriorityMode('balanced')end)
measure('equipment',function()event('PLAYER_EQUIPMENT_CHANGED',16);event('UNIT_INVENTORY_CHANGED','player');advance(.2)end)
measure('profession',function()event('SKILL_LINES_CHANGED');event('TRADE_SKILL_SHOW')end)
local gear=assert(addon:GetItems('tracker')[1])
measure('hide restore',function()addon:SetHidden(gear,true);assert(addon:IsHidden(gear));addon:SetHidden(gear,false);assert(not addon:IsHidden(gear))end)
measure('detail + overlay',function()addon:ShowUI();addon:RefreshAll();GetGear_MainWindow:Hide()end)
-- Repeated UI refreshes must retain pooled objects and recommendation contents.
local function ids(list)local out={};for _,g in ipairs(list)do out[#out+1]=g.id..':'..g.targetLevel end;return table.concat(out,',')end
local before=ids(addon:GetItems('tracker'));local frameCount=#frames
for _=1,3 do addon:RefreshOverlay()end
assert(ids(addon:GetItems('tracker'))==before and #frames==frameCount)
print('PASS production overlay performance scenarios (synthetic; times are not client frame latency)')
]=]
assert(load(prefix..body,'overlay performance','t',_G))()
