-- End-to-end route/capacity/weight regressions against the real manifest.
local root=arg[1] or "."
local a={};local assertions=0
local function check(ok,message) assertions=assertions+1;assert(ok,message) end
for f in assert(io.open(root.."/GetGear.toc")):read("*a"):gmatch("[^\r\n]+") do
    if f:match("%.lua$") and f~="UI.lua" and f~="Core.lua" and f~="AltInventory.lua" then assert(loadfile(root.."/"..f))("GetGear",a) end
end
local classes={"PRIEST","MAGE","WARLOCK","DRUID","ROGUE","HUNTER","SHAMAN","WARRIOR","PALADIN"}
local faction,class,race="Alliance","PRIEST","Human"
UnitFactionGroup=function()return faction end
UnitClass=function()return class,class end
UnitRace=function()return race,race end
UnitLevel=function()return a.level end
a.db={schemaVersion=4,overlay={},status={},hidden={},detail={}}
a.level=25;a.classToken=class
local done={}
C_QuestLog={IsQuestFlaggedCompleted=function(id)return done[id]==true end}
local function gear(routes,id)
    return {itemID=id or 900001,id="item_"..(id or 900001),name="Fixture",slot="Ring",targetLevel=25,acquisitionRoutes=routes}
end
local function route(zone,kind,side)
    return {kind=kind or "named_drop",side=side,location={zone=zone}}
