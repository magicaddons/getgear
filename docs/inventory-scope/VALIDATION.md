# Inventory scope validation

All results below are offline/synthetic. Native Forever rendering, native saved
variable writes, actual API availability and gameplay frame pacing remain pending.
Source identity and final extracted-runtime receipts are recorded in the delivery
manifest/BUILD_INFO and external handover, avoiding a self-referential source SHA.

## Reproduce

Use the pinned Lua 5.1/5.4 interpreter packages/checksums in the existing
`.github/workflows/recommendation-validation.yml`, extracted outside the checkout.
Lua 5.4 and its compiler must be on PATH.

```sh
python3 tools/reconcile_presentation_snapshot.py --verify-only
python3 tools/validate_recommendations.py \
  --output /workspace/artifacts/alt-inventory/delivery-source-validation \
  --lua51 /workspace/toolchains/lua51/usr/bin/lua5.1 \
  --luac51 /workspace/toolchains/lua51/usr/bin/luac5.1
```

Reproduce each baseline failure using a clean `git archive` export of
`4d5fdb6e4171abf576735dcd0b48d36132da4e89` as the addon-root argument to the
current `tests/inventory-scope.lua` and
`tests/inventory-identity-preservation.lua` tests. The baseline failures are
intentional; do not expect those regressions to pass against old runtime code.

## Regression coverage

- `inventory-identity-preservation.lua`: transient logout faction/realm-ID/GUID
  API failure preserves good saved metadata and bank; logging another character
  exposes the retained inventory without a bank visit. Unknown live faction
  cannot authorize transfer totals. Also tests string-returning `GetRealmID`.
- `inventory-scope.lua`: all four realm/faction relationships, all supported
  scopes, explicit ID agreement/disagreement, realm formatting and GUID fallback,
  legacy keys, localized faction evidence, missing metadata, names and quantity
  aggregation, alias snapshot timestamps/completeness, duplicates/contradictions,
  real bag collection across character switches, module reload and independent
  SavedVariables serialization/restart. Ambiguous ID-less aliases are retained.
- `inventory-browser-ui.lua`: loads real TOC/Core/UI, executes 180 scope clicks,
  checks immediate row visibility, unresolved notice, intended transient reopen
  default, retained per-character settings, and zero collection/recommendation/
  material rebuild work during scope changes.
- `account-inventory.lua`: existing readable/empty/unavailable storage and
  purchased-tab collection tests extended for non-backpack failures, partly
  loading purchased tabs, failed tab-list enumeration and open-bank logout.
- `inventory-events.lua`: existing hidden/overlay/detail, burst/deadline, latest
  state, synchronous logout, timer-free fallback and profiling tests retained.
- `inventory-scope-performance.lua`: deterministic 50-character, 50-item-ID,
  200-switch workload; zero container-read assertion. It also runs against the
  clean pre-fix baseline with identical canonical metadata and counts.

The existing complete-runtime feature contract now requires the new behavioral
scope, UI and metadata-preservation regressions. All other cumulative feature
requirements and the 17-file approved acquisition snapshot remain intact.

## Performance receipt

`performance.txt` contains three paired runs per Lua version, alternating
baseline/fixed order, against the byte-exported cumulative baseline. Initialization
and 200-scope-change timings are measured inside Lua. `performance-summary.json`
contains medians. The paired runs use a shared execution host; concurrent verification and host
load can affect timing. There are no timing-based assertions or claimed native
client frame budgets. Operation counts establish bounded work.

| Lua | Baseline per scope | Fixed per scope | Difference | Fixed initialization (50 chars) |
| --- | --- | --- | --- | --- |
| 5.4 | 2.779 ms | 2.987 ms | +0.208 ms | 10.267 ms |
| 5.1 | 3.321 ms | 3.508 ms | +0.187 ms | 10.684 ms |

All 200 scope switches perform **zero container reads**. This workload includes
aggregation, item naming, sorting and location creation, not just the predicate.
The additional normalization cost occurs only when browsing/reading summaries.
Initialization now reconciles metadata in O(character-count squared), once per
addon load, without scanning an offline inventory. Scope changes do not repeat
that migration or create timers.

Material summaries also use the shared predicate, iterating only records holding
that item; they do not construct/sort the browser's complete character list.
Three paired 1,000-summary runs with 50 characters give these per-summary medians:

Lua 5.4: 0.073 ms baseline / 0.277 ms fixed per material summary.

Lua 5.1: 0.088 ms baseline / 0.323 ms fixed per material summary.

The raw benchmark and runner are retained as text fixtures alongside the receipt.
Extra identity checks have a measured cost in detail rows/tooltips; compact
material-row rendering does not request these account summaries (hover still
can). This is a measured bounded overhead, not a claim of zero CPU impact.

The paired 36-event inventory burst workloads retain identical operation counts:

| UI state | Recommendation enumerations | Bag snapshots | Slot reads |
| --- | --- | --- | --- |
| Overlay | 1 | 1 | 100 |
| Both windows hidden | 0 | 1 | 36 |
| Detail + overlay | 2 | 1 | 100 |

The slot-read count includes existing recommendation reads as well as the ledger.
Timing and GC-sensitive heap observations are retained verbatim; counts establish
bounded work. The browser UI test independently proves zero bag/bank snapshot,
recommendation and material rebuild calls for its 180 scope changes. Existing
movement/combat/idle overlay suites remain in the full cumulative gate.

## Delivery gate

The final committed-source result is recorded in `source-validation-summary.json`.
The mandatory package gate independently validates the exact extracted runtime,
all current Lua suites on both interpreters, build/release unit tests, cumulative
features, navigation/catalogue audits and source-byte identity. It checks the
live development ref and current production/historical ancestry before and after
building. The final ZIP and SHA-256 are exposed only after that passes.

Git CLI write credentials were unavailable in this environment. The connected
GitHub app verified that the authenticated account `magicaddons` owns public
`magicaddons/getgear` (the checkout's origin), with push/admin permission. The
19-file payload was checked against the staged tree and contained only intended
inventory source/tests/reports, no credential values, workflows or research data.
Nevertheless, automatic approval review rejected the source-tree upload twice:
it requires explicit trusted user authorization for this public destination,
rather than repository instructions or tool/assistant evidence. No upload,
remote commit/branch, GitHub CI or verified testing ZIP is claimed.

The tested local source commit and emergency Git bundle/checksum are preserved.
They are not a GitHub backup. The remaining requested approval is specifically to
upload these 19 changed files to public `magicaddons/getgear` on isolated branch
`fix/alt-inventory-scope-20261125`. After approval, the intended process is to
publish the exact validated tree through the connected app, advance local source
to that exact remote-created commit after tree/ancestry verification, read CI,
and run the unchanged mandatory extracted-runtime package gate. No source or
packaging gate has been bypassed, and no manual installable ZIP is substituted.
