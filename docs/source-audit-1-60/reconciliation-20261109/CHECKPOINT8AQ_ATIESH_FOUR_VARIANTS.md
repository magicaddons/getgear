# Checkpoint 8AQ — four Atiesh variants

Integrated with fresh full local PASS 10 November 2026 UTC. Non-release CI/bot review pending; previous fully validated runtime was 8AP, CI [42821733151](https://github.com/magicaddons/getgear/actions/runs/42821733151), source `51f710db22105ccd5ad34f9bd57e9bb8bc4a7df4`, inspected bot `51f78a04edf0f30ec266cdbd2b86c19584590e4d`.

## Exact identities and rewards

| Finished item | Explicit equip class | Fixed reward quest |
| --- | --- | --- |
| [22589](https://www.wowhead.com/forever/item=22589) | Mage, mask128 | [9270](https://www.wowhead.com/forever/quest=9270) |
| [22630](https://www.wowhead.com/forever/item=22630) | Warlock, mask256 | [9271](https://www.wowhead.com/forever/quest=9271) |
| [22631](https://www.wowhead.com/forever/item=22631) | Priest, mask16 | [9257](https://www.wowhead.com/forever/quest=9257) |
| [22632](https://www.wowhead.com/forever/item=22632) | Druid, mask1024 | [9269](https://www.wowhead.com/forever/quest=9269) |

All four are Legendary/BoP/two-hand Staff, equip60/item90, with no plain Unique or primary unavailable/seasonal flag. Four matching item→quest→fixed-item joins establish distinct same-name variants, not a single four-choice quest or four rewards per completion. Final quests explicitly say Both, minimum60, Dungeon; no explicit class mask, repeatable label or start/end NPC infobox fields. Absence does not prove current acceptance or repeatability. Gear class requirements remain separate.

## Published route and qualifications

- [Splinter22726](https://www.wowhead.com/forever/item=22726) says **40 total**, four caster classes mask1424, BoP/equip60/maxstack40. Its item-use [28324](https://www.wowhead.com/forever/spell=28324) creates [Frame22727](https://www.wowhead.com/forever/item=22727), with raw reagent table39. Preserve both representations; do not advertise39 total, a learned profession recipe, or an extra40-splinter charge on the final quest. No player profession prerequisite is established.
- Twelve named NPC tables independently contain Splinter22726, matching the input item list; [Four Horsemen Chest181366](https://www.wowhead.com/forever/object=181366) independently contains it too. The chest is a container. These are published input routes, not current drop observations, rates, lockout guarantees or finished-staff loot.
- Frame22727 begins [9250](https://www.wowhead.com/forever/quest=9250), ends at Anachronos15192. Reciprocal series links connect [9251](https://www.wowhead.com/forever/quest=9251), which starts/ends at Anachronos and requires one [Staff Head22733](https://www.wowhead.com/forever/item=22733) and one [Base22734](https://www.wowhead.com/forever/item=22734). Inline Provided on the frame quest does not make its assembly free.
- Head22733 names [Kel’Thuzad15990](https://www.wowhead.com/forever/npc=15990), whose independent full loot table includes22733. Base22734 names [C’Thun15727](https://www.wowhead.com/forever/npc=15727), but the actual full NPC table, explicitly reused from8AO, **omits22734**. Keep that one-sided reference and omission; no two-sided base proof or current rates. Brann’s narrative role is not a new base merchant/drop.
- **Early9250/9251 say Horde; all four final quests say Both.** PandaQuest/ForeverDB secondary results instead describe Both using reused/uncertain data. Current Alliance/Horde acceptance is unresolved. No inferred faction rewrite. Early quest-side actor references total3; the known8Q full Anachronos403 was not retried and supplies no independent NPC inventory/map/hash.
- Final quests describe taking the provided [tool22737](https://www.wowhead.com/forever/item=22737) to Consecrated Earth in Stratholme, using [Exorcise28354](https://www.wowhead.com/forever/spell=28354), defeating [Atiesh16387](https://www.wowhead.com/forever/npc=16387), then returning to Anachronos at Caverns of Time/Tanaris. NPC16387 is cleansing credit(quantity1), not an item turn-in or finished-staff drop. Its independent objective-of list matches all4 quests. Stratholme objective marker has no coordinates.
- Tool22737 independently lists all4 quests in both provided-for and objective-of(8 joins). It is Unique and has a15-minute use cooldown. It is distinct from the four finished weapons(no plainUnique), whose shared [Portal28148](https://www.wowhead.com/forever/spell=28148) effect has a1-minute cooldown and independently lists all4 in used-by-item. Shared-cooldown/see-also lists are not extra costs or sources. Portal use does not guarantee current Karazhan access.
- Quest9251 JSON does not explicitly grant a tool reward; a formal prerequisite/transition graph to the four final quests is incomplete. Do not invent a missing grant, final NPC start/end edges, quest class gate, or current trigger/reset.
- Each of the six full quests grants200 Brood of Nozdormu910 and200 Argent Dawn529 reputation **gain**, not an Exalted/standing/equip requirement. Finished primary damage130–243 differs from secondary Classic225–338; this acquisition checkpoint does not rewrite stats.

## Evidence and confidence

[Structured proof](checkpoint8aq_working_evidence.json) verifies34 actual full HTTP fingerprints:4 gear,6 quests,5 inputs/tools,3 item-effect spells,15 NPCs,1 container.33 new responses and one explicitly reused C’Thun response; no failed new reads. It preserves14 reverse input joins(12splinterNPC+1container+1headNPC), zero base reverse joins,4 cleansing NPC joins,8 tool joins and4 fixed rewards. [Discovery index](checkpoint8aq_discovery_index.json) records four exact-ID and four shared queries, actual result URLs and historical/client/availability warnings; no fabricated secondary full-page hashes. Published relationships remain current-live-unverified. Numeric website loot percentages are not adopted.

## Resume

Integrate four qualified source records, preserve3011 prior objects and all canonical identity/class/stat/filter/craft facts. Fresh actual HTTP capture must exit0 before the full14Lua/offlinePython/syntax/24module/four-report suite and semantic/raw upstream review. Then push non-release source commit, inspect successful CI and direct bot changes, close handover. Frozen remaining2891 includes these4 until validated. Next8AR:82 world-drop cases at catalogue levels1–7, numeric item-ID order; then remaining world cases and9A’s195 separate candidates plus systematic Back-slot scope audit. Six dungeon exceptions/954 current-live book routes remain open. No main/Beta8/build/package/tag/release/billing action.

## Integration and upstream review

Four qualified equipment records added;3011 previous objects exact. Fresh capture exited0 before14Lua+offlinePython/24modules/fourreports/helper syntax PASS. Registry3015/index4486/display4485/books759;1254crafts4857ingredients/7707identities36341objectives/settings/filters preserved. Four summary cells changed plus only one independently reviewed upstream canonical source delta:Timmy13402 community Timmy10808 reference. [Separate scope review](checkpoint8aq_upstream_scope_review.json) records two additional full HTTP fingerprints:primary item namesTimmy;independent full NPC table omitsboots. No two-sided/live/rate claim or sixexception closure. Four unaffected companion reports are byte-exact.

[Raw comparison](checkpoint8aq_raw_upstream_review.json):Playfulls23434→23441 adds7 IDs,onecanonical andsixoutside/disjoint195→201pending9A. All23434 priorrawrows and9157 fullsource-definitionobjects/sk exact;metadatast only changes. [Semantic comparison](checkpoint8aq_upstream_review.json) limits newfacts to13402communitysource fields;no offsets or other facts. Everloot1416raw1204qualified exactrelations/build/install/first-lastseen,zero selectedobservededges. Allseven same-run HTTP bodies match provenance/metadatahash. [Local results](checkpoint8aq_local_results.txt). Frozenremaining2887allworlddrop;8AR82levels1–7 numericIDorder marked. CI/bot review remains required before8AR;no release/main action.
