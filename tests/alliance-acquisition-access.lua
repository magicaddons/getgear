-- Alliance acquisition policy across routes, recommendation surfaces and reloads.
local root=arg[1] or '.'
local function loadAddon()
 local a={}
 for line in io.lines(root..'/GetGear.toc') do
  if line:match('%.lua$') and line~='Core.lua' and line~='UI.lua' and line~='AltInventory.lua' then
   assert(loadfile(root..'/'..line))('GetGear',a)
  end
 end
 return a
end
local class='WARRIOR'
local classes={PRIEST=5,MAGE=8,WARLOCK=9,DRUID=11,ROGUE=4,HUNTER=3,SHAMAN=7,WARRIOR=1,PALADIN=2}
UnitFactionGroup=function()return 'Alliance' end
UnitClass=function()return class,class,classes[class] end
UnitRace=function()return 'Human','Human',1 end
UnitLevel=function()return 20 end
GetInventoryItemID=function()return nil end
GetInventoryItemLink=function()return nil end
local a=loadAddon()
a.db={status={},hidden={},starredItems={},overlay={showAllValidGear=true,filterObsolete=false},detail={}}
a.level=20
a.IsGearEquipped=function()return false end
a.GetObsoleteGearReason=function()return nil end
a.ShouldRecommendByStatPriority=function()return true end
local m=a.AcquisitionNavigationData
m.sources['fixture:capital']={name='Unclassified seller',locations={{zone='Orgrimmar'}}}
m.sources['fixture:shared']={name='Shared seller',locations={{zone='Orgrimmar'},{zone='The Barrens'}}}
m.sources['fixture:neutral']={name='Neutral seller',locations={{zone='The Barrens'}}}
m.sources['fixture:horde']={name='Horde seller',serviceSide=2,locations={{zone='Silverpine Forest'}}}
m.quests[990001]={questID=990001,name='Horde quest',side=2,starts={},ends={}}
m.quests[990002]={questID=990002,name='Capital quest',side=3,starts={'fixture:capital'},ends={}}
m.quests[990003]={questID=990003,name='Shared quest',side=3,starts={'fixture:neutral'},ends={}}
local function item(id,routes,zone)
 local g={itemID=id,id='item_'..id,name='Access fixture '..id,slot='Ring',armorType='Jewelry',targetLevel=20,availableLevel=20,zone=zone}
 g.acquisitionPlan=routes and {routes=routes} or nil
 return g
