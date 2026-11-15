# Checkpoint 4 — 577-row dungeon-source consistency check

**Date:** 2026-11-09 (Adelaide); **scope:** regenerated `dungeon_items_reconciled.csv`, `dungeon_equipment_drops.csv`, and `dungeon_source_followups.csv` on development branch. This is an offline schema/source review, not a live drop-rate audit.

## Exact classifications

| Role | Rows |
|---|---:|
| trash | 137 |
| boss | 397 |
| rare-boss | 12 |
| dungeon-enemy | 4 |
| container-lead | 2 |
| crafted-item | 1 |
| crafted-pattern | 24 |
| **Total historical dungeon-associated rows** | **577** |

- All **577** rows had unique equipment IDs, with no duplicate classifications.
- True dungeon equipment: **552** = 397 boss + 12 rare boss + 137 trash + 4 dungeon enemy + 2 container leads.
- The other 25 rows remain distinct: **24 crafted-pattern associations** and **1 crafted finished item**, Idol of the Dream. None should masquerade as dungeon equipment drops.
- All classified boss/rare-boss/trash/named-enemy rows have nonempty encounter names and source zones. All two coffer records say **Container lead** and explicitly lack live Forever item-loot proof.
- Every published boss/trash source summary either contains a reference/verification qualification or is among **13** already player-observed `forever-observed-npc` records. The latter represent independent player-observed NPC/item edges, not guaranteed drop rates.
- The six unresolved records are **10801**, **11945**, **11946**, **14525**, **23173**, and **273044**. The two 119xx records are confirmed *container-type leads* but their item-specific loot is not confirmed live.
- Validity checks found **0 structural/source-role contradictions** under these rules. Item-to-boss mapping in unobserved guides remains **reference-level**, not verified on a current Forever realm.

## Validation

- [Comprehensive no-release CI 42493307958](https://github.com/magicaddons/getgear/actions/runs/42493307958): **PASS**. Source generator, complete module Lua syntax, nine-class catalogue/source/crafting/material/stat rules, overlays (armour-only and green world BoE), settings, preview layout and performance.
- The CI generator automatically committed updated `AcquisitionEvidenceIndex.lua` and the reconciliation CSV/README/provenance files on the development branch in [dee3f9b](https://github.com/magicaddons/getgear/commit/dee3f9b004473519523dca957ce2b28d22083537).
- Does not verify live loot, current encounter/event availability or client UI; no ZIP, build, release, tag or main merge.
