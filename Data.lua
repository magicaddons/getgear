local addonName, GetGear = ...

-- v0.2.0: independently researched initial data batch, not the recovered original table.
-- confidence: client=item/recipe present in beta client (acquisition of recipe can remain unverified);
-- observed=source seen in Forever; classic-reference=quest source/reward still unconfirmed.
-- targetLevel is editorial recommendation; availableLevel is character/quest eligibility, not crafting feasibility.
GetGear.Gear = {
    {
        id = "item_247789",
        itemID = 247789,
        name = "Novice's Practice Wand",
        slot = "Wand",
        availableLevel = 1,
        targetLevel = 1,
        sourceType = "Enchanting",
        source = "Enchanting recipe",
        zone = "Dun Morogh / Ironforge",
        instructions = "Make with early Enchanting or obtain from another enchanter. Equip as soon as you have it.",
        notes = "Starter wand; 4.0 DPS. No listed minimum character level.",
        sourceURL = "https://foreverdb.net/item/247789",
        confidence = "client",
        focus = "All",
    },
    {
        id = "item_11287",
        itemID = 11287,
        name = "Lesser Magic Wand",
        slot = "Wand",
        availableLevel = 5,
        targetLevel = 5,
        sourceType = "Enchanting",
        source = "Lesser Magic Wand recipe",
        zone = "Ironforge",
        instructions = "Craft through Enchanting once you can; if needed buy from an enchanter or the Auction House.",
        notes = "Requires level 5; 11.3 wand DPS. Early major upgrade.",
        sourceURL = "https://foreverdb.net/item/11287",
        confidence = "client",
        focus = "All",
    },
    {
        id = "item_11288",
        itemID = 11288,
        name = "Greater Magic Wand",
        slot = "Wand",
        availableLevel = 13,
        targetLevel = 13,
        sourceType = "Enchanting",
        source = "Greater Magic Wand recipe",
        zone = "Ironforge",
        instructions = "Craft or purchase an enchanter-crafted Greater Magic Wand. Upgrade from Lesser Magic Wand.",
        notes = "Requires level 13; 17.5 wand DPS. Prefer over nerfed Sable Wand on raw DPS.",
        sourceURL = "https://foreverdb.net/item/11288",
        confidence = "client",
        focus = "All",
    },
    {
        id = "item_253907",
        itemID = 253907,
        name = "Filigreed Shadow Gown",
        slot = "Chest",
        availableLevel = 15,
        targetLevel = 15,
        sourceType = "Tailoring",
        source = "Pattern: Filigreed Shadow Gown",
        zone = "Profession / pattern source uncertain",
        instructions = "Requires Tailoring 75 and the pattern. The recipe materials appear below. Confirm pattern source before farming.",
        notes = "Shadow option, +9 Shadow damage. Bind on pickup; recipe acquisition not confirmed.",
        sourceURL = "https://foreverdb.net/item/253907",
        confidence = "client",
        focus = "Shadow",
    },
    {
        id = "item_253901",
        itemID = 253901,
        name = "Filigreed Pristine Gown",
        slot = "Chest",
        availableLevel = 15,
        targetLevel = 15,
        sourceType = "Tailoring",
        source = "Pattern: Filigreed Pristine Gown",
        zone = "Profession / pattern source uncertain",
        instructions = "Requires Tailoring 75 and the pattern. The recipe materials appear below. Confirm pattern source before farming.",
        notes = "Healing-oriented alternative to Shadow Gown; +13 Healing and +5 Spell Damage. Bind on pickup.",
        sourceURL = "https://foreverdb.net/item/253901",
        confidence = "client",
        focus = "Healing",
    },
    {
        id = "item_253925",
        itemID = 253925,
        name = "Pristine Sash",
        slot = "Waist",
        availableLevel = 17,
        targetLevel = 17,
        sourceType = "Tailoring",
        source = "Pristine Sash recipe",
        zone = "Profession / recipe source uncertain",
        instructions = "Craft using Tailoring (skill 85); where to learn this Forever-exclusive recipe is not yet confirmed. Confirm before searching for a vendor.",
        notes = "+11 Healing Power and +4 Spell Damage. Bind on pickup; more useful if healing dungeons.",
        sourceURL = "https://foreverdb.net/item/253925",
        confidence = "client",
        focus = "Healing",
    },
    {
        id = "item_253943",
        itemID = 253943,
        name = "Filigreed Shadow Leggings",
        slot = "Legs",
        availableLevel = 20,
        targetLevel = 20,
        sourceType = "Tailoring",
        source = "Filigreed Shadow Leggings recipe",
        zone = "Profession / pattern source uncertain",
        instructions = "Make through Tailoring if the recipe is obtainable. Verify its pattern acquisition source before making a special trip.",
        notes = "+11 Shadow Damage; requires level 20. Bind on pickup.",
        sourceURL = "https://foreverdb.net/item/253943",
        confidence = "client",
        focus = "Shadow",
    },
    {
        id = "item_8071",
        itemID = 8071,
        name = "Sizzle Stick",
        slot = "Wand",
        availableLevel = 15,
        targetLevel = 21,
        sourceType = "Quest",
        source = "Deviate Eradication",
        zone = "Wailing Caverns / The Barrens",
        instructions = "Classic quest route: take Deviate Eradication from Ebru above Wailing Caverns, kill the required Deviate creatures, and choose Sizzle Stick. Confirm Forever reward before committing.",
        notes = "23.2 wand DPS, +5 Spell Power. Quest seen in Forever, reward sourced from Classic data; not guaranteed.",
        sourceURL = "https://foreverdb.net/quest/1487-deviate-eradication",
        confidence = "classic-reference",
        focus = "All",
    },
    {
        id = "item_4318",
        itemID = 4318,
        name = "Gloves of Meditation",
        slot = "Hands",
        availableLevel = 21,
        targetLevel = 21,
        sourceType = "Tailoring",
        source = "Trainer: Gloves of Meditation",
        zone = "Ironforge",
        instructions = "Ask a Tailoring trainer for Gloves of Meditation (Jormund Stonebrow in Ironforge is a Classic location), or obtain the bind-on-equip gloves from another tailor. Verify the trainer and skill requirement in Forever.",
        notes = "+5 Spell Power and +7 Spirit; recipe and item exist in Forever.",
        sourceURL = "https://foreverdb.net/item/4318",
        confidence = "client",
        focus = "All",
    },
    {
        id = "item_253967",
        itemID = 253967,
        name = "Shadow Gown",
        slot = "Chest",
        availableLevel = 22,
        targetLevel = 22,
        sourceType = "Tailoring",
        source = "Pattern: Shadow Gown",
        zone = "Recipe source uncertain",
        instructions = "Tailoring skill 110 according to current ForeverDB profession data. Requires the pattern; confirm current seller and any reputation requirement.",
        notes = "+13 Shadow Damage. Bind on pickup; typically replaces the Filigreed version.",
        sourceURL = "https://foreverdb.net/item/253967",
        confidence = "client",
        focus = "Shadow",
    },
    {
        id = "item_253961",
        itemID = 253961,
        name = "Pristine Gown",
        slot = "Chest",
        availableLevel = 22,
        targetLevel = 22,
        sourceType = "Tailoring",
        source = "Pristine Gown recipe",
        zone = "Profession / recipe source uncertain",
        instructions = "Craft via Tailoring if the recipe is available. Confirm its unlock source before relying on it.",
        notes = "Healing-oriented alternative: +20 Healing Power, +7 Spell Damage and +7 Intellect. Bind on pickup.",
        sourceURL = "https://foreverdb.net/item/253961",
        confidence = "client",
        focus = "Healing",
    },
    {
        id = "item_6903",
        itemID = 6903,
        name = "Gaze Dreamer Pants",
        slot = "Legs",
        availableLevel = 23,
        targetLevel = 23,
        sourceType = "Dungeon",
        source = "Twilight Lord Kelris",
        zone = "Blackfathom Deeps",
        instructions = "Run Blackfathom Deeps, defeat Twilight Lord Kelris and roll for the cloth leg drop.",
        notes = "+12 Spell Power and +9 Spirit; boss source observed in Forever. May outperform crafted options depending on build.",
        sourceURL = "https://foreverdb.net/item/6903",
        confidence = "observed",
        focus = "All",
    },
    {
        id = "item_7047",
        itemID = 7047,
        name = "Hands of Darkness",
        slot = "Hands",
        availableLevel = 24,
        targetLevel = 24,
        sourceType = "Tailoring",
        source = "Hands of Darkness recipe",
        zone = "Tailoring / Auction House",
        instructions = "Craft by Tailoring or buy from a crafter / Auction House. Confirm recipe training in your profession book.",
        notes = "+9 Shadow Damage and +5 Spirit; alternative to Gloves of Meditation.",
        sourceURL = "https://foreverdb.net/item/7047",
        confidence = "client",
        focus = "Shadow",
    },
    {
        id = "item_253981",
        itemID = 253981,
        name = "Filigreed Shadow Circlet",
        slot = "Head",
        availableLevel = 25,
        targetLevel = 25,
        sourceType = "Tailoring",
        source = "Filigreed Shadow Circlet recipe",
        zone = "Profession / pattern source uncertain",
        instructions = "Craft through Tailoring once the pattern is learned. Check pattern source before farming.",
        notes = "+14 Shadow Damage, +12 Stamina; requires level 25; bind on pickup.",
        sourceURL = "https://foreverdb.net/item/253981",
        confidence = "client",
        focus = "Shadow",
    },
    {
        id = "item_7049",
        itemID = 7049,
        name = "Truefaith Gloves",
        slot = "Hands",
        availableLevel = 25,
        targetLevel = 25,
        sourceType = "Tailoring",
        source = "Truefaith Gloves recipe",
        zone = "Tailoring / Auction House",
        instructions = "Craft via Tailoring or obtain from another tailor / Auction House (bind on equip).",
        notes = "+15 Healing Power, +5 Spell Damage; healing alternative to shadow gloves.",
        sourceURL = "https://foreverdb.net/item/7049",
        confidence = "client",
        focus = "Healing",
    },
    {
        id = "item_253987",
        itemID = 253987,
        name = "Pristine Leggings",
        slot = "Legs",
        availableLevel = 25,
        targetLevel = 25,
        sourceType = "Tailoring",
        source = "Pristine Leggings recipe",
        zone = "Profession / pattern source uncertain",
        instructions = "Craft using Tailoring if its recipe is available in your client; check pattern source.",
        notes = "+22 Healing Power, +7 Spell Damage; healing alternative to Gaze Dreamer Pants.",
        sourceURL = "https://foreverdb.net/item/253987",
        confidence = "client",
        focus = "Healing",
    },
    {
        id = "item_253993",
        itemID = 253993,
        name = "Shadow Leggings",
        slot = "Legs",
        availableLevel = 25,
        targetLevel = 25,
        sourceType = "Tailoring",
        source = "Shadow Leggings recipe",
        zone = "Profession / pattern source uncertain",
        instructions = "Craft using Tailoring; verify how to acquire its recipe.",
        notes = "+14 Shadow Damage; compare with Gaze Dreamer Pants (+12 general Spell Power and Spirit).",
        sourceURL = "https://foreverdb.net/item/253993",
        confidence = "client",
        focus = "Shadow",
    },
    {
        id = "item_7001",
        itemID = 7001,
        name = "Gravestone Scepter",
        slot = "Wand",
        availableLevel = 18,
        targetLevel = 27,
        sourceType = "Quest",
        source = "Blackfathom Villainy",
        zone = "Blackfathom Deeps / Darnassus",
        instructions = "Pick up from Argent Guard Thaelrid inside Blackfathom Deeps; kill Twilight Lord Kelris, bring his head to Dawnwatcher Selgorm in Darnassus. Classic coordinates 56.2, 24.4.",
        notes = "29.0 wand DPS. Reward observed for Alliance in Forever; individual quest step locations partly Classic reference.",
        sourceURL = "https://foreverdb.net/item/7001",
        confidence = "observed",
        focus = "All",
    },
    {
        id = "item_2933",
        itemID = 2933,
        name = "Seal of Wrynn",
        slot = "Ring",
        availableLevel = 16,
        targetLevel = 28,
        sourceType = "Quest chain",
        source = "An Audience with the King",
        zone = "The Deadmines / Stormwind City",
        instructions = "Classic chain: obtain An Unsent Letter from Edwin VanCleef in Deadmines; continue the Defias correspondence/Stockades storyline through Brotherhood's End. Take Baros Alexston's report to the Stormwind Keep audience. Verify exact Forever chain.",
        notes = "Late-20s goal by choice, not minimum quest level. Reward and chain currently Classic-reference, not confirmed for Forever.",
        sourceURL = "https://foreverdb.net/quest/396-an-audience-with-the-king",
        confidence = "classic-reference",
        focus = "All",
    },
    {
        id = "item_254007",
        itemID = 254007,
        name = "Black Slippers",
        slot = "Feet",
        availableLevel = 30,
        targetLevel = 30,
        sourceType = "Tailoring",
        source = "Black Slippers recipe",
        zone = "Profession / pattern source uncertain",
        instructions = "Craft through Tailoring once you have obtained its pattern; source may require additional discovery.",
        notes = "+13 Shadow Damage and +7 Intellect; level 30 Shadow option.",
        sourceURL = "https://foreverdb.net/item/254007",
        confidence = "client",
        focus = "Shadow",
    },
    {
        id = "item_254001",
        itemID = 254001,
        name = "Gilded Slippers",
        slot = "Feet",
        availableLevel = 30,
        targetLevel = 30,
        sourceType = "Tailoring",
        source = "Gilded Slippers recipe",
        zone = "Profession / recipe source uncertain",
        instructions = "Craft through Tailoring skill 140 according to beta profession data if your recipe is available.",
        notes = "+20 Healing Power, +7 Spell Damage and +7 Intellect; level 30 healing alternative.",
        sourceURL = "https://foreverdb.net/item/254001",
        confidence = "client",
        focus = "Healing",
    },
}


