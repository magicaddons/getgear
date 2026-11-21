-- Production TOC/Core/UI with stateful frames; not a client-rendering claim.
local root=arg[1] or '.'
local dir=arg[0]:match('^(.*[/])') or 'tests/'
local file=assert(io.open(dir..'beta4-slot-ui.lua'));local source=file:read('*a');file:close()
local prefix=source:sub(1,assert(source:find('local addon={',1,true))-1)
local body=[=[
function methods:SetTexture(path)self.texturePath=path end
function methods:RegisterForClicks(...)self.clicks={...}end
function methods:UpdateScrollChildRect()self.layoutCommits=(self.layoutCommits or 0)+1 end
local originalSetText=methods.SetText
function methods:SetText(text)
 originalSetText(self,text)
 if self.kind=='EditBox' and self.scripts.OnTextChanged then self.scripts.OnTextChanged(self,false) end
end
function methods:RegisterEvent(event)self.events=self.events or {};self.events[event]=true end
function methods:SetFocus()self.focused=true end
function methods:ClearFocus()self.focused=false end
local now,queue=0,{}
C_Timer={After=function(delay,fn)queue[#queue+1]={at=now+delay,fn=fn}end}
local function advance(seconds)
 now=now+seconds
 for i=#queue,1,-1 do if queue[i].at<=now then local fn=table.remove(queue,i).fn;fn() end end
end
GetTime=function()return now end;time=function()return 1000 end
GetRealmName=function()return 'Realm'end
UnitClass=function()return testClassName,testClass end
UnitRace=function()return testRace,testRace end
UnitFactionGroup=function()return testFaction end;UnitLevel=function()return 23 end
SlashCmdList={}
C_Item={GetItemCount=function()return 0 end}
local addon={}
for line in io.lines(root..'/GetGear.toc')do
 if line:match('%.lua$')then assert(loadfile(root..'/'..line))('GetGear',addon)end
end
local function event(name,...)
 for _,frame in ipairs(frames)do if frame.events and frame.events[name] and frame.scripts.OnEvent then frame.scripts.OnEvent(frame,name,...)end end
end
local sourceCalls=0;local sourceFn=addon.HasEligibleAcquisitionSource
addon.HasEligibleAcquisitionSource=function(...)sourceCalls=sourceCalls+1;return sourceFn(...)end
local db={schemaVersion=4,status={retained='skipped'},hidden={keep=true},overlay={visible=true,materialsCollapsed=true},detail={}}
GetGear_CharacterDB=db;event('ADDON_LOADED','GetGear');advance(1)
local overlay=GetGear_TrackerOverlay
local popup=GetGear_ItemSearch
local edit=GetGear_ItemSearchInput
local detail=GetGear_MainWindow
local function children(parent,predicate)
 local out={};for _,frame in ipairs(frames)do if frame.parent==parent and predicate(frame)then out[#out+1]=frame end end;return out
end
local function button(parent,label)
 return assert(children(parent,function(f)return f.kind=='Button' and f.text==label end)[1],'missing button '..label)
end
local function click(frame)assert(frame.scripts.OnClick);frame.scripts.OnClick(frame,'LeftButton')end
local function visibleRows(parent)
 return children(parent,function(f)return f.kind=='Frame' and f:IsShown() and f.points[1] and #f.children>5 end)
end
local function item(row)
 for _,child in ipairs(row.children)do if child.gearRecord then return child.gearRecord end end
end
local function findContent(parent,needle)
 for _,f in ipairs(frames)do
  if f.parent and f.parent.parent==parent and f.kind=='Frame' and f.parent.kind=='ScrollFrame' then return f end
 end
end
local objContent=findContent(overlay)
assert(objContent)
local function starButton(row)
 return assert(children(row,function(f)return f.kind=='Button' and f.starTexture~=nil end)[1])
end
addon:ShowUI()
local detailContent=findContent(detail)
assert(detailContent)

local function starButton(row)
 return assert(children(row,function(f)return f.kind=='Button' and f.starTexture~=nil end)[1])
end
local function sortedRows(parent)
 local rows=visibleRows(parent)
 table.sort(rows,function(a,b)return -a.points[1][5]<-b.points[1][5] end)
 return rows
end
local function contains(parent,id)
 for _,row in ipairs(sortedRows(parent))do if item(row).itemID==id then return row end end
end
local function expected(mode,scope)
 local base=addon:GetItems(mode)
 if scope=='overlay' then
  local filtered={}
  for _,g in ipairs(base)do
   if addon:ShouldShowOverlayStatChanges(g) and addon:ShouldShowOverlayWorldBoEDrops(g)
      and addon:ShouldShowOverlayAcquisition(g) then filtered[#filtered+1]=g end
  end
  base=filtered
 end
 return addon:FilterEquipmentSlots(addon:ComposeStarredItems(base,mode,nil,true),addon:GetEquipmentSlotFilter(scope))
end
local function verifyOrder(parent,mode,scope,cap)
 local list=expected(mode,scope)
 local rows=sortedRows(parent)
 if #list==0 then
  assert(#rows==(scope=='detail' and 1 or 0),'empty state differs')
  if rows[1] then
   assert(not starButton(rows[1]):IsShown(),'empty state retained clickable star')
  end
  return
 end
 assert(#rows==math.min(#list,cap),'visible row count differs '..scope..' '..addon:GetEquipmentSlotFilter(scope)..' actual='..#rows..' expected='..math.min(#list,cap))
 local seen,bottom={},0
 for i,row in ipairs(rows)do
  local g=item(row)
  assert(g.itemID==list[i].itemID,'visible order differs immediately after toggle')
  assert(not seen[g.itemID],'duplicate row');seen[g.itemID]=true
  local y=-row.points[1][5]
  assert(y>=bottom,'row backgrounds/click targets overlap');bottom=y+row:GetHeight()
  local star=starButton(row)
  assert(star.record.itemID==g.itemID and star.starred==addon:IsItemStarred(g.itemID))
  assert(star.starTexture.texturePath:find(star.starred and 'StarFilled.tga' or 'StarOutline.tga',1,true))
  assert(star.clicks[1]=='LeftButtonUp','star click registration differs')
  -- Every direct action lives above the identity, with disjoint horizontal targets.
  local right=0
  local actions=children(row,function(f)return f.kind=='Button' and f:IsShown() and f.points[1]
      and f.points[1][1]=='TOPRIGHT' end)
  table.sort(actions,function(a,b)return -a.points[1][4]<-b.points[1][4]end)
  for _,action in ipairs(actions)do
   local inset=-action.points[1][4]
   assert(inset>=right,'action controls overlap');right=inset+action:GetWidth()
   assert(-action.points[1][5]+action:GetHeight()<=34,'action extends into identity')
  end
 end
 assert(parent:GetHeight()>=bottom,'scroll child clips last row')
 local count=0;for _,g in ipairs(list)do if addon:IsItemStarred(g.itemID)then count=count+1 end end
 local heading=false
 for _,label in ipairs(parent.children)do
  if label.kind=='FontString' and label:IsShown() and label.text=='Starred Items ('..count..')' then heading=true end
 end
 assert(count==0 or heading,'star count/heading not updated')
 assert((parent.parent.layoutCommits or 0)>0,'native scroll rectangle was not committed')
end
local function verifyBoth()
 verifyOrder(objContent,'tracker','overlay',32)
 verifyOrder(detailContent,'available','detail',40)
end
local toggleCount,slotCount=0,0
-- Existing recommendations, repeated changes, all slot selectors and All Slots.
for _,slot in ipairs(addon.EquipmentSlotFilters)do
 if testFull or slot[1]=='all' or slot[1]=='legs' or slot[1]=='chest' or slot[1]=='weapons' then
 addon:SetEquipmentSlotFilter('overlay',slot[1]);addon:SetEquipmentSlotFilter('detail',slot[1])
 addon:RefreshOverlay();addon:RefreshUI()
 local rows=sortedRows(objContent)
 if #rows>0 then
  slotCount=slotCount+1
  local ids={}
  for i=math.min(3,#rows),1,-1 do ids[#ids+1]=item(rows[i]).itemID end
  for _,id in ipairs(ids)do
   click(starButton(assert(contains(objContent,id))))
   assert(addon:IsItemStarred(id));toggleCount=toggleCount+1;verifyBoth()
   assert(addon.db.overlay.slotFilter==slot[1] and addon.db.detail.slotFilter==slot[1])
  end
  for _,id in ipairs(ids)do
   click(starButton(assert(contains(detailContent,id))))
   assert(not addon:IsItemStarred(id));toggleCount=toggleCount+1;verifyBoth()
  end
 end
end
end
assert(slotCount>0,'no real catalogue slot coverage')
if testFull then
assert(slotCount>=8,'insufficient Druid catalogue slot coverage')
-- A future star enters a sparse visible pool ahead of an existing row. Then
-- grow beyond both caps and star on a later page: the new section stays reachable.
addon:SetEquipmentSlotFilter('overlay','legs');addon:SetEquipmentSlotFilter('detail','legs')
addon:RefreshOverlay();addon:RefreshUI()
local candidates={}
for _,g in ipairs(addon.Gear)do
 if addon:MatchesEquipmentSlotFilter(g,'legs') and g.targetLevel>23 and not addon:GetSearchRestriction(g,true) then
  candidates[#candidates+1]=g
 end
end
assert(#candidates>42)
local calls,originals={},{}
for _,name in ipairs({'GetItems','GetCombinedMaterialRows','GetUndocumentedCrafts'})do
 originals[name]=addon[name];addon[name]=function(...)calls[name]=(calls[name]or 0)+1;return originals[name](...)end
end
for i=1,43 do assert(addon:SetItemStarred(candidates[i].itemID,true))end
assert(not next(calls),'targeted toggle rebuilt recommendations/materials')
for name,fn in pairs(originals)do addon[name]=fn end
verifyBoth()
local nextPage=button(overlay,'>');click(nextPage)
assert(addon:SetItemStarred(candidates[44].itemID,true));verifyBoth()
assert(addon.db.overlay.slotFilter=='legs' and addon.db.detail.slotFilter=='legs')
-- Rendered row bodies are reusable even in a large collection: no source,
-- comparison or material reconstruction for already displayed identities.
local visibleID=item(sortedRows(objContent)[2]).itemID
addon:SetItemStarred(visibleID,false);addon:SetItemStarred(visibleID,true)
local sourceBefore=sourceCalls
for _=1,20 do addon:SetItemStarred(visibleID,false);addon:SetItemStarred(visibleID,true)end
assert(sourceCalls-sourceBefore<=100,'reused stars recalculated visible source pages')
-- Width/state changes measure headers afresh; reuse on a subsequent toggle
-- must preserve those measured positions and full hit targets.
for _,width in ipairs({320,400,580,320})do
 overlay:SetWidth(width)
 for _,state in ipairs({'minimized','expanded','ordinary'})do
  for _,g in ipairs(candidates)do db.overlay.minimized[g.id]=state=='minimized';db.overlay.expanded[g.id]=state=='expanded' end
  addon:RefreshOverlay();addon:RefreshUI();verifyBoth()
  addon:SetItemStarred(visibleID,false);addon:SetItemStarred(visibleID,true);verifyBoth()
 end
end
-- Search uses the same assets and full names, with dynamic result-row geometry.
local searchButton=assert(children(overlay,function(f)return f.kind=='Button' and f.width==24 and f.text=='' end)[1])
click(searchButton);edit:SetText('leggings')
local searchRows={}
for _,f in ipairs(frames)do
 if f.star and f.label and f:IsShown() then searchRows[#searchRows+1]=f end
end
assert(#searchRows>0)
local bottom=0
for _,row in ipairs(searchRows)do
 assert(row.label.text:find(row.gearRecord.name,1,true),'search truncated item name')
 local y=-row.points[1][5]
 assert(y>=bottom and row:GetHeight()>=32+row.label:GetStringHeight(),'search rows clip or overlap')
 bottom=y+row:GetHeight()
 assert(row.star.starTexture.texturePath:find('Star',1,true))
end
-- Force long identities/metadata through the complete detailed renderer;
-- preserve real IDs/routes while varying presentation fields and widths.
local getItems=addon.GetItems
local fixtures={}
for i=1,3 do
 local record={};for k,v in pairs(candidates[i])do record[k]=v end
 record.name=i==1 and 'Short name' or string.rep('A long equipment name that wraps safely ',i+2)
 record.zone=string.rep('Lengthy acquisition location ',6)
 fixtures[i]=record
end
addon.GetItems=function()return fixtures end
db.starredItems={}
addon:SetEquipmentSlotFilter('detail','all')
for _,width in ipairs({720,960,1260,720})do
 detail:SetWidth(width);detailContent.parent:SetWidth(width-52)
 addon:RefreshUI()
 local bottom=0
 for _,row in ipairs(sortedRows(detailContent))do
  local identity,metadata,comparison,description
  for _,label in ipairs(row.children)do
   if label.kind=='FontString' and label:IsShown() and label.points[1] then
    if label.text==item(row).name then identity=label end
    if label.text:find('Lengthy acquisition location',1,true) then metadata=label end
   end
  end
  assert(identity and metadata)
  local nameY=-identity.points[1][#identity.points[1]]
  local metaY=-metadata.points[1][#metadata.points[1]]
  assert(nameY>=34 and metaY>=nameY+identity:GetStringHeight()+8,'wrapped identity collides with metadata')
  local top=-row.points[1][5]
  assert(top>=bottom,'detail row positions ignore dynamic height');bottom=top+row:GetHeight()
 end
 assert(detailContent:GetHeight()>=bottom,'detailed scroll child clips content')
end
-- A hidden pooled row can retain a previous width. Entering through a
-- star after resizing must render it at the current width, not reuse its body.
local late=addon:GetSearchRecord(candidates[#candidates].itemID)
addon.GetItems=function()return {fixtures[1],late}end
detailContent.parent:SetWidth(1208);addon:RefreshUI()
addon.GetItems=function()return {fixtures[1]}end
detailContent.parent:SetWidth(668);addon:RefreshUI()
assert(addon:SetItemStarred(late.itemID,true))
local entering=assert(contains(detailContent,late.itemID))
for _,label in ipairs(entering.children)do
 if label.kind=='FontString' and label:IsShown() and label.points[1] and label.points[1][1]=='TOPLEFT' then
  local point=label.points[1]
  local left=point[#point-1]
  if type(left)=='number' and left==62 then
   assert(left+label:GetWidth()<=entering:GetWidth()-10,'hidden pooled row retained stale width after star')
  end
 end
end
assert(addon:SetItemStarred(late.itemID,false))
-- Empty-state labels must invalidate the old body before a future item
-- returns through a targeted star update (no category switch).
addon.GetItems=function()return {} end
addon:RefreshUI()
local emptyRow=assert(sortedRows(detailContent)[1])
assert(addon:SetItemStarred(fixtures[1].itemID,true))
local restored=assert(contains(detailContent,fixtures[1].itemID))
local restoredName=false
for _,label in ipairs(restored.children)do
 if label.kind=='FontString' and label.text==addon:GetSearchRecord(fixtures[1].itemID).name then restoredName=true end
end
assert(restoredName and starButton(restored):IsShown(),'star update reused empty-state labels')
addon.GetItems=getItems
end -- extended reproduction/geometry/large-collection cases
print('PASS '..testClass..' '..testFaction..' level 23 production rows: '..toggleCount..' immediate cross-view toggles across '..slotCount..' slot views; counts/order/ordinary reinsertion, assets, targets and scroll rectangles'..(testFull and '; extended future/page/resize/search/name cases' or ''))
]=]
local contexts={
 {'DRUID','Druid','Alliance','NightElf',true},
 {'DRUID','Druid','Horde','Tauren'},
 {'WARRIOR','Warrior','Alliance','Human'}, {'WARRIOR','Warrior','Horde','Orc'},
 {'PALADIN','Paladin','Alliance','Human'},
 {'HUNTER','Hunter','Alliance','NightElf'}, {'HUNTER','Hunter','Horde','Orc'},
 {'ROGUE','Rogue','Alliance','Human'}, {'ROGUE','Rogue','Horde','Orc'},
 {'PRIEST','Priest','Alliance','Human'}, {'PRIEST','Priest','Horde','Scourge'},
 {'SHAMAN','Shaman','Horde','Orc'},
 {'MAGE','Mage','Alliance','Human'}, {'MAGE','Mage','Horde','Scourge'},
 {'WARLOCK','Warlock','Alliance','Human'}, {'WARLOCK','Warlock','Horde','Orc'},
}
for _,context in ipairs(contexts)do
 local env=setmetatable({arg={[1]=root},testClass=context[1],testClassName=context[2],
  testFaction=context[3],testRace=context[4],testFull=context[5]},{__index=_G})
 env._G=env
 env.loadfile=function(path)
  local f=assert(io.open(path));local text=f:read('*a');f:close()
  return load(text,'@'..path,'t',env)
 end
 assert(load(prefix..body,'starred row refresh '..context[1]..context[3],'t',env))()
end
local cold=body:sub(1,assert(body:find('local function starButton(row)',1,true))-1)
cold=cold:gsub('visible=true,materialsCollapsed=true','visible=true,materialsCollapsed=true,objectivesCollapsed=true')
cold=cold..[==[
local before=#frames
local g=assert(addon:GetItems('tracker')[1])
assert(addon:SetItemStarred(g.itemID,true))
assert(#frames==before,'cold collapsed star allocated off-screen rows')
assert(#children(objContent,function(f)return f.kind=='Frame'end)==0,'collapsed tracker created objective bodies')
]==]
local coldEnv=setmetatable({arg={[1]=root},testClass='DRUID',testClassName='Druid',testFaction='Alliance',testRace='NightElf'},{__index=_G})
coldEnv._G=coldEnv
coldEnv.loadfile=function(path)
 local f=assert(io.open(path));local text=f:read('*a');f:close();return load(text,'@'..path,'t',coldEnv)
end
assert(load(prefix..cold,'cold collapsed star','t',coldEnv))()
print('PASS all nine classes / 16 original faction-valid race/class contexts; cold collapsed tracker allocation budget')
