-- Search is catalogue metadata; wishlist is separate from recommendation scoring.
local root=arg[1] or '.'
local a={level=25,classToken='MAGE'}
assert(loadfile(root..'/GuideState.lua'))('GetGear',a)
a.db={status={},hidden={},overlay={},detail={},starredItems={}}
a.ItemCatalog={};a.EquipmentByClass={MAGE={},WARRIOR={}}
local function add(id,name,level,slot,class)
 local r={itemID=id,id='item_'..id,name=name,targetLevel=level,slot=slot or 'Chest',class=class}
 a.ItemCatalog[id]=r
 if class~='WARRIOR' then a.EquipmentByClass.MAGE[#a.EquipmentByClass.MAGE+1]=r end
 a.EquipmentByClass.WARRIOR[#a.EquipmentByClass.WARRIOR+1]=r
 return r
end
local exact=add(1,'Moon',40);local duplicate=add(2,'Moon',40,'Ring')
local prefix=add(3,'Moon Light',10);local partial=add(4,'A Moon',20)
local other=add(5,'Sun',30,'Main Hand');local class=add(6,'Moon Blade',1,'Main Hand','WARRIOR')
local faction=add(7,'Moon Horde',1);faction.blocked=true
local missing=add(8,'Moon Incomplete',1);missing.slot=nil
local route=add(9,'Moon Route',1);route.routeBlocked=true
local noName=add(10,nil,1)
local owned,sourceCalls,comparisons=0,0,0
a.CanClassEquipGear=function(_,r,c)return not r.class or r.class==c end
a.IsFactionUseEligible=function(_,r)return not r.blocked,'Faction restriction' end
a.HasEligibleAcquisitionSource=function(_,r) sourceCalls=sourceCalls+1;return not r.routeBlocked end
a.IsGearEquipped=function(_,r) return r.itemID==owned end
a.GetObsoleteGearReason=function()comparisons=comparisons+1;return 'outclassed' end
local function ids(list)local out={};for _,r in ipairs(list)do out[#out+1]=r.itemID end;return table.concat(out,',')end
assert(ids(a:SearchEquipment('mOoN',12))=='1,2,6,7,8,3,9,4')
assert(ids(a:SearchEquipment('moon light'))=='3')
assert(ids(a:SearchEquipment('oon l'))=='3')
assert(#a:SearchEquipment('does not exist')==0 and #a:SearchEquipment('  ')==0)
assert(#a:SearchEquipment('moon',2)==2 and #a:SearchEquipment('moon',100)==8)
local results=a:SearchEquipment('moon',12)
assert(results[3].restriction=='Not equippable by this class')
assert(results[4].restriction=='Faction restriction' and results[5].restriction=='Incomplete catalogue information')
assert(sourceCalls==0 and comparisons==0,'autocomplete evaluated sources/stats')
local index=a.itemSearchIndex
for _=1,500 do for _,q in ipairs({'m','mo','moo','moon','mo','sun','nope'})do a:SearchEquipment(q)end end
assert(a.itemSearchIndex==index and index.builds==1 and sourceCalls==0)
assert(not a:SetItemStarred(6,true) and not a:SetItemStarred(7,true) and not a:SetItemStarred(8,true) and not a:SetItemStarred(9,true))
assert(not a:SetItemStarred(1,true,true) and not a:IsItemStarred(1))
assert(a:SetItemStarred(1,true) and a:IsItemStarred(1))
assert(a:SetItemStarred(1,true));local count=0;for _ in pairs(a.db.starredItems)do count=count+1 end;assert(count==1)
assert(a:SetItemStarred(3,true) and a:SetItemStarred(2,true))
local list={other,exact,prefix,duplicate,partial}
assert(ids(a:ComposeStarredItems(list,'tracker'))=='3,1,2,5,4','level/slot/name/id order or ordinary order changed')
assert(ids(list)=='5,1,3,2,4','mutated recommendation input')
local slot=duplicate.slot;duplicate.slot='Chest'
assert(ids(a:ComposeStarredItems(list,'tracker'))=='3,1,2,5,4','equal level/name/slot ID tie changed')
duplicate.slot=slot
-- Equip requirement ordering is independent of practical acquisition minima.
a.EquipmentEligibility={[1]={0,5},[2]={0,5}}
assert(ids(a:ComposeStarredItems(list,'tracker'))=='1,2,3,5,4')
a.EquipmentEligibility=nil

assert(ids(a:FilterEquipmentSlots(a:ComposeStarredItems({other},'tracker'),'rings'))=='2')
assert(ids(a:ComposeStarredItems({other},'tracker'))=='3,1,2,5','future wishlist missing')
a.db.hidden[exact.id]=true;a.db.status[prefix.id]='skipped';owned=2
assert(ids(a:ComposeStarredItems({other},'tracker'))=='5','resurrected hide/skip/owned')
assert(ids(a:ComposeStarredItems({exact},'hidden'))=='1')
assert(ids(a:ComposeStarredItems({prefix,duplicate},'completed'))=='3,2')
a.db.status[prefix.id]='acquired';assert(a:GetSearchItemState(prefix)=='Acquired')
assert(a:GetSearchItemState(exact)=='Hidden' and a:GetSearchItemState(duplicate)=='Equipped')
C_Item={GetItemCount=function(id)return id==5 and 1 or 0 end}
assert(a:GetSearchItemState(other)=='Owned in bags (not marked acquired)')
C_Item=nil
local ok,focused=a:SelectSearchItem(1)
assert(ok and focused.itemID==1 and a.focusedSearchItem.itemID==1)
assert(a.db.overlay.slotFilter==nil and a.db.status[exact.id]==nil,'focus modified preferences/progress')
assert(not a:SelectSearchItem(6) and not a:SelectSearchItem(7) and not a:SelectSearchItem(8) and not a:SelectSearchItem(9) and not a:SelectSearchItem(999))
a.db.hidden={};a.db.status={};owned=0
assert(a:SetItemStarred(1,false) and not a:IsItemStarred(1))
local saved=a.db
local reload={classToken='MAGE',level=25,db=saved,ItemCatalog=a.ItemCatalog,EquipmentByClass=a.EquipmentByClass}
assert(loadfile(root..'/GuideState.lua'))('GetGear',reload)
assert(reload:IsItemStarred(2) and reload:IsItemStarred(3))
reload.db={starredItems={}};assert(not reload:IsItemStarred(2));reload.db=saved;assert(reload:IsItemStarred(2))
assert(comparisons==0,'wishlist changed stat scoring')
-- Actual catalogue, all classes/factions. Search never queries acquisition routes.
local actual={level=25,db={status={},hidden={},overlay={},starredItems={}}}
for line in io.lines(root..'/GetGear.toc') do
 if line:match('%.lua$') and line~='UI.lua' and line~='Core.lua' and line~='AltInventory.lua' then
  assert(loadfile(root..'/'..line))('GetGear',actual)
 end
end
local calls=0;local hasSource=actual.HasEligibleAcquisitionSource
actual.HasEligibleAcquisitionSource=function(...)calls=calls+1;return hasSource(...)end
for classToken,gearList in pairs(actual.EquipmentByClass) do
 actual.classToken=classToken
 for _,factionName in ipairs({'Alliance','Horde'}) do
  UnitFactionGroup=function()return factionName end
  local future
  for _,r in ipairs(gearList) do
   if r.targetLevel>=40 and not actual:GetSearchRestriction(actual:GetSearchRecord(r.itemID),false) then future=r;break end
  end
  assert(future)
  local found=false
  for _,r in ipairs(actual:SearchEquipment(future.name,12))do if r.itemID==future.itemID then found=true;assert(not r.restriction)end end
  assert(found,'missing future name for '..classToken..factionName)
 end
end
assert(calls==0,'real catalogue autocomplete source work')
print('PASS indexed search ranks/case/partial/duplicates/metadata/restrictions; future focus; character stars, ordering, views, hide/skip/acquired/equipped; 3500 rapid queries; all nine classes and both factions')
