local addonName, GetGear = ...

-- v0.10.1 acquisition routes, loaded after all 5 class modules.
-- This module extends the shared item catalog: map pins are only assigned
-- for independently sourced recipe vendors or documented profession trainers.
-- Intentional exclusions: dungeon-drop patterns, unverified beta recipe
-- sources, and trainerless automatically-learned recipes. This module does
-- not add recommendations, change item IDs or edit SavedVariables.
local locations = {
    Stondry = {zone="Redridge Mountains", x=10.4, y=74.7,
        spot="Stondry Darkhammer, ACA Blacksmithing patterns, Three Corners", quality="forever"},
    Daniel = {zone="Redridge Mountains", x=10.0, y=72.9,
        spot="Daniel Stitchsong, ACA Leatherworking patterns, Three Corners", quality="forever"},
    Alynsia = {zone="Redridge Mountains", x=11.2, y=71.6,
        spot="Alynsia, ACA Enchanting formulas, Three Corners", quality="forever"},
    Granny = {zone="Ironforge", x=39.3, y=33.7,
        spot="Granny Finespindle, Leatherworking patterns", quality="reported"},
}
local vendor = {
    -- Confirmed Stondry Darkhammer stock. Ordinary Guard/Veteran chain shirts,
    -- leggings and helms are NOT the Silvered vendor versions.
    [250514]={"Stondry",30}, -- Guard's Chain Belt
    [250509]={"Stondry",30}, -- Guard's Gloves
    [250508]={"Stondry",30}, -- Veteran's Gloves
    [250504]={"Stondry",30}, -- Guard's Boots
    [250503]={"Stondry",30}, -- Veteran's Boots
    [250530]={"Stondry",30}, -- Protector's Silvered Chain Helm
    [250528]={"Stondry",30}, -- Veteran's Silvered Chain Helm
    [250519]={"Stondry",30}, -- Guard's Silvered Chain Shirt
    [250518]={"Stondry",30}, -- Veteran's Silvered Chain Shirt
    [250524]={"Stondry",30}, -- Guard's Silvered Chain Leggings
    [250523]={"Stondry",30}, -- Veteran's Silvered Chain Leggings
    -- Additional Blacksmithing recipes: exact item/skill/vendor matches against
    -- Forever beta vendor inventories (2026-10-23); pattern not finished gear.
    [250506]={"Stondry",30}, -- Acolyte's Boots
    [250511]={"Stondry",30}, -- Acolyte's Gloves
    [250531]={"Stondry",30}, -- Acolyte's Silvered Chain Helm
    [250526]={"Stondry",30}, -- Acolyte's Silvered Chain Leggings
    [250521]={"Stondry",30}, -- Acolyte's Silvered Chain Shirt
    [250505]={"Stondry",30}, -- Protector's Boots
    [250525]={"Stondry",30}, -- Protector's Silvered Chain Leggings
    [250520]={"Stondry",30}, -- Protector's Silvered Chain Shirt
    -- Daniel Stitchsong's confirmed low-level ACA pattern inventory.
    [252494]={"Daniel",30}, -- Brawler's Leather Gloves
    [252496]={"Daniel",30}, -- Defender's Leather Gloves
    [252498]={"Daniel",30}, -- Stormrider's Leather Gloves
    [252441]={"Daniel",30}, -- Defender's Leather Boots
    [252443]={"Daniel",30}, -- Stormrider's Leather Boots
    [252504]={"Daniel",30}, -- Brawler's Leather Hood
    [252507]={"Daniel",30}, -- Wisdom's Leather Hood
    [252448]={"Daniel",30}, -- Totemic Leather Hood
    [252450]={"Daniel",30}, -- Defender's Leather Tunic
    [252510]={"Daniel",30}, -- Stormrider's Leather Tunic
    [252511]={"Daniel",30}, -- Wisdom's Leather Tunic
    [252457]={"Daniel",30}, -- Defender's Leather Kilt
    [252519]={"Daniel",30}, -- Wisdom's Leather Leggings
    [252439]={"Daniel",30}, -- Brawler's Leather Boots
    [252508]={"Daniel",30}, -- Brawler's Leather Tunic
    [252495]={"Daniel",30}, -- Trapper's Leather Gloves
    [252509]={"Daniel",30}, -- Trapper's Leather Tunic
    -- Three Forever level-30 belt patterns and early Moonglow Boots are
    -- separately reported from Granny Finespindle, not Daniel Stitchsong.
    [252427]={"Granny"}, -- Moonglow Boots
    [252460]={"Granny"}, -- Warden's Leather Belt
    [252522]={"Granny"}, -- Skycaller's Leather Belt
    [252523]={"Granny"}, -- Mender's Leather Belt
    -- Enchanting / ACA, 45 Merchant's Favor for each formula.
    [249396]={"Alynsia",45}, -- Mystic Mushroom (Druid)
    [249395]={"Alynsia",45}, -- Orb of Souls (Priest)
    [249398]={"Alynsia",45}, -- Polished Driftwood Icon
    [249397]={"Alynsia",45}, -- Tenets of the Silver Hand
}

