-- Fixed clean-metadata workload also runs against the pre-fix runtime.
local root=arg[1]or'.'
CreateFrame=function()return{RegisterEvent=function()end,SetScript=function()end}end
UnitName=function()return'Player'end;GetRealmName=function()return'Realm'end
UnitFactionGroup=function()return'Alliance'end
local reads=0
C_Container={GetContainerNumSlots=function()reads=reads+1;return 0 end,GetContainerItemInfo=function()reads=reads+1 end}
GetGear_AccountDB={characters={}}
for i=1,50 do
 local name=i==1 and'Player'or'Alt'..i
 local realm=i%3==0 and'Other'or'Realm'
 local faction=i%2==0 and'Horde'or'Alliance'
 local bags,bank={},{}
 for id=1,50 do bags[2000+id]=i;bank[2000+id]=2*i end
 GetGear_AccountDB.characters[realm..':'..name]={name=name,realm=realm,faction=faction,bags=bags,bank=bank,bagsAt=10,bankAt=20}
end
local addon={};assert(loadfile(root..'/AltInventory.lua'))('GetGear',addon)
local t=os.clock();addon.AltInventory:Initialize();local initialization=os.clock()-t
reads=0
local scopes={'eligible','current','alts','other','all'}
collectgarbage('collect');local memory=collectgarbage('count');t=os.clock()
for i=1,200 do
 local rows,meta=addon.AltInventory:BrowseItems(scopes[(i-1)%5+1],'')
 assert(#rows==50 and #meta.characters>0)
end
local elapsed=os.clock()-t
collectgarbage('collect');local retained=collectgarbage('count')-memory
assert(reads==0,'display scope changes scanned containers')
print(string.format('MEASURE inventory scope: 50 characters x 50 item IDs; 200 switches; initialize %.6fs; browse %.6fs; retained heap %.2fKiB; container reads %d (synthetic)',initialization,elapsed,retained,reads))
