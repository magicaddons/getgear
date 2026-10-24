local addonName, GetGear = ...

-- Account-wide, last-known material ledger. Never touches per-character
-- GetGear_CharacterDB, and never counts a bank we have not actually scanned.
-- Forever 1.60.1 uses purchased character bank tabs (not Classic 5-11 bags).
local Ledger = {}
GetGear.AltInventory = Ledger
local bankOpen = false
local bankSessionScanned = false

local function Clock()
    if type(time)=="function" then return time() end
    if type(GetServerTime)=="function" then return GetServerTime() end
    return 0
end

local function Identity()
    local name = type(UnitName)=="function" and UnitName("player") or nil
    local realm = type(GetRealmName)=="function" and GetRealmName() or nil
    if not name or name=="" or not realm or realm=="" then return nil end
    local faction=type(UnitFactionGroup)=="function" and UnitFactionGroup("player") or "Unknown"
    return realm .. ":" .. name, name, realm, faction
end

local function Current()
    local key,name,realm,faction=Identity()
    local db=GetGear_AccountDB
    if not key or type(db)~="table" or type(db.characters)~="table" then return nil end
    local c=db.characters[key]
    if type(c)~="table" then
        c={name=name,realm=realm,faction=faction}
        db.characters[key]=c
    end
    c.name=name; c.realm=realm; c.faction=faction
    return c,key
end

local function ReadBag(id)
    if not (C_Container and type(C_Container.GetContainerNumSlots)=="function"
        and type(C_Container.GetContainerItemInfo)=="function") then return nil end
    local ok,n=pcall(C_Container.GetContainerNumSlots,id)
    if not ok or type(n)~="number" or n<0 then return nil end
    local items={}
    for slot=1,n do
        local valid,info=pcall(C_Container.GetContainerItemInfo,id,slot)
        if not valid then return nil end -- preserve previous valid snapshot
        if type(info)=="table" and type(info.itemID)=="number" then
            local quantity=tonumber(info.stackCount) or 1
            if quantity>0 then items[info.itemID]=(items[info.itemID] or 0)+quantity end
        end
    end
    return items,n
end

local function Stamp(at)
    if type(at)=="number" and at>0 and type(date)=="function" then
        return date("%d %b %H:%M",at)
    end
    return "never"
end

local function Merge(target,source)
    for id,count in pairs(source) do target[id]=(target[id] or 0)+count end
end

