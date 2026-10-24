local addonName, GetGear = ...

-- Live, read-only equipment comparisons. We use item stats supplied by the
-- Forever client; missing stat data never becomes an invented zero.
local SLOT = {
    Head={1}, Neck={2}, Shoulder={3}, Chest={5}, Waist={6}, Legs={7},
    Feet={8}, Wrist={9}, Hands={10}, Back={15}, Wand={18},
    Ring={11,12}, Trinket={13,14}, ["Off Hand"]={17},
    ["Ranged"]={18}, ["Thrown"]={18},
    ["Two-Hand Staff"]={16,17}, ["Two-Hand"]={16,17},
    ["Two-Hand Mace"]={16,17}, ["Two-Hand Polearm"]={16,17},
    ["Two-Hand Axe"]={16,17}, ["Two-Hand Sword"]={16,17}, ["Main Hand"]={16},
    ["Relic"]={18},
}
local TWO_HANDED = { ["Two-Hand Staff"]=true, ["Two-Hand"]=true,
    ["Two-Hand Mace"]=true, ["Two-Hand Polearm"]=true,
    ["Two-Hand Axe"]=true, ["Two-Hand Sword"]=true }
local STAT_LABELS = {
    ITEM_MOD_STRENGTH_SHORT="Strength", ITEM_MOD_AGILITY_SHORT="Agility",
    ITEM_MOD_INTELLECT_SHORT="Intellect", ITEM_MOD_STAMINA_SHORT="Stamina",
    ITEM_MOD_SPIRIT_SHORT="Spirit", ITEM_MOD_ARMOR_SHORT="Armor",
    RESISTANCE0_NAME="Armor", RESISTANCE1_NAME="Holy Resistance",
    RESISTANCE2_NAME="Fire Resistance", RESISTANCE3_NAME="Nature Resistance",
    RESISTANCE4_NAME="Frost Resistance", RESISTANCE5_NAME="Shadow Resistance",
    RESISTANCE6_NAME="Arcane Resistance",
    SPELL_DAMAGE_TOTAL="Spell Damage",
    SPELL_HEALING_TOTAL="Spell Healing",
    ITEM_MOD_SHADOW_DAMAGE_SHORT="Shadow Damage",
    ITEM_MOD_FIRE_DAMAGE_SHORT="Fire Damage",
    ITEM_MOD_FROST_DAMAGE_SHORT="Frost Damage",
    ITEM_MOD_NATURE_DAMAGE_SHORT="Nature Damage",
    ITEM_MOD_ARCANE_DAMAGE_SHORT="Arcane Damage",
    ITEM_MOD_HOLY_DAMAGE_SHORT="Holy Damage",
    ITEM_MOD_CRIT_RATING_SHORT="Crit Rating",
    ITEM_MOD_HASTE_RATING_SHORT="Haste Rating",
    ITEM_MOD_HIT_RATING_SHORT="Hit Rating",
    ITEM_MOD_MANA_REGENERATION_SHORT="Mana Regeneration",
    ITEM_MOD_HEALTH_SHORT="Health", ITEM_MOD_MANA_SHORT="Mana",
    ITEM_MOD_ATTACK_POWER_SHORT="Attack Power",
    ITEM_MOD_DAMAGE_PER_SECOND_SHORT="Weapon DPS",
}
local STAT_ORDER = {
    "ITEM_MOD_INTELLECT_SHORT", "ITEM_MOD_STAMINA_SHORT", "ITEM_MOD_SPIRIT_SHORT",
    "SPELL_DAMAGE_TOTAL", "SPELL_HEALING_TOTAL",
    "ITEM_MOD_SHADOW_DAMAGE_SHORT", "ITEM_MOD_FIRE_DAMAGE_SHORT",
    "ITEM_MOD_FROST_DAMAGE_SHORT", "ITEM_MOD_ARCANE_DAMAGE_SHORT",
    "ITEM_MOD_HOLY_DAMAGE_SHORT", "ITEM_MOD_NATURE_DAMAGE_SHORT",
    "ITEM_MOD_STRENGTH_SHORT", "ITEM_MOD_AGILITY_SHORT", "RESISTANCE0_NAME",
}
local RANK = {}
for i,key in ipairs(STAT_ORDER) do RANK[key]=i end

local function IsSafe(v)
    return type(v)=="number" and
       (type(issecretvalue)~="function" or not issecretvalue(v)) and v==v
