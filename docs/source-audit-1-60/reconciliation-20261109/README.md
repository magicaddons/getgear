# GetGear acquisition-source reconciliation — 1–60

This is a comprehensive **evidence reconciliation**; it does not assert that all acquisition sources are confirmed in a live Forever realm.

## Catalogue and recipes
- All **7,707 / 7,707** equipment records examined.
- All **1,252 / 1,252** crafting recipes examined.
- All **577 / 577** dungeon-associated equipment records examined.
- New, conservative in-addon acquisition summaries generated: **583**.
- Combined Forever cache entries: **10,315**; Playfulls item entries: **22,890**.
- Published player-observed relationships: **853**.
- Dungeon rows needing exact enemy/boss/trash verification: **80**.
- Recipe book origins that still require live verification: **954**.
- Item ID name mismatches against Forever cache: **0**.

## Dungeon source classifications (reference quality, not drop-rate proof)
- boss: 390
- trash: 107
- dungeon-enemy: 59
- unknown: 21

## Dungeon evidence confidence
- forever-community-reference: 480
- forever-reference-unverified: 63
- unresolved: 21
- forever-observed-npc: 13

## Recipe learning (do not conflate *crafting* and *learning*)
- trainer-reference: 1,124
- vendor-reference: 68
- manual-researched: 50
- forever-observed: 6
- initial: 4

## Critical policy
- *Forever observed* means at least three Everloot installations independently recorded the item-to-NPC edge, and a published dungeon listing linked that NPC to this specific dungeon. These observations may still be incomplete.
- *Forever community reference* is a loot-list claim checked against client item IDs; it is **not** evidence of a live drop chance.
- *Classic reference* is used only as an explicitly uncertain farming lead.
- Encounter names in the client identify NPCs, not their loot tables.
- An unobserved recipe book is not evidence that a trainer teaches it or that a live vendor currently offers it.
- Original 1,252 crafting ingredient lists are **untouched**.
- Higher-confidence manually reviewed source text and item-ID exceptions take priority over this generated evidence.
- The index does not alter class eligibility, player status, equipment quality, recipe availability gates, or the two overlay filters.

## Audit files
- [All equipment records](all_items_reconciled.csv) — one row per item.
- [Dungeon acquisitions](dungeon_items_reconciled.csv) — boss, trash, named enemy, uncertainty, observations and source references.
- [Unresolved dungeon sources](dungeon_source_followups.csv).
- [Recipe acquisition and pattern book reconciliation](recipes_reconciled.csv).
- [Unresolved recipe sources](recipe_source_followups.csv).
- [Optional in-game verification](OPTIONAL_IN_GAME_CHECKS.md).
- [Source versions, hashes, attribution and limitations](provenance.json).

## Sources and licence notes
- [Playfulls](https://playfulls.com/database), [methodology](https://playfulls.com/methodology) — client + community loot sources (no live drop rates).
- [Everloot](https://everloot.app) — player-observed edges; [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) attribution and share-alike on derived Everloot observations.
- [Forever item cache](https://github.com/Napalmsteak/WoW-Classic-Item-Caches) — published Forever-specific tooltips and source references.
- [WoW Forever Friends](https://www.wowforeverfriends.org/library/sources/) — Classic baseline NPC/item lookup explicitly labelled unverified for Forever.
- [AHledger](https://ahledger.com) — supplemental recipe acquisition reference.
