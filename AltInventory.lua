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

-- Compare canonical identity without changing saved ledger keys. Unknown values
-- are never proof that two characters share a realm or faction.
local function Text(value)
    if type(value)~="string" then return nil end
    value=value:match("^%s*(.-)%s*$")
    if value=="" or value:lower()=="unknown" then return nil end
    return value
end
local function Realm(value)
    value=Text(value)
    return value and value:lower():gsub("[%s%-%']", "") or nil
end
local function SameName(a,b)
    return a~=nil and b~=nil and a:lower()==b:lower()
end
local function Faction(value)
    value=Text(value)
    if not value then return nil end
    local lower=value:lower()
    if lower=="alliance" or value==FACTION_ALLIANCE then return "Alliance" end
    if lower=="horde" or value==FACTION_HORDE then return "Horde" end
    return nil
end
local function RealmID(value)
    local id=tonumber(value)
    if id and id>0 and id==math.floor(id) then return id end
end
local function GuidRealm(guid)
    return type(guid)=="string" and RealmID(guid:match("^Player%-(%d+)%-")) or nil
end
local function Read(fn,...)
    if type(fn)~="function" then return nil end
    local ok,value=pcall(fn,...)
    if ok then return value end
end
local function Identity()
    local name=Text(Read(UnitName,"player"))
    local realm=Text(Read(GetRealmName)) or Text(Read(GetNormalizedRealmName))
    if not realm and type(UnitFullName)=="function" then
        local ok,_,fullRealm=pcall(UnitFullName,"player")
        if ok then realm=Text(fullRealm) end
    end
    if not name or not realm then return nil end
    local guid=Read(UnitGUID,"player")
    return realm..":"..name,name,realm,Faction(Read(UnitFactionGroup,"player")),
        RealmID(Read(GetRealmID)) or GuidRealm(guid),guid
end
local function Metadata(key,c)
    local keyRealm,keyName
    if type(key)=="string" then keyRealm,keyName=key:match("^([^:]+):([^:]+)$") end
    -- The historical writer always used Realm:Name. A key can fill a missing
    -- field, but cannot override explicit metadata or supply a faction.
    return Text(c.name) or Text(keyName),Text(c.realm) or Text(keyRealm),
        Faction(c.faction),RealmID(c.realmID) or GuidRealm(c.guid)
end
local function SameRealm(ar,ai,br,bi)
    if ai and bi then return ai==bi end
    local a,b=Realm(ar),Realm(br)
    return a~=nil and b~=nil and a==b
end
local function Eligible(realm,id,faction,currentRealm,currentID,currentFaction)
    return faction~=nil and currentFaction~=nil and faction==currentFaction
        and SameRealm(realm,id,currentRealm,currentID)
end

local function CharacterIdentity(key,c,currentName,currentRealm,currentFaction,currentID,currentGUID)
    local name,realm,faction,id=Metadata(key,c)
    local sameCharacter=SameName(name,currentName) and SameRealm(realm,id,currentRealm,currentID)
    local conflict=c.inventoryIdentityConflict or (sameCharacter and c.guid and currentGUID and c.guid~=currentGUID)
    return name,realm,faction,not conflict and sameCharacter,
        not conflict and Eligible(realm,id,faction,currentRealm,currentID,currentFaction),
        conflict or not realm or not faction
end

