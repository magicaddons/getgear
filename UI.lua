local addonName, GetGear = ...

-- Pure Blizzard UI, with no external process or communication bridge.
local function ItemIcon(itemID)
    if type(itemID) == "number" and C_Item and type(C_Item.GetItemIconByID) == "function" then
        local icon = C_Item.GetItemIconByID(itemID)
        if icon then return icon end
        if type(C_Item.RequestLoadItemDataByID) == "function" then
            C_Item.RequestLoadItemDataByID(itemID)
        end
    end
    return "Interface\\Icons\\INV_Misc_QuestionMark"
end

local function ShowItemTooltip(button)
    if not button.itemID or not GameTooltip then return end
    GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
    if type(GameTooltip.SetItemByID) == "function" then
        GameTooltip:SetItemByID(button.itemID)
    else
        GameTooltip:SetHyperlink("item:" .. tostring(button.itemID))
    end
    if button.gearRecord and not button.previewItem and GetGear.AppendComparisonTooltip then
        GetGear:AppendComparisonTooltip(GameTooltip,button.gearRecord)
    end
    if button.material then
        local recipe = button.material.recipe
        if recipe then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Can be made from:", 0.9, 0.8, 0.6)
            for _,part in ipairs(recipe.inputs) do
                GameTooltip:AddLine(tostring(part[2]) .. " x " .. (GetGear.MaterialName and GetGear:MaterialName(part[1]) or "ingredient"), 1, 1, 1)
            end
        end
        local have = GetGear:GetMaterialCount(button.itemID)
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(button.aggregate and "Total needed for selected objectives" or "Needed for this craft",
            tostring(button.material.amount), 1, 0.83, 0.35, 1, 1, 1)
        GameTooltip:AddDoubleLine("In your bags", have == nil and "Unknown" or tostring(have),
            0.72, 0.78, 0.85, 1, 1, 1)
        if button.itemID==929 then
            GameTooltip:AddLine("Healing Potion output count differs between published Forever sources (1 or 2). Expanded ingredients assume 1 until verified in-game.",1,0.74,0.33,true)
        end
        if GetGear.AppendAltMaterialTooltip then GetGear:AppendAltMaterialTooltip(GameTooltip,button.itemID,button.material.amount) end
    end
    GameTooltip:Show()
end

local function HideItemTooltip()
    if GameTooltip then GameTooltip:Hide() end
end

-- Colour only the class using Blizzard's standard class palette; keep the
-- level and race muted so even the white Priest class name stands out.
local function ColoredCharacterLabel(level, race, class, classToken)
    local muted = "|cffA8B5C5"
    local classColour = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classToken or ""]
    local hex = "FFFFFF"
    if classColour then
        hex = string.format("%02X%02X%02X",
            math.floor((classColour.r or 1)*255+0.5),
            math.floor((classColour.g or 1)*255+0.5),
            math.floor((classColour.b or 1)*255+0.5))
    end
    return muted .. "Level " .. tostring(level or 1)
        .. (race and race ~= "" and " " .. race or "")
        .. "|r |cff" .. hex .. (class or "Class") .. "|r"
end


local function NewIcon(parent, size)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(size, size)
    local texture = button:CreateTexture(nil, "ARTWORK")
    texture:SetAllPoints()
    button.texture = texture
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Buttons\\UI-Quickslot2")
    border:SetPoint("TOPLEFT", -5, 5)
    border:SetPoint("BOTTOMRIGHT", 5, -5)
    button:SetScript("OnEnter", ShowItemTooltip)
    button:SetScript("OnLeave", HideItemTooltip)
    return button
end

local function SetItemIcon(icon, itemID, material, aggregated, record, previewItem)
    icon.gearRecord = record
    icon.previewItem = previewItem and true or false
    icon.itemID = itemID
    icon.material = material
    icon.aggregate = aggregated
    icon.texture:SetTexture(ItemIcon(itemID))
end

local function NewText(parent, template, width, justify)
    local label = parent:CreateFontString(nil, "OVERLAY", template or "GameFontHighlightSmall")
    if width then label:SetWidth(width) end
    label:SetJustifyH(justify or "LEFT")
    label:SetJustifyV("TOP")
    return label
end

local function MeasureText(label, minimum)
    return math.max(minimum or 14, math.ceil(label:GetStringHeight() or minimum or 14))
end

local function NewButton(parent, text, width, height)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(width, height or 23)
    b:SetText(text)
    return b
end

-- Blizzard's bundled profession textures, without external icon assets.
local PROFESSION_ART = {
    Enchanting = "Interface\\Icons\\Trade_Engraving",
    Tailoring = "Interface\\Icons\\Trade_Tailoring",
    Alchemy = "Interface\\Icons\\Trade_Alchemy",
    Mining = "Interface\\Icons\\Trade_Mining",
    Blacksmithing = "Interface\\Icons\\Trade_BlackSmithing",
    Leatherworking = "Interface\\Icons\\Trade_LeatherWorking",
    Engineering = "Interface\\Icons\\Trade_Engineering",
    ["First Aid"] = "Interface\\Icons\\Spell_Holy_SealOfSacrifice",
}
local function ProfessionSource(gear)
    local name = gear.sourceType
    if name and PROFESSION_ART[name] then return name end
    if gear.profession and PROFESSION_ART[gear.profession] then return gear.profession end
    return nil
end

-- A lightweight gold map pin. We use our own icon, not Blizzard's quest
-- exclamation marks (blue is already reserved for repeatable quests).
local function NewAcquisitionPin(parent, size)
    local b=CreateFrame("Button",nil,parent)
    b:SetSize(size or 23,size or 23)
    local t=b:CreateTexture(nil,"ARTWORK")
    t:SetAllPoints()
    t:SetTexture("Interface\\AddOns\\GetGear\\MapPin")
    b.pinTexture=t
    b:SetScript("OnEnter",function(self)
        local destination=self.destination
        if not destination or not GameTooltip then return end
        self.pinTexture:SetVertexColor(1,1,0.82)
        GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
        GameTooltip:AddLine("Open acquisition location",1,0.84,0.42)
        GameTooltip:AddLine(destination.spot or destination.zone,1,1,1,true)
        if destination.x and destination.y then
            GameTooltip:AddLine(destination.zone .. " (" .. string.format("%.1f",destination.x) .. ", " .. string.format("%.1f",destination.y) .. ")",0.8,0.85,0.93)
        else
            GameTooltip:AddLine(destination.zone .. " - approximate region",0.8,0.85,0.93)
        end
        if destination.quality=="classic-reference" then
            GameTooltip:AddLine("Classic location; verify in Forever",1,0.70,0.32,true)
        elseif destination.quality=="reported" then
            GameTooltip:AddLine("Community-reported location; not independently confirmed",1,0.70,0.32,true)
        elseif destination.quality=="zone-only" then
            GameTooltip:AddLine("Approximate zone only; exact destination unverified",1,0.70,0.32,true)
        elseif destination.quality~="forever" then
            GameTooltip:AddLine("Acquisition location not independently verified",1,0.70,0.32,true)
        end
        GameTooltip:AddLine("Opens the map. Replaces your existing user waypoint when allowed.",0.65,0.76,0.88,true)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave",function(self)
        self.pinTexture:SetVertexColor(1,1,1)
        HideItemTooltip()
    end)
    b:SetScript("OnClick",function(self)
        if self.gear then GetGear:OpenAcquisitionMap(self.gear) end
    end)
    return b
end

local function AssignAcquisitionPin(b,gear)
    local target=GetGear.GetAcquisitionMapTarget and GetGear:GetAcquisitionMapTarget(gear)
    if target then
        b.gear=gear
        b.destination=target
        b:Show()
    else
        b.gear=nil
        b.destination=nil
        b:Hide()
    end
end

local function NewProfessionIcon(parent, size)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(size or 18, size or 18)
    local texture = button:CreateTexture(nil,"ARTWORK")
    texture:SetAllPoints()
    button.icon = texture
    button:SetScript("OnEnter", function(self)
        if self.profession and GameTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(self.profession, 1, 0.82, 0.35)
            if self.required then
                local current = GetGear:GetProfessionSkill(self.profession)
                local have = current == nil and "Not learned" or tostring(current)
                GameTooltip:AddDoubleLine("Skill", have .. " / " .. self.required, 1, 1, 1, 1, 1, 1)
            end
            GameTooltip:Show()
        end
    end)
    button:SetScript("OnLeave", HideItemTooltip)
    return button
end
local function SetProfessionIcon(button, profession, required)
    if not profession or not PROFESSION_ART[profession] then button:Hide(); return end
    button.profession, button.required = profession, required
    button.icon:SetTexture(PROFESSION_ART[profession])
    button:Show()
end
local function UpdateProfessionSkill(icon, label, gear, showRequiredProfession, previewMode)
    if not gear.profession then
        icon:Hide(); label:Hide(); return false
    end
    if previewMode then
        -- This is an alternate class/level; the actual player's skill and
        -- known recipes must not be presented as the preview character's.
        if gear.professionSkillRequired and gear.recipeLearnSkillEvidence~="unverified" then
            label:SetText(gear.profession .. " " .. tostring(gear.professionSkillRequired) ..
                (gear.recipeLearnSkillProvisional and "? (reported)" or " required"))
        elseif gear.professionLearnSource == "Trainer" or gear.professionSkillEstimate or gear.recipeLearnMethod=="trainer" then
            label:SetText(gear.profession .. " - Trainer (verify skill)")
        else
            label:SetText(gear.profession .. " - skill unverified")
        end
        label:SetTextColor(1,0.82,0.46)
        icon:Hide()
        label:Show()
        return true
    end
    -- A known craft recipe is stronger evidence than an external skill
    -- requirement. Lookup is tri-state: nil means the client has not supplied
    -- trustworthy learning data, not that the player lacks the recipe.
    local learned = GetGear.GetRecipeKnowledge and GetGear:GetRecipeKnowledge(gear)
    local required = gear.professionSkillRequired
    if gear.recipeLearnSkillEvidence=="unverified" then required=nil end
    local trainer = gear.professionLearnSource == "Trainer" or
        gear.professionSkillEstimate ~= nil or gear.recipeLearnMethod=="trainer"
    if learned ~= true and required == nil and not trainer then
        icon:Hide()
        label:SetText(gear.profession .. " - skill unverified")
        label:SetTextColor(1,0.77,0.38)
        label:Show()
        return true
    end
    local current = GetGear:GetProfessionSkill(gear.profession)
    if showRequiredProfession then
        if learned == true then
            label:SetText(gear.profession .. " - Learned")
        elseif required then
            label:SetText(gear.profession .. " " .. tostring(required) .. (gear.recipeLearnSkillProvisional and "?" or ""))
        else
            label:SetText(gear.profession .. " - Trainer")
        end
    else
        if learned == true then
            label:SetText(gear.profession .. " - Learned")
        elseif required then
            label:SetText((current == nil and "-" or tostring(current)) .. "/" .. tostring(required) .. (gear.recipeLearnSkillProvisional and "?" or ""))
        else
            label:SetText(gear.profession .. " - Trainer")
        end
    end
    if learned == true or (required and not gear.recipeLearnSkillProvisional and current and current >= required) then
        label:SetTextColor(0.38,0.90,0.53)
    else
        label:SetTextColor(1,0.77,0.38)
    end
    -- The overlay intentionally hides this icon; the detailed window keeps
    -- its existing icon for the progress tooltip when a requirement exists.
    if required and not (learned == true) then
        SetProfessionIcon(icon, gear.profession, required)
    else
        icon:Hide()
    end
    label:Show()
    return true
end

local function Describe(gear, previewMode)
    local hasSource = type(gear.source)=="string" and gear.source~=""
    local desc = (hasSource and (gear.source .. ": ") or "") .. (gear.instructions or "")
    if gear.notes and gear.notes ~= "" then desc = desc .. "\n" .. gear.notes end
    if gear.suitabilityWarning and gear.suitabilityWarning~="" and
        not desc:find(gear.suitabilityWarning,1,true) then
        desc=desc.."\n"..gear.suitabilityWarning
    end
    if gear.recipeLearningAvailability=="disputed" and
        not desc:lower():find("trainer teaching route",1,true) and
        not desc:lower():find("trainer teaching as well",1,true) and
        not desc:lower():find("method disputed",1,true) then
        desc=desc.."\n|cffffba63Recipe teaching availability is disputed in Forever sources. " ..
            "Check the current trainer/recipe window before relying on this route.|r"
    end
    if gear.confidence == "classic-reference" and not desc:lower():find("classic",1,true) then
        desc = desc .. "\n|cffffba63Item source is Classic-reference only, not a confirmed Forever reward or drop. Any map pin locates the destination, not proof of the item.|r"
    elseif gear.acquisitionConfidence == "client" and gear.profession
        and (not gear.recipeLearnMethod or gear.recipeLearnMethod=="unverified") then
        desc = desc .. "\n|cffffba63Recipe exists in client; learning source is not verified.|r"
    end
    if gear.confidence == "client" and gear.acquisitionConfidence == "classic-reference" then
        desc = desc .. "\n|cffffba63Item stats exist in the client; the listed seller/source is Classic-reference only.|r"
    end
    if previewMode and type(gear.races)=="table" and #gear.races>0 then
        desc = desc .. "\n|cffffba63Race-restricted: " .. table.concat(gear.races, ", ") .. ".|r"
    end
    return desc
end

