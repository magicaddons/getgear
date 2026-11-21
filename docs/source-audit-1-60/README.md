# GetGear 1–60 source and recipe audit (development only)

This is a **machine-assisted census**, not a claim that every drop or vendor route was personally verified in the live realm.
Generated UTC: 2026-11-08T12:36:05+00:00.

## Coverage
- Catalogue records checked: **7,707/7,707**; unique IDs: 7,707.
- Items with one or more outstanding flags: **6,514**.
- Crafting entries checked: **1,252**.
- Recipe material candidates requiring changes: **0** (missing: 0; conflicts: 0).
- Independent current-client recipe matches: **1,252**.
- Independent item-name catalogue matches: **6,991**.

## Nine-class eligibility checks
- PRIEST: 2,627 class-item objectives
- MAGE: 2,471 class-item objectives
- WARLOCK: 2,461 class-item objectives
- DRUID: 3,858 class-item objectives
- ROGUE: 3,639 class-item objectives
- HUNTER: 4,866 class-item objectives
- SHAMAN: 5,109 class-item objectives
- WARRIOR: 5,785 class-item objectives
- PALADIN: 5,525 class-item objectives

## Recipe acquisition categories
- trainer (AHledger reference): 1,086
- recipe item required; origin unresolved: 68
- vendor recipe: 48
- trainer (teaching unverified): 38
- dropped recipe (Forever-observed): 6
- initial profession: 4
- dropped recipe: 2

## Dungeon classifications
- not-dungeon: 7,130
- named client encounter (boss route unverified): 360
- dungeon; enemy unresolved: 132
- named dungeon enemy; boss/trash unresolved: 66
- named client boss encounter (Forever-observed item source): 17
- trash (reference): 2

## Outstanding issue counts
- acquisition_route_unverified: 6,389
- not_in_independent_catalogue_or_hidden: 716
- dungeon_enemy_or_role_unresolved: 198
- recipe_learning_source_unresolved: 68
- independent_name_disagreement: 33

## Interpretation and limitations
- Equipment existence and client encounter names are not proof that a named mob drops the item on the live server.
- A client dungeon encounter name identifies a recognised boss/encounter, not confirmation of that boss's item loot table.
- The Everloot recipe dataset is a separate 1.60.1.70790 client extract; MAF2414 is an older independent extract. Both are informative but neither proves live trainer/vendor/recipe-drop access.
- Material conflict records are retained for manual verification; no automatically inferred recipe learning skill or drop chance is promoted to verified.
- A record absent from an independent catalogue may be hidden, phased or unrevealed, not nonexistent.
- Source notes from nobody174 are reference leads, often explicitly labelled Classic data.
- All generated material Lua changes are **candidate-only**, not added to the addon load order.
- Automated tests validate Lua/code structure; actual overlay, crafting, boss drops and vendor availability require in-client confirmation.

## Files
- [Complete per-item audit](all_items.csv) (every item ID and class eligibility)
- [Direct-name dungeon classification corrections](dungeon_role_reconciliation.csv) (client encounters, no new drop claims)
- [Unresolved item queue](unresolved_items.csv)
- [Recipe evidence and material comparison](recipes.csv)
- [Candidate material corrections](material_candidates.json)
- [Candidate-only Lua reagent entries](material_candidates.lua)
- [Evidence provenance and failed lookups](provenance.json)

## Independent references and attribution
- [Everloot](https://github.com/Everloot/everloot) — client recipe and dungeon encounter extracts; game data © Blizzard.
- [MAF2414 WoW Forever professions research](https://github.com/MAF2414/wow-forever-talents) — older independent client recipe cross-check.
- [AHledger](https://ahledger.com/data) — newer Forever item catalog and observed-data methodology.
- [Road to Forever](https://github.com/nobody174/wow-forever) — independently documented item acquisition leads.
- [ForeverDB](https://foreverdb.net/developers) — additional acquisition research, its bulk API requires approval/key and was **not** queried.

## Unavailable sources at run time
- everloot_npc_sightings: `HTTP Error 429: Too Many Requests`
