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


## 8BS additional client acceptance tests (not yet performed)

1. Open Drakefire Amulet 16309 from compact overlay and full guide with no reliable completion API. Confirm the same source chooser exposes Helendis Riverhorn / Alliance 4182 and written Horde document 12563 / 4903 directions, rather than only final Haleh/Rexxar. Check long guide/chooser scrolling and ordinary map close behaviour.
2. With reliable completed flags through Alliance 4242, verify note 11446 / 4264 starter guidance appears before Windsor's turn-in. The note must not be described as a free Provided item. With 4264 accepted, GetGear must not tell the player to restart it. Confirm active later quests take priority over earlier incomplete flags.
3. Check current server prerequisites, 99435/6403 identities and completion behaviour, Goretooth's document interaction, four skull tasks/order, Mazthoril rune access and Drakefire attunement enforcement. Record actual client/build and evidence; do not silently turn published travel order into a mandatory graph.
4. Check Marshal Windsor and other friendly in-instance quest actors navigate via entrance/directions without a boss label. Genuine researched bosses retain their names. Verify floor/entrance fallback without a dungeon map API and no unsupported coordinates.
5. Compare all 14 new Fanny Pack alternatives between compact pin and full guide: Oralius / minimum 50 / Alliance / 20 input packs / random wrapper reward, distinct from gear equip level. Confirm no mixed input-mapper farm pin appears.
6. Bow 13022 and anonymous map rows on 153464/153469 must have no misleading precise pin. Repeatedly alternate valid destinations, switch zones/maps, preserve native quest markers/other addons, close/reopen the map and verify one marker only. Rendering remains unconfirmed until performed in the Forever client.


## 8BT additional manual client tests (not performed)