end
local function Pretty(key)
    if STAT_LABELS[key] then return STAT_LABELS[key] end
    if _G and type(_G[key])=="string" then
        local label=_G[key]
        if not label:find("%%") then return label end
    end
    return key:gsub("^ITEM_MOD_",""):gsub("_SHORT$",""):gsub("_"," "):lower():gsub("^%l",string.upper)
end
-- The client can encode a universal spell bonus as SPELL_POWER, or give
-- separate spell-damage and healing values. These are NOT three independent
-- attributes. Prefer explicit damage/healing when present, otherwise use the
-- universal value for each. Avoid summing API aliases and double counting.
local SPELL_KEYS = {
    ITEM_MOD_SPELL_POWER_SHORT=true,
    ITEM_MOD_SPELL_DAMAGE_DONE_SHORT=true, ITEM_MOD_SPELL_DAMAGE_SHORT=true,
    ITEM_MOD_SPELL_HEALING_DONE_SHORT=true, ITEM_MOD_SPELL_HEALING_SHORT=true,
    ITEM_MOD_HEALING_DONE_SHORT=true,
}
local function FirstStat(t, keys)
    for _,key in ipairs(keys) do
        if t[key] ~= nil then return t[key] end
    end
end
local function NormalizeStats(raw)
    local safe={}
    for key,value in pairs(raw) do
        if type(key)=="string" and IsSafe(value) and not SPELL_KEYS[key] then safe[key]=value end
    end
    local generic=raw.ITEM_MOD_SPELL_POWER_SHORT
    if not IsSafe(generic) then generic=nil end
    local damage=FirstStat(raw,{"ITEM_MOD_SPELL_DAMAGE_DONE_SHORT", "ITEM_MOD_SPELL_DAMAGE_SHORT"})
    local healing=FirstStat(raw,{"ITEM_MOD_SPELL_HEALING_DONE_SHORT", "ITEM_MOD_HEALING_DONE_SHORT", "ITEM_MOD_SPELL_HEALING_SHORT"})
    if not IsSafe(damage) then damage=generic end
    if not IsSafe(healing) then healing=generic end
    if IsSafe(damage) then safe.SPELL_DAMAGE_TOTAL=damage end
    if IsSafe(healing) then safe.SPELL_HEALING_TOTAL=healing end
    return safe
end
local function Stats(link)
    if not link or not C_Item or type(C_Item.GetItemStats)~="function" then return nil end
    local ok, result=pcall(C_Item.GetItemStats,link)
    if not ok or type(result)~="table" then return nil end
    return NormalizeStats(result)
end
local function ItemStats(itemID)
    if type(itemID)~="number" then return nil end
    local out=Stats("item:"..itemID)
    if out then return out end
    if C_Item and type(C_Item.RequestLoadItemDataByID)=="function" then
        pcall(C_Item.RequestLoadItemDataByID,itemID)
    end
    return nil
end
local function Equipped(slot)
    if type(GetInventoryItemLink)~="function" then return nil end
    local ok, link=pcall(GetInventoryItemLink,"player",slot)
    return ok and type(link)=="string" and link or nil
end
-- Equipped is a live presentation status, never persisted as "acquired".
-- Compare item IDs, not names/stats: the same item in either ring/trinket
-- slot counts, while different enchants on the same base item still match.
local function LinkItemID(link)
    if type(link)~="string" then return nil end
    local id=link:match("item:(%d+)")
    return id and tonumber(id) or nil
end
function GetGear:IsGearEquipped(gear)
    if not gear or type(gear.itemID)~="number" then return false end
    local slots=SLOT[gear.slot]
    if not slots then return false end
    for _,slot in ipairs(slots) do
        local link=Equipped(slot)
        if LinkItemID(link)==gear.itemID then return true end
        -- Some versions expose an inventory ID before a full link is cached.
        if not link and type(GetInventoryItemID)=="function" then
            local ok,id=pcall(GetInventoryItemID,"player",slot)
            if ok and IsSafe(id) and id==gear.itemID then return true end
        end
    end
    return false
end
local function IsTwoHanded(link)
    if not link or not C_Item or type(C_Item.GetItemInventoryTypeByID)~="function" then return nil end
    local ok, invType=pcall(C_Item.GetItemInventoryTypeByID,link)
    if not ok or not IsSafe(invType) then return nil end
    return invType==17
