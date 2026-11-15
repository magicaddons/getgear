local addonName, GetGear = ...

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
        if gear.targetLevel <= level + 5 and not self:GetStatus(gear)
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
                    entry = { itemID = material.itemID, name = material.name, amount = 0 }
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
    elseif mode == "hidden" then
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
        local status = record.bagUpgrade and nil or self:GetStatus(record)
        local target = record.targetLevel
        if type(target) == "number"
            and (not self.ShouldDisplayGear or self:ShouldDisplayGear(record,self.classToken,mode)) then
            local hidden = self:IsHidden(record)
            local include = false
            if mode == "bags" then
                include = record.bagUpgrade == true and not hidden
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
                result[#result + 1] = record
            end
        end
    end
    -- Objective ordering is neutral: level first, then equipment slot/name/ID.
    table.sort(result, function(a, b)
        if a.targetLevel ~= b.targetLevel then return a.targetLevel < b.targetLevel end
        local slotA,slotB=a.slot or "",b.slot or ""
        if slotA~=slotB then return slotA < slotB end
        local nameA,nameB=a.name or "",b.name or ""
        if nameA~=nameB then return nameA < nameB end
        return (a.itemID or 0) < (b.itemID or 0)
    end)
    return result
end
