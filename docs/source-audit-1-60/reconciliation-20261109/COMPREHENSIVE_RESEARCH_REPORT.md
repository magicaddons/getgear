# GetGear comprehensive research and navigation handover

13 November 2026, Australia/Adelaide. **All currently queued publication research is dispositioned and available automated validation is complete. The navigation feature is ready for actual Forever-client acceptance testing.** This is not confirmation that every acquisition is live, every item has a destination, or map rendering has been tested. Missing facts remain real exceptions below.

Work is isolated on `work/full-acquisition-reconciliation-20261109`. Main and the published Beta 8 tag/commit are unchanged. No addon build, package, tag, release or merge was created. Release still requires explicit authorization. The existing recurring research automation will be disabled after this verified closeout is pushed; its confirmed final state is recorded in checkpoint8cz_automation_completion.json. No duplicate automation, billing change, purchased credits or banked reset was used. This environment exposes no usage-balance/refresh meter; no allowance-exhaustion cause or guaranteed refresh is inferred.

## Completed checkpoints and preserved scope

| Research block | Result and durable evidence |
| --- | --- |
| Initial reconciliation and checkpoints 1–7 | Dungeon-role/source corrections, crafting/material integrity, rare-boss distinctions, book learning versus acquisition and all 954 queued physical book cases. See [durable progress](../../RECONCILIATION_PROGRESS.md), [trainer triage](TRAINER_BOOK_TRIAGE.md) and reviewed registries. |
| Original expanded acquisition queue | All 5,688 frozen weak/unknown-source cases dispositioned through successive bounded checkpoints; 5,902 reviewed gear records include 214 earlier records. No pending marker remains in [original queue](remaining_equipment_research_queue.csv). An unresolved outcome is preserved rather than invented. |
| Navigation restoration and successive source research | Shared pin/resolver, accurate point/roaming-area handling, client-resolved dungeon entrances, full quest/recipe/vendor directions, and follow-on coordinates/chain/source corrections. [Navigation implementation/history](NAVIGATION_RESTORE.md) contains the earlier case evidence. |
| All-slot/Back/source discovery and reward scope review through 8CW | Full-source deduplication and individual identity/version/printed wearer/class-policy decisions. Six completed physical books were reused after correcting bookItemID versus finished itemID exclusion. Final quest Series prefixes stop at the selected reward. [8CW closure](CHECKPOINT8CW_FINAL_REWARD_SCOPE.md). |
| 8CX | Primary merchant standing adapter; 254 source-only actor locations; Copper Mace/Axe spell mappings 2737/2738; exact fresh upstream delta investigation and full validation. [Case](CHECKPOINT8CX_SOURCE_RANK_LOCATIONS_AND_MAPPINGS.md). |
| 8CY | Seven new feed cases closed using cached full pages; 38 further full source-location records; 496 stale register labels aligned to completed proofs. All 1,425 candidate cases / 923 shared all-slot cases dispositioned; shared queue is a subset, not extra cases. [Case](CHECKPOINT8CY_FRESH_SCOPE_AND_SOURCE_POOL.md). |
| 8CZ | Final queue/canonical/coverage/source-exception integrity, gap dispositions, this handover and automation closeout. [Integrity](checkpoint8cz_final_integrity.json). |

The retained cache audit covers **3,130 full source pages**, with no unqueued typed equipment or raw quest reward references and no parse errors. It is closure of the current discovery evidence, not a guarantee of all future/worldwide content. New information still goes through the same exact-ID deduplication and shared research queues.

The current catalogue preserves **7,707 equipment IDs / 36,341 class objectives / 1,254 crafts / 4,857 ingredients**, the **954 reviewed recipe objects**, 35 global quest-chain/reference records, stat/armour/BoE filters, settings, layout and material calculations. The evidence index has 7,373 ID sources, 7,372 displayed additions and 759 indexed physical book IDs. Different recipe/index totals describe different scopes; they are not interchangeable.

