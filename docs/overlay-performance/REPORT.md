# Overlay calculation performance — cumulative .10

This focused milestone starts from accepted `.9`, commit `b08945d44fd454c13446a322bedbb58b1acc77fa`. It preserves the catalogue, recommendations, filters, progress, map navigation and UI layout. It does not certify live-client frame pacing or resolve the user's gameplay acceptance without their tests.

## Recovery and demonstrated causes

The interrupted execution was located through its retained command history. Its original dirty workspace and raw artifact directory were not accessible in this execution. The history recorded six modified runtime files and a new production-path benchmark, followed by an explicit usage-limit failure. Two expressions in its last profiling edit were redacted. Those edits were not blindly replayed. The benchmark literal and reviewed earlier scripts were recovered selectively; the final implementation and profiling attribution were reviewed and reconstructed separately. The recovery inventory is in `RECOVERY.json`.

Checkpoint `d96453008f5124186f50c593594e479841ea8a5d` preserves the production workloads and accepted `.9` output signatures before runtime changes. Subsequent implementation, CI, package and remote receipts accompany the final delivery. No unrelated branch, main, release or tag is modified.

The production-path fixture loads the actual 29-module TOC, Core and UI against deterministic frame, inventory and timer APIs. Before this repair, ten warm tracker refreshes called route eligibility 78,090 times. A single loot refresh rebuilt 2,548 recommendation records, made 5,471 source checks and evaluated 7,809 route sets. The same gear was examined in list selection, stat/availability filtering, visible rows, unknown-recipe checks and material aggregation. Routine warm refreshes created zero frames, so frame creation did not explain this workload. Idle movement in this fixture scheduled no heavy work; zone events did trigger full refreshes. These observations do not attribute all real movement hitching or other-addon interactions.

## Changes and correctness boundaries

`GetItems` rejects impossible future entries before building character-filtered acquisition information. This is safe because the access adjustment only raises a target level; effective levels are still checked afterward, and Hidden/Completed history retains its original reach. `ShouldDisplayGear` rejects out-of-lookback items before source processing while preserving hard eligibility for Show All and browsing scopes.

`GetRecommendationRecord` inspects raw quest facts only to rule out a possible increase. When any raw quest minimum could raise the target, the original full character-aware minimum calculation still decides. Mixed alternatives, unknown requirements, recipe-book quests and profession/bag exceptions retain their original semantics. Dedicated tests compare the shortcut with the original minimum rule.

`WithRecommendationSnapshot` reuses derived acquisition, faction, comparison, profession and recipe calculations inside one synchronous refresh. `RefreshAll` shares the scope between visible guide and tracker; standalone `GetItems`, `RefreshUI` and `RefreshOverlay` also establish a scope. Nested callers reuse it. Every result reference is released before the outer call returns, including on errors. The installed delegates retain no result across calls: inventory, equipment, class, faction, level, talents, quest, recipes, priorities, settings and account changes are read afresh next time. There is no persistent recommendation cache or invalidation list.

Keys distinguish nil, false, item identity and explicit context/option identity; all return values and nil holes are preserved. Explicit weapon-pair planning with a third argument bypasses memoization. Existing state-change and recommendation tests run in addition to the new lifetime/error tests. The implementation does not cache request-suppressing comparisons as request-enabled comparisons.

Material routines reject noncontributing records before acquisition/stat work. Collapsed total materials skip aggregate/recipe-tree construction. The visible header still receives the unknown-recipe information needed for its incomplete-list label. Expansion rebuilds current totals immediately. Per-objective materials remain controlled by their existing expansion state, and material scope, quantities and equipment-slot independence are preserved.

No debounce interval was lengthened. The `.8` 100ms inventory refresh and 50ms bag snapshot deadlines, synchronous fallback, latest-ledger flush and logout behavior remain. Zone, skill, quest, talent, combat and item-data events still cause legitimate updates through the existing scheduling paths.

## Combined-view benchmark failure

The interrupted test called `ShowUI()` and then `RefreshAll()`: that performs **two** guide refreshes and **one** overlay refresh. Its old `600 × RefreshOverlay` source-check budget counted only the overlay and failed at 604 checks, despite a large reduction from the baseline. The failure was an incorrect workload assumption, not proof of a calculation regression.

The replacement requires exactly two guide refreshes and one overlay refresh, with explicit total budgets (650 source checks, 700 route evaluations and 550 obsolete checks). Ordinary overlay-only cases have tighter budgets of 450/500/400 per refresh. Separate warmed guide-plus-overlay tests require exactly 20 list requests for ten combined refreshes and prove that shared calculation scope reduces route evaluations **6,320→4,160** and source checks **6,040→3,900** compared with separately scoped guide and overlay refreshes. Output fingerprints and frame-pool checks prevent obtaining the budget by suppressing work or returning empty lists.

## Measurements

`benchmark-comparison.json` retains all three sequential repeats per interpreter, raw operation counts, output signatures and median CPU times for the same baseline/implementation workloads. Baseline TOC, asset and runtime bytes are independently checked against the exact `.9` Git objects. Measurement precedes the final receipt commit; the frozen-source/extracted-runtime gate is the final implementation/package check. Full raw runs and exact final provenance are supplied with the delivery.

Representative operation counts are identical on both interpreters:

