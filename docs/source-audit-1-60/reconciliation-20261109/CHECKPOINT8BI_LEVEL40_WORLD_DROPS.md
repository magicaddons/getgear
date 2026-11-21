# Checkpoint 8BI — 100 level-40 acquisition cases

Status: publication research/integration verified; full local 19 PASS and non-release CI 18 PASS; generated commit inspected. No release authorised.

## Scope and preserved progress

Resume from verified navigation closure61e6821. The100 own full item responses and24 original discovery queries were preserved without rerequests. Complete the remaining76 exact queries, source joins and qualifications; all100 selected IDs are represented in [case evidence](checkpoint8bi_equipment_evidence.csv), [primary proof](checkpoint8bi_working_evidence.json) and [discovery index](checkpoint8bi_discovery_index.json). All prior4,584 reviewed equipment objects are semantically exact. The954 recipe-registry objects,1,254 crafts,4,857 ingredients,7,707 identities and36,341 nine-class objectives remain unchanged.

99 broad drop cases and one object/container case;100BoE,90Uncommon/8Rare/2Epic. No new gear class-mask, primary unavailable or Season-of-Discovery warning was found on these exact item pages. Published facts do not prove current live supply or loot. The original catalogue's eligibility, item stats, equip levels and filters are untouched.

## Source findings

- **Southsea Lamp9359:** no direct enemy relationship in its item table. Independently read full Captain's Chest142184, Pirate's Footlocker9276 and Cuergo's Hidden Treasure9265 each contain this exact lamp. None guarantees a lamp roll. Captain's Chest has a published Tanaris footprint x76.4–76.5,y45.7–45.8, represented as an area rather than an invented centre point.
- **Opening context:** Captain's Key9249 independently names object142184 in its unlock table; the full footlocker contains that key. Five full Southsea NPC inventories independently list physical footlocker9276, and none independently lists the lamp. The box's ten possible contents include lamp/key/map fragments, not a guaranteed bundle. Item level45 does not establish an opening minimum; the rendered box has no Requires or Locked line. Current key consumption, other opening methods, supply and chest access remain unverified.
- **Distinct routes:** Captain's Key9249 / Captain's Chest142184 differ from Cuergo's Key9275 / Pirate's Treasure!142194. Completed Cuergo, AQ30/AQ40 supplies, Hoard and Lesser Darkmoon Prize research is explicitly reused, not repeated. Quest-box rewards are not guaranteed finished gear. Preserve alternative donation costs, commendation rewards versus signet inputs, faction access versus equip gates, and unread source/prerequisite pages.
- **Ankh of Life1713:** Rare/BoE, Trinket, equip40/item45, Unique-Equipped rather than possession Unique. The item and independently read Heal1317424 Used-by-Item relation agree on648–792 target healing; the item says five-minute cooldown. Spell level30 and spell cooldown n/a do not replace item equip40 or remove that cooldown. This is an equipment effect, not a learned recipe/class-only source or measured current combat result.
- **Discrepancies:**146 independent object joins, but own Jouster's Greaves8160 names Large Iron Bound Chest75297 while its full174-row contents omit that item. Of144 physical-container references,117 reverse joins are positive;26 Cuergo9265 full225-row omissions plus one Hoard10569 full206-row omission remain one-sided. No cap, current absence, retirement or guaranteed alternate contents is inferred from those lengths.

## Evidence and confidence

415 exact item/full-NPC joins from13 ordinary source inventories; nine objects and11 physical containers.180 distinct case full-primary responses (117 original new/63 cached), plus one cached feed identity reference =181 unique responses,117 original new/64 reused. Only17 new full reads occurred in this continuation;100 earlier own responses were retained. Zero new failed reads; all127 known failed URLs preserved without unchanged retries. All100 cases have an exact discovery query; secondary Classic percentages, client metadata, hidden-until-drop statements and “confirmed” property badges are not promoted to current named-loot evidence. No secondary HTTP fingerprints are invented.

Full source URLs, exact response byte counts/hashes, identity, relationships, positive joins and omissions are in the proof. Sources are published Forever references, with `liveVerified=false`; zero researcher in-game verifications. Actor names, level, reaction or profession do not impose new wearer restrictions.

