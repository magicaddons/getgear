# Acquisition navigation restoration and handover

Status: implemented; full local and final non-release CI validation passed, generated commit inspected. Actual Forever rendering/manual acceptance remains outstanding. No package or release authorised. Original acquisition research remains active.

## What happened to the button

The pin was not deleted. Initial commit 8923044 placed `NewAcquisitionPin` in both detailed and compact rows. Commit 78d177a extracted the map helper into MapNavigation.lua. The current UI still had the 22px compact / 24px detailed pin and its 64×64 artwork, but only 111 of 7,707 items had acquisitionLocation (105 point / 6 zone-only records, 71 in Redridge, 12 distinct zones). The old helper recognised only 15 zone names. Reconciled source descriptions usually lacked structured navigation data. This was a data-coverage regression plus a limited adapter, not missing artwork.

## Shared implementation

- Keep one context-sensitive pin, existing row geometry and icon asset. Hover describes the destination. Left-click opens one useful destination directly; otherwise it opens a paginated six-source chooser. Right-click selects alternatives. The same resolver powers compact and detailed pins.
- Detailed cards add “Where to go”. One reusable, closable/Escape-enabled popup holds source choices or scrollable directions when accurate map placement is unavailable. `/getgear map ITEMID` opens the same route for testing or lookup, irrespective of current class filters.
- Generated AcquisitionNavigationData.lua deduplicates sources, primary location footprints, reward relationships and ordered routes. AcquisitionNavigation.lua selects destinations; MapNavigation.lua adapts the client. Item identities, eligibility, recipe ingredients and SavedVariables are untouched.
- Published point coordinates receive a labelled GetGear marker; published roaming footprints receive a shaded area, never an invented centroid. Classic-only coordinates open written guidance without claiming a precise Forever pin. Native player waypoints are never replaced.
- Single marker reused across clicks; hides on other maps, returns on the destination map, clears on close, world entry or quest-progress refresh. Canvas coordinates follow resizing/zoom. No per-row dungeon scan, external addon or native waypoint dependency.

## Source coverage and confidence

All 7,707 catalogue IDs and 36,341 objectives across nine classes were audited. Counts are data coverage, not a claim of successful in-game rendering:

| Coverage | Items | Meaning |
| --- | ---: | --- |
| Published coordinate data | 682 | Cited published point data exists; actual client map resolution/rendering still needs testing. |
| Useful directions | 1,269 | Named areas/roaming footprints, zone guidance or client-resolved dungeon entrances; precise fixed marker not established. |
| Missing useful location data | 3,170 | No safe actionable location; missing data is not implemented navigation. |
| No applicable fixed destination | 2,586 | Broad random drops without a justified named target. |

Actual in-game rendering verified: **0**. Machine-readable [per-item coverage](navigation_coverage.csv), [nine-class/category totals](navigation_audit.json) and [shared research gaps](navigation_research_gaps.csv) retain every classification. Gap rows are not unique items and can overlap.

Supported categories include direct vendors, limited recipe vendors, currency/reputation/ACA sources, individual quest starts versus turn-ins, ordered quest routes, dungeon bosses/trash/recipe sources, named rare drops, objects and researched trainers. A missing precise entrance falls back to directions. In-instance NPC locations redirect to the client entrance rather than pretending unsupported floor coordinates are accurate. Recipe learning destinations are separate from finished gear and special crafting locations. Generic crafts do not acquire a destination unless a meaningful source is researched.

The Defias reward route for 6087/2041/2042 now includes 65→132→135→141→142→155→166, NPCs and zones. Five investigation stages have a published order; 142 completion text connects the escort, and 155/166 have their own published order. This supports a travel sequence, **not a fully proven mandatory prerequisite graph or current quest availability**. Character IsOnQuest/IsQuestFlaggedCompleted may select an active/next uncompleted published stage; unavailable/secret/error results fall back to the beginning with progress unknown. Only an active quest uses the client's objective waypoint. Completion never establishes which choice reward was obtained. Unknown chains remain in the shared gap register.

Evidence comes from the existing individually researched source registry, primary response fingerprints, reviewed merchant/book CSV joins and the published Forever client source. Published source facts do not establish current NPC presence, stock, loot, rank, access, phase or supply. No item location or prerequisite was fabricated. Full API/route proof: [checkpoint_navigation_evidence.json](checkpoint_navigation_evidence.json).

## Future discoveries use the same pipeline

