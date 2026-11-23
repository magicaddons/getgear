-- Real Forever C_Traits group path and real recommendation/stat pipeline.
local root=arg[1] or '.';local a={}
for f in assert(io.open(root..'/GetGear.toc')):read('*a'):gmatch('[^\r\n]+') do
    if f:match('%.lua$') and f~='Core.lua' and f~='UI.lua' and f~='AltInventory.lua' then assert(loadfile(root..'/'..f))('GetGear',a) end
end
local trees={
 WARRIOR={'Arms','Fury','Protection'},PALADIN={'Holy','Protection','Retribution'},
 HUNTER={'Beast Mastery','Marksmanship','Survival'},ROGUE={'Assassination','Combat','Subtlety'},
 PRIEST={'Discipline','Holy','Shadow'},SHAMAN={'Elemental','Enhancement','Restoration'},
 MAGE={'Arcane','Fire','Frost'},WARLOCK={'Affliction','Demonology','Destruction'},
 DRUID={'Balance','Feral Combat','Restoration'},
}
local points,invalid,groups,broken={6,0,0},nil,nil,nil
C_ClassTalents={GetActiveConfigID=function()return 111 end}
C_Traits={
 GetConfigInfo=function(id)assert(id==111);return {treeIDs={100}} end,
 GetGroupDisplayInfoByTreeID=function(id)
  assert(id==100);if groups then return groups end
  local out={};for i,name in ipairs(trees[a.classToken])do out[i]={groupID=i,displayName=name..' (Talents)'}end
  return out
 end,
 GetGroupCurrencyInfo=function(id,ids)
  assert(id==111 and #ids==3)
  if broken then error('unavailable')end
  local out={};for i,n in ipairs(points)do
   out[i]={traitNodeGroupID=i,currencyInfos={{traitCurrencyID=1,spent=invalid or n,stagedSpent=50,pendingRanks=50}}}
  end
  return out
 end,
}
local statData,inventory={},{}
C_Item={GetItemStats=function(link)return statData[link]end,GetItemInventoryTypeByID=function()return 5 end}
GetInventoryItemLink=function(_,slot)return inventory[slot]end
GetInventoryItemID=function(_,slot)return inventory[slot]and tonumber(inventory[slot]:match('item:(%d+)'))end
local requests=0;a.RequestItemDataOnce=function()requests=requests+1 end
local function reset()
 a.level=15;a.db={status={keep='skipped'},hidden={keep=true},overlay={filterObsolete=false,hideGreenBoEWorldDrops=false},
  statPriorities={mode='balanced',priority='ITEM_MOD_SPIRIT_SHORT',weights={ITEM_MOD_INTELLECT_SHORT=7}}}
end
local count=0
for class,names in pairs(trees)do for _,side in ipairs({'Alliance','Horde'})do
 reset();a.classToken=class;UnitFactionGroup=function()return side end
 for index,name in ipairs(names)do
  points={0,0,0};points[index]=6
  assert(a:RefreshTalentAwareness()==name,class..' '..name)
  assert(a:GetTalentOrientation() and a.talentInvestmentState=='focused')
  local g={itemID=990001,id='fixture',name='Net benefit',slot='Ring',armorType='Jewelry',targetLevel=15}
  local key=(class=='WARRIOR' or class=='ROGUE' or class=='HUNTER')and'ITEM_MOD_AGILITY_SHORT'or'ITEM_MOD_INTELLECT_SHORT'
  inventory={[11]='item:990000',[12]='item:990000'}
  statData={['item:990000']={[key]=10,ITEM_MOD_STAMINA_SHORT=10},['item:990001']={[key]=11,ITEM_MOD_STAMINA_SHORT=1}}
  a.Gear={g}
  assert(not a:ShouldShowOverlayStatChanges(g),'a utility/primary gain cannot ignore a larger stamina loss')
  statData['item:990001']={[key]=15,ITEM_MOD_STAMINA_SHORT=15}
  assert(a:ShouldShowOverlayStatChanges(g),'real gain remains visible')
  a.db.statPriorities.mode='priority';a.db.statPriorities.priority=key
  assert(a:GetStatWeight(key,g)==10,'Priority must use explicit class-wide preferences')
  a.db.statPriorities.mode='custom';a.db.statPriorities.weights={[key]=7}
  assert(a:GetStatWeight(key,g)==7,'Advanced must never use inferred role multipliers')
  a.db.statPriorities.mode='balanced';count=count+1
 end
 for _,distribution in ipairs({{0,0,0},{1,0,0},{2,0,0},{4,3,0},{10,6,0},{3,3,3}})do
  points=distribution;assert(a:RefreshTalentAwareness()==nil,'ambiguous/early must fall back')
 end
 points={6,0,0};invalid=-1;assert(a:RefreshTalentAwareness()==nil);invalid=0/0;assert(a:RefreshTalentAwareness()==nil)
 invalid=math.huge;assert(a:RefreshTalentAwareness()==nil);invalid=nil
 broken=true;assert(a:RefreshTalentAwareness()==nil);broken=nil
 groups={{groupID=1,displayName=names[1]},{groupID=1,displayName=names[2]},{groupID=3,displayName=names[3]}}
 assert(a:RefreshTalentAwareness()==nil,'duplicate IDs fail open')
 groups={{groupID=1,displayName='Unrecognized/localized'},{groupID=2,displayName=names[2]},{groupID=3,displayName=names[3]}}
 assert(a:RefreshTalentAwareness()==nil,'do not guess tree order');groups=nil
 assert(a.db.status.keep=='skipped' and a.db.hidden.keep and select(2,next(a.db.statPriorities.weights))==7)
end end
-- Exact current published tooltip:78 armor,+5Int,+3 universal spell power,
-- no Stamina or Agility. Equipped baseline below is reconstructed only from
-- the user's reported deltas; its real item ID was not supplied.
reset();a.classToken='DRUID';points={0,5,0};assert(a:RefreshTalentAwareness()=='Feral Combat')
local tunic=assert(a.ItemCatalog[20575]);assert(tunic.name=='Black Whelp Tunic' and tunic.availableLevel==15 and tunic.slot=='Chest')
assert(tunic.recipePatternItemID==20576 and tunic.recipeSpellID==24940 and #tunic.reagents==4)
statData={['item:20575']={RESISTANCE0_NAME=78,ITEM_MOD_INTELLECT_SHORT=5,ITEM_MOD_SPELL_POWER_SHORT=3},
 ['item:990000']={RESISTANCE0_NAME=73,ITEM_MOD_STAMINA_SHORT=3,ITEM_MOD_AGILITY_SHORT=1}}
inventory={[5]='item:990000'}
local expected={ITEM_MOD_INTELLECT_SHORT=5,ITEM_MOD_STAMINA_SHORT=-3,SPELL_DAMAGE_TOTAL=3,SPELL_HEALING_TOTAL=3,ITEM_MOD_AGILITY_SHORT=-1,RESISTANCE0_NAME=5}
local comparison=a:GetGearComparison(tunic,true)
assert(#comparison.groups==1 and #comparison.groups[1].rows==6)
for _,row in ipairs(comparison.groups[1].rows)do assert(expected[row.key]==row.delta,'exact reported delta mismatch');expected[row.key]=nil end
assert(next(expected)==nil)
assert(not a:ShouldShowOverlayStatChanges(tunic),'reported Feral tradeoff must hide')
assert(math.abs(a:GetWeightedUpgradeEvaluation(tunic).score-(-3.7))<0.0001)
assert(a:ShouldDisplayGear(tunic,'DRUID','available'),'talent score must not erase guide access')
local objective=setmetatable({id='item_20575',targetLevel=15},{__index=tunic})
a.Gear={objective}
assert(#a:GetItems('available')==1 and #a:GetAggregateMaterials('tracked')==0,
 'Feral filter affects tracked materials while retaining detailed guide access')
assert(#a:GetAggregateMaterials('all')==4,'all-materials browsing retains the craft')

points={5,0,0};a:RefreshTalentAwareness();assert(a:ShouldShowOverlayStatChanges(tunic),'Balance should value the full caster gains')
assert(#a:GetAggregateMaterials('tracked')==4,'talent changes update tracked materials without stale results')
points={0,0,5};a:RefreshTalentAwareness();assert(a:ShouldShowOverlayStatChanges(tunic),'Restoration should value the healing gains')
points={0,5,0};a:RefreshTalentAwareness()
a.db.statPriorities.mode='priority';a.db.statPriorities.priority='ITEM_MOD_INTELLECT_SHORT'
assert(a:ShouldShowOverlayStatChanges(tunic))
a.db.statPriorities.mode='custom';a.db.statPriorities.weights={ITEM_MOD_INTELLECT_SHORT=7}
assert(a:ShouldShowOverlayStatChanges(tunic))
a.db.statPriorities.mode='balanced';a.db.overlay.showAllValidGear=true;assert(a:ShouldShowOverlayStatChanges(tunic))
a.db.overlay.showAllValidGear=false;a.db.overlay.hideWithoutPositiveStats=false;assert(a:ShouldShowOverlayStatChanges(tunic))
a.db.statPriorities.mode='custom';a.db.statPriorities.weights={ITEM_MOD_INTELLECT_SHORT=0}
assert(not a:ShouldShowOverlayStatChanges(tunic),'turning off the Balanced display filter must not bypass explicit Advanced weights')
a.db.statPriorities.mode='balanced'

a.db.overlay.hideWithoutPositiveStats=true
-- A pure utility gain alone is not the default reason to replace Feral gear.
statData['item:990000']={RESISTANCE0_NAME=78};assert(not a:ShouldShowOverlayStatChanges(tunic))
statData['item:20575'].ITEM_MOD_AGILITY_SHORT=4;assert(a:ShouldShowOverlayStatChanges(tunic),'hybrid gear with a net physical benefit stays')
statData['item:20575']=nil;assert(a:ShouldShowOverlayStatChanges(tunic),'unknown is not a rejection')
-- Explicit Mage priorities/custom school weights lift only inferred school
-- preferences, preserving the existing Balanced pure-school safeguard.
a.classToken='MAGE';points={0,5,0};assert(a:RefreshTalentAwareness()=='Fire')
local offschool={itemID=990050,name='Frost-only ring',targetLevel=15,slot='Ring',armorType='Jewelry',schoolOnly='Frost'}
assert(not a:ShouldDisplayGear(offschool,'MAGE','available'))
a.db.statPriorities.mode='priority';assert(a:ShouldDisplayGear(offschool,'MAGE','available'))
a.db.statPriorities.mode='custom';assert(a:ShouldDisplayGear(offschool,'MAGE','available'))
a.db.statPriorities.mode='balanced'
C_Traits=nil;assert(a:RefreshTalentAwareness()==nil and not a:GetTalentOrientation(),'lost API clears stale orientation')
assert(requests==0,'no bulk item-data requests')
-- Existing talent events must refresh the real detector and recommendation UI.
local events;CreateFrame=function()events={registered={},RegisterEvent=function(self,name)self.registered[name]=true end,SetScript=function(self,k,v)self[k]=v end};return events end
SlashCmdList={};assert(loadfile(root..'/Core.lua'))('GetGear',a)
local refreshed=0;a.RefreshAll=function()refreshed=refreshed+1 end
a.dominantTalentTree='Feral Combat';a.talentOrientation='feral'
events.OnEvent(nil,'TRAIT_CONFIG_UPDATED');assert(not a:GetTalentOrientation() and refreshed==1)
assert(events.registered.ZONE_CHANGED and events.registered.ZONE_CHANGED_NEW_AREA)
events.OnEvent(nil,'ZONE_CHANGED');events.OnEvent(nil,'ZONE_CHANGED_NEW_AREA')
assert(refreshed==2,'unchanged location should not rebuild source convenience twice')
local map=1
C_Map={GetBestMapForUnit=function()return map end,GetMapInfo=function()return {name='Test zone'}end}
events.OnEvent(nil,'ZONE_CHANGED');assert(refreshed==3)
events.OnEvent(nil,'ZONE_CHANGED_NEW_AREA');assert(refreshed==3)
map=2;events.OnEvent(nil,'ZONE_CHANGED');assert(refreshed==4,'real map transitions must refresh source convenience')
print('PASS talent recommendations: '..count..' tree/faction cases; nine classes/three modes, ambiguity/invalid APIs, exact reported tunic deltas, utility, guide choice, events and saved preferences')
