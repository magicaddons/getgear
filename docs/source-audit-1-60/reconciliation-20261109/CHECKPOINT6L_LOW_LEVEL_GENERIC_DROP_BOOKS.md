# Checkpoint 6L — 54 lower-level generic-drop recipe books

9 November 2026; baseline `9bc7fb25a6225b066f086e6e251035e8842e07b9` after complete Nightclaw validation.

## Exact evidence and in-addon directions

Researched all 54 gear-level-1–30 entries in the generic-drop cohort: 23 Blacksmithing, 16 Leatherworking, 14 Tailoring, one Engineering. All exact Forever XML/item pages match the independent book name, crafting spell and created-equipment mapping. No unavailable-item flag or named vendor alternative appears on these pages.

- [54 exact cases, learning skills, source hashes and scope](checkpoint6l_recipe_evidence.csv).
- [8,183 exact book/NPC/location references](checkpoint6l_book_drop_references.csv), from 7,480 retrieved NPC rows. Multi-location NPCs produce multiple relationships; these counts are references, not kills or independent observations.
- [64 book/container relationships](checkpoint6l_container_references.csv), spanning eight container identities. Contents and opening/access requirements remain live-unverified; no guaranteed reward is claimed.
- [49 independently fetched zone identities and 17 sparse-source NPC pages/maps](checkpoint6l_location_evidence.json), with traceable URLs and hashes. Negative source location IDs remain unresolved categories; no dungeon or continent name is guessed.

The overlay identifies the exact book/skill and either its narrow named source leads or examples of zones in the broad table. The full guide includes every retrieved NPC name grouped by the table's zone, plus container alternatives. NPC-page map footprints are supplied for narrow outdoor leads, explicitly as ranges rather than invented central waypoints or current sightings.

**23 tables contain exactly 200 NPC rows and may be truncated.** Every such guide entry says so. Other tables are also explicitly non-exhaustive publication references. No page proves an exclusive source, current drop rate, fastest farm or complete inventory. These references can retain inherited historical loot, even on a Forever page. Mob level, NPC rank, percentage and collection counts are not promoted into current loot or eligibility facts. All new summaries remain live-unverified; no finished crafted equipment becomes an enemy drop.

## Narrow cases worth retaining individually

| Exact book | Gear | Published named source and location |
|---:|---|---|
| [251335](https://www.wowhead.com/forever/item=251335) | Sterling Silver Boots | Syndicate Watchman — Hillsbrad Foothills |
| [251336](https://www.wowhead.com/forever/item=251336) | Sterling Silver Leggings | Skeletal Warrior — Duskwood |
| [251337](https://www.wowhead.com/forever/item=251337) | Sterling Silver Gauntlet | Wrathtail Myrmidon — Ashenvale |
| [251338](https://www.wowhead.com/forever/item=251338) | Sterling Silver Shoulders | Shadowhide Gnoll — Redridge Mountains |
| [251339](https://www.wowhead.com/forever/item=251339) | Sterling Silver Breastplate | Grimtotem Bandit — Thousand Needles |
| [251385](https://www.wowhead.com/forever/item=251385) | Hard Gold Cuirass | Screeching Roguefeather — Thousand Needles |
| [251386](https://www.wowhead.com/forever/item=251386) | Hard Gold Boots | Syndicate Highwayman — Arathi Highlands |
| [251454](https://www.wowhead.com/forever/item=251454) | Brass Knuckles | Gogger Rock Keeper — Stonetalon Mountains |
| [251455](https://www.wowhead.com/forever/item=251455) | Bronze Dory | Dark Strand Enforcer — Ashenvale |
| [251456](https://www.wowhead.com/forever/item=251456) | Iron Fists | Bleakheart Hellcaller — Ashenvale |
| [252804](https://www.wowhead.com/forever/item=252804) | Hillman's Leather Boots | Shadowhorn Stag — Ashenvale |
| [5773](https://www.wowhead.com/forever/item=5773) | Robes of Arcana | Defias Enchanter — Duskwood; Dark Strand Voidcaller — Darkshore |
| [253946](https://www.wowhead.com/forever/item=253946) | Filigreed Pearly Leggings | Edwin VanCleef — Deadmines; Shadow Charger — Shadowfang Keep; Lady Sarevess and Ghamoo-ra — Blackfathom Deeps |

These individual references are not propagated across recipes. “One NPC row” means one retrieved reference, not that the enemy is the only possible source. The Pearly Leggings page improves a generic-drop triage label to four named dungeon-book leads without changing the finished gear's crafted status or the independent dungeon cohort counts.

## Validation and generated-change inspection

**Local full validation PASS; GitHub PENDING.** Python compilation and full online reconciliation; three required files; all 24 Lua module syntax checks; 14/14 regressions. Source index 1,266 → 1,320 summaries. Runtime additive book IDs 253 → 305: 52 newly filled IDs; Red Linen Robe 2572/book2598 and Red Linen Vest 6239/book6271 already had correct IDs, which remain unchanged. Reviewed registry 189 → 243 cases. Complete structured relationships live in the permanent CSV to avoid duplicating thousands of rows inside the runtime-generator registry; all names/directions remain in guide details.

Decoded every changed generated CSV relationship field and removed only source-row offsets for comparison: the only semantic CSV changes are 54 additive summaries. Catalogue identities/order, original routes/confidence, requiresLiveCheck, roles, recipe statuses and ingredients remain unchanged. Index changes are the 54 new reviewed book records. Full catalogue/eligibility/settings/filter/material invariants and all prior tests pass; new tests cover exact IDs, truncation, narrow NPC alternatives, no copied source family, no loot percentages and no finished-gear drop claim.

Generic-drop cohort 54/221 researched, 167 higher-level remain. Lower-level reviewed register now 243 cases across all source groups except 23 no-alternative entries, which are next. Six unresolved finished-gear dungeon links and 954 book live-verification routes remain open. No build/package, ZIP, release, tag, merge or main changes.