Every normal `tools/reconcile_acquisition_1_60.py` run invokes the offline navigation generator after existing integrity guards. Non-release CI validates it and commits the generated navigation data with the evidence reports. This applies to subsequent research, not just today's snapshot.

1. Record new verified source facts in the existing checkpoint evidence JSON/merchant or recipe-source CSVs, retaining exact IDs, URLs, response fingerprints and uncertainty. NPC/object location proof accepts published `maps`/`mapper`, named footprints and zone-only evidence. Never turn a roaming region or generic random-drop sample into a precise destination.
2. Explicit reward/seller/object relationships automatically populate routes. A reviewed future trainer, special crafting location or unlock can use `navigationRoutes` in the existing reviewed equipment/recipe record, with kind, `source` (`npc:ID`/`object:ID`) and short instructions. It requires a source record with cited primary evidence; no UI coordinates or per-item UI branches.
3. Put researched ordered quest routes in navigation_quest_chains.json, with source proof, ordered steps, routeVerified and prerequisitesVerified kept distinct. Related/see-also IDs alone never prove prerequisites. Preserve unresolved links in navigation_research_gaps.csv.
4. Reconcile, run the full required suite and review the coverage/gap diff. Source IDs, current research status/nextBatch and exact next action remain linked to the same acquisition queue. Do not create a second worker, research project or automation.

The generator validates map candidates against client names and can discover newly researched zones from the client's map tree. No new UI-specific zone list is required for future locations. Gap reports are regenerated, including the empty-gap case.

## Forever API and implementation limits

Verified against Gethe/wow-ui-source's `forever` branch commit 4cd0ab752a77164f654ccbca9d0c1fe8dafceebe, with four Git blob IDs retained in the proof. C_Map.OpenWorldMap is present and restricted; it is **not** incorrectly dismissed as retail-only. Guarded fallbacks use global OpenWorldMap and WorldMapFrame.SetMapID. C_Map.GetMapInfo/GetMapChildrenInfo, C_EncounterJournal.GetDungeonEntrancesForMap, character quest APIs, WorldMapFrame:GetCanvas/GetMapID/OnHide are present in this source. Runtime capability checks and pcall remain necessary. Combat/unavailable APIs show written guidance.

This confirms published API support, not operation on the user's exact installed client. Localised map-name differences, map-canvas clipping/strata/scale, protected UI behaviour and entrance coverage require actual Forever checks. No accurate dungeon-floor/boss coordinates, keys or unlocks are asserted where unavailable. Primary published maps may contain historical footprints. Published Defias and Nilith travel sequences are assembled, with separate prefixes for different rewards; mandatory prerequisites/earlier unlock gaps remain open.

## Automated validation

Full local 19 PASS:15 Lua regressions (including new 13-source navigation scenarios), three offline Python regressions and required files / 26-module syntax checks. Exporter and four Python tool syntax checks also pass. The existing stress guard permits the two deliberately added data/model modules while retaining its time, class/filter and zero-bulk-request assertions.

Navigation tests cover simple quest, multi-stage chain, distinct start/end NPCs, equipment vendor, limited recipe vendor, ACA, dungeon boss, dungeon recipe, dungeon quest, multiple sources, rare NPC, broad random drop and missing data. They exercise shared actual UI factory, progress unknown/active/incomplete, point/area handling, invalid coordinates, entrance caching, repeated clicks, map changes/return, resizing, close cleanup, combat/missing-API fallbacks and native waypoint preservation. Offline generator tests prove future evidence propagation and reject fake centroids, inferred prerequisite edges, unreviewed partial research and disputed versions. These are behavior/API doubles, not game rendering tests.

Results: [navigation_local_results.txt](navigation_local_results.txt). Final GitHub validation and bot review are recorded below.

## Exact in-game acceptance tests

Install source files only through the next explicitly authorised build process; no package was created here. Enable Lua errors and use the actual Forever client. Open the relevant guide card/Preview and compare its pin with the compact objective pin where class/level eligibility allows. The lookup command exercises the same resolver without changing eligibility.