end
for _,c in ipairs(classes) do
    class=c;a.classToken=c
    for _,f in ipairs({"Alliance","Horde"}) do
        faction=f;a.level=15
        check(a:SelectCurrentGuide()>1000,c.." "..f.." class catalogue")
        local hostile=f=="Alliance" and "Silverpine Forest" or "Westfall"
        local friendly=f=="Alliance" and "Westfall" or "The Barrens"
        local g=gear({route(hostile)})
        check(not a:ShouldShowOverlayAcquisition(g),"hostile leveling travel")
        check(#a:GetAcquisitionNavigationChoices(g)==1,"full guide retains travel option")
        check(a:ShouldShowOverlayAcquisition(gear({route(friendly)})),"own territory")
        check(a:ShouldShowOverlayAcquisition(gear({route("Ashenvale")})),"contested territory")
        check(a:ShouldShowOverlayAcquisition(gear({{kind="dungeon",dungeon="Shadowfang Keep",location={zone="Silverpine Forest"}}})),"dungeon exception")
        check(a:ShouldShowOverlayAcquisition(gear({route(hostile),route(friendly)})),"one reasonable route retains item")
        check(not a:ShouldShowOverlayAcquisition(gear({route(friendly,"vendor",f=="Alliance" and 2 or 1)})),"hard vendor faction restriction")
        local neutral=route(hostile,"vendor")
        check(not a:ShouldShowOverlayAcquisition(gear({neutral})),"neutral vendor can still be impractical")
        neutral.travelExempt=true
        check(a:ShouldShowOverlayAcquisition(gear({neutral})),"named neutral travel exception")
        a.db.overlay.hideImpracticalSources=false
        check(a:ShouldShowOverlayAcquisition(g),"convenience toggle")
        check(not a:ShouldShowOverlayAcquisition(gear({route(friendly,"quest",f=="Alliance" and 2 or 1)})),"toggle cannot bypass hard faction")
        a.db.overlay.hideImpracticalSources=true
        a.level=31;check(a:ShouldShowOverlayAcquisition(g),"geography relaxes with level")
    end
end
faction="Alliance";class="PRIEST";a.classToken=class;a.level=25
local quest={kind="quest",questID=9002,side=1,minimumLevel=20,oneTime=true,prerequisiteQuests={9001}}
check(not a:HasAccessibleAcquisition(gear({quest})),"known incomplete prerequisite")
done[9001]=true;check(a:HasAccessibleAcquisition(gear({quest})),"completed prerequisite")
done[9002]=true;check(not a:HasAccessibleAcquisition(gear({quest})),"one-time reward completed")
done[9002]=nil;a.level=19;check(not a:HasAccessibleAcquisition(gear({quest})),"source minimum")
check(a:HasAccessibleAcquisition(gear({quest}),"upcoming"),"next-five source minimum")
a.level=25
check(not a:HasAccessibleAcquisition(gear({{kind="quest",raceMask=4}})),"verified race mask excludes human")
check(not a:HasAccessibleAcquisition(gear({{kind="quest",reqclass=1}})),"verified class quest mask excludes priest")
C_Reputation={GetFactionDataByID=function()return{reaction=4}end}
check(not a:HasAccessibleAcquisition(gear({{kind="vendor",offer={reqfaction=1,standing=6}}})),"known vendor reputation gate")
C_Reputation=nil
check(a:HasAccessibleAcquisition(gear({{kind="vendor",offer={reqfaction=1,standing=6}}})),"unknown reputation remains qualified")
a.level=15
check(not a:ShouldShowOverlayAcquisition({itemID=999111,sourceType="World drop",zone="Silverpine Forest"}),"legacy source geography")
check(a:GetAcquisitionMapTarget({itemID=999111,sourceType="World drop",zone="Silverpine Forest"})==nil,"legacy geography cannot invent map destination")
check(a:ShouldShowOverlayAcquisition(gear({route("Zephras Isle")})),"contested new starter zone retained")
a.level=25

-- All four ordinary bag slots already meet the small craft tier: independent
-- vendor and quest upgrades must still be present. Specialty bags stay protected.
local capacities={6,6,6,6};local bagIDs={}
C_Container={GetContainerNumSlots=function(index)return capacities[index] end,
    GetContainerNumFreeSlots=function()return 0,0 end}
GetInventoryItemID=function(_,slot)return bagIDs[slot-19] end
a.GetProfessionSkill=function()return nil end
a.GetMaterialCount=function()return 0 end
local function bag(id)
    for _,r in ipairs(a:GetItems("bags")) do if r.itemID==id then return r end end
end
a.level=10;done[271]=true
check(a:GetBagUpgradePlan()==nil,"no six-slot craft upgrade")
check(bag(1537) and bag(1537).quantity==1,"independent one-copy Blanchy reward")
a.level=25
check(bag(270017) and bag(270017).bagSlots==10,"ten-slot quest upgrade")
check(bag(4245) and bag(4245).bagSlots==10,"equal-capacity craft retained")
check(bag(4498) and bag(804) and bag(3233),"vendor/world/named drops retained")
a.db.overlay.hideUncraftableCrafts=true
check(bag(270017) and bag(4245),"bags independent of personal craft filter")
local mixed=gear({{kind="craft"},route("Westfall","quest",1)})
mixed.profession="Tailoring"
check(a:ShouldDisplayCraftedGear(mixed),"unrelated quest route survives craft restriction")
local patternOnly=gear({{kind="recipe_vendor",side=2,location={zone="Durotar"}}})
patternOnly.profession="Tailoring"
check(a:HasAccessibleAcquisition(patternOnly) and a:ShouldShowOverlayAcquisition(patternOnly),"recipe faction/travel gates do not become finished-item restrictions")
done[271]=false;check(not bag(270017),"quest prerequisite applied to real bag")
done[271]=true;done[531]=true;check(not bag(270017),"completed reward not repeatable")
done[531]=false
faction="Horde";check(not bag(270017) and bag(276891),"quest bag faction routes")
faction="Alliance";check(not bag(276891),"Horde-only reward excluded")
local hunting=bag(270017)
local target=a:GetAcquisitionMapTarget(hunting)
check(target and target.zone=="Loch Modan" and target.questID==531,"bag marker points to quest giver zone")
check(a:GetAcquisitionDirections(hunting):find("Vyrin",1,true),"quest chain directions")
local seen={};for _,r in ipairs(a:GetItems("bags")) do check(not seen[r.itemID],"one card per bag");seen[r.itemID]=true end
C_Container.GetContainerNumFreeSlots=function()return 0,32 end
check(#a:GetItems("bags")==0,"specialty bags not replaced")
C_Container.GetContainerNumFreeSlots=function()return 0,0 end
capacities={20,20,20,20};check(#a:GetItems("bags")==0,"no false capacity upgrades")

-- Real replacement deltas, normalized aliases, negative tradeoffs and modes.
local stats={
    ["item:9100"]={ITEM_MOD_INTELLECT_SHORT=10,ITEM_MOD_SPELL_DAMAGE_SHORT=6},
    ["item:9101"]={ITEM_MOD_INTELLECT_SHORT=12},
    ["item:9102"]={ITEM_MOD_INTELLECT_SHORT=10,ITEM_MOD_SPELL_DAMAGE_SHORT=8},
    ["item:9103"]={ITEM_MOD_STAMINA_SHORT=10},
    ["item:9104"]={ITEM_MOD_STAMINA_SHORT=12},
    ["item:9105"]={ITEM_MOD_STAMINA_SHORT=4},
    ["item:9106"]={ITEM_MOD_STAMINA_SHORT=1},
}
local equipped={[5]="item:9100",[16]="item:9100"}
C_Item={GetItemStats=function(link)return stats[link] end,
    GetItemInventoryTypeByID=function(link)return link=="item:9100" and 17 or 13 end}
GetInventoryItemLink=function(_,slot)return equipped[slot] end
GetInventoryItemID=function()return nil end
local function item(id,slot)return{itemID=id,id="item_"..id,name="Scoring fixture",slot=slot or "Chest",targetLevel=25}end
a:InitializeStatPriorities()
check(a.db.statPriorities.mode=="balanced","balanced default")
check(not a:ShouldShowOverlayStatChanges(item(9101)),"+2 Intellect cannot offset -6 Spell Damage")
check(a:ShouldShowOverlayStatChanges(item(9102)),"net positive spell gain")
check(a:SetStatPriority("priority","SPELL_DAMAGE_TOTAL"),"priority mode")
check(a:GetWeightedUpgrade(item(9102))>4,"preferred stat has extra influence")
check(not a:ShouldShowOverlayStatChanges(item(9101)),"priority accounts for losses")
a:SetStatPriority("custom");a:SetCustomStatWeight("ITEM_MOD_INTELLECT_SHORT",10);a:SetCustomStatWeight("SPELL_DAMAGE_TOTAL",1)
check(a:ShouldShowOverlayStatChanges(item(9101)),"explicit custom tradeoff")
check(not a:SetCustomStatWeight("SPELL_DAMAGE_TOTAL",-1) and not a:SetCustomStatWeight("SPELL_DAMAGE_TOTAL",0/0)
    and not a:SetCustomStatWeight("SPELL_DAMAGE_TOTAL",math.huge) and not a:SetCustomStatWeight("FAKE_STAT",5),"invalid weights rejected")
check(a:SetCustomStatWeight("SPELL_DAMAGE_TOTAL",0),"zero weight supported")
local saved=a.db;a.db={overlay={}};a:InitializeStatPriorities();check(a.db.statPriorities.mode=="balanced","other character isolated")
a.db=saved;a:InitializeStatPriorities();check(a.db.statPriorities.weights.SPELL_DAMAGE_TOTAL==0,"preference persists")
a:SetStatPriority("balanced")
check(not a:ShouldShowOverlayStatChanges(item(9102,"Off Hand")),"potential offhand cannot independently replace two-hander")
equipped[16]="item:9103";equipped[17]="item:9103"
check(not a:ShouldShowOverlayStatChanges(item(9104,"Two-Hand Staff")),"two-hand candidate loses combined offhand stats")
equipped={};check(a:ShouldShowOverlayStatChanges(item(9102)),"confirmed empty slot")
equipped={[11]="item:9103",[12]="item:9105"}
check(a:ShouldShowOverlayStatChanges(item(9106,"Ring"))==false,"worse than both rings")
check(a:ShouldShowOverlayStatChanges(item(9103,"Ring")),"best legal ring replacement")
for _,c in ipairs(classes) do
    class=c;a.classToken=c;equipped={[5]="item:9104"}
    check(not a:ShouldShowOverlayStatChanges(item(9103)),c.." net stamina loss")
    check(a:ShouldShowOverlayStatChanges({bagUpgrade=true}),c.." bags bypass weights")
end
class="PRIEST";a.classToken=class;equipped={[5]="item:9100"}
local effect=item(9101);effect.notes="Chance on hit: a special effect."
check(a:GetWeightedUpgrade(effect)==nil and a:ShouldShowOverlayStatChanges(effect),"unquantified effect not fabricated or silently discarded")
C_TooltipInfo={GetHyperlink=function(link)return{lines={{leftText=link=="item:9100" and "Use: temporary benefit" or ""}}}end}
check(a:GetWeightedUpgrade(item(9102))==nil,"equipped unquantified use effect also protects tradeoff")
C_TooltipInfo=nil
check(a:GetWeightedUpgrade(item(999999))==nil,"uncached stats stay unknown")
local list={item(9101),item(9102)};a:SortUpgradeRecommendations(list);check(list[1].itemID==9102,"score controls ordering")
a.Gear={item(9101)};a.db.overlay.showAllValidGear=true
check(#a:GetItems("available")==1,"poor weighted choice remains in full guide")
check(not a:CanClassEquipGear({itemID=273841,slot="Two-Hand Mace",armorType="Mace"},"PRIEST"),"weights never override proficiency")
check(a.CatalogueAudit.items==7707 and a.CatalogueAudit.objectives==36669,"catalogue identities/masks unchanged")
-- Exercise real Core initialization twice, including a reload and a different
-- per-character SavedVariables table. Existing status/settings must survive.
local callback
CreateFrame=function()return {RegisterEvent=function()end,SetScript=function(_,_,fn)callback=fn end}end
SlashCmdList={}
GetGear_CharacterDB={schemaVersion=4,status={item_1="skipped"},hidden={},detail={},overlay={hideImpracticalSources=false},
    statPriorities={mode="custom",preferred="SPELL_DAMAGE_TOTAL",weights={SPELL_DAMAGE_TOTAL=4,ITEM_MOD_INTELLECT_SHORT=1}}}
assert(loadfile(root.."/Core.lua"))("GetGear",a)
callback(nil,"ADDON_LOADED","GetGear")
check(a.db.statPriorities.mode=="custom" and a.db.statPriorities.weights.SPELL_DAMAGE_TOTAL==4,"Core reload retains custom weights")
check(a.db.overlay.hideImpracticalSources==false and a.db.status.item_1=="skipped","reload retains geography and progress")
local priestDB=a.db
GetGear_CharacterDB={schemaVersion=4};class="WARRIOR"
callback(nil,"ADDON_LOADED","GetGear")
check(a.db.statPriorities.mode=="balanced" and a.db.overlay.hideImpracticalSources==true,"new character defaults")
check(priestDB.statPriorities.mode=="custom" and priestDB.statPriorities.weights.SPELL_DAMAGE_TOTAL==4,"warrior initialization cannot edit priest")
print("PASS recommendation pipeline: "..assertions.." assertions, nine classes/both factions, real bags/routes/maps, weighted replacements, settings and catalogue integrity")
