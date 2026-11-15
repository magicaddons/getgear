-- Offline catalogue-wide button eligibility, not live map rendering.
local root=arg[1]or'.';local output=arg[2]or(root..'/docs/source-audit-1-60/reconciliation-20261109/acceptance2_button_coverage.csv')
local a={};for f in assert(io.open(root..'/GetGear.toc')):read('*a'):gmatch('[^\r\n]+')do
 if f:match('%.lua$')and f~='Core.lua'and f~='UI.lua'and f~='AltInventory.lua'then assert(loadfile(root..'/'..f))('GetGear',a)end
end
local classes={'PRIEST','MAGE','WARLOCK','DRUID','ROGUE','HUNTER','SHAMAN','WARRIOR','PALADIN'}
local gameID={PRIEST=5,MAGE=8,WARLOCK=9,DRUID=11,ROGUE=4,HUNTER=3,SHAMAN=7,WARRIOR=1,PALADIN=2}
local class;UnitClass=function()return class,class,gameID[class]end
UnitFactionGroup=function()return'Alliance'end;UnitLevel=function()return 25 end
C_Map=nil;C_QuestLog=nil
local requests=0;C_Item={RequestLoadItemDataByID=function()requests=requests+1 end}
a.level=25;a.db={overlay={},hidden={},status={}}
local observations={};local checks=0
for _,c in ipairs(classes)do
 class=c;a.classToken=c
 for _,g in ipairs(a.EquipmentByClass[c])do
  checks=checks+1;local r=observations[g.itemID]or{classes=0,targets=0,point=0,area=0};observations[g.itemID]=r;r.classes=r.classes+1
  local t=a:GetAcquisitionMapTarget(g)
  if t then
   r.targets=r.targets+1
   if not t.chainUnresolved then
    if type(t.x)=='number'and type(t.y)=='number'and t.verification~='legacy-reference'then r.point=r.point+1
    elseif t.bounds then r.area=r.area+1 end
   end
   if t.source then local s=a.AcquisitionNavigationData.sources[t.source]or{};assert(s.serviceSide~=2,'known Horde-only service offered to Alliance')end
  end
 end
end
assert(checks==36669 and requests==0)
local ids={};for id in pairs(a.ItemCatalog)do ids[#ids+1]=id end;table.sort(ids)
local published={}
-- CSV's item-name column can contain commas/escaped quotes; never split it
-- using a plain comma expression and mistake that for verified coverage.
local raw=assert(io.open(root..'/docs/source-audit-1-60/reconciliation-20261109/navigation_coverage.csv')):read('*a')
local rows,row,field,quoted={}, {},'',false;local i=1
while i<=#raw do
 local c=raw:sub(i,i)
 if c=='"'then
  if quoted and raw:sub(i+1,i+1)=='"'then field=field..'"';i=i+1 else quoted=not quoted end
 elseif not quoted and(c==','or c=='\n')then
  row[#row+1]=field:gsub('\r$','');field=''
  if c=='\n' then rows[#rows+1]=row;row={}end
 else field=field..c end
 i=i+1
end
for n=2,#rows do published[tonumber(rows[n][1])]=rows[n][4]end
local counts={};local out=assert(io.open(output,'w'));out:write('itemID,name,category,eligibleClasses,classesWithTarget,classesWithPointData,classesWithAreaData,buttonCoverage,availabilityStatus,noTargetReason\n')
local function csv(v)v=tostring(v or'');return '"'..v:gsub('"','""')..'"'end
for _,id in ipairs(ids)do
 local p=a.AcquisitionNavigationData.items[tostring(id)]or{};local r=observations[id]or{classes=0,targets=0,point=0,area=0}
 local status=r.point>0 and'published_point_data'or r.area>0 and'published_area_data'or r.targets>0 and'written_or_native_only'or published[id]=='not_applicable'and'not_applicable'or'missing_actionable_target'
 counts[status]=(counts[status]or 0)+1
 local av=a.AcquisitionNavigationData.availability[tostring(id)]or{}
 local reason=r.targets==0 and (#(p.routes or{})>0 and 'Known source restricted/unresolved for this character context'or published[id]=='not_applicable'and'No fixed navigable source applicable'or'No structured actionable destination')or''
 out:write(table.concat({id,csv(a.ItemCatalog[id].name),csv(p.category),r.classes,r.targets,r.point,r.area,csv(status),csv(av.status),csv(reason)},','),'\n')
end
out:close()
local details=assert(io.open(output:gsub('%.csv$','.txt'),'w'))
details:write('Scope:all7707catalogueIDs/36669eligibleclassrecords;Alliancelevel25/source-only planning;no active quests/location or live rendering assumed. No item-cache requests.\n')
for _,k in ipairs({'published_point_data','published_area_data','written_or_native_only','missing_actionable_target','not_applicable'})do details:write(k..'='..tostring(counts[k]or 0)..'\n')end;details:close()
print('PASS AH2 button audit:7707items/36669classsourcechecks/knownHordeservicesexcluded/zeroitemcache requests;point/area/written/missing distinguished;actual rendering untested')
