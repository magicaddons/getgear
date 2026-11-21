-- Paired synthetic timings/call counts using production Core/UI, same fixtures.
-- CPU timings are observations, never claims about Forever frame pacing.
local baseline,feature=assert(arg[1]),assert(arg[2])
local function read(path)local f=assert(io.open(path));local s=f:read('*a');f:close();return s end
local fixture=read(feature..'/tests/beta4-slot-ui.lua')
local prefix=fixture:sub(1,assert(fixture:find('local addon={',1,true))-1)
local tests=read(feature..'/tests/starred-row-refresh.lua')
local marker='local body=[=[\n'
local setup=tests:sub(assert(tests:find(marker,1,true))+#marker)
setup=setup:sub(1,assert(setup:find('local function starButton(row)',1,true))-1)
local tail=[=[
local function visibleID()
 local rows=visibleRows(objContent)
 table.sort(rows,function(a,b)return -a.points[1][5]<-b.points[1][5]end)
 return assert(item(rows[math.min(2,#rows)])).itemID
end
local counts={}
for _,name in ipairs({'GetItems','GetCombinedMaterialRows','GetUndocumentedCrafts',
 'GetEligibleAcquisitionRoutes','GetGearComparison','GetCraftingMaterialRows'})do
 local fn=addon[name]
 addon[name]=function(...)counts[name]=(counts[name]or 0)+1;return fn(...)end
end
return {addon=addon,counts=counts,visibleID=visibleID}
]=]
local function runtime(path)
 local env=setmetatable({arg={[1]=path},testClass='DRUID',testClassName='Druid',testRace='NightElf',testFaction='Alliance'},{__index=_G});env._G=env
 env.loadfile=function(name)return load(read(name),'@'..name,'t',env)end
 return assert(load(prefix..setup..tail,'star timing runtime','t',env))()
end
local base,new=runtime(baseline),runtime(feature)
local function prepare(runtime,kind)
 local addon=runtime.addon
 addon.db.starredItems={}
 if kind=='large collection' then
  local count=0
  for _,g in ipairs(addon.Gear)do
   if not addon:GetSearchRestriction(g,true)then
    addon.db.starredItems[g.itemID]=true;count=count+1
    if count==120 then break end
   end
  end
 end
 addon:RefreshOverlay();addon:RefreshUI()
 if kind=='future item' then
  for _,g in ipairs(addon.Gear)do
   if g.targetLevel>=40 and not addon:GetSearchRestriction(g,true) then return g.itemID end
  end
 end
 return runtime.visibleID()
end
local function batch(runtime,id)
 collectgarbage('collect')
 for name in pairs(runtime.counts)do runtime.counts[name]=nil end
 local memory=collectgarbage('count');local started=os.clock()
 for _=1,20 do
  assert(runtime.addon:SetItemStarred(id,true));assert(runtime.addon:SetItemStarred(id,false))
 end
 local cpu,heap=(os.clock()-started)*1000,collectgarbage('count')-memory
 local counts={};for name,count in pairs(runtime.counts)do counts[name]=count end
 return cpu,heap,counts
end
local function median(values)table.sort(values);return values[math.ceil(#values/2)]end
for _,kind in ipairs({'visible item','future item','large collection'})do
 local oldID,newID=prepare(base,kind),prepare(new,kind)
 assert(oldID==newID,'scenario target differs')
 -- Warm the same transition in each runtime.
 batch(base,oldID);batch(new,newID)
 local oldTimes,newTimes,oldHeaps,newHeaps={},{},{},{}
 local oldCounts,newCounts
 for i=1,7 do
  local a,b,c,d,e,f
  if i%2==1 then a,b,c=batch(base,oldID);d,e,f=batch(new,newID)
  else d,e,f=batch(new,newID);a,b,c=batch(base,oldID)end
  oldTimes[#oldTimes+1]=a;oldHeaps[#oldHeaps+1]=b
  newTimes[#newTimes+1]=d;newHeaps[#newHeaps+1]=e
  oldCounts,newCounts=c,f
  for _,name in ipairs({'GetItems','GetCombinedMaterialRows','GetUndocumentedCrafts'})do
   assert(not c[name] and not f[name],'toggle rebuilt recommendations/totals')
  end
  for name,count in pairs(f)do assert(count<=(c[name]or 0),'new computation growth: '..name)end
 end
 local a,b=median(oldTimes),median(newTimes)
 print(string.format('STAR_PAIRED %s: baseline %.3fms feature %.3fms change %.2f%% per 40 toggles; net heap %.1f/%.1f KiB',kind,a,b,(b/a-1)*100,median(oldHeaps),median(newHeaps)))
 for _,name in ipairs({'GetEligibleAcquisitionRoutes','GetGearComparison','GetCraftingMaterialRows'})do
  print(string.format('COUNTS %s %s baseline=%d feature=%d',kind,name,oldCounts[name]or 0,newCounts[name]or 0))
 end
end
print('PASS paired rapid star toggles: identical IDs, no recommendation/totals work, no computation count growth')
