# Checkpoint 6E — six lower-level Enchanting and Engineering books

9 November 2026. Baseline `c9157ca` (Leatherworking checkpoint closeout).

## Exact publication research

Fetched both Wowhead Forever XML and full item pages for all six remaining Merchant’s Favor book leads whose crafted equipment requires level 30 or below. Matched exact book name, craft spell, created item and profession before integration; no adjacent-ID inference. Item-page sold-by tables independently identify each vendor and its currency cost. XML/page SHA256 and full identity mappings are recorded in [Enchanting cases](checkpoint6e-enchanting_recipe_evidence.csv) and [Engineering cases](checkpoint6e-engineering_recipe_evidence.csv).

| Gear ID | Gear | Book page | Spell | Book skill | Favor cost |
|---:|---|---|---:|---:|---:|
| 249392 | Glimmering Staff | [249482](https://www.wowhead.com/forever/item=249482/formula-glimmering-staff) | 1248703 | 140 | 45 |
| 249393 | Soulstaff | [249483](https://www.wowhead.com/forever/item=249483/formula-soulstaff) | 1248739 | 140 | 45 |
| 249394 | Orb of Mystic Insight | [249484](https://www.wowhead.com/forever/item=249484/formula-orb-of-mystic-insight) | 1248745 | 140 | 45 |
| 280306 | Whimsical Waistwrap | [280321](https://www.wowhead.com/forever/item=280321/schematic-whimsical-waistwrap) | 1308178 | 175 | 180 |
| 280307 | Gizmo Girdle | [280322](https://www.wowhead.com/forever/item=280322/schematic-gizmo-girdle) | 1308179 | 175 | 180 |
| 280308 | Clanking Cord | [280323](https://www.wowhead.com/forever/item=280323/schematic-clanking-cord) | 1308180 | 175 | 180 |

- Enchanting: Alynsia (NPC 256732, Redridge Mountains zone 44) and Beneris (NPC 248199, The Barrens zone 17), 45 Merchant’s Favor each, Enchanting 140 book learning skill. [Alynsia’s inventory and Three Corners destination](https://www.wow-professions.com/forever/npc/alynsia); [Beneris near Crossroads](https://azeroth.wiki/forever/map/the-barrens/beneris).
- Engineering: Fritz Fizzle (NPC 256733, zone 44) and Fizzlefuse (NPC 248200, zone 17), 180 Merchant’s Favor each, Engineering 175. [Fritz inventory](https://www.wow-professions.com/forever/npc/fritz-fizzle); [Fizzlefuse destination](https://azeroth.wiki/forever/map/the-barrens/fizzlefuse). Settlements are Three Corners and the camp near Crossroads.
- All six exact pages returned no alternate drop/quest/container table or comments. That is absence of evidence on these pages, not proof of exclusive vendor availability or lack of trainer teaching.

## Item-specific reputation caveat

Each of schematics 280321–280323 explicitly says Friendly is required, but names only an unspecified faction in its tooltip. Fritz Fizzle’s exact schematic inventory rows identify **Azeroth Commerce Authority, Friendly**. Added that published Alliance requirement to each in-addon summary and full-guide explanation; did not infer the Horde faction requirement solely from the same schematic or a profession-wide rule. Horde gate remains explicitly unverified. No reputation requirement is copied onto Enchanting’s three formulas, whose exact tooltip has no such line. Live stock, price and eligibility remain reference-level claims.

## Integration and validation

Added book IDs, profession-specific learning skills/costs, named sellers and settlement/zone directions to overlay and detailed guide through the existing reviewed evidence register. Existing item identities, recipes/ingredients, class/spec rules, equip/crafting gates, settings and filters are preserved. Targeted regression checks prevent 30-Favor prices or Engineering’s Friendly gate from spreading to unrelated books, and verify the unresolved Horde gate remains visible.

**Local PASS:** Python compilation and full online reconciliation, three generated-file checks, all 24 module syntax checks and all 14 regression tests. Exact engineering reputation/cost and Enchanting negative cases pass; full-catalogue deep preservation check passes. CSV review retained identities, levels, roles, original source evidence and recipe/material classifications; only six additive summaries changed. Index 1,142 → 1,148 summaries; additive book IDs 133 → 139. Whitespace check passed with existing CSV CRLF recognised. **GitHub PASS:** [Non-release CI 42552352278](https://github.com/magicaddons/getgear/actions/runs/42552352278) PASS, including reconciliation, three required files, 24 module syntax checks, 14 regressions, artifact upload and report save. Source commit `c1ebc0e63e2713afbdb65eb583855dcf956f47ab`; verified bot final HEAD `d1ef8c524b9239f85b231d469762c7a1a2d07b14`. Full logs verified; bot diff only changes provenance timestamp and three response hashes, not evidence or index.

Cumulative: **71/188 Favor leads** reviewed and integrated, **117 remain** (all crafted gear level above 30 in the original cohort). This completes the session’s planned lower-level Favor cohorts: 10 prior Blacksmithing, plus 36 Tailoring, 19 Leatherworking, 3 Enchanting and 3 Engineering. It does not complete all lower-level acquisition research: quest, non-Favor vendor, generic-drop and unknown-route groups still remain. Six dungeon and 954 book live-verification routes stay open. No live-stock purchase/trainer confirmation or release/build/package/tag/merge/main action.
