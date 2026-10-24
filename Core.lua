local addonName, GetGear = ...
GetGear.level = 1
GetGear.activeTab = "available"

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_LEVEL_UP")
events:RegisterEvent("BAG_UPDATE_DELAYED")
events:RegisterEvent("ITEM_DATA_LOAD_RESULT")
events:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
events:RegisterEvent("UNIT_INVENTORY_CHANGED")
events:RegisterEvent("SKILL_LINES_CHANGED")
events:RegisterEvent("TRADE_SKILL_LIST_UPDATE")
events:RegisterEvent("TRADE_SKILL_SHOW")
events:RegisterEvent("CHAT_MSG_SKILL")
events:RegisterEvent("PLAYER_REGEN_DISABLED")
events:RegisterEvent("PLAYER_REGEN_ENABLED")

local function Say(message)
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cffbca4ff[GetGear]|r " .. message)
    end
end
GetGear.Say = Say

-- Keep "exists in client" separate from "we know the acquisition route".
-- Editors may mark an individual source independently verified with
-- notificationVerified=true after live beta observation.
local function VerifiedNotificationSource(item)
    if item.confidence=="classic-reference" then return false end
    if item.notificationVerified==true then return true end
    return item.acquisitionConfidence=="forever"
end
GetGear.VerifiedNotificationSource=VerifiedNotificationSource

local function NotifyLevel(newLevel)
    if not GetGear.db or GetGear.db.notifications == false then return end
    local count = 0
    for _, item in ipairs(GetGear.Gear) do
        if item.targetLevel == newLevel and VerifiedNotificationSource(item)
            and not GetGear:GetStatus(item) and not GetGear:IsHidden(item)
            and not GetGear:IsGearEquipped(item) then
            count = count + 1
        end
    end
    if count > 0 then
        Say("Level " .. newLevel .. ": " .. count .. " gear objective(s) with verified acquisition routes. Open /getgear to review. (Unverified routes are excluded.)")
    end
end

events:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 ~= addonName then return end
        if type(GetGear_CharacterDB) ~= "table" then GetGear_CharacterDB = {} end
        local db = GetGear_CharacterDB
        if type(db.status) ~= "table" then db.status = {} end
        if type(db.hidden) ~= "table" then db.hidden = {} end
        if type(db.overlay) ~= "table" then db.overlay = {} end
        if type(db.detail) ~= "table" then db.detail = {} end
        local o = db.overlay
        if o.visible == nil then o.visible = true end
        if type(o.backgroundOpacity) ~= "number" then o.backgroundOpacity = 0.78 end
        if type(o.locked) ~= "boolean" then o.locked = false end
        if type(o.hideInCombat) ~= "boolean" then o.hideInCombat = false end
        if o.materialScope ~= "all" then o.materialScope = "tracked" end
        -- Enabled by default, including on characters with older SavedVariables.
        -- Only presentation is affected: status, hidden and acquired keys never change.
        if type(o.filterObsolete) ~= "boolean" then o.filterObsolete = true end
        if type(o.bagUpgrades) ~= "boolean" then o.bagUpgrades = true end
        if type(o.expanded) ~= "table" then o.expanded = {} end
        if type(o.minimized) ~= "table" then o.minimized = {} end
        if type(o.dependencyCollapsed) ~= "table" then o.dependencyCollapsed = {} end
        -- Independent v0.10.8 expand choices; intermediate recipes start closed.
        if type(o.dependencyExpanded) ~= "table" then o.dependencyExpanded = {} end
        if o.materialsCollapsed == nil then o.materialsCollapsed = false end
        if o.objectivesCollapsed == nil then o.objectivesCollapsed = false end
        if type(o.scale) ~= "number" then o.scale=1 end
        -- Added in v0.4.5: user-controlled section split, optional for older saves.
        if type(o.materialShare) == "number" then
            o.materialShare=math.max(0.12,math.min(0.88,o.materialShare))
        else
            o.materialShare=nil
        end
        if type(db.detail.scale) ~= "number" then db.detail.scale=1 end
        -- Per-character SavedVariables are already isolated by WoW. No migration
        -- of existing acquired/hidden/minimized item state is necessary.
        if type(db.specialization) ~= "string" then db.specialization = "All" end
        GetGear.db = db
        if GetGear.AltInventory then GetGear.AltInventory:Initialize() end
        if GetGear.SelectCurrentGuide then GetGear:SelectCurrentGuide() end
        GetGear.level = UnitLevel("player") or 1
        if GetGear.InitializeUI then GetGear:InitializeUI() end
    elseif event == "PLAYER_ENTERING_WORLD" then
        if GetGear.SelectCurrentGuide then GetGear:SelectCurrentGuide() end
        GetGear.level = UnitLevel("player") or GetGear.level
        if GetGear.RefreshAll then GetGear:RefreshAll() end
    elseif event == "UNIT_INVENTORY_CHANGED" then
        if arg1 == "player" and GetGear.RefreshAll then GetGear:RefreshAll() end
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        if GetGear.RefreshAll then GetGear:RefreshAll() end
    elseif event == "BAG_UPDATE_DELAYED" or event == "ITEM_DATA_LOAD_RESULT" then
        if GetGear.OnInventoryUpdated then GetGear:OnInventoryUpdated() end
    elseif event == "SKILL_LINES_CHANGED" or event == "TRADE_SKILL_LIST_UPDATE" or event == "TRADE_SKILL_SHOW" or event == "CHAT_MSG_SKILL" then
        -- Dropping/relearning a profession must invalidate any positive recipe
        -- cache from the old profession skill line.
        if event == "SKILL_LINES_CHANGED" and GetGear.ResetRecipeKnowledge then
            GetGear:ResetRecipeKnowledge()
        end
        if (event == "TRADE_SKILL_LIST_UPDATE" or event == "TRADE_SKILL_SHOW")
            and GetGear.ScanKnownRecipes then GetGear:ScanKnownRecipes() end
        if GetGear.RefreshAll then GetGear:RefreshAll() end
    elseif event == "PLAYER_LEVEL_UP" then
        local newLevel = tonumber(arg1) or UnitLevel("player") or GetGear.level
        if newLevel > GetGear.level then NotifyLevel(newLevel) end
        GetGear.level = newLevel
        if GetGear.RefreshAll then GetGear:RefreshAll() end
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        if GetGear.RefreshOverlay then GetGear:RefreshOverlay() end
    end
