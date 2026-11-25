-- Travel convenience never changes source eligibility or the approved catalogue.
local root=arg[1] or '.';local a={}
for f in assert(io.open(root..'/GetGear.toc')):read('*a'):gmatch('[^\r\n]+') do
 if f:match('%.lua$') and f~='Core.lua' and f~='UI.lua' and f~='AltInventory.lua' then assert(loadfile(root..'/'..f))('GetGear',a) end
end
local classIDs={WARRIOR=1,PALADIN=2,HUNTER=3,ROGUE=4,PRIEST=5,SHAMAN=7,MAGE=8,WARLOCK=9,DRUID=11}
local faction,class,level,zone='Alliance','DRUID',14,nil
UnitFactionGroup=function()return faction end;UnitLevel=function()return level end
UnitClass=function()return class,class,classIDs[class]end
UnitRace=function()return 'Human','Human',1 end
C_Map={GetBestMapForUnit=function()return zone and 999 end,GetMapInfo=function()return {name=zone}end}
C_QuestLog={IsOnQuest=function()return false end,IsQuestFlaggedCompleted=function()return false end}
local occupied=true;local gain=1
GetInventoryItemLink=function(_,slot)return occupied and (slot==11 or slot==12) and 'item:990000' or nil end
GetInventoryItemID=function(_,slot)return occupied and (slot==11 or slot==12) and 990000 or nil end
C_Item={GetItemStats=function(link)return {ITEM_MOD_STAMINA_SHORT=link=='item:990000' and 10 or 10+gain}end}
a.db={overlay={filterObsolete=false,hideGreenBoEWorldDrops=false},status={},hidden={}};a.level=14
local model=a.AcquisitionNavigationData
local function actor(key,sourceZone,service,verification)
 model.sources[key]={name=key,serviceSide=service,locations={{zone=sourceZone,x=45,y=45,verification=verification or 'published-reference'}}}
end
local function item(id,routes)
 return {id='fixture_'..id,itemID=id,name='Travel fixture',targetLevel=14,slot='Ring',armorType='Jewelry',
   acquisitionPlan={routes=routes}}