-- v0.3.0: verified reagents per craft, drawn from Forever beta recipe data.
-- These are DIRECT reagents, not recursively expanded raw materials.
-- Item IDs are kept separate from display names for locale-independent bag counts.
-- Crafted items whose acquisition patterns are uncertain retain their earlier cautions.
local REAGENT_NAMES = {
    [4470] = "Simple Wood",
    [247786] = "Mote of Magic",
    [10938] = "Lesser Magic Essence",
    [2997] = "Bolt of Woolen Cloth",
    [4305] = "Bolt of Silk Cloth",
    [4339] = "Bolt of Mageweave",
    [2321] = "Fine Thread",
    [4291] = "Silken Thread",
    [8343] = "Heavy Silken Thread",
    [249409] = "Cerulean Dye",
    [249430] = "Magenta Dye",
    [1210] = "Shadowgem",
    [249427] = "Pristine Leather",
    [3383] = "Elixir of Wisdom",
    [2842] = "Silver Bar",
    [3577] = "Gold Bar",
    [11082] = "Greater Astral Essence",
    [4234] = "Heavy Leather",
    [6048] = "Shadow Protection Potion",
    [929] = "Healing Potion",
    [7971] = "Black Pearl",
}

-- Each entry is {itemID, amount}. The list order matches the craft recipe.
local REAGENTS_BY_RESULT = {
    [247789] = { {4470,1}, {247786,1} },
    [11287] = { {4470,1}, {10938,1} },
    [11288] = { {4470,1}, {10938,2} }, -- Forever change: not Greater Magic Essence
    [253907] = { {2997,8}, {2321,4}, {249409,2}, {1210,2} },
    [253901] = { {2997,8}, {2321,4}, {249409,2}, {249427,2} },
    [253925] = { {4305,8}, {2321,4}, {249409,3}, {249427,3} },
    [253943] = { {4305,8}, {2321,4}, {249409,2}, {1210,4} },
    [4318] = { {2997,4}, {2321,3}, {3383,1} },
    [253967] = { {4305,12}, {4291,2}, {249409,6}, {1210,6}, {2842,2}, {11082,2} },
    [253961] = { {4305,12}, {4291,2}, {249409,6}, {249427,6}, {2842,2}, {11082,2} },
    [7047] = { {4305,3}, {4234,2}, {6048,2}, {2321,2} },
    [253981] = { {4305,8}, {2321,4}, {249409,2}, {1210,6} },
    [7049] = { {4305,3}, {4234,2}, {929,4}, {2321,1} },
    [253987] = { {4305,14}, {2321,3}, {249409,8}, {249427,8}, {2842,2}, {11082,3} },
    [253993] = { {4305,14}, {2321,3}, {249409,8}, {1210,8}, {2842,2}, {11082,3} },
    [254007] = { {4339,8}, {8343,4}, {249430,2}, {249409,2}, {7971,2} },
    [254001] = { {4339,8}, {8343,4}, {249430,2}, {249409,2}, {3577,2} },
}

