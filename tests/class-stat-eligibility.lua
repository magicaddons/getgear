-- AH2: potential class proficiency precedes relevance; source facts stay intact.
local root=arg[1] or '.';local a={}
for f in assert(io.open(root..'/GetGear.toc')):read('*a'):gmatch('[^\r\n]+')do
 if f:match('%.lua$')and f~='UI.lua'and f~='Core.lua'and f~='AltInventory.lua'then assert(loadfile(root..'/'..f))('GetGear',a)end
end
local classes={'PRIEST','MAGE','WARLOCK','DRUID','ROGUE','HUNTER','SHAMAN','WARRIOR','PALADIN'}
a.db={overlay={showAllValidGear=false,filterObsolete=false,hideWithoutPositiveStats=true},status={},hidden={}};a.level=25;a.classToken='PRIEST'
local catalogue=a.ItemCatalog
local maul=assert(catalogue[273841]);assert(maul.name=='Twilight Maul'and maul.slot=='Two-Hand Mace')
assert(not a:CanClassEquipGear(maul,'PRIEST'))
assert(a:CanClassEquipGear(catalogue[4446],'PRIEST'),'potential daggers do not depend on trained skills')
a.db.overlay.showAllValidGear=true
assert(not a:ShouldDisplayGear(maul,'PRIEST','available'),'all-valid cannot override a real class restriction')
assert(a:GetGearComparison(maul).message:find('cannot equip',1,true),'eligibility precedes live stat comparisons')
assert(a:ShouldDisplayGear(catalogue[4446],'PRIEST','available'),'all-valid retains class-equippable physical daggers')
a.db.overlay.showAllValidGear=false
local changes,maces,offhands,frills=0,0,0,0;for id,diff in pairs(a.EquipmentEligibilityCorrections)do
 changes=changes+1
 if catalogue[id].slot=='Two-Hand Mace'then maces=maces+1;assert(diff.originalMask==diff.effectiveMask+1)elseif catalogue[id].armorType=='Fist Weapon'then offhands=offhands+1;assert(catalogue[id].slot=='Off Hand'and diff.originalMask==diff.effectiveMask+8)else frills=frills+1;assert(diff.originalMask==335 and diff.effectiveMask==511 and catalogue[id].verifiedHeldClassMask==511)end
end
assert(maces==79 and offhands==7 and frills==138 and changes==224 and a.CatalogueAudit.objectives==36669)
for _,c in ipairs({'WARRIOR','ROGUE','HUNTER'})do assert(a:CanClassEquipGear(catalogue[1992],c),'unrestricted non-weapon frill is not caster-only')end
assert(a:CanClassEquipGear(catalogue[6898],'WARLOCK')and not a:CanClassEquipGear(catalogue[6898],'PRIEST'),'printed class restriction preserved')
for _,class in ipairs(classes)do
 for _,g in ipairs(a.EquipmentByClass[class])do assert(a:CanClassEquipGear(g,class),class..' illegal '..g.itemID)end
end
for _,id in ipairs({253965,7046})do
 assert(not a:ShouldDisplayGear(catalogue[id],'PRIEST','available'),'unsupported offensive school despite useful attributes: '..id)
 assert(a:ShouldDisplayGear(catalogue[id],'MAGE','available'))
end
for _,id in ipairs({4446,6220})do assert(not a:ShouldDisplayGear(catalogue[id],'PRIEST','available'),'physical dagger source classification: '..id)end
local fixture={itemID=999000,name='School fixture',slot='Ring',armorType='Jewelry',statRole='mixed',targetLevel=25,genericSpellDamage=false,explicitHealing=false}
for _,class in ipairs(classes)do
 for _,school in ipairs({'Fire','Frost','Shadow','Holy','Arcane','Nature'})do
  fixture.offensiveSchools={[school]=true}
  assert(a:HasUsableOffensiveSchool(fixture,class)==(a.ClassOffensiveSchools[class][school]==true),class..' '..school)
 end
end
fixture.offensiveSchools={Fire=true,Shadow=true};assert(a:ShouldDisplayGear(fixture,'PRIEST','available'))
fixture.offensiveSchools={Frost=true};fixture.genericSpellDamage=true;assert(a:ShouldDisplayGear(fixture,'PRIEST','available'))
fixture.genericSpellDamage=false;fixture.explicitHealing=true;assert(a:ShouldDisplayGear(fixture,'PRIEST','available'))
fixture.explicitHealing=nil;assert(a:ShouldDisplayGear(fixture,'PRIEST','available'),'incomplete school evidence remains open')
-- Runtime comparison tests: meaningful tradeoffs without a universal score.
local stats={['item:9000']={ITEM_MOD_SPIRIT_SHORT=10,ITEM_MOD_SPELL_DAMAGE_SHORT=15,ITEM_MOD_SPELL_HEALING_SHORT=15},
 ['item:9001']={ITEM_MOD_SPIRIT_SHORT=4,ITEM_MOD_SPELL_HEALING_SHORT=16},
 ['item:9002']={ITEM_MOD_SPIRIT_SHORT=10,ITEM_MOD_SPELL_HEALING_SHORT=15,ITEM_MOD_SPELL_DAMAGE_SHORT=15,RESISTANCE2_NAME=3},
 ['item:9003']={ITEM_MOD_SPIRIT_SHORT=4,RESISTANCE2_NAME=3},
 ['item:9004']={ITEM_MOD_SPIRIT_SHORT=4,ITEM_MOD_ARMOR_SHORT=50}}
