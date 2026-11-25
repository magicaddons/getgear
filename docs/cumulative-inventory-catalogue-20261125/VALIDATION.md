# Cumulative inventory/catalogue integration review

Version: `0.14.0-private-cumulative.inventory-catalogue.20261125.1`.
Branch: `dev/cumulative-inventory-catalogue-20261125`.
This report records source review and offline validation. Final exact source SHA,
CI, extracted-runtime receipts, ZIP checksum and manifest are external delivery
receipts to avoid embedding a self-referential commit hash here.

## Source and workstream preservation

Current remote production was fetched and confirmed at
`de1037a8a20593430d1c27e123685980d6da909b`; historical integration remains
`685e612896c7297b18594bd28e448a21cac22dec`. All original cumulative/recovery
commits through `e61c16c1a136d3972b0af5b18821ceec1a2239f7` remain ancestors.

The standalone inventory work is now remotely preserved as
`4e314ffda1865847c5061c2eaf7482b4c02cf98e` on
`fix/alt-inventory-scope-20261125`. Its entire tree exactly matches the tested
local checkpoint `efe5a00e222f98fdb90ffe2031b3441770a65b39`; its parent retains
`4d5fdb6e4171abf576735dcd0b48d36132da4e89` overlay idle/group work.
[Inventory CI succeeded](https://github.com/magicaddons/getgear/actions/runs/45538960216).
No isolated inventory installation ZIP is being delivered.

The completed catalogue chat `6b0551e5-4488-83ec-a802-5f30f0314095` was located
and its final delivery and reports reviewed. It identifies source
`9cab9ff7897fdcad98fa783cfed3e507446f5cfb` on
`dev/source-integrity-20261124`, a completed private package receipt and
[successful GitHub CI](https://github.com/magicaddons/getgear/actions/runs/45518202409).
The prior package receipt identifies SHA-256
`3d5d26583ed9b2c217e399d5553ff9478b81095df0877c815a1470c16fa5e911`.
Its report explicitly disclaims whole-record/current-client verification.

All 60 committed research artifacts matched their manifest before integration.
One inherited prose discrepancy was corrected: the exact ledger has 7,423 route
rows, including 3,115 retained published-but-unverified rows, rather than the
7,424/3,116 stated in COVERAGE.md. That document and its manifest entry were
updated; no route or evidence row changed. All 60 manifest hashes verify again.
The authoritative route partition is:

| Status | Rows |
| --- | ---: |
| Exact published guide join | 170 |
| Retained published but unverified | 3,115 |
| Unapproved-evidence hold | 360 |
| Missing route-level evidence | 3,778 |
| Total | 7,423 |

The integration is a two-parent development merge of the independently preserved
inventory and research commits. The sole textual conflict was GetGear.toc's
private version; it was resolved with this new cumulative identity and all
three research policy modules retained. The shared UI and feature contract
merged independently applicable changes. Direct comparison verifies:

- Every required module, feature group and required regression from both
  parents remains in the merged contract: 32 modules and 14 feature groups.
- AltInventory.lua is byte-identical to the independent inventory commit;
  CommercePolicyData.lua, ResearchPolicyData.lua, AcquisitionPolicy.lua and the
  reviewed acquisition runtime changes retain the research checkpoint's bytes.
- The accepted 17-file historical acquisition snapshot, candidate holds and
  unaffected modules retain their accepted bytes. Existing renderer pinning and
  zero-navigation-loss assertions remain required.
- Inventory, source-policy and overlay groups all run in the same real TOC/UI
  test harness; one workstream is not substituted for another.
- No main/integration/research source branch is advanced by this integration;
  no release/tag or public installation package is created.

Research's reviewed raw-source-evidence minimum remains 22,016, with its original
reason for active holds. Other navigation minima and all zero-loss requirements
remain. This intentional qualified-evidence policy is not an accidental record
or module deletion. The original frozen records remain preserved.

## Incorporated corrections and unresolved research

[CHANGELOG.md](CHANGELOG.md) lists implemented changes. The catalogue checkpoint
contains actual validated corrections, including 30 names, three levels, three
quest titles, exact commerce service joins, 10 additional learning alternatives,
41 book associations and 42 legacy route projections. Faction/service eligibility,
learning requirements, text and navigation share the same decisions. Independent
alternatives, learned recipes and confirmed finished-item trade remain separate.

Research is not complete verification of the catalogue. Keep these open:

| Unresolved area | Count / qualification |
| --- | --- |
| Missing equipment responses | 92 of 7,707 requests |
| Unmatched crafting material joins | 32 of 1,254 crafting records |
| Published learning-skill disagreement | 54 commerce offers; both values remain visible |
| Conflicting enchantment effect | 1; no live value selected |
| ACA vendor coordinates | 6 disputes; exact pins withheld |
| Other NPC coordinates | 7 disputes; exact pins withheld |
| Stock, teaching, loot, rewards, full prerequisites, build agreement | Claim-specific register remains unverified |
| Whole records independently verified / native client observations | 0 / 0 |

Published tooltip/guide facts remain publication evidence, not independent live
observations. The inherited source-policy restrictions and original evidence
fixtures remain in force; no new upstream research or unapproved imports were
performed for this consolidation. Missing evidence does not prove removal.

Inventory metadata recovery preserves old snapshots where evidence suffices;
unknown factions and contradictory identities remain transparently qualified.
Users must not delete SavedVariables or revisit banks merely to recover a name/
realm already encoded in a sufficient legacy key. Logging into a character can
establish genuinely missing faction; bank contents/timestamps remain untouched
until an actual successful bank scan. See the independent inventory report for
schema, alias and snapshot preservation details.

## Complete source gate

Commands use the established pinned Lua 5.1 and 5.4 toolchains outside the checkout:

```sh
python3 tools/reconcile_presentation_snapshot.py --verify-only
python3 tools/validate_recommendations.py \
  --output /workspace/artifacts/cumulative-review-20261125/source-validation \
  --lua51 /workspace/toolchains/lua51/usr/bin/lua5.1 \
  --luac51 /workspace/toolchains/lua51/usr/bin/luac5.1
```

Result: **205 checks, 32 runtime modules, all 54 Lua suites on each interpreter,
zero failures**. The source validation summary is committed alongside this report;
complete checks/logs remain external. This includes every gameplay suite,
packaging/release tests, source-policy negative cases, generated policy/data
reproduction, catalogue integrity, UI state matrices, inventory migration/
serialization, item search and quantities, stars, slots, nine-class contexts,
source alternatives, map/navigation geometry, pooling and event budgets.

The combined real TOC inventory UI test exercises 180 immediate scope changes
with zero container/snapshot/recommendation/material rebuild calls. The commerce
matrix covers 414 recorded commerce routes and 12,960 class/level/slot contexts.
The source gate retains all historical acquisition audits and snapshot checks.

## Performance and catalogue receipts

The comparative overlay benchmark uses the pinned production baseline and an
identical six-context workload, three paired repeats on each interpreter:

```sh
python3 tools/benchmark_overlay_idle_groups.py \
  --baseline-root /workspace/artifacts/cumulative-review-20261125/production-baseline \
  --output /workspace/artifacts/cumulative-review-20261125/overlay-performance \
  --lua51 /workspace/toolchains/lua51/usr/bin/lua5.1 \
  --lua54 /workspace/toolchains/lua54/usr/bin/lua5.4 --repeats 3
```

The runner verifies the baseline's own committed TOC/modules rather than requiring
new policy modules to exist in older production. Full combined regressions retain
zero redundant unchanged-map/combat work, zero idle overlay frame callbacks,
validated model reuse for pages/slots, fixed event deadlines and frame pooling.
No new polling, per-frame processing, inventory collection on scope changes or
movement/loot-driven catalogue scans were introduced by the integration.

The inventory workload repeats 200 scope switches over 50 characters/50 item IDs,
plus 36-event bursts with UI hidden/overlay/detail and material-summary timing,
three paired repeats per interpreter against the prior cumulative inventory
baseline. Raw records, timing medians, operation counts and qualifications are
included in the final delivery. CPU/heap observations use synthetic frames on a
shared host; they are not native frame latency or proof of eliminated hitching.

An additional offline catalogue audit re-evaluates the combined runtime export
against the already retained published receipts, writing outside the checkout.
It does not fetch research endpoints or rewrite the original evidence. Its
counts and contradictions are compared with the reviewed research ledger.

## Completed performance and catalogue results

All 12 paired overlay runs completed: three baseline/combined repeats for each
Lua version, six class/level contexts and six workloads. All 36 context/workload
cases per interpreter retain the tested operation budgets. Across the six
contexts, the combined unchanged-map, combat, idle-frame and closed-window
workloads each produce zero refresh/evaluation/composition/material/comparison
calls. Page actions render entering rows but perform zero recommendation or
material enumeration; slot actions reuse the model and do no such enumeration.
Those presentation actions still perform row comparisons, as the raw logs show.

Inventory results (50 characters, 50 item IDs, 200 switches; three paired repeats):

| Lua | Baseline per scope | Combined per scope | Difference | Combined initialization |
| --- | --- | --- | --- | --- |
| 5.4 | 1.642 ms | 1.824 ms | +0.182 ms | 5.590 ms |
| 5.1 | 1.933 ms | 2.168 ms | +0.235 ms | 6.528 ms |

All 200-switch runs perform zero container reads. The 180-click combined UI
fixture additionally proves zero bag/bank snapshots, recommendation and material
rebuilds. Metadata reconciliation is an initialization-only O(character-count
squared) pass; scope changes do not repeat it. Material-summary normalization
also has a measured cost, recorded in performance-summary.json; compact material
rows do not request those account summaries except on hover. Timings and heap
values remain qualified synthetic observations on a shared host.

Repeated 36-event inventory bursts preserve one coalesced bag snapshot with
both windows closed, overlay-only and detail+overlay. Hidden windows perform
zero recommendation enumeration. No per-frame callback or continuous polling
was added. Raw operation counts and timing medians are retained together.

The extra offline catalogue audit completed. Its catalogue CSV and contradiction
list exactly match the reviewed research checkpoint, and all critical coverage
counts match: 7,707 items inventoried, 7,615 usable item responses, 30 name and
three level corrections, 1,222 exact published material joins, zero matched
material disagreements. Unresolved counts and zero native-client observations
remain unchanged. The combined audit adopts no new source facts.

## Mandatory delivery gate and live acceptance

The unchanged `tools/release/build_test_package.py --remote-branch` gate requires
clean committed exact GitHub source, current production/historical ancestry,
feature acceptance and committed packaging inputs. It exports that commit,
builds/extracts the installation payload, repeats the complete Lua 5.1/5.4 gate,
checks source-byte identity and rechecks remote refs before exposing the ZIP.
No manual ZIP or historical release workflow substitutes for that gate.

The delivery must keep ZIP, BUILD_INFO, PACKAGE_MANIFEST, SHA256SUMS, ZIP checksum,
changelog, validation receipts, remote proof and CI receipt together. Actual
Forever acceptance remains pending:

1. Exit the client; back up addon and SavedVariables. Install the complete new
   ZIP and verify this private version plus BUILD_INFO source SHA.
2. Before bank visits, verify retained same-realm/faction inventories and dates.
   Cycle every scope, search name/ID and check quantities and locations. Unknown
   identities remain in explicit reference scopes; do not reset saved data.
3. Switch characters, reload/restart, collect with both windows closed and
   logout with a bank open. Confirm identity, snapshots and saved settings/stars.
4. Check corrected names/levels/quests and representative commerce recipes,
   especially Prefect's Waistguard. Alliance text and map choices must use valid
   ACA services; neutral/shared alternatives and known learned recipes survive.
5. Confirm skill disputes and unsupported precise pins remain qualified; collect
   actual client evidence for unresolved stock/teaching/coordinates/loot.
6. Exercise All/Starred/Other, independent pages, slots, stat priorities, bag and
   material planning, maps and resize behavior. Compare matched movement/loot/
   gathering routes with tracker open/closed; retain existing perf captures.

No public release or merge into main is authorized until the owner completes
in-game testing and explicitly approves it.

## Remote delivery status at this checkpoint

The owner explicitly authorized the 19-file inventory upload, which succeeded;
its independent commit and successful CI are recorded above. The cumulative
source-tree operation was rejected twice by automatic approval review. The
reviewer interprets that explicit authorization as limited to the inventory
files, and requires additional explicit public-upload authorization for the
11 new/changed integration files (merged UI, contract, version/README, benchmark
helper and reports). This remained blocked after anonymous GitHub tree queries
proved the other 111 entries already exist in the public parent commits; no
new catalogue dataset or workflow content was part of the upload.

The exact merged source, complete 205-check receipt, repeated performance runs,
catalogue comparison, changelog and emergency Git bundle/checksum are retained
locally. The remaining approval is for those 11 integration files and creating
`dev/cumulative-inventory-catalogue-20261125` in public `magicaddons/getgear`.
No combined remote commit/CI or private ZIP is claimed. The mandatory remotely
verified packaging gate is unchanged; no manual ZIP substitutes for it. Original
inventory and catalogue source branches remain preserved. No mainline merge,
tag or public release has been performed.
