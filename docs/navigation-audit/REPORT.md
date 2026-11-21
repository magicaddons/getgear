# Shared acquisition marker audit — 18 November 2026

Owner-authorized follow-up to cumulative build `.20261118.1`, source
`b31e30e92256a00dbb3b75347d77731b52a0f06f`. The new private build identity is
`0.14.0-private-cumulative.20261118.3`. All cumulative features remain required.
No main change, merge, push, release or remote publication is authorized.

## Failure mechanisms and corrections

1. **Marker size inherited map zoom.** The previous standalone frame was a
   normal child of `ScrollContainer.Child`. Forever scales that child during
   map zoom. Native pins compensate using inverse scale and divide anchor
   offsets by their pin scale; GetGear did neither. At a canvas scale of .05,
   its 22px marker could be about 1px wide, including a shrunken label. The
   shared renderer now preserves a 28x32 icon and uses native anchor math for
   both points and published area bounds. Panning follows the canvas; zoom,
   resize, replacement canvases and map-ID transitions refresh through one
   independent driver. Old mocks only used scale 1 and missed this defect.
2. **Readiness and lifecycle.** Updating through the native map's OnUpdate
   hook or the hidden pin's own fallback tied recovery to those surfaces.
   One independent GetGear driver now retries pending placement, including
   a WorldMapFrame that is created only after the native open API returns. It never
   replaces native scripts. Closing hides the pin; reopening on its map
   restores the last selection. Browsing another map hides it. New clicks
   replace the destination; explicit clear/reset removes it. A three-second
   unsuccessful initial draw reports that placement is unconfirmed and shows
   written directions, retaining the pending target for later readiness.
3. **Deviate Hide Pack starter lost in generation.** The frozen Forever quest
   record for 1486 explicitly identifies NPC5767 in start/end entity links,
   but its mapper is null. The bag generator previously discarded those
   identities and flagged an unknown starter. A generic parser now preserves
   explicit NPC/object IDs from structured start/end blocks when mapper data
   is absent. Objective prose or the turn-in never becomes a guessed starter.
4. **No precise local Nalpak coordinates.** Re-reviewed Forever NPC and community
   pages supply only continent coordinates, rounded differently. They are
   not promoted to a local NPC pin. A small reviewed source overlay associates
   the named starter with the existing Wailing Caverns exterior approach.
   The tooltip and directions state that the exact quest-giver position is
   unresolved and distinguish it from the portal. Coordinate checks prevent
   future continent-to-local promotion. Reward, capacity and quest rules stay
   unchanged. This is an approach marker, not a claim of an exact Nalpak pin.
5. **Source-based instance routes missed published entrances.** Dungeon loot
   routes already had published approaches, but quest NPCs, objects and recipe
   sources inside an instance did not consistently pass those to the shared
   resolver. They now use the same reviewed exterior entrance definitions,
   retaining actor/quest identity and instructions. Active quest objectives
   without a reliable position retain their existing written guidance. Native
   entrance data is preferred only when it is an exterior map and matches a
   requested distinct gate. Interior NPC/boss coordinates are never portals.
6. **Instance aliases bypassed source classification.** Three named-drop
   records use The Stockade while the entrance definition uses Stormwind
   Stockade. Source/quest/object classification now consumes the existing shared
   instance alias table. This restores six faction/route observations without
   adding coordinates or guessing names. Every published alias and all three
   actual item records have regression coverage.
7. **Coordinate spaces could be reinterpreted.** A recognized explicit map ID
   with a mismatching zone name previously fell through to another map with
   that name. It now fails safely to directions. Unresolved discovery indexes
   can retry when client map metadata arrives, rather than caching absence.

The actual reported Gunnysack, Hunting Satchel and a catalogue Hands/Stockade
item now pass through the same adapter in source/API tests. Stockade already
has a reviewed exterior Stormwind City approach (41,57); its report is not
evidence of a missing entrance record. The scale defect is reproduced in the
API model, but without installed-client diagnostics it cannot be declared the
sole cause of every reported invisible pin. `/getgear mapstatus` reports the
current/target map, shown state, canvas dimensions and canvas/pin scales to
make any remaining in-game failure actionable.

## Forever compatibility evidence

Reviewed Gethe/wow-ui-source's **forever** commit
`4cd0ab752a77164f654ccbca9d0c1fe8dafceebe`: MapCanvas, its scroll controller/XML,
and WorldMap methods. `forever-api-evidence.json` records sources/fingerprints
and the relevant API behavior. This establishes source compatibility, not
actual rendering or installed-client map IDs. Runtime guards remain necessary.
No native waypoint setter/clearer, TomTom API or other addon's pin pool is used.

## Review of preserved unfinished work

`paused-dataset-review.json` compares the 3,836,743-byte paused extraction with
the already accepted 4,644,037-byte navigation module. All 3,557 common item
routes, 52 map lists, 36 chains, 32 entrance definitions and 39 aliases match.
All 874 common source and 670 common quest records match when projected onto
the extraction's retained fields; its differences mostly discard richer data.
Its two additional bag records are covered by the later accepted bag overlay.
Bulk import would duplicate/replace accepted evidence and drop useful fields.
It is therefore excluded. Valid driver/reopen/safe-map ideas were reviewed and
adapted to the cumulative implementation; the original files remain untouched.
The separate Buzzbox supplement is unnecessary because accepted bag data
already has the earlier Buzzbox827 start and the qualified published series.