## Shared navigation and necessary maintenance

The new researched Captain's Chest area/key context automatically enters the existing single context-sensitive pin. No second navigation queue or item-specific UI coordinates were introduced. Generic world drops retain no misleading farm pin. Reviewed typed object context and the primary object relationship merge into one destination. Local tests assert the real9359 area and exact key context.

This review verified that primary vendor price tables can wrap alternative price triples. The shared formatter now accepts wrapped and existing flat prices, preserves game currency/item components and displays alternatives with OR, not a sum of fees. Tests cover wrapped12-ticket currency and distinct coin/key price alternatives. This fixes an actual data-shape deficiency without changing published prices, charges or requirements.

Navigation audit:681 published point-data /1,267 useful directions /3,171 missing /2,588 not applicable; all7,707 IDs/36,341 class objectives,6,339 overlapping shared gap rows. Rendering verified0; the existing manual client matrix remains open. [Navigation audit](navigation_audit.json), [coverage](navigation_coverage.csv), [gaps](navigation_research_gaps.csv).

## Fresh reconciliation and validation

Final8BI capture completed successfully before the full sequential19 localPASS (15Lua+3offlinePython+required files/syntax);26 Lua modules/four Python tools/exporter syntax. [Results](checkpoint8bi_local_results.txt). All eight actual same-run feed responses match recorded fingerprints; no replay/fallback/diagnostic feed refetch. An earlier reconciliation was superseded after preserving prior registry serialization for the final source input.

Playfulls23,587items/9,246definitions: all prior raw rows, full source definitions, entire metadata, names, resolved acquisition facts and display fields exact navigation-final baseline. Everloot1,664→1,665raw/1,424qualified: only new NPC4086 located_in zone1442,three installations/null build. This is not gear item4086, an item-loot edge, current NPC presence or an event/kill timestamp. Zero selected8BI observations is not absence proof. Cached full Veenix reference provides identity/zone context without a new request. Original one-edge delta retained before advancing the diagnostic baseline; do not rerun old snapshot mutators.

Runtime integration adds100 summary cells only. All eight companion reports are byte-exact, including all six unresolved dungeon links. Index6,155/display6,154/books759/equipment registry4,684. Existing342 outside candidates remain unvalidated and byte-exact. Raw/semantic/companion reviews accompany this note.

## Exact next checkpoint

After successful18-test non-release CI and complete generated-commit inspection, proceed automatically to **8BJ:78 cases =17 remaining level40 +61 level41**, numeric ID order within level. Already marked in remaining_equipment_research_queue.csv. Frozen5,688 queue now4,470 publication-researched +1,218 pending. Preserve the100 completed8BI cases and earlier checkpoints; do not repeat their source reads absent a real deficiency. Continue adding newly discovered locations and chain links to the same navigation model/gaps.

342 outside candidates, systematic all-slot/Back scope audit, ten omitted cloaks, six dungeon exceptions,954 current-live recipe routes and manual map/overlay acceptance remain independent open work. Existing single automation retained; no main/Beta8/build/package/tag/release/billing action.

## Verified closure

Source `2466d48a8c0f459ba346f98fc69116b9d2256d4e`; [CI42988799050](https://github.com/magicaddons/getgear/actions/runs/42988799050), job130416310035, SUCCESS/18 timestamped testPASS (15Lua+3offlinePython),26modules/four tools/exporter syntax. Inspected direct bot/final validated `7bac831c930959f93d059ade6a09513f24f48274`: only provenance timestamp/four API hashes;no runtime/reports/counts. Actual bot API bytes not fetched; retain final-local actual1665/1424 factual snapshot,not equality from counters. Full [validation record](checkpoint8bi_validation.json) and [CI evidence](checkpoint8bi_ci_results.txt). Working evidence retains its source-commit pre-CI state as an immutable evidence input; this record closes that gate.

8BI is complete at publication-research level; continue8BJ78. No actual client rendering/current-live acquisition claim. Maincf7fa410/Beta8tag0a088935→543e5a24unchanged on current remote check;no package/release/billing action.
