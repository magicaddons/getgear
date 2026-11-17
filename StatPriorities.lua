local _, GetGear = ...

-- Per-character preferences. Scores are planning units, not simulated combat
-- performance. Balanced retains the established class-aware tradeoff filter.
local definitions={
    {"ITEM_MOD_INTELLECT_SHORT","Intellect",2}, {"ITEM_MOD_STAMINA_SHORT","Stamina",1},
    {"ITEM_MOD_SPIRIT_SHORT","Spirit",1}, {"ITEM_MOD_STRENGTH_SHORT","Strength",2},
    {"ITEM_MOD_AGILITY_SHORT","Agility",2}, {"SPELL_DAMAGE_TOTAL","Spell Damage",1},
    {"SPELL_HEALING_TOTAL","Spell Healing",1}, {"ITEM_MOD_ATTACK_POWER_SHORT","Attack Power",0.5},
    {"ITEM_MOD_DAMAGE_PER_SECOND_SHORT","Weapon DPS",3},
    {"ITEM_MOD_MANA_REGENERATION_SHORT","Mana Regeneration",2},
    {"ITEM_MOD_HEALTH_SHORT","Health",0.1}, {"ITEM_MOD_MANA_SHORT","Mana",0.1},
    {"ITEM_MOD_CRIT_RATING_SHORT","Crit Rating",1}, {"ITEM_MOD_HIT_RATING_SHORT","Hit Rating",1},
    {"ITEM_MOD_HASTE_RATING_SHORT","Haste Rating",1}, {"RESISTANCE0_NAME","Armor",0},
}
for _,school in ipairs({"Holy","Fire","Nature","Frost","Shadow","Arcane"}) do
    definitions[#definitions+1]={"ITEM_MOD_"..school:upper().."_DAMAGE_SHORT",school.." Damage",1}
end
for i,school in ipairs({"Holy","Fire","Nature","Frost","Shadow","Arcane"}) do
    definitions[#definitions+1]={"RESISTANCE"..i.."_NAME",school.." Resistance",0.1}
end
GetGear.StatPriorityDefinitions=definitions
local known={};for _,d in ipairs(definitions) do known[d[1]]=d end
local function finite(n) return type(n)=="number" and n==n and math.abs(n)<math.huge end
local function weight(n) return finite(n) and n>=0 and n<=1000 end

function GetGear:InitializeStatPriorities()
    if not self.db then return end
    local p=type(self.db.statPriorities)=="table" and self.db.statPriorities or {}
    if p.mode~="priority" and p.mode~="custom" then p.mode="balanced" end
    if not known[p.priority] then p.priority="ITEM_MOD_SPIRIT_SHORT" end
    if self.IsClassRelevantStat and not self:IsClassRelevantStat(p.priority,{slot="Wand"},nil,true) then
        p.priority=(self.classToken=="WARRIOR" or self.classToken=="ROGUE") and "ITEM_MOD_STRENGTH_SHORT" or "ITEM_MOD_AGILITY_SHORT"
    end
    local clean={}
    for key,value in pairs(type(p.weights)=="table" and p.weights or {}) do
        if known[key] and weight(value) then clean[key]=value end
    end
    p.weights=clean;self.db.statPriorities=p
    return p
end

function GetGear:GetStatPriorityMode()
    local p=self.db and self.db.statPriorities
    return p and (p.mode=="priority" or p.mode=="custom") and p.mode or "balanced"
end

function GetGear:GetSupportedPriorityStats(class,gear)
    local out={}
    for _,d in ipairs(definitions) do
        if not self.IsClassRelevantStat or self:IsClassRelevantStat(d[1],gear or {slot="Wand"},class,true) then
            out[#out+1]=d
        end
    end
    return out
end

function GetGear:SetStatPriorityMode(mode)
    if mode~="balanced" and mode~="priority" and mode~="custom" then return false end
    local p=self:InitializeStatPriorities();if not p then return false end
    if mode=="custom" and next(p.weights)==nil then
        for _,d in ipairs(self:GetSupportedPriorityStats()) do p.weights[d[1]]=d[3] end
    end
    p.mode=mode
    if self.RefreshAll then self:RefreshAll() end
    return true
end

function GetGear:SetPriorityStat(key)
    if not known[key] then return false end
    local p=self:InitializeStatPriorities();if not p then return false end
    p.priority=key
    if self.RefreshAll then self:RefreshAll() end
    return true
end

function GetGear:SetCustomStatWeight(key,value)
    if not known[key] or not weight(value) then return false end
    local p=self:InitializeStatPriorities();if not p then return false end
    p.weights[key]=value
    if self.RefreshAll then self:RefreshAll() end
    return true
end

function GetGear:ResetStatPriorities()
    if not self.db then return end
    self.db.statPriorities=nil;self:InitializeStatPriorities()
    if self.RefreshAll then self:RefreshAll() end
end

-- These are conservative planning weights, not combat simulation or equip
-- restrictions. Utility still contributes to net tradeoffs, but utility alone
-- cannot establish an upgrade for a confidently physical/caster/healing build.
local PHYSICAL={ITEM_MOD_INTELLECT_SHORT=0.1,ITEM_MOD_SPIRIT_SHORT=0.1,
    ITEM_MOD_MANA_SHORT=0.1,ITEM_MOD_MANA_REGENERATION_SHORT=0.1,
    SPELL_DAMAGE_TOTAL=0.05,SPELL_HEALING_TOTAL=0.05,school=0.05}
local CASTER={ITEM_MOD_STRENGTH_SHORT=0.1,ITEM_MOD_AGILITY_SHORT=0.1,
    ITEM_MOD_ATTACK_POWER_SHORT=0.1,ITEM_MOD_DAMAGE_PER_SECOND_SHORT=0.1,
    SPELL_HEALING_TOTAL=0.15}
local HEALER={ITEM_MOD_STRENGTH_SHORT=0.1,ITEM_MOD_AGILITY_SHORT=0.1,
    ITEM_MOD_ATTACK_POWER_SHORT=0.1,ITEM_MOD_DAMAGE_PER_SECOND_SHORT=0.1,
    SPELL_DAMAGE_TOTAL=0.15,SPELL_HEALING_TOTAL=2,school=0.15}
local PROFILES={physical=PHYSICAL,feral=PHYSICAL,ranged={
    ITEM_MOD_STRENGTH_SHORT=0.1,ITEM_MOD_INTELLECT_SHORT=0.3,
    ITEM_MOD_SPIRIT_SHORT=0.1},tank={ITEM_MOD_STAMINA_SHORT=2},
    ["spell-tank"]={ITEM_MOD_STAMINA_SHORT=2,ITEM_MOD_INTELLECT_SHORT=0.5,
        SPELL_DAMAGE_TOTAL=0.5,SPELL_HEALING_TOTAL=0.1,school=0.5},
    caster=CASTER,healer=HEALER,["hybrid-caster"]={}}

function GetGear:GetBalancedTalentStatFactor(key,class)
    if self:GetStatPriorityMode()~="balanced" or class and class~=self.classToken then return 1 end
    local orientation=self.GetTalentOrientation and self:GetTalentOrientation()
    local profile=orientation and PROFILES[orientation]
    if not profile then return 1 end
    local value=profile[key]
    if value==nil and key:match('^ITEM_MOD_%u+_DAMAGE_SHORT$') then value=profile.school end
    return value or 1
end

function GetGear:GetStatWeight(key,gear,class)
    local d=known[key];if not d then return 0 end
    if self.IsClassRelevantStat and not self:IsClassRelevantStat(key,gear,class,true) then return 0 end
    local p=self.db and self.db.statPriorities or {}
    if self:GetStatPriorityMode()=="custom" then return weight(p.weights and p.weights[key]) and p.weights[key] or 0 end
    local value=d[3]
    if key=="RESISTANCE0_NAME" and self.db and self.db.overlay and self.db.overlay.countArmorOnlyUpgrades then value=0.01 end
    if self:GetStatPriorityMode()=="priority" and key==p.priority then value=(value>0 and value or 0.01)*5 end
    return value*self:GetBalancedTalentStatFactor(key,class)
end

function GetGear:ScoreComparisonGroup(gear,group)
    if not group or not group.comparable or group.potentialOnly then return nil end
    if group.dpsUnknown and self:GetStatWeight("ITEM_MOD_DAMAGE_PER_SECOND_SHORT",gear)>0 then return nil end
    local slot=gear.slot or ""
    local weapon=slot=="Main Hand" or slot:find("^Two%-Hand") or slot=="Wand" or slot=="Ranged" or slot=="Thrown"
        or slot=="Off Hand" and ({Dagger=true,Axe=true,Sword=true,Mace=true,["Fist Weapon"]=true})[gear.armorType]
    if weapon and self:GetStatWeight("ITEM_MOD_DAMAGE_PER_SECOND_SHORT",gear)>0
        and (not group.candidateDPS or not group.emptySlot and not group.baselineDPS) then return nil end
    local score,primaryGain=0,false
    for _,row in ipairs(group.rows or {}) do
        if not finite(row.delta) then return nil end
        local statWeight=self:GetStatWeight(row.key,gear)
        score=score+row.delta*statWeight
        if row.delta>0.0001 and statWeight>0 and self:GetBalancedTalentStatFactor(row.key)>=0.5 then
            primaryGain=true
        end
    end
    if self:GetStatPriorityMode()=="balanced" and self.GetTalentOrientation
        and self:GetTalentOrientation() and not primaryGain then score=math.min(score,0) end
    return finite(score) and score or nil
end

function GetGear:GetWeightedUpgradeEvaluation(gear,comparison)
    if not gear or gear.bagUpgrade then return {status="bag"} end
    if self.CanClassEquipGear and not self:CanClassEquipGear(gear,self.classToken) then return {status="ineligible"} end
    comparison=comparison or self:GetGearComparison(gear,true)
    if not comparison or comparison.message then return {status="unknown"} end
    local best,unknown=nil,false
    for _,group in ipairs(comparison.groups or {}) do
        local score=self:ScoreComparisonGroup(gear,group)
        if score==nil then unknown=true elseif best==nil or score>best then best=score end
    end
    -- Either ring/trinket slot can establish a gain; incomplete alternatives
    -- must not establish a conclusive rejection.
    if best and best>0.0001 then return {status="upgrade",score=best} end
    if unknown or best==nil then return {status="unknown",score=best} end
    return {status="no-benefit",score=best}
end

function GetGear:ShouldRecommendByStatPriority(gear)
    if not gear or gear.bagUpgrade or self:GetStatPriorityMode()=="balanced" then return true end
    if self.db and self.db.overlay and self.db.overlay.showAllValidGear then return true end
    local result=self:GetWeightedUpgradeEvaluation(gear)
    return result.status~="no-benefit" and result.status~="ineligible"
end
