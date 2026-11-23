# Overlay event work and independent recommendation groups

Private cumulative testing build: `0.14.0-private.overlay-groups.20261123.1`.
Development branch: `dev/overlay-idle-groups-20261123`.
Production baseline: `de1037a8a20593430d1c27e123685980d6da909b` (Beta 11).
Historical remote recovery anchor at investigation: `685e612896c7297b18594bd28e448a21cac22dec`.
All five required cumulative commits through `e61c16c1a136d3972b0af5b18821ceec1a2239f7`
remain ancestors of production and this development branch. No public release,
tag, merge or production-branch update is authorized or performed.

## Confirmed mechanisms and changes

1. Core previously dispatched a complete `RefreshAll` for every `ZONE_CHANGED`
   and `ZONE_CHANGED_NEW_AREA`, including repeated events whose player-map ID
   and map name were unchanged. Open-window refreshes reevaluated catalogue
   eligibility, comparisons, acquisition convenience and aggregate materials.
   The synchronous recommendation snapshot helped within each refresh but was
   correctly discarded at its end, so it could not eliminate repeated refreshes.
   Core now compares the scalar location inputs used by travel rules. Real
   map/name changes still refresh immediately; unavailable map transitions are
   distinct, and failed/secret API reads are retried rather than cached as fact.
   Equipment, inventory, talent, quest, profession, item-data and settings
   invalidation retain their established paths. There is no new polling/debounce.
2. Both combat transitions previously called `RefreshOverlay`, even when the
   tracker was configured to remain visible. Those events now affect visibility
   only when automatic combat hiding is enabled. Hiding does no evaluation;
   returning from combat performs a full refresh, including changes received
   while the tracker was hidden.
3. Every previous/next page click and slot-menu click called a full refresh.
   Explicit presentation actions now reuse the last validated recommendation
   model and existing star-only row reuse. Page/group navigation uses the already
   composed, slot-filtered groups; slot changes repartition the validated model.
   These actions do not call `GetItems` or reconstruct aggregate materials.
   Entering visible rows still resolve their current descriptions, comparison,
   acquisition and ingredient presentation; they are not falsely counted as
   zero-cost navigation. Full gameplay/direct refreshes always rebuild models.
4. The shared resize grip had an `OnUpdate` callback whenever its parent was
   visible, even when not resizing. It now installs the fallback callback only
   while dragging, and removes it on mouse-up, lost mouse-up or hiding. This
   removes the idle overlay callback; the old callback was cheap and is not
   presented as a proven cause of perceptible hitching.

No equipment, eligibility or acquisition rule was changed. The approved 17-file
acquisition snapshot and pinned map/navigation renderer remain byte-identical.
Map actions and hover resolve targets on demand, so source selection continues to
use the current player position. The map readiness driver's existing bounded
polling/lifecycle is unchanged. Row and material objects remain pooled; expensive
snapshots remain synchronous rather than becoming stale gameplay caches.

These are confirmed redundant-work mechanisms and synthetic reductions. It is
not confirmed which mechanism dominates the reported Forever movement hitch.
Native rendering cost, real event rates (especially quest/inventory/item-data
bursts), CPU scheduling and client GC remain live-client hypotheses. A full
relevant-input refresh still has a measurable cost. No claim that live hitching
has been eliminated follows from the offline tests.

## Navigation

The compact menu beside the page arrows displays **All**, **Starred** or
**Other**. All is the normal initial view and retains the approved starred-first
ordering. Starred contains only eligible starred records from the existing
wishlist composition; Other contains the remaining eligible recommendations.
There is no destination-page calculation based on the number of stars.

Each view remembers its own page, clamps it when membership shrinks, and shows
page position when more than one page exists. A slot change resets all group
pages to the first page and applies the same slot rule to both groups. Group
switches reset the scroll offset; existing slot-scroll retention is preserved.
Starring/unstarring immediately repartitions the groups without changing the
active group. The existing new-star jump to the first page is retained. Empty
Starred/Other groups have explicit messages, including slot-specific wording.

The group button fits in the existing header at the minimum 320px overlay
width. No new header row or enlargement is introduced. Materials continue to
represent the established material scope, independently of the selected group.
Group and page choices are session presentation state; saved stars, preferences
and progress retain their schema and keys.

## Reproduction and profiling

