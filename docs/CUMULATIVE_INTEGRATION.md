# Cumulative development integration — 18 November 2026

This is a private development integration for owner-requested in-game testing.
It is not a merge into main, a public release, or an acquisition-data refresh.

## Confirmed cause

The delivered `GetGear-work-slot-filtering-2026-11-18.zip` has SHA-256
`f8b7b2163215179c52bd9481abdede5b10a255c5cea9b56c202fe5efa632f9cb`.
Its extracted files exactly match the slot-filtering implementation over the
older main/work runtime at `4ba2a850c4e3933b85f40c82a50b98314f117d80`.
It contains 18 runtime modules, while the pinned Beta9 archive has 26 and the
latest settings development baseline has 29. This confirms a baseline-selection
regression, rather than an interaction caused by selecting a slot.

Main had accepted release tooling and the immutable Beta9 ZIP, but its top-level
runtime files still predated that accepted gameplay source. Packaging all files
from that old TOC made an internally complete but non-cumulative addon. The 11
Lua tests that accompanied it could pass because that checkout also lacked the
newer settings, material-name, source, bag and stat-priority regression suites.
No feature acceptance comparison was performed before calling it complete.
This was a development/build-integration failure.

The material failure has a separate concrete mechanism: old `Materials.lua`
indexed `GetGear.Gear` during module load, while that character-specific list was
still empty. Reagent names already present in `ItemCatalog` never reached the
name index, and aggregate/nested rows fell back to `Item <ID>`.

## Baselines inspected

- Actual old test ZIP, including byte/hash verification, not just its filename.
- Original dirty `work` tree, including paused navigation changes.
- Pinned immutable Beta9 ZIP/source `04992876bd4f50b66d6b6dd78d00b32cd0594cd3`.
- `recommendation-sources-stat-priorities` at
  `ffd60c0c3c658ecff9dbabc09c442b4182955bf5`.
- `settings-ui-refinement` at
  `3e590ae438b2064bea756d40356ee5bc5c1205d4`, seven commits ahead of the stat branch
  and 18 ahead of accepted Beta9. Every file downloaded for this baseline was
  verified against its Git blob hash (1,709 files).
- Positive-stat, green-BoE, acquisition reconciliation, comparison-cleanup and
  `dev/recommendation-pipeline` branch ancestry/implementation intent.

`docs/CUMULATIVE_BRANCH_AUDIT.json` records pinned revisions and ancestry.
The older positive-stat branch diverges, but the accepted integration checkpoint
explicitly records its shared overlay rule as ported. The independent pipeline
branch is a competing three-commit implementation from Beta9, with different
priority preference keys, weights and bag-policy modules. Its requested feature
areas are covered by the later accepted stat/settings implementation; importing
both backends would change approved semantics and is not part of this repair.
Comparison-cleanup functionality is assessed through the accepted comparison
implementation and its class/stat tests, not by merging an older curated engine.

## Feature comparison

| Capability | Old slot ZIP / old main runtime | Pinned Beta9 | Stat-priority branch | Settings baseline | Cumulative build |
| --- | --- | --- | --- | --- | --- |
| Runtime modules | 18 | 26 | 28 | 29 | 29 |
| Independent character slot selectors | Yes | No | No | No | Yes |
| Armour-only checkbox, default off | Missing | Yes | Yes | Yes | Yes |
| Positive-stat / green-world-BoE toggles | Missing | Yes | Yes | Yes | Yes |
| Balanced / Priority / Advanced backend | Missing | Missing | Yes | Yes | Yes |
| Direct Advanced weight grid / alphabetical settings | Missing | Missing | Older controls | Yes | Yes |
| Canonical catalogue reagent-name indexing | Missing | Yes | Yes | Yes | Yes, shared across all paths |
| Independent quest-bag alternatives | Missing | Missing | Yes | Yes | Yes |
| Shared item/source faction eligibility | Older/partial | Earlier navigation model | Source-aware | Global evidence overlay | Preserved |
| All-nine-class talent orientation / practicality | Mage-only / older rules | Earlier rules | Earlier rules | Yes | Preserved |
| Measured wrapped tracker name/level headers | Earlier layout | Earlier layout | Earlier layout | Yes | Preserved |
| Completed acquisition/stat evidence modules | Missing | Yes | Yes | Yes | Preserved |
| Current paused navigation experiment | Not included | Not applicable | Not applicable | Not included | Excluded and preserved separately |

## Integration and preservation

Work is isolated in `/workspace/getgear-integrated`, branch
`integration/cumulative-slot-filtering`, based on the pinned settings revision.
The original `/workspace/getgear` worktree is retained without modifying any of
its 80 preserved files. Its complete tar snapshot, tracked patch and SHA-256
manifest are under
`/workspace/preserved/getgear-before-cumulative-integration-2026-11-18/`.
The paused marker/resolver experiment, generated navigation evidence, generator
and bag source supplements remain there; none is adopted by this integration.

