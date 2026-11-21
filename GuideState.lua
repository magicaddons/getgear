local addonName, GetGear = ...

-- Presentation-only slot groups. Call AFTER GetItems / preview generation;
-- never use these preferences in eligibility, comparisons or materials.
GetGear.EquipmentSlotFilters = {
    {"all", "All Slots"}, {"head", "Head"}, {"neck", "Neck"},
    {"shoulders", "Shoulders"}, {"back", "Back"}, {"chest", "Chest"},
    {"wrists", "Wrists"}, {"hands", "Hands"}, {"waist", "Waist"},
    {"legs", "Legs"}, {"feet", "Feet"}, {"rings", "Rings"},
    {"trinkets", "Trinkets"}, {"weapons", "Weapons"},
    {"offhand", "Off Hand"}, {"ranged", "Ranged"}, {"bags", "Bags"},
}
local FILTER_LABELS = {}
for _, entry in ipairs(GetGear.EquipmentSlotFilters) do FILTER_LABELS[entry[1]] = entry[2] end
local SLOT_GROUP = {
    Head="head", Neck="neck", Shoulder="shoulders", Back="back", Chest="chest",
    Wrist="wrists", Hands="hands", Waist="waist", Legs="legs", Feet="feet",
    Ring="rings", Trinket="trinkets", Bag="bags",
    Ranged="ranged", Thrown="ranged", Wand="ranged", Relic="ranged",
    ["Main Hand"]="weapons", ["Off Hand"]="offhand",
    ["Two-Hand"]="weapons", ["Two-Hand Staff"]="weapons",
    ["Two-Hand Axe"]="weapons", ["Two-Hand Mace"]="weapons",
    ["Two-Hand Sword"]="weapons", ["Two-Hand Polearm"]="weapons",
}
local MELEE_SUBTYPE = {Axe=true, Sword=true, Mace=true, Dagger=true,
    ["Fist Weapon"]=true, ["Fist Weapons"]=true}
local HAND_INVENTORY_TYPE = {INVTYPE_WEAPON=13, INVTYPE_WEAPONMAINHAND=21,
    INVTYPE_WEAPONOFFHAND=22, INVTYPE_SHIELD=14, INVTYPE_HOLDABLE=23}

function GetGear:NormalizeEquipmentSlotFilter(slot)
    return type(slot)=="string" and FILTER_LABELS[slot] and slot or "all"
end

function GetGear:GetEquipmentSlotFilterLabel(slot)
    return FILTER_LABELS[self:NormalizeEquipmentSlotFilter(slot)]
end

function GetGear:GetEquipmentSlotFilter(interface)
    local options = self.db and self.db[interface]
    return self:NormalizeEquipmentSlotFilter(options and options.slotFilter)
end

function GetGear:SetEquipmentSlotFilter(interface, slot)
    if interface~="overlay" and interface~="detail" then return end
    if self.db and self.db[interface] then
        self.db[interface].slotFilter = self:NormalizeEquipmentSlotFilter(slot)
    end
end

function GetGear:MatchesEquipmentSlotFilter(gear, slot)
    slot = self:NormalizeEquipmentSlotFilter(slot)
    if slot=="all" then return true end
    local group = SLOT_GROUP[gear.slot]
    if group==slot then return true end
    -- The generated taxonomy folds One-Hand and Main Hand into Main Hand.
    -- Use the same synchronous client metadata API as GearCompare to resolve
    -- compatibility; do not load tooltips, request item data or inspect names.
    if (slot=="offhand" and group=="weapons" and gear.slot=="Main Hand")
        or (slot=="weapons" and group=="offhand") then
        local inventoryType
        if gear.itemID and C_Item and type(C_Item.GetItemInventoryTypeByID)=="function" then
            local ok, value = pcall(C_Item.GetItemInventoryTypeByID, gear.itemID)
            if ok and (type(issecretvalue)~="function" or not issecretvalue(value))
                and type(value)=="number" and value>0 then
                inventoryType = value
            end
        end
        if not inventoryType and gear.itemID then
            local instant = C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant
            if type(instant)=="function" then
                local ok, _, _, _, equipLoc = pcall(instant, gear.itemID)
                if ok and (type(issecretvalue)~="function" or not issecretvalue(equipLoc))
                    and type(equipLoc)=="string" then
                    inventoryType = HAND_INVENTORY_TYPE[equipLoc]
                end
            end
        end
        if inventoryType~=nil then
            return inventoryType==13 or inventoryType==22 -- One-Hand / Weapon Off Hand
        end
        -- Off-hand subtype is retained in the catalogue. Unknown Main Hand
        -- compatibility must not be guessed when the client API is unavailable.
        return slot=="weapons" and MELEE_SUBTYPE[gear.armorType]==true
    end
    return false
