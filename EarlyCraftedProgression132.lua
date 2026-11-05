local addonName, GetGear = ...
-- GetGear: early-game crafted-upgrade gap fill (Alliance, character levels 1-15).
-- Only materially useful equip upgrades; never add cosmetic shirts, white armour
-- with no stat benefit, or a profession requirement to *wear* tradeable armour.
-- Pattern teaching minima come from the teaching ITEMS, not recipe skill colours.
-- Trainer learning thresholds with no independent evidence remain unspecified.
-- Load after the existing class guides and evidence reconciliation, before Core.

local function Mat(id, name, amount)
    return {itemID=id, name=name, amount=amount}
end

local entries = {
    {
        itemID=2572, name="Red Linen Robe", slot="Chest", level=5,
        profession="Tailoring", method="pattern", learn=25, pattern=2598,
        source="Pattern: Red Linen Robe (world/containers; exact live source unverified)",
        stats="+1 Intellect, 19 cloth armor; Bind on Equip",
        mats={Mat(2996,"Bolt of Linen Cloth",3),Mat(2320,"Coarse Thread",2),Mat(2604,"Red Dye",2)},
        classes={PRIEST=true,MAGE=true,WARLOCK=true},
        note="An early Intellect upgrade at level 5; replaces a statless starter robe. Pattern acquisition is separate from tailoring skill.",
    },
    {
        itemID=6239, name="Red Linen Vest", slot="Chest", level=7,
        profession="Tailoring", method="pattern", learn=35, pattern=6271,
        source="Pattern: Red Linen Vest (world drop/container; current location unverified)",
        stats="+2 Intellect, +1 Spell Power, 23 cloth armor; Bind on Equip",
        mats={Mat(2996,"Bolt of Linen Cloth",3),Mat(2320,"Coarse Thread",1),Mat(2604,"Red Dye",1)},
        classes={PRIEST={"Shadow"},MAGE=true,WARLOCK=true},
        note="Early offensive caster vest; optional if a stronger quest or existing chest piece is available.",
    },
    {
        itemID=6240, name="Blue Linen Vest", slot="Chest", level=7,
        profession="Tailoring", method="pattern", learn=35, pattern=6270,
        source="Pattern: Blue Linen Vest (trade supplies vendor; check live inventory)",
        stats="+2 Spirit, +1 Spell Power, 23 cloth armor; Bind on Equip",
        mats={Mat(2996,"Bolt of Linen Cloth",3),Mat(2320,"Coarse Thread",1),Mat(6260,"Blue Dye",1)},
        classes={PRIEST={"Holy","Discipline"}},
        note="Healing/regen-oriented alternative to the Red Linen Vest; choose one chest item, not both.",
    },
    {
        itemID=4308, name="Green Linen Bracers", slot="Wrist", level=7,
        profession="Tailoring", method="trainer",
        source="Tailoring trainer (minimum learning skill unverified)",
        stats="+1 Spirit, 10 cloth armor; Bind on Equip",
        mats={Mat(2996,"Bolt of Linen Cloth",3),Mat(2320,"Coarse Thread",2),Mat(2605,"Green Dye",1)},
        classes={PRIEST=true,MAGE=true,WARLOCK=true},
        note="Low-cost Spirit bracers. Do not confuse the recipe's yellow skill-up point with its trainer-learning minimum.",
    },
    {
        itemID=4239, name="Embossed Leather Gloves", slot="Hands", level=8,
        profession="Leatherworking", method="trainer",
        source="Leatherworking trainer (minimum learning skill unverified)",
        stats="+1 Agility, +1 Stamina, 41 leather armor; Bind on Equip",
        mats={Mat(2318,"Light Leather",3),Mat(2320,"Coarse Thread",2)},
        classes={ROGUE=true,HUNTER=true,DRUID={"Feral Cat","Feral Bear"},SHAMAN={"Enhancement"}},
        note="Early physical-stat gloves; no spell-damage gear is added for Rogue or Hunter.",
    },
    {
        itemID=2309, name="Embossed Leather Boots", slot="Feet", level=10,
        profession="Leatherworking", method="trainer",
        source="Leatherworking trainer (minimum learning skill unverified)",
        stats="+2 Stamina, +2 Spell Power, 48 leather armor; Bind on Equip",
        mats={Mat(2318,"Light Leather",8),Mat(2320,"Coarse Thread",5)},
        classes={DRUID={"Balance","Restoration"},SHAMAN={"Elemental","Restoration"}},
        note="Caster leather boots; deliberately excluded from Rogue/Hunter physical-DPS guides.",
    },
    {
        itemID=2312, name="Fine Leather Gloves", slot="Hands", level=10,
        profession="Leatherworking", method="pattern", learn=50,
        source="Pattern: Fine Leather Gloves (drop source unverified)",
        stats="+2 Intellect, +2 Spell Power, 43 leather armor; Bind on Equip",
        mats={Mat(4231,"Cured Light Hide",1),Mat(2318,"Light Leather",4),Mat(2320,"Coarse Thread",2)},
        classes={DRUID={"Balance","Restoration"},SHAMAN={"Elemental","Restoration"}},
        note="Caster leather gloves. Requires the separately obtained pattern; don't assume a trainer teaches it.",
    },
    {
        itemID=2851, name="Copper Chain Belt", slot="Waist", level=6,
        profession="Blacksmithing", method="trainer",
        source="Blacksmithing trainer (minimum learning skill unverified)",
        stats="+1 Stamina, 65 mail armor; Bind on Equip",
        mats={Mat(2840,"Copper Bar",6)},
        classes={WARRIOR=true,PALADIN=true},
        note="Tradeable early mail belt; a basic stat upgrade while waiting for stronger quest/ACA gear.",
    },
    {
        itemID=3469, name="Copper Chain Boots", slot="Feet", level=4,
        profession="Blacksmithing", method="trainer",
        source="Blacksmithing trainer (minimum learning skill unverified)",
        stats="+1 Stamina, 74 mail armor; Bind on Equip",
        mats={Mat(2840,"Copper Bar",8)},
        classes={PALADIN=true},
        note="Early mail feet upgrade. The Warrior guide already contains this objective.",
    },
    {
        itemID=4362, name="Rough Boomstick", slot="Ranged", level=5,
        profession="Engineering", method="trainer",
        source="Engineering trainer (minimum learning skill unverified)",
        stats="4.13 ranged DPS, +1 Stamina; Bind on Equip",
        mats={Mat(4361,"Copper Tube",1),Mat(4359,"Handful of Copper Bolts",1),Mat(4399,"Wooden Stock",1)},
        classes={HUNTER=true},
        note="Optional Engineering gun; 4.13 DPS is an early upgrade from Hornwood Recurve Bow (2.38). Requires gun proficiency and ammunition; buy or commission if not an Engineer.",
    },
}

