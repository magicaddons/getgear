local addonName, GetGear = ...

-- WoW Forever's three Classic-style talent tabs are C_Traits groups inside
-- one CamelotCombat config. Retail spec IDs DO NOT identify these trees.
-- Read the committed build only. Never write talent nodes or change points.
-- Failure/ambiguity means NO school-specific exclusions.

local MAGE_TREES = {Fire=true, Frost=true, Arcane=true}

local function SafeCall(fn,...)
    if type(fn)~="function" then return nil end
    local ok,result=pcall(fn,...)
    if not ok then return nil end
    return result
end

function GetGear:RefreshTalentAwareness()
    self.dominantTalentTree=nil
    self.talentTreePoints=nil
    if self.classToken~="MAGE" then return nil end
    if type(C_ClassTalents)~="table" or type(C_Traits)~="table" then return nil end
    local configID=SafeCall(C_ClassTalents.GetActiveConfigID)
    if type(configID)~="number" or configID<=0 then return nil end
    local config=SafeCall(C_Traits.GetConfigInfo,configID)
    if type(config)~="table" or type(config.treeIDs)~="table" then return nil end
    if type(C_Traits.GetGroupDisplayInfoByTreeID)~="function"
        or type(C_Traits.GetGroupCurrencyInfo)~="function" then return nil end

    local totals={}
    local discovered=0
    for _,treeID in ipairs(config.treeIDs) do
        local groups=SafeCall(C_Traits.GetGroupDisplayInfoByTreeID,treeID)
        if type(groups)~="table" then return nil end
        local ids,names={},{}
        for _,g in ipairs(groups) do
            if type(g)=="table" and type(g.groupID)=="number"
                and type(g.displayName)=="string" then
                local name=g.displayName:match("^(%S+)")
                if name and MAGE_TREES[name] then
                    ids[#ids+1]=g.groupID
                    names[g.groupID]=name
                    discovered=discovered+1
                    totals[name]=0
                end
            end
        end
        if #ids>0 then
            local currency=SafeCall(C_Traits.GetGroupCurrencyInfo,configID,ids)
            if type(currency)~="table" then return nil end
            for _,row in ipairs(currency) do
                if type(row)=="table" and names[row.traitNodeGroupID] then
                    local spent=0
                    for _,cur in ipairs(row.currencyInfos or {}) do
                        if type(cur.spent)=="number" and cur.spent>0 then
                            spent=spent+cur.spent
                        end
                    end
                    totals[names[row.traitNodeGroupID]]=spent
                end
            end
        end
    end
    if discovered~=3 then return nil end
    self.talentTreePoints=totals
    local best,bestCount,second=nil,-1,-1
    for name in pairs(MAGE_TREES) do
        local amount=totals[name] or 0
        if amount>bestCount then
            second=bestCount
            bestCount=amount
            best=name
        elseif amount>second then
            second=amount
        end
    end
    -- Avoid guessing from a single low-level point or ties/hybrids.
    -- A clear, committed lead triggers only PURE school-damage exclusions.
    if bestCount>=3 and bestCount-second>=2 then
        self.dominantTalentTree=best
    end
    return self.dominantTalentTree
end

function GetGear:GetDominantTalentTree()
    return self.dominantTalentTree
end