for _, gear in ipairs(GetGear.Gear) do
    local reagents = REAGENTS_BY_RESULT[gear.itemID]
    if reagents then
        gear.reagents = {}
        for _, source in ipairs(reagents) do
            gear.reagents[#gear.reagents + 1] = {
                itemID = source[1],
                amount = source[2],
                name = REAGENT_NAMES[source[1]] or "Unidentified material",
            }
        end
    end
end

-- Display-only benefits. The tooltip remains authoritative for all actual item stats.
-- Never guess bonuses for unverified quest rewards.
local BENEFITS = {
    [247789] = { { "Wand", "4.0 wand DPS" } },
    [11287] = { { "Wand", "11.3 wand DPS" } },
    [11288] = { { "Wand", "17.5 wand DPS" } },
    [253907] = { { "Shadow", "+9 Shadow damage" } },
    [253901] = { { "Healing", "+13 Healing" }, { "Spell", "+5 Spell damage" } },
    [253925] = { { "Healing", "+11 Healing power" }, { "Spell", "+4 Spell damage" } },
    [253943] = { { "Shadow", "+11 Shadow damage" } },
    [8071] = { { "Wand", "23.2 wand DPS" }, { "Spell", "+5 Spell power" } },
    [4318] = { { "Spell", "+5 Spell power" }, { "Spirit", "+7 Spirit" } },
    [253967] = { { "Shadow", "+13 Shadow damage" } },
    [253961] = { { "Healing", "+20 Healing power" }, { "Spell", "+7 Spell damage" }, { "Intellect", "+7 Intellect" } },
    [6903] = { { "Spell", "+12 Spell power" }, { "Spirit", "+9 Spirit" } },
    [7047] = { { "Shadow", "+9 Shadow damage" }, { "Spirit", "+5 Spirit" } },
    [253981] = { { "Shadow", "+14 Shadow damage" }, { "Stamina", "+12 Stamina" } },
    [7049] = { { "Healing", "+15 Healing power" }, { "Spell", "+5 Spell damage" } },
    [253987] = { { "Healing", "+22 Healing power" }, { "Spell", "+7 Spell damage" } },
    [253993] = { { "Shadow", "+14 Shadow damage" } },
    [7001] = { { "Wand", "29.0 wand DPS" } },
    [254007] = { { "Shadow", "+13 Shadow damage" }, { "Intellect", "+7 Intellect" } },
    [254001] = { { "Healing", "+20 Healing power" }, { "Spell", "+7 Spell damage" }, { "Intellect", "+7 Intellect" } },
}

