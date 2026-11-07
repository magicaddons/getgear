local addonName, GetGear = ...

-- Restore documented early crafted gear that was previously absent from
-- GetGear, regardless of the character's selected specialization.
-- Sources: WoW Forever client item/reagent data, cross-checked against
-- RaidDex (Nov 5 2026), The Forever Era and Wowhead Forever.
-- The equip requirement is NOT the recipe learning/skill-up threshold.
local function Mat(id,name,amount)
    return {itemID=id,name=name,amount=amount}
end

local entries={
    {
        itemID=3473,name="Runed Copper Pants",slot="Legs",level=8,
        stats="113 mail armor, +2 Strength, +2 Stamina",
        -- Hunter/Shaman cannot wear mail until level 40; at level 8
        -- these are early upgrades only for Warrior and Paladin.
        classes={"WARRIOR","PALADIN"},
        reagents={
            Mat(2840,"Copper Bar",8),
            Mat(2320,"Coarse Thread",3),
            Mat(3470,"Rough Grinding Stone",3),
        },
        yellow=75,green=95,gray=115,
        sourceURL="https://raiddex.com/en/wow-forever/items/runed-copper-pants",
    },
    {
        itemID=3489,name="Thick War Axe",slot="Main Hand",level=12,
        stats="One-hand axe, 8.6 DPS, +1 Strength, +1 Stamina",
        -- Forever explicitly added one-handed axes to Rogue proficiency.
        classes={"WARRIOR","PALADIN","HUNTER","ROGUE","SHAMAN"},
        reagents={
            Mat(2840,"Copper Bar",10),
            Mat(2880,"Weak Flux",2),
            Mat(2842,"Silver Bar",2),
            Mat(3470,"Rough Grinding Stone",2),
            Mat(2318,"Light Leather",2),
        },
        yellow=85,green=105,gray=125,
        sourceURL="https://raiddex.com/en/wow-forever/items/thick-war-axe",
    },
}

local audit={itemsAdded=0,recommendationsAdded=0,alreadyPresent=0}
for _,item in ipairs(entries) do
    if not GetGear.ItemCatalog[item.itemID] then
        assert(GetGear:RegisterItem({
            itemID=item.itemID,name=item.name,slot=item.slot,
            availableLevel=item.level,sourceType="Blacksmithing",
            source="Blacksmithing trainer (Forever client recipe)",
            zone="Blacksmithing / other players / Auction House",
            profession="Blacksmithing",
            recipeLearnMethod="trainer",
            recipeLearnSkillEvidence="unverified",
            -- Do not use the yellow-skill threshold as trainer-learning minimum.
            recipeLearningAvailability="Trainer-listed; exact learning skill requires live confirmation",
            recipeYellowSkill=item.yellow,
            recipeGreenSkill=item.green,
            recipeGraySkill=item.gray,
            confidence="client",acquisitionKind="Crafting",
            acquisitionConfidence="client",sourceURL=item.sourceURL,
            reagents=item.reagents,notes=item.stats,
            instructions="This Bind-on-Equip item is made by Blacksmithing. You can craft it, commission a blacksmith, or buy it from another player. The item's required character level is separate from recipe skill thresholds. Confirm live trainer availability.",
        }),"Could not register "..item.name)
        audit.itemsAdded=audit.itemsAdded+1
    end
    for _,classToken in ipairs(item.classes) do
        local exists=false
        for _,rec in ipairs(GetGear.Recommendations[classToken] or {}) do
            if rec.itemID==item.itemID then exists=true;break end
        end
        if not exists then
            assert(GetGear:AddRecommendation(classToken,{
                itemID=item.itemID,targetLevel=item.level,focus="All",
            }),"Failed to add "..item.name.." to "..classToken)
            audit.recommendationsAdded=audit.recommendationsAdded+1
        else
            audit.alreadyPresent=audit.alreadyPresent+1
        end
    end
end
GetGear.EarlyCoverage133=audit
