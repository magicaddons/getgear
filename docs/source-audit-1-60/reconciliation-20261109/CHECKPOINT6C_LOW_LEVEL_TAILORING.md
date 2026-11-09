# Checkpoint 6C — 36 lower-level Tailoring recipe books

9 November 2026. Starting development HEAD: `70e61d52ec2faef6b406b98fb0b64f7f2798b33d`.

## Result and source method

All 36 Merchant’s Favor Tailoring leads for gear requiring level 12–25 were researched by exact book ID. For each book, fetched both its Wowhead Forever XML tooltip and complete item page, parsed the JSON `teaches-recipe` and `sold-by` tables, and asserted book name, crafted item ID, craft spell ID and profession. No name-only or adjacent-ID joins. Each of the 36 pages lists Mivin Shadowweave (NPC 256735, zone 44 / Redridge Mountains) and Jim’bek (NPC 248202, zone 17 / The Barrens), each at 30 units of currency 3402 (Merchant’s Favor). These are published table references, not current live-stock observations. The book learning skill comes from the exact tooltip’s reqskillrank, not the crafting yellow threshold.

Independent settlement/location references: [Mivin inventory and Three Corners](https://www.wow-professions.com/forever/npc/mivin-shadowweave), [Jim’bek inventory near Crossroads](https://azeroth.wiki/forever/map/the-barrens/jim-bek). No new coordinates/pins were inferred. Blank reputation fields are not evidence that a gate is absent. All summaries retain live stock/gates unverified. No dropped-by, quest-reward or container tables, or player comments, were returned on these 36 fetched pages; this does not prove that alternate routes do not exist.

[Machine-readable case evidence](checkpoint6c_recipe_evidence.csv) records all 36 IDs, names, original gear levels, exact craft spell/book-learning skill, vendor NPC IDs, direct source URL and SHA256 of each XML/HTML response. The runtime-reviewed register also retains per-vendor published costs and source hashes. No third-party page prose was copied into addon instructions.

## Exact cases

| Gear ID | Gear | Book tooltip | Spell ID | Book skill |
|---:|---|---|---:|---:|
| 253889 | Pristine Boots | [253890](https://www.wowhead.com/forever/item=253890/pattern-pristine-boots) | 1257370 | 60 |
| 253891 | Silky Boots | [253892](https://www.wowhead.com/forever/item=253892/pattern-silky-boots) | 1257371 | 60 |
| 253893 | Flame Boots | [253894](https://www.wowhead.com/forever/item=253894/pattern-flame-boots) | 1257372 | 60 |
| 253895 | Shadow Boots | [253896](https://www.wowhead.com/forever/item=253896/pattern-shadow-boots) | 1257373 | 60 |
| 253897 | Pearly Boots | [253898](https://www.wowhead.com/forever/item=253898/pattern-pearly-boots) | 1257374 | 60 |
| 253899 | Shining Boots | [253900](https://www.wowhead.com/forever/item=253900/pattern-shining-boots) | 1257375 | 60 |
| 253913 | Pristine Gloves | [253914](https://www.wowhead.com/forever/item=253914/pattern-pristine-gloves) | 1257382 | 75 |
| 253915 | Silky Gloves | [253916](https://www.wowhead.com/forever/item=253916/pattern-silky-gloves) | 1257383 | 75 |
| 253917 | Flame Gloves | [253918](https://www.wowhead.com/forever/item=253918/pattern-flame-gloves) | 1257384 | 75 |
| 253919 | Shadow Gloves | [253920](https://www.wowhead.com/forever/item=253920/pattern-shadow-gloves) | 1257385 | 75 |
| 253921 | Pearly Gloves | [253922](https://www.wowhead.com/forever/item=253922/pattern-pearly-gloves) | 1257386 | 75 |
| 253923 | Shining Gloves | [253924](https://www.wowhead.com/forever/item=253924/pattern-shining-gloves) | 1257387 | 75 |
| 253925 | Pristine Sash | [253926](https://www.wowhead.com/forever/item=253926/pattern-pristine-sash) | 1257388 | 85 |
| 253927 | Silky Sash | [253928](https://www.wowhead.com/forever/item=253928/pattern-silky-sash) | 1257389 | 85 |
| 253929 | Flame Sash | [253930](https://www.wowhead.com/forever/item=253930/pattern-flame-sash) | 1257390 | 85 |
| 253931 | Shadow Sash | [253932](https://www.wowhead.com/forever/item=253932/pattern-shadow-sash) | 1257391 | 85 |
| 253933 | Pearly Sash | [253934](https://www.wowhead.com/forever/item=253934/pattern-pearly-sash) | 1257392 | 85 |
| 253935 | Shining Sash | [253936](https://www.wowhead.com/forever/item=253936/pattern-shining-sash) | 1257393 | 85 |
| 253949 | Pristine Circlet | [253950](https://www.wowhead.com/forever/item=253950/pattern-pristine-circlet) | 1257400 | 100 |
| 253951 | Silky Circlet | [253952](https://www.wowhead.com/forever/item=253952/pattern-silky-circlet) | 1257401 | 100 |
| 253953 | Flame Circlet | [253954](https://www.wowhead.com/forever/item=253954/pattern-flame-circlet) | 1257402 | 100 |
| 253955 | Shadow Circlet | [253956](https://www.wowhead.com/forever/item=253956/pattern-shadow-circlet) | 1257403 | 100 |
| 253957 | Pearly Circlet | [253958](https://www.wowhead.com/forever/item=253958/pattern-pearly-circlet) | 1257404 | 100 |
| 253959 | Shining Circlet | [253960](https://www.wowhead.com/forever/item=253960/pattern-shining-circlet) | 1257405 | 100 |
| 253961 | Pristine Gown | [253962](https://www.wowhead.com/forever/item=253962/pattern-pristine-gown) | 1257406 | 110 |
| 253963 | Silky Gown | [253964](https://www.wowhead.com/forever/item=253964/pattern-silky-gown) | 1257407 | 110 |
| 253965 | Flame Gown | [253966](https://www.wowhead.com/forever/item=253966/pattern-flame-gown) | 1257408 | 110 |
| 253967 | Shadow Gown | [253968](https://www.wowhead.com/forever/item=253968/pattern-shadow-gown) | 1257409 | 110 |
| 253969 | Pearly Gown | [253970](https://www.wowhead.com/forever/item=253970/pattern-pearly-gown) | 1257410 | 110 |
| 253971 | Shining Gown | [253972](https://www.wowhead.com/forever/item=253972/pattern-shining-gown) | 1257411 | 110 |
| 253987 | Pristine Leggings | [253988](https://www.wowhead.com/forever/item=253988/pattern-pristine-leggings) | 1257419 | 125 |
| 253989 | Silky Leggings | [253990](https://www.wowhead.com/forever/item=253990/pattern-silky-leggings) | 1257420 | 125 |
| 253991 | Flame Leggings | [253992](https://www.wowhead.com/forever/item=253992/pattern-flame-leggings) | 1257421 | 125 |
| 253993 | Shadow Leggings | [253994](https://www.wowhead.com/forever/item=253994/pattern-shadow-leggings) | 1257422 | 125 |
| 253995 | Pearly Leggings | [253996](https://www.wowhead.com/forever/item=253996/pattern-pearly-leggings) | 1257423 | 125 |
| 253997 | Shining Leggings | [253998](https://www.wowhead.com/forever/item=253998/pattern-shining-leggings) | 1257424 | 125 |

## Integration and safeguards

All 36 gain exact book IDs and qualified, named directions for both factions in the overlay and detailed guide. Existing manually reviewed source/instruction text, source confidence, material quantities, stats, class masks, recipe/equip gates, saved settings and filters are retained. Learning skill is reference text and does not rewrite a crafting gate. Twenty-nine already had stronger publication-level manual instructions but lacked an evidence summary/book ID; these are supplemented instead of discarded. Seven previously lacked those directions. Recorded/reported observations and existing manual summaries retain precedence.

The first targeted regression correctly caught that the old generator excluded 29 manually documented publication-level recipes. Its guard now permits additive reference metadata alongside those instructions, while still excluding recorded/reported observation records. A new deep structural regression compares all pre-existing fields (including nested ingredients/stats) across all 7,707 items immediately before/after evidence application, allowing only documented additive summary/book metadata. Thirty-six exact book/source assertions check both faction names, skills, price, caveat and detailed-guide visibility. No CI was launched on the intermediate failed local test.

## Validation and counts

**Local PASS:** Python compilation/full online reconciliation, 3/3 required files, all 24 Lua modules, 14/14 regressions (including all 36 cases and full-catalogue deep preservation check). Generated CSV review retained IDs, names, levels, source roles/classifications/materials/gates; only 36 additive summaries changed. Index 1,087 → 1,123 summaries, additive book IDs 78 → 114. Whitespace check passed with existing CSV CRLF recognised. **GitHub PENDING.** Only the non-release reconciliation workflow is authorised.

Expected cumulative review: 46/188 Favor leads (10 Blacksmithing + 36 Tailoring), 142 remain. All 954 recipe-book live-verification routes and six dungeon leads remain open; publication research is not live confirmation. Catalogue stays 7,707 items / 36,341 class objectives, 1,252 indexed recipes. No package, ZIP, tag, release, merge or main change. Next: all 19 lower-level Leatherworking Favor leads, then the six lower-level Enchanting/Engineering leads.