end
local function contains(mode,g)for _,r in ipairs(a:GetItems(mode))do if r.id==g.id then return true end end end
for token in pairs(classIDs)do for _,side in ipairs({'Alliance','Horde'})do
 class=token;a.classToken=class;faction=side;level=14;zone=nil
 local enemy=side=='Alliance' and 'The Barrens' or 'Westfall'
 local home=side=='Alliance' and 'Loch Modan' or 'Silverpine Forest'
 local enemySide=side=='Alliance' and 2 or 1
 actor('fixture:drop',enemy);actor('fixture:home',home,3-enemySide);actor('fixture:neutral',enemy,3)
 actor('fixture:restricted',enemy,enemySide)
 actor('fixture:unknown','Uncharted');actor('fixture:starter',side=='Alliance' and 'Durotar' or 'Elwynn Forest')
 local remote=item(990001,{{kind='named_drop',source='fixture:drop'}})
 local alternate=item(990002,{{kind='named_drop',source='fixture:drop'},{kind='vendor',source='fixture:home'}})
 local neutral=item(990003,{{kind='vendor',source='fixture:neutral'}})
 local dungeon=item(990004,{{kind='dungeon',dungeon='Shadowfang Keep'}})
 local starter=item(990005,{{kind='named_drop',source='fixture:starter'}})
 local uncertain=item(990006,{{kind='named_drop',source='fixture:drop'},{kind='named_drop',source='fixture:unknown'}})
 local forbidden=item(990007,{{kind='vendor',source='fixture:restricted'}})
 model.quests['990099']={questID=990099,name='Shared neutral quest',side=0,starts={'fixture:neutral'},ends={},reqlevel=10}
 local quest=item(990008,{{kind='quest',questID=990099}})
 a.Gear={remote,alternate,neutral,dungeon,starter,uncertain,forbidden,quest}
 assert(a:HasEligibleAcquisitionSource(remote) and a:GetAcquisitionPracticality(remote).status==(side=='Alliance' and 'restricted-territory' or 'inconvenient'))
 assert(not a:ShouldShowOverlayAcquisition(remote) and not a:ShouldShowOverlayAcquisition(starter),'minor remote ordinary sources should wait in Guide')
 assert(contains('available',remote) and contains('available',starter),'detailed guide preserves inconvenient sources')
 for _,g in ipairs({alternate,neutral,dungeon,uncertain,quest})do
  assert(a:HasEligibleAcquisitionSource(g) and a:ShouldShowOverlayAcquisition(g),'shared/alternative/uncertain sources stay')
 end
 local target=a:GetAcquisitionMapTarget(alternate)
 assert(target.source=='fixture:home' and target.practicality=='practical','map and compact source select practical alternative')
 assert(a:GetAcquisitionCompactSummary(alternate):find(home,1,true))
 assert(#a:GetAcquisitionNavigationChoices(alternate)==2,'original eligible sources remain browsable')
 assert(not a:HasEligibleAcquisitionSource(forbidden) and not a:ShouldShowOverlayAcquisition(forbidden))
 a.db.overlay.showAllValidGear=true
 assert(a:ShouldShowOverlayAcquisition(remote) and not a:ShouldShowOverlayAcquisition(forbidden),'show all lifts convenience, never hard restrictions')
 a.db.overlay.showAllValidGear=false
 gain=20;assert(a:ShouldShowOverlayAcquisition(remote)==(side=='Horde'),'substantial gain may justify travel');gain=1
 a.db.statPriorities={mode='custom',weights={ITEM_MOD_STAMINA_SHORT=0.001}}
 gain=4;assert(a:ShouldShowOverlayAcquisition(remote)==(side=='Horde'),'substantial custom-weight gain is independent of numerical weight scale')
 gain=1;assert(not a:ShouldShowOverlayAcquisition(remote),'relative minor gain remains minor at small custom scales')
 a.db.statPriorities=nil

 occupied=false;assert(a:ShouldShowOverlayAcquisition(remote)==(side=='Horde'),'confirmed empty slot may justify travel');occupied=true
 local saved=C_Item.GetItemStats;C_Item.GetItemStats=function()return nil end
 assert(a:ShouldShowOverlayAcquisition(remote)==(side=='Horde'),'unknown comparisons cannot prove a trivial gain');C_Item.GetItemStats=saved
 zone=enemy;assert(a:ShouldShowOverlayAcquisition(remote)==(side=='Horde'),'already in the source zone');zone=nil
 level=30;assert(a:ShouldShowOverlayAcquisition(remote)==(side=='Horde'),'do not extend low-level travel heuristics into endgame');level=14
 remote.bindingStatus='boe';assert(a:ShouldShowOverlayAcquisition(remote))
 assert(a:GetAcquisitionCompactSummary(remote):find('listings unknown',1,true),'trade alternative is distinct from original drop');remote.bindingStatus=nil
 remote.notes='Equip: movement speed bonus';assert(a:ShouldShowOverlayAcquisition(remote)==(side=='Horde'),'unscored effects cannot be trivialized');remote.notes=nil
 local unknown=item(990009,{});assert(a:ShouldShowOverlayAcquisition(unknown))
 model.sources['fixture:drop'].locations[1].verification=nil
 assert(a:ShouldShowOverlayAcquisition(remote)==(side=='Horde'),'unqualified geography remains uncertain')
 -- A known learned recipe is independent of its remote book-learning source.
 local craft=item(990010,{{kind='recipe_vendor',source='fixture:restricted'}});craft.profession='Leatherworking'
 a.GetRecipeKnowledge=function()return true end;assert(a:ShouldShowOverlayAcquisition(craft));a.GetRecipeKnowledge=nil
end end
-- Assert actual accepted examples and published source identity before applying policy.
faction='Alliance';class='DRUID';a.classToken=class
for _,spec in ipairs({{285339,'Centaur War Chain','npc:5841','Rocklance'},
 {285345,'Feather Padded Treads','npc:5830','Sister Rathtalon'},
 {285330,'Signet of the Zhevra','npc:5831','Swiftmane'}})do
 local g=assert(a.ItemCatalog[spec[1]]);local plan=assert(model.items[tostring(spec[1])]);local r=plan.routes[1]
 assert(g.name==spec[2] and r.kind=='named_drop' and r.source==spec[3] and not r.serviceSide)
 local source=assert(model.sources[r.source]);assert(source.name==spec[4] and not source.serviceSide and source.locations[1].zone=='The Barrens')
 assert(a:HasEligibleAcquisitionSource(g) and a:GetAcquisitionPracticality(g).status=='restricted-territory')
end
actor('fixture:multi-location','The Barrens')
model.sources['fixture:multi-location'].locations[2]={zone='Loch Modan',x=12,y=34,verification='published-reference'}
local multiple=item(990080,{{kind='named_drop',source='fixture:multi-location'}})
assert(a:GetAcquisitionPracticality(multiple).status=='practical')
assert(a:GetAcquisitionMapTarget(multiple).zone=='Loch Modan','practical location wins within a shared source')
local sharedAlternative=item(990081,{{kind='named_drop',source='fixture:unknown'},
 {kind='dungeon',dungeon='Stratholme'}})
assert(a:GetAcquisitionMapTarget(sharedAlternative).source=='fixture:unknown',
 'shared dungeon eligibility is not proof of a more convenient destination')
local actualNeutral=a.ItemCatalog[3334]
local neutralQuest=false
for _,route in ipairs(model.items['3334'].routes)do if route.questID==79192 then neutralQuest=true end end
assert(neutralQuest and model.quests['79192'].side==3)
assert(a:HasEligibleAcquisitionSource(actualNeutral) and a:GetAcquisitionPracticality(actualNeutral).status=='practical',
 'Stepping Stones is a shared Barrens quest, not Horde-only')
for _,side in ipairs({'Alliance','Horde'})do
 faction=side;local routes=a:GetEligibleAcquisitionRoutes(a.ItemCatalog[253925])
 assert(#routes==1 and routes[1].source==(side=='Alliance'and'npc:256735'or'npc:248202'),
  'Pristine Sash book vendors retain their published per-seller faction access')
end
faction='Alliance'
assert(a:GetAcquisitionPracticality(a.ItemCatalog[10410]).status=='practical','Wailing Caverns remains shared')
assert(a:GetAcquisitionPracticality(a.ItemCatalog[20575]).status=='practical','verified crafted BoE alternative survives')
print('PASS acquisition practicality: nine classes/both factions; remote/minor vs strong/empty/unknown, neutral/shared/contested, alternatives, same-zone, trade/craft, history and actual Barrens IDs')