local exclusions = {
    [250489]="Plans: Guard's Chain Shirt is listed as dungeon/world drops, not Stondry stock.",
    [250494]="Guard's Chain Leggings are trainer-taught, not the ACA Silvered version.",
    [252456]="Totemic Leather Helm is separate dungeon loot from Daniel's crafted Totemic Leather Hood.",
    [253885]="Novice Arcanist's Sash pattern learning route is inconsistent between sources.",
    [254005]="Fiery Slippers trainer/pattern route is not independently confirmed in Forever.",
}

local applied, protected = {}, {}
for id,route in pairs(vendor) do
    local item = GetGear.ItemCatalog and GetGear.ItemCatalog[id]
    assert(item, "AcquisitionRoutes: missing catalog item "..id)
    local key, favor=route[1], route[2]
    local place=locations[key]
    assert(place and (item.profession or item.sourceType=="Enchanting"), "AcquisitionRoutes: invalid recipe mapping "..id)
    if id==249395 then
        item.profession="Enchanting"
        item.professionSkillRequired=140
    end
    if item.acquisitionLocation and item.acquisitionLocation.zone then
        -- Never overwrite an existing route; report it for review instead.
        protected[#protected+1]=id
    else
        local prefix = (item.profession=="Blacksmithing" and "Plans: ") or
            (item.profession=="Leatherworking" and "Pattern: ") or "Formula: "
        local recipe=prefix..item.name
        local bindText
        if id==249395 then
            bindText="This is an Enchanting crafted off-hand; check its bind state before relying on another crafter. "
        elseif item.instructions and (item.instructions:find("BIND ON PICKUP",1,true) or
                    item.instructions:find("Binds when picked up",1,true) or
                    item.instructions:find("binds on pickup",1,true)) then
            bindText="The finished gear binds on pickup; THIS character must have "..item.profession.." and craft it. "
        else
            bindText="Confirm whether the finished equipment is tradeable before commissioning it. "
        end
        local vendorName = {Stondry="Stondry Darkhammer",Daniel="Daniel Stitchsong",
            Alynsia="Alynsia",Granny="Granny Finespindle"}
        local travel = key=="Granny" and "Ironforge" or "Three Corners, Redridge Mountains"
        local coords=" ("..string.format("%.1f, %.1f",place.x,place.y)..")"
        local currency=favor and (" for "..favor.." Merchant's Favor") or " (verify current vendor price)"
        local instruction="Get "..recipe.." from "..vendorName[key].." in "..travel..coords..currency..
            ". Learn it at "..item.profession.." skill "..tostring(item.professionSkillRequired or "required level")..". "..bindText
        item.acquisitionLocation=place
        item.acquisitionLocationConfidence=place.quality
        item.acquisitionKind="Recipe vendor"
        item.acquisitionConfidence=place.quality
        item.recipeLearnMethod="pattern"
        item.recipeLearnSkillEvidence="published-beta-vendor-pattern"
        item.recipeLearningSourceURL=(key=="Stondry" and "https://www.wow-professions.com/forever/npc/stondry-darkhammer")
            or (key=="Daniel" and "https://www.wow-professions.com/forever/npc/daniel-stitchsong")
            or (key=="Alynsia" and "https://www.wow-professions.com/forever/npc/alynsia")
            or "https://www.wow-professions.com/forever/"
        item.recipeVendor=vendorName[key]
        item.recipeVendorCurrency=favor and "Merchant's Favor" or nil
        item.recipeVendorCost=favor
        item.recipeLearningEvidence="published-beta-vendor; live stock to recheck"
        item.source=recipe.." — "..vendorName[key].." (recipe vendor)"
        item.zone=travel
        item.instructions=instruction
        if id==249396 then
            item.notes=(item.notes or ""):gsub("Unknown recipe source; do not farm an assumed location%.", "Formula sold by Alynsia (Azeroth Commerce Authority).")
        end
        -- Priest recommendations had their own instructions copied before
        -- the shared catalog was created; update only this confirmed route.
        if id==249395 and GetGear.Recommendations and GetGear.Recommendations.PRIEST then
            for _,rec in ipairs(GetGear.Recommendations.PRIEST) do
                if rec.itemID==id then rec.instructions=instruction end
            end
        end
        if id==249396 and GetGear.Recommendations and GetGear.Recommendations.DRUID then
            for _,rec in ipairs(GetGear.Recommendations.DRUID) do
                if rec.itemID==id then
                    rec.notes=(rec.notes or ""):gsub("No confirmed recipe learning location%.", "Formula sold by Alynsia in Redridge Mountains.")
                end
            end
        end
        applied[#applied+1]=id
    end
end
-- Wailing Caverns acquisition audit (staged; not yet a packaged release).
-- The Forever quest cache records Pattern: Deviate Scale Belt (6476) as a
-- selectable reward of Deviate Eradication from Ebru. Ebru's precise position
-- is still a Classic location; reuse the already mapped Sizzle Stick route.
local ebruReward = assert(GetGear.ItemCatalog[8071],
    "Missing existing Sizzle Stick / Deviate Eradication route")
local ebruLocation = assert(ebruReward.acquisitionLocation,
    "Missing Ebru map target")
local belt = assert(GetGear.ItemCatalog[6468], "Missing Deviate Scale Belt")
if not belt.acquisitionLocation then
    belt.acquisitionLocation = {
        zone=ebruLocation.zone, x=ebruLocation.x, y=ebruLocation.y,
        spot="Upper cave above Wailing Caverns: Ebru (Deviate Eradication)",
        quality="classic-reference", -- exact coordinate not observed in Forever
    }
    belt.acquisitionKind="Quest reward: Leatherworking pattern"
    belt.acquisitionConfidence="reported" -- reward verified in beta quest cache
    belt.source="Pattern: Deviate Scale Belt - Deviate Eradication quest reward"
    belt.zone="Wailing Caverns / The Barrens"
    belt.instructions="Take Deviate Eradication from Ebru in the upper cave above Wailing Caverns. " ..
        "Complete the dungeon quest (7 each: Deviate Ravagers, Vipers, Shamblers and Dreadfangs), " ..
        "then CHOOSE Pattern: Deviate Scale Belt as your reward. " ..
        "Sizzle Stick and Dagmire Gauntlets are mutually exclusive alternatives. " ..
        "The belt requires Leatherworking skill 90 to learn. " ..
        "The map pin is a Classic-reference approach point for Ebru's upper cave; confirm in Forever. " ..
        "The finished belt is bind-on-equip and can also be obtained through another crafter."
    if belt.notes then
        belt.notes=belt.notes:gsub("source of the pattern may differ from Classic%.",
            "The quest-cache reward is documented in Forever; location remains a Classic reference.")
    end
    for _,rec in ipairs((GetGear.Recommendations and GetGear.Recommendations.DRUID) or {}) do
        if rec.itemID==6468 and rec.notes then
            rec.notes=rec.notes:gsub("source of the pattern may differ from Classic%.",
                "The quest-cache reward is documented in Forever; location remains a Classic reference.")
        end
    end
    applied[#applied+1]=6468
end

-- Warrior: Kresh's Back is associated with Kresh in Wailing Caverns ONLY
-- through Classic loot tables. Offer dungeon-entrance navigation without
-- suggesting the Forever boss drop has been observed or the rate verified.
local kreshShield = assert(GetGear.ItemCatalog[13245], "Missing Kresh's Back")
if not kreshShield.acquisitionLocation then
    kreshShield.acquisitionLocation = {
        zone="The Barrens", x=45.9, y=36.1,
        spot="Wailing Caverns outer entrance (Kresh drop is Classic-only reference)",
        quality="classic-reference",
    }
    kreshShield.acquisitionKind="Dungeon entrance: provisional boss loot"
    kreshShield.acquisitionConfidence="classic-reference"
    applied[#applied+1]=13245
end

GetGear.AcquisitionRoutesAudit={version="0.10.3", applied=applied,
    preserved=protected, exclusions=exclusions}
