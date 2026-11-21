# Checkpoint 6A — all 886 trainer-labelled recipe-book records: systematic triage

**9 November 2026. Status: 886/886 structurally classified; no unverified acquisition method promoted.** See the [886-record sortable source index](trainer_book_triage_index.csv) and the [Forever-specific case evidence](CHECKPOINT6A_TRAINER_SOURCE_EXAMPLES.md).

## Why the existing labels cannot be trusted as confirmed teaching

The source generator preserves `trainer (AHledger reference)` as `trainer-reference-with-pattern-item` whenever a book ID exists. The underlying **AHledger label is a catalogue reference, not in-game observation of a Forever trainer teaching the spell**. Separately, community acquisition mappings for the physical book may be vendors, quests, drops, reputation or nothing at all. **Both learning routes could exist**; a physical pattern item's existence does not prove or disprove trainer teaching.

All **886** records have unique crafted equipment IDs, distinct physical book IDs, and distinct craft spell IDs, all linked to a profession. All **886** have `requiresLiveCheck=True`, `materialsStatus=confirmed`, and **zero recorded `observedBookAcquisition` relations**. None overlaps the separate 68-book published vendor list. All **954** source uncertainties therefore remain open.

## Eight exclusive evidence families

| Research cohort | Records | Action and evidence standard |
|---|---:|---|
| Merchant's Favor vendor leads | **188** | Group by named profession vendor and faction; verify exact book ID/price/rep gate against Forever client item and vendor lists, then any independent live purchase |
| Other vendor leads | **131** | Named vendor's exact book, faction, gating and stock; never count anonymous source row as an extra merchant |
| Quest leads | **36** | Exact physical pattern book as quest reward, current quest availability and faction; historical Classic data stays labelled |
| Quest **and** drop lead | **1** | Audit both routes separately; `candidateMethod=drop` masks the named quest for Copper Chain Vest (#3609) |
| Reputation-only faction leads | **94** | Identify exact Forever book vendor or reward and published reputation; reputation faction alone is not a seller |
| Boss/dungeon leads | **41** | Exact physical book-to-encounter item reference and live observation; don't confuse finished equipment or Classic loot with book loot |
| Generic drop leads | **221** | Placeholder drop with no named NPC or zone; non-targetable/unknown until better evidence |
| No alternate source listed | **174** | Physical book ID and AHledger trainer label only; no acquisition route should be guessed |
| **Total** | **886** | **0** independently live-confirmed routes in this cohort |

These cohorts reconcile the original four generator categories: **319 vendor (188 Favor + 131 other), 263 drop (221 generic + 41 boss/dungeon + 1 quest/drop), 36 quest, 268 unresolved (94 rep-only + 174 no source).** No category is proof of availability.

By profession: Leatherworking **313**, Blacksmithing **270**, Tailoring **249**, Engineering **29**, Enchanting **24**, Alchemy **1**. Counts sum to 886. The [index](trainer_book_triage_index.csv) preserves the full item IDs, source types, candidate NPC names, quest names, faction leads, zones, Favor cost leads and anonymous source-row counts.

## Independent source checks and cautions

The [case evidence](CHECKPOINT6A_TRAINER_SOURCE_EXAMPLES.md) checks several materially different cases against published Forever client/tooltips and clearly marks what is **not** verified. Particularly important:

- **2406 Pattern: Fine Leather Boots** has a directly published Forever tooltip with **Leatherworking 65**, not the old Classic requirement 90. It proves the book teaches the craft, not a trainer or drop.
- **3609 Plans: Copper Chain Vest** has a physically existing Forever book and two alternative community references: *Supplying the Front* quest plus generic drop. The generator currently reports `candidateMethod=drop` only because of source-priority order; the alternate quest must not be lost. Quest loot origin still requires live Forever confirmation.
- **249530 Formula: Libram of Holy Alacrity** has a direct Forever book tooltip requiring Enchanting 300 and Honored; published Forever vendor references name Alynsia/Beneris, and the original queue records 240 Merchant's Favor. That does not prove live stock or live price.
- **13517 Recipe: Alchemist's Stone** has a direct Forever tooltip requiring Alchemy 275 and Barkskin Burrow Exalted and a published Mount Hyjal vendor location. The repository's reputation-only method is incomplete as a published lead, but not a verified live seller.
- **11813 Formula: Smoking Heart of the Mountain** exists as a Forever formula; the historical Lord Roccor drop association remains unverified on the live realm.
- **254681 Pattern: Stormcloth Pants** has a book ID and no published acquisition route in the input register. Do not infer that a trainer teaches the recipe.
- Published sources (e.g. [ForeverDiff's client comparison](https://foreverdiff.com/items/pattern-fine-leather-boots-2406/) and [SenseOS's methodology](https://senseos.gg/wiki/wow-forever/items/3609/plans-copper-chain-vest/)) distinguish **client tooltip data** from **classic-era loot/quest maps**. Use that distinction in source confidence.

## Concrete rule set for subsequent edits

1. Track separately **physical book exists**, **book teaches spell**, **specific trainer teaches spell**, **book acquisition lead**, **published purchase/quest reputation gates**, and **live realm observation**. Avoid a single trusted `trainer` boolean.
2. Link all evidence by **exact book item ID**, crafted item ID and spell ID. Verify name identity and spell/profession skill. Never join only by item name or assume adjoining IDs imply matching spells.
3. Record one or more source edges (e.g. Quest and Drop) per book with a reference URL, client build/dated observation, faction/rep requirements, source family and evidence quality. A blank NPC entry is **not** an additional merchant or a farm target.
4. Use three confidence stages: imported/historical source reference; published Forever-specific book/vendor/trainer/quest listing; observed live Forever purchase/training/quest/drop. An exact book tooltip alone supports book existence and its listed requirements, not the seller or loot table.
5. Do not remove possible trainer teaching merely because a book exists, nor declare that trainers offer a spell solely from AHledger. Query exact trainer spell data or seek in-game test.
6. **Only for a verified correction**, update source logic conservatively, write item-ID-locked regression coverage, run entire non-release CI and inspect regenerated evidence; never touch recipe materials, gear eligibility, filters, settings or `main`.

## Work order, optimised for research reuse

1. Merchant's Favor **188**: research per vendor/profession in batches of 15–25, with direct book ID, cost/rep gate and both faction sellers. Independent published [profession vendor inventories](https://www.wow-professions.com/forever/npc/mivin-shadowweave) and [published Forever source guide](https://playfulls.com/guides/merchants-favor) are useful references; beta lists are not current live stock.
2. **37** quests and mixed quests, prioritising early 1–30 items and odd alternate quest/drop patterns; confirm faction chains.
3. **131** other vendors plus **94** reputation-only, clustered by vendor/faction (225 records).
4. **41** dungeon and boss patterns, grouped by encounter and direct item-specific journal.
5. **221** anonymous generic-drop and **174** no-source records. Investigate by profession and Forever client spell/book evidence; do not waste repeated searches on the same uncited Classic drop list.
6. After the independent source pass, produce a small optional in-game verification matrix for remaining uncertainties and run the full regression gate before any proposed release.

## Validation status

**Targeted inventory checks PASS:** 886 unique crafted IDs, 886 unique book IDs, 886 unique spell IDs, eight source-family counts total 886, no overlap with the 68 vendor-book records, no observed acquisition edges or promoted live statuses. This is a **documentation/index-only checkpoint**, so no Lua code was changed and no new full CI ran. Previous full non-release [PASS 42493307958](https://github.com/magicaddons/getgear/actions/runs/42493307958) still represents the validated code. **No ZIP, tag, release, packaging, main merge or publish approval.**