Slots were ported surgically from the tested ZIP into Core, GuideState and the
newer UI. Overlaps retain every existing stat, BoE and acquisition filter before
applying the slot presentation filter and computing totals. Detected talent
context remains visible for all classes. The accepted Advanced settings section,
wrapped row-header implementation, acquisition renderer and navigation source
modules remain intact. Preferences stay in schema4; no weight/progress reset is
introduced. The accepted 17-file acquisition snapshot is unchanged.

## Material names

`IndexMaterialNames` reads the complete canonical catalogue before guide
selection. A single `MaterialName` resolver serves recipe planning, nested
conversions, aggregate totals, bag recipes, visible labels and material tooltips.
Names carried by late/generated recipe rows are registered without changing
quantities or catalogue data. Blank/placeholder names cannot replace valid
names. No hardcoded Bronze Bar or Coarse Grinding Stone exception was added.

Known names resolve before any client cache query. Unknown names may request
item data through the existing once-per-ID/debounced refresh mechanism. A
placeholder is never cached as a real name; a genuine later item-data result can
resolve it. Tests compare all 262 unique canonical ingredient IDs to their known
names across 1,254 recipes / 4,857 ingredient occurrences, plus nested, aggregate,
bag, tooltip and late/cache-event cases.

## Permanent build protection

- `FEATURE_ACCEPTANCE.json` is the version-controlled cumulative contract:
  required modules/load order, ten feature groups and their functional suites.
- `tools/validate_feature_acceptance.py` rejects missing backends, settings,
  Advanced grid, slot controls, dependencies and unsafe ZIP contents. It also
  pins accepted navigation files/section so the paused experiment cannot leak
  into this build without an explicit reviewed contract change.
- `tools/release/build_test_package.py` requires a clean source revision and a
  distinct private TOC identity. It builds a candidate, extracts it, validates
  source-byte identity and runs the full integrated gate against extracted Lua
  modules. Only a passing candidate becomes the final installable ZIP. Test
  fixtures remain external; development files are not installed.
- The public packaging validator requires this contract for future releases;
  the existing byte-pinned historical Beta9 artifact remains immutable.
- The read-only recommendation CI includes the integration branch and contract
  paths, and uses the approved acquisition snapshot rather than adopting drift.
  No new remote CI, release workflow or branch publication is claimed here.
- Ten build unit cases deliberately remove settings/backends/grid/slots, add
  unsafe files, omit dependencies or change unreviewed navigation. The old test
  ZIP is rejected for its eleven missing cumulative runtime modules.

Use the reviewed build tool for every future test build. Removing an accepted
feature requires explicit owner approval and a documented contract/test update;
passing syntax or an unrelated historical test suite is not sufficient.

## Verification and in-game acceptance

The build writes exact commands, outcomes, source revision, payload hashes and
ZIP SHA-256 outside the checkout in its artifact directory. No actual WoW client
is available; synthetic frames and API mocks do not establish native rendering,
SavedVariables behavior on a real client, item-cache timing or live acquisitions.

The slot integration matrix uses all catalogue records/target levels and 126
real-engine class/faction/boundary-level contexts (1,15,30,39,40,45,60), alongside
the accepted full source/faction/talent suites. The original all-60-level stress
test repeatedly recalculated immutable acquisition routes and exceeded this
baseline's CI workload budget; its original copy remains in the preservation
snapshot. A first candidate validation was stopped for this test-workload
adjustment, before producing any final ZIP. No implementation was weakened to
make tests pass. Only the subsequent complete gate is reported as passing.

1. Exit Forever, back up/move the old GetGear folder outside AddOns, retain WTF,
   and extract the new ZIP to `Interface/AddOns/GetGear/GetGear.toc`.
2. Verify the private cumulative version in the AddOns list/TOC and BUILD_INFO.
   Do not use the superseded slot-only ZIP for this acceptance pass.
3. Check all nine sorted display checkboxes and saved defaults. On Warrior,
   verify armour-only gains disappear when the opt-in is off and appear when on;
   verify positive-stat and green-world-BoE switches still act independently.
4. Exercise Balanced, Priority and Advanced, several custom fields, validation,
   mode changes, close/reopen, reload, relog and another character.
5. Check Bronze Bar, Coarse Grinding Stone and other direct/nested/aggregate/bag
   materials and tooltips with a cold item cache, including later cache updates.
6. Select different slots in overlay and guide; check counts after existing
   filters, All Slots restoration, Hidden/Completed/Preview/Bags and scrolling.
7. Check wrapped/minimized names, map/source alternatives, bag capacity, crafting,
   talent and faction behavior against the accepted build. Navigation experiments
   remain a separate review; do not infer their acceptance from this ZIP.
