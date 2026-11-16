# Settings UI refinement — 16 November 2026

Branch: `settings-ui-refinement`, based on
`recommendation-sources-stat-priorities` at
`ffd60c0c3c658ecff9dbabc09c442b4182955bf5`.

## Changes

- All nine display checkboxes sort case-insensitively by their complete visible
  labels. Registration in `NewCheck` automatically re-sorts the collection;
  callbacks, tooltips, keys, defaults and saved values remain attached to the
  original controls. Sliders and the material-scope/toggle buttons remain separate.
- Three direct mode buttons read **Balanced**, **Priority**, **Advanced**.
  Internal identifiers remain `balanced`, `priority`, `custom`. One concise
  description appears for the current mode. No `(click)` suffix remains.
- Advanced displays every class-supported weight at once in a two-column grid,
  using the existing definitions/defaults/range. There are28 possible fields;
  unsupported class attributes stay hidden, as in the previous selector.
  Each supported stat has its own labelled numeric edit box. There is no stat
  selector or separate Apply step in Advanced. Priority retains its stat choice.
- A field saves through the existing `SetCustomStatWeight` API on Enter or focus
  loss. Pending valid edits also save before mode changes, close or reopen.
  Invalid/empty/nonfinite/out-of-range values leave saved weights untouched and
  display an inline error/red text; Escape restores the last saved value for
  that field. Other fields are not overwritten. Reset uses the unchanged
  `ResetStatPriorities` API and preserves unrelated preferences/progress.
- Input ownership is associated with the current character DB. A delayed focus
  event from the previous character cannot write into the new character's
  weights. Rendering and programmatic field refreshes do not save weights.
- The current maximum28-field grid fits a325x420 viewport with14 rows. The
  container can scroll if definitions grow. The780x692 settings window centres,
  clamps and scales down to the available UIParent area with a24-unit margin;
  resolution/UI-scale events update an open window. Other windows' scale and
  layout are unchanged.

Display checkbox order:

1. Count armour-only improvements
2. Filter clearly outclassed earlier gear
3. Hide crafted gear I can't make
4. Hide gear without positive stat changes
5. Hide green BoE world drops from tracker
6. Hide tracker automatically during combat
7. Lock overlay position
8. Recommend ordinary bag upgrades
9. Show all valid equipment (including off-spec)

## Scope and affected files

Production changes are confined to the Display Settings section of `UI.lua`.
The other27 Lua modules, TOC, saved-variable schema, source/recipe/stat/bag data,
map renderer, recommendation calculations and guide/overlay code outside that
settings section are byte-exact to the base commit.

`tests/stat-priority-settings.lua` executes the real complete settings section
with synthetic frames and real Core/preference helpers. It checks visible
sorting, each callback/key/refresh behavior, future checkbox registration,
mode labels/descriptions/visibility, all fields for nine classes and the full28
definitions, independent edits, numerical boundaries, focus/Enter/Escape,
mode/close/reopen/character transitions, defaults reset and12 resolution/scale
combinations. Source regressions continue testing scores, eligibility, sources
and bags. The existing non-release workflow also runs for this branch.

Affected files: `UI.lua`, `tests/stat-priority-settings.lua`,
`.github/workflows/recommendation-validation.yml`, `AGENTS.md`, this report and
the existing progress/release-gate documentation plus validation receipts.
There is no implementation change in `StatPriorities.lua`, `GearCompare.lua`,
`GearRelevance.lua`, `GuideState.lua`, `BagUpgrades.lua` or the source resolver.

## Validation

Focused settings tests and Lua5.1/5.4 syntax checks passed during implementation.
The integrated local gate passed all115 commands: syntax for28 modules and
two tools on Lua5.1/5.4, all23 Lua suites on both versions, four offline Python
suites, source/presentation/bag audits and20 mocked release-safety tests.
Detailed command receipts are in [local-checks.txt](settings-ui-validation/local-checks.txt);
final local/CI metadata is in [settings-ui-validation.json](settings-ui-validation.json). Fresh reconciliation is
diagnostic only: the accepted17-file acquisition snapshot is restored exactly;
no fresh source facts or held candidates are adopted.

The local fresh diagnostic **failed** the unchanged ingestion guard requiring
at least137 trash-source records. Current upstream data yielded136, with one
record, Defias Rapier (#1925), instead classified dungeon-enemy/unresolved.
The role/confidence comparison also found19 confidence-only changes; its
[unadopted diagnostic](settings-ui-validation/unadopted-role-confidence-diff.json)
and [failure receipt](settings-ui-validation/fresh-diagnostic.json) remain separate
from the accepted catalogue. The wrapper restored every
approved file exactly. This unrelated source-data refresh is not a successful
validation result and is not repaired or adopted in this UI task. This UI
branch's CI uses `--verify-only` to require the approved snapshot instead; the
original source branch retains its full fresh-reconciliation gate. The full
recommendation suite still runs, including all source/eligibility/bag tests.

Automated layout checks use frame geometry, not actual Forever text rendering.
In-game inspection must check font wrapping, text cursors, native scrollbar/
focus behavior, screen fit and other-addon interactions at the user's scale.
No actual-client acceptance is claimed. Existing Beta9 and the prior private
test ZIP remain untouched; no new addon package or release is produced.

## In-game acceptance after a separately authorized test build

1. Open `/getgear settings`. Confirm the nine checkboxes are A–Z, show their
   saved states and still control the corresponding behavior.
2. Select Balanced, Priority and Advanced directly. Check the short description
   changes and Priority's selected stat remains independent of Advanced weights.
3. In Advanced, edit several visible fields with Enter and by clicking another
   field. Try0,1000, a decimal, empty text, a negative and1000.1; invalid edits
   must leave the prior weight intact. Check labels/cursors are not clipped.
4. Change modes, close/reopen, `/reload` and log into another character. Check
   each character's entire weight configuration survives. Reset defaults must
   preserve progress and display preferences.
5. At common UI scales/resolutions, inspect both columns, the bottom controls
   and error text. Verify guide/overlay comparisons, bags and faction sources
   still behave as in the accepted implementation.
