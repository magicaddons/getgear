-- Presentation is read-only: concise primary text, complete guide/routes.
local root=assert(arg[1]);local a={}
assert(loadfile(root..'/AcquisitionNavigation.lua'))('GetGear',a)
assert(loadfile(root..'/AcquisitionSummary.lua'))('GetGear',a)
assert(loadfile(root..'/MapNavigation.lua'))('GetGear',a)
UnitFactionGroup=function()return'Horde'end;UnitClass=function()return'Druid','DRUID',11 end;UnitLevel=function()return 11 end
C_Map=nil;C_QuestLog=nil
local m={items={},sources={},quests={},chains={},recipeRequirements={}}
a.AcquisitionNavigationData=m
local function copy(v)if type(v)~='table'then return v end;local out={};for k,x in pairs(v)do out[k]=copy(x)end;return out end
local function same(a,b)if type(a)~=type(b)then return false end;if type(a)~='table'then return a==b end;for k,v in pairs(a)do if not same(v,b[k])then return false end end;for k in pairs(b)do if a[k]==nil then return false end end;return true end
local function actor(id,name,side)
 m.sources['npc:'..id]={name=name,serviceSide=side,evidence={{url='https://example.invalid/full-npc/'..id}},locations={{zone='Mulgore',bounds={xMin=30,xMax=32,yMin=40,yMax=41},verification='published-reference'}}}
end
actor(1,'Routine trainer',2);actor(2,'Second trainer',2);actor(3,'Pattern seller',2);actor(4,'Named enemy');actor(5,'Opposing seller',1)
local function gear(id,routes,extra)
 m.items[tostring(id)]={routes=routes};m.recipeRequirements[tostring(id)]={recipeMinimumSkill=35}
 local g={itemID=id,profession='Leatherworking'};for k,v in pairs(extra or {})do g[k]=v end;return g
