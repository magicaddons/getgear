local addonName, GetGear = ...

-- Build 1.60.1 Forever-specific verified intermediate conversions.
-- Missing conversions are kept as purchasable/gatherable leaf ingredients,
-- not guessed. outputCount may be used for verified multiple-output spells.
-- Healing Potion's published Forever yield is disputed, so leave its
-- effective count at 1 until in-game verification, with caution in UI.
local INTERMEDIATE = {
    [4243] = { name="Fine Leather Tunic", profession="Leatherworking", inputs={{4231,3},{2318,6},{2320,4}} },
    [2996]   = { name="Bolt of Linen Cloth", profession="Tailoring", skill=1, inputs={{2589,2}} },
    [2997]   = { name="Bolt of Woolen Cloth", profession="Tailoring", skill=75, inputs={{2592,3}} },
    [4305]   = { name="Bolt of Silk Cloth", profession="Tailoring", skill=125, inputs={{4306,4}} },
    [4339]   = { name="Bolt of Mageweave", profession="Tailoring", skill=175, inputs={{4338,5}} },
    [249409] = { name="Cerulean Dye", profession="Alchemy", inputs={{249399,2},{3371,1}} },
    [249430] = { name="Magenta Dye", profession="Alchemy", inputs={{249424,2},{3372,1}} },
    [3383]   = { name="Elixir of Wisdom", profession="Alchemy", inputs={{785,1},{2450,2},{3371,1}} },
    [6048]   = { name="Shadow Protection Potion", profession="Alchemy", skill=135, inputs={{3369,1},{3356,1},{3372,1}} },
    [929]    = { name="Healing Potion", profession="First Aid", inputs={{3372,1},{2692,1},{2453,1}} },
    [10939]  = { name="Greater Magic Essence", profession="Enchanting", inputs={{10938,3}} },
    [11082]  = { name="Greater Astral Essence", profession="Enchanting", inputs={{10998,3}} },
    -- Smelting: one ore becomes one bar. Blacksmithing isn't required.
    [2842]   = { name="Silver Bar", profession="Mining", inputs={{2775,1}} },
    [3577]   = { name="Gold Bar", profession="Mining", inputs={{2776,1}} },
}
GetGear.IntermediateRecipes = INTERMEDIATE
local NAMES = {
    [2318]="Light Leather",[2319]="Medium Leather",[4234]="Heavy Leather",[4291]="Silken Thread",[2320]="Coarse Thread",
    [2321]="Fine Thread",[4231]="Cured Light Hide",[7286]="Black Whelp Scale",
    [6470]="Deviate Scale",[6471]="Perfect Deviate Scale",
    [3182]="Spider's Silk",[5498]="Small Lustrous Pearl",[13926]="Golden Pearl",
    [7079]="Globe of Water",[7077]="Heart of Fire",[6260]="Blue Dye",
    [6371]="Fire Oil",[8343]="Heavy Silken Thread",[249430]="Magenta Dye",
    [2589]="Linen Cloth",[2592]="Wool Cloth",[4306]="Silk Cloth",[4338]="Mageweave Cloth",
    [249399]="Frilled Lichen",[3371]="Empty Vial",[249424]="Rosecap",[3372]="Leaded Vial",
    [785]="Mageroyal",[2450]="Briarthorn",[3369]="Grave Moss",[3356]="Kingsblood",
    [2692]="Hot Spices",[2453]="Bruiseweed",[10938]="Lesser Magic Essence",
    [10998]="Lesser Astral Essence",[2775]="Silver Ore",[2776]="Gold Ore",
}
for _, gear in ipairs(GetGear.Gear) do
    for _, reagent in ipairs(gear.reagents or {}) do
        NAMES[reagent.itemID] = reagent.name
    end
end

-- Some conversion recipes differ in their current trainer thresholds across sources.
-- This number is intentionally reserved for the verified minimum for the gear itself.
local REQUIREMENTS = {
    [247789]={"Enchanting",1}, [11287]={"Enchanting",10}, [11288]={"Enchanting",70},
    [253907]={"Tailoring",75}, [253901]={"Tailoring",75},
    [253925]={"Tailoring",85}, [253943]={"Tailoring",100},
    [4318]={"Tailoring",130}, [253967]={"Tailoring",110}, [253961]={"Tailoring",110},
    [7047]={"Tailoring",120}, [253981]={"Tailoring",125}, [7049]={"Tailoring",125},
    [253987]={"Tailoring",125}, [253993]={"Tailoring",125},
    [254007]={"Tailoring",140}, [254001]={"Tailoring",140},
}
for _,gear in ipairs(GetGear.Gear) do
    local r=REQUIREMENTS[gear.itemID]
    if r then gear.profession = r[1]; gear.professionSkillRequired = r[2] end
