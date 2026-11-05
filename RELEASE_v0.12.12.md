# GetGear v0.12.12 Beta — early crafted gear progression

**World of Warcraft Forever · Alliance · levels 1–30 · nine class guides**

This beta addresses a gap discovered at launch: GetGear recommended later high-value crafted gear but omitted several inexpensive green upgrades obtainable much earlier. These items should appear in the current-level / next-five-level tracker **whether or not your character has trained the relevant profession**. Crafting ability affects recipe guidance, not whether equipment can be recommended.

## What's new

**9 new catalogue items and 22 new class/spec recommendations**, covering early equipment from four crafting professions:

- **Tailoring:** Red Linen Robe (2572), Red Linen Vest (6239), Blue Linen Vest (6240), Green Linen Bracers (4308). Added to appropriate Priest, Mage and Warlock builds.
- **Leatherworking:** Embossed Leather Gloves (4239), Embossed Leather Boots (2309), Fine Leather Gloves (2312). Added to appropriate Hunter, Rogue, Druid and Shaman profiles, separating caster-specific items from physical DPS.
- **Blacksmithing:** Copper Chain Belt (2851) added to Warrior and Paladin; existing Copper Chain Boots (3469) also added to Paladin without duplicating the original Warrior recommendation.
- **Engineering:** Rough Boomstick (4362) for early Hunter ranged damage. Requires gun proficiency and ammunition, not Engineering to equip.
- **Enchanting:** Existing early wand upgrades preserved; no additional comparable missing wand was identified.

### Example: Priest level 6

The new tracker should offer **Red Linen Robe (level 5)** under available items, with **Red Linen Vest, Blue Linen Vest and Green Linen Bracers (level 7)** under upcoming gear when the relevant Priest spec is selected. With **All specs**, both alternative vests appear for planning; choose an appropriate chest piece rather than obtaining both.

## Data quality and limitations

- Included reagent lists and distinguished **character equip level** from **profession skill needed to learn a recipe**.
- Unverified trainer-learning minima remain unknown rather than substituting recipe skill-up thresholds.
- Some new items use pattern learning and acquisition information from Forever-indexed data; exact live-server trainer or drop availability still needs in-game confirmation.
- Existing class guides, higher-level items, quest/dungeon acquisitions and account inventory behavior remain unchanged.
- **234 catalogued items, 426 gear recommendations, 37 spec/profile views.** No changes to SavedVariables keys or the sole slash command `/getgear`.

## Tests

- Lua 5.4 syntax/load regression across **33 addon Lua modules**.
- Item/recommendation counts, all nine class guides, all 37 specialization preview combinations, duplicate IDs, and level-6 Priest visibility.
- Physical-versus-caster recommendation exclusions for Hunter/Rogue.
- Known ingredient-ID corrections including Coarse Thread (**2320**) and Rough Boomstick parts.
- Freshly packaged ZIP file validation through GitHub Actions.

**In-game testing is still required** for the live Forever client's actual trainer availability, UI displays and recipe sources. This release is a beta, not a certification of every data record.

## Installation

Download **`GetGear-v0.12.12-private-test-beta.zip`** from **Assets** below (not GitHub's automatically generated source archive).

1. Exit WoW Forever.
2. Back up your existing `GetGear` folder and SavedVariables if desired.
3. Extract the ZIP so `_forever_/Interface/AddOns/GetGear/GetGear.toc` exists.
4. Start the game and enter `/getgear`.

The previous [v0.12.11 Beta](https://github.com/magicaddons/getgear/releases/tag/v0.12.11) remains available as a fallback.

Report unexpected gear, missing recipes or material errors through [GitHub Issues](https://github.com/magicaddons/getgear/issues) with class, spec, level, item ID and a tooltip screenshot where possible.