end)

SLASH_GETGEAR1 = "/getgear"
SlashCmdList.GETGEAR = function(command)
    command = strtrim((command or ""):lower())
    if command == "notify" then
        if not GetGear.db then Say("Settings not loaded yet.") return end
        GetGear.db.notifications = not GetGear.db.notifications
        Say("Level notifications " .. (GetGear.db.notifications and "enabled" or "disabled") .. ".")
    elseif command == "bankdiag" then
        if not (C_Container and type(C_Container.GetContainerNumSlots)=="function") then
            Say("Container API unavailable")
        else
            local function Slots(id)
                local ok,n=pcall(C_Container.GetContainerNumSlots,id)
                return ok and tostring(n) or "error"
            end
            Say("Forever bank diagnostics: -1="..Slots(-1)..", -2="..Slots(-2))
            for i=1,9 do
                local id=Enum and Enum.BagIndex and Enum.BagIndex["CharacterBankTab_"..i]
                if id then Say("Character bank tab "..i.." / bag "..id..": "..Slots(id).." slots") end
            end
            Say("Diagnostic only: -1 may be the keyring; it is NOT counted in GetGear.")
        end
    elseif command == "inventory" then
        local ledger=GetGear_AccountDB and GetGear_AccountDB.characters or {}
        local count=0
        for _,c in pairs(ledger) do
            count=count+1
            Say((c.name or "Unknown") .. " - " .. (c.realm or "Realm")
                .. ": bags " .. (c.bagsAt and "scanned" or "not scanned")
                .. ", bank " .. (c.bankAt and (tostring(c.bankTabCount or "?").." tabs scanned") or "not scanned"))
        end
        Say(tostring(count).." character(s) in account inventory ledger. Visit each bank once to cache its contents.")
    elseif command:sub(1,10)=="inventory " then
        local id=tonumber(strtrim(command:sub(11)))
        local s=id and GetGear:GetAltMaterialSummary(id)
        if s then Say("Item "..id..": your bags "..tostring(s.bags or "?")
            ..", your bank "..(s.bankKnown and tostring(s.bank) or "not scanned")
            ..", same-realm/faction alts "..s.alts..", other "..s.other)
        else Say("Use /getgear inventory [itemID] to check an item.") end
    elseif command == "status" then
        Say("Level " .. tostring(GetGear.level) .. " " .. tostring(GetGear.className or "unknown class")
            .. "; profile " .. tostring(GetGear.GetSpecialization and GetGear:GetSpecialization() or "All")
            .. "; active recommendations " .. tostring(#GetGear.Gear)
            .. "; shared catalog " .. tostring(GetGear.GetCatalogSize and GetGear:GetCatalogSize() or 0)
            .. "; interface " .. tostring(select(4, GetBuildInfo())) .. ".")
    elseif command == "spec" then
        local choices = GetGear:GetSpecializationChoices()
        Say("Current profile: " .. GetGear:GetSpecialization() .. ". Options: " .. table.concat(choices, ", ")
            .. ". Use /getgear spec Shadow (for example) to select one.")
    elseif command:sub(1,5) == "spec " then
        local requested = strtrim(command:sub(6))
        if GetGear:SetSpecialization(requested) then
            Say("Gear profile set to " .. GetGear:GetSpecialization() .. ". " .. #GetGear.Gear .. " recommendations in this profile.")
        else
            Say("Unknown profile. Choices for this class: " .. table.concat(GetGear:GetSpecializationChoices(), ", "))
        end
    elseif command == "overlay" then
        if GetGear.ToggleOverlay then GetGear:ToggleOverlay() end
    elseif command == "settings" then
        if GetGear.ShowSettings then GetGear:ShowSettings() end
    elseif command == "help" then
        Say("/getgear = guide; /getgear inventory [itemID] = cached bags/banks; /getgear bankdiag = bank slot diagnostics; /getgear spec [name] = build; /getgear overlay = tracker; /getgear settings = settings; /getgear notify = alerts; /getgear status = diagnostics")
    elseif GetGear.ToggleUI then
        GetGear:ToggleUI()
    end
end