The production TOC, Core and UI run against stateful frames and deterministic
events in `tests/overlay-idle-groups.lua`. The matrix covers Night Elf Warrior
27, Tauren Druid 23, Human Priest 31, Undead Mage 60, Orc Shaman 45 and Night Elf
Hunter 15. Horde cases are defensive regressions, not a new supported gameplay
claim. The existing full suite additionally covers all nine classes and original
faction-valid combinations.

For each matrix context, measure 40 unchanged-map notifications, 40 combat
transitions, 3,600 idle frame ticks, 20 page clicks, three slot choices and
40 notifications with the tracker closed. Record refresh/evaluation/composition/
material/comparison counts, CPU time and GC-paused Lua heap growth. The boundary
models use 54/120 real, source-eligible catalogue records and
0/1/31/32/33/54 stars. They assert both group partitions, independent pages,
empty states, immediate transfers and all slot choices. Real recommendation
models separately exercise hidden, acquired and skipped exclusion.

Reproduce the before/after benchmark using a clean export of the baseline:

```sh
git archive de1037a8a20593430d1c27e123685980d6da909b | tar -x -C /path/to/baseline
python tools/benchmark_overlay_idle_groups.py \
  --baseline-root /path/to/baseline --output /path/to/new-receipts \
  --lua51 /path/to/lua5.1 --lua54 /path/to/lua5.4 --repeats 3
```

The runner checks baseline runtime bytes against the pinned Git objects,
alternates baseline/implementation run order, and retains every raw run plus
`comparison.json`. Timing medians are synthetic observations without timing pass
thresholds. Inclusive method counts overlap. GC-paused growth is a Lua allocation
proxy, not a native client allocation measurement. Idle-loop timing includes
walking mock frames; only callback counts establish the idle-polling change.

Measurement and full-gate results are recorded in the accompanying validation
receipt. Final exact source identity, remote proof, package hashes and extracted
runtime validation are delivered together by the mandatory private-package gate.

## In-game acceptance (pending)

1. Exit Forever. Back up `Interface/AddOns/GetGear` and GetGear SavedVariables.
   Move the old addon folder out of AddOns and install the complete private ZIP.
   Verify the private version in the TOC/AddOns list and `BUILD_INFO.txt`.
2. On the reported level-27 Warrior, repeat the same 60-second outdoor movement
   route with the tracker open and closed, without opening other GetGear windows.
   Use `/getgear perf start` immediately before each route and
   `/getgear perf stop` after it; retain event counts, trigger counts, inclusive
   CPU/max/p95 and heap results. Compare perceived frame pacing and client frame
   timing with capture disabled too, since profiling itself adds overhead.
3. Repeat on another class and level, with few/many recommendations, All Slots
   and restricted slots, materials expanded/collapsed and rows minimized/expanded.
   Unchanged map/subzone movement must not trigger recommendation rebuilds.
   Crossing into a different player map must update travel recommendations at once.
4. Exercise combat with automatic hiding both off and on. Always-visible mode
   must not rebuild simply on entering/leaving combat. Hidden mode must disappear
   promptly and show current data after inventory/equipment changes in combat.
5. Loot/gather, equip/unequip, change talents/stat priorities/settings, update
   quests, learn/drop professions/recipes and resolve cold item data. Confirm
   prompt recommendations, ingredient totals, inventory counts and source changes.
6. With fewer than 32 stars and more than 32 total recommendations, choose Other:
   its first row must be non-starred. Repeat at 31/32/33 stars and multiple pages.
   Switch between Starred/Other and confirm independent pages. Star/unstar an
   item in each group and the guide/search; membership and counts update at once.
   Test empty groups, every slot selector and All restoration. Hidden, acquired,
   skipped, equipped and hard-ineligible records must respect existing rules.
7. Check map buttons, hover/choices, world-map open/close and marker cleanup,
   recipe/material expansions, section splitter, window sizing and lost mouse-up.
   Check the group menu at 320/354/580px and UI scale changes for clipping/collision.
   Reload/relog and another character to confirm saved progress/stars/settings.

Acceptance requires no perceptible new gameplay hitch on the repeated open vs
closed route plus correct immediate state changes. If hitching remains, retain
those captures with the exact build/version and movement/map/quest conditions;
the unresolved native/client cost must be investigated from that evidence.
