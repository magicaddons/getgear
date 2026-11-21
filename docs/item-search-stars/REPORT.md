# Equipment search and character stars — private cumulative .11

Implementation starts at verified `.10` `d608838d049802e191e763ab32078116bc09a797`.
The live canonical `integration/cumulative` was `685e612896c7297b18594bd28e448a21cac22dec`,
which is an ancestor of this branch, including the original cumulative commit
and all four required recovery corrections. The `.10` baseline passed its
complete 175-check gate, 44 gameplay Lua suites on each interpreter and the
protected 17-file acquisition snapshot. Work stays on the isolated
`feature/item-search-stars-20261121` branch.

## Behavior and boundaries

The tracker header's magnifier opens a dismissible search panel. Search indexes
all locally catalogued names once, uses one-, two- and three-character inverted
buckets, chooses the smallest relevant bucket and verifies literal substrings.
It keeps at most twelve ranked matches internally and displays six. Ranking is
exact, prefix, then substring; normalized name and item ID break ties. Typing,
including backspacing, never reconstructs the catalogue or resolves remote names.
Autocomplete checks metadata, class proficiency and faction/race use constraints;
source routes and stat comparisons run only on selection or explicit starring.
Restricted matches are labelled and selection explains the restriction.

Enter selects, unmodified up/down choose suggestions, and Escape dismisses.
Selection uses the stable item ID and opens a highlighted card for that item's
slot. This separate focused-item presentation also handles entries omitted by
normal level, relevance and positive-stat filters. It has the existing source
summary, comparison, map control when supported, star and progress actions.
Highlight fades after six seconds; the card persists until dismissal or a new
query. Focus does not write either saved slot selection or any display filter.
The card uses a scrollable body to retain long acquisition text at fixed height.

Filled and outline stars in guide, tracker, suggestions and focused card all use
`GetGear_CharacterDB.starredItems[numericItemID] = true`. Unstar removes the key.
Existing schema-4 settings, status and hidden tables remain intact; missing or
malformed new star storage initializes independently. The account DB is untouched.
There are no duplicated item records or separate view-specific star stores.

| Item condition | Active wishlist | Search / history behavior |
| --- | --- | --- |
| Future or outside the lookback window | Visible, level-labelled | Search focus retains actual effective acquisition level |
| Nonpreferred armour, talent/stat relevance, not a positive upgrade | Visible as a player preference | Comparison and scoring remain unchanged |
| Overlay green-BoE / personal-craft / practical-travel display filter | Wishlist remains accessible | Existing acquisition requirements and uncertainty labels remain authoritative |
| Confirmed class, faction or race use restriction | Excluded | Labelled restricted, starring rejected; existing star can be removed in results |
| Missing class objective or incomplete name/slot/level metadata | Excluded | Search labels limitation; selection/starring rejected |
| Hidden | Excluded | Remains in Hidden; search can star/unstar and restore |
| Skipped or manually acquired | Excluded | Remains in Completed/Skipped; search can star/unstar and undo |
| Equipped | Excluded | Existing Completed behavior retained; search labels Equipped |
| Owned unequipped in personal bags | Existing recommendation/wishlist behavior retained | Search labels bag ownership; no automatic acquired status |
| Acquisition route becomes unavailable after starring | Visible only as a labelled unavailable wishlist entry | No acquisition pin; source details retain existing eligibility explanation |
| Unknown acquisition evidence | Existing uncertain-source behavior retained | No invented availability or missing-data claim |
| Preview, including another class | Read-only | Stars display this character's existing state; every Preview star mutation is rejected |

Stars are prepended to ordinary lists without changing `GetItems`, weighted
scores, stat preferences, item definitions or material aggregation. Starred
items sort by equip requirement, slot, normalized name and ID. Ordinary
recommendation order is retained exactly. History only sorts stars already in
that history category; it does not inject other starred items. Dedicated Bags
planning is unchanged. A single ID produces one All Slots row. Slot membership
continues to use the established multi-hand compatibility logic.

The tracker renders at most 32 objectives and the guide at most 40 per page.
Tracker arrows reach all pages; Other jumps to the page containing the first
ordinary recommendation. Group headings identify stars and ordinary rows.
All Slots and independent saved slot selections still filter the combined list.
Changing slots never writes star state. Scrolling, resizing and material-section
layout remain the existing implementations.

## Performance and regression evidence

No new frame polling, service, external library, recommendation cache, event or
debounce interval is introduced. The name index is session metadata, initialized
on first search/star use. Normal no-star refreshes do not construct it.

