-- Shared eligibility: 16 faction-valid original class combinations, all levels,
-- all catalogue entries, player choices, source alternatives and all surfaces.
local root=arg[1]or'.';local a={}
for file in assert(io.open(root..'/GetGear.toc')):read('*a'):gmatch('[^\r\n]+')do
 if file:match('%.lua$')and file~='Core.lua'and file~='UI.lua'and file~='AltInventory.lua'then assert(loadfile(root..'/'..file))('GetGear',a)end
end
local side,class,level='Alliance','PRIEST',28
local ids={WARRIOR=1,PALADIN=2,HUNTER=3,ROGUE=4,PRIEST=5,SHAMAN=7,MAGE=8,WARLOCK=9,DRUID=11}
UnitFactionGroup=function()return side end;UnitLevel=function()return level end
UnitClass=function()return class,class,ids[class]end
UnitRace=function()
 local race=side=='Alliance'and(class=='DRUID'and{'NightElf',4}or class=='HUNTER'and{'Dwarf',3}or{'Human',1})
  or(class=='DRUID'and{'Tauren',6}or(class=='MAGE'or class=='PRIEST')and{'Scourge',5}or{'Orc',2})
 return race[1],race[1],race[2]
end
local requests=0
C_Item={RequestLoadItemDataByID=function()requests=requests+1 end,GetItemStats=function()return nil end}
GetInventoryItemLink=function()return nil end;GetInventoryItemID=function()return nil end
C_QuestLog={IsOnQuest=function()return false end,IsQuestFlaggedCompleted=function()return false end}
a.GetObsoleteGearReason=function()return nil end;a.GetBagPlanningObjectives=function()return {}end
a.db={status={},hidden={},overlay={filterObsolete=false,hideGreenBoEWorldDrops=false,showAllValidGear=true},detail={}}
local combinations,entries,surfaces=0,0,0
for _,faction in ipairs({'Alliance','Horde'})do
 side=faction
 for token in pairs(ids)do
  if not(token=='PALADIN'and side=='Horde'or token=='SHAMAN'and side=='Alliance')then
   class=token;a:SelectCurrentGuide();combinations=combinations+1
   for _,g in ipairs(a.Gear)do
    entries=entries+1
    local usable=a:IsFactionUseEligible(g)
    assert(usable or not a:HasEligibleAcquisitionSource(g),'no source/trade bypasses an item-use restriction')
    assert(usable or #a:GetEligibleAcquisitionRoutes(g)==0)
    if not usable then
     assert(not a:ShouldDisplayGear(g,class,'available')and not a:ShouldDisplayGear(g,class,'preview'))
    end
   end
   for _,g in ipairs(a:GetPreviewRecommendations(class))do
    assert(a:HasEligibleAcquisitionSource(g,a:GetPreviewAcquisitionContext(class)),'preview must use faction/selected-class access')
   end
   for _,n in ipairs({1,14,28,40,60})do
    level=n;a.level=n
    for _,mode in ipairs({'available','upcoming','tracker','earlier'})do
     for _,g in ipairs(a:GetItems(mode))do
      assert(a:HasEligibleAcquisitionSource(g),mode..' faction-ineligible '..g.itemID..' '..class..side)
     end
     surfaces=surfaces+1
    end
   end
  end
 end
end
assert(combinations==16 and entries>60000)
-- Every cloth-girdle level variant, both directions, every class that can equip
-- cloth. The full catalogue—not item-name logic—selects the appropriate version.
local pairsByLevel={{28,20164,20099},{38,20166,20098},{48,20165,20097},{58,20163,20047}}
for _,faction in ipairs({'Alliance','Horde'})do
 side=faction
 for token in pairs(ids)do if not(token=='PALADIN'and side=='Horde'or token=='SHAMAN'and side=='Alliance')then
  class=token;a:SelectCurrentGuide()
  for _,spec in ipairs(pairsByLevel)do
   level=spec[1];a.level=level
   local bad=side=='Alliance'and spec[2]or spec[3];local good=side=='Alliance'and spec[3]or spec[2]
   assert(not a:HasEligibleAcquisitionSource(a.ItemCatalog[bad]))
   assert(a:HasEligibleAcquisitionSource(a.ItemCatalog[good]))
   assert(#a:GetAcquisitionNavigationChoices(a.ItemCatalog[bad])==0 and not a:GetAcquisitionMapTarget(a.ItemCatalog[bad]))
   for _,mode in ipairs({'balanced','priority','custom'})do
    a.db.statPriorities={mode=mode,priority='ITEM_MOD_INTELLECT_SHORT',weights={ITEM_MOD_INTELLECT_SHORT=1000}}
    local found=false
    for _,g in ipairs(a:GetItems('available'))do assert(g.itemID~=bad);if g.itemID==good then found=true end end
    assert(found,'valid counterpart lost '..good..class..side..mode)
   end
  end
 end end
end
-- Source-specific restrictions, reputation/PvP/quest/vendor/recipe types and
-- multiple methods; typed item requirements always take precedence over trade.
side='Alliance';class='MAGE';a.classToken=class;a.level=28
local model=a.AcquisitionNavigationData;local overlay=a.FactionEligibilityData
model.sources['fixture:H']={name='Horde seller',serviceSide=2,locations={{zone='The Barrens',x=50,y=50,verification='published-reference'}}}
model.sources['fixture:A']={name='Alliance seller',serviceSide=1,locations={{zone='Elwynn Forest',x=50,y=50,verification='published-reference'}}}
local function fixture(id,routes,extra)
 local g={id='fixture_'..id,itemID=id,name='Faction fixture',targetLevel=28,slot='Ring',armorType='Jewelry',acquisitionPlan={routes=routes}}
 for k,v in pairs(extra or{})do g[k]=v end;return g
end
local blocked=fixture(990001,{{kind='vendor',source='fixture:H'}})
local alternative=fixture(990002,{{kind='vendor',source='fixture:H'},{kind='dungeon',dungeon='Shadowfang Keep'}})
assert(not a:HasEligibleAcquisitionSource(blocked)and a:HasEligibleAcquisitionSource(alternative))
assert(a:GetAcquisitionMapTarget(alternative).kind=='dungeon')
blocked.factionEligibility={acquisitionSide=2,binding='bop'};assert(not a:HasEligibleAcquisitionSource(blocked))
alternative.factionEligibility={acquisitionSide=2,binding='bop'}
assert(a:HasEligibleAcquisitionSource(alternative),'an explicit shared source overrides acquisition attribution, not an equip requirement')
local learned=fixture(990010,{{kind='recipe_vendor',source='fixture:H'}},{profession='Tailoring',factionEligibility={acquisitionSide=2,binding='bop'}})
a.GetRecipeKnowledge=function()return true end;assert(a:HasEligibleAcquisitionSource(learned),'a learned craft is independent of one faction-attributed source');a.GetRecipeKnowledge=nil
blocked.factionEligibility=nil
blocked.bindingStatus='boe';assert(a:HasEligibleAcquisitionSource(blocked),'verified finished trade is separate from the inaccessible seller')
assert(not a:GetAcquisitionMapTarget(blocked),'trade never exposes a forbidden seller pin')
assert(a:GetAcquisitionSummary(blocked):find('listings unknown',1,true),'compact summary must present the legitimate trade alternative')
local sharedAV=a.ItemCatalog[19312];assert(a:HasEligibleAcquisitionSource(sharedAV))
side='Horde';assert(a:HasEligibleAcquisitionSource(sharedAV),'dual AV reputation clauses do not make shared equipment exclusive');side='Alliance'
assert(a:GetFactionAcquisitionDescription(blocked):find('no current offer',1,true))
blocked.factionEligibility={side=2,binding='boe'};assert(not a:HasEligibleAcquisitionSource(blocked),'item requirement wins over trade')
blocked.factionEligibility={races={3},binding='boe'};assert(not a:HasEligibleAcquisitionSource(blocked),'race requirement wins over trade')
assert(a:HasEligibleAcquisitionSource(blocked,{faction='Alliance',classToken='MAGE'}),'unknown race remains uncertain')
blocked.factionEligibility=nil;blocked.bindingStatus=nil
local perOffer=fixture(990003,{{kind='vendor',source='fixture:A'}})
overlay.offers[990003]={['fixture:A']=2}
assert(a:HasEligibleAcquisitionSource(perOffer),'explicit shared model actor takes precedence over supplementary offer data')
model.sources['fixture:shared']={name='Shared merchant',locations={{zone='Arathi Highlands',verification='published-reference'}}}
perOffer.acquisitionPlan.routes={{kind='vendor',source='fixture:shared'}};overlay.offers[990003]={['fixture:shared']=2}
assert(not a:HasEligibleAcquisitionSource(perOffer),'a shared merchant can still have a faction-specific offer')
perOffer.acquisitionPlan.routes[1].offer={side=3};assert(a:HasEligibleAcquisitionSource(perOffer),'explicit shared offer is not replaced by supplementary data')
model.quests['990099']={name='Race quest',raceIDs={3},side=1,reqlevel=1,starts={},ends={}}
local q=fixture(990004,{{kind='quest',questID=990099}})
assert(not a:HasEligibleAcquisitionSource(q))
model.quests['990098']={name='Known neutral quest',reqlevel=1,starts={},ends={}}
overlay.quests[990098]=3
local sharedFallback=fixture(990012,{{kind='quest',questID=990098}},{factionEligibility={acquisitionSide=2,binding='bop'}})
assert(a:HasEligibleAcquisitionSource(sharedFallback),'supplementary explicit shared quest evidence must survive projection')

assert(a:HasEligibleAcquisitionSource(q,{faction='Alliance',classToken='MAGE'}),'unknown race cannot veto a quest')
local recipe=fixture(990005,{{kind='recipe_vendor',source='fixture:H',bookItemID=990006}},{profession='Tailoring',bindingStatus='boe',recipeSpellID=123})
assert(a:HasEligibleAcquisitionSource(recipe)and not a:GetAcquisitionMapTarget(recipe))
recipe.bindingStatus='bop';assert(not a:HasEligibleAcquisitionSource(recipe))
a.GetRecipeKnowledge=function()return true end;assert(a:HasEligibleAcquisitionSource(recipe),'already learned recipe does not need a new book');a.GetRecipeKnowledge=nil
local unknown=fixture(990007,{});assert(a:HasEligibleAcquisitionSource(unknown))
local sharedDrop=fixture(990008,{{kind='named_drop',source='fixture:shared'}})
assert(a:HasEligibleAcquisitionSource(sharedDrop),'service restrictions never turn a neutral world drop into a faction veto')
-- Normalization/material/history paths share the same hard rule even with
-- Show-all and deliberately unusual custom preferences.
local hard=fixture(990009,{{kind='vendor',source='fixture:A'}},{factionEligibility={side=2},reagents={{itemID=2589,name='Linen Cloth',amount=5}}})
a.Gear={hard};a.db.statPriorities={mode='custom',weights={ITEM_MOD_INTELLECT_SHORT=999}}
assert(#a:GetItems('tracker')==0 and #a:GetAggregateMaterials('all')==0 and #a:GetUndocumentedCrafts('all')==0 and #a:GetCombinedMaterialRows('all')==0)
a.db.status[hard.id]='acquired';assert(#a:GetItems('completed')==1,'history remains reviewable')
a.db.status[hard.id]=nil;a.db.hidden[hard.id]=true;assert(#a:GetItems('hidden')==1,'hidden progress is preserved')
local hardBag=fixture(990011,{}, {bagUpgrade=true,profession='Tailoring',factionEligibility={side=2},reagents={{itemID=2589,name='Linen Cloth',amount=5}}})
a.GetBagUpgradePlan=function()return hardBag end
assert(#a:GetCombinedMaterialRows('all')==0,'dynamic bag materials also respect hard eligibility')
blocked.factionEligibility={races={"bad"},binding='boe'};assert(a:HasEligibleAcquisitionSource(blocked),'malformed race requirements remain uncertain')
blocked.factionEligibility=nil;blocked.bindingStatus='boe'
C_Item.IsItemDataCachedByID=function()return false end
C_Item.GetItemInfo=function()error('must not query uncached binding data')end
assert(a:HasEligibleAcquisitionSource(blocked),'known BoE fallback does not load uncached item info')
C_Item.IsItemDataCachedByID=function()return true end
C_Item.GetItemInfo=function()return 'Current item',nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,1 end
assert(not a:HasEligibleAcquisitionSource(blocked),'cached current BoP overrides older BoE evidence')
assert(requests==0,'catalogue scans must never issue bulk item-cache requests')
print('PASS global faction eligibility: '..combinations..' valid class/faction combinations; '..entries..' class records; '..surfaces..' level/view cases; all girdle variants, modes, trade/craft, race, routes, preview, materials and history')
