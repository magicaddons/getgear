local addonName, GetGear = ...
-- WoW Forever launch-client evidence update, build 1.60.1.70755.
-- Blizzard (Nov 2) announced newly obtainable random dungeon-drop profession
-- recipes. Launch-client Pattern/Plans item tooltips now establish exact
-- *learning* minima. This module deliberately does not infer a specific boss.
-- Quest and ACA vendor inventories are not changed without new direct evidence.

local newPatterns = {
    -- [finished item ID] = {pattern item ID, learning profession, learning skill}
    -- Leather Pants (not the separate Leather Legguards/Kilts)
    [252445]={252794,"Leatherworking",100}, -- Defender's Leather Pants
    [252501]={252793,"Leatherworking",100}, -- Trapper's Leather Pants
    [252502]={252796,"Leatherworking",100}, -- Stormrider's Leather Pants
    [252503]={252797,"Leatherworking",100}, -- Wisdom's Leather Pants
    -- Chain Helms (NOT Silvered Chain Helms sold by ACA)
    [250500]={251352,"Blacksmithing",125}, -- Protector's Chain Helm
    [250501]={251353,"Blacksmithing",125}, -- Acolyte's Chain Helm
    [250502]={251354,"Blacksmithing",125}, -- Crusader's Chain Helm
}
local aud={patternLearnCorrections={}, optionalHelmCrafts={}, familyPatternIDs={
    -- All six newly introduced lvl-25 helm pattern items, four catalogued here.
    [252512]=252814, [252455]=252816, [252456]=252817,
    [252515]=252819,
}}
-- Complete family record includes the two currently uncatalogued finished helms.
aud.familyPatternNames={
    [252814]="Brawler's Leather Helm", [252815]="Trapper's Leather Helm",
    [252816]="Defender's Leather Helm", [252817]="Totemic Leather Helm",
    [252818]="Stormrider's Leather Helm",[252819]="Wisdom's Leather Helm",
}
local function Link(id) return "https://www.wowhead.com/forever/item="..id end
for id, details in pairs(newPatterns) do
    local item=assert(GetGear.ItemCatalog[id],"Launch pattern requires existing item "..id)
    local patternID,profession,skill=details[1],details[2],details[3]
    assert(item.profession==profession and item.reagents and #item.reagents>0,
        "Launch pattern overwrote noncraft or wrong profession item "..id)
    item.professionSkillRequired=skill
    item.professionSkillEstimate=nil
    item.professionLearnSource="Pattern"
    item.recipeLearnMethod="pattern"
    item.recipeLearnSkillEvidence="Forever launch-client teaching item requirement (1.60.1.70755)"
    item.recipeLearnSkillProvisional=nil
    item.recipeLearningAvailability="pattern documented; dungeon source unverified"
    item.recipeMethodCaution=nil
    item.recipePatternItemID=patternID
    item.recipeLearningSourceURL=Link(patternID)
    item.recipeRequirementEvidenceURL=Link(patternID)
    item.recipeMethodEvidenceURL=Link(patternID)
    item.recipeVendor=nil
    item.recipeVendorCurrency=nil
    item.recipeVendorCost=nil
    item.acquisitionLocation=nil -- a trainer / ACA marker must not imply pattern stock
    item.acquisitionLocationConfidence=nil
    item.acquisitionKind="Dungeon pattern (recipe item)"
    item.acquisitionConfidence="client"
    item.source=""..(profession=="Blacksmithing" and "Plans: " or "Pattern: ")..item.name.." (dungeon recipe item)"
    item.sourceType=profession
    item.zone="Dungeon pattern drops — exact boss unconfirmed"
    item.instructions="Acquire "..(profession=="Blacksmithing" and "Plans: " or "Pattern: ")..
        item.name.." (item #"..patternID..") and learn it at "..profession.." "..skill..". "..
        "Blizzard's November 2 notes announced additional Blacksmithing/Leatherworking recipes "..
        "as dungeon drops. The precise boss for this plan/pattern has not yet been verified. "..
        "The finished item binds when picked up and must be crafted by the character who will wear it."
    item.sourceURL=Link(patternID)
    aud.patternLearnCorrections[#aud.patternLearnCorrections+1]=id
    -- Recommendation records may hold older trainer/source wording.
    for _,recs in pairs(GetGear.Recommendations or {}) do
        for _,rec in ipairs(recs) do
            if rec.itemID==id then
                rec.instructions=nil
                if type(rec.notes)=="string" and rec.notes:lower():find("trainer",1,true) then
                    rec.notes="Crafted from a newly indexed dungeon-drop recipe item; precise boss unverified."
                end
            end
        end
    end
end

-- Four leather helms were safely classified as observed/reported finished
-- dungeon drops in 0.12.10. Newly surfaced PATTERNS add an alternative
-- *personal* craft route; they do not invalidate finished-item drop reports.
-- Don't place these optional reagents in the default Material totals: a
-- player obtaining a dropped helm does not need to craft it.
local optionalCrafts={
    [252512]={252814,{{2319,12,"Medium Leather"},{4233,2,"Cured Medium Hide"},{1210,3,"Shadowgem"}}},
    [252455]={252816,{{2319,12,"Medium Leather"},{4233,2,"Cured Medium Hide"},{2458,3,"Elixir of Minor Fortitude"}}},
    [252456]={252817,{{2319,12,"Medium Leather"},{4233,2,"Cured Medium Hide"},{249410,3,"Sulfuric Acid"}}},
    [252515]={252819,{{2319,12,"Medium Leather"},{4233,2,"Cured Medium Hide"},{5498,3,"Small Lustrous Pearl"}}},
}
for id, data in pairs(optionalCrafts) do
    local item=assert(GetGear.ItemCatalog[id],"Missing launch dual-route helm "..id)
    assert(item.profession==nil and item.reagents==nil and item.acquisitionKind=="Dungeon boss drop",
        "Expected prior dungeon-drop correction for dual-route helm "..id)
    local patternID,mats=data[1],data[2]
    local parts={}
    for _,mat in ipairs(mats) do parts[#parts+1]=mat[2].." "..mat[3] end
    local detail="Alternative: Pattern: "..item.name.." (item #"..patternID..
        ") is indexed in the launch client and requires Leatherworking 125 to learn. "..
        "Crafting materials: "..table.concat(parts,", ")..". "..
        "The finished helm binds on pickup, so a crafter must make their own. "..
        "Blizzard announced additional dungeon-drop patterns; the exact boss for this pattern is not verified. "..
        "Do not confuse it with the separately crafted level-20 Leather Hood."
    item.optionalCraft={profession="Leatherworking",skill=125,
        patternItemID=patternID,patternURL=Link(patternID),reagents=mats,
        sourceConfidence="launch-client-pattern-item; dungeon boss unknown"}
    item.source="Dungeon boss drop; optional Leatherworking pattern"
    item.instructions="Finished-item dungeon-drop reports exist for this helm (exact current boss chance unverified). "..detail
    item.acquisitionResearchNote="Two distinct routes: reported finished-item dungeon loot; launch-client learnable pattern. Neither is a Leatherworking trainer recipe."
    for _,recs in pairs(GetGear.Recommendations or {}) do
        for _,rec in ipairs(recs) do
            if rec.itemID==id then
                rec.notes="Dungeon loot; optional crafted version available via a Leatherworking 125 pattern."
                rec.instructions=nil
            end
        end
    end
    aud.optionalHelmCrafts[#aud.optionalHelmCrafts+1]=id
end
GetGear.LaunchEvidence131=aud