end
local trainer={kind='trainer',source='npc:1',spellID=2160,verification='published-reference',serviceSide=2}
local ordinary=gear(1,{copy(trainer)},{recipeLearnMethod='trainer'})
assert(a:GetAcquisitionSummary(ordinary)=='Recipe: Leatherworking trainer (35)')
local uncertain=gear(2,{copy(trainer)})
assert(a:GetAcquisitionSummary(uncertain):find('teaching/access unverified',1,true),'one full teacher reference is not routine teaching')
local second=copy(trainer);second.source='npc:2'
local multi=gear(3,{copy(trainer),second})
assert(a:GetAcquisitionSummary(multi)=='Recipe: Leatherworking trainer (35)','consistent multiple full teaching routes can supply a concise summary without rewriting method metadata')
m.recipeRequirements['1']={};assert(a:GetAcquisitionSummary(ordinary)=='Recipe: Leatherworking trainer (skill unverified)','never invent a minimum from skill-up thresholds')
m.recipeRequirements['1']={recipeMinimumSkill=35}
local restricted=copy(trainer);restricted.sourceRequirements={'Complete the unlock quest','Requires revered reputation'}
local special=gear(4,{restricted},{recipeLearnMethod='trainer'})
assert(a:GetAcquisitionSummary(special):find('Complete the unlock quest',1,true)and a:GetAcquisitionSummary(special):find('revered',1,true),'special trainer requirements cannot be hidden by ordinary formatting')
local vendor=gear(5,{{kind='recipe_vendor',source='npc:3',serviceSide=2,verification='published-reference',offer={cost={0,{{3402,30}},{{1234,2}}},stock=1,standing=6,reqfaction=3000,side=2}}},{recipeLearnMethod='pattern',recipePatternItemID=900})
m.currencies={['3402']={name="Merchant's Favor"}}
local text=a:GetAcquisitionSummary(vendor)
for _,part in ipairs({'Pattern seller',"30 Merchant's Favor",'2 item #1234','Limited listing','Honored','Horde source access','stock/access unverified'})do assert(text:find(part,1,true),text..' lacks '..part)end
assert(not text:find('published reference',1,true)and not text:find('other qualified',1,true))
local foreign=copy(m.items['5'].routes[1]);foreign.source='npc:5';foreign.serviceSide=1;foreign.offer.side=1
m.items['5'].routes[#m.items['5'].routes+1]=foreign
assert(not a:GetAcquisitionSummary(vendor):find('Opposing seller',1,true),'compact text respects existing service access')
local drop=gear(6,{{kind='recipe_drop',source='npc:4',verification='published-reference'}})
assert(a:GetAcquisitionSummary(drop):find('Named enemy drop',1,true)and a:GetAcquisitionSummary(drop):find('drop unverified',1,true))
local dungeon=gear(7,{{kind='dungeon',dungeon='Blackfathom Deeps',boss='Kelris',verification='published-reference'}})
assert(a:GetAcquisitionSummary(dungeon):find('Kelris — Blackfathom Deeps drop',1,true))
local quest=gear(8,{{kind='quest',questID=10,bookItemID=999}})
m.quests['10']={questID=10,name='Earn the recipe',side=2,reqlevel=10,sourceRequirements={'Bring 3 tokens'},starts={'npc:1'},ends={'npc:2'}}
text=a:GetAcquisitionSummary(quest)
for _,part in ipairs({'Earn the recipe','quest level 10','Horde','Bring 3 tokens','prerequisites/access'})do assert(text:find(part,1,true))end
local disputed=gear(9,{copy(trainer)},{recipeLearnMethod='multiple'})
assert(a:GetAcquisitionSummary(disputed):find('disputed',1,true))
local conflicting=copy(second);conflicting.spellID=9999
m.items['3'].routes[2]=conflicting
assert(a:GetAcquisitionSummary(multi):find('teaching/access unverified',1,true),'different taught spells do not establish routine training')
m.items['3'].routes[2]=second;m.recipeRequirements['3'].minimumDisputed=true
assert(a:GetAcquisitionSummary(multi):find('teaching/access unverified',1,true),'disputed minimum remains qualified')
local historical=gear(10,{copy(trainer)},{recipeLearnMethod='trainer',confidence='classic-reference'})
assert(a:GetAcquisitionSummary(historical):find('Classic reference',1,true))
local broad=gear(11,{{kind='recipe_drop',source='npc:4'}});m.recipeRequirements['11'].broadBookDrop=true
assert(a:GetAcquisitionSummary(broad):find('random drop',1,true)and not a:GetAcquisitionSummary(broad):find('Named enemy',1,true),'random examples are not guaranteed or targeted drop sources')
local before=copy(m);a:GetAcquisitionSummary(ordinary);a:GetAcquisitionSummary(vendor);a:GetAcquisitionSummary(quest)
assert(same(before,m),'presentation must not mutate requirements, offers, routes or locations')
assert(a:GetAcquisitionDirections(vendor):find('Pattern seller',1,true)and a:GetAcquisitionDirections(ordinary):find('Routine trainer',1,true),'full guide retains named alternatives and qualifications')
assert(a:GetAcquisitionMarkerLabel({label="Va'yn Moongaze",bounds={}})=="Va'yn Moongaze")
assert(a:GetAcquisitionMarkerLabel({label='Quest objective target',kind='active_quest'})=='Quest objective target')
assert(a:GetAcquisitionMarkerLabel({kind='dungeon',dungeon='Shadowfang Keep',label='Published SFK approach'})=='Shadowfang Keep')
assert(a:GetAcquisitionMarkerLabel({kind='dungeon',dungeon='Stratholme',multipleEntrances=true,publishedEntrance={label='Stratholme — Undead Side Entrance (published approach)'}})=='Stratholme — Undead Side Entrance')
-- Reported record: source catalogued trainer method plus exact teaching skill.
local catalog={};for f in assert(io.open(root..'/GetGear.toc')):read('*a'):gmatch('[^\r\n]+')do
 if f:match('%.lua$')and f~='Core.lua'and f~='UI.lua'and f~='AltInventory.lua'then assert(loadfile(root..'/'..f))('GetGear',catalog)end
end
for _,side in ipairs({'Alliance','Horde'})do
 UnitFactionGroup=function()return side end
 local g=catalog.ItemCatalog[2300];assert(g.name=='Embossed Leather Vest')
 assert(catalog:GetAcquisitionSummary(g)=='Recipe: Leatherworking trainer (35)',side..' reported trainer text')
 local details=catalog:GetAcquisitionDirections(g)
 if side=='Alliance'then assert(details:find('Adele Fielder',1,true)and details:find('current',1,true))end
end
UnitFactionGroup=function()return'Alliance'end
local shining=catalog:GetAcquisitionSummary(catalog.ItemCatalog[253971])
assert(shining:find('Mivin Shadowweave',1,true)and shining:find("30 Merchant's Favor",1,true)and not shining:find("Jim'bek",1,true))
assert(catalog:GetAcquisitionSummary(catalog.ItemCatalog[7280]):find('random drop',1,true))
assert(catalog:GetAcquisitionSummary(catalog.ItemCatalog[3471]):find('Supplying the Front',1,true))
for _,pair in ipairs({{277046,'Friendly with Earthen Ring'},{277054,'Friendly with Kirin Tor'}})do
 assert(catalog:GetAcquisitionSummary(catalog.ItemCatalog[pair[1]]):find(pair[2],1,true),'reviewed text-only reputation gate must survive summarisation')
end
for _,pair in ipairs({{11604,'Armorsmith'},{12784,'Master Axesmith'},{15063,'Tribal Leatherworking'}})do
 assert(catalog:GetAcquisitionSummary(catalog.ItemCatalog[pair[1]]):find(pair[2],1,true),'retain recipe learning specialisation across named drops and vendors')
end
assert(catalog:GetAcquisitionSummary(catalog.ItemCatalog[252424]):find('other methods: Guide',1,true),'mixed vendor/trainer paths must not imply that the physical pattern is the only method')
assert(catalog:GetAcquisitionSummary(catalog.ItemCatalog[2311]):find('learning source unverified',1,true),'an unclassified recipe is not silently promoted to standard training')
assert(catalog:GetAcquisitionSummary(catalog.ItemCatalog[18405]):find("Knot Thimblejack's Cache",1,true),'legitimate object names containing Cache survive formatting')
local container=gear(12,{{kind='npc_container',source='npc:4',containerItemID=900}});container.profession=nil
assert(a:GetAcquisitionSummary(container):find('possible container contents',1,true),'a box drop is not guaranteed equipment')
local historicalTarget={label='Wailing Caverns outer entrance (Kresh drop is Classic-only reference)',kind='legacy',verification='legacy-reference'}
assert(a:GetAcquisitionMarkerLabel(historicalTarget)=='Wailing Caverns outer entrance'and historicalTarget.verification=='legacy-reference','primary text changes without laundering historical source status')
print('PASS acquisition presentation:reported2300/trainer-vendor-drop-quest/restrictions/faction/unknown/guide preservation/concise marker labels;live layout unverified')
