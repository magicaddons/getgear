-- Alternate .10/new refreshes in one interpreter to investigate host timing
-- variation in separate-process scenario runs. No elapsed-time pass threshold.
local baseline,feature=assert(arg[1]),assert(arg[2])
local function read(path)local f=assert(io.open(path));local s=f:read('*a');f:close();return s end
local fixture=read(feature..'/tests/beta4-slot-ui.lua')
local prefix=fixture:sub(1,assert(fixture:find('local addon={',1,true))-1)
local body=[=[
SlashCmdList={};GetRealmName=function()return 'Realm'end
UnitClass=function()return 'Priest','PRIEST',5 end
UnitFactionGroup=function()return 'Alliance'end;UnitLevel=function()return 31 end
GetTime=function()return 1 end;time=function()return 1000 end
debugprofilestop=function()return os.clock()*1000 end
C_Item={GetItemCount=function()return 1 end}
C_Container={GetContainerNumSlots=function(id)return id==0 and 16 or 4 end,
 GetContainerItemInfo=function(_,slot)if slot==1 then return {itemID=2589,stackCount=1}end end}
C_Timer={After=function()end}
function methods:RegisterEvent(event)self.events=self.events or {};self.events[event]=true end
local addon={}
for line in io.lines(root..'/GetGear.toc')do
 if line:match('%.lua$')then assert(loadfile(root..'/'..line))('GetGear',addon)end
end
local sourceCalls=0;local original=addon.HasEligibleAcquisitionSource
addon.HasEligibleAcquisitionSource=function(...)sourceCalls=sourceCalls+1;return original(...)end
GetGear_CharacterDB={schemaVersion=4,status={},hidden={},overlay={visible=true},detail={}}
for _,frame in ipairs(frames)do
 if frame.events and frame.events.ADDON_LOADED then frame.scripts.OnEvent(frame,'ADDON_LOADED','GetGear')end
end
return {addon=addon,count=function()return sourceCalls end}
]=]
local function runtime(path)
 local env=setmetatable({arg={[1]=path}},{__index=_G});env._G=env
 env.loadfile=function(name) return load(read(name),'@'..name,'t',env) end
 return assert(load(prefix..body,'paired runtime','t',env))()
end
local base,new=runtime(baseline),runtime(feature)
local function signature(runtime)
 local ids={};for _,r in ipairs(runtime.addon:GetItems('tracker'))do ids[#ids+1]=r.itemID..':'..r.targetLevel end
 return table.concat(ids,',')
end
assert(signature(base)==signature(new))
local function batch(runtime)
 collectgarbage('collect')
 local before=runtime.count();local started=os.clock()
 for _=1,10 do runtime.addon:RefreshOverlay() end
 return (os.clock()-started)*1000,runtime.count()-before
end
local function median(values)table.sort(values);return values[math.ceil(#values/2)]end
for _,collapsed in ipairs({false,true})do
 base.addon.db.overlay.materialsCollapsed=collapsed;new.addon.db.overlay.materialsCollapsed=collapsed
 local oldTimes,newTimes={},{}
 for i=1,9 do
  collectgarbage('collect')
  local oldTime,oldCount,newTime,newCount
  if i%2==1 then oldTime,oldCount=batch(base);newTime,newCount=batch(new)
  else newTime,newCount=batch(new);oldTime,oldCount=batch(base)end
  assert(oldCount==newCount,'source calculations changed')
  oldTimes[#oldTimes+1]=oldTime;newTimes[#newTimes+1]=newTime
 end
 local oldMedian,newMedian=median(oldTimes),median(newTimes)
 print(string.format('PAIRED %s: baseline %.3fms feature %.3fms change %.2f%% per ten refreshes',collapsed and 'collapsed' or 'expanded',oldMedian,newMedian,(newMedian/oldMedian-1)*100))
end
print('PASS alternating isolated runtime counts and ordered recommendation identity')
