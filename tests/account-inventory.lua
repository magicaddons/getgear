-- Last-known bag/bank truth, failure preservation and faction/realm isolation.
local root=arg[1]or'.';local frames={};local queue={};local stamp=100
CreateFrame=function()local f={events={}};frames[#frames+1]=f
 function f:RegisterEvent(e)self.events[e]=true end
 function f:SetScript(_,fn)self.callback=fn end
 return f end
local function event(e)for _,f in ipairs(frames)do if f.events[e]then f.callback(f,e)end end end
C_Timer={After=function(_,fn)queue[#queue+1]=fn end}
local function flush()while #queue>0 do local fn=table.remove(queue,1);fn()end end
UnitName=function()return'Alice'end;GetRealmName=function()return'Realm'end
UnitFactionGroup=function()return'Alliance'end;time=function()return stamp end
Enum={BagIndex={ReagentBag=5,CharacterBankTab_1=6,CharacterBankTab_2=7},BankType={Character=0}}
C_Bank={FetchPurchasedBankTabData=function()return{{},{}}end}
local broken,unloaded,empty=false,false,false
C_Container={GetContainerNumSlots=function(id)if unloaded then return 0 end;return id>=6 and 10 or 4 end,
 GetContainerItemInfo=function(id,slot)
  if broken then error('asynchronous container unavailable')end
  if not empty and slot==1 then return{itemID=id>=6 and 2840 or 2589,stackCount=id>=6 and 7 or 2}end
 end}
local a={};assert(loadfile(root..'/AltInventory.lua'))('GetGear',a)
a.GetMaterialCount=function()return nil end
a.AltInventory:Initialize();local db=GetGear_AccountDB
local c=db.characters['Realm:Alice'];assert(c.bags[2589]==12 and c.bagsAt==100 and not c.bankAt)
assert(not a.AltInventory:ScanBank(),'closed bank must not be scanned')
event('BANKFRAME_OPENED');flush();assert(c.bank[2840]==14 and c.bankAt==100 and c.bankTabCount==2 and not c.bankPartial)
local bags,bank=c.bags,c.bank;stamp=200;broken=true
assert(not a.AltInventory:ScanBags()and c.bags==bags and c.bagsAt==100)
assert(not a.AltInventory:ScanBank()and c.bank==bank and c.bankAt==100)
broken=false;unloaded=true
assert(not a.AltInventory:ScanBags()and c.bags==bags)
assert(not a.AltInventory:ScanBank()and c.bank==bank)
unloaded=false;empty=true
assert(a.AltInventory:ScanBags()and next(c.bags)==nil and c.bagsAt==200,'a readable empty bag is a real snapshot')
assert(a.AltInventory:ScanBank()and next(c.bank)==nil and c.bankAt==200)
event('BANKFRAME_CLOSED');assert(not a.AltInventory:ScanBank())
db.characters['Realm:Bob']={name='Bob',realm='Realm',faction='Alliance',bags={[2589]=5},bank={[2589]=3}}
db.characters['Realm:Enemy']={name='Enemy',realm='Realm',faction='Horde',bags={[2589]=11},bank={}}
db.characters['Other:Alice']={name='Alice',realm='Other',faction='Alliance',bags={[2589]=13},bank={}}
c.bags={[2589]=12};c.bank={[2589]=7}
local sum=a:GetAltMaterialSummary(2589)
assert(sum.bags==12 and sum.bank==7 and sum.alts==8 and sum.other==24 and sum.total==27)
assert(sum.bankKnown and #sum.details==3 and sum.details[1].name=='Bob'and sum.details[1].transferable)
-- Closing before delayed opening scans cannot overwrite the retained bank.
event('BANKFRAME_OPENED');event('BANKFRAME_CLOSED')
-- The close fallback is allowed to read the open bank; delayed callbacks must
-- be no-ops after closure, including when APIs later become unavailable.
local closed=c.bank;broken=true;flush();assert(c.bank==closed)
assert(GetGear_AccountDB==db and not GetGear_CharacterDB,'ledger must remain independent of character settings')
print('PASS account inventory: readable/empty/unavailable bags and purchased bank tabs, stale snapshots preserved, bank closure and delayed scans, realm/faction totals, account persistence; synthetic only')