end

local function Have(itemID)
    local count = GetGear:GetMaterialCount(itemID)
    if type(count) == "number" then return math.max(0,count) end
    return nil
end

-- Return an expanded materials tree for ONE item, displaying actual bag counts
-- and the raw ingredients required for only the MISSING intermediates.
-- Shared ingredients within that craft are pooled before comparing with bags.
local function Plan(directReagents)
    local totals, direct, children, rootOrder = {}, {}, {}, {}
    for _,reagent in ipairs(directReagents or {}) do
        if type(reagent.itemID)=="number" and type(reagent.amount)=="number" then
            local id = reagent.itemID
            totals[id] = (totals[id] or 0) + reagent.amount
            if not direct[id] then
                rootOrder[#rootOrder+1] = id
                direct[id] = true
            end
        end
    end
    -- A DAG of conversions, processed from more-complicated ingredients to
    -- simpler ones. Recursion guard prevents malformed future recipe cycles.
    local heightCache = {}
    local function Height(id,visited)
        if heightCache[id] then return heightCache[id] end
        if visited[id] then return 0 end
        local r=INTERMEDIATE[id]
        if not r then return 0 end
        visited[id]=true
        local m=0
        for _,part in ipairs(r.inputs) do m=math.max(m,Height(part[1],visited)+1) end
        visited[id]=nil
        heightCache[id]=m
        return m
    end
    local pending = {}
    for id in pairs(totals) do pending[id]=true end
    while next(pending) do
        local top,largest
        for id in pairs(pending) do
            local h=Height(id,{})
            if not top or h > largest or (h==largest and id<top) then top,largest=id,h end
        end
        pending[top]=nil
        local recipe=INTERMEDIATE[top]
        if recipe then
            local deficit=math.max(0,totals[top]-(Have(top) or 0))
            if deficit>0 then
                children[top]={}
                for _,part in ipairs(recipe.inputs) do
                    local outputCount=type(recipe.outputCount)=="number" and
                        math.max(1,recipe.outputCount) or 1
                    local crafts=math.ceil(deficit/outputCount)
                    local childID, qty=part[1],part[2]*crafts
                    totals[childID]=(totals[childID] or 0)+qty
                    children[top][#children[top]+1]=childID
                    pending[childID]=true
                end
            end
        end
    end
    local shown, result = {}, {}
    local function Add(id,depth,parentID)
        if shown[id] then return end
        shown[id]=true
        local recipe=INTERMEDIATE[id]
        local row={itemID=id,name=(GetGear.MaterialNames and GetGear.MaterialNames[id]) or NAMES[id] or (recipe and recipe.name) or ("Item "..id),
            amount=totals[id],depth=depth or 0,parentID=parentID,recipe=recipe,hasChildren=children[id]~=nil}
        result[#result+1]=row
        for _,childID in ipairs(children[id] or {}) do Add(childID,(depth or 0)+1,id) end
    end
    for _,id in ipairs(rootOrder) do Add(id,0) end
    -- Remaining shared children: displayed once rather than counted twice.
    local extra = {}
    for id in pairs(totals) do if not shown[id] then extra[#extra+1]=id end end
    table.sort(extra,function(a,b) return (NAMES[a] or "")<(NAMES[b] or "") end)
    for _,id in ipairs(extra) do Add(id,0) end
    return result
end

-- Collapse intermediate recipe dependencies by default. Each parent has
-- an independent expand toggle; this is only display state, not quantities.
local function VisibleRows(rows, keyPrefix, db, previewExpandAll)
    local result, hiddenByID = {}, {}
    local expanded = db and db.overlay and db.overlay.dependencyExpanded or {}
    for _,row in ipairs(rows) do
        local hidden = row.parentID and hiddenByID[row.parentID]
        local collapseKey = keyPrefix .. ":" .. tostring(row.itemID)
        row.collapseKey = collapseKey
        row.collapsed = row.hasChildren and not previewExpandAll and expanded[collapseKey] ~= true
        hiddenByID[row.itemID] = hidden or (row.hasChildren and row.collapsed) or false
        if not hidden then result[#result+1] = row end
    end
    return result
end

function GetGear:GetCraftingMaterialRows(gear, previewExpandAll)
    local rows=Plan(gear and gear.reagents or {})
    return VisibleRows(rows, "gear:" .. (gear and gear.id or ""), self.db, previewExpandAll)
end

-- Tracks undetailed crafts contributing to the visible material scope.
function GetGear:IsCraftMaterialsUnknown(gear)
    if not gear or gear.bagUpgrade then return false end
    local profession=gear.profession or gear.sourceType
    return (profession=="Blacksmithing" or profession=="Leatherworking"
        or profession=="Tailoring" or profession=="Enchanting")
        and (type(gear.reagents)~="table" or #gear.reagents==0)
end

function GetGear:GetUndocumentedCrafts(scope)
    local pending,level={},self.level or 1
    for _,gear in ipairs(self.Gear) do
        if gear.targetLevel<=level+5 and not self:GetStatus(gear)
            and (scope=="all" or (not self:IsHidden(gear)
                and not self:IsGearEquipped(gear)
                and self:GetObsoleteGearReason(gear)==nil)) then
            if self:IsCraftMaterialsUnknown(gear) then
                pending[#pending+1]=gear
            end
        end
    end
    return pending
end

function GetGear:GetCombinedMaterialRows(scope)
    local total, list = {}, {}
    local level=self.level or 1
    for _,gear in ipairs(self.Gear) do
        if gear.targetLevel <= level+5 and not self:GetStatus(gear)
            and (scope=="all" or (not self:IsHidden(gear)
                and not self:IsGearEquipped(gear)
                and self:GetObsoleteGearReason(gear)==nil)) then
            for _,mat in ipairs(gear.reagents or {}) do
                total[mat.itemID]=(total[mat.itemID] or 0)+mat.amount
            end
        end
    end
    -- One dynamic bag tier at a time. Quantities are already multiplied by
    -- number of bag slots requiring replacement. Non-tailors do not receive
    -- a misleading personal crafting shopping list.
    local bag = self.GetBagUpgradePlan and self:GetBagUpgradePlan() or nil
    if bag and bag.profession=="Tailoring" and not self:IsHidden(bag) then
        for _,mat in ipairs(bag.reagents or {}) do
            total[mat.itemID]=(total[mat.itemID] or 0)+mat.amount
        end
    end
    for id,qty in pairs(total) do
        list[#list+1]={itemID=id,amount=qty,name=(GetGear.MaterialNames and GetGear.MaterialNames[id]) or NAMES[id] or ("Item "..id)}
    end
    table.sort(list,function(a,b) return a.name<b.name end)
    return VisibleRows(Plan(list), "total:" .. (scope or "tracked"), self.db)
end

-- The professions API is present in WoW Forever's Mainline-derived client.
-- Never substitute 0 for a profession that hasn't been learned.
function GetGear:GetProfessionSkill(profession)
    if type(GetProfessions)~="function" or type(GetProfessionInfo)~="function" then return nil end
    local indices={GetProfessions()}
    for i=1,5 do
        local index=indices[i]
        if index then
            local name,_,skill=GetProfessionInfo(index)
            if type(name)=="string" and type(skill)=="number" and name:lower()==profession:lower() then
                return skill
            end
        end
    end
    return nil
end

function GetGear:GetProfessionDisplay(gear)
    if not gear.professionSkillRequired or gear.recipeLearnSkillEvidence=="unverified" then return nil end
    local current=self:GetProfessionSkill(gear.profession)
    local name=gear.profession
    if current==nil then return name.."  -/"..gear.professionSkillRequired.." (not learned)",false end
    return name.."  "..current.."/"..gear.professionSkillRequired,current>=gear.professionSkillRequired
end

function GetGear:MaterialName(itemID)
    return (self.MaterialNames and self.MaterialNames[itemID]) or NAMES[itemID] or (INTERMEDIATE[itemID] and INTERMEDIATE[itemID].name) or ("Item "..tostring(itemID))
end
