-- Preserve good saved identity across transient login/logout API failures.
local root=arg[1]or'.';local frames={}
CreateFrame=function()local f={events={}};frames[#frames+1]=f
 function f:RegisterEvent(e)self.events[e]=true end
 function f:SetScript(_,fn)self.fn=fn end
 return f end
UnitName=function()return'Alice'end;GetRealmName=function()return'Moon Guard'end
UnitFactionGroup=function()return'Alliance'end
GetRealmID=function()return 123 end;UnitGUID=function()return'Player-123-Alice'end
C_Container={GetContainerNumSlots=function(id)return id==0 and 1 or 0 end,
 GetContainerItemInfo=function()return{itemID=2589,stackCount=3}end}
local a={};assert(loadfile(root..'/AltInventory.lua'))('GetGear',a)
a.AltInventory:Initialize();local c=GetGear_AccountDB.characters['Moon Guard:Alice']
c.bank={[2589]=17};c.bankAt=20
UnitFactionGroup=function()return nil end;GetRealmID=function()error('not ready')end;UnitGUID=function()return nil end
for _,f in ipairs(frames)do if f.events.PLAYER_LOGOUT then f.fn(f,'PLAYER_LOGOUT')end end
assert(c.faction=='Alliance','transient logout API erased known faction: '..tostring(c.faction))
assert(c.realmID==123 and c.guid=='Player-123-Alice' and c.bank[2589]==17 and c.bankAt==20)
local rows=a.AltInventory:BrowseItems('eligible');assert(#rows==0,'unknown live faction must not imply transferability')
UnitName=function()return'Bob'end;UnitFactionGroup=function()return'Alliance'end
GetRealmID=function()return'123'end;UnitGUID=function()return'Player-123-Bob'end
a.AltInventory:Initialize()
rows=a.AltInventory:BrowseItems('alts');assert(#rows==1 and rows[1].total==20)
print('PASS inventory identity preservation: transient logout API cannot erase known faction/realm ID/GUID/bank; recorded alt reappears on next character without bank visit')