function Ledger:ScanBags()
    local c=Current()
    if not c then return false end
    local ids={0,1,2,3,4}
    if Enum and Enum.BagIndex and Enum.BagIndex.ReagentBag then
        ids[#ids+1]=Enum.BagIndex.ReagentBag
    else
        ids[#ids+1]=5
    end
    local totals={}
    local backpackSeen=false
    for _,id in ipairs(ids) do
        local items,slots=ReadBag(id)
        if items then
            if id==0 and slots>0 then backpackSeen=true end
            Merge(totals,items)
        elseif id==0 then
            return false
        end
    end
    if not backpackSeen then return false end -- bags not loaded yet
    c.bags=totals
    c.bagsAt=Clock()
    return true
end

local function PurchasedTabs()
    local result={}
    local known=false
    if not (Enum and Enum.BagIndex) then return result,known end
    local purchased=nil
    if C_Bank and type(C_Bank.FetchPurchasedBankTabData)=="function"
        and Enum.BankType and Enum.BankType.Character~=nil then
        local ok,tabdata=pcall(C_Bank.FetchPurchasedBankTabData,Enum.BankType.Character)
        if ok and type(tabdata)=="table" then purchased=#tabdata;known=true end
    end
    -- Enum keys, not hardcoded numeric slots: the account-bank range differs
    -- from modern Retail and must never be accidentally scanned as personal.
    for i=1,9 do
        local id=Enum.BagIndex["CharacterBankTab_"..i]
        if id and (purchased==nil or i<=purchased) then result[#result+1]=id end
    end
    return result,known
end

function Ledger:ScanBank()
    if not bankOpen then return false end
    local c=Current()
    if not c then return false end
    local tabs,known=PurchasedTabs()
    local totals={}
    local readable=0
    for _,id in ipairs(tabs) do
        local items,n=ReadBag(id)
        if not items then return false end
        if n>0 then readable=readable+1 end
        Merge(totals,items)
    end
    -- An opening bank can initially return zero slots while tabs load.
    -- No successful tab scan => never erase the last known bank snapshot.
    if readable==0 then return false end
    c.bank=totals
    c.bankAt=Clock()
    c.bankTabCount=readable
    c.bankPartial=not known or readable<#tabs
    bankSessionScanned=true
    if GetGear.IsUIShown and GetGear:IsUIShown() and GetGear.RefreshUI then GetGear:RefreshUI() end
    return true
end

function Ledger:Initialize()
    if type(GetGear_AccountDB)~="table" then GetGear_AccountDB={} end
    if type(GetGear_AccountDB.characters)~="table" then GetGear_AccountDB.characters={} end
    self:ScanBags()
end

-- Amounts are last-known and indicate possible transfers, not guaranteed
-- tradeability. Never add another realm or faction to transferable totals.
function GetGear:GetAltMaterialSummary(itemID)
    local c,key=Current()
    if not c then return nil end
    local bagCount=self:GetMaterialCount(itemID)
    if type(bagCount)~="number" then bagCount=c.bags and (c.bags[itemID] or 0) or nil end
    local ownBank=(type(c.bank)=="table") and (c.bank[itemID] or 0) or 0
    local alts,other,details=0,0,{}
    for otherKey,record in pairs(GetGear_AccountDB.characters) do
        if otherKey~=key and type(record)=="table" then
            local bags=type(record.bags)=="table" and (record.bags[itemID] or 0) or 0
            local bank=type(record.bank)=="table" and (record.bank[itemID] or 0) or 0
            if bags+bank>0 then
                local same=(record.realm==c.realm and record.faction==c.faction)
                if same then alts=alts+bags+bank else other=other+bags+bank end
                details[#details+1]={name=record.name or otherKey,realm=record.realm,
                    bags=bags,bank=bank,bankAt=record.bankAt,bagsAt=record.bagsAt,
                    transferable=same}
            end
        end
    end
    table.sort(details,function(a,b)
        if a.transferable~=b.transferable then return a.transferable end
        return (a.name or "")<(b.name or "")
    end)
    return {bags=bagCount,bank=ownBank,bankKnown=c.bankAt~=nil,
        bankAt=c.bankAt,alts=alts,other=other,details=details,
        total=(bagCount or 0)+ownBank+alts,characters=GetGear_AccountDB.characters}
end

-- Inventory browser: keep presentation separate from last-known snapshots.
-- Reading this data never touches per-character checklist state.
local requestedInventoryNames={}
local function InventoryItemName(id)
    local name
    if C_Item and type(C_Item.GetItemNameByID)=="function" then
        local ok,result=pcall(C_Item.GetItemNameByID,id)
        if ok and type(result)=="string" and result~="" then name=result end
    end
    if not name and type(GetItemInfo)=="function" then
        local ok,result=pcall(GetItemInfo,id)
        if ok and type(result)=="string" and result~="" then name=result end
    end
    if not name and GetGear.MaterialNames then name=GetGear.MaterialNames[id] end
    if not name and not requestedInventoryNames[id] and C_Item
        and type(C_Item.RequestLoadItemDataByID)=="function" then
        requestedInventoryNames[id]=true
        pcall(C_Item.RequestLoadItemDataByID,id)
    end
    if not name then name="Item #"..tostring(id) end
    return name
end

function Ledger:BrowserCharacters()
    local currentKey,currentName,currentRealm,currentFaction=Identity()
    local records=GetGear_AccountDB and GetGear_AccountDB.characters or {}
    local result={}
    for key,c in pairs(records) do
        if type(c)=="table" then
            result[#result+1]={key=key,name=c.name or key,realm=c.realm or "Unknown",
                faction=c.faction or "Unknown",current=key==currentKey,
                eligible=c.realm==currentRealm and c.faction==currentFaction,
                bagsKnown=type(c.bags)=="table",bankKnown=type(c.bank)=="table",
                bagsAt=c.bagsAt,bankAt=c.bankAt,bankPartial=c.bankPartial,
                bankTabCount=c.bankTabCount}
        end
    end
    table.sort(result,function(a,b)
        if a.current~=b.current then return a.current end
        if a.eligible~=b.eligible then return a.eligible end
        if a.realm~=b.realm then return a.realm<b.realm end
        return a.name<b.name
    end)
    return result
end

-- Scope: eligible/current/alts/other/all or a character's ledger key.
-- 'eligible' deliberately excludes other realms/factions from combined totals.
function Ledger:BrowseItems(scope,query)
    local chars=self:BrowserCharacters()
    local items,selected={},{}
    local records=GetGear_AccountDB and GetGear_AccountDB.characters or {}
    local all=(scope=="all")
    local unknownBanks,unknownBags,partialBanks=0,0,0
    for _,c in ipairs(chars) do
        local include=(scope=="eligible" and c.eligible)
            or (scope=="current" and c.current)
            or (scope=="alts" and c.eligible and not c.current)
            or (scope=="other" and not c.eligible)
            or all or (scope==c.key)
        if include then
            selected[#selected+1]=c
            if not c.bankKnown then unknownBanks=unknownBanks+1 end
            if not c.bagsKnown then unknownBags=unknownBags+1 end
            if c.bankPartial then partialBanks=partialBanks+1 end
            local record=records[c.key]
            local function Add(source,field)
                if type(source)~="table" then return end
                for id,n in pairs(source) do
                    if type(id)=="number" and type(n)=="number" and n>0 then
                        local entry=items[id]
                        if not entry then
                            entry={itemID=id,bags=0,bank=0,locations={}}
                            items[id]=entry
                        end
                        entry[field]=entry[field]+n
                        local loc=entry.locations[c.key]
                        if not loc then
                            loc={name=c.name,realm=c.realm,faction=c.faction,
                                key=c.key,current=c.current,eligible=c.eligible,
                                bags=0,bank=0,bagsAt=c.bagsAt,bankAt=c.bankAt,
                                bankKnown=c.bankKnown,bankPartial=c.bankPartial}
                            entry.locations[c.key]=loc
                        end
                        loc[field]=loc[field]+n
                    end
                end
            end
            Add(record.bags,"bags")
            Add(record.bank,"bank")
        end
    end
    query=tostring(query or ""):lower()
    local results={}
    for id,entry in pairs(items) do
        entry.name=InventoryItemName(id)
        entry.total=entry.bags+entry.bank
        if query=="" or entry.name:lower():find(query,1,true)
            or tostring(id):find(query,1,true) then
            local locations={}
            for _,loc in pairs(entry.locations) do locations[#locations+1]=loc end
            table.sort(locations,function(a,b)
                if a.current~=b.current then return a.current end
                if a.eligible~=b.eligible then return a.eligible end
                return a.name<b.name
            end)
            entry.locations=locations
            results[#results+1]=entry
        end
    end
    table.sort(results,function(a,b)
        local an,bn=a.name:lower(),b.name:lower()
        if an~=bn then return an<bn end
        return a.itemID<b.itemID
    end)
    return results,{characters=selected,missingBanks=unknownBanks,
        missingBags=unknownBags,partialBanks=partialBanks,
        eligibleOnly=not all and scope~="other",totalInScope=#results}
end

function Ledger:FormatScanTime(value)
    return Stamp(value)
end

function GetGear:AppendAltMaterialTooltip(tooltip,itemID,required)
    local s=self:GetAltMaterialSummary(itemID)
    if not s then return end
    tooltip:AddLine(" ")
    tooltip:AddLine("Account material ledger (last known)",0.57,0.83,1)
    tooltip:AddDoubleLine("This character's bank",s.bankKnown and tostring(s.bank) or "Not scanned",
        0.75,0.81,0.90,1,1,1)
    if s.bankKnown then tooltip:AddLine("Bank scanned "..Stamp(s.bankAt),0.65,0.72,0.81) end
    tooltip:AddDoubleLine("Other characters (same realm/faction)",tostring(s.alts),
        0.75,0.81,0.90,1,1,1)
    if type(required)=="number" and type(s.bags)=="number" then
        local short=math.max(0,required-s.bags)
        if short>0 then
            if s.bank+s.alts>=short then
                tooltip:AddLine("Missing from bags but potentially held in bank/alts",0.43,0.90,0.58,true)
            else
                tooltip:AddLine(tostring(short-s.bank-s.alts).." still unaccounted for (known inventory)",1,0.76,0.35,true)
            end
        end
    end
    for i,loc in ipairs(s.details) do
        if i>8 then tooltip:AddLine("...more characters in ledger",0.70,0.75,0.82); break end
        local label=loc.name..(loc.transferable and "" or (" ("..(loc.realm or "other realm").."; transfer unverified)"))
        tooltip:AddDoubleLine(label,"Bags "..loc.bags.." / Bank "..loc.bank,
            0.76,0.83,0.9,1,1,1)
        tooltip:AddLine("  Bags "..Stamp(loc.bagsAt).." | bank "..Stamp(loc.bankAt),0.62,0.69,0.78)
    end
    if s.other>0 then tooltip:AddLine(tostring(s.other).." stored on other realm/faction (excluded from totals)",1,0.75,0.37,true) end
    tooltip:AddLine("Offline counts may be stale. Transfers and binding are not guaranteed.",0.70,0.75,0.82,true)
end

local frame=CreateFrame("Frame")
for _,event in ipairs({"PLAYER_ENTERING_WORLD","BAG_UPDATE_DELAYED","BANKFRAME_OPENED",
    "BANKFRAME_CLOSED","BANK_TABS_CHANGED","PLAYERBANKSLOTS_CHANGED","PLAYER_LOGOUT"}) do
    frame:RegisterEvent(event)
end
frame:SetScript("OnEvent",function(_,event)
    if event=="PLAYER_ENTERING_WORLD" or event=="BAG_UPDATE_DELAYED" or event=="PLAYER_LOGOUT" then
        Ledger:ScanBags()
    end
    if event=="BANKFRAME_OPENED" then
        bankOpen=true
        bankSessionScanned=false
        -- Do not treat an immediately opening, asynchronously loading bank
        -- as an empty bank. Prefer delayed scans of the loaded tab slots.
        if C_Timer and type(C_Timer.After)=="function" then
            C_Timer.After(0.6,function() if bankOpen then Ledger:ScanBank() end end)
            C_Timer.After(2,function() if bankOpen then Ledger:ScanBank() end end)
        else
            Ledger:ScanBank()
        end
    elseif event=="BANKFRAME_CLOSED" then
        if not bankSessionScanned then Ledger:ScanBank() end
        bankOpen=false
    elseif bankOpen and (event=="BAG_UPDATE_DELAYED" or event=="BANK_TABS_CHANGED"
        or event=="PLAYERBANKSLOTS_CHANGED") then
        Ledger:ScanBank()
    end
end)