end
local function Combine(a,b)
    local result={}
    for key,value in pairs(a or {}) do result[key]=(result[key] or 0)+value end
    for key,value in pairs(b or {}) do result[key]=(result[key] or 0)+value end
    return result
end
local function MakeGroup(label, candidate, equippedLinks)
    local result={label=label,rows={}}
    if #equippedLinks==0 then
        result.message="No item equipped";return result
    end
    local base={}
    for _,link in ipairs(equippedLinks) do
        local equipped=Stats(link)
        if not equipped then
            result.message="Equipped item stats not available yet"
            return result
        end
        base=Combine(base,equipped)
    end
    if not candidate then
        result.message="Recommended item stats are loading"
        return result
    end
    local union={}
    for key in pairs(base) do union[key]=true end
    for key in pairs(candidate) do union[key]=true end
    local keys={}
    for key in pairs(union) do keys[#keys+1]=key end
    table.sort(keys,function(a,b)
        if (RANK[a] or 900)~=(RANK[b] or 900) then return (RANK[a] or 900)<(RANK[b] or 900) end
        return Pretty(a)<Pretty(b)
    end)
    for _,key in ipairs(keys) do
        local old,new=base[key] or 0,candidate[key] or 0
        local delta=new-old
        if delta>0.0001 or delta< -0.0001 then
            result.rows[#result.rows+1]={name=Pretty(key), key=key, old=old,
               new=new, delta=delta}
        end
    end
    if #result.rows==0 then result.message="No differences in reported base stats" end
    return result
end

function GetGear:GetGearComparison(gear)
    if type(gear)~="table" then return nil end
    if self:IsGearEquipped(gear) then return {message="Already equipped",groups={}} end
    local slots=SLOT[gear.slot]
    if not slots then return {message="No comparison available for this slot",groups={}} end
    local candidate=ItemStats(gear.itemID)
    local groups={}
    if gear.slot=="Ring" or gear.slot=="Trinket" then
        for index,slot in ipairs(slots) do
            local link=Equipped(slot)
            groups[#groups+1]=MakeGroup(gear.slot.." "..index,candidate,link and {link} or {})
        end
    elseif gear.slot=="Off Hand" then
        local main=Equipped(16)
        if main and IsTwoHanded(main)==true then
            return {message="A two-handed weapon is equipped; requires a one-handed weapon.",groups={}}
        end
        if main and IsTwoHanded(main)==nil then
            return {message="Cannot confirm main-hand type yet; off-hand comparison unavailable.",groups={}}
        end
        local link=Equipped(17)
        groups[1]=MakeGroup("Off Hand",candidate,link and {link} or {})
    elseif TWO_HANDED[gear.slot] then
        local links={}
        for _,slot in ipairs(slots) do
            local link=Equipped(slot)
            if link then links[#links+1]=link end
        end
        groups[1]=MakeGroup("Main Hand + Off Hand",candidate,links)
    else
        local link=Equipped(slots[1])
        groups[1]=MakeGroup(gear.slot,candidate,link and {link} or {})
    end
    return {groups=groups}
end
-- v0.10.5: Reversible earlier-gear classification. Equipment-ID matching
-- is handled independently; there is no implicit SavedVariables migration.
local OBSOLETE_ARMOR_SLOTS = {
    Head=1, Shoulder=3, Chest=5, Waist=6, Legs=7, Feet=8,
    Wrist=9, Hands=10, Back=15,
}
local function ItemInfo(item)
    local getter = C_Item and C_Item.GetItemInfo or GetItemInfo
    if type(getter) ~= "function" then return nil end
    local ok, name, link, quality, itemLevel = pcall(getter,item)
    if not ok or not name or not IsSafe(quality) or not IsSafe(itemLevel) then
        if type(item)=="number" and C_Item and type(C_Item.RequestLoadItemDataByID)=="function" then
            pcall(C_Item.RequestLoadItemDataByID,item)
        end
        return nil
    end
    return {quality=quality,level=itemLevel}
end
local function HasPossibleSpecialEffect(gear)
    -- Notes are an exclusion heuristic, not proof that tooltip effects are absent.
    local s=((gear.notes or "").." "..(gear.benefitsText or "")):lower()
    for _,word in ipairs({"on use","on-use","chance on hit","proc", "set bonus",
            "movement speed", "unique effect", "special effect", "equip:"}) do
        if s:find(word,1,true) then return true end
    end
    return false
end
local function Dominates(candidate,equipped,candidateQuality)
    local candidateHasStats=false
    for key,value in pairs(candidate) do
        -- DPS is compared separately for wands; never treat it as a stat.
        if key~="ITEM_MOD_DAMAGE_PER_SECOND_SHORT" then
            if value>0 then candidateHasStats=true end
            if (equipped[key] or 0)+0.0001<value then return false end
        end
    end
    if not candidateHasStats and candidateQuality~=1 then return false end
    for key,value in pairs(equipped) do
        if key~="ITEM_MOD_DAMAGE_PER_SECOND_SHORT" and value>(candidate[key] or 0)+0.0001 then
            return true
        end
    end
    return false
end
local function ToolTipDPS(link)
    if not C_TooltipInfo or type(C_TooltipInfo.GetHyperlink)~="function" then return nil end
    local ok,data=pcall(C_TooltipInfo.GetHyperlink,link)
    if not ok or type(data)~="table" or type(data.lines)~="table" then return nil end
    for _,line in ipairs(data.lines) do
        for _,value in ipairs({line.leftText,line.rightText}) do
            if type(value)=="string" then
                local clean=value:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
                local dps=clean:lower():match("([%d%.]+)%s+damage per second")
                    or clean:lower():match("([%d%.]+)%s+dps")
                if dps then return tonumber(dps) end
            end
        end
    end
    return nil
end
-- Conservative fallback for the two verified test-case wand IDs only.
-- The client tooltip is preferred; patch changes should update these values.
local VERIFIED_WAND_DPS = {[247789]=4.0, [279896]=18.53}
local function WeaponDPS(link,itemID,wandFallback)
    local stats=Stats(link)
    local value=stats and stats.ITEM_MOD_DAMAGE_PER_SECOND_SHORT
    if IsSafe(value) and value>0 then return value end
    value=ToolTipDPS(link)
    if IsSafe(value) and value>0 then return value end
    -- Never guess melee/ranged weapon DPS from item level or tooltip text.
    return wandFallback and VERIFIED_WAND_DPS[itemID] or nil
end

local OBSOLETE_WEAPON_SLOTS = {
    ["Ranged"]=18, ["Thrown"]=18, ["Main Hand"]=16, ["Off Hand"]=17,
    ["Two-Hand Staff"]=16, ["Two-Hand"]=16, ["Two-Hand Mace"]=16,
    ["Two-Hand Polearm"]=16, ["Two-Hand Axe"]=16, ["Two-Hand Sword"]=16,
}
-- Exclude use/proc items even when a recommendation's editorial notes omit it.
-- A green/blue tooltip that isn't readable cannot safely be declared obsolete.
local function TooltipEffectOrUnknown(link,quality)
    if quality<=1 then return false end
    if not C_TooltipInfo or type(C_TooltipInfo.GetHyperlink)~="function" then return true end
    local ok,data=pcall(C_TooltipInfo.GetHyperlink,link)
    if not ok or type(data)~="table" or type(data.lines)~="table" or #data.lines==0 then return true end
    for _,line in ipairs(data.lines) do
        for _,value in ipairs({line.leftText,line.rightText}) do
            if type(value)=="string" then
                local t=value:lower()
                if t:find("chance on hit",1,true) or t:find("equip:",1,true)
                    or t:find("use:",1,true) or t:find("on use",1,true)
                    or t:find("procs",1,true) or t:find("set:",1,true) then return true end
            end
        end
    end
    return false
end
local function InventoryType(link)
    if not C_Item or type(C_Item.GetItemInventoryTypeByID)~="function" then return nil end
    local ok,value=pcall(C_Item.GetItemInventoryTypeByID,link)
    return ok and IsSafe(value) and value or nil
end
local function WeaponSlotComparable(slot,equippedLink,candidateLink)
    local equippedType=InventoryType(equippedLink)
    local candidateType=InventoryType(candidateLink)
    if not equippedType or not candidateType then return false end
    if TWO_HANDED[slot] then return equippedType==17 and candidateType==17 end
    if slot=="Main Hand" then
        return (equippedType==13 or equippedType==21)
            and (candidateType==13 or candidateType==21)
    end
    if slot=="Off Hand" then
        return (equippedType==13 or equippedType==22)
            and (candidateType==13 or candidateType==22)
    end
    if slot=="Thrown" then return equippedType==25 and candidateType==25 end
    -- Different Forever ranged weapon subtypes may be 15 or 26. Both
    -- represent ranged weapons here; thrown (25) is never mixed in.
    if slot=="Ranged" then
        return (equippedType==15 or equippedType==26)
            and (candidateType==15 or candidateType==26)
    end
    return false
end
local function NoWeaponStatTradeoff(candidate,equipped)
    if not candidate or not equipped then return false end
    for key,value in pairs(candidate) do
        if key~="ITEM_MOD_DAMAGE_PER_SECOND_SHORT" and (equipped[key] or 0)+0.0001<value then
            return false
        end
    end
    return true
end
function GetGear:GetObsoleteGearReason(gear)
    if not gear or not self.db or not self.db.overlay or self.db.overlay.filterObsolete==false then return nil end
    local characterLevel=self.level or 1
    if type(gear.targetLevel)~="number" or characterLevel-gear.targetLevel < 5 then return nil end
    if HasPossibleSpecialEffect(gear) then return nil end
    if gear.slot=="Wand" then
        local equippedLink=Equipped(18)
        if not equippedLink then return nil end
        local equippedID=LinkItemID(equippedLink)
        if equippedID==gear.itemID then return nil end
        local candidateInfo,equippedInfo=ItemInfo(gear.itemID),ItemInfo(equippedLink)
        if not candidateInfo or not equippedInfo then return nil end
        if candidateInfo.quality<1 or candidateInfo.quality>2 then return nil end
        if equippedInfo.quality<candidateInfo.quality then return nil end
        local candidateDPS=WeaponDPS("item:"..gear.itemID,gear.itemID,true)
        local equippedDPS=WeaponDPS(equippedLink,equippedID,true)
        if not candidateDPS or not equippedDPS or equippedDPS<=candidateDPS+0.0001 then return nil end
        -- Spell power, resistances, attributes, and other benefits could
        -- outweigh extra DPS. Fail open if a candidate offers a tradeoff.
        local candidate,equipped=ItemStats(gear.itemID),Stats(equippedLink)
        if not candidate or not equipped then return nil end
        for key,value in pairs(candidate) do
            if key~="ITEM_MOD_DAMAGE_PER_SECOND_SHORT" and (equipped[key] or 0)+0.0001<value then return nil end
        end
        return "Equipped wand has higher damage per second without losing any reported base stats. Compare damage school/effects manually."
    end
    local weaponSlot=OBSOLETE_WEAPON_SLOTS[gear.slot]
    if weaponSlot then
        local equippedLink=Equipped(weaponSlot)
        if not equippedLink or LinkItemID(equippedLink)==gear.itemID then return nil end
        local candidateLink="item:"..gear.itemID
        local candidateInfo,equippedInfo=ItemInfo(gear.itemID),ItemInfo(equippedLink)
        if not candidateInfo or not equippedInfo then return nil end
        -- Only low-quality ordinary gear is eligible for automatic removal.
        if candidateInfo.quality<1 or candidateInfo.quality>2 then return nil end
        if equippedInfo.quality<candidateInfo.quality or equippedInfo.level<candidateInfo.level then return nil end
        if not WeaponSlotComparable(gear.slot,equippedLink,candidateLink) then return nil end
        if TooltipEffectOrUnknown(candidateLink,candidateInfo.quality) then return nil end
        local candidateDPS=WeaponDPS(candidateLink,gear.itemID)
        local equippedDPS=WeaponDPS(equippedLink,LinkItemID(equippedLink))
        if not candidateDPS or not equippedDPS or equippedDPS<=candidateDPS+0.0001 then return nil end
        if not NoWeaponStatTradeoff(ItemStats(gear.itemID),Stats(equippedLink)) then return nil end
        return "Equipped weapon has higher reported DPS and no lower reported base stats. Verify speed, damage school and effects manually."
    end
    local slot=OBSOLETE_ARMOR_SLOTS[gear.slot]
    if not slot then return nil end
    local link=Equipped(slot)
    if not link then return nil end
    local candidateInfo,equippedInfo=ItemInfo(gear.itemID),ItemInfo(link)
    if not candidateInfo or not equippedInfo then return nil end
    if candidateInfo.quality<1 or candidateInfo.quality>2 then return nil end
    if equippedInfo.quality<candidateInfo.quality or equippedInfo.level<candidateInfo.level then return nil end
    local candidate,equipped=ItemStats(gear.itemID),Stats(link)
    if not candidate or not equipped then return nil end
    if not Dominates(candidate,equipped,candidateInfo.quality) then return nil end
    return "Equipped item has at least as much of every reported base stat. Check unusual effects manually."
end
local function Number(n)
    if math.abs(n-math.floor(n+0.5))<0.0001 then return tostring(math.floor(n+0.5)) end
    return string.format("%.1f",n)
end
function GetGear:ComparisonNumber(n) return Number(n) end
local function IsFeralWeapon(self, gear)
    if self.classToken ~= "DRUID" then return false end
    if self:GetSpecialization() ~= "Feral Cat" and self:GetSpecialization() ~= "Feral Bear" then return false end
    return gear and (TWO_HANDED[gear.slot] or gear.slot=="Main Hand")
end
local function IsWarriorWeapon(self,gear)
    return self.classToken == "WARRIOR" and gear
        and (TWO_HANDED[gear.slot] or gear.slot=="Main Hand")
end
function GetGear:ComparisonInline(gear, detailed)
    local comparison=self:GetGearComparison(gear)
    if not comparison then return "",false end
    if comparison.message then
        return "|cff96a6ba"..comparison.message.."|r",true
    end
    local lines={}
    for _,group in ipairs(comparison.groups) do
        if #comparison.groups > 1 or TWO_HANDED[gear.slot] then
            lines[#lines+1]="|cff96a6baVs "..group.label.."|r"
        end
        if group.message then
            lines[#lines+1]="|cff96a6ba"..group.message.."|r"
        else
            local bits={}
            for _,stat in ipairs(group.rows) do
                local color=stat.delta>0 and "|cff66e29b" or "|cffff7777"
                local prefix=stat.delta>0 and "+" or ""
                local change=prefix..Number(stat.delta).." "..stat.name
                if detailed then
                    change=Number(stat.old).." -> "..Number(stat.new).."  ("..change..")"
                end
                bits[#bits+1]=color..change.."|r"
            end
            lines[#lines+1]=table.concat(bits,detailed and "\n" or "   ")
        end
    end
    if IsFeralWeapon(self,gear) then
        lines[#lines+1]="|cff96a6baFeral: also compare weapon DPS manually; form DPS may differ.|r"
    elseif IsWarriorWeapon(self,gear) then
        lines[#lines+1]="|cff96a6baWarrior: compare weapon DPS, speed and effects manually; stat deltas are incomplete.|r"
    end
    return table.concat(lines,"\n"),true
end
function GetGear:AppendComparisonTooltip(tip,gear)
    if not tip or not gear then return end
    local compare=self:GetGearComparison(gear)
    if not compare then return end
    tip:AddLine(" ")
    tip:AddLine("Gear comparison (base item stats)",1,0.82,0.35)
    if compare.message then
        tip:AddLine(compare.message,0.72,0.78,0.85,true)
        return
    end
    for _,group in ipairs(compare.groups) do
        tip:AddLine("Against "..group.label,0.75,0.83,0.95)
        if group.message then tip:AddLine(group.message,0.7,0.7,0.7,true)
        else
            for _,stat in ipairs(group.rows) do
                local r,g,b=1,0.45,0.45
                if stat.delta>0 then r,g,b=0.38,0.90,0.53 end
                local plus=stat.delta>0 and "+" or ""
                tip:AddDoubleLine("  "..stat.name,
                    Number(stat.old).." -> "..Number(stat.new).."  ("..plus..Number(stat.delta)..")",
                    1,1,1,r,g,b)
            end
        end
    end
    tip:AddLine("Enchantments, on-use effects and weapon DPS are not fully compared.",0.63,0.67,0.74,true)
    if IsFeralWeapon(self,gear) then
        tip:AddLine("Feral forms: check weapon DPS manually; the base-stat delta alone is insufficient.",0.95,0.72,0.42,true)
    elseif IsWarriorWeapon(self,gear) then
        tip:AddLine("Warrior: compare weapon DPS, speed and proc effects manually; stat deltas are insufficient to rank weapons.",0.95,0.72,0.42,true)
    end
end
