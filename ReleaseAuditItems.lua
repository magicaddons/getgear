local addonName, GetGear = ...
local function New(item)
    assert(GetGear:RegisterItem(item), "Audit item registration failed "..item.itemID)
end

-- v0.11.2 data corrections: stat-checked Forever records and conservative
-- source-provenance wording. Never infer a vendor inventory from Classic.
New({itemID=7374,name="Dusky Leather Armor",slot="Chest",availableLevel=30,
    sourceType="Leatherworking",source="Tradeable Leatherworking craft (skill 175)",
    zone="Leatherworking / trade / Auction House",profession="Leatherworking",professionSkillRequired=175,
    confidence="client",acquisitionKind="Crafting",acquisitionConfidence="client",
    instructions="Binds when equipped; buy a finished piece from a player/Auction House or ask a Leatherworker with the recipe (skill 175). Actual Forever trainer/pattern learning location is not independently verified.",
    notes="Level 30 leather chest, +14 Agility, BoE.",sourceURL="https://foreverdb.net/item/7374"})
New({itemID=6953,name="Verigan's Fist",slot="Two-Hand Mace",availableLevel=22,
    sourceType="Paladin class quest (Classic reference)",source="Classic-reference: The Test of Righteousness",
    zone="Alliance Paladin quest chain (unverified)",confidence="classic-reference",acquisitionKind="Quest reward",acquisitionConfidence="classic-reference",
    instructions="Class-restricted Paladin 2H mace. Classic quest says The Test of Righteousness; no independent Forever completion/source observed. Check your current quest rewards before relying on it.",
    notes="25.6 DPS, +5 Stamina/+10 Spirit/+6 Intellect; chance to deal 39-59 Holyfire damage. Only a candidate until Forever source observed.",sourceURL="https://foreverdb.net/item/6953"})
New({itemID=270027,name="Ursine Hammer",slot="Two-Hand Mace",availableLevel=22,
    sourceType="Quest reward (seen in Forever)",source="What Comes Around... (quest #386); selectable reward, seen by one player",
    zone="Stormwind Stockade / Redridge Mountains",confidence="reported",acquisitionKind="Quest reward",acquisitionConfidence="reported",
    instructions="Pick up What Comes Around... from Guard Berton, Redridge Mountains, and defeat Targorr in the Stockade. One Forever player reported Ursine Hammer as one of three exclusive reward choices. Check the reward list before handing in.",
    notes="18.4 DPS two-hand mace, +5 Agility/+5 Spirit/+5 Intellect. Quest requires about level 22, observed reward from one player only.",sourceURL="https://foreverdb.net/item/270027"})
New({itemID=5541,name="Iridescent Hammer",slot="Main Hand",availableLevel=23,
    sourceType="Blacksmithing",source="Tradeable Blacksmithing craft; recipe in client",
    zone="Blacksmithing / trade / Auction House",profession="Blacksmithing",professionSkillRequired=115,
    confidence="client",acquisitionKind="Crafting",acquisitionConfidence="client",
    instructions="Tradeable (BoE) one-hand mace. Check an appropriate Blacksmithing trainer/recipe in-game; client recipe existence does not prove its teaching source.",
    notes="14.6 DPS, +3 Strength/+3 Stamina; pair with shield.",sourceURL="https://foreverdb.net/item/5541"})
New({itemID=2506,name="Hornwood Recurve Bow",slot="Ranged",availableLevel=3,
    sourceType="Weapon vendor",source="Weapon merchants (Classic vendor reference)",zone="Alliance bow merchants",confidence="classic-reference",acquisitionConfidence="classic-reference",acquisitionKind="Vendor",
    instructions="Basic bow commonly sold by weapon merchants in Classic. Confirm current Forever shop stock before travelling; no confirmed Forever vendor observation in this guide.",
    notes="Starter bow, 2.4 DPS in Classic reference; compare live Forever tooltip.",sourceURL="https://foreverdb.net/item/2506"})
New({itemID=11304,name="Fine Longbow",slot="Ranged",availableLevel=14,
    sourceType="Weapon vendor (Classic reference)",source="Bowyers (Classic reference; not verified on Forever)",zone="Loch Modan / Duskwood (Classic)",confidence="client",acquisitionConfidence="classic-reference",acquisitionKind="Vendor",
    instructions="Level-14 BoE bow with +4 Attack Power in Forever. Historically sold by bowyers (Cliff Hadin / Avette Fellwood); vendor list not confirmed in Forever. Another player/trade may be an option.",
    notes="Forever +4 Attack Power; consult the live tooltip for ranged DPS.",sourceURL="https://foreverchanges.pro/item/11304"})
New({itemID=3026,name="Reinforced Bow",slot="Ranged",availableLevel=16,
    sourceType="Weapon vendor (Classic reference)",source="Bow merchants (Classic stock reference)",zone="Alliance weapon merchants",confidence="classic-reference",acquisitionConfidence="classic-reference",acquisitionKind="Vendor",
    instructions="Common level-16 vendor bow in Classic. Check merchant stock and live DPS in Forever; an item existing in the client does not independently prove vendor availability.",
    notes="Fallback bow if dungeon weapons are unavailable; Classic reference 7.5 DPS.",sourceURL="https://foreverdb.net/item/3026"})
New({itemID=3027,name="Heavy Recurve Bow",slot="Ranged",availableLevel=20,
    sourceType="Weapon vendor (Classic reference)",source="Weapon merchants (Classic stock reference)",zone="Alliance weapon merchants",confidence="classic-reference",acquisitionConfidence="classic-reference",acquisitionKind="Vendor",
    instructions="Level-20 common bow from classic merchant lists; beta merchant stock and live DPS have NOT been independently checked. Use only after comparing with your current weapon.",
    notes="Vendor fallback, not a guaranteed improvement over Venomstrike.",sourceURL="https://foreverdb.net/item/3027"})

-- Current Forever item stats are documented, but the old Jargba/RFK drop
-- attribution comes only from Classic data, not a live Forever loot test.
New({itemID=2816,name="Death Speaker Scepter",slot="Main Hand",availableLevel=28,
    sourceType="Dungeon drop (Classic-only source)",
    source="Death Speaker Jargba, Razorfen Kraul (Classic loot table only)",
    zone="Razorfen Kraul (unconfirmed Forever loot)",
    confidence="client",acquisitionKind="Dungeon boss drop",acquisitionConfidence="classic-reference",
    instructions="Powerful healer one-hand mace, but Death Speaker Jargba as its source is derived from Classic loot tables only. Verify in-game that he drops it before farming Razorfen Kraul; do not treat an RFK map pin as proof of availability.",
    notes="Level-28 BoP main-hand mace with +68 Healing, +12 HP regeneration, and +28 Shadow damage in Forever. Weapon damage changed across beta datasets; compare live tooltip.",
    sourceURL="https://theforeverera.com/en/items/2816/"})

assert(GetGear:AddRecommendation("PRIEST", {itemID=2816, targetLevel=28,
    specs={"Holy", "Discipline"}, focus="Healing",
    notes="OPTIONAL +68 Healing mace. Razorfen Kraul / Death Speaker Jargba acquisition is inherited from Classic tables, not verified Forever loot."}), "Priest healer scepter")