## Catalogue audit and remaining data gaps

`tools/audit_navigation_pipeline.lua` audits all **7,707 equipment identities**,
plus runtime bag alternatives: **7,732 unique IDs / 74,004 class-faction checks**
across nine classes and both factions. There are **23,412 destination/status
rows**, including **8,557 usable location rows**. **Zero** usable locations lack
the shared button. All **807 distinct usable destinations** are also opened
through the actual adapter with synthetic map metadata, checking map/parent,
shown state, native anchor math and absence of waypoint writes.

An independent pass inspects accepted input routes, quest starters and actor
locations before navigation choices are resolved: **24,520 source-evidence
checks**, with **zero** lost buttons. The feature contract records minimum
reviewed catalogue/source/marker coverage and zero-loss assertions, so deleting
all destinations cannot turn a vacuous audit into a pass. Build unit tests
deliberately reduce marker coverage or introduce lost source evidence and verify
rejection. A preliminary candidate gate was stopped to add these protections;
only a complete extracted-package gate is a deliverable pass. The `.2`
candidate then passed all145 checks and remains preserved. A final loading-order
review added coverage/recovery for WorldMapFrame itself appearing late, rather
than only its canvas. Reviewing the explicit gap CSV also exposed the three Stockade
alias records, which were corrected before rerunning `.3`. The final package
must pass the full gate again.

These counts are route/faction observations, not unique failing items:

| Status | Rows | Meaning |
| --- | ---: | --- |
| Point data | 3,358 | Reviewed coordinates; live map-ID/name/rendering pending |
| Area data | 5,195 | Published footprint; no invented NPC midpoint |
| Exterior approach only | 4 | Exact actor point unresolved; reviewed approach retained |
| Coordinates missing | 628 | Known region/source without usable local coordinates |
| Source location missing | 1,319 | Actor identity has no resolved location |
| Dungeon exterior missing | 126 | No resolved exterior destination in this context |
| Quest chain unresolved | 143 | Known stage is not a verified actionable chain start |
| No actionable destination | 378 | Known route, no resolved starting destination |
| Written reference only | 3,616 | Qualified historical/disputed directions, not current pins |
| Character restricted | 456 | Ineligible source; no marker appropriate |
| No fixed route | 8,189 | Includes random loot and absent route evidence; not all bugs |

Every row is written to `navigation-targets.csv`; `navigation-gaps.csv` retains
unresolved/qualified cases and reasons; `navigation-map-gaps.csv` separately
lists recorded zones without static map-ID candidates. A nonempty candidate
list does not prove a matching live ID. Exact gaps remain evidence work, not
guessed coordinates. Four current Back records have no reviewed point/area
route; their gaps remain listed. Back adapter wiring is tested with a synthetic
route rather than inventing locations for those items.

## Permanent gates and packaging

The cumulative feature contract retains all ten groups/29 modules and adds
marker/UI regressions. Its reviewed navigation hashes are deliberately advanced
for this owner request; the full accepted navigation evidence module stays exact.
Tests exercise 181 actual slot/route pairs, 88 visible UI button callbacks across
17 slot selections, city/outdoor entrances, quest progress, multiple routes,
zoom .05–4, incomplete maps/canvases, repeated clicks, reopen/clear, restrictions,
both factions/levels, and native waypoint preservation. Source generation tests
cover missing mapper/explicit actors and rejection of continent-local promotion.

The full extracted-package gate includes both Lua5.1 and Lua5.4, existing
settings/stat/material/slot/talent/faction/bag suites, catalogue audits, build
unit tests and release-safety tests. The private builder requires a clean source
revision and creates the final ZIP only after the complete gate passes. Exact
results/source revision/SHA-256 are recorded beside the final artifact; this
document does not substitute for that receipt. No actual-client screenshot or
marker visibility claim is available from API doubles.

## In-game acceptance

1. Exit Forever, move the old GetGear folder outside AddOns, retain WTF/settings,
   extract the complete `.20261118.3` ZIP and verify its TOC/BUILD_INFO identity.
2. Set a native player waypoint first. Open Gunnysack and Hunting Satchel from
   overlay, guide and Bags; confirm a visible labelled destination and an
   unchanged player waypoint. Check source chooser alternatives too.
3. Open Deviate Hide Pack: confirm the Wailing Caverns exterior approach marker
   and explicit quest-giver-position qualification. Verify Nalpak's actual cave
   location separately; do not accept the marker as an exact NPC point.
4. Open Stockade Hands equipment: confirm the marker on Stormwind City's exterior
   approach, not a boss-floor position. Compare with an outdoor dungeon entrance.
5. Zoom fully in/out, pan, resize/maximize, change maps, close/reopen, click a
   different destination repeatedly and repeat with the usual map addons enabled.
6. Check every slot and representative vendors/trainers/recipe vendors/objects/
   reputation or ACA sources where available. Written/unresolved sources must
   report their limitation and never invent a pin or current availability.
7. Verify all display settings, three stat modes/custom weights, materials,
   independent slot persistence, Hide/Unhide and wrapping/scrolling still work.
8. If a verified destination is invisible, capture `/getgear mapstatus`, build
   version, item/source, selected map, zoom and enabled map addons. Acceptance
   still requires actual visible rendering at the intended destination.
