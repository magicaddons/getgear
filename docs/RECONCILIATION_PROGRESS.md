# GetGear acquisition reconciliation — durable checkpoints

## Baseline recovered (2026-11-09)
- Branch: `work/full-acquisition-reconciliation-20261109`; starting commit `e03c64418356`.
- Prior comprehensive audit inspected 7,707 equipment records, 1,252 *previously indexed* crafting recipes and 577 historically dungeon-associated entries; results should not be treated as proof of live drops or vendors.
- Historical reconciliation CI: successful run [42488267084](https://github.com/magicaddons/getgear/actions/runs/42488267084); latest source snapshot passed its existing catalogue checks in [42488345804](https://github.com/magicaddons/getgear/actions/runs/42488345804). Earlier intermediate source-probe failures do not supersede those passes.

## Checkpoint 1 — dungeon equipment vs. crafted gear classification
**Scope:** One known false-positive dungeon record, item 220606 *Idol of the Dream*, not a re-audit of the catalogue.

- Root cause: the historical EquipmentCache row labels the item `The Temple of Atal'Hakkar, Crafted` with dungeon source code 6. The original recipe inventory did not include this craft, causing a generated report to treat the finished gear as unidentified dungeon loot.
- Corrected runtime source through `SourceEnrichment.lua` without modifying item ID, level, class mask, or all previously indexed recipe material lists.
- Independently published Forever client recipe: spell 1249128, Enchanting 300, formula item 249529; seven ingredient quantities matched against [ForeverDiff](https://foreverdiff.com/recipes/idol-of-the-dream-54443/), [Wowhead's Forever recipe](https://www.wowhead.com/forever/spell=1249128/idol-of-the-dream), and names/IDs already in `GeneratedBeta7Evidence.lua`.
- Provisional Alliance source: Alynsia at Three Corners, Redridge Mountains, reported as 240 Merchant's Favor with Honored requirement. [Forever atlas](https://wowforever.gg/en/atlas/knowledge/items/formula-idol-of-the-dream-i249529/), [Wowhead formula](https://www.wowhead.com/forever/item=249529/formula-idol-of-the-dream), and [community beta merchant log](https://wowforevertalent.com/professions/enchanting/?acquisition=favor). Live inventory/stock is NOT verified.
- Generator now preserves the historical dungeon association as `crafted-item` but excludes it from dungeon loot and unresolved dungeon enemy counts. Expected report once CI regeneration passes: 552 actual dungeon equipment records, 24 dungeon-pattern associations, 1 false-positive craft, 31 unresolved enemy/role questions.
- Added offline regression expectations to `tests/beta7-evidence.lua` and `tests/beta7-acquisition-reconciled.lua`.
- **Validation:** CI regeneration and regression results pending. Never promote source reference to a confirmed live drop or currently stocked vendor.
- **Packaging:** Prohibited without explicit user approval; no ZIP, tag, release, merge or change to `main`.

## Next checkpoint
Research a small set of remaining `dungeon-enemy` entries against current Forever-specific observations and source identities. Do not upgrade Classic-only claims to live-verified facts. Check recipe-book teaching routes separately in a later checkpoint; 954 of those remain uncertain pending actual server evidence.

## User assistance
None required now. Optional later in-game vendor checks can be requested after the independent research is exhausted.
