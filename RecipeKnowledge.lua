local addonName, GetGear = ...

-- Forever uses the modern TradeSkillUI recipe API, but the profession panel
-- may need to be opened before some recipe information is available.
-- Return true only on positive in-game evidence; nil means not verified.
local learnedCache = {}
local function Norm(name)
    if type(name)~="string" then return nil end
    return (name:lower():gsub("%s+"," "):gsub("^%s+",""):gsub("%s+$",""))
end

-- The modern recipe list includes unlearned entries. Inspect the .learned
-- flag, and scan only when the profession window fires its update event.
local learnedNames = {}
function GetGear:ResetRecipeKnowledge()
    learnedCache = {}
    learnedNames = {}
end
function GetGear:ScanKnownRecipes()
    if not (C_TradeSkillUI and type(C_TradeSkillUI.GetAllRecipeIDs)=="function"
        and type(C_TradeSkillUI.GetRecipeInfo)=="function"
        and type(C_TradeSkillUI.GetTradeSkillLine)=="function") then return end
    local okLine,skillLineID,skillLineName=pcall(C_TradeSkillUI.GetTradeSkillLine)
    if not okLine then return end
    local profession=Norm(type(skillLineName)=="string" and skillLineName or skillLineID)
    if not profession or profession=="" then return end
    local ok,ids=pcall(C_TradeSkillUI.GetAllRecipeIDs)
    if not ok or type(ids)~="table" then return end
    local names=learnedNames[profession] or {}
    for _,id in ipairs(ids) do
        local okInfo,info=pcall(C_TradeSkillUI.GetRecipeInfo,id)
        if okInfo and type(info)=="table" and info.learned==true then
            if Norm(info.name) then names[Norm(info.name)]=true end
            learnedCache[id]=true
        end
    end
    learnedNames[profession]=names
end

function GetGear:GetRecipeKnowledge(gear)
    if not gear or not gear.profession or
        not (self.GetProfessionSkill and self:GetProfessionSkill(gear.profession)) then
        return nil
    end
    local spellID=gear.recipeSpellID
    if spellID and learnedCache[spellID] then return true end
    local names=learnedNames[Norm(gear.profession)]
    if names and names[Norm(gear.name)] then return true end
    if spellID and C_TradeSkillUI and type(C_TradeSkillUI.GetRecipeInfo)=="function" then
        local ok,info=pcall(C_TradeSkillUI.GetRecipeInfo,spellID)
        if ok and type(info)=="table" and info.learned==true then
            learnedCache[spellID]=true
            return true
        end
    end
    if spellID and type(IsSpellKnown)=="function" then
        local ok,known=pcall(IsSpellKnown,spellID)
        if ok and known==true then
            learnedCache[spellID]=true
            return true
        end
    end
    return nil
end