## What happened to the map button

Git history shows the button was **not deleted**. Commit `8923044` created NewAcquisitionPin in both views; `78d177a` extracted MapNavigation.lua. The 22px compact / 24px detailed pin remained, but only 111 of 7,707 items had acquisitionLocation data (105 points/six zone-only records; 71 in Redridge), and the old adapter recognized only 15 zone names. This was a data-coverage regression plus a limited map adapter, rather than missing artwork.

The existing pin and row geometry are reused. One context-sensitive icon handles every source type; its tooltip describes the destination. A unique destination opens directly. Alternatives use a lightweight six-choice paginated selector and right-click selection; selecting another item replaces the old popup/destination. The detailed guide uses the same resolver, with “Where to go” and full source/quest/vendor/recipe/access instructions. Missing precise coordinates open qualified directions when useful; generic random drops do not acquire fabricated farms.

The source pool is separate from UI coordinates. Exact NPC/object IDs, full provenance, map/zone frames, verified coordinates or roaming bounds, recipe-learning versus special crafting locations, quest starting/turn-in/objective roles, alternatives and access qualifications serve both views. Subsequent source-only research updates existing and future exact routes automatically. Unused actors remain in evidence until a real route references them; they do not inflate active coverage.

## Categories supported and catalogue-wide coverage

Quest rewards, published quest chains and current/unknown progress; direct, limited-stock, reputation, special-currency/ACA and unlock vendors; physical recipe vendors, independently matched trainer teaching and special crafting destinations; named dungeon drops/recipes/quests/containers; rare NPCs, objects and fishing references are supported where reliable destinations exist. Recipe books, learned spells, finished gear, material inputs and loot containers remain distinct. Source level/reputation and wearer requirements are not silently substituted.

**No actual-client map rendering has been verified: that count is zero.** “Published coordinate data” below means a cited point exists somewhere in the route data, not that an end-to-end pin, quest progression, native entrance, current access or live stock was tested. A route may still be withheld by a source/version/progression qualification. Directions can be reference-qualified or intentionally use an area rather than a point. These categories do not certify current loot.

| Current catalogue outcome | Items |
| --- | ---: |
| Published coordinate data; actual client acceptance pending | 885 |
| Written/area/entrance directions; precision/current access may remain qualified | 1,581 |
| Missing actionable location information | 3,085 |
| Map navigation not applicable, including generic random origins | 2,156 |
| Total | 7,707 |

Every ID is listed in [navigation_coverage.csv](navigation_coverage.csv); source-specific gaps remain in the existing [navigation_research_gaps.csv](navigation_research_gaps.csv). No missing item is counted as successfully implemented navigation.

| Catalogue category | Point data | Directions | Missing | N/A |
| --- | ---: | ---: | ---: | ---: |
| world_drop | 133 | 419 | 35 | 2156 |
| dungeon | 9 | 684 | 0 | 0 |
| quest | 64 | 31 | 167 | 0 |
| crafting | 163 | 181 | 886 | 0 |
| vendor | 467 | 260 | 770 | 0 |
| unknown | 45 | 0 | 1210 | 0 |
| reputation | 0 | 2 | 0 | 0 |
| fishing | 0 | 1 | 0 | 0 |
| dungeon_recipe | 4 | 3 | 17 | 0 |

All nine classes use the same resolver and evidence. Class totals overlap by item and sum to 36,341 objectives, not 7,707 unique IDs.

| Class | Point data | Directions | Missing | N/A |
| --- | ---: | ---: | ---: | ---: |
| PRIEST | 310 | 707 | 827 | 783 |
| MAGE | 309 | 679 | 718 | 765 |
| WARLOCK | 313 | 674 | 709 | 765 |
| DRUID | 460 | 978 | 1209 | 1211 |
| ROGUE | 434 | 968 | 1052 | 1185 |
| HUNTER | 559 | 1235 | 1400 | 1672 |
| SHAMAN | 584 | 1250 | 1455 | 1820 |
| WARRIOR | 641 | 1464 | 1626 | 2054 |
| PALADIN | 627 | 1319 | 1529 | 2050 |

