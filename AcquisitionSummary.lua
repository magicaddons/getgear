local addonName, GetGear = ...
-- Compact, human-readable acquisition hints. This module does not invent
-- boss identities or upgrade rankings. Specific reviewed facts take precedence.
-- A confidence caveat is retained wherever the underlying route is unverified.

-- Older reviewed records have human-readable source references rather than
-- typed navigation routes. Shorten their presentation without rewriting them
-- or turning a reference into a verified farm/teacher/available offer.
function GetGear:GetCompactLegacyAcquisitionSummary(gear)
    local source=type(gear.sourceSummary)=="string" and gear.sourceSummary or ""
    local recipe=gear.profession~=nil
    local prefix=recipe and "Recipe: " or "Source: "
    local minimum=self.GetRecipeSkillRequirement and self:GetRecipeSkillRequirement(gear)
    local skill=recipe and (" ("..gear.profession..(minimum and " "..minimum or "; skill unverified")..")") or ""
    local function first(text)
        text=(text:match("^([^;]+)") or text):gsub("%s*%([Nn][Pp][Cc] %d+%)",""):gsub("%s*%(%#%d+%)","")
        text=text:gsub("%s*%([^)]*unverified[^)]*%)",""):gsub("%s*%([^)]*published[^)]*%)","")
            :gsub("%s*%([Pp]ublished.*$",""):gsub("%s*%(object #%d+%)","")
        return text:gsub("%s+$","")
    end
    local function sideReference(text)
        local side
        if type(UnitFactionGroup)=="function" then
            local ok,value=pcall(UnitFactionGroup,"player")
            if ok and not (type(issecretvalue)=="function" and issecretvalue(value)) then side=value end
        end
        if text:find("Alliance:",1,true) or text:find("Horde:",1,true) then
            if side=="Alliance" or side=="Horde" then
                local part=text:match(side..":%s*(.-)%s*/%s*") or text:match(side..":%s*(.+)")
                return part
            end
        elseif text:match("^Alliance ") or text:match("^Horde ") then
            if side=="Alliance" or side=="Horde" then return text:match(side.." ([^;]+)") end
        end
        return text
    end
    if source=="" then
        if recipe and type(gear.recipeVendor)=='string' and gear.recipeVendor~='' then
            return prefix..'vendor — '..gear.recipeVendor..skill..'; stock/access unverified'
        end
        if recipe and gear.recipeAcquisitionKind=='Drop' then
            return prefix..'possible pattern drop'..skill..'; source unverified'
        end
        if recipe then return prefix.."learning source unverified"..skill.."; see Guide" end
        return nil
    end
    local lower=source:lower()
    if recipe and (lower:find("unavailable to players",1,true) or lower:find("availability conflict",1,true)) then
        return prefix.."availability/version disputed"..skill.."; see Guide"
    end
    if recipe and (lower:find("physical book origin",1,true) or lower:find("learning route unresolved",1,true)) then
        return prefix.."learning source unresolved"..skill.."; see Guide"
    end
    local learning=source:match('[Pp]ublished book requirement:%s*([^%.]+)')
    if recipe and learning then return prefix..'learning source unverified'..skill..'; learning requirement: '..learning..'; see Guide' end
    if lower:find("broad published book%-drop table") then
        return prefix.."random drop"..skill.."; not a targeted farm; other routes: Guide"
    end
    local refs=source:match("vendor references:%s*(.+)") or source:match("merchant references:%s*(.+)")
    if refs then
        local selected=sideReference(refs)
        if not selected then return prefix.."no known vendor for this faction"..skill.."; see Guide" end
        local cost=source:match("(%d+ Merchant's Favor)") or source:match("listed ([^%.;]+)")
        return prefix..first(selected)..skill..(cost and "; "..cost or "").."; stock/access unverified; alternatives: Guide"
    end
    if recipe and lower:find("published gate:",1,true) then
        local seller=source:match(";%s*([^;]+)")
        local cost=source:match("listed ([^%.;]+)")
        if seller then return prefix..first(seller)..skill..(cost and "; listed "..cost or "").."; stock/access unverified" end
    end
    refs=source:match("quest references:%s*(.+)")
    if refs then
        local selected=sideReference(refs)
        if not selected then return prefix.."no known quest for this faction"..skill.."; see Guide" end
        local name=selected:match("^(.-)%s*%(%#%d+%)") or first(selected)
        local level=selected:match("minimum quest level (%d+)") or selected:match("quest minimum level (%d+)") or selected:match("minimum (%d+)")
        return prefix.."quest — "..name..skill..(level and "; quest level "..level or "").."; prerequisites/other routes: Guide"
    end
    refs=source:match("book%-drop leads:%s*(.+)") or source:match("book%-drop references:%s*(.+)")
    if refs then
        local named=first(refs):match("^([^,]+)") or first(refs)
        return prefix.."possible drop — "..named..skill.."; drops/other sources: Guide"
    end
    local contents=source:match("lootable%-object references:%s*(.+)") or source:match("item%-container references:%s*(.+)") or source:match("gift%-container references:%s*(.+)")
    if contents then return prefix.."possible contents — "..first(contents)..skill.."; contents/access: Guide" end
    refs=source:match("book references:%s*(.+)") or source:match("trainer references%s*(.+)")
    if refs then return prefix..first(refs):gsub(" %(examples.*$","")..skill.."; learning/access unverified; other routes: Guide" end
    if lower:find('published broad drop reference',1,true) or lower:find('published world-drop references',1,true) then
        return prefix..'random world drop; current drops/rates unverified'
    end
    if lower:find('origin unresolved',1,true) or lower:find('published alias:',1,true) then
        return prefix..'origin unresolved; see Guide'
    end
    if lower:find('unavailable reference:',1,true) then return prefix..'availability disputed; current source unverified; see Guide' end
    if lower:find('flags unavailable to players',1,true) then return prefix..'listed unavailable; current availability unverified; see Guide' end
    if lower:find('published identity;',1,true) then return prefix..'named acquisition origin unresolved; current availability unverified; see Guide' end
    if lower:find('vendor identity unresolved:',1,true) then
        return prefix..'vendor unknown'..(source:match('rank%s*(%d+)') and '; listed rank '..source:match('rank%s*(%d+)') or '')..'; current requirements: Guide'
    end
    if lower:find('published acquisition reference (',1,true) or lower:find('published item/source assessment',1,true) or lower:find('published item reference;',1,true) then
        return prefix..'acquisition source unverified; see Guide'
    end
    if lower:find('published attributed player reports',1,true) then return prefix..'reported acquisition; build/access unverified; see Guide' end
    local version=source:match('Published Season of Discovery (.-) reference')
    if version then return prefix..'Season of Discovery '..version..'; Forever availability/acquisition unverified' end
    local observed=source:match('Published player%-observed sources:%s*(.+)') or source:match('Published player%-observed source:%s*(.+)') or source:match('Published player%-observed drops:%s*(.+)')
    if observed then return prefix..'reported drops — '..first(observed):gsub(' %#[%d]+','')..'; build/access unverified; other sources: Guide' end
    local enemy=source:match('Published enemy reference:%s*(.+)') or source:match('Published loot reference:%s*(.+)')
    if enemy then return prefix..'possible drop — '..first(enemy):match('^([^,]+)')..'; drops/other sources: Guide' end
    local possible=source:match('[Pp]ublished acquisition references:%s*(.+)')
    if possible then return prefix..'possible sources — '..first(possible)..'; availability/other sources: Guide' end
    -- Preserve unfamiliar factual wording; the audit reports remaining long
    -- cases instead of silently truncating costs, restrictions or names.
    source=source:gsub("[Pp]ublished enemy reference:","Possible drop:")
        :gsub("[Pp]ublished acquisition references:","Possible sources:")
        :gsub("[Pp]ublished book requirement:","Learning requirement:")
        :gsub('PvP vendor reference:','PvP vendor:'):gsub('Vendor reference:','Vendor:')
        :gsub('exact published ID','identity listed'):gsub('secondary published reference','unconfirmed lead')
        :gsub('published rank','listed rank'):gsub('Exalted published requirement','Exalted requirement')
        :gsub('Published Arena Treasure Chest reference','Arena Treasure Chest')
        :gsub('Published Sparklematic box%-content reference','Possible Sparklematic box contents')
        :gsub('Exact tooltip requirement:','Requires:')
        :gsub('published ([A-Za-z -]+quest)','%1')
    return prefix..source
