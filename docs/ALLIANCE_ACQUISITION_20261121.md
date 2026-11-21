# Alliance acquisition correction — private cumulative .14

This correction starts at the newest overlay-polish `.20261121.13` source,
`8c18efa54eaab8a43fb5d5eb8d9c5032707a388e`, which contains public Beta 10,
the immediate star-refresh fixes and the accepted tightened overlay. It includes
canonical `integration/cumulative` at
`685e612896c7297b18594bd28e448a21cac22dec`, original cumulative
`b31e30e92256a00dbb3b75347d77731b52a0f06f`, and all four recovered successors.
The initial workspace's old Beta 7 runtime was not used for this build.

Branch: `fix/alliance-acquisition-20261121`. Version:
`0.14.0-private-cumulative.20261121.14`. No public release, tag, merge, main
change or canonical integration update is authorized/performed by this task.
The private installation package requires in-game acceptance. Implementation
and new acceptance cases concern Alliance; existing Horde behavior is preserved,
without implementing or claiming supported Horde acquisition routes.

## Confirmed causes

1. `routesForCharacter` checked item use, quest class/race/side and vendor
   service-side metadata, but contained no capital/instance access check.
   `sharedSource` treated every dungeon as a shared acquisition route. RFC's
   correctly named/observed dungeon drops therefore passed, despite its entrance
   being inside Orgrimmar. Observed loot proves a source association, not access.
2. `GetAcquisitionRoutePracticality` immediately classified every dungeon as
   practical. Its separate low-level travel heuristic never inspected dungeon
   containment. The show-all setting still called acquisition eligibility, but
   that predicate accepted the dungeon; it was not a stat/layout failure.
3. Some recorded capital vendors have no service-side metadata. Unknown faction
   facts stayed open even where the recorded physical location established that
   the only direct route requires entering an opposing capital.
4. UI composition passed `deferSources=true` when adding saved stars. It skipped
   `GetSearchRestriction(...,true)` and trusted cached displayed stars. Rendered
   rows could say "Unavailable" while the item remained in the actionable list.

The synchronous recommendation snapshot already expires after each calculation;
no persistent recommendation database or stale generated cache caused RFC's
ordinary inclusion. Source correctness and the star display bypass were separate
confirmed defects. Equipability masks and item identities were not the cause.

## Shared correction

`AcquisitionNavigation.lua` now contains a small acquisition-topology policy:
capital affiliations, documented instance containment and the six previously
reviewed battleground reputation affiliations. `supportedSides` enables this
new policy for Alliance only. It is source data, not an item-ID/name blacklist.
RFC containment uses the same published dungeon overview already retained in
the approved source evidence. Instance entrances also participate generically,
so another instance wholly inside a capital needs no item-by-item fix.

The shared route predicate checks each acquisition method independently, before
it can enter recommendations, convenience scoring, source summaries or map
choices. It also covers quest start/turn-in actors, direct locations, vendors,
trainers, containers and explicit reputation offers. A source with multiple
locations remains eligible if any is accessible; its capital location is omitted
from actionable directions/pins. Raw evidence is not edited. A limited fallback
uses explicitly recorded capital/contained-instance destinations on legacy
records when structured routes are absent; it invents no acquisition method.
Recipe drop evidence remains comprehensive, while actionable recipe summaries
and directions project only accessible drop destinations.

Surrounding Horde/contested territory is not excluded. Shadowfang Keep, Wailing
Caverns, Ruins of Lordaeron's exterior Tirisfal approach, neutral Barrens sellers,
shared quests and ordinary Durotar drops retain their existing eligibility.
Travel inconvenience remains a separate relevance decision. Show-all/custom
priorities cannot lift confirmed access/use restrictions. Verified finished BoE
trade or a positively known learned recipe remains an independent alternative;
no auction listing, recipe availability or unknown binding is inferred.

Star composition validates eligibility before adding records, including restored
stars, slot-filtered lists and caller-supplied cached presentation models. It
preserves saved stars so users can remove/review their choices. Successful
eligibility checks can be reused only for immediate reorder of the current
rendered model; a normal composition or general refresh rebuilds those checks.
Nothing is saved to SavedVariables. Star-click reordering retains its existing
source/comparison/material budgets.

## Catalogue-wide audit