end
local blocked={
 item(990010,{{kind='dungeon',dungeon='Ragefire Chasm'}}),
 item(990011,{{kind='vendor',source='fixture:capital'}}),
 item(990012,{{kind='trainer',source='fixture:horde'}}),
 item(990013,{{kind='quest',questID=990001}}),
 item(990014,{{kind='quest',questID=990002}}),
 item(990015,{{kind='reputation',offer={reqfaction=729,standing=8}}}),
 item(990016,{{kind='vendor',offer={reqfaction=510,standing=7},source='fixture:neutral'}}),
 item(990017,{{kind='legacy',location={zone='Undercity'}}}),
 item(990018,nil,'Ragefire Chasm (Classic reference)'),
 item(990019,{{kind='recipe_vendor',source='fixture:capital'}}),
}
local valid={
 item(990020,{{kind='dungeon',dungeon='Ragefire Chasm'},{kind='vendor',source='fixture:neutral'}}),
 item(990021,{{kind='dungeon',dungeon='Shadowfang Keep'}}),
 item(990022,{{kind='dungeon',dungeon='Wailing Caverns'}}),
 item(990023,{{kind='dungeon',dungeon='Ruins of Lordaeron'}}),
 item(990024,{{kind='vendor',source='fixture:shared'}}),
 item(990025,{{kind='quest',questID=990003}}),
 item(990026,{{kind='named_drop',location={zone='Durotar'}}}),
 item(990027,{{kind='world_drop'}}),
 item(990028,{}), -- unresolved remains uncertain, never inferred faction-exclusive
}
local function contains(list,id)for _,g in ipairs(list)do if g.itemID==id then return true end end return false end
for token in pairs(classes) do
 class=token;a.classToken=class;a.Gear={}
 a.EquipmentByClass[class]={}
 for _,g in ipairs(blocked)do a.Gear[#a.Gear+1]=g;a.db.starredItems[g.itemID]=true end
 for _,g in ipairs(valid)do a.Gear[#a.Gear+1]=g end
 a.EquipmentByClass[class]=a.Gear;a.itemSearchIndex=nil
 for level=1,60 do
  a.level=level
  for _,g in ipairs(blocked)do
   assert(not a:HasEligibleAcquisitionSource(g),'blocked source '..g.itemID..' '..class)
   for _,mode in ipairs({'available','upcoming','earlier','tracker','preview','materials-all'})do
    assert(not a:ShouldDisplayGear(g,class,mode),'visibility bypass '..mode)
   end
  end
  for _,g in ipairs(valid)do assert(a:HasEligibleAcquisitionSource(g),'valid route rejected '..g.itemID)end
 end
 a.level=20
 for _,mode in ipairs({'available','upcoming','earlier','tracker'})do
  local list=a:ComposeStarredItems(a:GetItems(mode),mode,nil,true)
  local reused={};for _,g in ipairs(blocked)do reused[g.itemID]=g end
  local cached=a:ComposeStarredItems(blocked,mode,reused,true)
  for _,g in ipairs(blocked)do
   assert(not contains(list,g.itemID),'restored star bypass '..mode)
   assert(not contains(cached,g.itemID),'cached presentation bypass '..mode)
  end
  for _,slot in ipairs({'all','rings','head'})do
   local filtered=a:FilterEquipmentSlots(list,slot)
   for _,g in ipairs(blocked)do assert(not contains(filtered,g.itemID))end
  end
 end
 for _,g in ipairs(blocked)do assert(not contains(a:GetPreviewRecommendations(class),g.itemID))end
 a:RefreshAll() -- no persistent acquisition-result cache
 assert(not a:HasEligibleAcquisitionSource(blocked[1]))
end
class='WARRIOR';a.classToken=class
local mixed=valid[1]
assert(#a:GetEligibleAcquisitionRoutes(mixed)==1)
assert(a:GetAcquisitionMapTarget(mixed).source=='fixture:neutral')
for _,g in ipairs({mixed,valid[5]})do
 local summary=a:GetAcquisitionCompactSummary(g) or ''
 assert(not summary:find('Ragefire Chasm',1,true) and not summary:find('Orgrimmar',1,true))
 for _,dest in ipairs(a:GetAcquisitionNavigationChoices(g))do
  assert(a:IsAcquisitionLocationEligible(dest) and dest.zone~='Orgrimmar')
 end
end
assert(not a:GetAcquisitionMapTarget(blocked[1]))
local legacyTrade=item(990039,nil,'Ragefire Chasm');legacyTrade.bindingStatus='boe'
assert(a:HasEligibleAcquisitionSource(legacyTrade))
assert((a:GetFactionAcquisitionDescription(legacyTrade)or''):find('traded',1,true))
assert((a:GetAcquisitionCompactSummary(legacyTrade)or''):find('trade/Auction House',1,true))
assert(not a:GetAcquisitionMapTarget(legacyTrade))
-- Independent access requires positive evidence, not merely a blocked route.
local craft=item(990040,{{kind='recipe_vendor',source='fixture:capital'}});craft.profession='Tailoring'
assert(not a:HasEligibleAcquisitionSource(craft))
a.GetRecipeKnowledge=function()return true end;assert(a:HasEligibleAcquisitionSource(craft));a.GetRecipeKnowledge=nil
craft.bindingStatus='boe';assert(a:HasEligibleAcquisitionSource(craft))
craft.factionEligibility={side=2};assert(not a:HasEligibleAcquisitionSource(craft),'trade cannot bypass item use')
-- Recipe drop evidence stays raw, but directions never offer the capital source.
local raw={documentedDrops={
 {name='Capital boss',npcID=990010,bookItemID=990050,dungeons={'Ragefire Chasm'}},
 {name='Shared boss',npcID=990011,bookItemID=990050,dungeons={'Ragefire Chasm','Shadowfang Keep'}},
}}
local drops=a:GetAccessibleRecipeDrops(raw)
assert(#drops==1 and #drops[1].dungeons==1 and drops[1].dungeons[1]=='Shadowfang Keep')
assert(#raw.documentedDrops==2 and #raw.documentedDrops[2].dungeons==2,'raw research mutated')
assert(#a:GetAccessibleRecipeDrops({documentedDrops={{name='Unresolved drop',dungeons={}}}})==1,'unknown geography became an exclusion')
-- The same rule handles an independently recorded instance inside a capital,
-- and keeps a dungeon with an independently accessible entrance.
m.instanceEntrances['Fixture dungeon']={entrances={{zone='Orgrimmar'}}}
local instance=item(990041,{{kind='dungeon',dungeon='Fixture dungeon'}})
assert(not a:HasEligibleAcquisitionSource(instance))
m.instanceEntrances['Fixture dungeon'].entrances[2]={zone='Silverpine Forest'}
assert(a:HasEligibleAcquisitionSource(instance))
local gate=item(990042,{{kind='dungeon',dungeon='Ragefire Chasm'},{kind='quest',questID=990003}})
m.quests[990003].reqlevel=25
assert(a:GetRecommendationRecord(gate).targetLevel==25 and gate.targetLevel==20)
-- A rendered-model proof is invalidated by a general refresh, including when
-- the windows are hidden. Caller-supplied cached stars alone are never a proof.
local cached=item(990043,{{kind='vendor',source='fixture:neutral'}})
a.ItemCatalog[cached.itemID]=cached;a.EquipmentByClass[class][#a.EquipmentByClass[class]+1]=cached
a.itemSearchIndex=nil;a.db.starredItems[cached.itemID]=true
assert(contains(a:ComposeStarredItems({cached},'tracker',nil,true),cached.itemID))
cached.acquisitionPlan.routes[1]={kind='dungeon',dungeon='Ragefire Chasm'}
a:RefreshAll()
assert(not contains(a:ComposeStarredItems({cached},'tracker',{[cached.itemID]=cached},true),cached.itemID))
-- Policy changes and next-refresh route updates cannot use a stale decision.
a:WithRecommendationSnapshot(function()assert(not a:HasEligibleAcquisitionSource(blocked[1]))end)
blocked[1].acquisitionPlan.routes[2]={kind='vendor',source='fixture:neutral'}
a:WithRecommendationSnapshot(function()assert(a:HasEligibleAcquisitionSource(blocked[1]))end)
blocked[1].acquisitionPlan.routes[2]=nil
-- Actual catalogue RFC records, all class lists, plus saved stars restored on a fresh runtime.
local fresh=loadAddon();fresh.db=a.db;fresh.classToken='MAGE';fresh.level=20
local count=0
for id,plan in pairs(fresh.AcquisitionNavigationData.items)do
 for _,route in ipairs(plan.routes or {})do if route.dungeon=='Ragefire Chasm' then
  count=count+1
  local gear=assert(fresh.ItemCatalog[tonumber(id)])
  for _,eligible in ipairs(fresh:GetEligibleAcquisitionRoutes(gear))do assert(eligible.dungeon~='Ragefire Chasm')end
  if #(plan.routes or {})==1 and not fresh:GetIndependentAcquisitionAccess(gear) then
   assert(not fresh:HasEligibleAcquisitionSource(gear),'actual RFC-only '..id)
   fresh.db.starredItems[gear.itemID]=true
   for token in pairs(classes)do
    class=token;fresh.classToken=token
    assert(not contains(fresh:GetPreviewRecommendations(token),gear.itemID))
    assert(not contains(fresh:ComposeStarredItems({},'tracker',nil,true),gear.itemID))
   end
  end
 end end
end
assert(count>5,'actual dungeon evidence not exercised')
print('PASS Alliance acquisition: nine classes/60 levels; '..count..' RFC records, capital services/quests/reputation, alternatives/shared dungeons, stars/slots/refresh/reload/map selection; no invented sources')
