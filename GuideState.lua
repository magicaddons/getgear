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
    local minimum=self.GetAcquisitionMinimumLevel and self:GetAcquisitionMinimumLevel(record)
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
    end
    table.sort(result, function(a,b) return a.name < b.name end)
    return result
end

-- Refresh whichever windows are currently visible.
function GetGear:RefreshAll()
    if self.RefreshUI and self.IsUIShown and self:IsUIShown() then self:RefreshUI() end
    if self.RefreshOverlay then self:RefreshOverlay() end
end

function GetGear:OnInventoryUpdated()
    if self.RefreshAll then self:RefreshAll() end
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

function GetGear:GetItems(mode)
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
    end
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