-- The compact overlay already identifies the profession and trainer/skill
-- state beside MATERIALS. The acquisition pin supplies mapped recipe vendors.
-- Don't repeat those facts in a second paragraph. Keep method information not
-- shown by the heading (patterns and initial recipes), and significant source
-- warnings even when a location pin exists. The detailed Guide stays complete.
local function DescribeOverlay(gear, hasLocationButton)
    if gear.profession then
        if gear.recipeLearningAvailability=="disputed" or gear.recipeLearnMethod=="multiple" then
            return "Recipe teaching method disputed in Forever; check trainer/pattern availability."
        end
        if gear.acquisitionConfidence=="classic-reference" or gear.confidence=="classic-reference" then
            return "Recipe source based on Classic; not yet confirmed in Forever."
        end
        -- An existing map button already shows the vendor/destination.
        if hasLocationButton then return nil end
        -- A vendor can be documented even when no usable navigation pin exists.
        if gear.recipeVendor and gear.recipeVendor~="" then
            return "Pattern vendor: "..gear.recipeVendor.."."
        end
        -- A bare "pattern/plans required" message is not actionable.
        -- Show a named vendor above when known, or a mapped pin; otherwise
        -- leave detailed learning information to the Guide instead of filler.
        if gear.recipeLearnMethod=="pattern" then
            return nil
        end
        if gear.recipeLearnMethod=="initial" then
            return "Recipe included when learning the profession (client-listed)."
        end
        -- Trainer recipes are already labelled "Profession - Trainer" in the
        -- MATERIALS header, or "Learned" if the client knows the recipe.
        return nil
    end
    -- Source names may contain periods (Mr. Smite) or ellipses in quest
    -- titles (What Comes Around...). Never split on punctuation: the
    -- overlay description text wraps, with its height measured dynamically.
    local source = tostring(gear.source or gear.sourceType or "Unknown source")
    local short=source:match("^([^\r\n]+)") or source
    local last=short:sub(-1)
    local text="Source: "..short..((last=="." or last=="!" or last=="?") and "" or ".")
    if (gear.confidence=="classic-reference"
        or gear.acquisitionConfidence=="classic-reference")
        and not source:lower():find("classic",1,true)
        and not source:lower():find("unverified",1,true)
        and not source:lower():find("unconfirmed",1,true) then
        text=text.." Source not yet verified in Forever."
    end
    return text
end

-- Benefit icons deliberately use client-bundled Blizzard icon art.
local function NewBenefit(parent)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetSize(282, 22)
    local texture = holder:CreateTexture(nil, "ARTWORK")
    texture:SetSize(19, 19)
    texture:SetPoint("LEFT", 0, 0)
    local label = NewText(holder, "GameFontHighlightSmall", 251)
    label:SetPoint("LEFT", texture, "RIGHT", 7, 0)
    holder.icon, holder.label = texture, label
    return holder
end