end

local function acquisitionSummary(self,gear)
    if not gear or gear.bagUpgrade then return nil end
    local recipe=self.GetCompactRecipeSummary and self:GetCompactRecipeSummary(gear)
    if recipe then return recipe end
    if self.GetRecipeAcquisitionKind and self:GetRecipeAcquisitionKind(gear)=="broad-book-drop" then
        return "Recipe: broad/random-drop examples, not farm directions. See Guide for other routes; trade/Auction House if tradeable (listings unknown)."
    end
    local contextual=self.GetAcquisitionCompactSummary and self:GetAcquisitionCompactSummary(gear)
    if contextual then return contextual end
    local legacy=self:GetCompactLegacyAcquisitionSummary(gear)
    if legacy then return legacy end
    if gear.profession then
        local learning=gear.recipeLearnMethod
        if gear.recipeAcquisitionKind=="Drop" then
            return "Recipe: dropped plans/pattern (live source unverified)"
        end
        if learning=="pattern" then
            if type(gear.recipeVendor)=="string" and gear.recipeVendor~="" then
                return "Recipe: vendor - "..gear.recipeVendor
            end
            return "Recipe: plans/pattern (acquisition unverified)"
        end
        -- Trainer recipes are already identified beside MATERIALS.
        return nil
    end
    local category=tostring(gear.sourceType or ""):lower()
    local kind=tostring(gear.acquisitionKind or ""):lower()
    if category:find("dungeon",1,true) or kind:find("dungeon",1,true) then
        local zone=gear.zone
        if type(zone)~="string" or zone=="" or zone=="Source not yet confirmed" then
            return "Source: dungeon loot (location unverified)"
        end
        local source=tostring(gear.source or "")
        local enemy=source:match("^Boss:%s*(.-)%s*%(")
            or source:match("^Dungeon enemy:%s*(.-)%s*%(")
        if enemy and enemy~="" then
            -- Source imports use a generic boss field that sometimes refers
            -- to regular trash enemies; do not assert boss status here.
            return "Source: "..zone.." | Enemy: "..enemy.." (route unverified)"
        end
        return "Source: "..zone.." | dungeon loot (route unverified)"
    end
    return nil
end

function GetGear:GetAcquisitionSummary(gear)
    local text=acquisitionSummary(self,gear)
    if text and self.GetCompactAcquisitionRequirements then
        for _,requirement in ipairs(self:GetCompactAcquisitionRequirements(gear)) do
            if not text:find(requirement,1,true) then text=text..'; '..requirement end
        end
    end
    if text and gear and (gear.confidence=='classic-reference' or gear.acquisitionConfidence=='classic-reference')
        and not text:find('Classic',1,true) then text=text..'; Classic source' end
    return text
end