## Catalogue corrections and source confidence

Corrections include separating Idol of the Dream 220606 from dungeon loot (Enchanting 300, spell 1249128, formula 249529), the independently evidenced Centaur Hoofwarmers craft 274490, rare-boss versus trash/container roles, item-locked merchant/quest alternatives and fees, physical predecessor rewards versus ordinary crafting, and recipe-book acquisition versus finished-equipment loot. All pre-existing ingredients remain intact; the two supplementary crafts account for the 1,252→1,254 craft total.

Copper Mace 2844→2737 and Copper Axe 2845→2738 now have independently matched full item/spell/trainer evidence and reusable Alphonse Dumas trainer destinations. Learning skills 15/20 are not wearer level 4, and published training fee 50 copper is not guaranteed live service.

Primary merchant raw standing **6=Revered / 7=Exalted** is normalized to client IDs 7/8. Raw zero lists no gate. Malformed/boolean values do not acquire a rank. Manual/client offers retain their one-based convention (client rank 6=Honored). The independent full 274022/280363 merchant/item records calibrate this rule. Prices remain seller-specific alternatives: 274022’s own quote 52,631 copper versus full/base 50,000 remains a discount/price uncertainty, not a universal fee or inferred gate.

Full primary item identities/tooltips and exact item↔NPC/object/quest joins provide strong **publication** evidence. Classic/unconfirmed/version warnings are preserved. A book’s existence does not establish current merchant stock or trainer teaching; trainer routes require exact spell, output, name and profession matches. Full quest Series establish reported travel order, not necessarily every mandatory current branch/unlock. Reliable client APIs can choose an active/next incomplete researched stage; missing/error/unknown progress falls back to the documented start or qualified directions. Completion does not prove which reward was selected.

Published Forever instance definitions and guides establish named geography/written approaches, not invented boss floors. For Krol’dok, full guide/zone evidence supplies the written approach and six published encounters; pet adds are not extra bosses and unnamed/unread reward placeholders remain held. The guide cannot create a UI map ID or entrance coordinate by itself.

Playfulls is a credited community source; Everloot supplies attributed anonymous observations. Those are not personal/current-build live confirmation. Final actual local capture is PF **23,642 items / 9,328 full source objects** and EV **1,873 relations / 1,583 qualifying item relationships**. The entire 8CX→8CY parsed source data is exact except four generatedAt values; complete earlier deltas remain preserved. CI bot API bodies were not independently read, and equal counters were not treated as equivalence. Full source hashes, joins, omissions and limitations are retained in checkpoint proofs; failed responses have no invented body hashes.

## Remaining exceptions and exact continuation

There are **17,404 overlapping gap rows**, not 17,404 unique items or extra queued checkpoints. The [gap disposition table](checkpoint8cz_navigation_gap_dispositions.csv) categorizes every current gap type without changing its factual status. Important groups include 3,085 missing actionable destinations, 895 missing source coordinates, 885 missing quest starts, 156 unresolved quest-chain relationships, 5,974 imprecise/area references and 3,339 intentionally withheld targets. Counts overlap across alternate sources and include qualified dungeon/container/quest access references.

A full Series or final turn-in cannot substitute for a verified chain start; source roles, faction/class branches and quest-start item farms must be independently known. Roaming NPCs are correctly represented as areas; a missing exact point is not solved by inventing a centroid. Instance-floor/key/access gaps use entrance/written guidance. Unconfirmed versions and unknown origins do not gain markers.

Six dungeon acquisition links remain unconfirmed for the current realm:

