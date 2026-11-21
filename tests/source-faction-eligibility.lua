local root=arg[1] or '.';local a={}
for f in assert(io.open(root..'/GetGear.toc')):read('*a'):gmatch('[^\r\n]+') do
    if f:match('%.lua$') and f~='Core.lua' and f~='UI.lua' and f~='AltInventory.lua' then assert(loadfile(root..'/'..f))('GetGear',a) end
end
local side,class,level='Alliance','PRIEST',10
local classIDs={WARRIOR=1,PALADIN=2,HUNTER=3,ROGUE=4,PRIEST=5,SHAMAN=7,MAGE=8,WARLOCK=9,DRUID=11}
UnitFactionGroup=function()return side end;UnitClass=function()return class,class,classIDs[class]end
UnitLevel=function()return level end;UnitRace=function()return'Human','Human',1 end
C_QuestLog={IsOnQuest=function()return false end,IsQuestFlaggedCompleted=function()return false end}
a.db={status={},hidden={},overlay={showAllValidGear=true,filterObsolete=false},detail={}};a.level=10
local model=a.AcquisitionNavigationData
model.sources['fixture:A']={name='Alliance seller',serviceSide=1,locations={{zone='Loch Modan',x=10,y=20}}}
model.sources['fixture:H']={name='Horde seller',serviceSide=2,locations={{zone='Silverpine Forest',x=30,y=40}}}
model.sources['fixture:N']={name='Neutral seller',locations={{zone='The Barrens',x=50,y=50}}}
model.quests['990001']={questID=990001,name='Alliance quest',side=1,starts={'fixture:A'},ends={},reqlevel=1}
model.quests['990002']={questID=990002,name='Horde quest',side=2,starts={'fixture:H'},ends={},reqlevel=1}
local function fixture(id,routes)
    model.items[tostring(id)]={routes=routes}
    return{itemID=id,id='item_'..id,slot='Ring',name='Source fixture '..id,targetLevel=10,armorType='Jewelry'}
end
local mixed=fixture(990010,{{kind='quest',questID=990001},{kind='quest',questID=990002}})
local hostile=fixture(990011,{{kind='vendor',source='fixture:H'}})
local neutral=fixture(990012,{{kind='vendor',source='fixture:N'}})
local contested=fixture(990013,{{kind='dungeon',dungeon='Shadowfang Keep'}})
local unknown=fixture(990014,{})
local multi=fixture(990015,{{kind='vendor',source='fixture:H'},{kind='vendor',source='fixture:N'}})
local recipe=fixture(990016,{{kind='recipe_vendor',source='fixture:H'}});recipe.profession='Tailoring'
local function has(mode,id)for _,g in ipairs(a:GetItems(mode))do if g.itemID==id then return true end end end
GetInventoryItemLink=function()return nil end;GetInventoryItemID=function()return nil end
for token in pairs(classIDs)do for _,faction in ipairs({'Alliance','Horde'})do
    class=token;side=faction;a.classToken=class;a.faction=side;a.Gear={mixed,hostile,neutral,contested,unknown,multi,recipe}
    local routes,known=a:GetEligibleAcquisitionRoutes(mixed)
    assert(known and #routes==1 and routes[1].questID==(side=='Alliance'and 990001 or 990002))
    assert(a:GetAcquisitionMapTarget(mixed).questID==routes[1].questID)
    assert(a:GetAcquisitionDirections(mixed):find(side..' quest',1,true))
    assert(not a:GetAcquisitionDirections(mixed):find((side=='Alliance'and'Horde'or'Alliance')..' quest',1,true))
    assert(a:HasEligibleAcquisitionSource(hostile)==(side=='Horde'))
    assert((has('available',hostile.itemID)==true)==(side=='Horde'))
    assert((has('tracker',hostile.itemID)==true)==(side=='Horde'))
    if side=='Alliance'then assert(not a:GetAcquisitionMapTarget(hostile));assert(a:GetFactionAcquisitionDescription(hostile):find('No published',1,true))end
    assert(a:HasEligibleAcquisitionSource(neutral) and a:ShouldShowOverlayAcquisition(neutral),'neutral Barrens is accessible, regardless of danger/distance')
    assert(a:HasEligibleAcquisitionSource(contested) and a:ShouldShowOverlayAcquisition(contested),'Silverpine dungeon access is shared')
    assert(a:HasEligibleAcquisitionSource(unknown),'no data is unknown, not faction-exclusive')
    assert(a:HasEligibleAcquisitionSource(multi),'one eligible source keeps the item')
    if side=='Alliance'then assert(a:GetAcquisitionMapTarget(multi).source=='fixture:N')end
    assert(#a:GetPreviewRecommendations(class)>1000)
    assert(a:SelectCurrentGuide()>1000,'both faction characters can use the proficiency catalogue')
end end
side='Alliance';class='PRIEST';a.classToken=class;a.Gear={hostile}
a.db.status[hostile.id]='acquired';assert(has('completed',hostile.itemID),'source changes do not erase acquired history')
a.db.status[hostile.id]=nil;a.db.hidden[hostile.id]=true;assert(has('hidden',hostile.itemID));a.db.hidden[hostile.id]=nil
local future=fixture(990017,{{kind='quest',questID=990003}})
model.quests['990003']={questID=990003,name='Known level gate',side=1,reqlevel=14,starts={'fixture:A'},ends={}}
a.Gear={future};a.level=10
assert(not has('available',future.itemID) and has('upcoming',future.itemID),'source minimum is reflected in recommendation target without mutating catalogue')
assert(future.targetLevel==10)
recipe.bindingStatus='boe';recipe.recipeSpellID=990001
assert(a:HasEligibleAcquisitionSource(recipe),'verified tradeable craft remains possible without inventing a new recipe seller')
assert(a:ShouldShowOverlayAcquisition(recipe) and not a:GetAcquisitionMapTarget(recipe),'finished tradeability does not expose a Horde book pin')
assert(a:GetFactionAcquisitionDescription(recipe):find('no current offer',1,true))
recipe.bindingStatus=nil
local questCraft=fixture(990018,{{kind='quest',questID=990003,bookItemID=990019}})
questCraft.profession='Tailoring';assert(a:GetRecommendationRecord(questCraft).targetLevel==10,'book quest minimum must not become finished-item equip/access minimum')
a.GetRecipeKnowledge=function()return true end
assert(a:HasEligibleAcquisitionSource(recipe),'known recipe does not require reacquiring a faction-specific book')
assert(a:ShouldShowOverlayAcquisition(recipe),'known recipe eligibility is consistent on the overlay')
-- Actual low-level catalogue routes keep their correct faction and neutral choices.
a.GetRecipeKnowledge=nil
for _,id in ipairs({3334,6468,6898,15109,8071,6392})do
    for _,route in ipairs(a:GetEligibleAcquisitionRoutes(a.ItemCatalog[id]))do
        local q=model.quests[tostring(route.questID)]
        assert(not q or q.side~=2,'actual Alliance source projections must not include Horde-only quests')
    end
end
print('PASS source eligibility:nine classes/both factions/quest-vendor-recipe/neutral-contested/multiple routes/unknown/history/preview/minimum-level/map consistency')
