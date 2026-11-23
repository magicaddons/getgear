-- Real cumulative runtime, deterministic events/frame ticks and group boundaries.
-- Optional baseline mode measures the identical workload on the production head.
local root=arg[1] or '.'
local baseline=arg[2]=='baseline' or os.getenv('GETGEAR_OVERLAY_BASELINE')=='1'
local function read(path)local f=assert(io.open(path));local s=f:read('*a');f:close();return s end
local dir=arg[0]:match('^(.*[/])') or 'tests/'
local fixture=read(dir..'beta4-slot-ui.lua')
local prefix=fixture:sub(1,assert(fixture:find('local addon={',1,true))-1)
local tests=read(dir..'starred-row-refresh.lua')
local marker='local body=[=[\n'
local setup=tests:sub(assert(tests:find(marker,1,true))+#marker)
setup=setup:sub(1,assert(setup:find('local function starButton(row)',1,true))-1)
setup=setup:gsub("return 23 end", "return testLevel end")
setup=setup:gsub('materialsCollapsed=true','materialsCollapsed=false')
setup=setup:gsub('local addon={}', [[
local currentMap,currentMapName=1429,nil
C_Map={GetBestMapForUnit=function()return currentMap end,
 GetMapInfo=function(id)return {name=currentMapName or (id==1429 and 'Elwynn Forest' or 'Westfall')}end}
local combat=false
InCombatLockdown=function()return combat end
local addon={}
]])
local body=[=[
detail:Hide()
local function sortedRows()
 local rows=visibleRows(objContent)
 table.sort(rows,function(a,b)return -a.points[1][5]<-b.points[1][5]end)
 return rows
end
local counts={}
for _,name in ipairs({'RefreshOverlay','GetItems','ComposeStarredItems','GetCombinedMaterialRows','GetGearComparison'})do
 local fn=addon[name];addon[name]=function(...)counts[name]=(counts[name]or 0)+1;return fn(...)end
end
local function measure(label,fn)
 counts={};collectgarbage('collect');collectgarbage('stop')
 local heap=collectgarbage('count');local started=os.clock();fn()
 local cpu,growth=(os.clock()-started)*1000,collectgarbage('count')-heap
 collectgarbage('restart');collectgarbage('collect')
 print(string.format('IDLE_GROUPS %s level=%d %s cpu=%.3fms heapGrowth=%.1fKiB refresh=%d items=%d compose=%d totals=%d comparisons=%d',
  testClass,testLevel,label,cpu,growth,counts.RefreshOverlay or 0,counts.GetItems or 0,
  counts.ComposeStarredItems or 0,counts.GetCombinedMaterialRows or 0,counts.GetGearComparison or 0))
end
measure('same map zones x20',function()for _=1,20 do event('ZONE_CHANGED');event('ZONE_CHANGED_NEW_AREA')end end)
if not baseline then assert(not next(counts),'unchanged map rebuilt the overlay')end
measure('combat x20',function()for _=1,20 do combat=true;event('PLAYER_REGEN_DISABLED');combat=false;event('PLAYER_REGEN_ENABLED')end end)
if not baseline then assert(not next(counts),'combat rebuilt always-visible overlay')end
local ticks=0
measure('idle frames x3600',function()
 for _=1,3600 do for _,f in ipairs(frames)do
  if f:IsShown() and f.scripts.OnUpdate then ticks=ticks+1;f.scripts.OnUpdate(f,1/60)end
 end end
end)
if not baseline then assert(ticks==0 and not next(counts),'overlay has an idle frame callback')end
print('FRAME_CALLBACKS '..testClass..' '..ticks)
measure('pages x10',function()for _=1,10 do click(button(overlay,'>'));click(button(overlay,'<'))end end)
if not baseline then assert(not counts.GetItems and not counts.ComposeStarredItems and not counts.GetCombinedMaterialRows,'page navigation rebuilt selection/totals')end
measure('slots x3',function()
 for _,label in ipairs({'Head','Rings','All Slots'})do
  click(GetGear_OverlaySlotMenu.parent);click(button(GetGear_OverlaySlotMenu,label))
 end
end)
if not baseline then assert(not counts.GetItems and not counts.GetCombinedMaterialRows,'slot action rebuilt selection/totals')end
addon:ToggleOverlay()
measure('closed zones x20',function()for _=1,20 do event('ZONE_CHANGED');event('ZONE_CHANGED_NEW_AREA')end end)
assert(not counts.GetItems and not counts.GetCombinedMaterialRows,'closed overlay evaluated data')
addon:ToggleOverlay()
if baseline then return end
-- Real map/name changes must still refresh immediately, including transitions
-- through an unavailable map; repeated subzone events then remain cheap.
counts={};currentMap=1436;event('ZONE_CHANGED');assert(counts.GetItems==1)
event('ZONE_CHANGED_NEW_AREA');assert(counts.GetItems==1)
currentMap=nil;event('ZONE_CHANGED');assert(counts.GetItems==2)
currentMap=1429;event('ZONE_CHANGED_NEW_AREA');assert(counts.GetItems==3)
currentMapName='Westfall';event('ZONE_CHANGED');assert(counts.GetItems==4)
currentMapName=nil;event('ZONE_CHANGED');assert(counts.GetItems==5)
local getMap=C_Map.GetBestMapForUnit
C_Map.GetBestMapForUnit=function()error('transient map API failure')end
event('ZONE_CHANGED');assert(counts.GetItems==6,'uncertain map result was cached')
C_Map.GetBestMapForUnit=getMap;event('ZONE_CHANGED');assert(counts.GetItems==7)
-- Hide-in-combat keeps data fresh on returning; no calculation on hiding.
db.overlay.hideInCombat=true;counts={}
combat=true;event('PLAYER_REGEN_DISABLED');assert(not overlay:IsShown() and not next(counts))
event('BAG_UPDATE_DELAYED');advance(1);assert(not counts.GetItems)
combat=false;event('PLAYER_REGEN_ENABLED');assert(overlay:IsShown() and counts.GetItems==1)
db.overlay.hideInCombat=false
-- Resize polling exists only during an actual drag, including lost mouse-up.
local grip
for _,f in ipairs(overlay.children)do if f.scripts.OnMouseDown and f.scripts.OnMouseUp and f.width==21 then grip=f end end
assert(grip and not grip.scripts.OnUpdate)
IsMouseButtonDown=function()return false end
grip.scripts.OnMouseDown(grip,'LeftButton');assert(grip.scripts.OnUpdate)
grip.scripts.OnUpdate(grip);assert(not grip.scripts.OnUpdate and not overlay.isSizing)
-- Closed/open gameplay-event processing, with the same map transition.
addon:ToggleOverlay();counts={};currentMap=1436;event('ZONE_CHANGED')
assert(not counts.GetItems and not counts.GetCombinedMaterialRows)
addon:ToggleOverlay();assert(counts.GetItems==1)
if not testFull then return end
local function selectGroup(label)
 click(GetGear_OverlayGroupMenu.parent);click(button(GetGear_OverlayGroupMenu,label))
 assert(GetGear_OverlayGroupMenu.parent.text==label..' v')
end
-- Exercise established exclusion rules before replacing recommendation input
-- with the boundary models below. Starred/Other must both exclude these IDs.
local live=assert(addon:GetItems('tracker')[1])
assert(addon:SetItemStarred(live.itemID,true))
local function excluded()
 for _,label in ipairs({'Starred','Other'})do
  selectGroup(label)
  for _,row in ipairs(sortedRows())do assert(item(row).itemID~=live.itemID,'excluded objective entered group')end
 end
end
addon:SetHidden(live,true);excluded();addon:SetHidden(live,false)
addon:SetStatus(live,'acquired');excluded();addon:SetStatus(live,nil)
addon:SetStatus(live,'skipped');excluded();addon:SetStatus(live,nil)
addon:SetItemStarred(live.itemID,false);selectGroup('All')
-- Controlled eligible models exercise exact pagination boundaries independently
-- of catalogue size and stat relevance. Every record has real source eligibility.
local candidates={}
addon:InitializeItemSearch()
for _,g in ipairs(addon.Gear)do
 if not addon:GetSearchRestriction(g,true) then candidates[#candidates+1]=g end
 if #candidates==120 then break end
end
assert(#candidates==120,'candidate count '..#candidates)
addon.ShouldShowOverlayStatChanges=function()return true end
addon.ShouldShowOverlayWorldBoEDrops=function()return true end
addon.ShouldShowOverlayAcquisition=function()return true end
local model={}
addon.GetItems=function()return model end
local function ids()
 local out={};for _,r in ipairs(sortedRows())do out[#out+1]=item(r).itemID end;return table.concat(out,',')
end
local function verify(starred,expected)
 local rows=sortedRows();assert(#rows==math.min(32,expected),'group count differs')
 for _,r in ipairs(rows)do assert(addon:IsItemStarred(item(r).itemID)==starred,'mixed groups')end
end
for _,size in ipairs({54,120})do
 model={};for i=1,size do model[i]=candidates[i]end
 for _,starCount in ipairs({0,1,31,32,33,54})do
  db.starredItems={};for i=1,starCount do db.starredItems[candidates[i].itemID]=true end
  addon:RefreshAll();selectGroup('All');selectGroup('Starred')
  -- Each group remembers a page, so reset explicitly for boundary assertions.
  while button(overlay,'<').enabled do click(button(overlay,'<'))end
  verify(true,starCount)
  selectGroup('Other');while button(overlay,'<').enabled do click(button(overlay,'<'))end
  verify(false,size-starCount)
  if size-starCount>32 then
   click(button(overlay,'>'));local second=ids()
   selectGroup('Starred');verify(true,starCount)
   selectGroup('Other');assert(ids()==second,'Other lost its independent page')
   click(button(overlay,'<'))
  end
  if starCount>32 then
   selectGroup('Starred');click(button(overlay,'>'));local second=ids()
   selectGroup('Other');selectGroup('Starred');assert(ids()==second,'Starred lost its independent page')
   click(button(overlay,'<'))
  end
 end
end
-- Targeted star changes transfer membership while preserving the active group.
db.starredItems={};addon:RefreshAll();selectGroup('Other')
local target=item(sortedRows()[1]);counts={}
assert(addon:SetItemStarred(target.itemID,true));verify(false,119)
assert(GetGear_OverlayGroupMenu.parent.text=='Other v')
assert(not counts.GetItems and not counts.GetCombinedMaterialRows)
selectGroup('Starred');verify(true,1)
assert(addon:SetItemStarred(target.itemID,false));verify(true,0)
local empty=false
for _,label in ipairs(objContent.children)do if label.kind=='FontString' and label:IsShown() and label.text=='No starred recommendations.'then empty=true end end
assert(empty,'missing empty starred message')
-- Every slot choice applies to both groups, keeping selection work cached.
assert(addon:SetItemStarred(target.itemID,true))
for _,slot in ipairs(addon.EquipmentSlotFilters)do
 click(GetGear_OverlaySlotMenu.parent);counts={};click(button(GetGear_OverlaySlotMenu,slot[2]))
 for _,label in ipairs({'Starred','Other'})do
  selectGroup(label)
  for _,r in ipairs(sortedRows())do
   local g=item(r);assert(addon:MatchesEquipmentSlotFilter(g,slot[1]))
   assert(addon:IsItemStarred(g.itemID)==(label=='Starred'))
  end
 end
 assert(not counts.GetItems and not counts.GetCombinedMaterialRows,'slot/group action rebuilt gameplay data')
end
print('PASS 54/120 recommendations; 0/1/31/32/33/54 stars; independent pages, membership, empty groups and all slots')
]=]
for _,c in ipairs({
 {'WARRIOR','Warrior','Alliance','NightElf',27,true},
 {'DRUID','Druid','Horde','Tauren',23},
 {'PRIEST','Priest','Alliance','Human',31},
 {'MAGE','Mage','Horde','Scourge',60},
 {'SHAMAN','Shaman','Horde','Orc',45},
 {'HUNTER','Hunter','Alliance','NightElf',15},
})do
 local env=setmetatable({arg={[1]=root},testClass=c[1],testClassName=c[2],testFaction=c[3],testRace=c[4],testLevel=c[5],testFull=c[6],baseline=baseline},{__index=_G})
 env._G=env;env.loadfile=function(path)return load(read(path),'@'..path,'t',env)end
 assert(load(prefix..setup..body,'overlay idle/groups','t',env))()
end
print('PASS residual overlay workload matrix (synthetic; no client frame-pacing claim)')