-- Reconcile formatting aliases once at login. Retain original records as
-- evidence; use the latest complete snapshot per storage, never sum aliases.
-- Conflicting identities remain separate and are labelled unresolved below.
function Ledger:ReconcileMetadata()
    local records=GetGear_AccountDB.characters
    local keys={}
    for key,c in pairs(records) do
        if type(c)=="table" then
            keys[#keys+1]=key
            local name,realm,faction,id=Metadata(key,c)
            c.name=name; c.realm=realm
            if faction then c.faction=faction end
            if id then c.realmID=id end
            c.inventoryAliasOf=nil
            c.inventoryIdentityConflict=nil
        end
    end
    table.sort(keys,function(a,b)return tostring(a)<tostring(b) end)
    -- Detect ambiguous groups before merging any member (including aliases
    -- lacking a GUID/faction between two contradictory known records).
    for _,key in ipairs(keys) do
        local c=records[key]
        local name,realm,faction,id=Metadata(key,c)
        local guid=c.guid
        local groupID=id
        for _,otherKey in ipairs(keys) do
            local other=records[otherKey]
            local on,orr,of,oi=Metadata(otherKey,other)
            if SameName(name,on)
                and (SameRealm(realm,id,orr,oi) or (Realm(realm) and Realm(realm)==Realm(orr)))
                and (not id or not oi or id==oi) then
                if (guid and other.guid and guid~=other.guid)
                    or (faction and of and faction~=of) or (groupID and oi and groupID~=oi) then
                    c.inventoryIdentityConflict=true
                end
                guid=guid or other.guid;faction=faction or of;groupID=groupID or oi
            end
        end
    end
    for i,key in ipairs(keys) do
        local c=records[key]
        if not c.inventoryAliasOf and not c.inventoryIdentityConflict then
            local name,realm,faction,id=Metadata(key,c)
            for j=i+1,#keys do
                local otherKey=keys[j];local other=records[otherKey]
                local on,orr,of,oi=Metadata(otherKey,other)
                if not other.inventoryAliasOf and not other.inventoryIdentityConflict
                    and SameName(name,on)
                    and SameRealm(realm,id,orr,oi) then
                    for _,storage in ipairs({"bags","bank"}) do
                        local at=storage.."At"
                        local moreComplete=storage=="bank" and c.bankPartial and not other.bankPartial
                        local lessComplete=storage=="bank" and not c.bankPartial and other.bankPartial
                        if type(other[storage])=="table" and (type(c[storage])~="table" or moreComplete
                            or (not lessComplete and (tonumber(other[at]) or 0)>(tonumber(c[at]) or 0))) then
                            c[storage]=other[storage];c[at]=other[at]
                            if storage=="bank" then
                                c.bankPartial=other.bankPartial;c.bankTabCount=other.bankTabCount
                            end
                        end
                    end
                    c.faction=faction or of;c.realmID=id or oi;c.guid=c.guid or other.guid
                    faction=c.faction;id=c.realmID
                    other.inventoryAliasOf=key
                end
            end
        end
    end
    GetGear_AccountDB.inventorySchemaVersion=2
end

local currentRecord,currentRecordKey
local function Current()
    local key,name,realm,faction,id,guid=Identity()
    local db=GetGear_AccountDB
    if not key or type(db)~="table" or type(db.characters)~="table" then return nil end
    if currentRecord and currentRecordKey and db.characters[currentRecordKey]==currentRecord then
        local n,r,_,ri=Metadata(currentRecordKey,currentRecord)
        if not SameName(n,name) or not SameRealm(r,ri,realm,id) then currentRecord=nil end
    end
    local c=currentRecord
    if not c then
        c=db.characters[key]
        if type(c)=="table" and c.inventoryAliasOf then key=c.inventoryAliasOf;c=db.characters[key] end
        if type(c)~="table" then
            -- Formatting changes must reuse a recorded bank instead of creating
            -- a second character. Metadata reconciliation already merges aliases.
            for savedKey,record in pairs(db.characters) do
                if type(record)=="table" and not record.inventoryAliasOf then
                    local n,r,_,ri=Metadata(savedKey,record)
                    if SameName(n,name) and SameRealm(r,ri,realm,id)
                        and not record.inventoryIdentityConflict
                        and (not record.guid or not guid or record.guid==guid) then c=record;key=savedKey;break end
                end
            end
        end
        if type(c)~="table" then c={};db.characters[key]=c end
        currentRecord=c;currentRecordKey=key
    else key=currentRecordKey end
    if c.inventoryIdentityConflict or (c.guid and guid and c.guid~=guid) then return nil end
    local savedName,savedRealm,_,savedID=Metadata(key,c)
    if (savedName and not SameName(savedName,name)) or (savedRealm and not SameRealm(savedRealm,savedID,realm,id)) then return nil end
    if savedID and id and savedID~=id then return nil end
    c.name=name;c.realm=realm
    -- Unavailable login APIs must not erase previously established metadata.
    if faction then c.faction=faction end
    if id then c.realmID=id end
    if guid then c.guid=guid end
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
        else
            return false -- one unavailable bag must not erase its previous contents
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
        if n>0 then readable=readable+1
        elseif known then return false end -- purchased tab still loading
        Merge(totals,items)
    end
    -- An opening bank can initially return zero slots while tabs load.
    -- No successful tab scan => never erase the last known bank snapshot.
    if readable==0 then return false end
    -- Without a purchased-tab list we cannot prove a partial result replaces
    -- an existing snapshot safely. Keep it until a complete read is possible.
    if not known and type(c.bank)=="table" then return false end
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
    self:ReconcileMetadata()
    currentRecord=nil;currentRecordKey=nil
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
    local _,currentName,currentRealm,currentFaction,currentID,currentGUID=Identity()
    for otherKey,record in pairs(GetGear_AccountDB.characters) do
        if otherKey~=key and type(record)=="table" and not record.inventoryAliasOf then
            local bags=type(record.bags)=="table" and (record.bags[itemID] or 0) or 0
            local bank=type(record.bank)=="table" and (record.bank[itemID] or 0) or 0
            if bags+bank>0 then
                local name,realm,_,_,same=CharacterIdentity(otherKey,record,
                    currentName,currentRealm,currentFaction,currentID,currentGUID)
                if same then alts=alts+bags+bank else other=other+bags+bank end
                details[#details+1]={name=name or tostring(otherKey),realm=realm,
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
    if not name and not requestedInventoryNames[id] then
        requestedInventoryNames[id]=true
        if GetGear.RequestItemDataOnce then GetGear:RequestItemDataOnce(id) end
    end
    if not name then name="Item #"..tostring(id) end
    return name
end

function Ledger:BrowserCharacters()
    local _,currentName,currentRealm,currentFaction,currentID,currentGUID=Identity()
    local records=GetGear_AccountDB and GetGear_AccountDB.characters or {}
    local result={}
    for key,c in pairs(records) do
        if type(c)=="table" and not c.inventoryAliasOf then
            local name,realm,faction,current,eligible,unknown=CharacterIdentity(key,c,
                currentName,currentRealm,currentFaction,currentID,currentGUID)
            result[#result+1]={key=key,name=name or tostring(key),realm=realm or "Unknown",
                faction=faction or "Unknown",current=current,eligible=eligible,
                metadataUnknown=unknown,
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
    local unknownBanks,unknownBags,partialBanks,unknownMetadata,unresolvedCharacters=0,0,0,0,0
    for _,c in ipairs(chars) do
        if c.metadataUnknown then unresolvedCharacters=unresolvedCharacters+1 end
        local include=(scope=="eligible" and c.eligible)
            or (scope=="current" and c.current)
            or (scope=="alts" and c.eligible and not c.current)
            or (scope=="other" and not c.eligible)
            or all or (scope==c.key)
        if include then
            selected[#selected+1]=c
            if c.metadataUnknown then unknownMetadata=unknownMetadata+1 end
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
        unknownMetadata=unknownMetadata,unresolvedCharacters=unresolvedCharacters,
        eligibleOnly=scope=="eligible" or scope=="alts",totalInScope=#results}
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
local pendingBagScan
function Ledger:FlushPendingBagScan()
    if not pendingBagScan then return end
    pendingBagScan=nil
    self:ScanBags()
end
local function QueueBagScan()
    if pendingBagScan then return end
    if not(C_Timer and type(C_Timer.After)=="function")then Ledger:ScanBags();return end
    local ticket={};pendingBagScan=ticket
    C_Timer.After(0.05,function()
        if pendingBagScan~=ticket then return end
        Ledger:FlushPendingBagScan()
    end)
end
for _,event in ipairs({"PLAYER_ENTERING_WORLD","BAG_UPDATE_DELAYED","BANKFRAME_OPENED",
    "BANKFRAME_CLOSED","BANK_TABS_CHANGED","PLAYERBANKSLOTS_CHANGED","PLAYER_LOGOUT"}) do
    frame:RegisterEvent(event)
end
frame:SetScript("OnEvent",function(_,event)
    if event=="BAG_UPDATE_DELAYED" then
        QueueBagScan()
    elseif event=="PLAYER_ENTERING_WORLD" or event=="PLAYER_LOGOUT" then
        -- Final logout state must be written synchronously, without waiting
        -- for a timer that cannot run once the client closes.
        pendingBagScan=nil
        Ledger:ScanBags()
        if event=="PLAYER_LOGOUT" and bankOpen then Ledger:ScanBank() end
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