The visible UI retains its existing ordinary list as a presentation model. An
explicit star click alone reorders that model and existing measured row frames,
renders only newly entering rows, and skips aggregate materials/unknown-recipe
work. Every normal inventory, equipment, quest, level, talent, settings or other
refresh rebuilds the underlying list through the original calculation path.
This model is never consulted by `GetItems` or any ordinary refresh. The entire
star action shares `.10`'s synchronous calculation scope; no derived results
survive that scope.

For large wishlists, metadata/use eligibility and deterministic sorting cover
all saved IDs, but detailed source/quest-minimum calculations run only for the
visible page. Equipped IDs are read once per composition where APIs permit,
rather than rescanning inventory for every star. Saved source-only restrictions
are communicated as unavailable wishlist entries. This avoids thousands of
unnecessary source calculations for off-page stars. Hidden and progress state
are always read live.

New regressions execute search ranking, duplicate identities, incomplete metadata,
class/faction restrictions, future focus, ordering, persistence and ownership.
The real catalogue is queried across all nine classes and both factions with
zero autocomplete source queries. Production TOC/Core/UI tests execute actual
search and star callbacks, focus progress actions, keyboard dismissal, both
views, large wishlists, paging and Other navigation, Preview, reload/character
switching, and hidden-window inventory/gathering events. Eighty repeated toggles
retain bounded row pools and perform no GetItems, aggregate-material or unknown-
recipe calls. Existing rows retain their measured acquisition/comparison/material
presentation; only entering rows require construction.

`tools/benchmark_item_search_stars.py` compares the same fourteen production
workloads against independently verified `.10` Git objects in three interleaved
runs per Lua version. It enforces identical calculation counts and the accepted
recommendation/material fingerprints; text writes additionally update stars.
Raw CPU/heap samples and final comparison accompany the validation delivery.
The earlier frozen-runtime `timing-investigation.json` retains the slower
separate-process comparison that prompted the paired investigation. These
separate-process timings showed substantial host variation, including isolated
samples more than twice their neighboring samples. To investigate, the paired
runner alternated nine batches of ten old/new refreshes inside each interpreter,
with separate addon environments and the same frame/inventory fixtures. The
expanded/collapsed median differences were +0.19% / -4.83% on Lua 5.1 and
+2.56% / +4.30% on Lua 5.4. Source calculations stayed identical. This supports
a small presentation cost rather than renewed acquisition calculations; it
is not a promise of equivalent client frame pacing. Existing operation/heap
budgets remain intact. First opening the guide creates exactly forty additional
star-button frames, one per bounded guide row; warmed refreshes create zero.
`benchmark_paired_overlay.lua` and the full comparison logs preserve both
measurements rather than dropping the noisier scenario data.
These measurements are synthetic, not WoW Forever frame latency or FPS results.

Final full-gate, exact-commit CI, checksum and extracted-runtime package receipts
are recorded in the delivery handover. Gameplay acceptance remains with the
owner: search/focus, stars through reload and character switching, actual font
and icon rendering, narrow/wide tracker layout, acquisition/maps and overlay
responsiveness while moving, looting and mining with the normal addon set.

The final frozen-runtime three-repeat comparison is `benchmark-comparison.json`.
Its per-file feature hashes exactly match the delivered runtime; all 26 unchanged
modules are listed in `PRESERVATION.json`. The original `.10` scenario fixture
and fixed recommendation/material signature remain unchanged. Final delivery
retains the twelve raw scenario logs and both paired investigation logs.

## Implementation checkpoint validation

The complete local gate passed **179 checks**, including **46 Lua gameplay
suites on each of Lua 5.1 and 5.4**, all manifest syntax checks, 79 build-tool
unit tests, release-workflow tests, generated-data/source audits and navigation
coverage. `validation-summary.json` records the aggregate result. The approved
17-file acquisition snapshot is exact. `git diff --check` also passed.

Reproduction commands:

```sh
python3 tools/validate_recommendations.py --output /outside/source/validation --lua51 /path/to/lua5.1 --luac51 /path/to/luac5.1
python3 tools/reconcile_presentation_snapshot.py --verify-only
python3 tools/benchmark_item_search_stars.py --baseline /verified/dot10 --lua51 /path/to/lua5.1 --lua54 /path/to/lua5.4 --output /outside/source/benchmark
lua5.4 tools/benchmark_paired_overlay.lua /verified/dot10 .
```

Run the paired Lua 5.1 measurement with the same string/environment `load`
adapter used by `tools/release/lua51-harness.lua`, passing both runtime roots.
Final source SHA, exact remote/CI evidence and the gated package checksum live
in the delivery receipt, avoiding a self-referential committed SHA.