| Test | Action and expected result |
| --- | --- |
| Simple quest | `/getgear map 263329` (Flutterfly Swatter): display its published quest source; verify NPC/zone and tooltip against the guide. |
| Long chain | `/getgear map 2042` (Staff of Westfall): with no reliable progress use Gryan/Westfall and ordered seven-stage instructions. With65 complete, select132; with a stage active use the client's next objective when available. Verify unknown prerequisite warning. |
| Different start/end | `/getgear map 2042`: inspect65 within the Defias route (Westfall/Gryan start; Redridge/Wiley turn-in). Use the alternate-location chooser to verify distinct roles. |
| Direct vendor/multiple choices | `/getgear map 2506`: choose among ten researched merchants; verify the chosen zone/name updates, then right-click the normal item pin to choose another. |
| Limited recipe vendor | `/getgear map 5780`: identify named recipe vendors, published limited-stock qualification and written fallback where exact coordinates are missing. Do not expect live stock to be known. |
| ACA | `/getgear map 250513` and `/getgear map 220606`: inspect Stondry/Alynsia, Redridge coordinates and Merchant's Favor; verify recipe learning versus finished crafting and Honored text on the idol. |
| Dungeon boss | `/getgear map 1155`: choose Blackfathom Deeps entrance/other researched alternatives; confirm Kelris directions and no guessed boss-floor pin. |
| Dungeon recipe | Preview a dungeon-recipe entry (e.g.252455): entrance plus recipe-book source, never a claim the finished craft drops. If no native entrance exists, expect directions. |
| Dungeon quest | `/getgear map 2042`: start the outside quest before the dungeon; distinguish VanCleef objective from Gryan's start/turn-in. |
| Rare | `/getgear map 1404`: Prince Nazjak's published Arathi area; shade a region rather than invent a precise spawn. |
| Object | `/getgear map 18706`: named Arena Master object source; use directions if no reliable position is available. |
| Random drop |1713 (Ankh of Life) has no normal pin; lookup shows existing acquisition information without a fabricated farm. |
| Missing location |273884 (Grovekeeper Trousers) retains unresolved acquisition/location qualifications. No precise pin is fabricated. Southsea Lamp9359 acquired a researched Captain's Chest area in checkpoint8BI; test it separately with the object/key case below. |

For point and area cases: start with an existing native user waypoint; click alternating items at least 20 times, switch zones/maps/floors and return, zoom/resize, close with Escape/map toggle, reopen, accept/complete a quest, and retry during combat. Require exactly one correctly labelled GetGear marker/area, no stale marker after close or quest refresh, no accumulated frames, intact native markers/waypoint, normal map controls and no Lua errors. Check small/large overlay sizes and guide pagination, all nine Preview classes, factions and unavailable/API fallback profiles. Inspect profiler for no bulk item requests, repeated entrance scans or expensive per-row map work. Report actual client build/locale and failing item/source ID if anything differs.

## Broader research preserved and next checkpoint

Fresh required reconciliation detected genuine upstream changes: Playfulls 23,484→23,587 items / 9,161→9,246 definitions; 103 new IDs (five canonical,98 unvalidated outside leads), 841 prior resolved acquisition sets changed. Four existing dungeon entries gain independently joined community corroboration without changing their actor/role or live uncertainty. Four recipe report source lists change; current reviewed registries remain exact. Everloot 1,664 raw / 1,424 qualifying relations/counters are unchanged. Exact raw/semantic delta, primary joins and diagnostic snapshot advancement are in checkpoint_navigation_*review/comparison files. Raw cache/stat/index changes were not copied into equipment stats, eligibility or materials. Existing outside candidate register 244→342; frozen queue remains 1,318 pending. No automatic item adoption.

Next: close navigation CI/bot review and document any manual-only exceptions, then resume original 8BI at remaining discovery batches 6–24 (76 queries), preserving the 100 own item reads / 24 completed searches in checkpoint8bi_partial_evidence.json. No 8BI cases were marked individually complete or integrated by navigation work. Registry 4,584 / index 6,055 / display 6,054 / books 759, 7,707 identities / 36,341 objectives / 1,254 crafts / 4,857 ingredients remain. Six dungeon exceptions, 954 current-live recipe routes, all-slot/Back audit and current-live availability remain open. Single existing continuation automation retained; no duplicate automation or billing action.

Beta readiness: source implementation is ready for review and client acceptance testing after successful CI. Inclusion in the next beta depends on the manual map/overlay checks above. This is not a release or a claim that missing location/chain research is complete.

## Final routing review