| One loot refresh | .9 | .10 |
| --- | ---: | ---: |
| Recommendation-record visits | 2,548 | 1,093 |
| Source-eligibility calculations | 5,471 | 390 |
| Route calculations | 7,809 | 416 |
| Equipment comparisons | 346 | 346 |
| Obsolete checks | 944 | 314 |
| Profession queries | 8 | 1 |
| Text writes | 259 | 259 |
| New frames | 0 | 0 |

Collapsed totals perform **1→0** aggregate calls without hiding the uncertainty header. Both hidden windows retain zero list calculations in the inventory-event regression. The existing moving/stationary resize budgets remain zero heavy work and zero new frames.

Across the three-repeat development comparison, every active workload reduced median synthetic CPU time on both interpreters; no measured active workload regressed. Idle movement retained zero heavy calls and negligible timer-fixture overhead. Full time comparisons follow below. These are not client latency distributions, an FPS guarantee, or a measurement of other addons. Shared-host conditions and GC affect timings; permanent gates enforce operation counts and correctness rather than fragile elapsed-time limits.

The one-refresh GC-paused Lua heap-growth proxy fell from 9,885.5 to 1,337.1 KiB on Lua 5.4 and 15,031.9 to 1,665.7 KiB on 5.1. This isolated synthetic experiment pauses collection only inside the test. It is not a total client allocation counter or a measurement of GC pause duration. Production never forces or pauses collection. GC-sensitive net heap samples are retained separately and are not described as allocated bytes.

## Optional diagnostics

`/getgear perf start` and `stop` now report call totals, averages, maxima, rolling p50/p95 values and initiating-event counts, plus snapshot hits/misses. Instrumented phases separate selection/evaluation, sorting, objective UI, material aggregation and material UI. Samples are limited to the last 128 per operation, with at most 128 individual overlay-refresh records; only the latest capture is retained in session memory. Nested inclusive times overlap. Profiling is optional, adds overhead and does not measure native frame pacing. Starting/stopping and error cleanup have permanent tests; disabled profiling performs no sampling, memory inspection or polling.

## Preservation, regression scope and acceptance

All 23 other runtime modules, including `AcquisitionNavigation.lua`, `MapNavigation.lua`, the inventory ledger, recommendation/stat engines and recipe data, remain byte-identical to `.9`. The section-resize implementation and accepted acquisition-pin UI section are exact. All 17 protected acquisition snapshot files remain exact. `PRESERVATION.json` records the module set and resize-section digest. Only six runtime modules change: GuideState, Materials, GearRelevance, Core, ItemData and UI; the private version label advances to `.20261121.10`.

The new matrix compares ordered recommendations, effective levels, unknown-recipe membership, exact material quantities and all 17 slot selections across nine classes, both factions, levels 1/15/30/39/40/60 and seven views: **108 contexts and 12,852 slot views** per interpreter. It also opens the real guide and overlay and collapses/expands totals after changing inventory in every context. Other existing suites cover additional level boundaries, previews, priorities, equipment combinations, alternative acquisition routes, quests, learned recipes, bank/account snapshots, settings and saved progress. Unknown facts and supported faction/class combinations retain their existing rules.

New dedicated tests cover snapshot lifetime, options/contexts, return arity, nested calls, error cleanup, explicit weapon partners, quest-minimum bounds, bounded profiling, event attribution and actual UI workloads. All three suites are required in the cumulative feature contract and automatically exercised on Lua 5.1 and 5.4, including against the extracted package. The `.9` baseline passed 169 top-level checks and 41 Lua suites per interpreter. The expanded gate contains 175 checks and 44 suites per interpreter, with 105 Python unittest cases. Final pass/fail counts, CI URL, full source SHA, ZIP/source comparison, checksum and package receipts are in the delivery handover and manifest.

Actual-client acceptance is left to the owner: repeat overlay closed/open/closed/open while moving, grinding, looting and mining, both with GetGear alone and the normal addon set; compare captures with profiling disabled too. Check updated equipment, talents, skills, quests and materials after each relevant change. This repair substantially reduces demonstrated work but still rebuilds necessary recommendations and UI on legitimate refreshes. Its remaining per-refresh CPU/heap cost, GC pacing, native rendering and ItemTree/other-addon effects require real-client observation.

## Median synthetic CPU milliseconds (three repeats)

| Workload | Lua 5.1 .9 → .10 | Lua 5.4 .9 → .10 |
| --- | ---: | ---: |
| warm overlay x10 | 726.974 → 162.958 | 532.072 → 130.458 |
| one loot | 64.038 → 19.057 | 50.178 → 15.022 |
| rapid loot x12 | 64.360 → 19.120 | 51.936 → 15.640 |
| mining + skill | 125.288 → 33.803 | 106.912 → 27.894 |
| movement zones x10 | 698.934 → 162.652 | 520.776 → 125.036 |
| ordinary movement idle | 0.005 → 0.005 | 0.006 → 0.006 |
| collapsed materials | 63.820 → 16.341 | 48.364 → 13.359 |
| slot changes x3 | 174.685 → 44.831 | 154.606 → 36.345 |
| open close x3 | 194.092 → 49.492 | 156.670 → 37.648 |
| priority settings | 183.173 → 48.887 | 162.214 → 41.274 |
| equipment | 68.827 → 19.688 | 53.122 → 16.956 |
| profession | 121.031 → 33.632 | 103.750 → 28.161 |
| hide restore | 124.039 → 33.425 | 107.516 → 26.454 |
| detail + overlay | 135.846 → 30.259 | 111.285 → 24.375 |