local function SetBenefit(widget, benefit, x, y, parent)
    widget:ClearAllPoints()
    widget:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
    widget.icon:SetTexture(benefit.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    widget.label:SetText(benefit.text)
    widget:Show()
end

local function NewReagent(parent, compact)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetSize(compact and 292 or 324, compact and 27 or 34)
    local quantity = NewText(holder, compact and "GameFontHighlightSmall" or "GameFontNormal", compact and 43 or 42, "RIGHT")
    quantity:SetPoint("LEFT", 0, 0)
    local icon = NewIcon(holder, compact and 22 or 29)
    icon:SetPoint("LEFT", quantity, "RIGHT", compact and 5 or 7, 0)
    local arrow = CreateFrame("Button", nil, holder)
    arrow:SetSize(18, 18)
    -- Anchored beside the reagent name in UpdateReagent. Do not reserve a
    -- column before the name: all top-level quantities/icons/names align.
    -- No opaque box: gold arrow on a transparent 18px hit area.
    local arrowGlyph = NewText(arrow, "GameFontNormalSmall", 18, "CENTER")
    arrowGlyph:SetPoint("CENTER",0,0)
    arrowGlyph:SetTextColor(1,0.76,0.33)
    arrow.arrowGlyph = arrowGlyph
    arrow:SetScript("OnEnter", function(self)
        arrowGlyph:SetTextColor(1, 0.94, 0.62)
        GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
        GameTooltip:AddLine(self.collapsed and "Expand ingredients" or "Collapse ingredients",1,0.82,0.35)
        GameTooltip:Show()
    end)
    arrow:SetScript("OnLeave",function()
        arrowGlyph:SetTextColor(1,0.76,0.33)
        HideItemTooltip()
    end)
    local name = NewText(holder, "GameFontHighlightSmall", compact and 198 or 239)
    name:SetPoint("LEFT",icon,"RIGHT",7,0)
    local hit = CreateFrame("Button", nil, holder)
    hit:SetPoint("TOPLEFT", name, "TOPLEFT", 0, 4)
    hit:SetSize(compact and 194 or 225, compact and 26 or 30)
    hit:SetScript("OnEnter", ShowItemTooltip)
    hit:SetScript("OnLeave", HideItemTooltip)
    return {frame=holder, count=quantity, icon=icon, name=name, hit=hit, arrow=arrow, compact=compact}
end

local function UpdateReagent(widget, mat, x, y, parent, aggregated, previewMode)
    widget.frame:ClearAllPoints()
    widget.frame:SetPoint("TOPLEFT", parent, "TOPLEFT", x, -y)
    local parentWidth = (parent.GetWidth and parent:GetWidth()) or 316
    local available = math.max(185, parentWidth - x - 8)
    widget.frame:SetWidth(available)
    SetItemIcon(widget.icon, mat.itemID, mat, aggregated)
    widget.hit.itemID, widget.hit.material, widget.hit.aggregate = mat.itemID, mat, aggregated
    local function ToggleReagent()
        if GetGear.db and mat.collapseKey then
            local setting=GetGear.db.overlay.dependencyExpanded
            setting[mat.collapseKey]=not setting[mat.collapseKey] or nil
            GetGear:RefreshAll()
        end
    end
    widget.name:ClearAllPoints()
    -- The icon/name column is aligned on every top-level material row. Only
    -- true crafting dependencies are indented (via the x value passed in).
    widget.name:SetPoint("LEFT",widget.icon,"RIGHT",7,0)
    local leftSpace = (widget.compact and (43+5+22+7) or (42+7+29+7))
    local expandable = mat.hasChildren and mat.collapseKey
    local maxNameWidth = math.max(65,available-leftSpace-(expandable and 25 or 5))
    widget.name:SetWidth(maxNameWidth)
    local materialLabel=mat.name
    if not previewMode and not widget.compact and GetGear.GetAltMaterialSummary then
        local stock=GetGear:GetAltMaterialSummary(mat.itemID)
        if stock and stock.bank+stock.alts>0 then
            materialLabel=materialLabel.." |cff91bedb(bank "..stock.bank..", alts "..stock.alts..")|r"
        end
    end
    widget.name:SetText(materialLabel)
    if expandable and not previewMode then
        widget.arrow.collapsed = mat.collapsed
        widget.arrow.arrowGlyph:SetText(mat.collapsed and ">" or "v")
        widget.arrow:SetScript("OnClick",ToggleReagent)
        -- Keep the arrow immediately after the visible name, not right-justified.
        -- First measure at the available width, then constrain if necessary.
        local measured = widget.name:GetStringWidth() or maxNameWidth
        widget.name:SetWidth(math.max(50,math.min(maxNameWidth,math.ceil(measured)+2)))
        widget.arrow:ClearAllPoints()
        widget.arrow:SetPoint("LEFT",widget.name,"RIGHT",3,0)
        widget.arrow:Show()
        widget.hit:SetScript("OnClick",ToggleReagent)
    else
        widget.arrow:Hide()
        widget.hit:SetScript("OnClick",nil)
    end
    widget.hit:SetWidth(widget.name:GetWidth())
    local have = previewMode and nil or GetGear:GetMaterialCount(mat.itemID)
    if previewMode then
        widget.count:SetText(tostring(mat.amount) .. " x")
        widget.count:SetTextColor(1, 0.79, 0.40)
        widget.name:SetTextColor(0.89, 0.89, 0.89)
        widget.icon.texture:SetDesaturated(false)
        widget.icon.texture:SetVertexColor(1, 1, 1)
    else
        widget.count:SetText((have == nil and "?" or tostring(have)) .. "/" .. tostring(mat.amount))
    end
    if not previewMode and have ~= nil and have >= mat.amount then
        widget.count:SetTextColor(0.38, 0.90, 0.53)
        widget.name:SetTextColor(0.43, 0.89, 0.57)
        widget.icon.texture:SetDesaturated(false)
        widget.icon.texture:SetVertexColor(1, 1, 1)
    elseif not previewMode then
        widget.count:SetTextColor(1, 0.79, 0.40)
        widget.name:SetTextColor(0.89, 0.89, 0.89)
        widget.icon.texture:SetDesaturated(true)
        widget.icon.texture:SetVertexColor(0.78, 0.78, 0.78)
    end
    widget.frame:Show()
end

-- Native resizing with a small, discoverable bottom-right grab handle.
local function AllowResizing(frame,minW,minH,maxW,maxH)
    frame:SetResizable(true)
    if type(frame.SetResizeBounds)=="function" then
        frame:SetResizeBounds(minW,minH,maxW,maxH)
    else
        if type(frame.SetMinResize)=="function" then frame:SetMinResize(minW,minH) end
        if type(frame.SetMaxResize)=="function" then frame:SetMaxResize(maxW,maxH) end
    end
    local grip=CreateFrame("Button",nil,frame)
    grip:SetSize(21,21)
    grip:SetPoint("BOTTOMRIGHT", -2, 2)
    grip:SetFrameLevel(frame:GetFrameLevel()+15)
    grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    grip:SetScript("OnMouseDown",function(self,button)
        if button=="LeftButton" then frame.isSizing=true;frame:StartSizing("BOTTOMRIGHT") end
    end)
    grip:SetScript("OnMouseUp",function(self,button)
        if button=="LeftButton" and frame.isSizing then
            frame:StopMovingOrSizing()
            frame.isSizing=false
            if frame.afterResize then frame:afterResize() end
        end
    end)
    grip:SetScript("OnHide",function()
        if frame.isSizing then frame:StopMovingOrSizing();frame.isSizing=false end
    end)
    grip:SetScript("OnUpdate",function()
        if frame.isSizing and type(IsMouseButtonDown)=="function" and not IsMouseButtonDown("LeftButton") then
            frame:StopMovingOrSizing()
            frame.isSizing=false
            if frame.afterResize then frame:afterResize() end
        end
    end)
    return grip
end

-- =====================================================================
-- Detailed planning window: useful for descriptions, hidden items and settings.
-- =====================================================================
local window = CreateFrame("Frame", "GetGear_MainWindow", UIParent, "BasicFrameTemplateWithInset")
window:SetSize(780, 608)
-- The detailed guide is a foreground planning window, not part of the
-- translucent tracker. DIALOG sits above normal bag/addon frames while
-- higher strata remain available to Blizzard confirmations and tooltips.
window:SetFrameStrata("DIALOG")
if window.SetToplevel then window:SetToplevel(true) end
-- The Blizzard BasicFrameTemplate has translucent regions. An opaque BACKGROUND
-- texture fills the entire frame behind its title bar, borders and content,
-- so UI windows underneath cannot bleed through the guide. It is deliberately
-- independent of the tracker backgroundOpacity slider.
local detailBackdrop = window:CreateTexture(nil, "BACKGROUND", nil, -8)
detailBackdrop:SetAllPoints(window)
detailBackdrop:SetColorTexture(0.045, 0.065, 0.10, 1)
if window.SetClampedToScreen then window:SetClampedToScreen(true) end
window:SetPoint("CENTER")
window:SetMovable(true)
window:EnableMouse(true)
-- Do not make the entire guide draggable. A large drag target can accidentally
-- engage WoW's mouse capture when clicking/Alt-Tabbing across the window.
-- Restrict movement to its title bar; the close button is not covered.
local titleDrag=CreateFrame("Button",nil,window)
titleDrag:SetPoint("TOPLEFT",window,"TOPLEFT",26,-3)
titleDrag:SetPoint("TOPRIGHT",window,"TOPRIGHT",-52,-3)
titleDrag:SetHeight(23)
titleDrag:SetFrameLevel(window:GetFrameLevel()+4)
local titleDragging=false
local function StopTitleDrag()
    if not titleDragging then return end
    titleDragging=false
    window:StopMovingOrSizing()
    if GetGear.db then
        GetGear.db.detail.x, GetGear.db.detail.y = window:GetLeft(), window:GetTop()
    end
end
titleDrag:SetScript("OnMouseDown",function(self,button)
    if button=="LeftButton" and not titleDragging then
        titleDragging=true
        window:StartMoving()
    end
end)
titleDrag:SetScript("OnMouseUp",function(self,button)
    if button=="LeftButton" then StopTitleDrag() end
end)
titleDrag:SetScript("OnUpdate",function()
    if titleDragging and type(IsMouseButtonDown)=="function" and not IsMouseButtonDown("LeftButton") then
        StopTitleDrag()
    end
end)
titleDrag:SetScript("OnHide",StopTitleDrag)
window:Hide()
if window.TitleText then window.TitleText:SetText("GetGear") end
if UISpecialFrames then table.insert(UISpecialFrames, "GetGear_MainWindow") end

local levelText = NewText(window, "GameFontNormalLarge")
levelText:SetPoint("TOPLEFT", 18, -36)
local subtitle = NewText(window, "GameFontHighlightSmall", 720)
subtitle:SetPoint("TOPLEFT", levelText, "BOTTOMLEFT", 0, -7)
subtitle:SetText("Hover icons for stats. Equipped items appear in Completed; older outclassed gear in Earlier Gear. Neither changes saved statuses.")

-- Session-only detailed-window planning state. Never saved and never used
-- in GetGear.Gear / GetItems / RefreshOverlay or character progression.
local preview = {active=false, classToken="ROGUE", spec="All", level=30, full=true}
local previewClasses = {
    "PRIEST", "WARLOCK", "MAGE", "DRUID", "WARRIOR",
    "ROGUE", "PALADIN", "HUNTER", "SHAMAN",
}
local previewNames = {
    PRIEST="Priest", WARLOCK="Warlock", MAGE="Mage", DRUID="Druid",
    WARRIOR="Warrior", ROGUE="Rogue", PALADIN="Paladin",
    HUNTER="Hunter", SHAMAN="Shaman",
}
local function PreviewEntries()
    local all = GetGear:GetPreviewRecommendations(preview.classToken, preview.spec)
    local visible = {}
    for _, gear in ipairs(all) do
        if preview.full or (gear.targetLevel and gear.targetLevel <= preview.level) then
            visible[#visible+1] = gear
        end
    end
    table.sort(visible, function(a,b)
        if a.targetLevel ~= b.targetLevel then return a.targetLevel < b.targetLevel end
        if (a.slot or "") ~= (b.slot or "") then return (a.slot or "") < (b.slot or "") end
        if (a.name or "") ~= (b.name or "") then return (a.name or "") < (b.name or "") end
        return (a.itemID or 0) < (b.itemID or 0)
    end)
    return visible
end

local scroll
local tabs, tabNames = {}, {
    -- Navigation belongs on the top row in progression order; stay within
    -- the 720px minimum window width (666px including 5px gaps).
    {"earlier", "Earlier Gear", 108}, {"available", "Available Now", 102},
    {"upcoming", "Next 5 Levels", 126}, {"completed", "Completed / Skipped", 151},
    {"hidden", "Hidden", 78}, {"bags", "Bags", 76},
}
for i, entry in ipairs(tabNames) do
    local btn = NewButton(window, entry[2], entry[3], 24)
    if i == 1 then btn:SetPoint("TOPLEFT", 18, -91)
    else btn:SetPoint("LEFT", tabs[i-1], "RIGHT", 5, 0) end
    local tab = entry[1]
    btn:SetScript("OnClick", function()
        GetGear.activeTab = tab
        scroll:SetVerticalScroll(0)
        GetGear:RefreshUI()
    end)
    tabs[i] = btn
end
-- Manual specialization selector. It cycles planning profiles; it does not
-- inspect talents or assume a particular Forever specialization API.
local specButton = NewButton(window, "All specs", 101, 24)
specButton:SetPoint("TOPLEFT", 18, -122)
specButton:SetScript("OnClick", function()
    if GetGear:NextSpecialization() then
        scroll:SetVerticalScroll(0)
        GetGear:RefreshUI()
    end
end)
specButton:SetScript("OnEnter", function(self)
    if not GameTooltip then return end
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    GameTooltip:AddLine("Gear recommendation profile",1,0.82,0.35)
    GameTooltip:AddLine("Click to cycle specialization profiles. This is a manual preference, not detected talents.",1,1,1,true)
    GameTooltip:AddLine("Or type /getgear spec <name>",0.8,0.86,1)
    GameTooltip:Show()
end)
specButton:SetScript("OnLeave", HideItemTooltip)
local optionsButton = NewButton(window, "Display settings", 130, 24)
optionsButton:SetPoint("TOPLEFT", 124, -122)
optionsButton:SetScript("OnClick", function() GetGear:ShowSettings() end)

-- Preview controls exist ONLY in the detailed guide, not the tracker overlay.
local startPreview = NewButton(window, "Preview guide", 126, 24)
startPreview:SetPoint("TOPLEFT", 260, -122)
-- Detailed-window-only entry point for cached bags/bank diagnostics.
local altInventoryButton = NewButton(window, "Alt inventory", 126, 24)
altInventoryButton:SetPoint("TOPLEFT", 392, -122)
altInventoryButton:SetScript("OnClick", function()
    if GetGear.ShowAltInventoryBrowser then GetGear:ShowAltInventoryBrowser() end
end)
altInventoryButton:SetScript("OnEnter", function(self)
    if not GameTooltip then return end
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    GameTooltip:AddLine("Account inventory tracker",1,0.83,0.35)
    GameTooltip:AddLine("Open the searchable inventory browser inside this guide.",1,1,1,true)
    GameTooltip:AddLine("View bags, banks and saved alt inventories. Click an item for a character breakdown.",0.75,0.84,1,true)
    GameTooltip:Show()
end)
altInventoryButton:SetScript("OnLeave", HideItemTooltip)
local previewHeading = NewText(window, "GameFontNormal", 462)
previewHeading:SetPoint("TOPLEFT", 18, -96)
previewHeading:SetText("|cffedc774GUIDE PREVIEW|r  |cffb6c3d3(read-only)|r")
local exitPreview = NewButton(window, "Return to character", 137, 24)
exitPreview:SetPoint("TOPLEFT", 489, -91)
local previewClassButton = NewButton(window, "Class: Rogue", 151, 24)
previewClassButton:SetPoint("TOPLEFT", 18, -122)
local previewSpecButton = NewButton(window, "Spec: All", 147, 24)
previewSpecButton:SetPoint("TOPLEFT", 176, -122)
local previewMinus = NewButton(window, "-", 28, 24)
previewMinus:SetPoint("TOPLEFT", 329, -122)
local previewLevelLabel = NewText(window, "GameFontHighlightSmall", 24)
previewLevelLabel:SetPoint("TOPLEFT", 360, -126)
previewLevelLabel:SetText("Lv")
local previewLevel = CreateFrame("EditBox", nil, window, "InputBoxTemplate")
previewLevel:SetSize(45, 22)
previewLevel:SetPoint("TOPLEFT", 389, -122)
previewLevel:SetAutoFocus(false)
previewLevel:SetNumeric(true)
previewLevel:SetMaxLetters(2)
previewLevel:SetText("30")
local previewPlus = NewButton(window, "+", 28, 24)
previewPlus:SetPoint("TOPLEFT", 441, -122)
local previewFullButton = NewButton(window, "Full 1-30: ON", 156, 24)
previewFullButton:SetPoint("TOPLEFT", 477, -122)

startPreview:SetScript("OnClick", function()
    preview.active = true
    preview.classToken = GetGear.GuideDefinitions[GetGear.classToken] and GetGear.classToken or "ROGUE"
    preview.spec = "All"
    preview.level = 30
    preview.full = true
    scroll:SetVerticalScroll(0)
    GetGear:RefreshUI()
end)
exitPreview:SetScript("OnClick", function()
    preview.active = false
    scroll:SetVerticalScroll(0)
    GetGear:RefreshUI()
end)
previewClassButton:SetScript("OnClick", function()
    for i, class in ipairs(previewClasses) do
        if class == preview.classToken then
            preview.classToken = previewClasses[(i % #previewClasses)+1]
            preview.spec = "All"
            break
        end
    end
    scroll:SetVerticalScroll(0)
    GetGear:RefreshUI()
end)
previewSpecButton:SetScript("OnClick", function()
    local choices=GetGear:GetSpecializationChoices(preview.classToken)
    for i, choice in ipairs(choices) do
        if choice == preview.spec then
            preview.spec = choices[(i % #choices)+1]
            break
        end
    end
    scroll:SetVerticalScroll(0)
    GetGear:RefreshUI()
end)
local function SetPreviewLevel(delta)
    preview.level = math.max(1, math.min(30, preview.level+delta))
    preview.full = false
    scroll:SetVerticalScroll(0)
    GetGear:RefreshUI()
end
previewMinus:SetScript("OnClick", function() SetPreviewLevel(-1) end)
previewPlus:SetScript("OnClick", function() SetPreviewLevel(1) end)
previewLevel:SetScript("OnEnterPressed", function(self)
    local chosen = tonumber(self:GetText())
    if chosen then
        preview.level = math.max(1, math.min(30, math.floor(chosen)))
        preview.full = false
        scroll:SetVerticalScroll(0)
    end
    self:ClearFocus()
    GetGear:RefreshUI()
end)
previewLevel:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
    self:SetText(tostring(preview.level))
end)
previewFullButton:SetScript("OnClick", function()
    preview.full = not preview.full
    scroll:SetVerticalScroll(0)
    GetGear:RefreshUI()
end)
previewClassButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    GameTooltip:AddLine("Cycle through all nine class guides",1,0.82,0.35)
    GameTooltip:AddLine("A race-restricted item is marked in its description.",1,1,1,true)
    GameTooltip:Show()
end)
previewClassButton:SetScript("OnLeave",HideItemTooltip)
previewSpecButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    GameTooltip:AddLine("Cycle specialization filters",1,0.82,0.35)
    GameTooltip:AddLine("This does not change your character's saved spec.",1,1,1,true)
    GameTooltip:Show()
end)
previewSpecButton:SetScript("OnLeave",HideItemTooltip)

local statusText = NewText(window, "GameFontHighlightSmall", 720, "RIGHT")
statusText:SetPoint("TOPRIGHT", -38, -151)
scroll = CreateFrame("ScrollFrame", nil, window, "UIPanelScrollFrameTemplate")
scroll:SetPoint("TOPLEFT", 17, -185)
scroll:SetPoint("BOTTOMRIGHT", -35, 15)
local content = CreateFrame("Frame", nil, scroll)
content:SetSize(720, 400)
scroll:SetScrollChild(content)

-- Detailed-window-only account inventory browser. It reads the existing
-- account snapshots and does not store state or modify character checklists.
local inventoryMode=false
local inventoryScope="eligible"
local inventorySearch=""
local inventorySelectedID=nil
local inventoryResults={}
local inventoryMeta={}
local inventoryChoices={}

local inventoryView=CreateFrame("Frame",nil,window)
inventoryView:SetAllPoints(window)
inventoryView:Hide()
local inventoryTitle=NewText(inventoryView,"GameFontNormalLarge",390)
inventoryTitle:SetPoint("TOPLEFT",18,-94)
inventoryTitle:SetText("ACCOUNT INVENTORY")
local inventoryBack=NewButton(inventoryView,"Return to guide",145,24)
inventoryBack:SetPoint("TOPRIGHT",-18,-90)
local inventoryScopeButton=NewButton(inventoryView,"Scope: Same realm/faction",300,25)
inventoryScopeButton:SetPoint("TOPLEFT",18,-130)
local inventorySearchLabel=NewText(inventoryView,"GameFontHighlightSmall",82)
inventorySearchLabel:SetPoint("LEFT",inventoryScopeButton,"RIGHT",12,0)
inventorySearchLabel:SetText("Find item:")
local inventorySearchBox=CreateFrame("EditBox",nil,inventoryView,"InputBoxTemplate")
inventorySearchBox:SetPoint("LEFT",inventorySearchLabel,"RIGHT",6,0)
inventorySearchBox:SetPoint("RIGHT",inventoryView,"RIGHT",-26,0)
inventorySearchBox:SetHeight(24)
inventorySearchBox:SetAutoFocus(false)
inventorySearchBox:SetMaxLetters(80)
local inventoryHelp=NewText(inventoryView,"GameFontHighlightSmall",730)
inventoryHelp:SetPoint("TOPLEFT",18,-166)
inventoryHelp:SetText("Last-known snapshots. Visit a character and open its bank to refresh counts.")
local inventoryStatus=NewText(inventoryView,"GameFontHighlightSmall",730)
inventoryStatus:SetPoint("TOPLEFT",18,-184)

local inventoryDetailPanel=CreateFrame("Frame",nil,inventoryView)
inventoryDetailPanel:SetWidth(254)
inventoryDetailPanel:SetPoint("TOPRIGHT",-18,-237)
inventoryDetailPanel:SetPoint("BOTTOMRIGHT",-18,20)
local inventoryPanelBackground=inventoryDetailPanel:CreateTexture(nil,"BACKGROUND")
inventoryPanelBackground:SetAllPoints()
inventoryPanelBackground:SetColorTexture(0.075,0.105,0.17,0.95)
-- The selected-character list uses the same stock scroll template as the
-- item list/overlay. Its scroll bar sits against the RIGHT edge of this blue
-- panel, so reserve a dark track for it rather than painting blue behind it.
local inventoryDetailScrollGutter=inventoryDetailPanel:CreateTexture(nil,"BORDER")
inventoryDetailScrollGutter:SetPoint("TOPRIGHT",inventoryDetailPanel,"TOPRIGHT",0,0)
inventoryDetailScrollGutter:SetPoint("BOTTOMRIGHT",inventoryDetailPanel,"BOTTOMRIGHT",0,0)
inventoryDetailScrollGutter:SetWidth(29)
inventoryDetailScrollGutter:SetColorTexture(0.025,0.035,0.055,0.98)
local selectedScroll=CreateFrame("ScrollFrame",nil,inventoryDetailPanel,"UIPanelScrollFrameTemplate")
selectedScroll:SetPoint("TOPLEFT",8,0)
selectedScroll:SetPoint("BOTTOMRIGHT",-27,0)
local selectedContent=CreateFrame("Frame",nil,selectedScroll)
selectedContent:SetSize(215,200)
selectedScroll:SetScrollChild(selectedContent)
-- Put selected-item summary within the scrollable content.
local selectedTitle=NewText(selectedContent,"GameFontNormal",200)
selectedTitle:SetPoint("TOPLEFT",2,-10)
local selectedTotals=NewText(selectedContent,"GameFontHighlightSmall",200)
selectedTotals:SetPoint("TOPLEFT",2,-32)
local selectedNote=NewText(selectedContent,"GameFontHighlightSmall",200)
selectedNote:SetPoint("TOPLEFT",2,-52)
selectedNote:SetTextColor(0.70,0.79,0.89)
local selectedRows={}

local inventoryListScroll=CreateFrame("ScrollFrame",nil,inventoryView,"UIPanelScrollFrameTemplate")
inventoryListScroll:SetPoint("TOPLEFT",18,-237)
-- UIPanelScrollFrameTemplate places its 16px scrollbar 6px OUTSIDE the
-- scroll frame. Reserve space for it plus a clear gutter to the right panel.
inventoryListScroll:SetPoint("BOTTOMRIGHT",inventoryDetailPanel,"BOTTOMLEFT",-38,0)
local inventoryListContent=CreateFrame("Frame",nil,inventoryListScroll)
inventoryListContent:SetSize(440,300)
inventoryListScroll:SetScrollChild(inventoryListContent)
local inventoryHeadItem=NewText(inventoryView,"GameFontNormalSmall",200)
inventoryHeadItem:SetPoint("BOTTOMLEFT",inventoryListScroll,"TOPLEFT",35,4)
inventoryHeadItem:SetText("ITEM")
local inventoryHeadBags=NewText(inventoryView,"GameFontNormalSmall",45,"RIGHT")
inventoryHeadBags:SetPoint("BOTTOMRIGHT",inventoryListScroll,"TOPRIGHT",-124,4)
inventoryHeadBags:SetText("BAGS")
local inventoryHeadBank=NewText(inventoryView,"GameFontNormalSmall",45,"RIGHT")
inventoryHeadBank:SetPoint("BOTTOMRIGHT",inventoryListScroll,"TOPRIGHT",-76,4)
inventoryHeadBank:SetText("BANK")
local inventoryHeadTotal=NewText(inventoryView,"GameFontNormalSmall",48,"RIGHT")
inventoryHeadTotal:SetPoint("BOTTOMRIGHT",inventoryListScroll,"TOPRIGHT",-27,4)
inventoryHeadTotal:SetText("TOTAL")
local inventoryEmpty=NewText(inventoryListContent,"GameFontHighlightSmall",380)
inventoryEmpty:SetPoint("TOPLEFT",13,-20)
local inventoryRowHeight=37
local inventoryRows={}
local RefreshInventoryBrowser,RefreshSelectedItem,RenderInventoryRows

local function InventoryScopeName(scope)
    if scope=="eligible" then return "Same realm/faction" end
    if scope=="current" then return "Current character" end
    if scope=="alts" then return "Eligible alts" end
    if scope=="other" then return "Other realms/factions" end
    if scope=="all" then return "All saved characters*" end
    for _,c in ipairs(inventoryChoices) do
        if scope==c.key then return c.name.." ("..c.realm..")" end
    end
    return "Same realm/faction"
end

local function InventoryRow(index)
    local row=CreateFrame("Button",nil,inventoryListContent)
    row:SetSize(445,inventoryRowHeight-1)
    local bg=row:CreateTexture(nil,"BACKGROUND")
    bg:SetAllPoints()
    row.bg=bg
    local icon=NewIcon(row,27)
    -- Let the entire row (including the icon) receive selection clicks.
    icon:EnableMouse(false)
    icon:SetPoint("LEFT",5,0)
    local name=NewText(row,"GameFontHighlightSmall",180)
    name:SetPoint("LEFT",icon,"RIGHT",8,0)
    local bags=NewText(row,"GameFontHighlightSmall",42,"RIGHT")
    bags:SetPoint("RIGHT",row,"RIGHT",-105,0)
    local bank=NewText(row,"GameFontHighlightSmall",42,"RIGHT")
    bank:SetPoint("RIGHT",row,"RIGHT",-57,0)
    local total=NewText(row,"GameFontNormalSmall",46,"RIGHT")
    total:SetPoint("RIGHT",row,"RIGHT",-8,0)
    row:SetScript("OnClick",function(self)
        inventorySelectedID=self.itemID
        RefreshSelectedItem()
        RenderInventoryRows()
    end)
    row:SetScript("OnEnter",function(self)
        if not self.itemID then return end
        self.bg:SetColorTexture(0.17,0.24,0.34,1)
        if GameTooltip then
            GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
            if type(GameTooltip.SetItemByID)=="function" then
                GameTooltip:SetItemByID(self.itemID)
            else
                GameTooltip:SetHyperlink("item:"..tostring(self.itemID))
            end
            GameTooltip:AddLine("Click for saved character locations",0.67,0.84,1)
            GameTooltip:Show()
        end
    end)
    row:SetScript("OnLeave",function(self)
        HideItemTooltip()
        if self.itemID==inventorySelectedID then
            self.bg:SetColorTexture(0.14,0.21,0.31,1)
        else
            self.bg:SetColorTexture(0.08,0.12,0.19,self.rowNumber%2==0 and 0.95 or 0.76)
        end
    end)
    inventoryRows[index]={frame=row,icon=icon,name=name,bags=bags,bank=bank,total=total}
end
for i=1,32 do InventoryRow(i) end

local function InventoryTimestamp(at)
    return GetGear.AltInventory and GetGear.AltInventory:FormatScanTime(at) or "never"
end

RefreshSelectedItem=function()
    local item=nil
    for _,entry in ipairs(inventoryResults) do
        if entry.itemID==inventorySelectedID then item=entry;break end
    end
    for _,entry in ipairs(selectedRows) do entry:Hide() end
    if not item then
        selectedTitle:SetText("Select an item")
        selectedTotals:SetText("Click an item on the left")
        selectedNote:SetText("See exactly which character holds it")
        selectedContent:SetHeight(90)
        return
    end
    selectedTitle:SetText(item.name)
    local incomplete=inventoryMeta.missingBanks>0 or inventoryMeta.missingBags>0 or inventoryMeta.partialBanks>0
    selectedTotals:SetText("Bags "..item.bags.."  |  Bank "..item.bank.."  |  Known total "..item.total)
    selectedNote:SetText(incomplete and "Some snapshots missing: totals are minimums." or "Last-known quantities, not live transfers.")
    for i,loc in ipairs(item.locations) do
        local row=selectedRows[i]
        if not row then
            row=CreateFrame("Frame",nil,selectedContent)
            row:SetWidth(213)
            local title=NewText(row,"GameFontNormalSmall",208)
            title:SetPoint("TOPLEFT",2,-2)
            local counts=NewText(row,"GameFontHighlightSmall",208)
            counts:SetPoint("TOPLEFT",2,-20)
            local ages=NewText(row,"GameFontHighlightSmall",208)
            ages:SetPoint("TOPLEFT",2,-38)
            row.title=title;row.counts=counts;row.ages=ages
            selectedRows[i]=row
        end
        row:SetHeight(60)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT",selectedContent,"TOPLEFT",0,-90-(i-1)*60)
        row.title:SetText(loc.name..(loc.eligible and "" or " |cffffb366(other realm/faction)|r"))
        row.counts:SetText("Bags "..loc.bags.."  |  Bank "..(loc.bankKnown and tostring(loc.bank) or "?") )
        row.ages:SetText("Bag "..InventoryTimestamp(loc.bagsAt).."; Bank "..InventoryTimestamp(loc.bankAt))
        row:Show()
    end
    selectedContent:SetHeight(math.max(90,90+#item.locations*60))
end

RenderInventoryRows=function()
    local width=math.max(330,(inventoryListScroll:GetWidth() or 440)-19)
    inventoryListContent:SetWidth(width)
    local offset=math.max(0,math.floor((inventoryListScroll:GetVerticalScroll() or 0)/inventoryRowHeight))
    for i,row in ipairs(inventoryRows) do
        local index=offset+i
        local entry=inventoryResults[index]
        if entry then
            row.frame:ClearAllPoints()
            row.frame:SetPoint("TOPLEFT",inventoryListContent,"TOPLEFT",0,-(index-1)*inventoryRowHeight)
            row.frame:SetWidth(width)
            row.name:SetWidth(math.max(80,width-202))
            row.rowNumber=index
            row.frame.rowNumber=index
            row.frame.itemID=entry.itemID
            SetItemIcon(row.icon,entry.itemID)
            row.name:SetText(entry.name)
            row.bags:SetText(tostring(entry.bags)..(inventoryMeta.missingBags>0 and "+" or ""))
            row.bank:SetText(tostring(entry.bank)..((inventoryMeta.missingBanks>0 or inventoryMeta.partialBanks>0) and "+" or ""))
            row.total:SetText(tostring(entry.total)..((inventoryMeta.missingBags>0 or inventoryMeta.missingBanks>0 or inventoryMeta.partialBanks>0) and "+" or ""))
            if entry.itemID==inventorySelectedID then
                row.frame.bg:SetColorTexture(0.14,0.21,0.31,1)
            else
                row.frame.bg:SetColorTexture(0.08,0.12,0.19,index%2==0 and 0.95 or 0.76)
            end
            row.frame:Show()
        else
            row.frame:Hide()
            row.frame.itemID=nil
        end
    end
    inventoryEmpty:SetWidth(width-25)
    if #inventoryResults==0 then
        inventoryEmpty:SetText(inventorySearch~="" and "No matching items. Try another search." or
            "No saved items in this scope. Log onto a character, then open its bank to scan.")
        inventoryEmpty:Show()
    else inventoryEmpty:Hide() end
end

RefreshInventoryBrowser=function(resetScroll)
    if not inventoryMode then return end
    if not (GetGear.AltInventory and GetGear.AltInventory.BrowseItems) then return end
    inventoryChoices=GetGear.AltInventory:BrowserCharacters()
    inventoryResults,inventoryMeta=GetGear.AltInventory:BrowseItems(inventoryScope,inventorySearch)
    inventoryScopeButton:SetText("Scope: "..InventoryScopeName(inventoryScope))
    inventoryStatus:SetText(#inventoryResults.." items  |  "..#inventoryMeta.characters.." character(s)  |  "
        ..inventoryMeta.missingBanks.." bank(s) unscanned"
        ..(inventoryMeta.missingBags>0 and ("  |  "..inventoryMeta.missingBags.." bag(s) unscanned") or "")
        ..(inventoryMeta.partialBanks>0 and ("  |  "..inventoryMeta.partialBanks.." partial bank(s)") or ""))
    inventoryHelp:SetText(inventoryScope=="all" and
        "*Different realms/factions are combined for browsing only; transfers are not guaranteed."
        or "Click an item for locations and scan dates. A + means some inventories are unscanned.")
    if resetScroll then inventoryListScroll:SetVerticalScroll(0) end
    inventoryListContent:SetHeight(math.max(50,#inventoryResults*inventoryRowHeight))
    local present=false
    for _,entry in ipairs(inventoryResults) do
        if entry.itemID==inventorySelectedID then present=true;break end
    end
    if not present then inventorySelectedID=inventoryResults[1] and inventoryResults[1].itemID or nil end
    RenderInventoryRows()
    RefreshSelectedItem()
end

inventoryListScroll:HookScript("OnVerticalScroll",function() RenderInventoryRows() end)
inventorySearchBox:SetScript("OnTextChanged",function(self)
    inventorySearch=self:GetText() or ""
    RefreshInventoryBrowser(true)
end)
inventorySearchBox:SetScript("OnEscapePressed",function(self) self:ClearFocus() end)
inventorySearchBox:SetScript("OnEnterPressed",function(self) self:ClearFocus() end)
inventoryScopeButton:SetScript("OnClick",function()
    local order={"eligible","current","alts","other","all"}
    for _,c in ipairs(inventoryChoices) do order[#order+1]=c.key end
    local index=1
    for i,key in ipairs(order) do if key==inventoryScope then index=i;break end end
    inventoryScope=order[(index%#order)+1]
    RefreshInventoryBrowser(true)
end)
inventoryScopeButton:SetScript("OnEnter",function(self)
    if not GameTooltip then return end
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    GameTooltip:AddLine("Inventory scope",1,0.84,0.42)
    GameTooltip:AddLine("Click to cycle current character, eligible alts, other characters, and individual saved characters.",1,1,1,true)
    GameTooltip:AddLine("Combined transferable totals use same-realm/faction only; all-character mode is for reference.",0.78,0.84,0.91,true)
    GameTooltip:Show()
end)
inventoryScopeButton:SetScript("OnLeave",HideItemTooltip)
inventoryBack:SetScript("OnClick",function()
    inventoryMode=false
    GetGear:RefreshUI()
end)
function GetGear:ShowAltInventoryBrowser()
    if not self.db then return end
    preview.active=false
    inventoryMode=true
    inventoryScope="eligible"
    inventorySearch=""
    inventorySelectedID=nil
    inventorySearchBox:SetText("")
    self:RefreshUI()
end

local detailRows = {}
local function NewDetailRow(i)
    local frame = CreateFrame("Frame", nil, content)
    frame:SetSize(717, 160)
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.07, 0.10, 0.16, i % 2 == 0 and 0.76 or 0.92)
    local item = NewIcon(frame, 41)
    item:SetPoint("TOPLEFT", 10, -13)
    local name = NewText(frame, "GameFontNormal", 492)
    name:SetPoint("TOPLEFT", 62, -12)
    local meta = NewText(frame, "GameFontHighlightSmall", 510)
    meta:SetPoint("TOPLEFT", 62, -34)

    local levelHeader = NewText(frame, "GameFontHighlightSmall", 55, "CENTER")
    levelHeader:SetPoint("TOPRIGHT", -12, -11)
    levelHeader:SetText("LEVEL")
    local levelValue = NewText(frame, "GameFontNormal", 55, "CENTER")
    levelValue:SetPoint("TOP", levelHeader, "BOTTOM", 0, -3)

    local metaSourceIcon = NewProfessionIcon(frame, 18)
    local metaRest = NewText(frame, "GameFontHighlightSmall", 390)
    local professionIcon = NewProfessionIcon(frame,18)
    local profession = NewText(frame, "GameFontHighlightSmall", 150)
    local desc = NewText(frame, "GameFontHighlightSmall", 636)
    local benefits = {}
    local comparison = NewText(frame, "GameFontHighlightSmall", 625)
    local matTitle = NewText(frame, "GameFontNormalSmall", 550)
    matTitle:SetText("MATERIALS")
    local materials = {}
    local action1 = NewButton(frame, "Acquired", 108)
    local action2 = NewButton(frame, "Skip", 90)
    local action3 = NewButton(frame, "Hide", 90)
    local pin = NewAcquisitionPin(frame, 24)
    detailRows[i] = {frame=frame, item=item, name=name, meta=meta,
        levelHeader=levelHeader,levelValue=levelValue,
        metaSourceIcon=metaSourceIcon,metaRest=metaRest,
        profession=profession,professionIcon=professionIcon, desc=desc,
        benefits=benefits, comparison=comparison, matTitle=matTitle, mats=materials,
        a=action1, b=action2, c=action3, pin=pin}
    return detailRows[i]
end

function GetGear:RefreshUI()
    if not self.db then return end
    if inventoryMode then
        levelText:SetText("GetGear  |  Account inventory")
        subtitle:SetText("Search saved bags and banks across your characters. Offline counts are last known, not live.")
        for _,button in ipairs(tabs) do button:Hide() end
        specButton:Hide(); startPreview:Hide(); altInventoryButton:Hide();optionsButton:Hide()
        previewHeading:Hide();exitPreview:Hide()
        previewClassButton:Hide();previewSpecButton:Hide()
        previewMinus:Hide();previewPlus:Hide();previewLevelLabel:Hide();previewLevel:Hide();previewFullButton:Hide()
        statusText:Hide()
        scroll:Hide()
        inventoryView:Show()
        RefreshInventoryBrowser()
        return
    end
    inventoryView:Hide()
    scroll:Show();statusText:Show();optionsButton:Show()
    local inPreview = preview.active
    local playerName = UnitName("player") or "Character"
    local race = type(UnitRace)=="function" and UnitRace("player") or ""
    local class = self.className or (type(UnitClass)=="function" and UnitClass("player")) or "Class"
    local classToken = type(UnitClass)=="function" and select(2,UnitClass("player")) or nil
    local spec = self.GetSpecialization and self:GetSpecialization() or "All"
    local list
    for _, button in ipairs(tabs) do
        if inPreview then button:Hide() else button:Show() end
    end
    if inPreview then
        list = PreviewEntries()
        levelText:SetText("GetGear  |  " .. ColoredCharacterLabel(
            preview.full and "1-30" or preview.level, "", previewNames[preview.classToken], preview.classToken))
        subtitle:SetText("Browse future or alternate-class gear. Read-only: no saves, equip comparisons or live status filters.")
        startPreview:Hide(); specButton:Hide(); altInventoryButton:Hide()
        previewHeading:Show(); exitPreview:Show()
        previewClassButton:Show(); previewSpecButton:Show()
        previewMinus:Show(); previewPlus:Show(); previewLevelLabel:Show(); previewLevel:Show(); previewFullButton:Show()
        previewClassButton:SetText("Class: " .. previewNames[preview.classToken])
        previewSpecButton:SetText("Spec: " .. preview.spec)
        previewLevel:SetText(tostring(preview.level))
        previewFullButton:SetText(preview.full and "Full 1-30: ON" or "Full 1-30: OFF")
        statusText:ClearAllPoints()
        statusText:SetPoint("TOPRIGHT", -38, -151)
        statusText:SetText(tostring(#list) .. " preview objectives" .. (preview.full and " (all levels)" or " (up to level " .. preview.level .. ")"))
        scroll:ClearAllPoints()
        scroll:SetPoint("TOPLEFT",17,-185)
        scroll:SetPoint("BOTTOMRIGHT",-35,15)
    else
        list = self:GetItems(self.activeTab)
        levelText:SetText(playerName .. "  |  " .. ColoredCharacterLabel(self.level, race, class, classToken))
        subtitle:SetText("Hover icons for stats. Equipped items appear in Completed; older outclassed gear in Earlier Gear. Neither changes saved statuses.")
        specButton:SetText(spec == "All" and "All specs" or spec)
        specButton:Show(); startPreview:Show(); altInventoryButton:Show()
        previewHeading:Hide(); exitPreview:Hide()
        previewClassButton:Hide(); previewSpecButton:Hide()
        previewMinus:Hide(); previewPlus:Hide(); previewLevelLabel:Hide(); previewLevel:Hide(); previewFullButton:Hide()
        local contextNote = (self.classToken == "MAGE" and spec == "All")
            and "  |  All shows Arcane, Fire and Frost alternatives" or ""
        statusText:ClearAllPoints()
        statusText:SetPoint("TOPRIGHT", -38, -151)
        statusText:SetText(tostring(#list) .. " objectives" .. contextNote)
        scroll:ClearAllPoints()
        scroll:SetPoint("TOPLEFT",17,-185)
        scroll:SetPoint("BOTTOMRIGHT",-35,15)
    end
    local innerWidth = math.max(655, (scroll:GetWidth() or 725) - 5)
    content:SetWidth(innerWidth)
    local y = 0
    if #list == 0 then
        local row = detailRows[1] or NewDetailRow(1)
        row.frame:ClearAllPoints()
        row.frame:SetWidth(innerWidth-3)
        row.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
        row.frame:SetHeight(95)
        row.item:Hide()
        row.name:SetText("No gear objectives in this category")
        row.meta:SetText(inPreview and "No recommendations for this class / specialization / level; try All specs or Full 1-30."
            or (#self.Gear == 0 and self:GetGuideEmptyMessage()
            or (self.activeTab=="bags" and "No ordinary bag upgrades needed, bag inspection unavailable, or bag recommendations disabled."
            or self.activeTab=="earlier" and "No gear is clearly outclassed, or automatic filtering is switched off."
            or "Check other tabs or another specialization; hidden objectives remain in Hidden.")))
        row.levelHeader:SetText("LEVEL")
        row.levelValue:SetText("")
        row.desc:Hide()
        row.comparison:Hide()
        row.profession:Hide();row.professionIcon:Hide()
        row.metaSourceIcon:Hide();row.metaRest:Hide()
        row.matTitle:Hide()
        row.a:Hide(); row.b:Hide(); row.c:Hide(); row.pin:Hide()
        for _, w in ipairs(row.benefits) do w:Hide() end
        for _, w in ipairs(row.mats) do w.frame:Hide() end
        row.frame:Show()
        y = 102
    else
        for i, gear in ipairs(list) do
            local row = detailRows[i] or NewDetailRow(i)
            row.frame:ClearAllPoints()
            row.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
            row.frame:SetWidth(innerWidth-3)
            row.name:SetWidth(math.max(130,innerWidth-240))
            row.desc:SetWidth(innerWidth-85)
            row.item:Show()
            SetItemIcon(row.item, gear.itemID,nil,nil,gear,inPreview)
            row.name:SetText(gear.name .. (gear.bagUpgrade and ("  x"..gear.quantity) or "") .. (not inPreview and self.activeTab=="completed" and self:GetStatus(gear)==nil
                and self:IsGearEquipped(gear) and "  |cff66e29b(Equipped)|r" or ""))
            local sourceProf=ProfessionSource(gear)
            if sourceProf then
                row.meta:SetText((gear.slot or "Item") .. "  |")
                row.meta:SetWidth(math.ceil(row.meta:GetStringWidth() or 58)+2)
                row.metaSourceIcon:ClearAllPoints()
                row.metaSourceIcon:SetPoint("LEFT",row.meta,"RIGHT",8,0)
                SetProfessionIcon(row.metaSourceIcon,sourceProf)
                row.metaRest:ClearAllPoints()
                row.metaRest:SetPoint("LEFT",row.metaSourceIcon,"RIGHT",5,0)
                row.metaRest:SetText("|  " .. (gear.zone or "Unknown"))
            else
                row.meta:SetWidth(math.max(290,innerWidth-260))
                row.meta:SetText((gear.slot or "Item") .. "  |  " .. (gear.sourceType or "Source") .. "  |  " .. (gear.zone or "Unknown"))
                row.metaSourceIcon:Hide();row.metaRest:Hide()
            end
            row.levelHeader:SetText(gear.bagUpgrade and "SLOTS" or "LEVEL")
            row.levelValue:SetText(gear.bagUpgrade and tostring(gear.bagSlots) or tostring(gear.targetLevel))

            -- Profession progress belongs to the metadata block, not below
            -- the stat changes. This second metadata row also gives the
            -- coloured comparison an unobstructed starting position.
            local nextY = 65
            if UpdateProfessionSkill(row.professionIcon,row.profession,gear,nil,inPreview) then
                row.professionIcon:ClearAllPoints()
                row.professionIcon:SetPoint("TOPLEFT",row.frame,"TOPLEFT",62,-54)
                row.profession:ClearAllPoints()
                if row.professionIcon:IsShown() then
                    row.profession:SetPoint("LEFT",row.professionIcon,"RIGHT",7,0)
                else
                    row.profession:SetPoint("TOPLEFT",row.frame,"TOPLEFT",62,-54)
                end
                nextY=81
            end
            -- Automatic comparison: visible in every item row, no extra toggle.
            local changeText,showChange = "",false
            if not inPreview and not gear.bagUpgrade then changeText,showChange=self:ComparisonInline(gear,true) end
            if showChange and changeText ~= "" then
                row.comparison:ClearAllPoints()
                row.comparison:SetPoint("TOPLEFT",row.frame,"TOPLEFT",62,-nextY)
                row.comparison:SetWidth(innerWidth-88)
                row.comparison:SetText(changeText)
                row.comparison:Show()
                nextY=nextY+MeasureText(row.comparison,28)+8
            else
                row.comparison:Hide()
            end
            -- The colored gear-stat deltas above replace the older fixed
            -- +damage/+healing/+attribute badge rows. Item tooltips remain
            -- available for full stats, including wand DPS and special effects.
            for _, widget in ipairs(row.benefits) do widget:Hide() end

            row.desc:ClearAllPoints()
            row.desc:SetPoint("TOPLEFT", row.frame, "TOPLEFT", 62, -nextY)
            row.desc:SetText(Describe(gear,inPreview))
            row.desc:Show()
            nextY = nextY + MeasureText(row.desc, 33) + 14

            local reagents = self:GetCraftingMaterialRows(gear, inPreview)
            if #reagents>0 then
                row.matTitle:ClearAllPoints()
                row.matTitle:SetPoint("TOPLEFT", row.frame, "TOPLEFT", 62, -nextY)
                row.matTitle:SetText("MATERIALS")
                row.matTitle:Show()
                nextY = nextY + 19
                for j, mat in ipairs(reagents) do
                    local widget = row.mats[j]
                    if not widget then widget=NewReagent(row.frame, false); row.mats[j]=widget end
                    -- One per line so intermediate children remain directly below parents.
                    UpdateReagent(widget, mat, 62 + math.min(mat.depth or 0, 2)*20,
                        nextY+(j-1)*35, row.frame, false, inPreview)
                end
                nextY = nextY + #reagents*35 + 8
            else
                if self.IsCraftMaterialsUnknown and self:IsCraftMaterialsUnknown(gear) then
                    row.matTitle:ClearAllPoints()
                    row.matTitle:SetPoint("TOPLEFT", row.frame, "TOPLEFT", 62, -nextY)
                    row.matTitle:SetText("Materials not yet documented (not zero)")
                    row.matTitle:Show()
                    nextY = nextY + 19
                else
                    row.matTitle:Hide()
                end
            end
            for j=#reagents+1,#row.mats do row.mats[j].frame:Hide() end

            row.a:ClearAllPoints()
            row.a:SetPoint("TOPLEFT", row.frame, "TOPLEFT", 62, -nextY)
            row.b:ClearAllPoints()
            row.b:SetPoint("LEFT", row.a, "RIGHT", 7, 0)
            row.c:ClearAllPoints()
            row.c:SetPoint("LEFT", row.b, "RIGHT", 7, 0)
            row.pin:ClearAllPoints()
            row.pin:SetPoint("LEFT",row.c,"RIGHT",10,0)
            AssignAcquisitionPin(row.pin, gear)
            if inPreview then
                row.a:Hide(); row.b:Hide(); row.c:Hide()
                row.a:SetScript("OnClick", nil)
                row.b:SetScript("OnClick", nil)
                row.c:SetScript("OnClick", nil)
                -- A map pin may still navigate to a source; it does not
                -- change player acquisition, hidden or skipped state.
                row.pin:ClearAllPoints()
                row.pin:SetPoint("TOPLEFT",row.frame,"TOPLEFT",62,-nextY)
            else
                local status = self:GetStatus(gear)
                if self.activeTab == "hidden" then
                    row.a:SetText("Restore")
                    row.a:SetScript("OnClick", function() self:SetHidden(gear, false) end)
                    row.b:SetText("Acquired")
                    row.b:SetScript("OnClick", function() self:SetStatus(gear, "acquired") end)
                    row.c:SetText("Skip")
                    row.c:SetScript("OnClick", function() self:SetStatus(gear, "skipped") end)
                    row.c:Show()
                elseif self.activeTab == "completed" then
                    row.a:SetText(status == "acquired" and "Undo acquire" or "Acquired")
                    row.a:SetScript("OnClick", function()
                        if status == "acquired" then
                            self:SetStatus(gear, nil)
                        else
                            self:SetStatus(gear, "acquired")
                        end
                    end)
                    row.b:SetText(status == "skipped" and "Undo skip" or "Skip")
                    row.b:SetScript("OnClick", function()
                        if status == "skipped" then
                            self:SetStatus(gear, nil)
                        else
                            self:SetStatus(gear, "skipped")
                        end
                    end)
                    row.c:Hide()
                else
                    row.a:SetText("Acquired")
                    row.a:SetScript("OnClick", function() self:SetStatus(gear, "acquired") end)
                    row.b:SetText("Skip")
                    row.b:SetScript("OnClick", function() self:SetStatus(gear, "skipped") end)
                    row.c:SetText("Hide")
                    row.c:SetScript("OnClick", function() self:SetHidden(gear, true) end)
                    row.c:Show()
                end
                row.a:Show(); row.b:Show()
                if gear.bagUpgrade then
                    -- Dynamic bag objectives can be hidden/restored, but can't be
                    -- manually Acquired or Skipped: worn slot counts own completion.
                    if self.activeTab == "hidden" then
                        row.a:Show(); row.b:Hide(); row.c:Hide()
                    else
                        row.a:Hide(); row.b:Hide(); row.c:Show()
                        row.c:ClearAllPoints()
                        row.c:SetPoint("TOPLEFT",row.frame,"TOPLEFT",62,-nextY)
                        row.c:SetScript("OnClick",function() self:SetHidden(gear,true) end)
                    end
                end
                if self.activeTab=="completed" then
                    row.pin:ClearAllPoints()
                    row.pin:SetPoint("LEFT",row.b,"RIGHT",10,0)
                end
            end
            row.frame:SetHeight(nextY + 35)
            row.frame:Show()
            y = y + nextY + 46
        end
    end
    for i=(#list==0 and 2 or #list+1),#detailRows do detailRows[i].frame:Hide() end
    content:SetHeight(math.max(425,y))
end

AllowResizing(window,720,400,1260,1000)
function window:afterResize()
    if GetGear.db then
        GetGear.db.detail.width, GetGear.db.detail.height = math.floor(self:GetWidth()+0.5), math.floor(self:GetHeight()+0.5)
        GetGear.db.detail.x, GetGear.db.detail.y = self:GetLeft(),self:GetTop()
    end
    GetGear:RefreshUI()
end
window:SetScript("OnHide", function()
    StopTitleDrag()
    if window.isSizing then
        window:StopMovingOrSizing()
        window.isSizing=false
    end
    preview.active=false
    inventoryMode=false
end)
function GetGear:IsUIShown() return window:IsShown() end
function GetGear:ShowUI()
    window:Show()
    -- Keep this action idempotent: a Guide button should open/raise the guide,
    -- not close it when it is already visible.
    if type(window.Raise)=="function" then window:Raise() end
    self:RefreshUI()
end
function GetGear:ToggleUI()
    if window:IsShown() then window:Hide() else self:ShowUI() end
end

-- =====================================================================
-- Always-on tracker overlay: level-aware objectives + combined materials.
-- =====================================================================
local overlay = CreateFrame("Frame", "GetGear_TrackerOverlay", UIParent)
overlay:SetSize(354, 420)
overlay:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -45, -135)
overlay:SetFrameStrata("MEDIUM")
overlay:SetMovable(true)
overlay:EnableMouse(true)
if overlay.SetClampedToScreen then overlay:SetClampedToScreen(true) end
overlay:Hide()

local background = overlay:CreateTexture(nil, "BACKGROUND")
background:SetAllPoints()

-- The draggable header must NOT overlap Guide or the character label.
-- In v0.7.1 it covered almost the entire header and could swallow clicks.
local dragArea = CreateFrame("Button", nil, overlay)
dragArea:SetPoint("TOPLEFT", 0, 0)
dragArea:SetSize(82, 32)
dragArea:RegisterForDrag("LeftButton")
dragArea:SetScript("OnDragStart", function()
    if GetGear.db and not GetGear.db.overlay.locked then overlay:StartMoving() end
end)
dragArea:SetScript("OnDragStop", function()
    overlay:StopMovingOrSizing()
    if GetGear.db then
        GetGear.db.overlay.x = overlay:GetLeft()
        GetGear.db.overlay.y = overlay:GetTop()
    end
end)
local trackerTitle = NewText(overlay, "GameFontNormal")
trackerTitle:SetPoint("TOPLEFT", 11, -10)
trackerTitle:SetText("GETGEAR")
-- Quick access to the full guide without typing a slash command.
local openGuide=NewButton(overlay,"Guide",52,22)
openGuide:SetPoint("TOPLEFT",overlay,"TOPLEFT",91,-5)
openGuide:SetFrameLevel(dragArea:GetFrameLevel()+2)
openGuide:SetScript("OnClick",function() GetGear:ShowUI() end)
openGuide:SetScript("OnEnter",function(self)
    if not GameTooltip then return end
    GameTooltip:SetOwner(self,"ANCHOR_BOTTOM")
    GameTooltip:AddLine("Open GetGear guide",1,0.82,0.35)
    GameTooltip:Show()
end)
openGuide:SetScript("OnLeave",HideItemTooltip)
local trackerLevel = NewText(overlay, "GameFontHighlightSmall", 168, "RIGHT")
trackerLevel:SetPoint("TOPRIGHT", -39, -11)
local trackerClose = NewButton(overlay, "X", 25, 22)
trackerClose:SetPoint("TOPRIGHT", -7, -6)
trackerClose:SetFrameLevel(dragArea:GetFrameLevel()+2)
trackerClose:SetScript("OnClick", function() GetGear:ToggleOverlay() end)

local objHead = CreateFrame("Button", nil, overlay)
objHead:SetPoint("TOPLEFT", 10, -37)
objHead:SetSize(326, 24)
local objHeadText = NewText(objHead, "GameFontNormalSmall", 324)
objHeadText:SetPoint("LEFT", 0, 0)
objHead:SetScript("OnClick", function()
    if not GetGear.db then return end
    GetGear.db.overlay.objectivesCollapsed = not GetGear.db.overlay.objectivesCollapsed
    GetGear:RefreshOverlay()
end)

local objScroll = CreateFrame("ScrollFrame", nil, overlay, "UIPanelScrollFrameTemplate")
objScroll:SetPoint("TOPLEFT", overlay, "TOPLEFT", 10, -65)
local objContent = CreateFrame("Frame", nil, objScroll)
objContent:SetSize(290, 200)
objScroll:SetScrollChild(objContent)
local overlayRows = {}

local function NewOverlayRow(i)
    local f = CreateFrame("Frame", nil, objContent)
    f:SetSize(316, 46)
    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    local icon = NewIcon(f, 30)
    icon:SetPoint("TOPLEFT", 5, -7)
    local expand = CreateFrame("Button", nil, f)
    expand:SetPoint("TOPLEFT", 41, 0)
    expand:SetSize(229, 46)
    local name = NewText(expand, "GameFontNormalSmall", 227)
    name:SetPoint("TOPLEFT", 2, -7)
    local sub = NewText(expand, "GameFontHighlightSmall", 226)
    sub:SetPoint("TOPLEFT", 2, -26)
    local hide = NewButton(f, "X", 25, 22)
    hide:SetPoint("TOPRIGHT", -7, -11)
    hide:SetScript("OnEnter",function(self)
        if not GameTooltip then return end
        GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
        GameTooltip:AddLine("Hide objective",1,0.82,0.35)
        GameTooltip:AddLine("Does not mark acquired or skipped. Restore in Guide > Hidden.",1,1,1,true)
        GameTooltip:Show()
    end)
    hide:SetScript("OnLeave",HideItemTooltip)
    local minimize = NewButton(f, "-", 25, 22)
    minimize:SetPoint("RIGHT",hide,"LEFT",-4,0)
    minimize:SetScript("OnEnter",function(self)
        if GameTooltip then
            GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
            GameTooltip:AddLine(self.minimized and "Expand objective" or "Minimize objective",1,0.82,0.35)
            GameTooltip:Show()
        end
    end)
    minimize:SetScript("OnLeave",HideItemTooltip)
    local pin=NewAcquisitionPin(f,22)
    pin:SetPoint("RIGHT",minimize,"LEFT",-3,0)
    local professionIcon = NewProfessionIcon(f,18)
    local profession = NewText(f,"GameFontHighlightSmall",140)
    local desc = NewText(f, "GameFontHighlightSmall", 295)
    local comparison = NewText(f,"GameFontHighlightSmall",295)
    local benefits = {}
    local matTitle = NewText(f, "GameFontNormalSmall", 296)
    matTitle:SetText("MATERIALS")
    local matNote = NewText(f, "GameFontHighlightSmall", 276)
    local mats = {}
    overlayRows[i] = {f=f,bg=bg,icon=icon,expand=expand,name=name,sub=sub,
        hide=hide,minimize=minimize,pin=pin,profession=profession,professionIcon=professionIcon,
        desc=desc,comparison=comparison,benefits=benefits,matTitle=matTitle,matNote=matNote,mats=mats}
    return overlayRows[i]
end

local matHeader = CreateFrame("Button", nil, overlay)
matHeader:SetSize(332, 28)
local matHeaderText = NewText(matHeader, "GameFontNormalSmall", 210)
matHeaderText:SetPoint("LEFT", 0, 0)
matHeader:SetScript("OnClick", function()
    if not GetGear.db then return end
    GetGear.db.overlay.materialsCollapsed = not GetGear.db.overlay.materialsCollapsed
    GetGear:RefreshOverlay()
end)
matHeader:SetScript("OnEnter", function(self)
    if not GameTooltip then return end
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    GameTooltip:AddLine(self.listIncomplete and "Why this list is incomplete" or "Total crafting materials",1,0.82,0.35)
    local undocumented=self.undocumentedCrafts or {}
    if #undocumented>0 then
        GameTooltip:AddLine("Recipe requirements: "..#undocumented.." tracked craft(s) have no documented ingredient list.",1,0.77,0.4,true)
        for i=1,math.min(#undocumented,3) do
            GameTooltip:AddLine("  "..tostring(undocumented[i].name or "Unnamed craft"),0.84,0.85,0.91,true)
        end
        if #undocumented>3 then
            GameTooltip:AddLine("  ...and "..(#undocumented-3).." more; see Guide.",0.76,0.81,0.88)
        end
    else
        GameTooltip:AddLine("Ingredient requirements are documented for the tracked crafts.",0.59,0.87,0.65,true)
    end
    if (self.unscannedBanks or 0)>0 or (self.unscannedBags or 0)>0
        or (self.partialBanks or 0)>0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Inventory coverage (same realm/faction):",0.70,0.85,1)
        if (self.unscannedBanks or 0)>0 then
            GameTooltip:AddLine(self.unscannedBanks.." saved character bank(s) not yet scanned.",1,0.78,0.45,true)
        end
        if (self.unscannedBags or 0)>0 then
            GameTooltip:AddLine(self.unscannedBags.." character bag snapshot(s) missing.",1,0.78,0.45,true)
        end
        if (self.partialBanks or 0)>0 then
            GameTooltip:AddLine(self.partialBanks.." character bank(s) scanned incompletely.",1,0.78,0.45,true)
        end
        if self.unscannedNames and #self.unscannedNames>0 then
            GameTooltip:AddLine("Visit bank or log in: "..table.concat(self.unscannedNames,", "),0.85,0.87,0.92,true)
        end
    end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Missing recipe data affects materials NEEDED. Missing bank/alt scans affect materials OWNED, not the recipe requirements.",0.70,0.82,0.94,true)
    GameTooltip:AddLine("Only previously visited characters are recorded; saved counts can become outdated.",0.69,0.73,0.82,true)
    GameTooltip:Show()
end)
matHeader:SetScript("OnLeave",HideItemTooltip)
local scopeButton = nil -- material scope is configured in /getgear settings
-- Dedicated, clearly labelled collapse control instead of a tracking button.
local collapseMaterials=NewButton(overlay,"-",24,22)
collapseMaterials:SetScript("OnClick",function()
    if not GetGear.db then return end
    GetGear.db.overlay.materialsCollapsed=not GetGear.db.overlay.materialsCollapsed
    GetGear:RefreshOverlay()
end)
collapseMaterials:SetScript("OnEnter",function(self)
    if not GameTooltip then return end
    GameTooltip:SetOwner(self,"ANCHOR_LEFT")
    GameTooltip:AddLine(GetGear.db and GetGear.db.overlay.materialsCollapsed and "Expand total materials" or "Minimize total materials",1,0.82,0.35)
    GameTooltip:Show()
end)
collapseMaterials:SetScript("OnLeave",HideItemTooltip)
local matScroll = CreateFrame("ScrollFrame", nil, overlay, "UIPanelScrollFrameTemplate")
local matContent = CreateFrame("Frame", nil, matScroll)
matContent:SetSize(290, 200)
matScroll:SetScrollChild(matContent)
local materialRows = {}
local emptyMaterialText = NewText(matContent, "GameFontHighlightSmall", 300)
emptyMaterialText:SetPoint("TOPLEFT", 3, -8)

local noObjectives = NewText(objContent, "GameFontHighlightSmall", 300)
noObjectives:SetPoint("TOPLEFT", 5, -9)

-- A real splitter between the two independent scrolling sections. The
-- player's chosen ratio is persisted; no dependence on the current item count.
local SIDE_PADDING = 10
local SPLITTER_HEIGHT = 14
local SECTION_START_Y = 65
local BOTTOM_AND_HEADERS = 112
local splitter = CreateFrame("Button", "GetGear_OverlaySectionSplitter", overlay)
splitter:SetHeight(SPLITTER_HEIGHT)
splitter:SetFrameLevel(overlay:GetFrameLevel()+5)
splitter:EnableMouse(true)
local splitRule=splitter:CreateTexture(nil, "BACKGROUND")
splitRule:SetHeight(2)
splitRule:SetPoint("LEFT",5,0)
splitRule:SetPoint("RIGHT",-5,0)
splitRule:SetColorTexture(0.59,0.43,0.19,0.85)
local splitGrip=splitter:CreateTexture(nil,"ARTWORK")
splitGrip:SetSize(54,11)
splitGrip:SetPoint("CENTER",0,0)
splitGrip:SetColorTexture(0.23,0.18,0.11,0.98)
local splitGlyph=NewText(splitter,"GameFontNormalSmall",50,"CENTER")
splitGlyph:SetPoint("CENTER",0,1)
splitGlyph:SetText("= = =")
splitGlyph:SetTextColor(1,0.76,0.33)
splitter:SetScript("OnEnter",function(self)
    if GameTooltip then
        GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
        GameTooltip:AddLine("Resize tracker sections",1,0.82,0.35)
        GameTooltip:AddLine("Drag up for more crafting materials; down for more objectives.",1,1,1,true)
        GameTooltip:Show()
    end
end)
splitter:SetScript("OnLeave",HideItemTooltip)
local function UpdateSplitFromCursor()
    if not GetGear.db or type(GetCursorPosition)~="function" then return end
    local scale=overlay.GetEffectiveScale and overlay:GetEffectiveScale() or 1
    if not scale or scale<=0 then scale=1 end
    local _,cursorY=GetCursorPosition()
    if type(cursorY)~="number" or type(overlay:GetTop())~="number" then return end
    local fromTop=overlay:GetTop()-cursorY/scale
    local budget=math.max(0,overlay:GetHeight()-BOTTOM_AND_HEADERS-SPLITTER_HEIGHT)
    if budget<72 then return end
    local objectiveHeight=fromTop-SECTION_START_Y-3
    local minSection=36
    objectiveHeight=math.max(minSection,math.min(budget-minSection,objectiveHeight))
    local share=math.max(0.12,math.min(0.88,(budget-objectiveHeight)/budget))
    local previous=GetGear.db.overlay.materialShare
    if type(previous)=="number" and math.abs(previous-share)<0.004 then return end
    GetGear.db.overlay.materialShare=share
    GetGear:RefreshOverlay()
end
splitter:SetScript("OnMouseDown",function(self,button)
    if button=="LeftButton" then
        self.dragging=true
        HideItemTooltip()
        UpdateSplitFromCursor()
    end
end)
splitter:SetScript("OnUpdate",function(self)
    if not self.dragging then return end
    -- A release outside the grip should not leave the splitter stuck.
    if type(IsMouseButtonDown)=="function" and not IsMouseButtonDown("LeftButton") then
        self.dragging=false
        return
    end
    UpdateSplitFromCursor()
end)
splitter:SetScript("OnMouseUp",function(self,button)
    if button=="LeftButton" and self.dragging then
        UpdateSplitFromCursor()
        self.dragging=false
    end
end)
splitter:SetScript("OnHide",function(self)self.dragging=false end)

local function UpdateOverlayWidths()
    local width=overlay:GetWidth()
    -- Both stock scrollbars sit 6px OUTSIDE their scroll-frame edge and
    -- consume another 16px. Reserve a consistent dark gutter on both lists
    -- so blue objective cards never run beneath either scrollbar.
    local rowW=math.max(280,width-2*SIDE_PADDING)
    local scrollW=math.max(254,rowW-26)
    -- Reserve header space for the Guide button and character label.
    -- Only the GetGear title itself serves as the drag handle.
    dragArea:SetWidth(82)
    trackerLevel:SetWidth(math.max(95,width-190))
    objHead:SetWidth(rowW)
    objHeadText:SetWidth(rowW-2)
    objScroll:SetWidth(scrollW)
    objContent:SetWidth(scrollW)
    noObjectives:SetWidth(scrollW-10)
    matHeader:SetWidth(rowW)
    matHeaderText:SetWidth(rowW-48)
    matScroll:SetWidth(scrollW)
    matContent:SetWidth(scrollW)
    emptyMaterialText:SetWidth(scrollW-12)
    splitter:SetWidth(rowW)
    for _,r in ipairs(overlayRows) do
        r.f:SetWidth(scrollW)
        r.expand:SetWidth(scrollW-111)
        r.name:SetWidth(scrollW-116)
        r.sub:SetWidth(scrollW-116)
        r.desc:SetWidth(scrollW-20)
        r.comparison:SetWidth(scrollW-20)
        r.matTitle:SetWidth(scrollW-20)
    end
end

local function IsInCombat()
    return type(InCombatLockdown) == "function" and InCombatLockdown()
end

-- Keep the trade skill requirement with the relevant item's Materials
-- heading, rather than adding a separate metadata line below its level.
-- No redundant profession icon: the required skill is printed in full.
local function ShowOverlayMaterialHeader(row, gear, y)
    row.matTitle:ClearAllPoints()
    row.matTitle:SetPoint("TOPLEFT", row.f, "TOPLEFT", 11, -y)
    row.matTitle:SetWidth(82)
    row.matTitle:SetText("MATERIALS")
    row.matTitle:Show()
    if UpdateProfessionSkill(row.professionIcon, row.profession, gear, true) then
        row.professionIcon:Hide()
        row.profession:SetWidth(170)
        row.profession:SetJustifyH("RIGHT")
        row.profession:ClearAllPoints()
        row.profession:SetPoint("TOPRIGHT", row.f, "TOPRIGHT", -11, -y)
    end
end

function GetGear:RefreshOverlay()
    if not self.db then return end
    local opts = self.db.overlay
    local opacity = math.max(0.2, math.min(1, opts.backgroundOpacity or 0.78))
    background:SetColorTexture(0.045, 0.065, 0.10, opacity)
    local shouldShow = opts.visible and not (opts.hideInCombat and IsInCombat())
    if not shouldShow then overlay:Hide(); return end
    overlay:Show()
    UpdateOverlayWidths()
    local race = type(UnitRace)=="function" and UnitRace("player") or nil
    local class = type(UnitClass)=="function" and UnitClass("player") or nil
    local classToken = type(UnitClass)=="function" and select(2,UnitClass("player")) or nil
    trackerLevel:SetText(ColoredCharacterLabel(self.level, race, class, classToken))

    local list = self:GetItems("tracker")
    objHeadText:SetText((opts.objectivesCollapsed and "+" or "-") .. "  OBJECTIVES (" .. #list .. ")")
    local totalY = 0
    if opts.objectivesCollapsed then
        objScroll:Hide()
    else
        objScroll:Show()
        if #list == 0 then
            noObjectives:SetText(#self.Gear == 0 and self:GetGuideEmptyMessage()
                or "No current objectives. Check Earlier Gear, Hidden or Completed in /getgear.")
            noObjectives:Show()
            totalY = 44
        else
            noObjectives:Hide()
            for i, gear in ipairs(list) do
                local r = overlayRows[i] or NewOverlayRow(i)
                r.f:ClearAllPoints()
                r.f:SetPoint("TOPLEFT", objContent, "TOPLEFT", 0, -totalY)
                r.bg:SetColorTexture(0.10, 0.13, 0.19, opacity*0.9)
                SetItemIcon(r.icon, gear.itemID,nil,nil,gear)
                AssignAcquisitionPin(r.pin,gear)
                -- Make room for the map pin in the header only for records
                -- that have a trustworthy location attached.
                local reserved=(r.pin:IsShown() and 27 or 0)
                r.expand:SetWidth(math.max(125,r.f:GetWidth()-111-reserved))
                r.name:SetWidth(math.max(125,r.f:GetWidth()-116-reserved))
                r.sub:SetWidth(math.max(125,r.f:GetWidth()-116-reserved))
                r.name:SetText(gear.name .. (gear.bagUpgrade and ("  x"..gear.quantity) or ""))
                r.sub:SetText(gear.bagUpgrade and (tostring(gear.bagSlots).." slots each | "..gear.quantity.." needed") or ("Level " .. tostring(gear.targetLevel)))
                r.expand:SetScript("OnClick", function()
                    opts.expanded[gear.id] = not opts.expanded[gear.id] or nil
                    self:RefreshOverlay()
                end)
                r.hide:SetScript("OnClick", function() self:SetHidden(gear, true) end)
                r.hide:Show()
                local minimized = opts.minimized[gear.id] == true
                r.minimize.minimized=minimized
                r.minimize:SetText(minimized and "+" or "-")
                r.minimize:SetScript("OnClick",function()
                    if minimized then
                        opts.minimized[gear.id] = nil
                    else
                        opts.minimized[gear.id] = true
                    end
                    self:RefreshOverlay()
                end)
                -- Minimized objectives retain their header (icon/name/level)
                -- and continue contributing to the aggregate materials tracker.
                -- Full objectives retain their prior title-click detail toggle.
                if minimized then
                    r.comparison:Hide()
                    r.professionIcon:Hide(); r.profession:Hide()
                    r.desc:Hide(); r.matTitle:Hide(); r.matNote:Hide()
                    for _, w in ipairs(r.benefits) do w:Hide() end
                    for _, w in ipairs(r.mats) do w.frame:Hide() end
                    r.f:SetHeight(47)
                    r.f:Show()
                    totalY=totalY+51
                else
                -- The compact tracker ALWAYS displays the per-item material
                -- checklist, including for objectives within the next 5 levels.
                -- Expanding adds benefits and useful source detail; status actions stay in the full Guide.
                local nextY = 48
                -- The trade-skill requirement is rendered beside the item's
                -- Materials heading below, not between level and stat deltas.
                local changeText,showChange="",false
                if not gear.bagUpgrade then changeText,showChange=self:ComparisonInline(gear,false) end
                if showChange and changeText ~= "" then
                    r.comparison:ClearAllPoints()
                    r.comparison:SetPoint("TOPLEFT",r.f,"TOPLEFT",11,-nextY)
                    r.comparison:SetWidth(r.f:GetWidth()-23)
                    r.comparison:SetText(changeText)
                    r.comparison:Show()
                    -- Match the deliberate gap above the stat block, measured
                    -- from its final wrapped line, not its first line.
                    -- Allow one-line strings to use their measured height. The
                    -- old 17px minimum added whitespace to short stat lines;
                    -- actual two-or-more-line measurements stay unchanged.
                    nextY=nextY+MeasureText(r.comparison,12)+14
                else
                    r.comparison:Hide()
                end
                local expanded = opts.expanded[gear.id]
                if expanded then
                    -- No duplicate fixed benefit badge: comparison numbers are
                    -- already visible inline; icon tooltip has complete stats.
                    for _, widget in ipairs(r.benefits) do widget:Hide() end
                    local summary=DescribeOverlay(gear,r.pin:IsShown())
                    if summary and summary~="" then
                        r.desc:ClearAllPoints()
                        r.desc:SetPoint("TOPLEFT", r.f, "TOPLEFT", 11, -nextY)
                        r.desc:SetText(summary)
                        r.desc:Show()
                        -- The former 35-pixel minimum created a large blank gap
                        -- even when the summary occupied only one text line.
                        nextY = nextY + MeasureText(r.desc, 12) + 5
                    else
                        r.desc:Hide()
                    end
                else
                    r.desc:Hide()
                end
                for _,widget in ipairs(r.benefits) do widget:Hide() end

                local reagents = self:GetCraftingMaterialRows(gear)
                if #reagents > 0 then
                    ShowOverlayMaterialHeader(r, gear, nextY)
                    r.matNote:Hide()
                    nextY = nextY + 17
                    for j, mat in ipairs(reagents) do
                        local widget = r.mats[j]
                        if not widget then widget=NewReagent(r.f,true);r.mats[j]=widget end
                        UpdateReagent(widget,mat,9 + math.min(mat.depth or 0, 2)*14,nextY+(j-1)*28,r.f,false)
                    end
                    nextY = nextY + #reagents*28 + 5
                else
                    if gear.bagUpgrade and gear.profession then
                        -- Show the craft threshold even when the player is not
                        -- a Tailor (and hence we don't track their reagents).
                        ShowOverlayMaterialHeader(r, gear, nextY)
                        r.matTitle:SetText("CRAFTING")
                        nextY = nextY + 17
                        r.matNote:ClearAllPoints()
                        r.matNote:SetPoint("TOPLEFT",r.f,"TOPLEFT",11,-nextY)
                        r.matNote:SetText("Buy, commission, or learn Tailoring")
                        r.matNote:Show()
                        nextY = nextY + 17
                    elseif self.IsCraftMaterialsUnknown and self:IsCraftMaterialsUnknown(gear) then
                        ShowOverlayMaterialHeader(r, gear, nextY)
                        nextY = nextY + 17
                        r.matNote:ClearAllPoints()
                        r.matNote:SetPoint("TOPLEFT", r.f, "TOPLEFT", 11, -nextY)
                        r.matNote:SetText("Materials not yet documented")
                        r.matNote:Show()
                        nextY = nextY + 17
                    else
                        r.matTitle:Hide()
                        r.matNote:Hide()
                        r.professionIcon:Hide(); r.profession:Hide()
                    end
                end
                for j=#reagents+1,#r.mats do r.mats[j].frame:Hide() end

                r.f:SetHeight(nextY)
                r.f:Show()
                totalY=totalY+nextY+4
                end -- not minimized
            end
        end
    end
    for i=(opts.objectivesCollapsed and 1 or #list+1),#overlayRows do overlayRows[i].f:Hide() end
    local materials = self:GetCombinedMaterialRows(opts.materialScope)
    local totalMatsH=math.max(42,#materials*29+7)
    local desiredObj = opts.objectivesCollapsed and 0 or math.max(45,totalY)
    local desiredMat = opts.materialsCollapsed and 0 or totalMatsH
    local bothOpen = desiredObj>0 and desiredMat>0
    local dividerSpace = bothOpen and SPLITTER_HEIGHT or 0
    -- Auto-fit only until the first user resize. Give Materials more space by
    -- default so the aggregate list is usable even with many active crafts.
    if type(opts.height) ~= "number" then
        overlay:SetHeight(BOTTOM_AND_HEADERS + dividerSpace
            + math.min(desiredObj,280) + math.min(desiredMat,215))
    end
    local budget=math.max(0,overlay:GetHeight()-BOTTOM_AND_HEADERS-dividerSpace)
    local objH,matsH=0,0
    if bothOpen then
        local share=opts.materialShare
        if type(share)~="number" then
            -- A sensible initial split; user-dragged preference takes priority.
            share=math.max(0.45,math.min(0.65,desiredMat/math.max(1,desiredMat+desiredObj)))
        end
        share=math.max(0.12,math.min(0.88,share))
        local minimum=math.min(36,math.floor(budget/2))
        matsH=math.max(minimum,math.min(budget-minimum,math.floor(budget*share+0.5)))
        objH=budget-matsH
        if desiredObj<objH then
            objH=desiredObj
            matsH=math.min(desiredMat,budget-objH)
        elseif desiredMat<matsH then
            matsH=desiredMat
            objH=math.min(desiredObj,budget-matsH)
        end
    elseif desiredObj>0 then
        objH=math.min(desiredObj,budget)
    elseif desiredMat>0 then
        matsH=math.min(desiredMat,budget)
    end
    if bothOpen then
        splitter:ClearAllPoints()
        splitter:SetPoint("TOPLEFT",overlay,"TOPLEFT",SIDE_PADDING,-(SECTION_START_Y+objH+3))
        splitter:Show()
    else
        splitter:Hide()
    end
    objContent:SetHeight(math.max(50,totalY))
    objScroll:SetHeight(objH)
    if objScroll.GetVerticalScroll and objScroll:GetVerticalScroll()>math.max(0,totalY-objH) then
        objScroll:SetVerticalScroll(math.max(0,totalY-objH))
    end
    local headerY = SECTION_START_Y+objH+6+dividerSpace
    matHeader:ClearAllPoints()
    matHeader:SetPoint("TOPLEFT",overlay,"TOPLEFT",11,-headerY)
    local missing = self:GetUndocumentedCrafts(opts.materialScope)
    -- The ingredient requirements and the account-owned inventory are
    -- separate concepts. Surface either gap, but explain which is affected
    -- in the hover text rather than implying all recipes lack materials.
    local missingBanks,missingBags,partialBanks=0,0,0
    local unscannedNames={}
    if self.AltInventory and self.AltInventory.BrowserCharacters then
        for _,character in ipairs(self.AltInventory:BrowserCharacters()) do
            if character.eligible then
                local bankMissing=not character.bankKnown
                local bagsMissing=not character.bagsKnown
                local bankPartial=character.bankPartial==true
                if bankMissing then missingBanks=missingBanks+1 end
                if bagsMissing then missingBags=missingBags+1 end
                if bankPartial then partialBanks=partialBanks+1 end
                if bankMissing or bagsMissing or bankPartial then
                    if #unscannedNames<4 then unscannedNames[#unscannedNames+1]=character.name or "Unknown" end
                end
            end
        end
    end
    matHeader.undocumentedCrafts=missing
    matHeader.unscannedBanks=missingBanks
    matHeader.unscannedBags=missingBags
    matHeader.partialBanks=partialBanks
    matHeader.unscannedNames=unscannedNames
    matHeader.listIncomplete=(#missing>0 or missingBanks>0 or missingBags>0 or partialBanks>0)
    matHeaderText:SetText(matHeader.listIncomplete and "TOTAL MATERIALS (INCOMPLETE LIST)" or "TOTAL MATERIALS")
    collapseMaterials:ClearAllPoints()
    collapseMaterials:SetPoint("TOPRIGHT",overlay,"TOPRIGHT",-11,-headerY-3)
    collapseMaterials:SetText(opts.materialsCollapsed and "+" or "-")
    if opts.materialsCollapsed then
        matScroll:Hide()
    else
        matScroll:Show()
        if #materials == 0 then
            emptyMaterialText:SetText(#missing>0 and ("Materials missing for " .. #missing .. " craft(s); total is incomplete.") or "No documented materials needed for these objectives.")
            emptyMaterialText:Show()
        else
            emptyMaterialText:Hide()
        end
        for i, material in ipairs(materials) do
            local r=materialRows[i]
            if not r then r=NewReagent(matContent,true);materialRows[i]=r end
            UpdateReagent(r,material,3 + math.min(material.depth or 0, 2)*14,4+(i-1)*29,matContent,true)
        end
        for i=#materials+1,#materialRows do materialRows[i].frame:Hide() end
        matContent:SetHeight(totalMatsH)
        matScroll:ClearAllPoints()
        matScroll:SetPoint("TOPLEFT",overlay,"TOPLEFT",9,-headerY-32)
        matScroll:SetHeight(matsH)
        if matScroll.GetVerticalScroll and matScroll:GetVerticalScroll()>math.max(0,totalMatsH-matsH) then
            matScroll:SetVerticalScroll(math.max(0,totalMatsH-matsH))
        end
    end
end

AllowResizing(overlay,320,230,580,950)
function overlay:afterResize()
    if GetGear.db then
        local opts=GetGear.db.overlay
        opts.width,opts.height=math.floor(self:GetWidth()+0.5),math.floor(self:GetHeight()+0.5)
        opts.x,opts.y=self:GetLeft(),self:GetTop()
    end
    GetGear:RefreshOverlay()
end
function GetGear:ToggleOverlay()
    if not self.db then return end
    local opts=self.db.overlay
    opts.visible=not opts.visible
    self:RefreshOverlay()
end

-- =====================================================================
-- Settings in separate window; overlay stays uncluttered while playing.
-- =====================================================================
local settings = CreateFrame("Frame", "GetGear_OverlaySettings", UIParent, "BasicFrameTemplateWithInset")
settings:SetSize(418, 530)
settings:SetPoint("CENTER", UIParent, "CENTER", 270, 50)
-- Settings must still be usable when opened from the foreground detail guide.
settings:SetFrameStrata("DIALOG")
if settings.SetToplevel then settings:SetToplevel(true) end
settings:Hide()
if settings.TitleText then settings.TitleText:SetText("GetGear - Display Settings") end
if UISpecialFrames then table.insert(UISpecialFrames,"GetGear_OverlaySettings") end

local helperText=NewText(settings,"GameFontHighlightSmall",340)
helperText:SetPoint("TOPLEFT",17,-40)
helperText:SetText("Transparency affects only the tracker background, never text or item icons.")
local sliderTitle=NewText(settings,"GameFontNormal",330)
sliderTitle:SetPoint("TOPLEFT",18,-80)
sliderTitle:SetText("Background opacity")
local alphaSlider=CreateFrame("Slider", "GetGear_OpacitySlider", settings, "OptionsSliderTemplate")
alphaSlider:SetPoint("TOPLEFT",25,-106)
alphaSlider:SetSize(244,18)
alphaSlider:SetMinMaxValues(20,100)
alphaSlider:SetValueStep(5)
if alphaSlider.SetObeyStepOnDrag then alphaSlider:SetObeyStepOnDrag(true) end
local alphaValue=NewText(settings,"GameFontNormal",90,"RIGHT")
alphaValue:SetPoint("LEFT",alphaSlider,"RIGHT",17,0)
alphaSlider:SetScript("OnValueChanged",function(_,value)
    local rounded=math.floor((value+2.5)/5)*5
    rounded=math.max(20,math.min(100,rounded))
    alphaValue:SetText(rounded .. "%")
    if GetGear.db then
        GetGear.db.overlay.backgroundOpacity=rounded/100
        GetGear:RefreshOverlay()
    end
end)

local function AddScaleSlider(name,y,label,which)
    local title=NewText(settings,"GameFontNormal",340)
    title:SetPoint("TOPLEFT",18,-y)
    title:SetText(label)
    local slider=CreateFrame("Slider",name,settings,"OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT",25,-y-26)
    slider:SetSize(244,18)
    slider:SetMinMaxValues(70,150)
    slider:SetValueStep(5)
    if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
    local display=NewText(settings,"GameFontNormal",90,"RIGHT")
    display:SetPoint("LEFT",slider,"RIGHT",17,0)
    slider:SetScript("OnValueChanged",function(_,value)
        local rounded=math.max(70,math.min(150,math.floor((value+2.5)/5)*5))
        display:SetText(rounded .. "%")
        if GetGear.db then
            GetGear.db[which].scale=rounded/100
            if which=="overlay" then overlay:SetScale(rounded/100)
            else window:SetScale(rounded/100) end
        end
    end)
    return slider
end
local overlayScaleSlider=AddScaleSlider("GetGear_OverlayScaleSlider",150,"Overlay UI scale","overlay")
local detailScaleSlider=AddScaleSlider("GetGear_DetailScaleSlider",218,"Detailed window UI scale","detail")

local function NewCheck(parent,label,y,callback)
    local checkbox=CreateFrame("CheckButton",nil,parent,"UICheckButtonTemplate")
    checkbox:SetSize(25,25)
    checkbox:SetPoint("TOPLEFT",18,-y)
    local text=NewText(parent,"GameFontHighlight",325)
    text:SetPoint("LEFT",checkbox,"RIGHT",3,0)
    text:SetText(label)
    checkbox:SetScript("OnClick",function(self)
        if GetGear.db then callback(self:GetChecked() and true or false) end
    end)
    return checkbox
end
local lockedCheck=NewCheck(settings,"Lock overlay position",292,function(v)
    GetGear.db.overlay.locked=v
end)
local combatCheck=NewCheck(settings,"Hide tracker automatically during combat",325,function(v)
    GetGear.db.overlay.hideInCombat=v
    GetGear:RefreshOverlay()
end)
-- This filter never edits hidden/acquired SavedVariables. Disabled means
-- older recommendations return to Available Now and the overlay.
local obsoleteCheck=NewCheck(settings,"Filter clearly outclassed earlier gear",357,function(v)
    GetGear.db.overlay.filterObsolete=v
    GetGear:RefreshAll()
end)
obsoleteCheck:SetScript("OnEnter",function(self)
    if not GameTooltip then return end
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    GameTooltip:AddLine("Conservative earlier gear filtering",1,0.82,0.35)
    GameTooltip:AddLine("Moves clearly outclassed older armour and ordinary weapons to Earlier Gear; matching equipped items appear in Completed.",1,1,1,true)
    GameTooltip:AddLine("Weapon DPS, stats, item quality and special effects are checked conservatively. Unknown items stay active; nothing is permanently hidden.",0.7,0.8,1,true)
    GameTooltip:Show()
end)
obsoleteCheck:SetScript("OnLeave",HideItemTooltip)
local bagsCheck=NewCheck(settings,"Recommend ordinary bag upgrades",390,function(v)
    GetGear.db.overlay.bagUpgrades=v
    GetGear:RefreshAll()
end)
bagsCheck:SetScript("OnEnter",function(self)
    if not GameTooltip then return end
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    GameTooltip:AddLine("Automatic bag upgrades",1,0.82,0.35)
    GameTooltip:AddLine("Scans four worn bag slots, excluding specialty/reagent bags. Crafting materials include every needed copy when Tailoring is learned.",1,1,1,true)
    GameTooltip:AddLine("Bag objectives disappear automatically when the bags are replaced. No saved gear statuses are modified.",0.7,0.8,1,true)
    GameTooltip:Show()
end)
bagsCheck:SetScript("OnLeave",HideItemTooltip)
-- Keep the Tracked/All material-scope choice in settings, without
-- confusing it with the Total Materials minimize button.
local materialScopeButton=NewButton(settings,"",185,23)
materialScopeButton:SetPoint("TOPLEFT",18,-438)
materialScopeButton:SetScript("OnClick",function(self)
    if not GetGear.db then return end
    local opts=GetGear.db.overlay
    opts.materialScope = opts.materialScope == "tracked" and "all" or "tracked"
    self:SetText("Materials: " .. (opts.materialScope == "all" and "All" or "Tracked"))
    GetGear:RefreshOverlay()
end)
materialScopeButton:SetScript("OnEnter",function(self)
    if not GameTooltip then return end
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    GameTooltip:AddLine("Material tally scope",1,0.82,0.35)
    GameTooltip:AddLine("Tracked: visible objectives only",1,1,1)
    GameTooltip:AddLine("All: also includes hidden and earlier objectives",1,1,1)
    GameTooltip:Show()
end)
materialScopeButton:SetScript("OnLeave",HideItemTooltip)
local showOverlay=NewButton(settings,"Show / hide tracker",165,24)
showOverlay:SetPoint("BOTTOMLEFT",20,18)
showOverlay:SetScript("OnClick",function() GetGear:ToggleOverlay() end)
local closeSettings=NewButton(settings,"Close",88,24)
closeSettings:SetPoint("BOTTOMRIGHT",-18,18)
closeSettings:SetScript("OnClick",function() settings:Hide() end)

function GetGear:ShowSettings()
    if not self.db then return end
    -- Within DIALOG, put settings above the detailed guide while it is open.
    settings:SetFrameLevel(math.max(settings:GetFrameLevel(), window:GetFrameLevel() + 20))
    settings:Show()
    if type(settings.Raise) == "function" then settings:Raise() end
    materialScopeButton:SetText("Materials: " .. (self.db.overlay.materialScope == "all" and "All" or "Tracked"))
    lockedCheck:SetChecked(self.db.overlay.locked)
    combatCheck:SetChecked(self.db.overlay.hideInCombat)
    obsoleteCheck:SetChecked(self.db.overlay.filterObsolete ~= false)
    bagsCheck:SetChecked(self.db.overlay.bagUpgrades ~= false)
    alphaSlider:SetValue(math.floor((self.db.overlay.backgroundOpacity or 0.78)*100 + 0.5))
    overlayScaleSlider:SetValue(math.floor((self.db.overlay.scale or 1)*100+0.5))
    detailScaleSlider:SetValue(math.floor((self.db.detail.scale or 1)*100+0.5))
end

function GetGear:InitializeUI()
    if not self.db then return end
    local opts=self.db.overlay
    local detail=self.db.detail or {}
    overlay:SetScale(math.max(0.7,math.min(1.5,opts.scale or 1)))
    window:SetScale(math.max(0.7,math.min(1.5,detail.scale or 1)))
    if type(opts.width)=="number" then overlay:SetWidth(math.max(320,math.min(580,opts.width))) end
    if type(opts.height)=="number" then overlay:SetHeight(math.max(230,math.min(950,opts.height))) end
    if type(opts.x)=="number" and type(opts.y)=="number" then
        overlay:ClearAllPoints()
        overlay:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",opts.x,opts.y)
    end
    if type(detail.width)=="number" and type(detail.height)=="number" then
        window:SetSize(math.max(720,math.min(1260,detail.width)),math.max(400,math.min(1000,detail.height)))
    end
    if type(detail.x)=="number" and type(detail.y)=="number" then
        window:ClearAllPoints()
        window:SetPoint("TOPLEFT",UIParent,"BOTTOMLEFT",detail.x,detail.y)
    end
    self:RefreshOverlay()
end

-- Zero-dependency minimap button: click for detailed guide, shift-click overlay.
local minimapButton=CreateFrame("Button", "GetGear_MinimapButton",Minimap)
minimapButton:SetSize(30,30)
minimapButton:SetPoint("TOPLEFT",Minimap,"TOPLEFT",-9,2)
local minimapTexture=minimapButton:CreateTexture(nil,"ARTWORK")
minimapTexture:SetAllPoints()
minimapTexture:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
minimapButton:SetScript("OnClick",function()
    if type(IsShiftKeyDown)=="function" and IsShiftKeyDown() then GetGear:ToggleOverlay()
    else GetGear:ToggleUI() end
end)
minimapButton:SetScript("OnEnter",function(self)
    GameTooltip:SetOwner(self,"ANCHOR_LEFT")
    GameTooltip:AddLine("GetGear")
    GameTooltip:AddLine("Click: toggle detailed guide",1,1,1)
    GameTooltip:AddLine("Shift-click: show/hide overlay",1,1,1)
    GameTooltip:Show()
end)
minimapButton:SetScript("OnLeave",HideItemTooltip)
