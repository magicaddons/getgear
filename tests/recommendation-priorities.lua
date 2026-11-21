-- Net scoring is shared by the guide/tracker; preview and progress stay independent.
local root=arg[1] or '.';local a={}
for f in assert(io.open(root..'/GetGear.toc')):read('*a'):gmatch('[^\r\n]+') do
    if f:match('%.lua$') and f~='Core.lua' and f~='UI.lua' and f~='AltInventory.lua' then assert(loadfile(root..'/'..f))('GetGear',a) end
end
local stats,inventory,kinds={},{},{}
C_Item={GetItemStats=function(link)return stats[link]end,GetItemInventoryTypeByID=function(link)return kinds[link] or 13 end}
GetInventoryItemLink=function(_,slot)return inventory[slot]end
GetInventoryItemID=function(_,slot)local link=inventory[slot];return link and tonumber(link:match('item:(%d+)'))end
local requests=0;a.RequestItemDataOnce=function()requests=requests+1 end
local function fresh()
    a.db={schemaVersion=4,status={},hidden={},overlay={filterObsolete=false,hideGreenBoEWorldDrops=false},detail={}}
    a.level=25;a:InitializeStatPriorities();inventory={};stats={};kinds={}
end
local function gear(id,slot)return{itemID=id,id='item_'..id,name='Fixture '..id,slot=slot or 'Ring',targetLevel=25,armorType='Jewelry',statRole='mixed'}end
local function has(mode,id)for _,g in ipairs(a:GetItems(mode))do if g.itemID==id then return true end end;return false end
local classes={'PRIEST','MAGE','WARLOCK','DRUID','ROGUE','HUNTER','SHAMAN','WARRIOR','PALADIN'}
for _,class in ipairs(classes) do for _,side in ipairs({'Alliance','Horde'})do
    fresh();a.classToken=class;UnitFactionGroup=function()return side end
    UnitClass=function()return class,class,({WARRIOR=1,PALADIN=2,HUNTER=3,ROGUE=4,PRIEST=5,SHAMAN=7,MAGE=8,WARLOCK=9,DRUID=11})[class]end
    assert(a:GetStatPriorityMode()=='balanced')
    local key=(class=='WARRIOR' or class=='ROGUE' or class=='HUNTER')and'ITEM_MOD_STRENGTH_SHORT'or'ITEM_MOD_INTELLECT_SHORT'
    local candidate,negative=gear(990001),gear(990002)
    inventory[11]='item:990000';inventory[12]='item:990000'
    stats['item:990000']={[key]=10,ITEM_MOD_STAMINA_SHORT=10}
    stats['item:990001']={[key]=12,ITEM_MOD_STAMINA_SHORT=7}
    stats['item:990002']={[key]=11,ITEM_MOD_STAMINA_SHORT=1}
    a.Gear={candidate,negative};a:SetPriorityStat(key);a:SetStatPriorityMode('priority')
    assert(a:GetWeightedUpgradeEvaluation(candidate).score==17,class..side)
    assert(has('available',candidate.itemID)==a:ShouldShowOverlayStatChanges(candidate))
    a:SetStatPriorityMode('custom');a.db.statPriorities.weights={[key]=1,ITEM_MOD_STAMINA_SHORT=1}
    assert(a:GetWeightedUpgradeEvaluation(candidate).status=='no-benefit')
    assert(not has('available',candidate.itemID) and not has('tracker',candidate.itemID))
    a:SetCustomStatWeight(key,5)
    assert(a:GetWeightedUpgradeEvaluation(candidate).score==7)
    assert(has('available',candidate.itemID) and has('tracker',candidate.itemID))
    assert(not has('available',negative.itemID))
    a.db.statPriorities.weights={[key]=0,ITEM_MOD_STAMINA_SHORT=0}
    assert(a:GetWeightedUpgradeEvaluation(candidate).score==0 and not has('available',candidate.itemID))
    a.db.overlay.showAllValidGear=true;assert(has('available',candidate.itemID));a.db.overlay.showAllValidGear=false
    a.db.status[candidate.id]='skipped';assert(has('completed',candidate.itemID));a.db.status[candidate.id]=nil
    a.db.hidden[candidate.id]=true;assert(has('hidden',candidate.itemID));a.db.hidden[candidate.id]=nil
    local preview=a:GetPreviewRecommendations(class);assert(#preview>1000)
    assert(a.db.statPriorities.mode=='custom' and a.db.statPriorities.weights[key]==0,'preview must not change preferences')
    a:ResetStatPriorities();assert(a:GetStatPriorityMode()=='balanced')
end end
fresh();a.classToken='PRIEST'
local item=gear(990001);inventory[11]='item:990000';inventory[12]='item:990000'
stats['item:990000']={ITEM_MOD_SPIRIT_SHORT=10,ITEM_MOD_INTELLECT_SHORT=10,ITEM_MOD_STAMINA_SHORT=10}
stats['item:990001']={ITEM_MOD_SPIRIT_SHORT=14,ITEM_MOD_INTELLECT_SHORT=4,ITEM_MOD_STAMINA_SHORT=6}
a:SetPriorityStat('ITEM_MOD_SPIRIT_SHORT');a:SetStatPriorityMode('priority')
assert(a:GetWeightedUpgradeEvaluation(item).score==4,'Spirit priority counts Intellect and Stamina losses')
a:SetStatPriorityMode('custom');a.db.statPriorities.weights={ITEM_MOD_SPIRIT_SHORT=5,ITEM_MOD_INTELLECT_SHORT=3,ITEM_MOD_STAMINA_SHORT=1}
assert(a:GetWeightedUpgradeEvaluation(item).score==-2)
stats['item:990001'].ITEM_MOD_SPIRIT_SHORT=16;assert(a:GetWeightedUpgradeEvaluation(item).score==8)
stats['item:990001'].ITEM_MOD_SPIRIT_SHORT=0/0
assert(a:GetWeightedUpgradeEvaluation(item).status=='unknown','unreadable numerical stats cannot become a zero-valued tradeoff')
stats['item:990001'].ITEM_MOD_SPIRIT_SHORT=16
-- Do not require the selected stat: a large relevant gain elsewhere can win.
stats['item:990001']={ITEM_MOD_SPIRIT_SHORT=10,ITEM_MOD_INTELLECT_SHORT=20,ITEM_MOD_STAMINA_SHORT=10}
assert(a:GetWeightedUpgradeEvaluation(item).score==30)
stats['item:990001']={ITEM_MOD_INTELLECT_SHORT=40,ITEM_MOD_STAMINA_SHORT=10}
assert(a:GetWeightedUpgradeEvaluation(item).score==40,'an item lacking Spirit can win after explicitly counting the entire Spirit loss')
stats['item:990001']={ITEM_MOD_SPIRIT_SHORT=10,ITEM_MOD_INTELLECT_SHORT=20,ITEM_MOD_STAMINA_SHORT=10}
-- Empty slots, either paired slot, uncached inventory and explicit set planning.
inventory={};assert(a:GetWeightedUpgradeEvaluation(item).status=='upgrade')
GetInventoryItemID=nil;assert(a:GetWeightedUpgradeEvaluation(item).status=='unknown')
GetInventoryItemID=function()return nil end
inventory[16]='item:990000';kinds['item:990000']=17
local off=gear(990001,'Off Hand');off.armorType='Held In Off-hand'
assert(a:GetWeightedUpgradeEvaluation(off).status=='unknown','potential offhand does not define net replacement')
stats['item:990002']={ITEM_MOD_SPIRIT_SHORT=1};kinds['item:990002']=13
local partner=gear(990002,'Main Hand');partner.armorType='Dagger'
local pair=a:GetGearComparison(off,true,partner)
assert(a:ScoreComparisonGroup(off,pair.groups[2])==35)
local two=gear(990001,'Two-Hand Staff');two.armorType='Staff'
inventory[17]='item:990002';kinds['item:990000']=13
assert(a:GetWeightedUpgradeEvaluation(two).score==25,'two-handed candidate loses both main-hand and offhand attributes')
local one=gear(990001,'Main Hand');one.armorType='Dagger';inventory[17]=nil;kinds['item:990000']=17
assert(a:GetWeightedUpgradeEvaluation(one).score==30,'one-handed replacement loses all two-handed stats')
-- Dual-wield DPS cannot be added or silently scored as zero.
a.classToken='WARRIOR';a.db.statPriorities.weights={ITEM_MOD_DAMAGE_PER_SECOND_SHORT=1}
stats['item:990000']={ITEM_MOD_DAMAGE_PER_SECOND_SHORT=10};stats['item:990002']={ITEM_MOD_DAMAGE_PER_SECOND_SHORT=12}
stats['item:990001']={ITEM_MOD_DAMAGE_PER_SECOND_SHORT=25};inventory[17]='item:990002'
two.slot='Two-Hand Sword';two.armorType='Sword'
assert(a:GetWeightedUpgradeEvaluation(two).status=='unknown')
stats['item:990002']={ITEM_MOD_STRENGTH_SHORT=1}
assert(a:GetWeightedUpgradeEvaluation(two).status=='unknown','one missing dual-wield DPS value cannot disappear from the baseline')
inventory={};stats['item:990001']={ITEM_MOD_STRENGTH_SHORT=2}
assert(a:GetWeightedUpgradeEvaluation(one).status=='unknown','unreported physical weapon DPS is not zero')
-- Neither Show-all nor weights may introduce unusable equipment or irrelevant stats.
a.classToken='PRIEST';a.db.overlay.showAllValidGear=true
assert(a:GetWeightedUpgradeEvaluation(a.ItemCatalog[273841]).status=='ineligible')
assert(a:GetStatWeight('ITEM_MOD_STRENGTH_SHORT',item)==0)
assert(a:GetStatWeight('ITEM_MOD_DAMAGE_PER_SECOND_SHORT',one)==0)
assert(not a:SetCustomStatWeight('ITEM_MOD_SPIRIT_SHORT',-1))
assert(not a:SetCustomStatWeight('ITEM_MOD_SPIRIT_SHORT',0/0))
assert(not a:SetCustomStatWeight('ITEM_MOD_SPIRIT_SHORT',math.huge))
assert(not a:SetCustomStatWeight('made-up-stat',5))
a.db.statPriorities={mode='invalid',priority='invalid',weights={bad=3,ITEM_MOD_SPIRIT_SHORT=-9}}
a:InitializeStatPriorities();assert(a:GetStatPriorityMode()=='balanced' and next(a.db.statPriorities.weights)==nil)
assert(requests==0,'recommendation scans must not issue bulk cache requests')
print('PASS stat priorities: nine classes x two factions, three modes, net gains/losses, slots/sets, zero/invalid/unknown, preview/progress and shared lists')
