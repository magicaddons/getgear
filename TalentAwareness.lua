local addonName, GetGear = ...

-- Forever exposes Classic-style tree names as C_Traits groups in one
-- CamelotCombat config. Read active investment only; never use retail spec IDs
-- or write nodes. Unknown/localized trees and incomplete APIs fail open.
local TREES = {
    WARRIOR={Arms="physical",Fury="physical",Protection="tank"},
    PALADIN={Holy="healer",Protection="spell-tank",Retribution="physical"},
    HUNTER={["Beast Mastery"]="ranged",Marksmanship="ranged",Survival="ranged"},
    ROGUE={Assassination="physical",Combat="physical",Subtlety="physical"},
    PRIEST={Discipline="hybrid-caster",Holy="healer",Shadow="caster"},
    SHAMAN={Elemental="caster",Enhancement="physical",Restoration="healer"},
    MAGE={Arcane="caster",Fire="caster",Frost="caster"},
    WARLOCK={Affliction="caster",Demonology="caster",Destruction="caster"},
    DRUID={Balance="caster",["Feral Combat"]="feral",Restoration="healer"},
}

local function SafeCall(fn,...)
    if type(fn)~="function" then return nil end
    local ok,result=pcall(fn,...)
    if not ok or type(issecretvalue)=="function" and issecretvalue(result) then return nil end
    return result
end
local function Points(value)
    return not (type(issecretvalue)=="function" and issecretvalue(value))
        and type(value)=="number" and value==value and value>=0
        and value<math.huge and value==math.floor(value)
end
local function TreeName(display,trees)
    if type(display)~="string" then return end
    display=display:match("^%s*(.-)%s*$")
    for name in pairs(trees) do
        -- Accept a display suffix, but keep multi-word names intact. Do not
        -- guess from tree order or interpret unrelated groups as class trees.
        if display==name or display:sub(1,#name+2)==name.." (" then return name end
    end
end

function GetGear:RefreshTalentAwareness()
    self.dominantTalentTree=nil
    self.talentTreePoints=nil
    self.talentOrientation=nil
    self.talentAwarenessClass=self.classToken
    self.talentInvestmentState="unknown"
    local trees=TREES[self.classToken]
    if not trees or type(C_ClassTalents)~="table" or type(C_Traits)~="table" then return nil end
    local configID=SafeCall(C_ClassTalents.GetActiveConfigID)
    if not Points(configID) or configID<=0 then return nil end
    local config=SafeCall(C_Traits.GetConfigInfo,configID)
    if type(config)~="table" or type(config.treeIDs)~="table" then return nil end
    if type(C_Traits.GetGroupDisplayInfoByTreeID)~="function"
        or type(C_Traits.GetGroupCurrencyInfo)~="function" then return nil end

    local totals,seenIDs,seenTrees={},{},{}
    local discovered=0
    for _,treeID in ipairs(config.treeIDs) do
        local groups=SafeCall(C_Traits.GetGroupDisplayInfoByTreeID,treeID)
        if type(groups)~="table" then return nil end
        local ids,names={},{}
        for _,g in ipairs(groups) do
            if type(g)~="table" then return nil end
            local name=TreeName(g.displayName,trees)
            if name then
                if not Points(g.groupID) or seenIDs[g.groupID] or seenTrees[name] then return nil end
                ids[#ids+1]=g.groupID;names[g.groupID]=name
                seenIDs[g.groupID]=true;seenTrees[name]=true
                discovered=discovered+1;totals[name]=0
            end
        end
        if #ids>0 then
            local currency=SafeCall(C_Traits.GetGroupCurrencyInfo,configID,ids)
            if type(currency)~="table" then return nil end
            local seenRows={}
            for _,row in ipairs(currency) do
                if type(row)~="table" then return nil end
                if names[row.traitNodeGroupID] then
                    if seenRows[row.traitNodeGroupID] or type(row.currencyInfos)~="table" then return nil end
                    seenRows[row.traitNodeGroupID]=true
                    local spent,currencies=0,{}
                    for _,cur in ipairs(row.currencyInfos) do
                        if type(cur)~="table" or not Points(cur.spent) then return nil end
                        if cur.traitCurrencyID then
                            if currencies[cur.traitCurrencyID] then return nil end
                            currencies[cur.traitCurrencyID]=true
                        end
                        spent=spent+cur.spent -- staged/pending fields never contribute
                    end
                    totals[names[row.traitNodeGroupID]]=spent
                end
            end
        end
    end
    if discovered~=3 then return nil end
    self.talentTreePoints=totals
    local best,bestCount,second,total=nil,-1,-1,0
    for name in pairs(trees) do
        local amount=totals[name];total=total+amount
        if amount>bestCount then second=bestCount;bestCount=amount;best=name
        elseif amount>second then second=amount end
    end
    self.talentInvestmentState=total==0 and "unspent" or bestCount<3 and "early" or "mixed"
    -- A few committed points, a clear lead AND a substantial majority. Mixed
    -- builds retain class-wide recommendations, including physical/caster utility.
    if bestCount>=3 and bestCount-second>=2 and bestCount>=total*0.7 then
        self.talentInvestmentState="focused"
        self.dominantTalentTree=best
        self.talentOrientation=trees[best]
    end
    return self.dominantTalentTree
end

function GetGear:GetDominantTalentTree()
    return self.talentAwarenessClass==self.classToken and self.dominantTalentTree or nil
end

function GetGear:GetTalentOrientation()
    return self.talentAwarenessClass==self.classToken and self.talentOrientation or nil
end