for _,id in ipairs({4446,6220,4454})do stats['item:'..id]={ITEM_MOD_AGILITY_SHORT=1,ITEM_MOD_DAMAGE_PER_SECOND_SHORT=17.8,RESISTANCE2_NAME=3}end
C_Item={GetItemStats=function(link)return stats[link]end,GetItemInventoryTypeByID=function(link)return link=='item:9000'and 17 or 13 end}
GetInventoryItemLink=function(_,slot)return slot==16 and'item:9000'end
GetInventoryItemID=function()return nil end
for _,id in ipairs({4446,6220,4454})do assert(not a:ShouldShowOverlayStatChanges(catalogue[id]),'trivial physical/resistance positives do not offset caster losses '..id)end
local function sample(id)return{itemID=id,slot='Main Hand',armorType='Dagger',name='Comparison fixture'}end
assert(a:ShouldShowOverlayStatChanges(sample(9001)),'healing gain with spirit loss is still a legitimate choice')
assert(a:ShouldShowOverlayStatChanges(sample(9002)),'resistance with no meaningful loss remains a choice')
assert(not a:ShouldShowOverlayStatChanges(sample(9003)),'resistance alone cannot offset primary losses')
assert(not a:ShouldShowOverlayStatChanges(sample(9004)))
a.db.overlay.countArmorOnlyUpgrades=true;assert(a:ShouldShowOverlayStatChanges(sample(9004)));a.db.overlay.countArmorOnlyUpgrades=false
a.db.overlay.showAllValidGear=true;assert(a:ShouldShowOverlayStatChanges(catalogue[6220]));a.db.overlay.showAllValidGear=false
for _,class in ipairs(classes)do
 a.classToken=class
 local pureCaster=class=='PRIEST'or class=='MAGE'or class=='WARLOCK'
 assert(a:IsClassRelevantStat('ITEM_MOD_DAMAGE_PER_SECOND_SHORT',{slot='Main Hand'})==not pureCaster)
 assert(a:IsClassRelevantStat('ITEM_MOD_DAMAGE_PER_SECOND_SHORT',{slot='Wand'}))
 assert(a:IsClassRelevantStat('ITEM_MOD_INTELLECT_SHORT',{})==(class~='WARRIOR'and class~='ROGUE'))
end
a.classToken='PRIEST'
stats['item:13031']={ITEM_MOD_SPIRIT_SHORT=4,ITEM_MOD_SHADOW_DAMAGE_SHORT=6,ITEM_MOD_SPELL_HEALING_SHORT=9}
local orb=a:GetGearComparison(catalogue[13031]);assert(orb.groups[1].potentialOnly and orb.groups[1].comparable and not orb.groups[1].emptySlot)
assert(orb.note:find('Net replacement',1,true)and #orb.groups[1].rows==3)
assert(a:ComparisonInline(catalogue[13031]):find('Potential',1,true))
local planned=a:GetGearComparison(catalogue[13031],true,{itemID=9001,slot='Main Hand',armorType='Dagger'})
assert(#planned.groups==2 and planned.groups[2].comparable)
GetInventoryItemLink=function()return nil end
local aliases={RESISTANCE0_NAME=40,ITEM_MOD_ARMOR_SHORT=40,ITEM_MOD_SPELL_POWER_SHORT=20,
 SPELL_DAMAGE_TOTAL='unavailable',
 ITEM_MOD_SPELL_DAMAGE_DONE_SHORT=8,ITEM_MOD_SPELL_DAMAGE_SHORT=8,ITEM_MOD_SPELL_HEALING_DONE_SHORT=9,ITEM_MOD_HEALING_DONE_SHORT=9}
for i,school in ipairs({'HOLY','FIRE','NATURE','FROST','SHADOW','ARCANE'})do aliases['RESISTANCE'..i..'_NAME']=3;aliases['ITEM_MOD_'..school..'_RESISTANCE_SHORT']=3 end
stats['item:9005']=aliases
local normal=a:GetGearComparison({itemID=9005,slot='Ring'}).groups[1];assert(#normal.rows==9)
for _,r in ipairs(normal.rows)do assert(not r.key:find('RESISTANCE_SHORT',1,true));if r.key:match('^RESISTANCE[1-6]_NAME$')then assert(r.new==3)end end
a.classToken='WARRIOR'
stats['item:9006']={ITEM_MOD_DAMAGE_PER_SECOND_SHORT=20};stats['item:9007']={ITEM_MOD_DAMAGE_PER_SECOND_SHORT=15};stats['item:9008']={ITEM_MOD_DAMAGE_PER_SECOND_SHORT=25}
GetInventoryItemLink=function(_,slot)return slot==16 and'item:9006'or slot==17 and'item:9007'end
local dualCandidate={itemID=9008,slot='Two-Hand Mace',armorType='Mace'}
local dual=a:GetGearComparison(dualCandidate);assert(dual.groups[1].dpsUnknown and #dual.groups[1].rows==0,'do not add two reported weapon DPS totals and claim actual dual-wield combat performance')
assert(a:ShouldShowOverlayStatChanges(dualCandidate),'unknown set DPS is not proof of no possible weapon improvement')
print('PASS AH2:7707items/36669legal objectives/224audited item masks/nine-class schools/meaningful stats/aliases/explicit offhand planning;client rendering untested')
