-- Offline event regression for the GetGear login-freeze guard.
local root=(arg and arg[1]) or "."
local addon={db={}}
local queue, requests = {}, {}
local now=100
GetTime=function() return now end
C_Timer={After=function(delay,callback)
    assert(delay>=0.4)
    queue[#queue+1]={delay=delay,callback=callback}
end}
C_Item={RequestLoadItemDataByID=function(id)
    requests[id]=(requests[id] or 0)+1
    if id==777 then error("simulated unavailable ID") end
    return true
end}
local refreshes=0
addon.RefreshAll=function(self)
    refreshes=refreshes+1
    if refreshes==1 then
        assert(self:RequestItemDataOnce(900))
        self:OnItemDataLoadResult(900,true)
    end
end
assert(loadfile(root.."/ItemData.lua"))("GetGear",addon)
assert(not addon:RequestItemDataOnce(-1))
assert(addon:RequestItemDataOnce(123))
for i=1,100 do assert(not addon:RequestItemDataOnce(123)) end
assert(requests[123]==1)
addon:OnItemDataLoadResult(123,false)
addon:OnItemDataLoadResult(123,true)
addon:OnItemDataLoadResult(456,true)
assert(#queue==0, "failure or foreign event triggered redraw")
assert(not addon:RequestItemDataOnce(777))
assert(not addon:RequestItemDataOnce(777))
assert(requests[777]==1)
for id=1000,1050 do
    assert(addon:RequestItemDataOnce(id))
    addon:OnItemDataLoadResult(id,true)
end
assert(#queue==1,"burst not coalesced")
table.remove(queue,1).callback()
assert(refreshes==1 and #queue==1,"refresh must not recurse")
local deferred=table.remove(queue,1)
assert(deferred.delay>=0.99,"refreshes should be rate limited")
now=now+deferred.delay
deferred.callback()
assert(refreshes==2 and #queue==0)
for i=1,500 do addon:OnItemDataLoadResult(i,true) end
assert(#queue==0,"repeated results triggered refresh")
local events={}
local frame
CreateFrame=function()
    frame={RegisterEvent=function(_,e)events[e]=true end}
    function frame:SetScript(name,callback) self[name]=callback end
    return frame
end
SlashCmdList={}
UnitLevel=function()return 7 end
local bags=0
addon.OnInventoryUpdated=function()bags=bags+1 end
assert(loadfile(root.."/Core.lua"))("GetGear",addon)
assert(events.ITEM_DATA_LOAD_RESULT)
frame.OnEvent(frame,"ADDON_LOADED","GetGear")
frame.OnEvent(frame,"ITEM_DATA_LOAD_RESULT",999,true)
assert(#queue==0)
frame.OnEvent(frame,"BAG_UPDATE_DELAYED")
assert(bags==1)
assert(addon:RequestItemDataOnce(1051))
frame.OnEvent(frame,"ITEM_DATA_LOAD_RESULT",1051,true)
assert(#queue==1)
table.remove(queue,1).callback()
assert(bags==1 and refreshes==3)
print("PASS: guarded item events, bounded retries, delayed refresh, bag event independent")
