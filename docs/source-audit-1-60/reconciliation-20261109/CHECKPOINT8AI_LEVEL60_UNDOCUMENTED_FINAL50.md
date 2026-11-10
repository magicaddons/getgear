# Checkpoint 8AI — final 50 undocumented level-60 acquisition cases

Status: publication research/integration and full local/non-release CI42768530618 PASS; directbot2b51ecb385f4e9a9d2afb6a5217821326b0ca7a5 reviewed. All1,162 cases in the frozen undocumented queue are now publication-researched. This closes the research queue, not unknown origins or current live verification.

## Scope and next checkpoint

Selected50 IDs280918–284716. Equipment registry2,825/index4,474/display4,473; all previous2,775 registry objects unchanged. Frozen remaining3,077:190 quest and2,887 world-drop. After full CI/bot review, **8AJ: first12 level-60 quest cases, IDs19019–21188** (Thunderfury, four Darkmoon cards, three Dragonslayer rewards, two Darkmoon jewellery rewards, Malfurion's Signet Ring and Fist of Cenarius). Then review the15 legacy Nozdormu rings as a separate exact-ID group; do not copy the previously researched newer rings' source/gates.

[50-case table](checkpoint8ai_undocumented_equipment.csv), [working evidence](checkpoint8ai_working_evidence.json), [52-query index](checkpoint8ai_discovery_index.json), [local results](checkpoint8ai_local_results.txt), [semantic comparison](checkpoint8ai_upstream_review.json) and [raw feed comparison](checkpoint8ai_raw_upstream_review.json) preserve the item-level scope.

## Findings and confidence

| Group | Cases | Published identity/equip evidence | Origin confidence |
| --- | ---: | --- | --- |
| Hyjal-family armour |49| Exact aggregate-cache IDs/names, item65/equip60/BoP/classes/sets | Cached publication only; full primary item pages404, cache source Unknown |
| Band of the Better Half284716 |1| Exact full primary item response, item70/equip60/Epic/BoP/Unique-Equipped, set2131 | Primary has no acquisition table; actual news/secondary pages explicitly leave its origin unknown |

Forty-nine cached class projections match the canonical catalogue: seven Priest,18 Paladin,18 Shaman, six Druid. Thirty-two have different-ID canonical namesakes. Those lower-ID crafted/gear versions, including Spiritcaller276538–276541, do not transfer learned recipes, BoE binding, Artisan limits, materials, book sellers, skill or reputation gates to selected280xxx IDs. Sets/procs do not create specialization-only eligibility.

The [public Forever cache](https://raw.githubusercontent.com/Napalmsteak/WoW-Classic-Item-Caches/main/Forever%20Cache.json) has all50 IDs; each of the49 missing-page records says Unknown source and lists no boss. The full cache read from8AH is explicitly reused, not described as a fresh current acquisition observation. Its18,590,138-byte SHA25686a387d5274635ebff1589b8702792fc8c0bfdb55df2ae29ec31a4c894f18e3a matches fresh8AI reconciliation provenance. The [AHledger aggregate](https://www.wowforeverfriends.org/items/items.json),16,908,600bytes/SHA256e0a86115fc289b5c9914b6212e0b178f3e2e1777429c08eaaf4b586277c01fba, contains none of the selected50 and also matches fresh provenance. Its old coverage/update is not current live evidence.

Every49 direct primary attempt returned404. Four representative reader fallbacks280918/280928/280951/280977 were inaccessible too. No missing item page has a fictitious successful HTTP hash or an inferred unavailable-to-players warning. Actual aggregate fingerprints and clearly labelled record-projection hashes are distinct. Cache timestamps do not establish loot events.

The exact secondary [Halo280918](https://forever.undrwrldcub.com/db/items/item-280918/) and [Spiritcaller Helmet280951](https://forever.undrwrldcub.com/db/items/item-280951/) records call origin Unknown and Hyjal Summit merely expected from model tags. That is speculative family context, not a named selected boss drop or current raid-access proof.

## Band of the Better Half: source-role discrepancy resolved

Primary [284716](https://www.wowhead.com/forever/item=284716) lists only24 see-also entries, with no seller/quest/drop/creation table and no explicit unavailable/seasonal warning. Set2131 Partners in Crime pairs it with **First Mate Band284715**, a separate equip17 item. Existing catalogue evidence for284715 is the dated Mr. Smite/Deadmines reference; this checkpoint preserves it.

The actual [21Sep Wowhead news body](https://www.wowhead.com/classic-ptr/news/wow-forever-introduces-new-item-sets-dungeon-and-endgame-items-mixed-383002) reports Mr. Smite for First Mate Band and explicitly states that Band of the Better Half's source is unknown. Neither the sibling's source nor a displayed1.01% rate applies to284716.

A misleading search snippet from the [First Mate Band gear page](https://forever.undrwrldcub.com/db/gear/gear-first-mate-band-the-deadmines-284715/) combines the selected ring's name with Dropped by Mr. Smite. The actual page gives Band of the Better Half a separate Finger/Unknown row. This resolves the snippet's scope without reopening or changing the completed sibling research.

The exact-ID [ForeverDB page](https://foreverdb.net/item/284716) also says the source is unknown. Its revealed/found/cache language does not identify an observed loot actor. The primary sell field is45,322c(4g53s22c); the secondary gives9s3c. These are conflicting sell/reference values, not accepted purchase or auction costs. No older set/stat or Classic disenchant table is adopted as a correction.

Unique-Equipped is not Unique ownership or the Watcher ring-family restriction. Strength/Expertise does not impose a Warrior/Rogue-only gate. No marriage quest, Mr. Smite source, level60 boss or profession is guessed from the name, set or stats. Current acquisition and retention remain unverified.

## Validation and outstanding work

- Full14 Lua regressions, offline Python dungeon-link guard,24 modules/four reports/capture-helper syntax: PASS.
- Exactly50 additive-summary cells changed; zero other derived semantic/offset changes. Canonical7,707 IDs/36,341 class objectives, nine classes, armour/stat/BoE filters, settings,1,254 crafts/4,857 ingredients and all six dungeon exceptions remain intact.
- Seven original same-run HTTP responses match recorded provenance; no duplicate diagnostic feed requests or replay/fallback.
- Playfulls23,352 items/9,153 definitions and Everloot1,399 raw/1,199 qualifying edges: exact local fact/counter snapshots unchanged, zero selected observed edges.
- 107 outside-canonical9A candidates remain separate and unaudited.954 current-live book routes and six dungeon exceptions remain open.

All1,162 undocumented cases have traceable researched dispositions, including honest unresolved cases. Continue the190 quest/world2,887 queues and candidate audit. Later in-game work must determine current named origins, stock/access/accepted costs, set/equip behavior and retention. No release build/package/tag/publish, Beta8 replacement, main modification or billing action.


## Checkpoint 8AI validated — next 8AJ

Full local/GitHub PASS: [42768530618](https://github.com/magicaddons/getgear/actions/runs/42768530618), source8ad3a37edcf6c951d157ff6b84000595bba0168e; inspected direct bot/final validated 2b51ecb385f4e9a9d2afb6a5217821326b0ca7a5. All14 Lua regressions, offline Python guard,24 modules/four reports/helper syntax pass;15 timestamped CI test-PASS lines inspected. Bot changes only run time/three Everloot response hashes; no runtime/report/index/count changes or claimed independently captured bot response bytes.

Final50 undocumented cases complete:49 primary404/cache-identified unknown origins,49 class projections(7Priest/18Paladin/18Shaman/6Druid),32 different-ID namesakes not source/craft/binding transfer;one primary Band of the Better Half284716. Actual21Sep news explicitly leaves its origin unknown; Mr.Smite/1.01%/Deadmines evidence identifies sibling FirstMate284715. Misleading search snippet resolved by actual secondary page's selected Unknown row. No purchase price, ownership/class gate or old-stat correction invented. Canonical identity/eligibility and prior2,775 objects exact;50 summary cells only/all six dungeon exceptions retained.

Equipment2,825/index4,474/display4,473/books759;crafts1,254/ingredients4,857. Seven same-run actual HTTP captures match provenance; both reused aggregate fingerprints also match fresh regeneration. Local Playfulls23,352/9,153 and Everloot1,399raw/1,199qualified exact facts/counters unchanged; zero selected observed edges.107 outside-canonical9A candidates remain separate/unvalidated. **All1,162 frozen undocumented cases publication-researched**, unknown origins/live exceptions not closed. Frozen queue conservation5,688=2,611researched+3,077remaining;equipment214+2,611=2,825. Remaining190quest/2,887world-drop. **Next8AJ:first12quest60 IDs19019–21188**, markedqueue; then15 legacyNozdormurings before laterAQ/Naxx groups. All current-live book/dungeon/access/supply/retention exceptions remain. No release/main/billing action.
