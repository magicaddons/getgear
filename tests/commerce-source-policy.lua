local root=arg[1] or '.'
UnitFactionGroup=function()return 'Alliance' end
UnitClass=function()return 'Warrior','WARRIOR',1 end
UnitRace=function()return 'Human','Human',1 end
UnitLevel=function()return 25 end
local a={}
for file in io.lines(root..'/GetGear.toc') do
 if file:match('%.lua$') and file~='Core.lua' and file~='UI.lua' and file~='AltInventory.lua' then assert(loadfile(root..'/'..file))('GetGear',a) end
end
local m=a.AcquisitionNavigationData
local known=a.ItemCatalog[250574]
local routes=a:GetEligibleAcquisitionRoutes(known)
assert(#routes==1 and routes[1].source=='npc:256730','Shared commerce book must select ACA only')
assert(not a:GetAcquisitionSummary(known):find("Gor'mak",1,true))
assert(a:GetAcquisitionSummary(known):find('Stondry Darkhammer',1,true))
local choices=a:GetAcquisitionNavigationChoices(known)
assert(#choices>0)
for _,target in ipairs(choices) do
 assert(target.source~='npc:248197')
 if target.source=='npc:256730' then assert(target.zone=='Redridge Mountains' and not target.x and target.instructions:find('disagree',1,true)) end
end
-- Every current commerce route is evaluated, across professions; unknown service
-- metadata and explicit contradictions cannot open an Alliance service route.
local commerceCount=0
for id,plan in pairs(m.items) do
 local g=a.ItemCatalog[tonumber(id)]
 for _,r in ipairs(plan.routes or {}) do
  local commerce=a:AcquisitionRouteUsesCurrency(r,3402)
  if commerce then
   commerceCount=commerceCount+1
   local allowed=a:GetAcquisitionServiceDecision(g,r,{faction='Alliance'})
   r=a:ProjectAcquisitionRoute(g,r)
   local book=r.bookItemID or g and g.recipePatternItemID
   local published=a.CommercePolicyData.offers[tostring(book)]
   assert(allowed==(published~=nil and published.source==r.source),'Exact guide offer join required')
  end
 end
end
assert(commerceCount>300)
m.sources['fixture:neutral']={name='Verified neutral Ratchet vendor',serviceSide=3,locations={{zone='The Barrens'}}}
m.sources['fixture:unknown']={name='Unverified seller',locations={{zone='The Barrens'}}}
m.sources['fixture:contradictory']={name='Conflicting seller',serviceSide=2,locations={{zone='Redridge Mountains'}}}
local merchant={kind='recipe_vendor',source='npc:248197',bookItemID=251426,offer={cost={0,{{3402,90}},{}}}}
local contradictory={kind='vendor',source='fixture:contradictory',serviceSide=1}
local neutral={kind='vendor',source='fixture:neutral'}
local unknown={kind='recipe_vendor',source='fixture:unknown',bookItemID=251426,offer={cost={0,{{3402,90}},{}}}}
local slots,seenSlots={},{}
for _,gear in pairs(a.ItemCatalog) do if not seenSlots[gear.slot] then seenSlots[gear.slot]=true;slots[#slots+1]=gear.slot end end
table.sort(slots)
local cases=0
for _,class in ipairs({'WARRIOR','PALADIN','HUNTER','ROGUE','PRIEST','SHAMAN','MAGE','WARLOCK','DRUID'}) do
 for level=1,60 do
  for _,slot in ipairs(slots) do
   local context={faction='Alliance',classToken=class,level=level}
   local gear={itemID=990099,slot=slot,profession='Blacksmithing',recipePatternItemID=251426}
   assert(not a:IsAcquisitionRouteAccessible(gear,merchant,context))
   assert(not a:IsAcquisitionRouteAccessible(gear,contradictory,context))
   assert(not a:IsAcquisitionRouteAccessible(gear,unknown,context))
   assert(not a:IsAcquisitionRouteAccessible(gear,{kind='recipe_vendor',cost=90,currency="Merchant's Favor",location={zone='The Barrens',npcName="Gor'mak"}},context),'legacy string currency cannot bypass commerce access')
   assert(a:IsAcquisitionRouteAccessible(gear,neutral,context))
   assert(a:GetAcquisitionRoutePracticality(gear,neutral,context)=='unknown' or a:GetAcquisitionRoutePracticality(gear,neutral,context)=='practical')
   assert(a:GetAcquisitionRoutePracticality(gear,{kind='named_drop',location={zone='The Barrens'}},context)=='restricted-territory')
   assert(a:GetAcquisitionRoutePracticality(gear,{kind='named_drop',location={zone='Durotar'}},context)=='restricted-territory')
   assert(a:GetAcquisitionRoutePracticality(gear,{kind='dungeon',dungeon='Wailing Caverns'},context)=='practical')
   assert(a:GetAcquisitionRoutePracticality(gear,{kind='quest',questID=999999},context)=='practical')
   assert(not a:IsAcquisitionRouteAccessible(gear,{kind='dungeon',dungeon='Ragefire Chasm'},context))
   gear.acquisitionPlan={routes={merchant,neutral}}
   assert(#a:GetEligibleAcquisitionRoutes(gear,context)==1)
   cases=cases+1
  end
 end
end
-- A misleading explicit trainer label must not bypass a rejected teacher.
local blocked={itemID=990098,name='Unknown recipe',profession='Blacksmithing',recipeLearnMethod='trainer',
 acquisitionPlan={routes={{kind='trainer',source='fixture:contradictory',spellID=99999,verification='published-reference'}}}}
-- Recipe summary uses the same plan lookup as production model records.
m.items['990098']=blocked.acquisitionPlan
assert(not a:GetCompactRecipeSummary(blocked):find('Blacksmithing trainer',1,true))
assert(a:GetCompactRecipeSummary(blocked):find('unverified',1,true))
for _,id in ipairs({250519,250523}) do
 local g=a.ItemCatalog[id]
 assert(g.recipePatternItemID and g.recipeBookEvidence,'missing book must be resolved through its exact current spell/output proof')
 local choices=a:GetAcquisitionNavigationChoices(g)
 assert(#choices==1 and choices[1].source=='npc:256730' and not choices[1].x,'legacy route must use the same source identity and disputed precision policy')
 assert(not a:GetAcquisitionDirections(g):find('(10.4, 74.7)',1,true),'stale inline coordinates bypassed the source projection')
end
assert(a:IsAcquisitionRouteAccessible({}, {kind='named_drop',source='fixture:contradictory'}), 'Horde service affiliation cannot veto a separate enemy loot route')
local bag={itemID=999997,name='Blocked bag fixture',bagUpgrade=true,acquisitionPlan={routes={merchant}}}
assert(not a:ShouldShowOverlayAcquisition(bag),'bag presentation must retain hard service restrictions')
bag.bagFromInventory=true
assert(a:ShouldShowOverlayAcquisition(bag),'owned usable bag needs no new vendor route')
for _,id in ipairs({13400,13402,18674}) do
 assert(a.ItemCatalog[id].availableLevel==55)
 for _,list in pairs(a.EquipmentByClass) do for _,g in ipairs(list) do if g.itemID==id then assert(g.targetLevel>=55,'copied class objective retained obsolete required level') end end end
end
for id,name in pairs({['93165']='Mercy Falls on Deaf Ears',['93459']="More Al'Aketh Ears",['94484']='Unnerving Silence'}) do
 assert(m.quests[id].name==name and m.quests[id].previousPublishedName=='Quest #'..id,'exact current quest title must replace only its placeholder')
end
for _,spec in ipairs({{'256','starts','256'},{'93318','starts','610954'},{'1526','ends','61934'},{'1527','starts','61934'},{'94467','ends','61934'},{'94468','starts','61934'}}) do
 local quest=m.quests[spec[1]];local found=false
 for _,key in ipairs(quest[spec[2]]) do assert(key~='npc:'..spec[3]);if key=='object:'..spec[3] then found=true end end
 assert(found and quest.previousSourceActors[spec[2]],'retain the verified object role and historical actor list')
end
print('PASS commerce policy: '..commerceCount..' real routes; '..cases..' class/level/slot contexts; exact ACA identity/offer/point, Horde/conflicting/unknown service, neutral Ratchet, shared quests/WC, RFC and analogous territories')
