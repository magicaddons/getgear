-- Lifetime/identity/error contracts for synchronous calculation reuse.
local root=arg[1] or '.'
local a={}
assert(loadfile(root..'/GuideState.lua'))('GetGear',a)
local state,calls=1,0
a.GetEligibleAcquisitionRoutes=function(_,key,context)
 calls=calls+1
 return {state=state,key=key,context=context},nil,false
end
a.GetGearComparison=function(_,key,option,partner)
 calls=calls+1;return {state=state,partner=partner}
end
local item={}
local function check()
 local r,h,f=a:GetEligibleAcquisitionRoutes(item)
 assert(h==nil and f==false and r.state==state)
 return r
end
a:WithRecommendationSnapshot(function()
 local r=check();assert(check()==r and calls==1)
 a:WithRecommendationSnapshot(function()assert(check()==r and calls==1)end)
 local nilKey=a:GetEligibleAcquisitionRoutes(nil)
 local falseKey=a:GetEligibleAcquisitionRoutes(false)
 assert(nilKey~=falseKey,'nil and false keys conflated')
 assert(a:GetEligibleAcquisitionRoutes(nil)==nilKey and a:GetEligibleAcquisitionRoutes(false)==falseKey)
 local nilOption=a:GetEligibleAcquisitionRoutes(item,nil)
 local falseOption=a:GetEligibleAcquisitionRoutes(item,false)
 assert(nilOption~=falseOption,'nil and false options conflated')
 local context={}
 assert(a:GetEligibleAcquisitionRoutes(item,context)==a:GetEligibleAcquisitionRoutes(item,context))
 assert(a:GetEligibleAcquisitionRoutes(item,{})~=a:GetEligibleAcquisitionRoutes(item,{}))
 local one=a:GetGearComparison(item,true)
 assert(a:GetGearComparison(item,true)==one)
 local partner={}
 assert(a:GetGearComparison(item,true,partner)~=a:GetGearComparison(item,true,partner),'mutable planning partner cached')
end)
assert(a.recommendationSnapshot==nil)
state=2;assert(check().state==2,'next call reused old state')
a:WithRecommendationSnapshot(function()assert(check().state==2)end)
local ok,err=pcall(a.WithRecommendationSnapshot,a,function()check();error('intentional calculation error')end)
assert(not ok and tostring(err):find('intentional calculation error',1,true))
assert(a.recommendationSnapshot==nil,'error retained cache')
state=3;a:WithRecommendationSnapshot(function()assert(check().state==3)end)
local x,y,z=a:WithRecommendationSnapshot(function()return nil,false,3 end)
assert(x==nil and y==false and z==3,'callback return arity changed')

-- Every external-state transition gets a new snapshot. No invalidation list
-- or persistent result is necessary, even for direct guide-only refreshes.
for _,reason in ipairs({'level','equipment','inventory','profession','recipes','talents',
 'weights','slots','visibility','class','faction','quest','account','settings','item-data','reopen'})do
 state=state+1
 a:WithRecommendationSnapshot(function()assert(check().state==state,'stale '..reason)end)
 assert(a.recommendationSnapshot==nil)
end

-- Verify the raw quest bound cannot hide a possible effective-level increase.
local model={items={},quests={[1]={reqlevel=20},[2]={reqlevel=5},[3]={reqlevel=40}}}
a.AcquisitionNavigationData=model
local minimumCalls=0
a.GetAcquisitionMinimumLevel=function(_,g)
 minimumCalls=minimumCalls+1
 if g.bagUpgrade or g.profession then return end
 local min
 for _,r in ipairs(g.acquisitionPlan.routes)do
  if r.kind~='quest' and r.kind~='quest_container' then return end
  local q=model.quests[r.questID];if not q then return end
  min=math.min(min or q.reqlevel,q.reqlevel)
 end
 return min
end
for _,routes in ipairs({{},{{kind='vendor'}},{{kind='quest',questID=1}},
 {{kind='quest',questID=2}},{{kind='quest_container',questID=3}},
 {{kind='quest',questID=1},{kind='vendor'}},{{kind='quest',questID=1},{kind='quest',questID=2}},
 {{kind='quest',questID=1},{kind='quest',questID=99}}})do
 local g={targetLevel=10,acquisitionPlan={routes=routes}}
 local direct=a:GetAcquisitionMinimumLevel(g)
 local expected=math.max(10,direct or 10)
 assert(a:GetRecommendationRecord(g).targetLevel==expected,'quest bound changed access level')
end
local ordinary={targetLevel=10,acquisitionPlan={routes={{kind='vendor'}}}}
minimumCalls=0;assert(a:GetRecommendationRecord(ordinary)==ordinary and minimumCalls==0)

-- Profile samples are bounded; start/stop restores methods and errors clean up.
debugprofilestop=function()return os.clock()*1000 end
a.RefreshOverlay=function(self)self:WithRecommendationSnapshot(check)end
local original=a.RefreshOverlay
a:StartPerformanceCapture()
for _=1,140 do a:RefreshOverlay('test-event')end
local profile=a:StopPerformanceCapture()
assert(a.RefreshOverlay==original and not a.performanceStats and not a.recommendationSnapshot)
local sample=profile.samples.RefreshOverlay
assert(sample.calls==140 and sample.windowSamples==128 and #profile.refreshes==128)
assert(sample.maxMilliseconds>=sample.averageMilliseconds and sample.p95Milliseconds>=sample.p50Milliseconds)
assert(sample.triggers['test-event']==140)
a.RefreshOverlay=function()error('profile failure')end
a:StartPerformanceCapture();assert(not pcall(a.RefreshOverlay,a,'failed-event'))
assert(a.performanceStats.trigger==nil);a:StopPerformanceCapture()
print('PASS synchronous snapshots: keys/options/arity/nesting, planning bypass, errors, fresh state, quest bounds and bounded optional diagnostics')
