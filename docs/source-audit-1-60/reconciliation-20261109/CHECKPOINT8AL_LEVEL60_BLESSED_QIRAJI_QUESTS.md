# Checkpoint 8AL — seven Blessed Qiraji quest weapons

Status: publication research/integration and full sequential local validation PASS; non-release CI/bot review pending. Current live loot, exchange acceptance and access remain unverified.

## Scope and next checkpoint

Selected21242/21244/21268/21269/21272/21273/21275. [Case table](checkpoint8al_quest_equipment.csv), [26-source proof](checkpoint8al_working_evidence.json), [discovery index](checkpoint8al_discovery_index.json), [local results](checkpoint8al_local_results.txt), [semantic review](checkpoint8al_upstream_review.json) and [raw comparison](checkpoint8al_raw_upstream_review.json) retain exact IDs, quantities, reward choices and full-response fingerprints.

Registry2,859; previous2,852 objects exact. All seven IDs were already indexed generically, so index4,479/display4,478 is unchanged. Frozen remaining3,043:156 quest/2,887 world-drop. After CI/bot review continue **8AM:45 AQ class armour cases21329–21391**, five pieces for each of nine classes.

## Exact exchanges

| Quest | Independent start/end NPC | Required inputs per completion | Choose ONE |
| --- | --- | --- | --- |
|8789 Imperial Qiraji Armaments|Arygos15380|1Imperial Qiraji Armaments21232 +3Elementium Ore18562|War Axe21242,Musket21272,Pugio21244 orBulwark21269|
|8790 Imperial Qiraji Regalia|Merithra of the Dream15378|1Imperial Qiraji Regalia21237 +3Elementium Ore18562|Acolyte Staff21273,Augur Staff21275 orWar Hammer21268|

Both full quest pages and independently read NPC start/end lists agree. Input pages independently list the matching quests as objectives. Each quest publishes minimum60/display60/Raid/Both/repeatable. Repeatability does not establish current frequency, resets, acceptance or retention.

The cost is **three ORE18562, not three bars17771**. Thunderfury's ten-bar requirement is a different quest. Elementium-infused flavour does not make these outputs learned crafts or impose Mining on the user. Both tokens publish BoP/require60. The ore page lacks an explicit binding line; current trade/AH availability is not promised.

War Hammer is a Regalia8790 reward despite its melee name. It is a One-Hand Mace; Pugio is a Dagger, War Axe a One-Hand Axe, Musket a Gun, Bulwark a Shield and both staves Two-Hand Staves. Names, older feral-AP expectations, healing/spell stats or firearm flavour do not add class/spec/profession gates. Original weapon proficiency/eligibility and stat filters are preserved.

## Input source roles, maps and reputation

Each token has the same ten published NPC references: Vek'nilash15275,Vek'lor15276,Viscidus15299,Huhuran15509,Fankriss15510,Kri15511,Sartura15516,Ouro15517,Yauj15543,Vem15544. Twenty exact token/NPC reverse loot-table joins match. These are token references, not direct finished-weapon drops or ten independent encounters. Twin/Bug Trio records do not imply extra loot rolls, guaranteed tokens or current rates.

Elementium Ore18562 independently joins Blackwing Technician13996. The earlier full ore response is explicitly reused, not described as a fresh live observation; its published33.40% is not a verified current farming rate.

Both actor NPC responses have empty maps. Temple of Ahn'Qiraj is the quest-side location context; no point, current spawn, raid-clear/phase requirement or access route is invented. Static NPC faction reaction does not change quests marked Both into Horde-only gear.

The reused full faction910 page independently lists both quests with **200 reputation GAIN**. This is not a200-point requirement, Neutral threshold or proof of unrestricted current acceptance. Omission from the faction objective-of list likewise does not prove no prerequisites.

Only four gear tooltips publish plain Unique: Bulwark,Musket and both staves. That label is not copied to War Axe,Pugio orWar Hammer, and no named family equipped-limit is invented. All seven are Epic/BoP/item79/equip60, with no explicit class mask or unavailable/seasonal warning and no seller/drop/creation table.

## Evidence quality and validation

The26 full sources comprise seven gear pages,two quests,three inputs,13 NPCs and one reused faction page. Every full-response hash is checked against actual saved bytes. The environment transition preserved those files; transient search payloads were lost. The seven-query index honestly preserves the observed URLs/query strings with null body-ID flags, without claiming a rerun or reconstructed full response. Classic/cMaNGOS-labelled discovery leads remain historical context, not independent current acquisition observations.

- Sequential completed capture, full14 Lua regressions, offline Python guard,24 modules/four reports/helper syntax: PASS.
- Exactly seven additive-summary cells changed; zero other derived semantics/offset changes. Prior2,852 registry objects and all six dungeon exceptions retained.
- Canonical7,707/class objectives36,341; books759; crafts1,254/ingredients4,857; all filters/settings intact.
- Seven actual same-run feed responses match provenance; no duplicate diagnostic feed requests/replay.
- Playfulls23,366/9,153 and Everloot1,399raw/1,199qualified exact facts/counters unchanged; zero selected observed edges. API data-as-of refresh is not a newly observed loot event.
- 121 outside-canonical9A candidates remain separate and unaudited.

Next in-game testing must verify present actor/phase access, token/ore availability, accepted quantities, reward choice and retention.954 live book routes and six dungeon exceptions remain open. No release build/package/tag/publish, Beta8 replacement, main modification or billing action.