Initial source4c7f3d6 passed [CI 42983282336](https://github.com/magicaddons/getgear/actions/runs/42983282336),18 test checks; inspected direct bot 0d40226 changed only provenance time/four API hashes. Fresh final capture retained exact PF 23,587 / 9,246 raw rows/metadata/source objects and EV 1,664 / 1,424 full relations/counters. Final 19 local PASS repeated after targeted corrections.

Selecting another pin closes the old source/directions popup. A known related quest sequence without a researched starting route now opens qualified directions instead of a misleading reward-quest marker. Generic dungeon-pattern labels without an identified dungeon were recategorised as missing; multiple identified dungeons have separate choices. Final audit: 681 point data / 1,266 directions / 3,172 missing / 2,588 not applicable; 6,339 overlapping gap rows. See navigation_final_validation.json. Final code CI/bot review passed; manual acceptance is the remaining navigation gate.

## Verified final code checkpoint

Source `2cc132a6ce6a8b89dd3e6bee934cfbd7e672693d`; [non-release CI 42984155730](https://github.com/magicaddons/getgear/actions/runs/42984155730), job 130401250893, SUCCESS / 18 timestamped test PASS (15 Lua + 3 offline Python), 26 modules/four Python tools/exporter syntax. Inspected direct bot/final validated `c74372c6b44e1a405fd55a3fa551570fd9b8a1cc`: only provenance timestamp/four API hashes, no runtime/report/count changes. Actual bot API response bodies were not independently fetched; equal counters are not treated as factual equivalence. Final-local actual factual snapshots retained. Main/Beta8 remote refs unchanged at 08:06:58 UTC / 18:36:58 Adelaide. No ZIP/package/tag/release or billing change.

Source is ready for the next beta subject to the manual acceptance matrix; rendering is not yet confirmed. Original 8BI research may resume independently.

| Acquisition category | Published point data | Directions | Missing | Not applicable |
| --- | ---: | ---: | ---: | ---: |
| world_drop | 7 | 262 | 30 | 2588 |
| dungeon | 9 | 543 | 0 | 0 |
| quest | 43 | 34 | 184 | 0 |
| crafting | 136 | 163 | 931 | 0 |
| vendor | 437 | 259 | 800 | 0 |
| unknown | 45 | 0 | 1210 | 0 |
| reputation | 0 | 2 | 0 | 0 |
| dungeon_recipe | 4 | 3 | 17 | 0 |

Categories retain original catalogue classification, with researched quest/dungeon overrides. Some original “unknown” entries retain previously researched location metadata; a point-data entry is not proof of live availability or a complete prerequisite route. The CSV and shared gap register provide item-level qualifications.

## New researched destination — checkpoint8BI

Southsea Lamp9359 now uses the existing pin for Captain's Chest142184 in Tanaris (published area76.4–76.5,45.7–45.8). Full chest contents independently name this lamp; Captain's Key9249 independently names this chest in its unlock table. Five full Southsea NPC inventories contain physical footlocker9276,not direct lamp9359; that box can contain the key/lamp/map fragments,not a guaranteed bundle. Keep this separate from Cuergo's Key9275/object142194. Current consumption/access/supply unverified. `/getgear map 9359` should open a labelled area and keep key context in guide/directions. No exact point, live rendering or guaranteed loot is claimed.

The automatic audit changes one item from missing to useful directions:681point-data/1267directions/3171missing/2588notapplicable;6339overlapping gap rows. This demonstrates that subsequent acquisition research updates the shared navigation model. The source formatter also now displays primary wrapped vendor-price alternatives correctly, using OR rather than combined charges.8BI local19PASS and [CI42988799050](https://github.com/magicaddons/getgear/actions/runs/42988799050)18testPASS;directbot7bac831inspected. Existing manual map tests remain necessary.

## Continuing discoveries — checkpoint8BJ

Drake-scale Vest1677 now has the published Mosh'Ogg Lord680 area (Stranglethorn49.4–52.6/26.6–31.2). Rockhide Strongfish19808 has a pure fishing-zone reference and opens qualified directions,never a fabricated point/school/mandatory event. Full Nilith3379→3385→3402 travel order now supports quest-unlocked Shadoweave Mask10025/Pattern10463, with Tailoring source label versus separate200book learning skill. Earlier mandatory/current unlocks and exact source skill remain unresolved. See CHECKPOINT8BJ_LEVEL40_41_WORLD_DROPS.md.

New source requirements appear in detailed guidance/hover; indirect container-quest unknowns and known-order-but-unverified-prerequisite gaps stay in the same generated research CSV. This extends future reconciliation,not only the original dataset. Manual additions: `/getgear map 1677`, `/getgear map 19808` (directions only/no precise marker), `/getgear map 10025` (published Nilith starting route/requirements, recipe book versus finished craft). Actual rendering remains0 verified;19localPASS and [CI43002009931](https://github.com/magicaddons/getgear/actions/runs/43002009931)18testPASS, generated bot91d3003 inspected.

Current regenerated coverage after8BJ:682published point-data/1269directions/3170missing/2586notapplicable;6397overlapping gap rows/rendering0. This is source-data coverage,not in-game rendering verification. Manual tests remain the beta acceptance gate.

## Continuing research through8BO — manual additions

- `/getgear map 4478` and `/getgear map 5029`: published ScaleBelly/LordSakrasis areas; no fabricated exact point. `/getgear map 5028` and `/getgear map 285043`: unresolved origins must not receive a misleading pin.
- `/getgear map 18709`,18710,18711,18712: same labelled ArenaTreasureChest179697/STVarea30.4–30.5/47.8; repeat clicks must update one marker normally. Guide distinguishes direct contents, supported18709/18712Spoils contents,18709own-wrapper omission and18711one-sided wrapper reference. No guaranteed event schedule/gear roll or twelve-trinket fee.
- View HeraldicBreastplate8119’s GreaterDarkmoonPrize context. At an active Faire, compare Gelvas14828’s actual price/currency, quest7933objective and availability with the qualified published40currency515 listing/removed physical objective. No purchase required. Valid client currency labels should be localized; verified published names must cover unavailable/empty currency API results (automated variants already pass). Record live differences; camp presence and current cost are not confirmed here.
- View CowKing’sHide13009’s ColossalBag context. If available, compare quests8857/8858/8859: Silithusresearchers provide their husks and send players to three different remote NPCs. Directions must label provided inputs separately from external collection, keep source51separate from gear46, and qualify unknown earlier unlocks/current event phase. Do not assume boss farming or a guaranteed gear reward.
- View Lord’sBoots10082for AQ50crate21513versus older crate/MithrilLockbox/ReinforcedLockedChest references, and VanadiumLoop11989for HeavyJunkbox. Current opening/phase/stock conditions remain unverified;13918has no established origin. Random world-drop entries must retain qualified guide information without an arbitrary farm pin.

After8BO:682published point-data/1275directions/3172missing/2578notapplicable;6758overlapping gaps/rendering0. Seventeen new cloaks are candidate-register additions pending the broader Back-slot/eligibility review; active catalogue remains7707. Existing full manual matrix/API limitations remain required. Latest final validation is recorded in checkpoint8bo_validation.json after CI closure; implementation tests do not establish actual client rendering or live loot.


### 8BP manual additions (not yet tested in game)

- `/getgear map 17055`: qualify Omgorn/Tanaris as historical Classic guidance; show written directions through the same compact/guide action and no current map marker. Switch from an existing real marker first and ensure it is cleared.
- 11302: Wasteland/Haunted affects the published shield proc; neither area is an acquisition marker.
- Authored future `directionsOnly` and `legacy-reference` routes must withhold coordinates even if an NPC record has a position; source text and shared gap tracker remain visible. Client rendering remains unverified.


### 8BR manual additions: indirect quest-container alternatives

- `/getgear map 10096`, then10096/10103/10107/10109/10126/10128/10166/10171/10176/10179/10183/10199/10244 from compact overlay and full guide: same single pin/Oralius starting area in Burning Steppes; no invented exact point or input-farm marker.
- Show Alliance quest minimum50/20DarkIronFannyPacks11468 in Blackrock Depths/return to Oralius forone11883container. Equipment remains level49/BoE/broad-drop eligible; source faction/level/inputs do not become wearer restrictions. Random container contents are not guaranteed gear.
- Check reliable known/unknown/completed quest progress and unsupported APIs. Earlier prerequisites/current repeatability/access remain qualified; mixed BRD-body versus new BurningSteppes inputmapper points must not appear as confirmed farms.
- Switch from/to17055historical written guidance and real markers; close/reopen maps/change zones/repeated clicks/native quest markers. Offline tests pass, but no actual Forever rendering or quest acceptance has been confirmed.

A reliable active-client objective waypoint for4286 may supplement the published Oralius start/end area. Do not confuse that client-provided objective with the withheld mixed-source published input mapper.