`tools/audit_alliance_acquisition.lua` generates
`docs/alliance-acquisition/catalogue-access.csv`. The integrated gate reproduces
and compares it. All 7,707 items and nine class catalogues are inspected.

- 183 item records contain 914 routes rejected by the added capital/reputation
  policy. This counts routes, not unique vendors, and includes existing exclusions.
- 152 of those items retain at least one class-eligible acquisition alternative
  or positively evidenced independent access. The other 31 have no eligible
  Alliance class; 21 were already excluded by existing use/source requirements.
- All 10 newly excluded item IDs are RFC-only records: 14145, 14147, 14148,
  14150, 14151, 272996, 272998, 272999, 273003 and 273007. They remain in the
  reference catalogue. Every RFC route is removed from actionable source choices.
- The existing exhaustive faction audit changes Alliance route counts/class
  eligibility on 34 records. Horde route counts/class eligibility are unchanged.
- 4,095 records lack structured routes. Missing evidence stays uncertain with
  existing unverified labels; it does not prove an accessible farm, faction
  restriction, drop, seller or trade route. Unrecorded prerequisite/service
  restrictions and live Forever availability remain acquisition-data gaps.

The raw 17-file acquisition snapshot, 900 historical candidate holds and item
facts are preserved. Audit CSVs describing runtime behavior are updated; source
snapshots and historical `.9` state-signature fixtures are not rewritten.

## Regression and preservation evidence

New `alliance-acquisition-access.lua` exercises all nine classes at every level
1–60, actual RFC records, source categories, mixed routes/locations, hostile
travel, show-all, preview, earlier/tracker/material views, slots, saved stars,
refresh/reload, source minimums, independent trade/crafting and map selection.
Production UI tests additionally restore an old RFC star without deleting it.
Existing immediate star-toggle budgets remain enforced; the large-wishlist test
now requires eligibility checks for restored stars while bounding expensive
navigation/presentation work to visible rows.

The historical output signature expected RFC in Earlier Gear, so the state
oracle has a separate `.14` fixture. The reviewed changes affect 45 Alliance
class/level contexts; all 54 Horde contexts and all level-1 contexts are identical
to `.9`. The warm-overlay fingerprint changes to 591227800. Workload, allocation,
map, layout and input/event assertions remain active. The exhaustive instance
navigation regression now explicitly asserts that blocked capital instances and
aliases provide no actionable choice, while exercising every accessible entrance.

`UI.lua`, Core, GearRelevance, GearCompare, MapNavigation and all three textures
are byte-identical to `.13`. The feature contract changes only the reviewed
AcquisitionNavigation hash and adds the new regression/API requirements.
No SavedVariables schema change, progress reset or new idle/background job occurs.

Validation commands:

```
python3 tools/reconcile_presentation_snapshot.py --verify-only
python3 tools/validate_recommendations.py --output <external-receipts> --lua51 <lua5.1> --luac51 <luac5.1>
python3 tools/release/build_test_package.py --remote-branch fix/alliance-acquisition-20261121 --output <new-external-delivery> --lua51 <lua5.1> --luac51 <luac5.1>
```

The local integrated gate passed all 185 checks: 29 runtime modules and all 48
Lua suites on each of Lua 5.1 and 5.4, plus build/release/generator/audit checks.
See `alliance-acquisition/validation.json` for the runtime hashes and receipt.

The final delivery's `validation/summary.json`, full checks, build information,
manifest and ZIP checksum are the authoritative receipts for the exact committed
source and extracted runtime. No synthetic test establishes live-client acceptance.

## In-game acceptance

Exit Forever, back up the current GetGear folder and SavedVariables, then replace
GetGear with the supplied complete `.14` folder. Confirm the TOC version, keep
existing progress/settings/stars and reload. Check low-level RFC-only examples in
normal/preview/starred/slot views; a previously saved star must not resurrect one.
Check immediate star/unstar reordering and independent guide/tracker slots.
Verify Shadowfang Keep/Wailing Caverns and a genuine mixed-source item's valid
route, including its map button/directions. Exercise comparison modes, materials,
item tracking, narrow/wide/collapsed overlay states and acquisition markers.
Repeat after reload/relog and an equipment/inventory/source refresh. Live loot,
vendor stock, quest prerequisites and native rendering remain to be accepted.
