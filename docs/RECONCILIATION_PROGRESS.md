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

## UI checkpoint — armour-only overlay filtering (2026-11-09)
**Status: completed and validated. Scope:** Conservative per-character overlay display filtering; full guide unaffected.
- Current `ShouldShowOverlayStatChanges` accepted positive `ITEM_MOD_ARMOR_SHORT` or `RESISTANCE0_NAME` as a valid upgrade despite negative intellect, spirit or other stats. These two ordinary armour keys no longer qualify by themselves.
- Any positive *non-armour* stat—including resistance, stamina, primary stats, spell stats—still qualifies even if other stats fall. Unknown comparison data and empty equipment slots remain visible. No bulk client item-data requests.
- New per-character setting: **Count armour-only improvements** (default **off**, including every tank-capable class; opt-in supports tank roles). Only affects tracker visibility while the pre-existing positive-stat filter is enabled; its setting is always visible in Display Settings.
- Detailed Guide, item eligibility, stat comparison numbers, materials in 'All' scope, source research and equipment progress remain unchanged; tracked material totals follow overlay visibility.
- **Validation: PASS** — [no-release CI 42490932171](https://github.com/magicaddons/getgear/actions/runs/42490932171) completed all source regeneration, addon Lua syntax and nine-class comparison, overlay, material, layout and performance regressions. It did **not** package or publish a release.
- Packaging and publishing remain out of scope.

## Checkpoint 3 — named low-level dungeon trash
**Status: completed and validated. Scope:** Two level-20/21 equipment drops whose named enemies can now be classified as trash using specific Forever references.

- **Rift Bracers (5943)** — Arugal's Voidwalker in **Shadowfang Keep**. [Forever-specific item entry](https://azeroth.wiki/forever/items/rift-bracers) explicitly lists Arugal's Voidwalker and "Trash"; independent [Icy Veins Forever item](https://db.icy-veins.com/wow-forever/items/5943) lists the same NPC as a source. Old Classic-based percentages are not asserted as live Forever rates.
- **Vicar's Robe (3569)** — Death's Head Priest in **Razorfen Kraul**, identified on the [WoWhead Forever zone page](https://www.wowhead.com/forever/zone=491/razorfen-kraul). The [Forever Affliction guide](https://www.wowhead.com/forever/guide/classes/warlock/affliction/level-30-dps-overview) independently lists Vicar's Robe under RFK **Trash**, not a named boss.
- The generator adds an exact two-ID/name-checked source override, role `trash`, a direct source URL and a clear `live drop unverified` caveat. It preserves the original source, source evidence, item ID, stats, eligibility and all recipe/mats data.
- Regenerated report confirms **137** trash equipment references, **20** remaining unresolved dungeon NPC/role entries, **552** total dungeon equipment and **954** uncertain recipe book sources. All **7,707** equipment identities and previously indexed **1,252** recipes are retained.
- **Scorn's Icy Choker (23169)** and **Abomination Skin Leggings (23173)**: both have credible historic links to Scorn and Sever, but Classic-era event-specific spawn availability is a caveat; no current Forever spawn/loot observation was established here, so neither is promoted in this checkpoint. [Forever source item](https://www.wowhead.com/forever/item=23169/scorns-icy-choker), [Forever Shadowfang source](https://senseos.gg/wiki/wow-forever/loot-tables/shadowfang-keep/).
- **Arcanowisp Robes (273044)**: [City of Dalaran community listing](https://tavernforever.com/en/loot/city-of-dalaran/) associates it with Arcanic Enigma, but [Forever class guides](https://www.wowhead.com/forever/guide/classes/mage/frost/level-30-dps-overview) expressly lack confirmed City of Dalaran drops; source remains uncertain rather than falsely confirmed.
- **Validation: PASS** — [non-release CI run 42491517157](https://github.com/magicaddons/getgear/actions/runs/42491517157) regenerated public-source evidence and passed manifest Lua syntax, full nine-class tests, crafting/material sources, stat/armour filtering, preview layout and performance. The auto-regenerated index and reports were saved to [commit 059e188](https://github.com/magicaddons/getgear/commit/059e18829305a1b195d0ee310277da86a507fe8b). Two intermediate CI attempts failed only because the new test asserted an incorrect runtime source-confidence field/value; the test was corrected without changing source facts.
- No ZIP, public release, tag, branch merge or change to `main`.

## Checkpoint 4 — dungeon role reconciliation (2026-11-09)
**Status: COMPLETED — full non-release CI PASS** in [workflow 42493307958](https://github.com/magicaddons/getgear/actions/runs/42493307958), including all nine classes, source regeneration, Lua syntax, filtering, materials, preview and performance.
- Audited all 20 dungeon-source leads. **14** item-ID/name-locked encounter roles now have specific Forever journal, guide or beta reference links, with live-drop caveats; **2** Dark/Relic Coffer leads correctly identified as containers, not NPCs, and retained as unresolved; **4** other item-source links remain unresolved. Queue now **6**.
- Dark Iron Ambassador's Royal Diplomatic Scepter has an exact Forever Journal loot link. Scorn's Icy Choker has a beta class-guide reference but event-spawn availability is not established. The BRD/UBRS/Sunken Temple/Scholomance item associations may derive from historic loot tables; never equate role identification with a live drop.
- Regression assertions enforce item-ID/name mappings, source uncertainty, container roles, and invariant 552 dungeon equipment, 7,707 gear and 954 uncertain recipe books. The [full consistency audit](source-audit-1-60/reconciliation-20261109/CHECKPOINT4_CONSISTENCY.md) checked all 577 original rows: 577 distinct IDs, no invalid boss/trash/container role records; 13 previously player-observed references remain explicitly observation-level evidence, not guaranteed live rates. Prior armour-only filtering stays untouched.
- [Full evidence register](source-audit-1-60/reconciliation-20261109/CHECKPOINT4_EVIDENCE.md) lists all 20 cases and reasons to retain unresolved rows.
- **Roadmap:** (1) finish any verifiable dungeon leads, (2) 954 recipe-book sources (68 vendor and 886 trainer-labelled), (3) other equipment source gaps, (4) final catalogue/source/filtering/regression audits, (5) in-game acceptance testing before asking approval to compile/publish. No packaging, tag, release or main merge.

## Unattended checkpoint procedure
The [agent instructions](../AGENTS.md) and [bounded overnight/Codex plan](OVERNIGHT_WORK_PLAN.md) document resume points, one-batch-at-a-time source validation, CI gating and release prohibitions. Scheduled task execution does not itself verify that repository writes or CI can run; each run must record actual outcomes.

## Checkpoint 5A — vendor-pattern evidence (2026-11-09)
**Status: documentation-only, no new CI.** Direct Forever item-ID-locked vendor and specialization references were recorded for Grovekeeper Grips (book 273953), Mitts (273957) and Mantle (273958) in [the 3-case evidence note](source-audit-1-60/reconciliation-20261109/CHECKPOINT5A_VENDOR_EVIDENCE.md). The three remain in the **68-record live vendor verification queue**, as published inventory does not prove live merchant stock. The prior full non-release CI pass remains workflow 42493307958; no addon files, recipes or filters changed. Next batch: individual remaining Grovekeeper book pages and their distinct quest/reputation/specialization gates.

## Next checkpoint
Resolve the remaining **6** source-verification leads only if new Forever item-specific evidence appears. Two are container/coffer leads, and four are unconfirmed mob/item or historical event associations. Next bounded active category is **954** recipe-book sources (68 vendor, 886 trainer-labelled). Preserve the other-equipment, final-audit, and in-game acceptance checkpoints in that order.

Recipe-book teaching routes are a **separate later category**; 954 remain uncertain pending source/stock evidence.

## User assistance
None required now. Optional later in-game vendor checks can be requested after the independent research is exhausted.