local audit={itemsAdded=0,recommendationsAdded=0,recommendationsAlreadyPresent=0,byClass={}}
for _,entry in ipairs(entries) do
    local item=GetGear.ItemCatalog[entry.itemID]
    if not item then
        local source=entry.source
        local text="Tradeable crafted upgrade: make it yourself, commission a crafter, or obtain the finished item from players/Auction House. "
        if entry.method=="pattern" then
            text=text.."The teaching item requires "..entry.profession.." "..entry.learn.." to learn; "..
                "the named pattern itself must be obtained. "
        else
            text=text.."A "..entry.profession.." trainer is indexed, but the exact minimum learning skill is unverified. "
        end
        text=text.."The equip-level requirement is "..entry.level..", independent of the recipe requirement. "..
            "Verify current live-client acquisition and tooltips before making a special trip."
        item={
            itemID=entry.itemID,name=entry.name,slot=entry.slot,availableLevel=entry.level,
            sourceType=entry.profession,source=source,zone=entry.profession.." / player trading",
            profession=entry.profession,
            professionLearnSource=entry.method=="pattern" and "Pattern" or "Trainer",
            recipeLearnMethod=entry.method,
            recipeLearnSkillEvidence=entry.learn and "Forever teaching item tooltip" or "unverified",
            recipePatternItemID=entry.pattern,
            professionSkillRequired=entry.learn,
            recipeLearningAvailability="Forever-client-indexed; live stock unverified",
            confidence="client",acquisitionConfidence="client",acquisitionKind="Crafted gear",
            sourceURL="https://www.wowhead.com/forever/item="..entry.itemID,
            recipeLearningSourceURL=entry.pattern and ("https://www.wowhead.com/forever/item="..entry.pattern) or nil,
            instructions=text,notes=entry.stats,
            reagents=entry.mats,
        }
        assert(GetGear:RegisterItem(item),"Could not register early craft "..entry.itemID)
        audit.itemsAdded=audit.itemsAdded+1
    end
    for classToken,specs in pairs(entry.classes) do
        assert(GetGear.Recommendations[classToken],"Missing class guide "..classToken)
        local found=false
        for _,rec in ipairs(GetGear.Recommendations[classToken]) do
            if rec.itemID==entry.itemID then found=true; break end
        end
        if not found then
            local rec={itemID=entry.itemID,targetLevel=entry.level,focus="All",
                notes=entry.note}
            if type(specs)=="table" then rec.specs=specs end
            assert(GetGear:AddRecommendation(classToken,rec),"Early crafted recommendation failed "..classToken.." "..entry.itemID)
            audit.recommendationsAdded=audit.recommendationsAdded+1
            audit.byClass[classToken]=(audit.byClass[classToken] or 0)+1
        else
            audit.recommendationsAlreadyPresent=audit.recommendationsAlreadyPresent+1
        end
    end
end
GetGear.EarlyCraftedProgression132=audit
