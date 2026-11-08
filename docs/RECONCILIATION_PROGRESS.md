# GetGear acquisition reconciliation — durable checkpoints

## Baseline recovered (2026-11-09)
- Branch: `work/full-acquisition-reconciliation-20261109`; starting commit `e03c64418356`.
- Prior comprehensive audit inspected 7,707 equipment records, 1,252 *previously indexed* crafting recipes and 577 historically dungeon-associated entries; results should not be treated as proof of live drops or vendors.
- Historical reconciliation CI: successful run [42488267084](https://github.com/magicaddons/getgear/actions/runs/42488267084); latest source snapshot passed its existing catalogue checks in [42488345804](https://github.com/magicaddons/getgear/actions/runs/42488345804). Earlier intermediate source-probe failures do not supersede those passes.

## Checkpoint 1 — dungeon equipment vs. crafted gear classification
**Status: completed and audited. Scope:** One known false-positive dungeon record, item 220606 *Idol of the Dream*, not a re-audit of the catalogue.

- Root cause: the historical EquipmentCache row labels the item `The Temple of Atal'Hakkar, Crafted` with dungeon source code 6. The original recipe inventory did not include this craft, causing a generated report to treat the finished gear as unidentified dungeon loot.
- Corrected runtime source through `SourceEnrichment.lua` without modifying item ID, level, class mask, or all previously indexed recipe material lists.
- Independently published Forever client recipe: spell 1249128, Enchanting 300, formula item 249529; seven ingredient quantities matched against [ForeverDiff](https://foreverdiff.com/recipes/idol-of-the-dream-54443/), [Wowhead's Forever recipe](https://www.wowhead.com/forever/spell=1249128/idol-of-the-dream), and names/IDs already in `GeneratedBeta7Evidence.lua`.
- Provisional Alliance source: Alynsia at Three Corners, Redridge Mountains, reported as 240 Merchant's Favor with Honored requirement. [Forever atlas](https://wowforever.gg/en/atlas/knowledge/items/formula-idol-of-the-dream-i249529/), [Wowhead formula](https://www.wowhead.com/forever/item=249529/formula-idol-of-the-dream), and [community beta merchant log](https://wowforevertalent.com/professions/enchanting/?acquisition=favor). Live inventory/stock is NOT verified.
- The regenerated audit retains the historical association as `crafted-item` rather than loot: **552** dungeon equipment records, **24** possible dungeon-pattern associations, **1** false-positive finished craft, and **31** unresolved enemy/role questions. The excluded item is absent from both `dungeon_equipment_drops.csv` and `dungeon_source_followups.csv`.
- Added offline regression expectations to `tests/beta7-evidence.lua` and `tests/beta7-acquisition-reconciled.lua`.
- **Validation: PASS** — [CI run 42489073921](https://github.com/magicaddons/getgear/actions/runs/42489073921) completed successfully on 2026-11-09 (Adelaide). It ran public-source reconciliation, syntax checks for all addon Lua modules, nine-class catalogue/source/material/armour/preview regression, overlay filters, and performance checks. CI regenerated the reports in commit [`f7d3286`](https://github.com/magicaddons/getgear/commit/f7d3286a2f722f892771050d0adb2d298cb91245). This is **offline** validation, not a live-server test. Never promote a reference to a confirmed live drop or currently stocked vendor.
- **Packaging:** Prohibited without explicit user approval; no ZIP, tag, release, merge or change to `main`.

## Checkpoint 2 — Scarlet Monastery Graveyard rare bosses
**Status: completed and validated. Scope:** Nine level-30 dungeon equipment items, three rare encounters. This is a targeted boss-versus-trash classification fix, not a new catalogue or recipe audit.

- Forever's published [Scarlet Monastery: Graveyard Dungeon Journal](https://www.wowhead.com/forever/dungeon-journal/scarlet-monastery-graveyard) identifies **Ironspine**, **Fallen Champion**, and **Azshir the Sleepless** as rare bosses, and lists three specific equipment rewards under each encounter.
- Ironspine: **7686** Ironspine's Eye, **7687** Ironspine's Fist, **7688** Ironspine's Ribcage — [Journal loot](https://www.wowhead.com/forever/dungeon-journal/scarlet-monastery-graveyard/ironspine-rare).
- Fallen Champion: **7689** Morbid Dawn, **7690** Ebon Vise, **7691** Embalmed Shroud — [Journal loot](https://www.wowhead.com/forever/dungeon-journal/scarlet-monastery-graveyard/fallen-champion-rare).
- Azshir the Sleepless: **7708** Necrotic Wand, **7709** Blighted Leggings, **7731** Ghostshard Talisman — [Journal loot](https://www.wowhead.com/forever/dungeon-journal/scarlet-monastery-graveyard/azshir-the-sleepless-rare).
- The generator now uses an explicit nine-ID/item-name-checked journal register, records source role `rare-boss`, `published-forever-dungeon-journal` confidence, a direct journal URL, and the displayed summary "Rare boss: ... (Forever Dungeon Journal; live drop unverified)". It does not generalise Classic elite NPC ranks or encounter lists to loot.
- Existing observed data for Blighted Leggings (#7709) is preserved; its missing readable source summary is supplemented only.
- Regenerated report: **552** real dungeon equipment entries remain, **9** rare bosses are now separately documented, and the unresolved boss-versus-trash queue fell from **31 to 22**. All nine identifiers were checked against the regenerated equipment audit and the current in-addon evidence index.
- **Validation: PASS** — [no-release CI run 42490031007](https://github.com/magicaddons/getgear/actions/runs/42490031007) completed the public source-reconciliation step, full manifest Lua syntax check, nine-class catalogue/crafting/armour/overlay/preview/performance regressions and evidence-index checks. The regenerated reports were saved in [commit 55324d3](https://github.com/magicaddons/getgear/commit/55324d34501d4288162b36912e59b22b15aeb2f9).
- **Limitations:** Forever Dungeon Journal is published source evidence, **not** proof of a current live drop or percentage. No real-game UI or dungeon-drop observation was performed.
- No ZIP, release, tag, branch merge or modification of `main`.

## Next checkpoint
Prioritise lower-level targets among the **22** remaining dungeon-source questions: Rift Bracers (5943) and Abomination Skin Leggings (23173) in Shadowfang Keep; Vicar's Robe (3569) in Razorfen Kraul; Arcanowisp Robes (273044) in City of Dalaran; and Scorn's Icy Choker (23169) in Scarlet Monastery Graveyard. These require their own small Forever-specific evidence batch—do not promote Classic-only drop rates or NPC labels to live confirmation.

Recipe-book teaching routes are a **separate later category**; 954 remain uncertain pending source/stock evidence.

## User assistance
None required now. Optional later in-game vendor checks can be requested after the independent research is exhausted.
