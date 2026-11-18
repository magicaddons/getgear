# GetGear stabilisation handover — 19 November 2026

Private cumulative identity: `0.14.0-private-cumulative.20261119.8`.
Development branch: `dev/stabilisation-regression-20261119`.

## Verified baseline and preservation

The initial checkout was `main` runtime at `4ba2a850c4e3933b85f40c82a50b98314f117d80`, with 18 modules. It is not the cumulative baseline. Fetching all branches identified `.7` at `47adaeaef53e1dbb8876c523c29086b26468e6e5` on `dev/navigation-renderer-integrity-20261118`; its TOC, retained handover and successful exact-commit CI ([run 44315457582](https://github.com/magicaddons/getgear/actions/runs/44315457582)) agree. The new branch descends directly from that source. Canonical `integration/cumulative` at `685e612896c7297b18594bd28e448a21cac22dec`, the original cumulative commit and every recovered successor remain ancestors.

`BASELINE.json` records every expected .7 payload filename/hash, its exact source/tree, differences from the initial checkout and the preserved complete source archive's SHA-256. The .7 integrated baseline passed all 159 checks before runtime changes: 36 Lua suites on each interpreter, 29 modules and the cumulative feature contract. Its complete Git source archive and raw validation logs are preserved with the external task artifacts. `BASELINE_VALIDATION.json` retains the recorded result.

**Package identity limitation:** the owner-installed .7 ZIP/checksum was not available in this workspace. The versioned source/CI lineage and its expected packaged bytes are identified, but byte identity to the owner's installed ZIP is not independently certified. A filename/checksum clarification was requested while work continued. No claim is made that the unrelated checked-in Beta9 ZIP is the accepted .7. Its historical bytes remain untouched.

All 29 runtime modules and all 12 feature groups remain. Of those modules, only Core, GuideState, AltInventory and the label-fitting portion of MapNavigation change. UI.lua, marker frame levels/scale/placement/lifecycle, map asset, acquisition data, all recommendation/scoring rules, schema4 progress/settings and source qualifiers are retained. The approved 17-file acquisition snapshot is byte-exact. The feature contract adds mandatory new behavioral suites and updates only the reviewed cosmetic map-file hash. TOC/private README metadata identifies the new build consistently.

## Confirmed corrections

1. **Overlapping inventory events repeatedly rebuilt the same UI and bag snapshot.** The actual-code storm fixture demonstrates the shared issue across tracker, guide and hidden UI. Inventory refreshes now coalesce within a fixed 100ms deadline, bag snapshots within 50ms, with a pending-ledger flush before UI consumption, synchronous logout and timer-free fallback. This is a measured reduction of GetGear work, not proof that actual client hitching is resolved.
2. **A fixed 250px label box caused needless edge displacement for short NPC names.** fitLabel now measures text at the available wrapping width, fits name and area qualifier together, and applies the minimum viewport correction. Each refresh restores the measurement width first so a long name cannot inherit a previous short name's width. Layering, marker positioning and coordinate semantics remain intact. The old .7 runtime fails the new short-name boundary regression; the current implementation passes 324 physical edge/corner/interior/scale/name/area cases per interpreter.
3. **Regression summary counts could reflect files added after a run began.** The runner now retains the executed suite list for reporting. Four new test files were authored separately while the initial baseline ran. Its original summary counted that later directory contents; the preserved baseline receipt corrects the count to the 36 suites actually executed, using command records, and explains the correction. No failed baseline test is hidden by that accounting correction.

The new inventory-event and label tests were also run against the exported .7 runtime and failed on the intended old behavior. These expected negative controls are distinct from the successful full gates. During development, a richer font-metric fixture exposed the long-after-short label issue before delivery; it was corrected and revalidated on both Lua versions.

## Regression results and permanent additions

| Measure | Verified .7 baseline | Expanded source gate |
| --- | ---: | ---: |
| Integrated command checks | 159 | 167 |
| Functional Lua suites, Lua 5.1 | 36 | 40 |
| Functional Lua suites, Lua 5.4 | 36 | 40 |
| Runtime modules parsed on each compiler | 29 | 29 |
| Python unittest cases | 66 | 66 |
| Failed checks / skipped automated tests | 0 / 0 | 0 / 0 |

Python totals are 40 build/integrity cases, six recipe-generator cases and 20 release-tool cases; standalone generators/audits also run. These categories must not be added to the top-level command count as if they were independent command invocations. Executable coverage by requested area is in `REGRESSION_COVERAGE.md`.

Four new permanent suites build on the existing fixtures/framework:

- `account-inventory.lua`: real ledger, readable/empty/failing/unloaded bags and purchased personal bank tabs, delayed closing, saved account snapshots, faction/realm-separated totals.
- `inventory-events.lua`: full real TOC/Core/UI/ledger event path, visible/hidden/detail storms, latest state, late-event deadline ordering, sustained input, repeated bursts, stale callbacks, final logout, fallback without timers, optional profiling and preserved settings. Profiling preserves multiple returns/trailing nils, errors and method restoration and identifies unavailable memory inspection.
- `map-label-boundaries.lua`: 324 point/area edge/interior/scale cases, minimal displacement, wrapping width reuse, separate qualifiers, unchanged marker visibility/position/layering, honest Mivin uncertainty.
- `tracker-resize-budget.lua`: extends the existing 1,200-movement-tick benchmark with 5,000 stationary ticks, no redundant geometry writes/frames/heavy work, scroll clamping and release persistence.

The full source gate passed 167 checks. Final profile-memory reporting and richer instrumentation assertions were additionally syntax/behavior checked on Lua 5.1.5 and 5.4.7. Final exact-commit CI and the mandatory frozen-source/extracted-runtime package gate rerun the complete suite, including these final refinements. The external delivery receipts identify their final commit/run/ZIP, avoiding a self-referential hash in this report.

Existing recipe coverage includes all 1,254 catalogue crafts, 1,239 documented crafting minima, 104 independently reconciled entries, 72 source/profession matrix cases, and Veteran's Chain Helm's 29 documented enemies/five dungeons and Blacksmithing 125. Fifteen minima remain uncertain. No isolated Helm or NPC-specific runtime exception was added.

The catalogue navigation audit retains 7,732 audited IDs, 74,004 class/faction checks, 9,435 usable-location rows, 820 distinct simulated destinations and 25,608 raw source-evidence checks. Usable locations without a button, raw source evidence without a button, and bulk item-cache requests remain zero. Full map/source audits and honest uncertain destinations remain in the delivery logs.

## Coordinate investigation

Mivin Shadowweave (`npc:256735`) retains Redridge map1433, x=10 and y=72.4–72.8. The qualifier originates in retained multiple-position published geometry and the evidence projection's area classification. No demonstrated wrong map conversion or erroneous acquisition category is involved. The general location-review policy already accepts supported single points and preserves unresolved regions rather than choosing a corner or average.

Fresh opened references identify the same NPC but do not establish one agreed precise location: ForeverDB lists 10.0,72.7, Azeroth Wiki 10,72.5, and the exact Wowhead identity lists two locations without exposing mapper coordinates in its text extract. `MIVIN_REVIEW.json` retains citations and the decision. No unsupported precision is fabricated; Mivin remains a focused actual-client check. Broader accepted audit coverage of 975 source records, 70 primary capital references and 28 prior geometry corrections remains intact.

## Performance findings

See `PERFORMANCE.md` for separate causes, representative before/after measurements, instrumentation limits and follow-up. The 36-event fixture reduces tracker list enumerations 36→1 (guide plus tracker 72→2), bag snapshots 12→1, and retains zero hidden-window catalogue scans. CPU timings are synthetic examples, not client frame-time measurements. No total-allocation or other-addon attribution claim is made.

The accepted .7 already contains the historical section-resize correction at `cea9cdef9cc161959e3b3787dc0a0e025fbeb6e7`: geometry-only movement, no repeated full overlay refresh, pixel-change guard and release-only persistence. Baseline and expanded benchmarks verify zero heavy work/new frames. No speculative resize rewrite or additional throttle was introduced.

## Delivery, CI and reproducibility

`tools/validate_recommendations.py` remains the permanent integrated gate; GitHub Actions runs it on development pushes and PRs. No new dependency or alternate test framework is introduced. The isolated development branch is committed, pushed and live-verified before packaging. The canonical integration branch remains the ancestor baseline; future continuation of this milestone must use this stabilisation branch or its reviewed integration, rather than selecting the old main runtime.

The authorized installable private ZIP is built exclusively by `tools/release/build_test_package.py --remote-branch dev/stabilisation-regression-20261119`, with output outside the checkout. The gate checks clean committed source, exact live GitHub HEAD, canonical ancestry and the feature contract; exports all inputs from committed objects; runs the complete Lua 5.1/5.4 gate against the extracted runtime; validates every final member against source; checks deterministic serialization, manifest and checksums; then repeats live source verification before exposing the delivery.

Keep the resulting ZIP, `.zip.sha256`, `PACKAGE_MANIFEST.json`, `BUILD_INFO.txt` and full `validation/` together. They supply the exact source/tree SHA, ordered module inventory, member sizes/hashes, baseline and package checksum. The external `HANDOVER.md` records completed CI, final package validation and any remaining limitations. The source-tree pass alone is not the delivery evidence.

## Outstanding actual-client validation

Run `ACCEPTANCE.md`. Automated checks cannot certify installed-client pixel rendering, locale/font clipping, real loot/trainer/vendor/quest availability, looting event frequency/frame pacing, ItemTree interaction or drag smoothness. The 15 unresolved recipe minima and existing published-location/source uncertainty remain explicit. Bank-open scan performance retains existing behavior and is not claimed fixed. The owner-installed .7 ZIP identity remains unverified without its actual bytes/checksum. No passing mock is presented as real-client acceptance.
