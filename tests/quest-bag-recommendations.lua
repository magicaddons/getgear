local root=arg[1] or '.';local a={}
for f in assert(io.open(root..'/GetGear.toc')):read('*a'):gmatch('[^\r\n]+') do
    if f:match('%.lua$') and f~='Core.lua' and f~='UI.lua' and f~='AltInventory.lua' then assert(loadfile(root..'/'..f))('GetGear',a) end
end
a.db={status={},hidden={},overlay={bagUpgrades=true},detail={}};a.Gear={}
local capacities,ids,families={6,6,6,6},{},{0,0,0,0}
local side,race,raceID='Alliance','Human',1
UnitFactionGroup=function()return side end
UnitRace=function()return race,race,raceID end
UnitClass=function()return a.classToken,a.classToken end
local done,owned,bank={},{},{}
C_QuestLog={IsQuestFlaggedCompleted=function(id)return done[id] or false end,IsOnQuest=function()return false end}
GetInventoryItemID=function(_,slot)return ids[slot-19]end
GetInventoryItemLink=function()return nil end
C_Item={GetItemCount=function(id,includeBank)return(owned[id]or 0)+(includeBank and bank[id]or 0)end}
C_Container={GetContainerNumSlots=function(index)return index==0 and 16 or capacities[index]end,
    GetContainerNumFreeSlots=function(index)return 0,families[index]end}
local function find(id,mode)
    for _,g in ipairs(mode and a:GetItems(mode) or a:GetBagPlanningObjectives())do if g.itemID==id then return g end end
end
assert(#a.QuestBagCatalogue==23)
local seen={};for _,b in ipairs(a.QuestBagCatalogue)do assert(not seen[b.itemID]);seen[b.itemID]=true;assert(b.slots>=6 and b.slots<=18)end
assert(not seen[3604] and not seen[3605] and not seen[226697],'ammo/quivers and explicitly unconfirmed Red Bag stay excluded')
local classes={'PRIEST','MAGE','WARLOCK','DRUID','ROGUE','HUNTER','SHAMAN','WARRIOR','PALADIN'}
for _,class in ipairs(classes)do for _,faction in ipairs({'Alliance','Horde'})do
    a.classToken=class;side=faction;race=faction=='Alliance' and 'Human' or 'Orc';raceID=faction=='Alliance' and 1 or 2
    for level=1,60 do
        a.level=level
        for _,g in ipairs(a:GetBagPlanningObjectives())do
            assert(g.bagUpgrade and g.quantity>0)
            if g.sourceType=='Quest' then
                assert(g.quantity==1 and g.capacityGain>0 and g.bagSlots>g.oldSlots[1])
                for _,route in ipairs(a:GetEligibleAcquisitionRoutes(g))do
                    local q=a.AcquisitionNavigationData.quests[tostring(route.questID)]
                    assert(q and level>=q.reqlevel)
                    assert(q.side~=1 or faction=='Alliance');assert(q.side~=2 or faction=='Horde')
                end
            end
        end
    end
end end
side='Alliance';race='Human';raceID=1;a.level=9;a.classToken='PRIEST'
assert(a:GetBagUpgradePlan()==nil,'four6slot bags need no level9 crafted6slot bags')
local blanchy=assert(find(1537));assert(blanchy.bagSlots==8 and blanchy.quantity==1 and blanchy.capacityGain==2)
assert(find(277332),'Ratchet neutral quest remains available to Alliance')
assert(not find(11845),'Horde-only bag cannot leak to Alliance')
assert(find(277977)==nil,'equal6slot quest bag has no benefit')
capacities={0,0,0,0};a.level=4
assert(find(277977),'Canvas Latchbag has no published Dwarf/Gnome-only restriction')
assert(not find(279936),'Book Return has an explicit published non-Human race gate')
race='Dwarf';raceID=3;assert(find(279936),'eligible Book Return race retains the reward')
done[97277]=true;assert(not find(277977));done[97277]=nil
a.db.hidden.auto_bag_277977=true;assert(not find(277977,'bags'));a.db.hidden.auto_bag_277977=nil
a.db.status.auto_bag_277977='skipped';assert(not find(277977,'bags') and find(277977,'completed'));a.db.status.auto_bag_277977=nil
a.level=15;capacities={6,6,6,6};race='Human';raceID=1
assert(find(4498),'vendor alternative survives when crafted plan is absent or independently adequate')
local vendor=assert(find(4498));assert(a:GetAcquisitionMapTarget(vendor).zone=='Elwynn Forest')
side='Horde';race='Orc';raceID=2
assert(a:GetAcquisitionMapTarget(assert(find(4498))).zone=='Orgrimmar')
capacities={0,0,0,0};a.level=4;assert(find(11845));assert(not find(277977))
race='Tauren';raceID=6;a.level=1;assert(find(277200))
race='Orc';raceID=2;assert(not find(277200),'Tauren/Undead race-restricted quest is not an Orc route')
side='Alliance';race='Human';raceID=1;a.level=60;capacities={18,18,18,18}
assert(#a:GetBagPlanningObjectives()==0,'no equal/smaller bags at level60')
capacities={2,2,2,2};families={1,2,4,8};assert(#a:GetBagPlanningObjectives()==0,'restricted bags are not interchangeable')
families={nil,nil,nil,nil};assert(#a:GetBagPlanningObjectives()==0,'unknown bag families are protected')
families={0,0,0,0};capacities={6,6,6,6};ids={1537};a.level=9
assert(not find(1537),'Unique equipped copy cannot be acquired again for another slot')
ids={};done[151]=true;owned[1537]=1
local spare=assert(find(1537));assert(spare.bagFromInventory and spare.quantity==1 and not a:GetAcquisitionMapTarget(spare))
owned[1537]=nil;bank[1537]=1;assert(find(1537).bagFromInventory,'known bank ownership avoids a second Unique reward')
capacities={8,6,6,6};assert(not find(1537),'uncached equipped bag identity cannot turn a possibly worn Unique bag into a spare')
capacities={6,6,6,6}
bank[1537]=nil;assert(not find(1537),'completed quest with no owned reward is not repeatable')
done[151]=nil;a.db.statPriorities={mode='custom',weights={ITEM_MOD_SPIRIT_SHORT=0}}
assert(find(1537,'tracker') and a:ShouldShowOverlayStatChanges(find(1537)),'bags never enter equipment stat scoring')
local directions=a:GetAcquisitionDirections(assert(find(2082)))
assert(directions:find('Buzzbox 827',1,true) and directions:find('Buzzbox 525',1,true) and directions:find('prerequisite',1,true))
local reads=0
C_Container.GetContainerItemInfo=function(index,slot)reads=reads+1;if index==0 and slot==1 then return{itemID=1537,stackCount=1}end end
local inventoryBag=assert(find(1537));assert(inventoryBag.spareBags==1 and inventoryBag.bagFromInventory)
assert(reads==16+24,'inventory is scanned once for every quest/craft/vendor alternative combined')
a.db.overlay.bagUpgrades=false;assert(#a:GetBagPlanningObjectives()==0)
print('PASS quest bags:23 published candidates/nine classes/both factions/levels1-60/capacity/race/Unique/owned/complete/skip/vendor/map/chain/specialty protection')
