local addonName, GetGear = ...

-- Avoid feedback loops from item-data callbacks while retaining lazy tooltips.
-- Only refresh for item IDs explicitly requested by GetGear this session.
local requested, pending = {}, {}
local scheduled, running, dirty = false, false, false
local lastRun
local function Clock()
    if type(GetTime)=="function" then
        local n=GetTime()
        if type(n)=="number" then return n end
    end
end
local Schedule
Schedule=function()
    if not dirty or scheduled or running then return end
    if not (C_Timer and type(C_Timer.After)=="function") then return end
    local delay=0.4
    local now=Clock()
    if now and lastRun then delay=math.max(delay, 1-(now-lastRun)) end
    scheduled=true
    C_Timer.After(delay,function()
        scheduled=false
        if not dirty or not GetGear.db or running then return end
        dirty=false
        running=true
        lastRun=Clock()
        local ok,err=pcall(function()
            if GetGear.RefreshAll then GetGear:RefreshAll() end
        end)
        running=false
        if dirty then Schedule() end
        if not ok then error(err) end
    end)
end

function GetGear:RequestItemDataOnce(itemID)
    if type(itemID)~="number" or itemID<=0 or itemID%1~=0 then return false end
    if requested[itemID] then return false end
    if not (C_Item and type(C_Item.RequestLoadItemDataByID)=="function") then return false end
    requested[itemID]=true
    pending[itemID]=true
    local ok,result=pcall(C_Item.RequestLoadItemDataByID,itemID)
    if not ok or result==false then pending[itemID]=nil;return false end
    return true
end

function GetGear:OnItemDataLoadResult(itemID,success)
    if type(itemID)~="number" or not pending[itemID] then return end
    pending[itemID]=nil
    if success==false or not self.db then return end
    dirty=true
    Schedule()
end
