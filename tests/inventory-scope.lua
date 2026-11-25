-- Scope/metadata regression against the real ledger; no collection API required.
local root=arg[1]or'.'
CreateFrame=function()return{RegisterEvent=function()end,SetScript=function()end}end
local player,realm,faction='Alice',"Moon Guard",'Alliance'
UnitName=function()return player end
GetRealmName=function()return realm end
GetNormalizedRealmName=function()return'MoonGuard'end
UnitFactionGroup=function()return faction end
GetRealmID=function()return 123 end
UnitGUID=function()return'Player-123-'..player end
local a={GetMaterialCount=function()return nil end}
GetGear_AccountDB={characters={
 ['Moon Guard:Alice']={name='Alice',realm='Moon Guard',faction='Alliance',bags={[2589]=1}},
 ['MoonGuard:Bob']={name='Bob',realm='MoonGuard',faction='Alliance',bank={[2589]=2}},
 ['Moon Guard:Enemy']={name='Enemy',realm='Moon Guard',faction='Horde',bags={[2589]=4}},
 ['Elsewhere:Friend']={name='Friend',realm='Elsewhere',faction='Alliance',bags={[2589]=8}},
 ['Elsewhere:Enemy']={name='Enemy',realm='Elsewhere',faction='Horde',bags={[2589]=16}},
 ['Moon Guard:Legacy']={faction='Alliance',bank={[2589]=32}},
 ['Moon Guard:Unknown']={name='Unknown',realm='Moon Guard',bank={[2589]=64}},
}}
assert(loadfile(root..'/AltInventory.lua'))('GetGear',a)
a.AltInventory:Initialize()
local function count(scope,expected,characters)
 local rows,meta=a.AltInventory:BrowseItems(scope,'2589')
 assert((expected==0 and #rows==0) or (#rows==1 and rows[1].total==expected),scope..' expected '..expected..' got '..tostring(rows[1]and rows[1].total))
 assert(#meta.characters==characters,scope..' character count')
 return rows,meta
end
count('eligible',35,3);count('current',1,1);count('alts',34,2)
count('other',92,4);count('all',127,7);count('Moon Guard:Unknown',64,1)
assert(a:GetAltMaterialSummary(2589).alts==34,'tooltip/browser must agree')
local rows,meta=a.AltInventory:BrowseItems('all','linen');assert(#rows==0)
-- Realm formatting, canonical faction tokens and explicit realm IDs.
local db=GetGear_AccountDB
for _,value in ipairs({' moon guard ',"Moon-Guard","Moon'Guard",'MOONGUARD'})do
 db.characters['MoonGuard:Bob'].realm=value
 count('eligible',35,3)
end
db.characters['MoonGuard:Bob'].realm='Renamed';db.characters['MoonGuard:Bob'].realmID=123
count('eligible',35,3)
db.characters['MoonGuard:Bob'].realmID=999
count('eligible',33,2)
db.characters['MoonGuard:Bob'].realm='Moon Guard';count('eligible',33,2)
db.characters['MoonGuard:Bob'].realmID=123;db.characters['MoonGuard:Bob'].faction=' alliance '
count('eligible',35,3)
-- Unknown/unknown must never be transferable, including a temporarily unavailable API.
faction=nil;count('eligible',0,0)
faction='Horde';count('eligible',4,1)
faction='Alliance'
-- Migration is additive and idempotent. Missing fields recover from the old key;
-- faction must come from evidence, never from the current player's faction.
local saved=GetGear_AccountDB.characters['Moon Guard:Legacy']
assert(saved.name=='Legacy' and saved.realm=='Moon Guard' and saved.bank[2589]==32)
local unknown=db.characters['Moon Guard:Unknown'];assert(unknown.faction==nil)
local unknownBank=unknown.bank
assert(db.inventorySchemaVersion==2)
a.AltInventory:Initialize();count('eligible',35,3)
assert(unknown.bank==unknownBank and not unknown.faction)
-- Equivalent keys: newer bag and older bank may reside on different aliases.
db.characters={
 ['Moon Guard:Alice']={bags={[2589]=1},bagsAt=20,faction='Alliance',bank={[2589]=9},bankAt=50},
 ['MoonGuard:Alice']={bags={[2589]=5},bagsAt=30,faction='Alliance',bank={[2589]=3},bankAt=40},
}
a.AltInventory:Initialize()
count('eligible',14,1);count('current',14,1)
local before=a.AltInventory:BrowseItems('all')[1].total
a.AltInventory:Initialize();assert(a.AltInventory:BrowseItems('all')[1].total==before)
-- Reload with a changed display realm reuses the existing record and bank.
realm='MoonGuard';a.AltInventory:Initialize();count('current',14,1)
assert(db.characters['Moon Guard:Alice'].bank[2589]==9)
-- Actual player switching attributes only newly collected inventory to the player.
player='Bob';a.AltInventory:Initialize()
local bob=db.characters['MoonGuard:Bob'];assert(bob and bob~=db.characters['Moon Guard:Alice'])
assert(db.characters['Moon Guard:Alice'].bank[2589]==9 and bob.faction=='Alliance' and bob.realmID==123)
player='Alice';realm='Moon Guard'
-- Same name/realm with conflicting GUIDs is not automatically merged or counted
-- as transferable, and scans must not overwrite either record.
db.characters={
 ['Moon Guard:Alice']={faction='Alliance',guid='Player-123-old',bank={[2589]=4}},
 ['MoonGuard:Alice']={faction='Alliance',guid='Player-123-new',bank={[2589]=8}},
}
a.AltInventory:Initialize();count('all',12,2);count('eligible',0,0)
assert(db.characters['Moon Guard:Alice'].guid=='Player-123-old')
local _,meta=a.AltInventory:BrowseItems('eligible');assert(meta.unresolvedCharacters==2)
-- Numeric realm IDs exposed by Forever/modern APIs, GUID fallback and transient APIs.
GetRealmName=function()return nil end;GetRealmID=nil
GetNormalizedRealmName=function()return'MoonGuard'end
UnitGUID=function()return'Player-123-current'end
db.characters={['MoonGuard:Alice']={faction='Alliance',bank={[2589]=4}}}
a.AltInventory:Initialize();count('eligible',4,1)
assert(db.characters['MoonGuard:Alice'].realmID==123)
-- Offline records with a numeric realm value alone are not a realm-name match.
db.characters['123:NoEvidence']={realm=123,faction='Alliance',bank={[2589]=2}}
count('eligible',4,1)
GetNormalizedRealmName=function()return nil end
UnitFullName=function()return'Alice','MoonGuard'end
count('eligible',4,1)
-- Unknown faction on both sides must not produce an equality match.
UnitFactionGroup=function()return nil end
db.characters['MoonGuard:Alice'].faction=nil;count('eligible',0,0)
print('PASS inventory scope: realm/faction matrix, formatting, realm IDs/GUIDs, key recovery, unknown identity, alias reconciliation, storage timestamps, switching/reload and preservation; synthetic only')
-- Current login repairs stale faction without needing another bank visit.
UnitFactionGroup=function()return'Alliance'end
db.characters={['MoonGuard:Alice']={faction='Horde',bank={[2589]=7},bankAt=10}}
a.AltInventory:Initialize();count('eligible',7,1)
assert(db.characters['MoonGuard:Alice'].bankAt==10)
-- Localized faction labels are accepted only when the client supplies the label.
FACTION_ALLIANCE='Alliance locale';db.characters['MoonGuard:Locale']={faction=FACTION_ALLIANCE,bank={[2589]=3}}
count('eligible',10,2)
C_Item={GetItemNameByID=function(id)return id==2589 and'Linen Cloth'end}
local named=a.AltInventory:BrowseItems('eligible','LINEN');assert(#named==1 and named[1].total==10)
assert(#named[1].locations==2 and named[1].bags==0 and named[1].bank==10)
-- An ambiguous three-member group must not merge before finding a contradiction.
db.characters={
 ['Moon Guard:Ghost']={faction='Alliance',guid='Player-123-old',bank={[2589]=1}},
 ["Moon'Guard:Ghost"]={faction='Alliance',bank={[2589]=2}},
 ['MoonGuard:Ghost']={faction='Alliance',guid='Player-123-new',bank={[2589]=4}},
}
a.AltInventory:Initialize();count('all',7,4);count('eligible',0,1)
-- The current record has no inventory but remains an eligible known character.
print('PASS additional inventory identity: stale current faction repair, localized API evidence, item-name search/locations, ambiguous three-way aliases')
-- Real collection during switching/reload must only replace the current bags.
local quantity=3
C_Container={GetContainerNumSlots=function(id)return id==0 and 1 or 0 end,
 GetContainerItemInfo=function()return{itemID=2589,stackCount=quantity}end}
db.characters={};player='Alice';a.AltInventory:Initialize()
local alice=db.characters['MoonGuard:Alice'];assert(alice.bags[2589]==3)
alice.bank={[2589]=99};alice.bankAt=20
player='Bob';quantity=5;a.AltInventory:Initialize()
assert(db.characters['MoonGuard:Bob'].bags[2589]==5 and alice.bags[2589]==3 and alice.bank[2589]==99)
player='Alice';quantity=7
local reloaded={GetMaterialCount=function()return nil end}
assert(loadfile(root..'/AltInventory.lua'))('GetGear',reloaded);reloaded.AltInventory:Initialize()
assert(alice.bags[2589]==7 and alice.bank[2589]==99 and alice.bankAt==20)
assert(db.characters['MoonGuard:Bob'].bags[2589]==5)
print('PASS collected inventory attribution: two characters, module reload, retained offline bags/bank and independent latest current bags')
-- A newer partial alias cannot replace a complete known bank.
C_Container=nil;player='Alice';db.characters={
 ['Moon Guard:Alice']={faction='Alliance',bank={[2589]=99},bankAt=10},
 ['MoonGuard:Alice']={faction='Alliance',bank={[2589]=3},bankAt=20,bankPartial=true},
}
a.AltInventory:Initialize();count('current',99,1)
assert(db.characters['MoonGuard:Alice'].bank[2589]==3,'partial evidence must remain preserved')
print('PASS bank alias completeness: retained complete snapshot and original partial evidence')
-- Simulate SavedVariables serialization/restart, rather than just module reuse.
local function serialize(value)
 if type(value)=='table'then
  local parts={'{'}
  for k,v in pairs(value)do parts[#parts+1]='['..serialize(k)..']='..serialize(v)..','end
  parts[#parts+1]='}';return table.concat(parts)
 elseif type(value)=='string'then return string.format('%q',value)
 else return tostring(value)end
end
local serialized=serialize(db)
GetGear_AccountDB=assert(load('return '..serialized))()
local restarted={GetMaterialCount=function()return nil end}
assert(loadfile(root..'/AltInventory.lua'))('GetGear',restarted);restarted.AltInventory:Initialize()
local items=restarted.AltInventory:BrowseItems('current','2589')
assert(#items==1 and items[1].bank==99)
assert(GetGear_AccountDB.inventorySchemaVersion==2)
local oldPartial=GetGear_AccountDB.characters['MoonGuard:Alice'];assert(oldPartial.bank[2589]==3 and oldPartial.inventoryAliasOf)
print('PASS serialized restart: schema, alias keys, original evidence and complete bank survive independent table deserialization')
-- An ID-less alias cannot be assigned to either of two conflicting realm IDs.
GetGear_AccountDB.characters={
 ['Moon Guard:Ghost']={faction='Alliance',realmID=123,bank={[2589]=1}},
 ["Moon'Guard:Ghost"]={faction='Alliance',bank={[2589]=2}},
 ['MoonGuard:Ghost']={faction='Alliance',realmID=999,bank={[2589]=4}},
}
restarted.AltInventory:Initialize()
local scoped=restarted.AltInventory:BrowseItems('eligible')
assert(#scoped==1 and scoped[1].bank==1)
local ambiguous=GetGear_AccountDB.characters["Moon'Guard:Ghost"]
assert(ambiguous.inventoryIdentityConflict and not ambiguous.inventoryAliasOf and not ambiguous.realmID)
print('PASS ambiguous realm-ID alias: known IDs stay distinct; ID-less evidence is retained without attribution')
-- Character-name casing must use the same identity rule as alias reconciliation.
GetGear_AccountDB.characters={['MoonGuard:alice']={faction='Alliance',bank={[2589]=11}}}
restarted.AltInventory:Initialize()
local currentItems,currentMeta=restarted.AltInventory:BrowseItems('current')
assert(#currentItems==1 and currentItems[1].bank==11 and #currentMeta.characters==1)
assert(not GetGear_AccountDB.characters['MoonGuard:Alice'],'case-only identity created a duplicate')
print('PASS character name casing: current identity reuses the same case-insensitive primary as migration')
