# In-game acceptance handover 1 — fixes and validation

Scope: the six reported findings only, starting from `4df9a03fc5033fd9067e0fa573129a4b6cbb5fd2` on `work/full-acquisition-reconciliation-20261109`. The completed comprehensive research programme stays closed. No new package, tag, public release, merge, candidate adoption or automation action.

## 1. Copper Mace: trainer prioritisation

**Confirmed underlying cause:** only a very small pool of full, independently joined trainer teaching records was available to navigation. Its 21 exact spell-linked trainer routes covered 21 crafted items; selecting the only known route made Alphonse Dumas in Riverglades appear to be the default/exclusive teacher. This was incomplete evidence coverage and selection policy, not proof that other teachers lacked the recipe.

**Fix:** 18 full profession-trainer pages provide 349 additional exact spell/output/name/profession teaching relationships. There are now 370 such routes across 147 crafted items (126 additional items gain a verified-at-publication teaching alternative). Generic selection prefers an eligible trainer in the player's current map/zone, using distance only within that exact map frame when player coordinates are available; otherwise it prefers a faction-appropriate capital, then other eligible teachers. Friendly-service qualification comes from the full NPC page, never its profession title. Alternative destinations remain in the selector.

For Copper Mace 2844 / spell 2737, published teaching includes Smith Argus in Elwynn, Bengus Deepforge in Ironforge and Therum Deepforge in Stormwind; Alphonse remains an alternative. Published minimum: Blacksmithing 15. Source: [spell 2737](https://www.wowhead.com/forever/spell=2737), [Smith Argus](https://www.wowhead.com/forever/npc=514), [Bengus](https://www.wowhead.com/forever/npc=4258), [Therum](https://www.wowhead.com/forever/npc=5511).

**Tests:** nearer same-map teacher, capital fallback without reliable location, exclusion of a known opposing service, retained alternatives, exact teaching joins and future-source propagation pass. These are publication references; current teaching, cost, player access and map rendering still require client verification. Only independently researched teachers enter the pool, so coverage is not a claim to list every trainer worldwide.

## 2. Rugged Leather Pants: random pattern references

**Confirmed:** the broad pattern-drop table could read like travel/farming instructions. Pattern 7288 and spell 9064 explicitly publish Leatherworking 30. The full spell response supplies no taught-by-NPC rows, and the checked capital trainer inventories do not establish a trainer alternative. This does not prove that no trainer anywhere teaches it.

**Fix:** shared data marks the broad physical-pattern drop component. The compact summary calls these random-drop examples rather than farm directions; the guide retains the original source evidence, other qualified routes and a conditional player-trade/Auction House alternative, with listings explicitly unknown. No destination is fabricated from a broad table. **114 crafted-item records** receive the qualification, using the reviewed book metadata's broad table (at least ten retrieved NPC rows). This flag qualifies the broad component; it does not erase independently known targeted alternatives.

Sources: [pattern 7288](https://www.wowhead.com/forever/item=7288), [spell 9064](https://www.wowhead.com/forever/spell=9064). **Tests:** broad source summary/directions, conditional trade wording, no random-farm pin and existing targeted-route boundaries pass. Live pattern drops and actual trade availability remain unverified.

## 3. Handstitched Leather Belt: numerical skill minima

**Confirmed:** research evidence contained explicit numerical learning/recipe minima, but much of it never entered a shared runtime field. UI also replaced the number with “Learned” for known recipes. Skill-up colors are separate source fields.

**Fix:** the shared model imports explicit `learnedat` only after canonical spell/output/name/profession joins; exact trainer learning requirements and book-learning minima remain distinct. Conflicting or malformed minima stay unresolved; orange/yellow/green/grey thresholds are retained for review and never substituted. Both normal and preview displays show the known number, including learned recipes. Existing optional crafting-visibility gates are preserved; this presentation improvement does not silently turn learning thresholds into new crafting gates.

Handstitched Leather Belt 4237 / spell 3753: **Leatherworking 25**, independently published as `learnedat=25`, versus colors `[25,55,70,85]`. Rugged Leather Pants: 30 versus colors `[30,60,75,90]`. [Belt spell](https://www.wowhead.com/forever/spell=3753).

Of **1,254 crafts, 1,135** now expose a reliable numerical requirement, **972 newly numerical** relative to the previous verified field; **119 remain unknown**. Known counts: Leatherworking 403, Blacksmithing 360, Tailoring 304, Enchanting 34, Engineering 33, Alchemy 1. A displayed book-learning minimum is identified as such in directions, not asserted to be a different crafting minimum.

**Tests:** all six professions, deliberately different minimum/colors, book-versus-recipe distinction, invalid boolean minimum, numerical learned-label rendering and unknown preservation pass. Publication data is not a live skill/training check.

## 4. Farmer's Shovel: faction and travel relevance

**Confirmed distinction:** 3334's two published Tirisfal NPC references are neutral item sources, not an Alliance prohibition. They are nevertheless poor default travel for a low-level Alliance player. A separate published reward route, Stepping Stones 79192, has a **quest minimum of 14**, distinct from the item's wearer level 5. Full source pages show faction-specific preceding starts: Alliance 79008 at Westfall remains; Horde 79007 at Barrens remains. Follow-up stages and mandatory unlock completeness are not established.

**Fix:** shared route filtering respects known quest/vendor/trainer faction and class restrictions. Faction-specific chain prefixes and actor-side locations choose the appropriate start. A conservative travel preference suppresses the ordinary compact recommendation at level 15 or below when every usable, currently level-appropriate known destination lies in opposing starting territory. This does not label the item faction-exclusive, remove it from the guide, suppress a player already in that zone, or blacklist arbitrary Horde-zone items. Known later quest routes remain visible with their actual access minimum and qualified prerequisites. No false live completion knowledge is introduced.

For measurement, evaluating **all Druid catalogue records** as Alliance level 5 with location unknown yields 16 faction/class-only exclusions and 31 opposing-starting-territory exclusions. These are catalogue-route evaluations across all item levels, **not counts of currently visible upgrades**. Restrictions vary with class, faction, location, quest state and level. The fix is shared, not an item-ID exception.

Sources: [item 3334](https://www.wowhead.com/forever/item=3334), [reward quest 79192](https://www.wowhead.com/forever/quest=79192), [Alliance prefix 79008](https://www.wowhead.com/forever/quest=79008), [Horde prefix 79007](https://www.wowhead.com/forever/quest=79007). The added chain explicitly has `routeVerified=false` and `prerequisitesVerified=false`; published actors/roles do not establish every current unlock. Original 35 chain records remain exact. Existing wearer-level/earlier-item windows are preserved, so this change does not guarantee the old level-5 item stays in a level-14 character's compact lookback window.

**Tests:** neutral hostile-territory source retained in guide, low/high-level and already-in-zone cases, known faction-exclusive quest exclusion, Alliance/Horde starts and published minimum pass. Initial triggers, phasing, current loot and practical cross-continent travel remain manual checks.

## 5. Scarlet Dagger: acquisition confidence versus statistics

**Confirmed:** source/version warnings were descriptive metadata rather than a compact recommendation-eligibility rule. Scarlet Dagger 241089 has no established current acquisition route and should be excluded from ordinary compact upgrades.

**Fix:** a catalogue-wide availability policy separates explicitly unresolved origins/version warnings from actionable sources. **1,076 records** are excluded: **801 origin-unresolved, 275 unconfirmed-version**. Stats, a client listing, a PTR/datamined/cross-version reference or a generic market mention alone do not establish current acquisition. Full-guide records and warnings remain intact. This is independent of the positive-stat and random uncommon-BoE presentation filters; toggling those does not turn unconfirmed origins into established sources.

There is no blanket SoD-origin exclusion. Independently verified manual/current-observed sources are preserved. An independently joined published route can supersede an older origin-unknown finding. Explicit version warnings require reviewed current-source evidence: `availabilityStatus=published-current-source` plus a traceable HTTPS URL and full SHA-256, or retained verified/observed evidence. A disputed physical pattern cannot erase a separately established trainer route. This provides a data-driven reclassification path for future evidence.

**Tests:** Scarlet exclusion/full-guide retention, unresolved-statistics-only exclusion, existing verified source preservation, exact published source superseding stale unknown origin, explicit reviewed reclassification and independent green-BoE behavior pass. This audits existing evidence status, not live availability of all 7,707 items. It cannot discover an undocumented current source by itself.

## 6. Empty slots: zero baseline without false certainty

**Confirmed:** `MakeGroup` returned “No item equipped” before comparing the candidate, suppressing every positive difference. An absent inventory link also did not distinguish a truly empty slot from an uncached occupied item.

**Fix:** inventory occupancy is tri-state. An independently confirmed empty slot uses zero baseline and displays the candidate's complete reported stat benefits. A positive inventory ID supplies an occupied-item fallback when its link is not ready; failed/unknown lookups and uncached stats remain unknown. Invalid IDs are rejected. Rings/trinkets retain separate slot comparisons; two-handed candidates replace both equipped hands, and an occupied two-handed main hand continues to block offhand comparisons. Shirt/tabard physical slot mappings are included. Existing class-aware benefit filtering and armour settings remain independent.

**Tests:** nine classes × **26 slot/type labels**, confirmed-empty benefits (+3 Agility/+2 Stamina/+35 Armour fixture), equipped comparisons, failed occupancy, uncached candidate/occupied data, invalid IDs, both occupied hands and offhand blocking pass. The illustrative fixture values are not attributed to Al'Aketh equipment. Actual Forever inventory/cache behavior still needs manual acceptance.

## Evidence, integrity and validation

- Targeted source checks: **40 full responses, 30 new + 10 reused**, zero failures. All body lengths and SHA-256 checked against the saved full responses; no unchanged known failures retried. See [source integrity](acceptance1_source_integrity.json) and the runtime-input [full evidence extracts](checkpoint_acceptance1_working_evidence.json).
- Fresh normal reconciliation: `acceptance1verified`, eight original HTTP responses captured without duplicate diagnostic feed reads, exit 0. Full local **19/19 PASS**; all **26 gameplay modules** parse with Lua 5.4 and Lua 5.1. **15/15 Lua 5.1 regressions PASS** using a test-only `loadstring`/`setfenv` adapter for the fixtures' modern `load` API; gameplay source unmodified for that adapter. Full synthetic TOC startup passes under both runtimes. See [local results](acceptance1_local_results.txt).
- Non-release CI and whole bot diff inspection: **pending source push**; closure records will supply the exact run/source/final bot commits. Do not treat this pending entry as completed CI.
- Preserved: 7,707 gear identities, 36,341 nine-class objectives, 1,254 crafts, 4,857 ingredient rows, 954 reviewed book objects, all 5,902 prior equipment objects except additive navigation-only fields on 3334; 900 held outside candidates untouched. Existing stat/armour/green-BoE, preview/layout, materials, guide and marker lifecycle regressions pass. No settings migration or release identity change.
- Navigation audit: **897 published-coordinate-data / 1,683 written directions / 2,971 missing / 2,156 N/A**; 17,634 overlapping research-gap rows. These include additional recipe teachers and quest actors. **Actual map rendering remains unverified**; coordinate-data counts do not mean verified live pins.
- Incidental upstream feed changes from the required rebuild are documented in [upstream review](acceptance1_upstream_review.json). All changed companion CSV cells were inspected: only source-row remapping and 72 recipe report cells removing upstream faction suffixes from zone labels, not changes to reviewed faction restrictions. Canonical item/source summaries and runtime acquisition-evidence index stay exact. Seven new feed IDs were not adopted or added to the closed research programme. Original diagnostic snapshots retain their original 8CY provenance.
- Record-level impacts are listed in [affected records](acceptance1_affected_records.csv); overlapping categories should not be added together.

## Next in-game acceptance

1. On the Alliance Druid, open Copper Mace navigation in Elwynn and then with location unavailable/in a remote zone: verify local trainer versus faction-capital preference and alternative selector; confirm each teacher actually offers the recipe at the published minimum.
2. Inspect Rugged Leather Pants and its pattern: confirm Leatherworking 30, clear random-drop qualification, guide evidence and conditional trade text; no invented broad-table farming pin.
3. Inspect Handstitched Leather Belt before and after learning: number 25 stays visible in normal/preview displays; unknown minima still say unknown. Check other professions and all current crafting visibility/material settings.
4. At low Alliance level, Farmer's Shovel should not suggest Tirisfal as an ordinary compact trip. Full guide retains neutral drops and qualified level-14 quest alternative. Check Alliance versus Horde starts, active quest priority and normal manual access. Confirm staying in Tirisfal or higher level does not create blanket exclusion.
5. Scarlet Dagger remains absent from compact recommendations even when green-BoE or positive-stat filters are disabled; full guide retains its availability warning. Confirm known current equipment/recipes are still shown normally.
6. Empty gloves and other slots show actual client stat gains; equip/remove an item, wait for item cache, test rings/trinkets and one-hand+offhand/two-hand transitions. Unknown data must not become zero or invent benefits.
7. Repeat existing guide/compact pin tests: multiple sources, quest start/turn-in, dungeon entrance fallback, native waypoint preservation, switch maps/items, close/reopen map, no accumulated markers. Check overlay layout, next-five-level/earlier views, nine-class preview, status/hide, materials and both existing filter toggles.

**Stop here after validated fixes. No replacement beta ZIP has been created. Await the next user acceptance handover.** Automated Lua/API fixtures establish local logic and integration only, not actual Forever compatibility, map rendering, live NPC inventory/loot or quest phasing.