local NOTES = {
    [247789] = "Starter wand; no listed minimum character level.",
    [11287] = "A major early wand upgrade.",
    [11288] = "Prefer over the nerfed Sable Wand on raw DPS.",
    [253907] = "Bind on pickup; recipe acquisition not confirmed.",
    [253901] = "Healing-oriented alternative to Filigreed Shadow Gown. Bind on pickup.",
    [253925] = "Bind on pickup; mainly useful if healing dungeons.",
    [253943] = "Bind on pickup.",
    [8071] = "Quest seen in Forever; reward only supported by Classic references, not guaranteed.",
    [4318] = "Recipe and item present in Forever.",
    [253967] = "Bind on pickup; typically replaces the Filigreed version.",
    [253961] = "Healing-oriented alternative; bind on pickup.",
    [6903] = "Boss source observed in Forever. Compare with crafted leggings for your build.",
    [7047] = "Alternative to Gloves of Meditation.",
    [253981] = "Bind on pickup.",
    [7049] = "Healing alternative to shadow gloves.",
    [253987] = "Healing alternative to Gaze Dreamer Pants.",
    [253993] = "Compare against Gaze Dreamer Pants and its general spell power.",
    [7001] = "Alliance quest reward observed in Forever; some quest steps use Classic references.",
    [2933] = "A late-20s objective by recommendation, not minimum quest level. Forever reward is unconfirmed.",
    [254007] = "Shadow option.",
    [254001] = "Healing option.",
}

