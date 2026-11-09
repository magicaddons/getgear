# Checkpoint 6J — 17 lower-level Tailoring dungeon-source books

9 November 2026; baseline `4850a73` after lower-level vendor closeout.

## Exact book research

Fetched all 17 exact Wowhead Forever book XML/item pages. Each book name, taught craft spell and created equipment ID matches the repository’s independent book/spell/gear mapping. Direct tooltip learning skill is 75 for gowns, 100 for leggings, 125 for circlets. Every exact page supplies a dropped-by table; none supplies a named vendor alternative. No family-wide source rule is inferred from these individual tables.

[17 book identities and source response hashes](checkpoint6j_recipe_evidence.csv); [all 213 exact book→NPC→zone publication references](checkpoint6j_book_drop_references.csv). Only identity/name/zone relationships are retained, not kill counts, percentages, popularity, NPC rank or a guaranteed current live rate.

| Crafted ID | Gear | Exact book page | Craft spell | Book learning skill | Published NPC references |
|---:|---|---|---:|---:|---:|
| 253901 | Filigreed Pristine Gown | [253902](https://www.wowhead.com/forever/item=253902) | 1257376 | 75 | 13 |
| 253903 | Filigreed Silky Gown | [253904](https://www.wowhead.com/forever/item=253904) | 1257377 | 75 | 13 |
| 253905 | Filigreed Flame Gown | [253906](https://www.wowhead.com/forever/item=253906) | 1257378 | 75 | 12 |
| 253907 | Filigreed Shadow Gown | [253908](https://www.wowhead.com/forever/item=253908) | 1257379 | 75 | 13 |
| 253909 | Filigreed Pearly Gown | [253910](https://www.wowhead.com/forever/item=253910) | 1257380 | 75 | 12 |
| 253911 | Filigreed Shining Gown | [253912](https://www.wowhead.com/forever/item=253912) | 1257381 | 75 | 13 |
| 253937 | Filigreed Pristine Leggings | [253938](https://www.wowhead.com/forever/item=253938) | 1257394 | 100 | 5 |
| 253939 | Filigreed Silky Leggings | [253940](https://www.wowhead.com/forever/item=253940) | 1257395 | 100 | 5 |
| 253941 | Filigreed Flame Leggings | [253942](https://www.wowhead.com/forever/item=253942) | 1257396 | 100 | 5 |
| 253943 | Filigreed Shadow Leggings | [253944](https://www.wowhead.com/forever/item=253944) | 1257397 | 100 | 4 |
| 253947 | Filigreed Shining Leggings | [253948](https://www.wowhead.com/forever/item=253948) | 1257399 | 100 | 5 |
| 253975 | Filigreed Pristine Circlet | [253976](https://www.wowhead.com/forever/item=253976) | 1257413 | 125 | 18 |
| 253977 | Filigreed Silky Circlet | [253978](https://www.wowhead.com/forever/item=253978) | 1257414 | 125 | 21 |
| 253979 | Filigreed Flame Circlet | [253980](https://www.wowhead.com/forever/item=253980) | 1257415 | 125 | 17 |
| 253981 | Filigreed Shadow Circlet | [253982](https://www.wowhead.com/forever/item=253982) | 1257416 | 125 | 18 |
| 253983 | Filigreed Pearly Circlet | [253984](https://www.wowhead.com/forever/item=253984) | 1257417 | 125 | 20 |
| 253985 | Filigreed Shining Circlet | [253986](https://www.wowhead.com/forever/item=253986) | 1257418 | 125 | 19 |

## Item-specific distinctions

- Book 253902 (Filigreed Pristine Gown) lists Kresh in Wailing Caverns; book 253904 (Filigreed Silky Gown) instead lists Lady Anacondra. Book 253906 (Filigreed Flame Gown) has no Wailing Caverns entry in this retrieved table. Do not copy a general “all gowns drop in WC” rule.
- Book 253908 (Filigreed Shadow Gown) lists Deviate Faerie Dragon in Wailing Caverns. Its named relationship is retained without asserting a spawn rate or using NPC rank as loot proof.
- Book 253978 (Filigreed Silky Circlet) lists Dark Iron Ambassador in Gnomeregan. That relationship is not copied to the Flame Circlet book 253980 or other superficially similar records.
- Scarlet Monastery references are kept at the source table’s zone granularity; no wing is guessed from a shared zone ID. No finished crafted item is reclassified as a boss drop.

Overlay summaries name the exact book, skill and published dungeon alternatives. Full-guide details list every source-table enemy under the correct dungeon, and explicitly distinguish book acquisition from finished gear. This makes the leads available inside the addon without claiming live proof. The source tables may retain historical data; only a dated traceable publication reference is established. No vendor/quest alternative is ruled out solely by its absence here.

## Validation and continuation

**Local PASS:** Python compilation/full online reconciliation, all three required files, all 24 Lua syntax checks and 14/14 regressions. Source index 1,201 → 1,218; runtime additive book IDs 188 → 205. Exact book/NPC exceptions and full-catalogue invariants pass. CSV identities/original source facts/roles/recipe-material classifications and gates retained; only 17 additive summaries changed. Whitespace check passed with existing CSV CRLF recognised. **GitHub PENDING.** Tests cover all 17 exact book IDs, source-confidence caveats, crafted identity/material preservation, the Kresh/Anacondra/no-WC negative cases, and Ambassador non-propagation. Full-catalogue pre-existing field invariants, settings/filters and every previous regression remain enforced.

Dungeon/book-drop cohort: 17/41 publication-researched, all 17 gear-level-1–30 entries; 24 higher-level remain. This does not close the separate six finished-equipment dungeon leads or any of the 954 live book verification routes. Current reviewed register has 141 cases (Favor 71 + quest/mixed 8 + non-Favor vendors 45 + dungeon books 17), including three unavailable-book conflicts. Next lower-level research: 48 reputation-only leads, 54 generic-drop and 23 no-alternate-source entries. No ZIP/build/package, release, tag, merge or main change.