end

function GetGear:FilterEquipmentSlots(items, slot)
    local result = {}
    for _, gear in ipairs(items) do
        if self:MatchesEquipmentSlotFilter(gear, slot) then result[#result+1] = gear end
    end
    -- New list, original record identities and order; no writes to inputs.
    return result, #items
end

function GetGear:EquipmentSlotCountText(matches, total, displayed)
    if displayed and displayed<matches then
        return "Showing "..displayed.." of "..total.." ("..matches.." slot matches)"
    end
    return "Showing "..matches.." of "..total.." recommendations"
end

-- Unified runtime gear visibility, progress and materials (Beta 4).
-- Equipment facts and eligibility are loaded separately.

-- Counts character bags only. Bank and other characters intentionally excluded.
-- An absent API returns nil (unknown), never falsely reports a material as missing.
function GetGear:GetMaterialCount(itemID)
    if C_Item and type(C_Item.GetItemCount) == "function" then
        return C_Item.GetItemCount(itemID, false, false, false)
    end
    return nil
end

function GetGear:GetRecommendationRecord(record)
    -- Raw quest facts can rule out an increase without building eligible routes.
    -- Any possible increase still uses the complete character-aware minimum.
    local model=self.AcquisitionNavigationData
    local mayRaise=not model
    if model and not record.bagUpgrade and not record.profession then
        local plan=record.acquisitionPlan or model.items and
            (model.items[record.itemID] or model.items[tostring(record.itemID)])
        for _,route in ipairs(plan and plan.routes or {}) do
            if route.kind=="quest" or route.kind=="quest_container" then
                local quests=model.quests or {}
                local quest=quests[route.questID] or quests[tostring(route.questID)]
                if quest and type(quest.reqlevel)=="number" and quest.reqlevel>(record.targetLevel or 1) then
                    mayRaise=true;break
                end
            end
        end
    end
    local minimum=mayRaise and self.GetAcquisitionMinimumLevel and self:GetAcquisitionMinimumLevel(record)
    if minimum and minimum>(record.targetLevel or 1) then
        return setmetatable({targetLevel=minimum},{__index=record})
    end
    return record
end

-- A hidden objective is not the same as a skipped or acquired objective.
function GetGear:IsHidden(record)
    return self.db and self.db.hidden and self.db.hidden[record.id] == true or false
end

function GetGear:SetHidden(record, hidden)
    if not self.db then return end
    self.db.hidden[record.id] = hidden and true or nil
    if self.RefreshAll then self:RefreshAll() end
end

function GetGear:GetAggregateMaterials(scope)
    local level = self.level or 1
    local totals, result = {}, {}
    for _, gear in ipairs(self.Gear) do
        if gear.reagents and #gear.reagents>0 then
        gear=self:GetRecommendationRecord(gear)
        if gear.targetLevel <= level + 5 and not self:GetStatus(gear)
            and (not self.HasEligibleAcquisitionSource or self:HasEligibleAcquisitionSource(gear))
            and (not self.ShouldDisplayGear
                or self:ShouldDisplayGear(gear,self.classToken,
                    scope=="all" and "materials-all" or "materials"))
            and (not self.ShouldDisplayCraftedGear or self:ShouldDisplayCraftedGear(gear))
            and (scope == "all" or (not self:IsHidden(gear)
                and not self:IsGearEquipped(gear)
                and self:GetObsoleteGearReason(gear) == nil
                and (not self.ShouldShowOverlayStatChanges
                    or self:ShouldShowOverlayStatChanges(gear))
                and (not self.ShouldShowOverlayWorldBoEDrops
                    or self:ShouldShowOverlayWorldBoEDrops(gear))
                and (not self.ShouldShowOverlayAcquisition
                    or self:ShouldShowOverlayAcquisition(gear)))) then
            for _, material in ipairs(gear.reagents or {}) do
                local entry = totals[material.itemID]
                if not entry then
                    entry = { itemID = material.itemID, name = self.MaterialName and self:MaterialName(material.itemID,material.name) or material.name, amount = 0 }
                    totals[material.itemID] = entry
                    result[#result + 1] = entry
                end
                entry.amount = entry.amount + material.amount
            end
        end
        end -- documented reagents
    end
    table.sort(result, function(a,b) return a.name < b.name end)
    return result
end

-- A synchronous refresh is one coherent state snapshot. Share pure derived
-- results across catalogue, material and visible-row consumers, then release
-- every reference before returning to the client. No cross-event cache exists:
-- inventory, equipment, talents, quests, professions, settings and item data
-- are always read afresh on the next refresh, including direct UI refreshes.
local SnapshotNil={}
local SnapshotUnpack=unpack or table.unpack
local function SnapshotPack(...)return {n=select('#',...),...}end
local function InstallSnapshotMethods(self)
    if self.snapshotMethodsInstalled then return end
    self.snapshotMethodsInstalled=true
    for _,name in ipairs({"GetEligibleAcquisitionRoutes",
        "HasEligibleAcquisitionSource","IsGearEquipped",
        "GetObsoleteGearReason","GetGearComparison","GetWeightedUpgradeEvaluation",
        "GetProfessionSkill","IsFactionUseEligible","GetNormalizedRecipeData",
        "GetRecipeSkillRequirement","GetAcquisitionPracticality"}) do
        local original=self[name]
        if type(original)=="function" then
            self[name]=function(owner,key,option,planningPartner)
                local snapshot=owner.recommendationSnapshot
                -- Explicit weapon-pair planning is uncommon and may carry
                -- caller-owned mutable tables; use its original path.
                if not snapshot or planningPartner~=nil then
                    return original(owner,key,option,planningPartner)
                end
                local cache=snapshot[name]
                if not cache then cache={};snapshot[name]=cache end
                local keyIndex=key
                if keyIndex==nil then keyIndex=SnapshotNil end
                local optionKey=option
                if optionKey==nil then optionKey=SnapshotNil end
                local bucket=cache[optionKey]
                if not bucket then bucket={};cache[optionKey]=bucket end
                local result=bucket[keyIndex]
                local capture=owner.performanceStats
                if capture then
                    local counter=capture.cache[name]
                    if not counter then counter={hits=0,misses=0};capture.cache[name]=counter end
                    local field=result and "hits" or "misses";counter[field]=counter[field]+1
                end
                if not result then
                    result=SnapshotPack(original(owner,key,option,planningPartner))
                    bucket[keyIndex]=result
                end
                return SnapshotUnpack(result,1,result.n)
            end
        end
    end
end
function GetGear:WithRecommendationSnapshot(callback,...)
    if self.recommendationSnapshot then return callback(self,...) end
    InstallSnapshotMethods(self)
    self.recommendationSnapshot={}
    local result=SnapshotPack(pcall(callback,self,...))
    self.recommendationSnapshot=nil -- also on errors; never retain stale state
    if not result[1] then error(result[2],0) end
    return SnapshotUnpack(result,2,result.n)
end

-- Refresh whichever windows are currently visible.
local function RefreshVisible(self)
    if self.RefreshUI and self.IsUIShown and self:IsUIShown() then self:RefreshUI() end
    if self.RefreshOverlay then self:RefreshOverlay() end
end

function GetGear:RefreshAll(trigger)
    self.starAcquisitionProofs=nil
    local capture=self.performanceStats
    local previous=capture and capture.trigger
    if capture then capture.trigger=trigger or "RefreshAll" end
    local ok,err=pcall(self.WithRecommendationSnapshot,self,RefreshVisible)
    if capture then capture.trigger=previous end
    if not ok then error(err,0) end
end

function GetGear:OnInventoryUpdated(trigger)
    self.inventoryRefreshTrigger=trigger or "inventory"

    if not self.db or self.inventoryRefreshPending then return end
    -- Equipment, unit-inventory and bag notifications overlap during looting.
    -- A fixed deadline coalesces the burst without starving sustained updates.
    local function refresh()
        self.inventoryRefreshPending=nil
        -- An event arriving between the ledger and UI deadlines must not
        -- leave the account browser showing the previous snapshot.
        if self.AltInventory and self.AltInventory.FlushPendingBagScan then self.AltInventory:FlushPendingBagScan() end
        if self.db and self.RefreshAll then self:RefreshAll(self.inventoryRefreshTrigger) end
    end
    if C_Timer and type(C_Timer.After)=="function" then
        self.inventoryRefreshPending=true
        C_Timer.After(0.1,refresh)
    else refresh() end
end

-- Opt-in session measurements only; no SavedVariables or idle polling.
local function ProfileClock()
    if type(debugprofilestop)=="function" then return debugprofilestop() end
    return type(GetTime)=="function" and GetTime()*1000 or 0
end
local function ProfileMemory()
    if type(collectgarbage)=="function" then
        local ok,n=pcall(collectgarbage,"count")
        if ok and type(n)=="number" then return n end
    end
end
local function Pack(...)return {n=select('#',...),...}end
local Unpack=unpack or table.unpack
function GetGear:PerformanceClock()return ProfileClock()end
local function NewSample()
    return {calls=0,milliseconds=0,maxMilliseconds=0,heapDeltaKB=0,
        memoryAvailable=false,durations={},triggers={}}
end
local function AddDuration(sample,elapsed,trigger)
    sample.calls=sample.calls+1
    sample.milliseconds=sample.milliseconds+elapsed
    sample.maxMilliseconds=math.max(sample.maxMilliseconds,elapsed)
    -- Bounded rolling latency window; no per-frame polling or unbounded log.
    sample.durations[(sample.calls-1)%128+1]=elapsed
    sample.triggers[trigger]=(sample.triggers[trigger] or 0)+1
end
function GetGear:RecordPerformancePhase(name,started)
    local capture=self.performanceStats
    if not capture or not started then return end
    local sample=capture.samples[name]
    if not sample then sample=NewSample();capture.samples[name]=sample end
    AddDuration(sample,math.max(0,ProfileClock()-started),capture.trigger or "UI/direct")
end
function GetGear:StopPerformanceCapture()
    local capture=self.performanceStats
    if not capture then return end
    for _,entry in ipairs(capture.wrappers)do
        if entry.owner[entry.name]==entry.wrapper then entry.owner[entry.name]=entry.original end
    end
    self.performanceStats=nil
    capture.wrappers=nil
    for _,sample in pairs(capture.samples)do
        local values={}
        for i,value in ipairs(sample.durations)do values[i]=value end
        table.sort(values)
        sample.windowSamples=#values
        sample.averageMilliseconds=sample.calls>0 and sample.milliseconds/sample.calls or 0
        sample.p50Milliseconds=values[math.ceil(#values*.50)]
        sample.p95Milliseconds=values[math.ceil(#values*.95)]
    end
    return capture
end
function GetGear:StartPerformanceCapture()
    self:StopPerformanceCapture()
    -- Install memo delegates before profiling them, so stopping the capture
    -- always restores method identity even when this is the first refresh.
    InstallSnapshotMethods(self)
    local capture={events={},samples={},wrappers={},cache={},refreshes={}}
    self.performanceStats=capture
    local function wrap(owner,name)
        local original=owner and owner[name]
        if type(original)~="function" then return end
        local sample=NewSample()
        capture.samples[name]=sample
        local function wrapper(...)
            local previous=capture.trigger
            local reason=(name=="RefreshAll" or name=="RefreshOverlay") and select(2,...) or nil
            local trigger=previous or (type(reason)=="string" and reason) or "UI/direct"
            capture.trigger=trigger
            local started,memory=ProfileClock(),ProfileMemory()
            local result=Pack(pcall(original,...))
            local elapsed=math.max(0,ProfileClock()-started)
            capture.trigger=previous
            AddDuration(sample,elapsed,trigger)
            local after=ProfileMemory()
            if memory and after then sample.memoryAvailable=true;sample.heapDeltaKB=sample.heapDeltaKB+after-memory end
            if name=="RefreshOverlay" then
                capture.refreshes[(sample.calls-1)%128+1]={milliseconds=elapsed,
                    trigger=trigger,heapDeltaKB=memory and after and after-memory or nil}
            end
            if not result[1]then error(result[2],0)end
            return Unpack(result,2,result.n)
        end
        owner[name]=wrapper
        capture.wrappers[#capture.wrappers+1]={owner=owner,name=name,original=original,wrapper=wrapper}
    end
    for _,name in ipairs({"RefreshAll","RefreshUI","RefreshOverlay","GetItems",
        "SortRecommendations","GetCombinedMaterialRows","GetUndocumentedCrafts",
        "GetCraftingMaterialRows"})do wrap(self,name)end
    for _,name in ipairs({"ScanBags","ScanBank"})do wrap(self.AltInventory,name)end
    return capture
end

function GetGear:GetStatus(record)
    return self.db and self.db.status and self.db.status[record.id] or nil
end

function GetGear:SetStatus(record, status)
    if not self.db then return end
    if status ~= "acquired" and status ~= "skipped" then status = nil end
    self.db.status[record.id] = status
    if status then self.db.hidden[record.id] = nil end
    self:RefreshAll()
end

local function CalculateItems(self,mode)
    local started=self.performanceStats and ProfileClock()
    local result = {}
    local level = self.level or 1
    local planning = self.Gear
    if mode == "bags" then
        planning = self.GetBagPlanningObjectives and self:GetBagPlanningObjectives() or {}
    elseif mode == "hidden" or mode == "completed" then
        planning = {}
        for _, record in ipairs(self.Gear) do planning[#planning+1]=record end
        for _, record in ipairs(self.GetBagPlanningObjectives and self:GetBagPlanningObjectives() or {}) do
            planning[#planning+1]=record
        end
    elseif mode == "tracker" then
        planning = {}
        for _, record in ipairs(self.Gear) do planning[#planning+1]=record end
        for _, record in ipairs(self.GetBagPlanningObjectives and self:GetBagPlanningObjectives() or {}) do
            planning[#planning+1]=record
        end
    end
    for _, record in ipairs(planning) do
        -- Acquisition minimums only RAISE targetLevel. Reject impossible
        -- future entries before route/class/faction/stat work; history modes
        -- remain unrestricted. Recheck the effective target below.
        local rawTarget=record.targetLevel
        local ceiling=(mode=="available" or mode=="earlier") and level
            or (mode=="tracker" or mode=="upcoming") and level+5
        if not ceiling or type(rawTarget)~="number" or rawTarget<=ceiling then
        record=self:GetRecommendationRecord(record)
        local status = self:GetStatus(record)
        local target = record.targetLevel
        if type(target) == "number"
            and (not self.ShouldDisplayGear or self:ShouldDisplayGear(record,self.classToken,mode)) then
            local hidden = self:IsHidden(record)
            local include = false
            if mode == "bags" then
                include = record.bagUpgrade == true and not hidden and status==nil
            elseif mode == "completed" then
                include = status == "acquired" or status == "skipped"
                    or (status == nil and not hidden and self:IsGearEquipped(record))
            elseif mode == "hidden" then
                include = status == nil and hidden
            elseif mode == "upcoming" then
                -- Level gates must precede equipment/stat queries. A 1-60
                -- catalogue has thousands of future entries.
                include = target > level and target <= level + 5
                    and status == nil and not hidden and not self:IsGearEquipped(record)
            elseif mode == "earlier" then
                -- Earlier Gear catches either proven stat-obsolete items OR
                -- any eligible equipment at least 5 levels below the character.
                -- Acquisition-level exceptions are already reflected in targetLevel.
                include = target <= level and status == nil and not hidden
                    and not self:IsGearEquipped(record)
                    and ((self.IsOlderGear and self:IsOlderGear(record,level))
                        or self:GetObsoleteGearReason(record) ~= nil)
            elseif mode == "available" then
                include = target <= level and status == nil and not hidden
                    and not self:IsGearEquipped(record)
                    and self:GetObsoleteGearReason(record) == nil
            elseif mode == "tracker" then
                include = target <= level + 5 and status == nil and not hidden
                    and not self:IsGearEquipped(record)
                    and (record.bagUpgrade or self:GetObsoleteGearReason(record) == nil)
            else
                include = false
            end
            -- This is a display-only filter. Completed and Hidden remain
            -- accessible so existing statuses can always be reviewed/undone.
            local history = mode == "completed" or mode == "hidden" or mode == "bags"
            if include and (history or not self.ShouldDisplayCraftedGear
                or self:ShouldDisplayCraftedGear(record)) then
                local recommendation=mode=="available" or mode=="upcoming" or mode=="tracker"
                if not recommendation or ((not self.HasEligibleAcquisitionSource or self:HasEligibleAcquisitionSource(record))
                    and (not self.ShouldRecommendByStatPriority or self:ShouldRecommendByStatPriority(record))) then
                    result[#result + 1] = record
                end
            end
        end
        end -- within raw level ceiling
    end
    if self.performanceStats then self:RecordPerformancePhase("ItemsEvaluation",started) end
    return self:SortRecommendations(result,mode)
end

function GetGear:SortRecommendations(result,mode)
    -- Objective ordering is neutral: level first, then equipment slot/name/ID.
    local scores={}
    if (mode=="available" or mode=="tracker" or mode=="upcoming")
        and self.GetStatPriorityMode and self:GetStatPriorityMode()~="balanced" then
        for _,gear in ipairs(result) do
            scores[gear]=self:GetWeightedUpgradeEvaluation(gear).score or 0
        end
    end
    table.sort(result, function(a, b)
        if scores[a] and scores[b] and scores[a]~=scores[b] then return scores[a]>scores[b] end
        if a.targetLevel ~= b.targetLevel then return a.targetLevel < b.targetLevel end
        local slotA,slotB=a.slot or "",b.slot or ""
        if slotA~=slotB then return slotA < slotB end
        local nameA,nameB=a.name or "",b.name or ""
        if nameA~=nameB then return nameA < nameB end
        return (a.itemID or 0) < (b.itemID or 0)
    end)
    return result
end

function GetGear:GetItems(mode)
    return self:WithRecommendationSnapshot(CalculateItems,mode)
end

-- Catalogue search and character wishlist are presentation tools. Neither is
-- consulted by GetItems, stat evaluation, acquisition rules or material totals.
local function SearchName(value)
    return type(value)=="string" and value:lower() or ""
end
function GetGear:GetWishlistRequiredLevel(record)
    local eligibility=self.EquipmentEligibility and self.EquipmentEligibility[record.itemID]
    return eligibility and eligibility[2] or record.requiredLevel or record.targetLevel or record.availableLevel or 0
end
local function WishlistOrder(self,a,b)
    local la,lb=self:GetWishlistRequiredLevel(a),self:GetWishlistRequiredLevel(b)
    if la~=lb then return la<lb end
    if (a.slot or "")~=(b.slot or "") then return (a.slot or "")<(b.slot or "") end
    if SearchName(a.name)~=SearchName(b.name) then return SearchName(a.name)<SearchName(b.name) end
    return a.itemID<b.itemID
end

function GetGear:InitializeItemSearch()
    if self.itemSearchIndex then return end
    local index={entries={},grams={},classes={},builds=1}
    -- Metadata only; no source queries, item data requests or recommendation copies.
    for class,list in pairs(self.EquipmentByClass or {}) do
        local lookup={};index.classes[class]=lookup
        for _,record in ipairs(list) do lookup[record.itemID]=record end
    end
    for id,record in pairs(self.ItemCatalog or {}) do
        if type(id)=="number" and type(record)=="table" then
            local name=SearchName(record.name)
            local entry={itemID=id,name=name,record=record}
            index.entries[id]=entry
            -- One-/two-character queries use the same index as longer queries.
            for size=1,3 do
                local seen={}
                for pos=1,#name-size+1 do
                    local gram=name:sub(pos,pos+size-1)
                    if not seen[gram] then
                        seen[gram]=true
                        local bucket=index.grams[gram]
                        if not bucket then bucket={};index.grams[gram]=bucket end
                        bucket[#bucket+1]=id
                    end
                end
            end
        end
    end
    self.itemSearchIndex=index
end

function GetGear:GetSearchRecord(itemID)
    self:InitializeItemSearch()
    local index=self.itemSearchIndex
    local class=index.classes[self.classToken]
    return class and class[itemID] or self.ItemCatalog and self.ItemCatalog[itemID]
end

function GetGear:GetSearchRestriction(record,checkSource)
    if not record or type(record.itemID)~="number" or type(record.name)~="string"
        or record.name=="" or type(record.slot)~="string"
        or type(record.targetLevel or record.availableLevel)~="number" then
        return "Incomplete catalogue information"
    end
    if self.IsHardExcludedGear and self:IsHardExcludedGear(record) then return "Internal/test equipment" end
    if not self.classToken then return "Waiting for character information" end
    if self.CanClassEquipGear and not self:CanClassEquipGear(record,self.classToken) then
        return "Not equippable by this class"
    end
    -- Require a class objective, rather than guessing an absent requirement.
    local class=self.itemSearchIndex and self.itemSearchIndex.classes[self.classToken]
    if not class or not class[record.itemID] then return "No class equipment objective in catalogue" end
    if self.IsFactionUseEligible then
        local usable,reason=self:IsFactionUseEligible(record)
        if not usable then return reason or "Faction/race restriction" end
    end
    if checkSource and self.HasEligibleAcquisitionSource and not self:HasEligibleAcquisitionSource(record) then
        return "No eligible acquisition route for this character"
    end
end

function GetGear:SearchEquipment(query,limit)
    self:InitializeItemSearch()
    query=SearchName(query):match("^%s*(.-)%s*$")
    limit=math.max(1,math.min(12,tonumber(limit) or 8))
    if query=="" then return {} end
    local index=self.itemSearchIndex
    local size=math.min(3,#query)
    local bucket
    -- Pick the rarest gram. Verify the whole literal name before ranking.
    for pos=1,#query-size+1 do
        local candidate=index.grams[query:sub(pos,pos+size-1)]
        if not candidate then return {} end
        if not bucket or #candidate<#bucket then bucket=candidate end
    end
    local results={}
    local function before(a,b)
        if a.rank~=b.rank then return a.rank<b.rank end
        if a.entry.name~=b.entry.name then return a.entry.name<b.entry.name end
        return a.entry.itemID<b.entry.itemID
    end
    for _,id in ipairs(bucket or {}) do
        local entry=index.entries[id]
        local start=entry.name:find(query,1,true)
        if start then
            local result={entry=entry,rank=entry.name==query and 1 or start==1 and 2 or 3}
            local pos=1
            while results[pos] and not before(result,results[pos]) do pos=pos+1 end
            if pos<=limit then
                table.insert(results,pos,result)
                if #results>limit then table.remove(results) end
            end
        end
    end
    local out={}
    for _,result in ipairs(results) do
        local record=self:GetSearchRecord(result.entry.itemID)
        out[#out+1]={itemID=result.entry.itemID,record=record,
            restriction=self:GetSearchRestriction(record,false)}
    end
    return out
end

function GetGear:IsItemStarred(itemID)
    return self.db and type(self.db.starredItems)=="table" and self.db.starredItems[itemID]==true or false
end

local function ChangeItemStar(self,itemID,starred,previewMode)
    if not self.db or previewMode then return false,"Preview is read-only" end
    if type(itemID)~="number" or itemID<=0 or itemID~=math.floor(itemID) then return false,"Invalid item ID" end
    if starred then
        local record=self:GetSearchRecord(itemID)
        local reason=self:GetSearchRestriction(record,true)
        if reason then return false,reason end
    end
    if type(self.db.starredItems)~="table" then self.db.starredItems={} end
    self.db.starredItems[itemID]=starred and true or nil
    if self.RefreshStarPresentation then self:RefreshStarPresentation(itemID,starred) end
    return true
end

function GetGear:SetItemStarred(itemID,starred,previewMode)
    return self:WithRecommendationSnapshot(ChangeItemStar,itemID,starred,previewMode)
end

function GetGear:GetSearchItemState(record)
    if self:IsHidden(record) then return "Hidden" end
    local status=self:GetStatus(record)
    if status=="skipped" then return "Skipped" elseif status=="acquired" then return "Acquired" end
    if self.IsGearEquipped and self:IsGearEquipped(record) then return "Equipped" end
    local owned=self:GetMaterialCount(record.itemID)
    if type(owned)=="number" and (type(issecretvalue)~="function" or not issecretvalue(owned)) and owned>0 then return "Owned in bags (not marked acquired)" end
    if record.targetLevel and record.targetLevel>(self.level or 1) then
        return "Future: target level "..record.targetLevel
    end
    return "Catalogue item; not necessarily an upgrade"
end

-- Read equipped IDs once for a large wishlist, within this call only.
local function WishlistEquippedIDs()
    if type(GetInventoryItemID)~="function" and type(GetInventoryItemLink)~="function" then return nil end
    local ids={}
    for slot=1,19 do
        local ok,value
        if type(GetInventoryItemID)=="function" then ok,value=pcall(GetInventoryItemID,"player",slot) end
        if ok and type(value)=="number" and (type(issecretvalue)~="function" or not issecretvalue(value)) then ids[value]=true
        elseif type(GetInventoryItemLink)=="function" then
            ok,value=pcall(GetInventoryItemLink,"player",slot)
            if ok and type(value)=="string" and (type(issecretvalue)~="function" or not issecretvalue(value)) then
                local id=tonumber(value:match("item:(%d+)"));if id then ids[id]=true end
            end
        end
    end
    return ids
end

function GetGear:ComposeStarredItems(recommendations,mode,displayedStars,deferSources)
    local saved=self.db and self.db.starredItems
    if not saved or not next(saved) or mode=="bags" then return recommendations end
    local stars,rest,seen={},{},{}
    local history=mode=="hidden" or mode=="completed"
    -- Proofs live only in the current rendered model, never SavedVariables.
    -- A full refresh always rebuilds them. Immediate star-only reorders can
    -- reuse successful checks from that model without rescanning source pages.
    self.starAcquisitionProofs=self.starAcquisitionProofs or {}
    local proofs=displayedStars and self.starAcquisitionProofs[mode] or {}
    proofs=proofs or {}
    self.starAcquisitionProofs[mode]=proofs
    local function sourceEligible(record)
        if displayedStars and proofs[record] then return true end
        local allowed=not self.HasEligibleAcquisitionSource or self:HasEligibleAcquisitionSource(record)
        proofs[record]=allowed or nil
        return allowed
    end
    for _,record in ipairs(recommendations) do
        if history or sourceEligible(record) then
            if self:IsItemStarred(record.itemID) then
                stars[#stars+1]=record;seen[record.itemID]=true
            else rest[#rest+1]=record end
        end
    end
    if not history then
        self:InitializeItemSearch()
        local equipped=WishlistEquippedIDs()
        for id,value in pairs(saved) do
            if value==true and not seen[id] then
                local record=displayedStars and displayedStars[id] or not displayedStars and self:GetSearchRecord(id)
                if record and (not self:GetSearchRestriction(record,false))
                    and sourceEligible(record)
                    and not self:IsHidden(record) and not self:GetStatus(record)
                    and (equipped and not equipped[id] or not equipped and
                        (not self.IsGearEquipped or not self:IsGearEquipped(record))) then
                    stars[#stars+1]=deferSources and record or self:GetRecommendationRecord(record)
                    seen[id]=true
                end
            end
        end
    end
    table.sort(stars,function(a,b) return WishlistOrder(self,a,b) end)
    for _,record in ipairs(rest) do stars[#stars+1]=record end
    return stars
end

function GetGear:SelectSearchItem(itemID)
    local record=self:GetSearchRecord(itemID)
    local reason=self:GetSearchRestriction(record,true)
    if reason then return false,reason end
    record=self:GetRecommendationRecord(record)
    -- Session-only focus. Never writes slot, level, status or display preferences.
    self.focusedSearchItem=record
    if self.ShowSearchFocus then self:ShowSearchFocus(record) end
    return true,record
end
