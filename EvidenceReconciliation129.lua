local addonName, GetGear = ...
-- v0.12.9 evidence reconciliation; source claims retain their individual confidence.
-- Numeric requirements below are backed by specific WoW Forever pattern or
-- profession spell records, NOT by yellow/green/grey skill-up thresholds.
-- Recipe method and live trainer/vendor availability remain distinct.
local facts = {
    [7374] = {skill=150, kind="trainer", url="https://www.wowhead.com/forever/spell=9196/dusky-leather-armor",
        source="Leatherworking trainer (Forever recipe-list entry)",
        instructions="The Forever Leatherworking recipe lists skill 150. The specific trainer offering it in the current server has not been independently checked. Finished armor binds when equipped; another Leatherworker can craft it."},
    [2852] = {skill=15, kind="trainer", url="https://www.wowhead.com/forever/npc=957/dane-lindgren",
        source="Blacksmithing trainer (Forever trainer listing)",
        instructions="Copper Chain Pants appear at Blacksmithing 15 in the Forever trainer listing. Tradeable: craft them or obtain from another Blacksmith."},
    [252520] = {skill=150,kind="pattern",url="https://www.wowhead.com/forever/item=252827/pattern-skulkers-leather-belt",
        source="Pattern: Skulker's Leather Belt",
        instructions="Requires Leatherworking 150. The item is bind on pickup and must be crafted by the character who will wear it. Granny Finespindle is listed as a vendor in Ironforge (39.3, 33.7); current stock has not been live-checked."},
    [253885] = {skill=50,kind="pattern",url="https://www.wowhead.com/forever/item=253886/pattern-novice-arcanists-sash",
        source="Pattern: Novice Arcanist's Sash",
        instructions="Requires Tailoring 50. Check the current server for the pattern's acquisition source before travelling."},
    [254007] = {skill=140,kind="multiple",url="https://www.wowhead.com/forever/item=254008/pattern-black-slippers",
        source="Pattern: Black Slippers",
        instructions="Requires Tailoring 140. Crafting requires a Spinning Wheel. A trainer teaching route has also been reported in beta; confirm its current availability."},
    [254001] = {skill=140,kind="multiple",url="https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes",
        source="Pattern: Gilded Slippers",
        instructions="Requires Tailoring 140. Crafting requires a Spinning Wheel. Separate beta reports suggest trainer teaching as well; confirm current availability."},
    [253887] = {skill=50,kind="pattern",url="https://www.wowhead.com/forever/item=253888/pattern-novice-ardents-sash",
        source="Pattern: Novice Ardent's Sash",
        instructions="Requires Tailoring 50. The exact current-server method of acquiring the pattern remains to be checked."},
    [252459] = {skill=150,kind="pattern",url="https://www.wowhead.com/forever/items/recipes/leatherworking",
        source="Pattern: Prowler's Leather Belt",
        instructions="Requires Leatherworking 150. Granny Finespindle is listed in Ironforge (39.3, 33.7); confirm current stock. The finished belt is bind on pickup, so the wearer must craft it."},
    [252521] = {skill=150,kind="pattern",url="https://www.wowhead.com/forever/item=252828/pattern-stalkers-leather-belt",
        source="Pattern: Stalker's Leather Belt",
        instructions="Requires Leatherworking 150. Granny Finespindle is listed in Ironforge (39.3, 33.7); confirm current stock. The finished belt is bind on pickup, so the wearer must craft it."},
    [252460] = {skill=150,kind="pattern",url="https://www.wowhead.com/forever/item=252829/pattern-wardens-leather-belt",
        source="Pattern: Warden's Leather Belt",
        instructions="Requires Leatherworking 150. Granny Finespindle is listed in Ironforge (39.3, 33.7); confirm current stock. The finished belt is bind on pickup, so the wearer must craft it."},
    [252522] = {skill=150,kind="pattern",url="https://www.wowhead.com/forever/item=252831/pattern-skycallers-leather-belt",
        source="Pattern: Skycaller's Leather Belt",
        instructions="Requires Leatherworking 150. Granny Finespindle is listed in Ironforge (39.3, 33.7); confirm current stock. The finished belt is bind on pickup, so the wearer must craft it."},
    [252523] = {skill=150,kind="pattern",url="https://www.wowhead.com/forever/item=252832/pattern-menders-leather-belt",
        source="Pattern: Mender's Leather Belt",
        instructions="Requires Leatherworking 150. Granny Finespindle is listed in Ironforge (39.3, 33.7); confirm current stock. The finished belt is bind on pickup, so the wearer must craft it."},
    [5957] = {skill=1,kind="initial",url="https://questing.wiki/wow-forever/professions/leatherworking/",
        source="Initial Leatherworking recipe (learned with profession)",
        instructions="Listed as learned with Leatherworking at profession skill 1. Finished vest is bind on equip.",
    },
}
GetGear.EvidenceReconciliation129={correctedItems={}, removedObjectives={}, displayedSourceChanges={}}
for id, fact in pairs(facts) do
    local item=assert(GetGear.ItemCatalog[id], "Missing evidence-reconciled item "..id)
    assert(item.profession and item.recipeLearnMethod, "Item without profession/recipe metadata "..id)
    item.professionSkillRequired=fact.skill
    item.recipeLearnSkillEvidence="forever-record-explicit-requirement"
    item.recipeLearnSkillProvisional=false
    item.recipeRequirementEvidenceURL=fact.url
    item.recipeLearnMethod=fact.kind
    item.recipeMethodEvidence="Forever item/spell/client recipe data; current server stock not independently verified"
    item.source=fact.source
    item.instructions=fact.instructions
    if id==5957 then item.recipeLearningAvailability=nil;item.recipeMethodCaution=nil end
    if id==254007 then
        -- The old Jormund map pin is a Classic trainer reference; it is not
        -- evidence of the confirmed pattern's current vendor/drop location.
        item.acquisitionLocation=nil
        item.acquisitionKind="Pattern item; trainer teaching disputed"
        item.acquisitionConfidence="client"
    end
    if (id==252459 or id==252460 or id==252520 or
        id==252521 or id==252522 or id==252523) then
        -- Wowhead Forever indexes the pattern to Granny Finespindle; coordinates
        -- are a reported Ironforge vendor location, not a live stock test.
        item.recipeVendor="Granny Finespindle"
        item.acquisitionKind="Pattern vendor (client indexed; stock unverified)"
        item.acquisitionConfidence="client"
        if not item.acquisitionLocation then
            item.acquisitionLocation={zone="Ironforge",x=39.3,y=33.7,
                spot="Granny Finespindle: Leatherworking patterns (verify stock)",quality="reported"}
        end
    end
    -- The teaching-method disagreement for the slippers must be retained.
    GetGear.EvidenceReconciliation129.correctedItems[#GetGear.EvidenceReconciliation129.correctedItems+1]=id
end
-- A structured learning method is stronger than stale generic source text.
-- No guessed NPC, recipe minimum, bind status, or learning item is invented.
for id,item in pairs(GetGear.ItemCatalog) do
    if item.profession and type(item.source)=="string" then
        local source=item.source
        local generic=source:match("^([A-Za-z]+) recipe %(learning skill unverified%)$")
        if generic and generic==item.profession then
            if item.recipeLearnMethod=="trainer" then
                item.source=item.profession.." trainer (client-listed; availability unconfirmed)"
            elseif item.recipeLearnMethod=="initial" then
                item.source="Initial "..item.profession.." recipe"
            else
                item.source=nil
            end
            GetGear.EvidenceReconciliation129.displayedSourceChanges[#GetGear.EvidenceReconciliation129.displayedSourceChanges+1]=id
        elseif source=="Pattern/plans documented (exact learning item source unconfirmed)" then
            -- Method is visible in recipe metadata; unlocated generic phrase adds nothing.
            item.source=nil
            GetGear.EvidenceReconciliation129.displayedSourceChanges[#GetGear.EvidenceReconciliation129.displayedSourceChanges+1]=id
        elseif source:find("; plans source unknown",1,true) and item.recipeLearnMethod=="trainer" then
            item.source=item.profession.." trainer (client-listed; availability unconfirmed)"
            GetGear.EvidenceReconciliation129.displayedSourceChanges[#GetGear.EvidenceReconciliation129.displayedSourceChanges+1]=id
        end
    end
end
-- The profession/skill badge already states unresolved minimums. Remove
-- repetitive non-actionable sentences from detailed instructions, preserving
-- BoP/BoE, named sources, direct reagents, maps and meaningful cautions.
local function CleanCraftProse(text)
    if type(text)~="string" then return text end
    text=text:gsub("^[Ll]earn/craft with [A-Za-z]+ %(minimum learning skill unverified%)%.%s*","")
    text=text:gsub("^[Cc]raft through [A-Za-z]+ %(minimum learning skill unverified%)%.%s*","")
    text=text:gsub("^[Ff]orge with [A-Za-z]+ %(minimum learning skill unverified%)%.%s*","")
    text=text:gsub("^[Cc]raft with [A-Za-z]+ %(minimum learning skill unverified%)%.%s*","")
    text=text:gsub("Item and recipe are in the Forever client%. Check an available trainer/recipe source in%-game before traveling; specific instruction sources are not independently verified%.%s*","")
    text=text:gsub("Forever client listings identify a teaching pattern or plans; the exact acquisition method may still need confirmation%.%s*","")
    text=text:gsub("Forever client listings mark this as trainer%-taught; check the current trainer UI for availability%.%s*","")
    text=text:gsub("^%s+",""):gsub("%s+$","")
    return text
end
for _,item in pairs(GetGear.ItemCatalog) do
    if item.profession then
        item.instructions=CleanCraftProse(item.instructions)
        if item.itemID==5957 then
            item.notes="+1 Agility. Starter craft learned with Leatherworking; replace quickly."
        end
    end
end
for _,r in ipairs(GetGear.Recommendations.WARRIOR) do
    if type(r.notes)=="string" and r.notes:find("Tradeable: other blacksmiths/AH possible.",1,true) then
        local item=GetGear.ItemCatalog[r.itemID]
        -- Do not remove tradeability from the only place it is stated.
        if item and type(item.instructions)=="string" and
            (item.instructions:find("Tradeable",1,true) or
             item.instructions:find("tradeable",1,true)) then
            r.notes=r.notes:gsub("%s*Tradeable: other blacksmiths/AH possible%.$","")
        end
    end
end
-- Recommendation suitability fixes. Saved IDs are not deleted and shared
-- caster catalog items remain registered for Mage / Priest / Warlock.
for _,cls in ipairs({"HUNTER", "ROGUE"}) do
    local list=assert(GetGear.Recommendations[cls],cls)
    for i=#list,1,-1 do
        if list[i].itemID==273034 then
            GetGear.EvidenceReconciliation129.removedObjectives[#GetGear.EvidenceReconciliation129.removedObjectives+1]=cls..":"..list[i].id
            table.remove(list,i)
        end
    end
end
local rogue=GetGear.Recommendations.ROGUE
for _,rec in ipairs(rogue) do
    if rec.itemID==7348 then
        local filtered={}
        for _,spec in ipairs(rec.specs or {}) do if spec~="Combat" then filtered[#filtered+1]=spec end end
        assert(#filtered==2, "Expected Assassination/Subtlety Fletcher's Gloves specs")
        rec.specs=filtered
        rec.notes="Optional critical-strike gloves with a parry penalty; not recommended for Combat/Riposte."
    elseif rec.itemID==7374 then
        rec.notes="Tradeable +14 Agility chest at level 30; Forever recipe lists Leatherworking 150. Confirm current trainer availability."
    elseif rec.itemID==252520 then
        rec.notes=nil -- The shared source and instructions already cover pattern, skill and BoP.
    end
end
for _,rec in ipairs(GetGear.Recommendations.HUNTER) do
    if rec.itemID==7374 then
        rec.notes="Tradeable +14 Agility chest at level 30; Forever recipe lists Leatherworking 150. Confirm current trainer availability."
    end
end
for _,rec in ipairs(GetGear.Recommendations.WARRIOR) do
    if rec.itemID==2852 then
        rec.notes="Copper Chain Pants: early mail legs, Blacksmithing 15 in the Forever trainer listing."
    end
end
for _,rec in ipairs(GetGear.Recommendations.DRUID) do
    if rec.itemID==5957 then
        rec.notes="Starter leather vest; learned with Leatherworking at skill 1. It is not necessary to wait until 40 to learn this starter recipe."
    end
end
for _,rec in ipairs(GetGear.Recommendations.PRIEST) do
    if rec.itemID==254007 or rec.itemID==254001 then
        -- Original class instructions bypass catalogue-level corrections.
        rec.instructions=nil
    end
end
-- Put meaningful provenance warnings outside class notes, which otherwise
-- suppress catalog notes in ClassProfiles.lua's metatable lookup.
local grips=GetGear.ItemCatalog[273034]
grips.suitabilityWarning="These gloves boost Arcane and Shadow spells, not Fire or Frost spells."
