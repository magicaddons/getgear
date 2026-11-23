# Validation receipt

Source gate: **187 checks passed, 0 failures; 29 modules; 49 Lua regression suites
on each of Lua 5.1.5 and 5.4.7**. The cumulative feature contract, source-byte
acquisition audits and approved 17-file snapshot passed. Full receipt:
`source-validation.json`. This is source validation; the private-package builder
runs the complete gate again against the extracted committed runtime.

Commands run from the repository (Lua 5.4 binaries added to PATH):

```sh
python tools/reconcile_presentation_snapshot.py --verify-only
python tools/validate_recommendations.py --output /workspace/artifacts/overlay-groups-validation-final --lua51 /workspace/.getgear-tools/lua51/usr/bin/lua5.1 --luac51 /workspace/.getgear-tools/lua51/usr/bin/luac5.1
python tools/benchmark_overlay_idle_groups.py --baseline-root /workspace/artifacts/overlay-baseline --output /workspace/artifacts/overlay-idle-comparison-final --lua51 /workspace/.getgear-tools/lua51/usr/bin/lua5.1 --lua54 /workspace/.getgear-tools/lua/usr/bin/lua5.4 --repeats 3
lua5.4 tools/benchmark_paired_overlay.lua /workspace/artifacts/overlay-baseline /workspace/getgear
```

The new targeted suite passed on both interpreters, including all group
boundaries, exclusions, live-map-input changes/failures, visibility and resize
callback lifetimes. Existing search/star/row tests cover all nine classes and 16
original faction-valid contexts; the unchanged recommendation-state suite passed
108 contexts and 12,852 slot views.

## Before/after observations

These are medians of three synthetic runs per interpreter against byte-verified
production `de1037a8a20593430d1c27e123685980d6da909b`. All six class/level contexts
have identical deterministic reductions in catalogue/totals calls. The table
shows the reported Warrior context with materials expanded; it is an example,
not a class-specific fix. Full multi-context data is in `comparison.json`.

| Lua | Workload | Catalogue/totals calls before → after | CPU ms before → after | GC-paused Lua heap growth KiB before → after |
| --- | --- | --- | --- | --- |
| 5.1 | 40 unchanged-map notifications | 40/40 → 0/0 | 1737.144 → 4.098 | 105135.9 → 5.6 |
| 5.1 | 40 combat transitions | 40/40 → 0/0 | 1704.797 → 4.173 | 105136.1 → 0.0 |
| 5.1 | 20 page clicks | 20/20 → 0/0 | 851.855 → 71.715 | 55746.8 → 11538.1 |
| 5.1 | 3 slot choices | 3/3 → 0/0 | 121.266 → 16.462 | 7978.9 → 1319.2 |
| 5.4 | 40 unchanged-map notifications | 40/40 → 0/0 | 1371.970 → 3.771 | 81550.1 → 4.7 |
| 5.4 | 40 combat transitions | 40/40 → 0/0 | 1280.188 → 3.857 | 81550.1 → 0.0 |
| 5.4 | 20 page clicks | 20/20 → 0/0 | 694.051 → 62.392 | 42910.9 → 9909.5 |
| 5.4 | 3 slot choices | 3/3 → 0/0 | 97.154 → 15.181 | 6086.8 → 1086.9 |

Across 3,600 simulated idle frames per context, overlay callback calls fell from
3,600 to zero, while both versions already performed zero idle recommendation
refreshes. Idle-loop CPU includes mock-frame traversal and does not measure
native renderer savings. Closed-overlay notifications perform zero catalogue or
material calculations before and after; the new version additionally skips the
redundant `RefreshAll`/`RefreshOverlay` calls when location is unchanged.

A 20-click page workload still renders entering rows: Warrior comparison calls
fell from 8,720 to 640, rather than zero. Slots still compose/filter the validated
model (three compositions); page/group clicks reuse the partitioned lists.
No per-frame model copy, location poll or gameplay cache was introduced.

GC-paused growth deliberately accumulates temporary allocations across each
batch. It is not retained memory, native allocations or normal client GC behavior.
Profiling timings include nested calls and cannot be summed as separate costs.
In-game `/getgear perf start` / `perf stop` remains opt-in; it reports bounded
refresh timings/triggers/cache counts and GC-sensitive net heap.

## Full refresh cost and limits

The separate alternating full-refresh benchmark preserves identical ordered
recommendations and source calculation counts. Full relevant-input refreshes
remain expensive; this task avoids redundant invocations rather than promising
a cheaper score/eligibility pipeline. The first run, concurrent with other
validation, observed -4.34% expanded and +9.74% collapsed CPU time per ten
refreshes. An isolated repeat observed +1.67% expanded (175.547 → 178.481ms) and
+7.33% collapsed (178.350 → 191.424ms) per ten refreshes. Full refreshes
now also partition the group lists; no reduction in full-refresh cost is claimed.
The repeated collapsed increase is a remaining synthetic cost observation to
check in client, alongside the much lower event/navigation workload. These observations have no
elapsed-time pass threshold and are not native frame-pacing measurements.

Actual Forever client acceptance remains **pending**. Follow the checklist in
`REPORT.md`; passing mocks does not establish that movement hitching is gone.
Final remote source/CI identity, package hashes and extracted-runtime receipts
are supplied alongside the ZIP, outside the checkout to avoid self-referential
commit hashes.