| Item | Named lead | Publication confidence |
| --- | --- | --- |
| 10801 Slitherscale Boots | Spawn of Hakkar | forever-community-reference |
| 11945 Dark Iron Ring | Dark/Relic Coffer | historic-container-reference |
| 11946 Fire Opal Necklace | Dark/Relic Coffer | historic-container-reference |
| 14525 Boneclenched Gauntlets | Ras Frostwhisper | forever-community-reference |
| 23173 Abomination Skin Leggings | Sever | forever-reference-unverified |
| 273044 Arcanowisp Robes | Arcanic Enigma | forever-reference-unverified |

The complete records and URLs remain in [dungeon_source_followups.csv](dungeon_source_followups.csv); all six retain needsLiveVerification=true. The **954 physical book cases are publication-researched, not 954 live-verified routes**. Retain unknown named origins, alternatives, disputed access and unavailable-version qualifications. Current stock, limited supply, source acceptance, fees, unlocks, container opening/retention and drop conditions still need fresh reliable or live evidence where flagged.

The shared [failed-read ledger](checkpoint8cw_known_failed_reads.json) contains **1,732 distinct previously failed URLs**. Do not repeatedly retry unchanged URLs or infer retirement/absence from unread pages. The eight-group book triage, item-specific proofs and current gap file supply the exact affected IDs; there is no disconnected second research queue.

The [candidate register](additional_catalogue_coverage_candidates.csv) and [authoritative research queue](additional_catalogue_research_queue.csv) preserve all **1,425 decisions**. **900 outside-catalogue references pass the published baseline**; none was silently adopted. They need a separate development/adoption pass with complete item facts, existing class/slot/quality policy, source qualifications and catalogue tests. There are also 287 missing-printed-wearer holds, 64 version holds and explicit quality/type/unread/placeholder/book-reuse outcomes. Do not treat these as 1,425 missing current items, 900 live upgrades, or a release-ready catalogue expansion.

The next executable work is **actual Forever-client acceptance and targeted new evidence for these exceptions**, followed by development review of outside-catalogue candidates. Reopen exact item/source IDs when a genuinely new reliable location, prerequisite relationship or in-game result appears; reuse the existing source model, queues and gap reports. No uncommitted state or chat-only memory is required to resume. [Machine-readable continuation](checkpoint8cz_resume.json).

## Client/API compatibility and validation

Supported interface behavior was independently checked against Gethe/wow-ui-source’s **forever** branch at `4cd0ab752a77164f654ccbca9d0c1fe8dafceebe`, with blob/source fingerprints in checkpoint_navigation_evidence.json. C_Map map inspection/opening, guarded global/OpenWorldMap/WorldMapFrame fallbacks, C_EncounterJournal.GetDungeonEntrancesForMap, quest state APIs and world-map canvas/hide behavior exist in that source. This is not a retail-only API assumption or installed-client rendering test. No TomTom or third-party addon is required.

One addon marker/roaming area is reused and labelled; it hides on other maps, close, world entry and relevant quest refresh. Native user waypoints are preserved. Native dungeon entrances are used where supported; missing entrance/floor information produces directions rather than an inaccurate point. Zone/map IDs are validated; switching destinations/maps and missing/error/unknown API fallbacks are tested with doubles.