local ICONS = {
    Shadow = "Interface\\Icons\\Spell_Shadow_Shadowform",
    Healing = "Interface\\Icons\\Spell_Holy_Heal",
    Spell = "Interface\\Icons\\Spell_Holy_MagicalSentry",
    Spirit = "Interface\\Icons\\Spell_Holy_DivineSpirit",
    Intellect = "Interface\\Icons\\Spell_Holy_MagicalSentry",
    Stamina = "Interface\\Icons\\Spell_Holy_WordFortitude",
    Wand = "Interface\\Icons\\INV_Wand_02",
}

for _, gear in ipairs(GetGear.Gear) do
    local benefits = BENEFITS[gear.itemID]
    if benefits then
        gear.benefits = {}
        for _, benefit in ipairs(benefits) do
            gear.benefits[#gear.benefits + 1] = {
                category = benefit[1], text = benefit[2], icon = ICONS[benefit[1]],
            }
        end
    end
    gear.notes = NOTES[gear.itemID] or gear.notes
end

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
            and (scope == "all" or (not self:IsHidden(gear)
                and not self:IsGearEquipped(gear)
                and self:GetObsoleteGearReason(gear) == nil)) then
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
        if type(target) == "number" then
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
                include = status == nil and not hidden and not self:IsGearEquipped(record)
                    and target > level and target <= level + 5
            elseif mode == "earlier" then
                -- Earlier Gear contains auto-filtered equipment, not manually hidden items.
                include = status == nil and not hidden and not self:IsGearEquipped(record)
                    and target <= level and self:GetObsoleteGearReason(record) ~= nil
            elseif mode == "available" then
                include = status == nil and not hidden and not self:IsGearEquipped(record)
                    and target <= level and self:GetObsoleteGearReason(record) == nil
            elseif mode == "tracker" then
                include = status == nil and not hidden and not self:IsGearEquipped(record)
                    and target <= level + 5 and (record.bagUpgrade or self:GetObsoleteGearReason(record) == nil)
            else
                include = false
            end
            if include then result[#result + 1] = record end
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