1. Use Councillor's Boots 10095 in compact overlay and full guide. Select Container vendor and confirm Augustus's Eastern Plaguelands area and receipt-book unlock instructions. Check one-stock qualification, published 7g20s offer versus unresolved 8g base, actual charged price/restock and shop access before/after quest 6164.
2. Accept 6164 from Augustus, locate receipt object 177789 at the published inn area, return and verify whether the shop opens. Record actual client/build. Do not convert source minimum 50 / Both factions or bag BoP/Unique into equipment gates.
3. Check Lord Alexander's Battle Axe 13003, Elder Wizard's Mantle 13013 and Heartseeking Crossbow 13040. With unknown progress, the initial Sack route should start with Huum in Cenarion Hold, not only Bor. Check all-stage shard/crest/signet quantities and the separate one- versus three-signets exchanges.
4. Verify actual initial/repeat quests, reputation/summoning/phase rules, medallion/trappings/wind-stone use and source inputs. Published travel order is not a claim that those prerequisites are confirmed. Current Duke loot/rates and random gear rolls require separate evidence.
5. Open another exact grab-bag catalogue content (e.g. Commander's Girdle 10381) and a newly surfaced Dingy Fanny Pack content. Confirm the same shared source is available without per-item UI code. Generic world drops without meaningful destinations still have no misleading farm pin.
6. For a positive Supply Crate 176224 alternative, confirm the Forever client recognises Zephras Isle and the area; use written directions if it does not. Nameless 0,0 rows and unknown Dark Coffer coordinates must not create a pin. Retest source chooser scrolling, long guide scrolling, map switching, repeated destinations, single-marker lifecycle, native markers and normal map closure.


## 8BU manual acceptance additions (not performed)

1. Use Demonslayer13044 in compact overlay and full guide. Confirm distinct Sack and Chest source alternatives, with initial Chest itinerary8343→8341→8351→8352 starting at Huum when progress is unknown. Verify completed/active flags select the correct published stage without claiming mandatory prerequisites.
2. Check five shards/three signets for ring20451 versus one OR three scepters20515 for the two chest exchanges. Confirm no combined four-scepters fee or guaranteed equipment reward, and no source-level60 gate imposed on gear52.
3. Verify actual reputation, Greater Wind Stone/ring+medallion+trappings, group/summoning/phase and repeat rules; independently test whether the Classic Everun ring alternative is currently obtainable and whether it changes unlocks. Do not assume a bypass.
4. Inspect Ornate Legguards10124's low-level21510 wrapper alternative without changing its equip52 requirement; check event acceptance, opening and source-location disagreement. No disputed current-source pin should appear.
5. Check a new shared chest content outside this batch (Band of the Cultist20721), positive Arena/Supply Crate alternatives and nameless0,0 negative cases. Retest source chooser/guide scrolling, zone/map changes, native markers, repeated destinations and normal close behaviour. Record actual Forever client/build; no rendering is confirmed by offline tests.


## 8BV manual acceptance additions (not performed)

1. On Alliance and Horde characters,open Drakefire16309 from compact and full guide. Alliance should use its Helendis/note itinerary;Horde should use the Goretooth document itinerary. Both-faction intermediate stages must not independently enable the opposite final reward path.
2. Confirm explicit other-faction-only quest/container/vendor sources are omitted from actionable navigation while gear eligibility and existing settings stay unchanged. Check a Horde character with a Dingy-only Alliance source:no misleading Oralius pin. Where another compatible source exists,that destination remains.
3. Verify the actual Forever UnitFactionGroup return/capability. Unknown/unavailable API should retain qualified alternatives;current client-active evidence may override stale published source-side metadata without claiming a complete mandatory graph. Test any actual cross-faction quest exception separately.
4. Check13146 effect/source directions,13070 broad-drop qualification,189420 SoD origin warning and positive Supply Crate alternatives. No current SoD farm pin/gear retirement/wearer Plate requirement or fake0,0 marker should appear.
5. Retest source chooser/guide scrolling,quest-state changes,map switching,repeated destinations,native markers,one-marker lifecycle and normal close. Record actual client/build;rendering remains unconfirmed until performed.


## 8BW manual acceptance additions (not performed)

1. On Warrior/Paladin and Mage/other-class characters,inspect a Demon Kissed Sack content (Commander's Girdle10381). Navigation should use published5127class access when classAPI is known,retain qualified paths when unavailable,and honour actual active-quest exceptions. Verify whether current server access agrees with published Warrior/Paladin flags;do not infer quest profession skill from book learning.
2. Check Lorax63.8,73.8/quest55,Blood12848→Soul12847 corpse use on Goraluk,Unforged12806/object175970 and return. Confirm current class/profession/earlier unlocks and dungeon access. Book260Armorsmith is a separate learning gate;no item-wearer requirement or ordinary crafting transformation should appear. Raw input0,0 must not create a floor pin.
3. Inspect Bag20603 one/three-Crest alternatives separately from Sack/Signets and Chest/Scepters. Verify actual initial/repeat/summon/reputation/phase/opening rules. No combined fees or inherited ring/medallion prerequisite should be asserted.
4. Select Zigris Footlocker13247. It must show qualified Classic Blackrock Spire directions without a current precise NPC-farm pin or guaranteed gear/rate. Verify actual NPC/container loot,current wing/floor/keys/group/entry/opening before upgrading confidence.
5. Check unavailable18674:explicit published warning/current-origin gap,no false destination or permanent-retirement assertion. Check recipe12628's repaired Lorax navigation,negative-Agility Tankard4696/cooldown information,other sources and unchanged gear eligibility/settings.
6. Retest all nine classes/source selectors,unknown APIs,active quest changes,compact/guide consistency,source chooser/long guide scrolling,zone/map changes,native markers,one-marker lifecycle and normal close. Record actual Forever client/build;offline tests do not confirm rendering or availability.


## Verified evidence-format deficiency repaired — non-release CI gate next

Shared navigation now reads completed6O recipe-quest evidence through exact full-page SHA256/URL/book-reward joins. This reuses completed research, not35 new cases.33 full quest records/58 formal actor roles restored;current full3402/5127 retain precedence. Four item-started quests7649/7650/7651/7604 retain explicit starter items;turn-in NPC is withheld as first destination until reliable client state shows accepted quest. Unknown8869/92817 actors and three unmatched Nightclaw legacy records remain unresolved. No name-based joins,provided-item/free-starter inference,mandatory chains,race gates or guessed positions.

22 cases improve:18missing→directions/fourmissing→published point data. Global695point-data/1483directions/3151missing/2378NA;8529overlappinggaps/rendering0. Same compact/guide selector/shared gaps cover future exact evidence. Case NAVIGATION_LEGACY_RECIPE_QUEST_FORMAT.md and checkpointnavcompat_review.json include exact35joins/status changes/immutable fingerprints/companion review.

Fresh navcompat capture exit0/eight actual fingerprints→full19localPASS=15Lua/threeofflinePython/filesandsyntax26modules/fourtools/exporter. Genuine upstream update reviewed before diagnostic advance:PF23629→23618rows/9248→9327definitions,23newoutsideIDs/34omittedIDs;2336resolved source changes(1703note-only/633other),full originaldiff retained.827typeindices/85encounterlists resolve identically;85raw16/12726opaque10changes uninterpreted.10418raw subtype/masks not accepted gear gates/stats. Two principal reportcases271800/271804KhanJehn match completed93196 rewardcontext,not giverNPC/pin.11946container note adds11937link in threecompanion copies;2460othercompanioncells sourceRow-only. EV1688raw1439qual/noadded-removedrelation;one npc2851→zone1417 installs3→4/lastSeen only. Reviewed source/recipe/identity/material/settings unchanged.

23 community-feed-only leads extend shared outside candidates470→493;old470rows exact/zeroadoption/primaryeligibility-version-source research pending.633otherfeedchanges unverifieddiagnosticleads,not replacements forprimarynavigation. Removed feedrows not retirement. Originaldiffs saved before snapshotadvance;do not rerunmutator;actual-local facts remain baseline,not inferred from unreadbotbodies.

Originalqueue5260/5688researched/428pending;registry5474/index6945/display6944/books759/7707identities36341classobjectives1254crafts4857ingredients/954recipes preserved. **Next finish repair nonrelease18CI PASS/fullbotreview,then8BXall54level55numericIDorder.**493candidates/wholeBackThrown/knowncloaks/sixdungeon954livebooks/3151missing-locationdispositions/manualmap/finalintegrity remain. Existingtwo-hour automation verifiedenabled/oneworker/no newautomation/mainBeta8buildpackagereleasebilling. Earlieridleinterval not attributed to quota.


## Navigation evidence-format repair verified — continue 8BX

The repair is verified and pushed: source f38564187ce594d9b9dfd9c7ac950211d15b5e68; [non-release CI 43184666327](https://github.com/magicaddons/getgear/actions/runs/43184666327), job 131068755503, SUCCESS with 18 timestamped test PASS. Full local validation passed 19 checks. Inspected direct-bot/final generated head cad1336bc3f334da2c74ef6556d3faa4a8d860f7 changes only time and four Everloot fingerprints; all other runtime, source and report bytes are exact. Bot response bodies were not read; retain actual-local navcompat factual snapshots. No pending validation gate.

Completed research is reused: 33 legacy recipe-quest records and 58 formal actor roles restored; two current full records preserved. Four item-started quests retain an unresolved first destination rather than a false turn-in pin. Two unknown actors and three unmatched Nightclaw legacy records remain exceptions. Navigation now has 695 published point-data cases, 1,483 written directions, 3,151 missing and 2,378 not applicable; 8,529 overlapping gaps; zero live rendering confirmations. All 22 coverage improvements, sources, confidence and test limits are recorded in NAVIGATION_LEGACY_RECIPE_QUEST_FORMAT.md and checkpointnavcompat_review.json; final gate in checkpointnavcompat_validation.json.

The fresh upstream update and complete original deltas were reviewed before diagnostic snapshot advance. New community-only leads increase the shared candidate register to 493, with all prior 470 rows exact and no catalogue adoption. Current primary-validated source/recipe objects and equipment eligibility remain unchanged. Do not rerun the completed snapshot mutator or reinterpret opaque feed changes as availability or retirement.

Original queue: 5,260 researched, 428 pending. **Next: 8BX, all 54 level-55 items in numeric ID order.** Registry 5,474 / index 6,945 / displayed references 6,944 / books 759; identities, class objectives, crafts, ingredients, settings and filters preserved. Remaining work includes the 493 candidates, all-slot Back/Thrown review, known omitted cloaks, six dungeon exceptions, 954 current-live book routes, missing navigation dispositions, manual map tests and final integrity review. This closure is documentation-only; targeted evidence/link/input-hash/bot-diff checks passed, with no claim of a new full run. Same worker and existing automation; no main, Beta 8, build, package, release or billing action.


## Checkpoint 8BX integrated — non-release CI gate next

All 54 level-55 cases are publication-researched and integrated: 52 broad-drop references, one qualified Classic item-side named reference (18671) and one container-only ring (20692). Quality: 47 Uncommon / seven Rare; all BoE; Band of the Hierophant13096 has possession Unique, not Unique-Equipped. All 5,474 prior equipment objects and 954 recipe objects are exact. Registry5,528 / index6,999 / displayed references6,998 / books759. Original queue:5,314 researched /374 pending, about93% of this queue only. **Next8BY: all51 level56 in numeric ID order**, after CI/full bot review.

417 case primary pages (256 new/161 cached),676 including retained completed context (256 new/420 cached);54 exact/four shared discovery queries.2,790 fullNPC/77 object/121 physical-container positive joins;1,663 NPC/37 object/six container omissions remain one-sided, not assumed table caps/current absence.86 new403 responses (84 NPC/two spells) are retained without body hashes or retries;two relevant known failures were skipped;213 cumulative known URLs. Zero earlier failed URL retries. No new outside lead;493candidate register byte-exact/no adoption.

Baron Charr14461 full NPC positively lists sceptre18671 as specific;the own item marks that relation Classic while the reverse does not. Retain that distinction, not a current29.55% rate/world-boss/spawn claim.109-point Un'Goro footprint gives qualified written directions, no precise centroid/current farm pin. Published equip55/item60/90Fire differs from older54/59/35Fire. Full proc13442 unread403. Multicolored Band20692 has no enemy table and a full own↔Bag20603 positive;the existing one-or-three Crest source route remains separate from equip55. Needler13060 fullWound16405 UsedBy positive/75damage is an equipment effect,not learned recipe/proc probability. Doombringer13053 own161–301Shadow retained;full18211 unread403.

Completed8BO's17 quest records/14 actors match exact cached primary fingerprints and full quest metadata;reused without repeat HTTP research. Two shared container destinations now propagate automatically to every exact earlier/future canonical content:21513 War Effort Supplies145contents/14 alternative quests,21528 Colossal Bag134contents/three alternative provided-husk deliveries. All279contents carry explicit Classic provenance/current loot unconfirmed. War sources retain capital-versus-DunMorogh/Durotar conflict and open written directions only. Researchers start the Colossus deliveries;Oglethorpe/Oilfist/Tyrosus are distinct turn-ins;provided husks are not extra boss-kill fees. Source minimums,faction,ten-commendation rewards and30-signet exchanges do not change gear eligibility or combine into one fee. Current event phase,NPC presence,earlier unlocks,repeatability,opening and rolls remain unresolved.

Shared quest-container routes now preserve authored written-only policy;runtime choices retain exact quest identity/preference rather than merging distinct written alternatives. Same single compact/guide pin, no UI coordinates/extra icons. Navigation813 point-data/1421 directions/3150 missing/2323NA;15994 overlapping gaps/rendering0.132 status changes:76 directions→point-data,41NA→point-data,14NA→directions,13022missing→point-data.56 newly located cases/118 more point-data cases,including76 existing directions upgrades;not118 new NPCs or current live routes.

First local run had18PASS then an obsolete13022 no-destination assertion failed:the new full21528 quest/container evidence provides a qualified alternative without validating its sparse oldNPCclaims. Updated test forbids all bow routes except exact21528questcontainers;added actualBaron/container-only/disputedwar negatives. Failed log retained. Final fresh8bx2 capture exit0/eight actual HTTP fingerprints→full19localPASS (15Lua/threeofflinePython/filesandsyntax26modules/fourtools/exporter). PF23618/9327 all raw/full sources/metadata andEV1688raw1439qual all fields exact actualnavcompat and first8bx;no new/removed/updated/index/opaque changes. All factual snapshots/eight companion CSVs/supplementary/candidates exact;only54 principal CSV research-summary cells change.7707 identities/36341classobjectives/1254crafts/4857ingredients/settings/filters preserved.

Case CHECKPOINT8BX_LEVEL55_WORLD_DROPS_AND_SHARED_EVENT_CONTAINERS.md, immutable proof, local validation and exact navigation delta record evidence/confidence/limits. Non-release18CI PASS/full bot review next,then automatically8BY51.493 candidates,all-slotBackThrown/knowncloaks,sixdungeon954livebooks,3150missing-location dispositions,manual map/client acceptance and final integrity remain. Same worker/existing two-hour automation;no new automation/main/Beta8/build/package/tag/release/billing.


## Checkpoint 8BX verified — continue 8BY

All 54 level-55 cases are publication-researched and integrated. Source97148e4f906d3cb76fe97afe0f581d788c2603c3; [non-release CI43186762584](https://github.com/magicaddons/getgear/actions/runs/43186762584), job131075740131, SUCCESS with18 timestamped test PASS. Final local suite:19PASS. Inspected direct-bot/final generated head159bbe1e9b7de9618a4f04f16654daea26c16adc adds exactly the54 new index rows; all6,945 prior rows are exact, and the whole index matches the locally validated bytes. The only other changes are time/four Everloot fingerprints. All other source/runtime/report bytes are exact. Bot response bodies were not read; actual-local8bx2 full factual snapshots remain the baseline. No pending8BX validation gate.

Original queue:5,314 publication-researched /374 pending. Registry5,528 /index6,999 /displayed6,998 /books759; all5,474 prior equipment objects/954 recipe objects/identities/class objectives/crafts/ingredients/settings/filters preserved.52 broad references/one qualified Classic Baron Charr reference/one container-only ring;47Uncommon/sevenRare/allBoE/one possession Unique13096.417 case primary pages256new161cached;676 with completed context256new420cached.54 exact/four shared queries.2,790NPC/77object/121physical positive joins;1,663NPC/37object/sixcontainer omissions retain uncertainty.86 new403 reads,zero prior failed-URL retries,two historical failures skipped;213 known unread URLs.493 outside candidates byte-exact/no adoption.

Shared21513/21528 destinations cover all279 exact Classic-labelled contents, including older/future discoveries. War locations with disputed narratives remain written-only;Colossus quests start with researchers and deliver provided husks to different turn-ins,not extra boss kills. Source min/faction/event requirements remain distinct from wearability. Navigation813 published point-data/1421directions/3150missing/2323NA;15994 overlapping gaps/rendering0.132 status improvements include76 existing directions upgraded in precision and56 newly located cases,not current loot/map confirmation. Full findings,confidence,failed first test and final validation are in CHECKPOINT8BX_LEVEL55_WORLD_DROPS_AND_SHARED_EVENT_CONTAINERS.md/checkpoint8bx_validation.json.

**Next:8BY, all51 level-56 items in numeric ID order**, already marked in the queue. Do not repeat completed8B–8BX research or retry unchanged failed URLs.493 candidates,all-slot Back/Thrown/knowncloaks,six dungeon exceptions,954 current-live book routes,3150 missing-location dispositions,manual map/client acceptance and final integrity remain. This closure is documentation-only; targeted proof-hash/queue/CI-log/full-bot-diff/protected-ref checks passed, retaining prior full local/CI results. Main/Beta8 refs independently unchanged at19:24Adelaide12Nov. Same worker/existing automation;no new automation,main change,build,package,tag,release or billing action.


## Checkpoint 8BY integrated — non-release CI gate next

All51 level-56 cases are publication-researched/integrated:46Uncommon/fourRare/oneEpic,allBoE,noUnique/unavailable/cross-version/explicit wearer-class flags on these equipment pages. All5,528 prior equipment objects/954 recipe objects exact. Registry5,579 /index7,050 /displayed7,049 /books759. Original queue5,365 researched/323 pending,about94% of this queue only. **Next8BZ:all56 level57 numeric-ID order**,after CI/full bot review.

365 case primary pages95new270cached;654 with retained completed context95new559cached.51 exact discovery queries;no new shared query needed for already completed container routes.2,253 NPC/14 object/103 physical-container positive joins;1,592 NPC/oneobject omission remains one-sided,not cap/currentabsence. Zero new failures;213 known failed URLs not retried,58 relevant historical unread references retained. Full container/object contents checked;no outside lead/candidate493 file byte-exact/no adoption.

Elemental Mage Staff944 full page publishes equip56/item61,+26Intellect,100Fire/100Frost spell damage,8MagicResistance penetration and10Fire/Frost resistance. Name/effects do not create Mage-only wearability,trainer/recipe/quest source or current measured combat proof. Serathil13015 bonus100Armor is not armour subclass;Bludstone13028 name not Bloodstone quest. DrakesfireEpaulets13133 is not DrakefireAmulet16309/Onyxia-chain evidence.189420full container exactly matches completed8BV primary SHA/explicitSoDMaynotForever warning;reuse,not freshcurrentavailability/gearretirement/Platewearergate research.

Existing shared destinations already cover the new exact contents,including older/future evidence. Navigation coverageCSV is byte-exact:813published point-data/1421directions/3150missing/2323NA,rendering0.16172 overlapping gaps (+178 qualified uncertainties),no newcoordinate/coverage-success claim. Compact/guide single pin/model/quest-source class-faction selection/written-only disputed event policy remain intact.

Fresh8by capture exit0/eight actual fingerprints→full19localPASS (15Lua/threeofflinePython/filesandsyntax26modules/fourtools/exporter). PF23618/9327 all raw/fullsourceobjects/entiremetadata andEV1688raw1439qual/all fields exact actual8BX2;zero added/removed/updated/opaque/index changes. All factual snapshots,eight companionCSVs,954recipes,supplementary,candidates exact;only51 principal CSV research-summary cells change.7707identities36341classobjectives1254crafts4857ingredients/settingsfilters preserved.

Case CHECKPOINT8BY_LEVEL56_WORLD_DROPS.md/immutable source proof/local validation record exact51IDs,citations,confidence and unresolved source/opening/event/roll conditions. Nonrelease18CI PASS/full bot review next,then automatically8BZ56.493 candidates,all-slotBackThrown/knowncloaks,six dungeon exceptions,954 current-live book routes,3150missing-location dispositions,manual map/client acceptance and final integrity remain. Same worker/existing automation;no new automation/main/Beta8/build/package/tag/release/billing.


8BY final gate:source40d3e57;CI43187955068/job131079780923 SUCCESS18timestampedPASS/full19local. Inspected directbot71d4c4e onlytime/fourEVfingerprints;allotherbytes exact. checkpoint8by_validation.json overrides historical pending fields;actual-local8byfacts retained/botbodiesunread. Continue8BZ56level57. No new map/live claim.


## Checkpoint 8BZ integrated — non-release CI gate next

All56 level-57 cases are publication-researched/integrated:54 broad references/two uncorroborated Classic item-side Tempestria references18678/18679.48Uncommon/sixRare/twoEpic/allBoE/possessionUnique2243/no explicit wearer-class or availability/cross-version flags on selected gear. All5,579 prior equipment objects/954 recipes exact. Registry5,635/index7,106/displayed7,105/books759. Original5,421 researched/267 pending,about95% of this queue only. **Next8CA:all52 level58 numeric-ID order**,after CI/full bot review.

349 case primary pages88new261cached;639 with retained completed context88new551cached;56 exact/three shared discovery queries.2,143 NPC/oneobject/89physical-container positive joins;1,841NPC omissions retain their qualification. Zero new failures/213 known failed URLs not retried/51 relevant historical unread references retained. Full containers/objects checked/no outside lead;493candidate file byte-exact/no adoption.

Tempestria18678/18679 own pages name NPC14457 with classicEra1,while independent fullNPC7-entry loot omits both. Neither17.79%29/163 nor58.28%95/163 is a current measured rate;no table cap,currentabsence,retirement/worldboss/spawn inference.24-point Winterspring geography does not prove these gear drops. Current origins remain unresolved/no farm marker;two NA→missing cases correctly increase missing-location total. FullNPC contains Pattern21548,not finished21278;completed6U book lead retained,not new recipe/material/currentloot proof.

HandofEdward2243 full18803 UsedBy positive:published next spell within4seconds casts instantly,90spellpower/healing andpossessionUnique;equipment metadata,not learnedrecipe/currentproc probability/combat confirmation. Cloudkeeper14554 full18787 UsedBy positive:own use100AP30seconds/15minute item cooldown,not Alchemy/free permanentbuff. StaffHaleMagefire/Dreamwalker names not Mage/Druid gates,Haleh/Onyxia/Naxx quest-source proof. Exact equipment/class/stat/armour filters preserved.

Navigation813published point-data/1421directions/3152missing/2321NA;16302overlappinggaps/rendering0. Only18678/18679statuschanges,NA→missing;no new locations/current farm or successful navigation claimed. Shared single compact/guide model and older/future container propagation intact.

Fresh8bz capture exit0/eightactualfingerprints→full19localPASS (15Lua/threeofflinePython/filesandsyntax26modules/fourtools/exporter). PF23618/9327allraw/fullsourceobjects/entiremetadata andEV1688raw1439qual/allfields exact actual8BY;zero new/removed/updated/opaque/index changes. All factual snapshots/eightcompanionCSVs/954recipes/supplementary/candidates exact;only56principalCSV summarycells change.7707identities36341classobjectives1254crafts4857ingredients/settingsfilters preserved.

Case CHECKPOINT8BZ_LEVEL57_WORLD_DROPS_AND_TEMPESTRIA_GAPS.md/sourceproof/localvalidation records exact56IDs,citations,confidence and missing origins. Nonrelease18CI PASS/fullbotreview next,then automatically8CA52.493candidates/ALLslotBackThrown/knowncloaks/sixdungeon954livebooks/3152missing-locationdispositions/manualclientmapacceptance/finalintegrity remain. Existingworker/automation;no newautomation/mainBeta8buildpackagereleasebilling.


8BZ verified:source8dc0011;CI43189344820/job131084407230 SUCCESS18timestampedPASS/full19local. Inspected directbot8a46e767d5a2af50a289ee7997e8a58fee0a0ae1 onlytime/fourEVfingerprints;allotherbytesexact. Final checkpoint8bz_validation.json overrides immutable pending fields;actual-local8bzfacts retained/botbodiesunread. TwoTempestriagaps remainmissing/no mapfarm. Continue8CA52level58.


## Checkpoint 8CA integrated — non-release CI gate next

All52 level-58 cases are publication-researched/integrated:50 broad references/one origin-unresolved BoP ring19109/one container-only necklace20695.45Uncommon/sevenRare/51BoE/oneBoP/possessionUnique5267/no selected equipment availability/cross-version/explicit wearer-class flags. All5,635 prior equipment objects/954 recipes exact. Registry5,687/index7,158/displayed7,157/books759. Original5,473 researched/215 pending,about96% of this queue only. **Next8CB:all26 level59 numeric-ID order**,after CI/fullbotreview.

328 case primary responses70new258cached;618 with retained completed context70new548cached;52 exact/six shared discovery queries.1,713 NPC/90 physical-container positive joins/1,560 NPC omissions remain qualified;zero object references/omissions. Zero new failures/213 known failed URLs not retried/47 relevant historical unread references retained. Full content tables checked/no outside lead;493candidatefile byte-exact/no adoption.

DeepRootedRing19109 is primary-confirmed RareBoP58/63,+10Stamina/+10Intellect/+12spell damage-healing,with no acquisition tables. Historical expansion listings/comments suggest Lokholar13256/Ivus13419;fullForeverNPC titles match,but10/9 loot rows omit the ring/no maps. No accepted current drop,AVdestination,retirement,summon fee,quest or reputation proof. OneNA→missing;no marker. Original world-drop queue label is not proof of tradable BoE. Identity/equip/class/filters preserved;current origin unresolved.

AbyssalWarBeads20695 own↔fullSack20601 positive/56Classic-labelled contents;existing oneORthree Signets20514/min60Both/Bor shared route reused,not direct Duke finishedloot/guaranteed necklace/equip60 gate. SwordofZeal6622 full8191UsedBy positive;own effect10damage/150Armor15seconds is equipment metadata,not learnedrecipe/currentproc probability. ScarletKris5267 possessionUnique,notUniqueEquipped/ScarletMonastery-exclusive/Rogue gate.

Fresh8ca exit0/eightactualfingerprints→full19localPASS (15Lua/threeofflinePython/filesandsyntax26modules/fourtools/exporter). PF23618/9327allraw/fullsourceobjects/entiremetadata andEV1688raw1439qual/allfields exactactual8BZ;zero new/removed/updated/opaque/index changes. All factual snapshots/eightcompanionCSVs/954recipes/supplementary/candidates exact;only52principalCSV summarycells.7707identities36341classobjectives1254crafts4857ingredients/settingsfilters preserved.

Navigation813published point-data/1421directions/3153missing/2320NA;16439overlappinggaps/rendering0. Only19109NA→missing;no new location/current farm/successful navigation claimed. Same single compact/guide model and automatic shared destinations for older/future exact evidence remain intact.

Case CHECKPOINT8CA_LEVEL58_WORLD_DROPS_AND_DEEP_ROOTED_GAP.md/sourceproof/localvalidation include exact52IDs,citations,confidence and historical lead exclusions. Nonrelease18CI PASS/fullbotreview next,then automatically8CB26.493candidates/ALLslotBackThrown/knowncloaks/sixdungeon954livebooks/3153missing-locationdispositions/manualclientacceptance/finalintegrity remain. Existingworker/automation;no newautomation/mainBeta8buildpackagereleasebilling.


8CAverified:source46402cb;CI43190822637/job131089384906 SUCCESS18timestampedPASS/full19local. Inspected directbot95a37f4761856e36d7140226587db6424e441c7f onlytime/fourEVfingerprints/allotherbytesexact. Final checkpoint8ca_validation.json overrides historicalpending fields;actual-local8cafacts retained/botbodiesunread.19109BoP currentoriginmissing/noAVpin. Continue8CB26level59.


## Checkpoint 8CB integrated — non-release CI gate next

All26 level-59 cases publication-researched/integrated:25Uncommon/oneEpic/allBoE/noUnique/no selected explicit wearer-class/availability/cross-version flags. All5,687 prior equipment objects/954recipes exact. Registry5,713/index7,184/display7,183/books759. Original5,499 researched/189pending,about97% of this queue only. **Next8CC:first100 of189 remaining level60, numeric-ID order**,markedqueue;after CI/fullbotreview.

190 case primary responses36new154cached;490 with retained completed context36new454cached;26 exact/one shared query.902NPC/23physical-container positive joins/333NPC omissions retained with directional qualification;no object refs. Zero new failures;213known failed URLs not retried/29relevant historical unread references. Allfullcontents checked/no outside lead/candidate493byte-exact/no adoption.

BladeofHanna2801 fullImprovingForm1325535 UsedBy positive. Own published per-melee stack mechanic reaches30stacks for490Physical plus20allstats20seconds. EpicBoE/equip59/item64/96–145damage/2.00speed preserved. This is equipment metadata,not learnedrecipe,HannaNPCsource,permanentstats,guaranteed currentstack/proc/combatAPI result or class gate. Randomring suffixes/names do not establish quest/farm/profession routes.

Fresh8cb capture exit0/eightactualfingerprints→full19localPASS (15Lua/threeofflinePython/filesandsyntax26modules/fourtools/exporter). PF23618/9327allraw/fullsourceobjects/entiremetadata andEV1688raw1439qual/allfields exactactual8CA;zero new/removed/updated/opaque/index changes. Factual snapshots/eightcompanionCSVs/954recipes/supplementary/candidates exact;only26principalCSV summarycells.7707identities36341classobjectives1254crafts4857ingredients/settingsfilters preserved.

CoverageCSV byte-exact:813published point-data/1421directions/3153missing/2320NA;16461overlappinggaps(+22qualifieduncertainties)/rendering0. Existing shared sources already reach these exact contents automatically;no newcoords/navigation success claimed. Same single compact/guide model/sourcefaction-class selection/written-only disputed destinations remain intact.

Case CHECKPOINT8CB_LEVEL59_WORLD_DROPS_AND_BLADE_OF_HANNA.md/sourceproof/localvalidation record all26 IDs,citations,confidence and limits. Nonrelease18CI PASS/fullbotreview next,then automatically8CC100.493candidates/ALLslotBackThrown/knowncloaks/sixdungeon954livebooks/3153missing-locationdispositions/manualclientacceptance/finalintegrity remain. Same worker/existing automation;no newautomation/mainBeta8buildpackagereleasebilling.


8CBverified:sourcec131687;CI43192012001/job131093437379 SUCCESS18timestampedPASS/full19local. Inspected directbot0b2907078737bc083fb0a098a8bd72a6f88fc5a3 onlytime/fourEVfingerprints/allotherbytesexact. Final checkpoint8cb_validation.json overrides immutable historicalpending fields;actual-local8cbfacts retained/botbodiesunread. Continue8CCfirst100of189level60numericIDorder. Coverageunchanged/no newrendering orcoordsclaim.


## 8CC primary reads preserved — integration pending

The first100level60 items1728–21622 have verified full primary reads:100 item pages98new/two cached,139 auxiliary pages18new/121cached,nine new zone pages;248 unique responses125new/123cached. One zone3429 read timed out and was not retried;18 relevant old failures were skipped.73BoP/24BoE/three without a binding line,71Epic/24Uncommon/fiveRare;ten raw class masks retained without altering nine-class eligibility. Exact structured projections/headers/locations/quickfacts/failedread are in checkpoint8cc_primary_read_log.json. This log is deliberately outside runtime-input filename patterns.

Source integration/navigation corrections/full validation remain PENDING. The frozen queue is unchanged:5499researched/189pending,8CC100 still marked,next8CD89. Reuse completed8AD Benediction inputs/quest rather than repeat it. Existing native instance-entrance helper can be reused with verified raid context;written-only first-region loss and automatic object reverse-join gaps require bounded fixes/tests. Current legacy sources are not current live loot/coordinates. No implementation or new fullrun claimed. Documentation-only ID/name/SHA256/readcount checks passed;retain verified8CB19local/18CI43192012001,bot0b29070/closure90de6f1. Resume this same8CC integration from the read log/cache,not a new concurrent worker.493candidates/other exceptions remain. Main/Beta8/release/billing untouched;existing automation only.


## Checkpoint 8CC integrated — final validation and CI gate

The first 100 remaining level-60 cases (IDs 1728–21622) are individually publication-researched and integrated. Registry 5,813; source index 7,284; displayed references 7,283; books 759. All 5,713 prior equipment records, 954 reviewed recipes, 7,707 identities, nine-class eligibility and existing filters remain unchanged. Frozen queue: 5,599 researched / 89 pending. Next is **8CD: all 89 remaining level-60 IDs, 21623–23577, numeric order**, after this checkpoint's full local/CI/bot gate.

Evidence: 255 unique full case responses (130 new, 125 cached), 552 including reused completed context; 100 exact and four shared discovery queries. 528 exact own/full-NPC joins, two own/full-object joins and 21 physical-container joins; 205 full-NPC omissions remain one-sided references rather than caps, absence or retirement. One zone3429 timeout had no status/body/hash and was not retried; 18 relevant historical failures were skipped. Known failed-URL register: 214. No new outside-container lead; 493-candidate register unchanged/no catalogue adoption.

Seventy-one Epic, 24 Uncommon and five Rare; 73 BoP, 24 BoE and three without a binding line. Ten raw class masks are preserved separately from printed requirements; no inferred wearer gates. Teebu1728 has eight own Classic references and no independent full-NPC positive: current origin/location unresolved. Both Eyes remain wearable trinkets as well as completed8AD Benediction inputs; Eye of Shadow is not Kazzak-exclusive. Twilight clothing, physical wrappers, summon tools, source access and equipment eligibility remain distinct. Item19002 is Head of Nefarian, not Blackhand's letter; actual starter18987→7761 is independently joined. Lothos7848/Blackhand7761 are published transport references, not verified current mandatory raid attunements.

The shared navigation model now validates exact zone identity/name/primary Dungeon or Raid quickfacts, retains all written source regions, rejects 0,0 placeholders and requires full exact loot joins for new authored destinations. Geographic client-resolved entrances retain historical loot qualifications; NPC/object floor coordinates are never reused as world entrances. Same-instance sources can open one physical entrance directly while the guide retains every source. Future verified records use the same model; failed full joins cannot fall through to weaker automatic pins. Ruins3429 keeps its explicit missing-definition gap. Eight new records had exact repeated shared instruction paragraphs removed.

Coverage: 813 published point-data / 1,500 qualified directions / 3,152 missing / 2,242 not applicable; 16,941 overlapping research gaps. Seventy-nine direction gains: 77 previously NA and earlier gaps21529/21530. Teebu NA→missing. No lost point-data; **zero actual Forever map-rendering confirmations**. This is useful qualified navigation coverage, not live loot, precise entrance or client-rendering proof.

Initial8cc reconciliation correctly failed the required `unverified` summary-word guard on two new summaries; both were corrected. Successful8cc2/full19 local preceded final future-source guards, Dungeon support and deduplication. Final capture/local results and CI state are authoritative in checkpoint8cc_local_validation.json/checkpoint8cc_validation.json when present. Full original upstream review is preserved: all Playfulls23,618 rows/9,327 full definitions/entire metadata exact8CB; one Everloot npc8719→zone1453 location observation installs4→5/lastSeen only, not gear loot. Original diff saved before advancing diagnostics. No main/Beta8/build/package/release/billing action; the same worker and existing automation continue.

Final8CC local gate: actual fresh8cc4 capture exit0/eight response fingerprints, then full19 local PASS (15 Lua,three offline Python,26 modules/four tools/exporter syntax). Final feed facts exactsuccessful8cc2;original one-observation delta retained separately. All100 summary cells only;companions/recipes/identity/filter invariants exact. Non-release CI18 and entire generated-bot review remain the next gate before8CD89. No client-rendering claim.

8CC verified:source0efc4d4,full19local,[non-release CI43200618367](https://github.com/magicaddons/getgear/actions/runs/43200618367),job131122763702,SUCCESS18. Directbotb48f68a inspected in full:onlyfourEverlootfingerprints/time,allotherbytesexact. No new local fullrun for this documentation closure. Final checkpoint8cc_validation.json is authoritative. Continue8CD89;actualclientrendering remains0/no release.


## Checkpoint 8CD integrated — original queue dispositioned; CI gate next

All 89 remaining level-60 cases have individual research dispositions: 88 successful full item pages and one HTTP404 exception23577. These are not 89 confirmed current acquisition sources. Registry5,902/index7,373/display7,372/books759. All5,813 prior equipment records,954 reviewed recipes,eight companion CSVs,7,707 identities,36,341 class objectives,1,254 crafts,4,857 ingredients,nine-class legality/settings/stat/armour/world-BoE filters remain exact. **Original frozen queue5,688 individually assessed/zero pending**,including explicit unresolved/unread/version exceptions. The comprehensive objective remains open.

Next after CI/full bot review: **8CE:first100 of495 outside-catalogue candidates,IDs647–12062 numeric order**,marked in the new derived additional_catalogue_research_queue.csv. Reuse completed exact primary evidence. The existing candidate register's first493 rows/bytes are preserved;fresh feed IDs18736PlaguehoundLeggings and284848DiamondStuddedBelt add two independently primary-ID/name/quality/level-matched leads,not active catalogue adoption. Systematic all-slot/Back/Thrown,known omitted cloaks,six dungeon exceptions,954 current-live book limitations,navigation dispositions/manual Forever acceptance and final integrity remain.

Original89-case/access research:267 full responses115new152cached,plus five independent upstream followups(fournew/onecached);587 unique full pages with completed context119new468cached.89 exact/three shared discovery queries.197NPC/two object/six physical-container/one vendor positive joins;106NPC/three object/three container omissions retain their direction and are not caps,currentabsence or retirement. New40423577 had no body/hash and was not retried;31 relevant historical gear-source failures plus known giver16116 were skipped. Known failed URLs215. Forty-seven Poor-quality outside contents were individually retained as existing quality>=2 policy exclusions,not missing eligible gear or new candidates.

Read88:84Epic/fourRare,85BoP/threeBoE,49plainUnique/noUniqueEquipped,ten raw class masks(nine class rings and explicit Shaman21890);existing eligibility unchanged. Gloves of the Fallen Prophet21890 has five own Classic references,all five full NPC inventories omit it;no accepted current origin/pin. The Hungering Cold23577 full URL404 and full KelThuzad13-row omission do not establish retirement,a replacement,table cap or a current source;no marker/new identity facts fabricated. Three RareBoE relics retain broad/random sources and qualified container alternatives,no named random farm. Four Horsemen Chest181366 has six full possible contents,two selected exact joins,not direct guaranteed boss drops.

Sentinel’s Lamellar Legguards22753 has an exact own/full Illiyana14753 sale,Ashenvale61.4–61.6,83.8,printed Silverwing Sentinels Exalted and Alliance source. Published price17g13s58c,current price/stock/access unverified;item-side stock-1 and fullsale standing0 do not erase the tooltip requirement. The shared vendor/recipe-book model now accepts reviewed full ID/name sale joins,keeps printed source requirements in both compact and guide,and prevents a failed authored join falling through to weaker automatic seller/merchant references. Recipe navigation matches the book,not finished gear;no new craft/wearer gates.

Naxxramas access is shared with older/future established routes:full9121Honored asks5ArcaneCrystals,2NexusCrystals,1RighteousOrb+60gold;9122Revered asks2ArcaneCrystals,1NexusCrystal+30gold;9123Exalted waives cost. Allmin60/Both,start/endAngela16116,primary quest-mapped EPL81.4–81.6,58.2. Alternatives,not three mandatory sequential quests/gear rewards/current live attunement or assumed player progress. Giver full403 remains unread. Raw input-drop mapper is retained separately,not promoted to formal objectives or guaranteed farms. Published completion describes the Plaguewood rune portal;client entrance only,no invented portal/floor point. BugTrio current item-specific kill-order/allocation remains an explicit gap.

Final actual8cd3 capture exit0/eight fingerprints→full19 localPASS(15Lua/threeofflinePython/26modules/fourtools/exporter). Original/full/final feed diffs saved before diagnostic advance:Playfulls23618→23620,two outside IDs;all prior rawrows/9327 full sourceobjects/indices/opaque cells exact,five st.last-field metadata counters only. Everloot1688→1691/1439 qualifying gear edges unchanged;three new NPC located_in relations344→1433,2046→1429,514→1429,all3installs/nullbuild,independently match full primary geography. No new item-loot edge or old-edge update. Shared source geography propagates without promoting an acquisition relation. Final capture fullfacts exactinitial8cd;89 principal summary cells only/all other principal semantics/companions unchanged.

Coverage813 published point-data/1584 qualified directions/3154 missing/2156NA;17549 overlapping gaps.84NA→directions;21890/23577NA→missing,no lost point-data. **Actual client rendering confirmations:0.** Missing source/floor/access/gates stay in the shared research list. Non-release CI18/full bot review next;then automatically8CE100of495. Final checkpoint8cd_validation.json overrides earlier historical pending states when present. Same worker/single existing automation;no main/Beta8/build/package/release/billing action.
