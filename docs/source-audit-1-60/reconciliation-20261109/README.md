# GetGear acquisition-source reconciliation — 1–60

This is a comprehensive **evidence reconciliation**; it does not assert that all acquisition sources are confirmed in a live Forever realm.

## Catalogue and recipes
- All **7,707 / 7,707** equipment records examined.
- All **1,252 / 1,252** crafting recipes examined.
- All **577 / 577** historically dungeon-associated records examined, including **24** crafted items with possible dungeon pattern routes and **1** item incorrectly catalogued as dungeon loot.
- New, conservative in-addon acquisition summaries generated: **1,343**.
- Combined Forever cache entries: **10,315**; Playfulls item entries: **23,096**.
- Published player-observed relationships: **956**.
- True dungeon-equipment records: **552**; still requiring encounter or container-loot confirmation: **6**.
- Recipe book origins that still require live verification: **954** (68 named vendor references; 886 trainer-labelled recipes with separate pattern-book IDs).
- Item ID name mismatches against Forever cache: **0**.
- Nine Scarlet Monastery Graveyard rare-boss loot references are attributed to the Forever Dungeon Journal, with no live drop-rate claims.
- Two named dungeon trash equipment sources (Vicar's Robe and Rift Bracers) are now labelled from published Forever loot references; no live drop rates.
- Checkpoint 4 identifies **14** more encounter roles from Forever-published guides, journal and beta references; none establishes live drop rates.
- **2** Dark/Relic Coffer leads are containers, not enemies, and remain unresolved because Forever item-to-coffer loot is unverified.

## Dungeon source classifications (reference quality, not drop-rate proof)
- boss: 397
- trash: 137
- crafted-pattern: 24
- rare-boss: 12
- dungeon-enemy: 4
- container-lead: 2
- crafted-item: 1

## Dungeon evidence confidence
- forever-community-reference: 484
- forever-reference-unverified: 26
- recipe-origin-unverified: 24
- forever-observed-npc: 15
- published-forever-dungeon-journal: 10
- published-forever-dungeon-guide: 10
- published-forever-trash-reference: 2
- historic-container-reference: 2
- forever-encounter-historic-loot-reference: 1
- forever-item-historic-loot-reference: 1
- published-forever-beta-class-guide: 1
- published-forever-recipe: 1

## Recipe learning (do not conflate *crafting* and *learning*)
- trainer-reference-with-pattern-item: 886
- trainer-reference: 238
- vendor-reference: 68
- manual-researched: 50
- forever-observed: 6
- initial: 4

## Critical policy
- *Forever observed* means at least three Everloot installations independently recorded the item-to-NPC edge, and a published dungeon listing linked that NPC to this specific dungeon. These observations may still be incomplete.
- *Forever community reference* is a loot-list claim checked against client item IDs; it is **not** evidence of a live drop chance.
- *Published Forever trash reference* names a specific equipment item and trash NPC in a Forever zone/item listing, but is **not** a live drop observation.
- *Classic reference* is used only as an explicitly uncertain farming lead.
- Encounter names in the client identify NPCs, not their loot tables.
- An unobserved recipe book is not evidence that a trainer teaches it or that a live vendor currently offers it.
- The 68 new level-60 book items have a published *Aisarra Nightmeadow* (Mount Hyjal) vendor lead, **not** live confirmed stock.
- Example Forever plan tooltips independently identify requirements beyond the vendor: Grovekeeper Leggings requires Friendly status and the Friendly Advice quest; Grovekeeper Mantle requires reputation progress and shoulder specialization. Other books may have their own reputation or specialization gates.
- A trainer-labelled recipe with a pattern item is marked for a teaching-method check; the two routes could both exist and should not be called contradictory without server evidence.
- Non-dungeon vendor/quest details only supplement imported generic vendor/quest entries and are explicitly labelled reference-only.
- Original 1,252 indexed crafting ingredient lists are **untouched**; one additional client-confirmed craft is corrected in SourceEnrichment.lua.
- Higher-confidence manually reviewed source text and item-ID exceptions take priority over this generated evidence.
- The index does not alter class eligibility, player status, equipment quality, recipe availability gates, or the two overlay filters.

## Audit files
- [All equipment records](all_items_reconciled.csv) — one row per item, including raw published source relationships and observation records.
- [All historically dungeon-associated records](dungeon_items_reconciled.csv), including separately classified crafted-pattern and misclassified crafted-item entries.
- [Actual dungeon equipment drops](dungeon_equipment_drops.csv) — boss, trash, enemy, confidence and observed sources.
- [Unresolved dungeon sources](dungeon_source_followups.csv).
- [Recipe acquisition and pattern book reconciliation](recipes_reconciled.csv).
- [Unresolved recipe sources](recipe_source_followups.csv).
- [68 named-vendor pattern-book verification leads](recipe_vendor_book_checks.csv).
- [Recipes with both trainer-classified references and pattern books](recipe_trainer_book_checks.csv).
- [Optional in-game verification](OPTIONAL_IN_GAME_CHECKS.md).
- [Source versions, hashes, attribution and limitations](provenance.json).

## Sources and licence notes
- [Playfulls](https://playfulls.com/database), [methodology](https://playfulls.com/methodology) — client + community loot sources (no live drop rates).
- [Everloot](https://everloot.app) — player-observed edges; [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) attribution and share-alike on derived Everloot observations.
- [Forever item cache](https://github.com/Napalmsteak/WoW-Classic-Item-Caches) — published Forever-specific tooltips and source references.
- [WoW Forever Friends](https://www.wowforeverfriends.org/library/sources/) — Classic baseline NPC/item lookup explicitly labelled unverified for Forever.
- [WoWhead Grovekeeper Leggings pattern](https://www.wowhead.com/forever/item=273964) and [Grovekeeper Mantle pattern](https://www.wowhead.com/forever/item=273958) — published plan tooltips with class/reputation/quest specialization requirements.
- [AHledger](https://ahledger.com) — supplemental recipe acquisition reference.
- [WoWhead Forever Razorfen Kraul](https://www.wowhead.com/forever/zone=491/razorfen-kraul) and [Forever caster guide](https://www.wowhead.com/forever/guide/classes/warlock/affliction/level-30-dps-overview) — Vicar's Robe attributed to Death's Head Priest, classed as trash.
- [Azeroth.wiki Forever Rift Bracers](https://azeroth.wiki/forever/items/rift-bracers) — Arugal's Voidwalker in Shadowfang Keep listed as trash; the published listing does not establish current drop probability.