Latest full gate: source **5a2b557d913e8e57688f8232e7073f3725c25b47**, [nonrelease CI 43406651194](https://github.com/magicaddons/getgear/actions/runs/43406651194), job 131822497647; **19 local / 18 timestamped CI checks passed**, all 26 addon modules and four Python tools/exporter syntax checked. Whole direct bot **dfc312057884f20670c83166f27c1be47df142d3** was reviewed: four Everloot response hashes and run timestamp only; all other committed bytes exact. [Validation](checkpoint8cy_validation.json), [local results](checkpoint8cy_local_results.txt), [CI checks](checkpoint8cy_ci_results.txt). The final documentation-only 8CZ checks queues, proof hashes, full coverage, gap dispositions, links and protected bytes; it does not claim another full suite.

Automated cases cover simple quest, long chain, different starting/turn-in actors, direct vendor, limited recipe vendor, ACA, dungeon boss, dungeon recipe, dungeon quest, alternatives, named rare, generic random drop and incomplete location data. They check compact/guide consistency, progress unknown/error/active, no fake coordinates/random farms/prerequisites, future evidence propagation, source rank conventions, recipe/output guards, native waypoint preservation, marker lifecycle and existing nine-class/filter/material/layout/performance regressions. Actual renderer/gameplay outcomes remain manual.

## Exact in-game acceptance before the next beta

Use the active source only through your authorized development install/build process; no new build was created here. Enable Lua errors, record actual client build/locale, and compare compact overlay, detailed guide and `/getgear map ITEMID` (the command bypasses class visibility filtering for lookup, not eligibility).

| Case | Command/action and required result |
| --- | --- |
| Simple quest | `/getgear map 263329`: Flutterfly Swatter’s published source/zone and guide instructions; use directions where no point is established. |
| Long chain and distinct start/end | `/getgear map 2042`: unknown progress starts at Gryan/Westfall with qualified seven-stage Defias instructions; inspect quest 65’s separate Wiley/Redridge turn-in. With reliable active/completed quest state, verify the next researched stage; no false reward-selection or unknown-unlock claim. |
| Equipment vendor and alternatives | `/getgear map 2506`: select different Hornwood Recurve Bow merchants; labels/maps update and right-click choices work without cluttering the compact row. |
| Limited recipe | `/getgear map 5780`: named recipe vendors, limited-stock qualification and recipe-learning destination; no live-stock guarantee. |
| ACA | `/getgear map 250513` and `/getgear map 220606`: Stondry/Alynsia, Redridge, Merchant’s Favor and published Honored qualification; recipe acquisition differs from finished crafting. |
| Dungeon boss | `/getgear map 1155`: Blackfathom Deeps entrance/Kelris guidance and any qualified alternative; no guessed boss-floor point. |
| Dungeon recipe | `/getgear map 252455`: separate Blackfathom/Razorfen Kraul possibilities and recipe-source uncertainty; never claim the finished helm drops. Missing native entrances fall back to directions. |
| Dungeon quest | `/getgear map 2042`: distinguish outside starting/turn-in NPCs from the VanCleef dungeon objective. |
| Rare/roaming area | `/getgear map 1404`: Prince Nazjak’s Arathi footprint/qualified directions, not a fake exact spawn. |
| Object and key | `/getgear map 18706` and `/getgear map 9359`: named Arena Master and Captain’s Chest; lamp/key/physical-footlocker distinctions and published area stay clear. |
| Newly mapped trainers | `/getgear map 2844` and `/getgear map 2845`: Alphonse Dumas; spell/learning skills 15/20, published fee and side/access qualification; no fabricated physical recipe book. |
| Random world drop | Item 1713 retains no normal dedicated-farm pin; lookup provides existing information without inventing a destination. |
| Incomplete data | Item 273884 retains missing/unknown acquisition qualifications and no precise pin. A held candidate such as 285066 is not silently added to the current catalogue. |
| Layout/lifecycle/fallbacks | Start with a native user waypoint. Alternate at least 20 pin clicks, switch zones/maps/floors and return, zoom/resize, close with Escape/map toggle, reopen, refresh/accept/complete quests and test in combat. Exactly one correctly labelled addon marker/area; no stale marker/accumulated frames; native quest markers/waypoint unchanged; normal closing works. Verify single icon alignment, tooltips, chooser pagination, guide scrolling and closable directions. |

**Beta readiness:** implementation and offline data handling have passed automated review and are ready for in-game QA. Inclusion in the next beta should follow the manual matrix and any resulting fixes. This is not release authorization or a claim of full current-live acquisition/map coverage. Prioritize real starting points/chain branches, ACA/vendor access and dungeon entrances, then fill high-value missing locations and review the 900 outside candidates with the existing class/stat filters.
