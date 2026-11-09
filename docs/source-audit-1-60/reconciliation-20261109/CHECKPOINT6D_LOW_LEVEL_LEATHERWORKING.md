# Checkpoint 6D — 19 lower-level Leatherworking recipe books

9 November 2026. Baseline `d5f1e54c57f7676f601f85fb3f317df86d6f78a6`.

## Exact publication research

All 19 Merchant’s Favor Leatherworking leads for gear requiring level 12–25 were fetched by exact book ID using both Wowhead Forever XML and item-page JSON tables. Assertions match each book name, taught craft spell, created equipment ID and profession. All 19 list Pawani (NPC 248201, zone 17) and Daniel Stitchsong (NPC 256734, zone 44), each at 30 Merchant’s Favor (currency 3402). Tooltip learning skills span 60–125. No new equipment/recipe material/gating facts are inferred from vendor stock tables.

Independent destination/inventory references: [Daniel Stitchsong at Three Corners, Redridge Mountains](https://www.wow-professions.com/forever/npc/daniel-stitchsong), [Pawani near Crossroads, The Barrens](https://azeroth.wiki/forever/map/the-barrens/pawani). Blank reputation fields do not establish gate absence. All descriptions explicitly retain live stock/gates unverified.

[Case register with SHA256 of all 38 fetched XML/HTML responses](checkpoint6d_recipe_evidence.csv).

| Gear ID | Gear | Book page | Craft spell | Book learning skill |
|---:|---|---|---:|---:|
| 252428 | Brawler's Leather Belt | [252765](https://www.wowhead.com/forever/item=252765/pattern-brawlers-leather-belt) | 1255142 | 60 |
| 252429 | Trapper's Leather Belt | [252766](https://www.wowhead.com/forever/item=252766/pattern-trappers-leather-belt) | 1255141 | 60 |
| 252430 | Defender's Leather Belt | [252767](https://www.wowhead.com/forever/item=252767/pattern-defenders-leather-belt) | 1255140 | 60 |
| 252431 | Totemic Leather Belt | [252768](https://www.wowhead.com/forever/item=252768/pattern-totemic-leather-belt) | 1255139 | 60 |
| 252432 | Stormrider's Leather Belt | [252769](https://www.wowhead.com/forever/item=252769/pattern-stormriders-leather-belt) | 1255138 | 60 |
| 252433 | Wisdom's Leather Belt | [252770](https://www.wowhead.com/forever/item=252770/pattern-wisdoms-leather-belt) | 1255137 | 60 |
| 252497 | Totemic Leather Gloves | [252780](https://www.wowhead.com/forever/item=252780/pattern-totemic-leather-gloves) | 1255127 | 75 |
| 252499 | Wisdom's Leather Gloves | [252782](https://www.wowhead.com/forever/item=252782/pattern-wisdoms-leather-gloves) | 1255125 | 75 |
| 252440 | Trapper's Leather Boots | [252787](https://www.wowhead.com/forever/item=252787/pattern-trappers-leather-boots) | 1255120 | 85 |
| 252442 | Totemic Leather Boots | [252789](https://www.wowhead.com/forever/item=252789/pattern-totemic-leather-boots) | 1255118 | 85 |
| 252444 | Wisdom's Leather Boots | [252791](https://www.wowhead.com/forever/item=252791/pattern-wisdoms-leather-boots) | 1255116 | 85 |
| 252505 | Trapper's Leather Hood | [252799](https://www.wowhead.com/forever/item=252799/pattern-trappers-leather-hood) | 1255108 | 100 |
| 252447 | Defender's Leather Hood | [252800](https://www.wowhead.com/forever/item=252800/pattern-defenders-leather-hood) | 1255107 | 100 |
| 252506 | Stormrider's Leather Hood | [252802](https://www.wowhead.com/forever/item=252802/pattern-stormriders-leather-hood) | 1255105 | 100 |
| 252451 | Totemic Leather Tunic | [252808](https://www.wowhead.com/forever/item=252808/pattern-totemic-leather-tunic) | 1255099 | 110 |
| 252516 | Brawler's Leather Legguards | [252820](https://www.wowhead.com/forever/item=252820/pattern-brawlers-leather-legguards) | 1255087 | 125 |
| 252517 | Trapper's Leather Legguards | [252821](https://www.wowhead.com/forever/item=252821/pattern-trappers-leather-legguards) | 1255086 | 125 |
| 252458 | Totemic Leather Leggings | [252823](https://www.wowhead.com/forever/item=252823/pattern-totemic-leather-leggings) | 1255084 | 125 |
| 252518 | Stormrider's Leather Kilt | [252824](https://www.wowhead.com/forever/item=252824/pattern-stormriders-leather-kilt) | 1255083 | 125 |

## Alternate book routes preserved

Nine exact books also have item-specific published dropped-by tables: 252780, 252782, 252799, 252800, 252802, 252820, 252821, 252823 and 252824. [All 94 book→NPC→zone reference edges](checkpoint6d_book_drop_references.csv) are retained by exact book ID. These are published Forever item-table leads, not this session’s live observations or guarantees; no percentages/count-based rates were imported. NPC ranks were not used to infer boss/trash roles. Classic NPC/zone identities alone are not the supporting loot evidence.

The overlay names the alternative dungeons. The detailed guide gives every published named enemy grouped by dungeon, with an explicit live-unverified/no-rate caveat. The vendor route is retained alongside drops, not replaced by source-priority order. This is recipe-book acquisition, never a claim that the finished craft drops from these enemies.

Two item-specific comments add weaker information: book 252780 comment 6438030 suggests a Deadmines drop but the writer is unsure of the enemy; it does not identify which other Blacksmithing pattern reportedly dropped from Mr. Smite. Book 252799 comment 6439055 reports Lord Cobrahn in Wailing Caverns, separately from its published table’s enemies. Both remain player-report/unverified, with no verified build/realm/date from the retrieved text. An unrelated stats-opinion comment is not acquisition evidence.

## Integration and validation

Optional detailed research text travels from the reviewed register through the evidence index to the existing detailed-guide formatter. Source summaries remain compact; new exact book/NPC reference fields are separate from original acquisition confidence. Existing source text, instructions, stats, ingredients, class eligibility and equip/crafting gates are unchanged. No navigation coordinates, drop rates or new settings were added.

**Local PASS:** Python compilation, full online reconciliation, all three required files, syntax for all 24 Lua modules and 14/14 regression tests. CSV row-by-row review confirms unchanged identities, levels, roles, original evidence and recipe/material classifications; only 19 additive summaries changed. Whitespace check passed with CSV CRLF recognised. Index 1,123 → 1,142 summaries, additive book IDs 114 → 133. **GitHub PENDING.** Tests include 19 exact book/vendor/skill assertions, alternative-route guide visibility, original crafted classification and negative protection against copying a glove’s drop references to a belt. Full-catalogue deep preservation and all prior safeguards remain in the 14-test suite.

Cumulative publication review: 65/188 Favor leads; 123 remain. All six dungeon and 954 book live-verification routes remain queued. Next: three lower-level Enchanting books plus three Engineering schematics. No ZIP/package/build, release, tag, merge or main change. Real-client layout and live acquisition acceptance remain outstanding.
