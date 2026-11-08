# GetGear source audit: actionable unresolved queues

Generated from the complete [7,707-item census](all_items.csv). This report is an offline index and does not change any source verdict.

- [Every dungeon-associated item; named client bosses are not necessarily confirmed loot sources](dungeon_sources.csv) — **577** entries
- [Dungeon entries lacking a reliable boss/trash or enemy assignment](dungeon_sources_unresolved.csv) — **198** entries
- [Recipes with an unknown trainer/vendor/drop/quest learning route](recipe_learning_unresolved.csv) — **68** entries
- [Name disagreements against the newer independent client catalogue; verify localisation and phase](independent_name_disagreements.csv) — **33** entries
- [IDs not found in the newer item source; absence alone cannot establish removal](independent_catalogue_unmatched.csv) — **716** entries
- [Items with published Everloot observations linking the item ID to a dropped-by NPC; names can be absent](observed_item_drop_records.csv) — **106** entries

## Evidence boundary

A source labelled *trainer (AHledger reference)* is a catalogue classification, **not** direct confirmation that a Forever trainer sells it. Treat these as verification leads.

A dungeon encounter name is client metadata; whether that enemy actually drops the item is a separate, server-side fact. Do not promote it without live observation.

Recipe reagents have been cross-checked against a second client extract; **0** ingredient changes were identified. Recipe learning and actual availability remain separate questions.

Observed Everloot evidence is attributed to [Everloot](https://everloot.app) under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).
