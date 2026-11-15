local _, GetGear = ...

-- Weights are per reported item-stat unit, not estimated combat percentages.
-- Unknown effects are never assigned a made-up score. No talent/spec choice.
local definitions = {
    {"ITEM_MOD_INTELLECT_SHORT", "Intellect", 1},
    {"SPELL_DAMAGE_TOTAL", "Spell Damage", 2},
    {"SPELL_HEALING_TOTAL", "Healing Power", 1},
    {"ITEM_MOD_SPIRIT_SHORT", "Spirit", 0.7},
    {"ITEM_MOD_STAMINA_SHORT", "Stamina", 0.5},
    {"ITEM_MOD_STRENGTH_SHORT", "Strength", 2},
    {"ITEM_MOD_AGILITY_SHORT", "Agility", 2},
    {"ITEM_MOD_ATTACK_POWER_SHORT", "Attack Power", 0.2},
    {"ITEM_MOD_DAMAGE_PER_SECOND_SHORT", "Weapon DPS", 5},
    {"ITEM_MOD_HEALTH_SHORT", "Health", 0.05},
    {"ITEM_MOD_MANA_SHORT", "Mana", 0.04},
    {"ITEM_MOD_CRIT_RATING_SHORT", "Crit Rating", 0.5},
    {"ITEM_MOD_HIT_RATING_SHORT", "Hit Rating", 0.5},
    {"ITEM_MOD_HASTE_RATING_SHORT", "Haste Rating", 0.5},
    {"ITEM_MOD_MANA_REGENERATION_SHORT", "Mana Regeneration", 2},
    {"RESISTANCE0_NAME", "Armor", 0.02},
}
for _, school in ipairs({"Holy", "Fire", "Nature", "Frost", "Shadow", "Arcane"}) do
    definitions[#definitions+1]={"ITEM_MOD_"..school:upper().."_DAMAGE_SHORT", school.." Damage", 2}
end
for i, school in ipairs({"Holy", "Fire", "Nature", "Frost", "Shadow", "Arcane"}) do
    definitions[#definitions+1]={"RESISTANCE"..i.."_NAME", school.." Resistance", 0.1}
end
GetGear.StatPriorityDefinitions=definitions
local known={}
for _, row in ipairs(definitions) do known[row[1]]=row end
local function finite(n) return type(n)=="number" and n==n and n>=0 and n<=100 end

function GetGear:InitializeStatPriorities()
    if not self.db then return end
    local p=self.db.statPriorities
    if type(p)~="table" then p={};self.db.statPriorities=p end
    if p.mode~="priority" and p.mode~="custom" then p.mode="balanced" end
    if not known[p.preferred] then p.preferred="SPELL_DAMAGE_TOTAL" end
    if type(p.weights)~="table" then p.weights={} end
    for key,value in pairs(p.weights) do
        if not known[key] or not finite(value) then p.weights[key]=nil end
    end
end

function GetGear:SetStatPriority(mode, preferred)
    if not self.db or (mode~="balanced" and mode~="priority" and mode~="custom") then return false end
    self:InitializeStatPriorities()
    local p=self.db.statPriorities
    if preferred and not known[preferred] then return false end
    p.mode=mode;p.preferred=preferred or p.preferred
    if self.RefreshAll then self:RefreshAll() end
    return true
end

function GetGear:SetCustomStatWeight(key, value)
    value=tonumber(value)
    if not self.db or not known[key] or not finite(value) then return false end
    self:InitializeStatPriorities()
    self.db.statPriorities.weights[key]=value
    if self.RefreshAll then self:RefreshAll() end
    return true
end

function GetGear:GetStatWeight(key, gear)
    local row=known[key]
    if not row then return nil end
    if self.IsClassRelevantStat and not self:IsClassRelevantStat(key,gear) then return 0 end
    local p=self.db and self.db.statPriorities or {}
    local weight=row[3]
    local class=self.classToken
    if key=="ITEM_MOD_STRENGTH_SHORT" and (class=="ROGUE" or class=="HUNTER") then weight=1 end
    if key=="ITEM_MOD_AGILITY_SHORT" and (class=="WARRIOR" or class=="PALADIN") then weight=1.2 end
    if key=="RESISTANCE0_NAME" and not (self.db and self.db.overlay and self.db.overlay.countArmorOnlyUpgrades)
        and not (p.mode=="priority" and p.preferred==key) then weight=0 end
    if p.mode=="custom" and type(p.weights)=="table" and finite(p.weights[key]) then weight=p.weights[key] end
    if p.mode=="priority" and p.preferred==key then weight=weight*3 end
    return weight
end

function GetGear:GetStatPriorityExplanation()
    local p=self.db and self.db.statPriorities or {}
    if p.mode=="priority" then return "Recommended based on "..(known[p.preferred] and known[p.preferred][2] or "stat").." priority." end
    if p.mode=="custom" then return "Recommended based on custom stat weights." end
    return "Recommended based on balanced stat gains and losses."
end

-- Score the actual replacement groups produced by the existing comparison
-- engine. Rings use the best legal slot; potential offhand benefits aren't a set.
function GetGear:GetWeightedUpgrade(gear, comparison)
    if not gear or gear.bagUpgrade then return nil end
    comparison=comparison or self:GetGearComparison(gear,true)
    if not comparison or not comparison.groups or #comparison.groups==0 then return nil end
    local best,uncertain=nil,false
    local links={["item:"..gear.itemID]=true}
    for _,group in ipairs(comparison.groups) do
        for _,link in ipairs(group.equippedLinks or {}) do links[link]=true end
        if not group.potentialOnly then
            if not group.comparable or group.dpsUnknown and (not self.IsClassRelevantStat or self:IsClassRelevantStat("ITEM_MOD_DAMAGE_PER_SECOND_SHORT",gear)) then
                uncertain=true
            else
                local score,unknown=0,false
                for _,stat in ipairs(group.rows or {}) do
                    local weight=self:GetStatWeight(stat.key,gear)
                    if weight then score=score+stat.delta*weight
                    elseif stat.delta>0 then unknown=true end
                end
                if unknown then uncertain=true end
                if not unknown and (best==nil or score>best) then best=score end
            end
        end
    end
    local text=((gear.notes or "").." "..(gear.benefitsText or "")):lower()
    local effects={"chance on hit","on use","on-use","proc","set bonus","movement speed","unique effect","special effect"}
    for _,word in ipairs(effects) do if text:find(word,1,true) then uncertain=true end end
    -- A readable tooltip can reveal utility omitted by the stat API. Unknown
    -- tooltip effects aren't assigned a value or used as a scored upgrade.
    if C_TooltipInfo and type(C_TooltipInfo.GetHyperlink)=="function" then
        for link in pairs(links) do
            local ok,tip=pcall(C_TooltipInfo.GetHyperlink,link)
            if ok and type(tip)=="table" then
                for _,line in ipairs(tip.lines or {}) do
                    local t=((line.leftText or "").." "..(line.rightText or "")):lower()
                    for _,word in ipairs(effects) do if t:find(word,1,true) then uncertain=true end end
                    if t:find("use:",1,true) then uncertain=true end
                end
            end
        end
    end
    if gear.hasUnquantifiedEffect or uncertain then return nil end
    return best
end

function GetGear:SortUpgradeRecommendations(list)
    local scores={}
    for _,gear in ipairs(list) do scores[gear]=self:GetWeightedUpgrade(gear) end
    table.sort(list,function(a,b)
        local sa,sb=scores[a],scores[b]
        if a.bagUpgrade~=b.bagUpgrade then return a.bagUpgrade==true end
        if (sa~=nil)~=(sb~=nil) then return sa~=nil end
        if sa and sb and math.abs(sa-sb)>0.0001 then return sa>sb end
        if a.targetLevel~=b.targetLevel then return a.targetLevel<b.targetLevel end
        return (a.itemID or 0)<(b.itemID or 0)
    end)
end
