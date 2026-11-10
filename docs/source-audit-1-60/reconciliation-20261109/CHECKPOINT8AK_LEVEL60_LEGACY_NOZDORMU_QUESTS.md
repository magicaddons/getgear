# Checkpoint 8AK — 15 legacy Nozdormu quest rings

Status: complete at publication-research level; full final local/non-release CI42773331069 PASS and directbotb72a360dfcbf5069965692876b6a4a80b3f3eb59 reviewed. Current live acceptance and access remain unverified.

## Scope and evidence

Selected21196–21210, all with the same displayed name. [Case table](checkpoint8ak_quest_equipment.csv), [49-response proof](checkpoint8ak_working_evidence.json), [19-query index](checkpoint8ak_discovery_index.json), [local results](checkpoint8ak_local_results.txt), [semantic review](checkpoint8ak_upstream_review.json) and [raw comparison](checkpoint8ak_raw_upstream_review.json) preserve numeric identity, input quantities, reward roles and real full-response hashes.

The49 full primary responses are15 items,18 quests,15 internal DND spells and one [Brood faction page](https://www.wowhead.com/forever/faction=910). No standalone NPC/scarab response is invented. Known8Q failures are explicitly reused, not retried or described as current reads.

Registry2,852; prior2,837 objects exact. Remaining3,050:163 quest/2,887 world-drop. After full CI/bot review, **8AL: seven Blessed Qiraji quest weapons21242/21244/21268/21269/21272/21273/21275**, then AQ class armour. All1,162 frozen undocumented cases remain publication-researched.

## Paths, standing and hand-ins

| Path | Neutral3 | Friendly4 | Honored5 | Revered6 | Exalted7 | Base reward quests |
| --- | --- | --- | --- | --- | --- | --- |
|Protector|21196|21197|21198|21199|21200|8747–8751|
|Conqueror|21201|21202|21203|21204|21205|8752–8756|
|Invoker|21206|21207|21208|21209|21210|8757–8761|

Each item requires equip60 and its exact faction910 standing. Independent faction item/standing rows match all15. The faction's base-quest rows show100 reputation gain; that is a reward, not a100-point acceptance threshold. Current quest/purchase acceptance is not independently established by equip requirements or a secondary guide.

All three initial quests have no published item objective. This does not prove a currently free/unrestricted claim or every starting prerequisite. The twelve later upgrades each require ONE exact previous same-path ring, with matching full quest objective and previous item's objective-of row. Same-name versions are not interchangeable; hand-in does not promise earlier-ring retention.

## Three distinct final-ring switches

| Quest | Input ring | Additional inputs,15 each | Choose ONE output |
| --- | --- | --- | --- |
|8764Protector No More|21200|Stone20858,Gold20859,Silver20860|21210 or21205|
|8765Invoker No More|21210|Bronze20861,Crystal20862,Clay20863|21200 or21205|
|8766Conqueror No More|21205|Bone20864,Ivory20865,Stone20858|21200 or21210|

All three publish minimum60/sideBoth/repeatable and require45 specifically typed scarabs plus the final ring. Three input-ring objective-of joins and six incoming reward-choice links agree. This is not one generic pool of interchangeable scarabs, both rewards, an arbitrary lower-tier switch or a guaranteed current service.

Initial quest text warns that the chosen path cannot be undone. The three separately read repeatable final-ring switches qualify that warning; neither a permanent lock nor unlimited current reset/replacement availability is assumed.

## Access, faction and source-role exceptions

- **8751 and8756** publish Horde in the full quest and independent faction quest list. The related final items have no Horde-only equip flag, and their incoming switches publish Both. Current Alliance completion remains unverified; canonical eligibility is preserved.
- **8765** publishes an Anachronos end but no start entry. The starting interaction is not filled in from the other two switches.
- Quest metadata/maps identify Anachronos15192 and Tanaris65.2,50. The map's Alliance-1/Horde1 reaction fields are actor context, not automatic character/gear faction restrictions.
- The faction member list corroborates identity/Tanaris but is not a standalone NPC map or quest-inventory read. The new quest-side point does not retroactively turn8Q's unreadable merchant into a verified current inventory.
- [8Q's access record](checkpoint8q_publication_evidence.json) already documents15192 and scarab full-page403s. No unchanged failures were repeated; no successful NPC/input hash, input farm, accepted cost, current stock/spawn or independent NPC quest-list join is claimed.
- A secondary guide for8756 repeats Horde/Exalted/min60/prior-ring/Tanaris context but supplies no independent current server acceptance evidence. Refinement hits for NPC8756Raytaf/item8751OverlinkedCoif are different entity kinds and rejected.

All15 exact tooltips publish BOTH Unique and the named Unique-Equipped family limit1. Unique concerns duplicates of the exact item ID; the equipped category is a different restriction. This does not establish a single carried ring across every tier/path or the ownership rules of35 newer different-ID items.

Each created-by record has an exact full DND spell/Create Item target. The15 full spell pages have no clear player-use/learning/profession route. These internal references are not learned crafts, free creation or lost-ring replacement guarantees. TANK/DPS/CASTER labels do not impose class/spec gates; all15 retain original nine-class eligibility.

The legacy quests, previous-ring inputs and45-scarab switches are not copied onto8Q's35 newer rings. Those newer scarab/idol merchant rows likewise do not replace these exact legacy quest routes.

## Validation and next in-game work

An initial local test/diagnostic attempt overlapped final generation fetches and lacked completed capture payloads. It was discarded. The capture completed successfully, then the entire suite and semantic/raw comparisons were rerun sequentially. Only that final run is reported as PASS; no failed CI/source was pushed.

- Full14 Lua regressions, offline Python guard,24 modules/four reports/helper syntax PASS.
- Exactly15 additive-summary cells change; zero other derived semantics/offset changes. All15 IDs were already indexed generically, so index4,479/display4,478 stays unchanged.
- Registry2,852/books759; canonical7,707/class objectives36,341; crafts1,254/ingredients4,857; all six dungeon exceptions, filters/settings and previous2,837 objects preserved.
- Seven actual same-run feed response bytes/hashes match provenance; no duplicate diagnostic feed requests.
- Playfulls23,366/9,153 and Everloot1,399raw/1,199qualified exact facts/counters unchanged; zero selected observed edges.121 separate outside-canonical9A candidates remain unaudited.

Next in-game tests should check faction acceptance of8751/8756, how8765 starts, actual standing/claim conditions, input consumption, path-switch choice/retention, replacement behavior and present Anachronos/scarab availability.954 live book routes and six dungeon exceptions remain open. No release build/package/tag/publish, Beta8 replacement, main modification or billing action.


## Checkpoint 8AK validated — next 8AL

Full final local/GitHub PASS: [42773331069](https://github.com/magicaddons/getgear/actions/runs/42773331069), sourcecf62c174be8ae7fb2a23c1eaec5043ee75a99839; inspected direct bot/final validatedb72a360dfcbf5069965692876b6a4a80b3f3eb59. All14 Lua regressions, offline Python guard,24 modules/four reports/helper syntax pass;15 timestamped CI test-PASS lines inspected. Final local tests ran sequentially after complete capture;earlier overlapping test/diagnostic attempt discarded and not pushed. Bot changes only run time/three Everloot response hashes; no runtime/report/index/count changes or independently captured bot API byte-identity claim.

Fifteen legacy Nozdormu rings complete:49fullresponses/19queries/15independentstanding+15questgain joins;12previous-ringquantity1reversejoins/3finalring+45typedscarab switches/6incomingchoices. ExactUnique-per-ID andfamilyUniqueEquipped1 retained;15DNDCreateItem references notlearnedcraft/replacement/specgates. Quest8751/8756Horde versus16othersBoth,8765missingstart,mapperreaction andcurrentacceptance discrepancies explicit;no canonicalclass/factioneligibility mutation. Prior8QknownNPC/scarab403failures reusedwithoutretry/fakehash;quest-sideTanaris65.2,50 notindependentNPC/currentstock. Legacy/newer35 ring rules remain separate.

Equipment2,852/index4,479/display4,478/books759;crafts1,254/ingredients4,857. Prior2,837 objects exact;15 summary cells only/all six dungeon exceptions retained. All15 were indexed generically already,so no newindexIDs. Seven same-run actual feed captures match provenance; no extra diagnosticrequests. Playfulls23,366/9,153 and Everloot1,399raw/1,199qualified exactlocalfacts/counters unchanged;zero selected observededges.121 outsidecanonical9A candidates remain separate/unvalidated;diagnostic8AJlocalPlayfulls/8YEverloot factualbaselines retained.

Frozen remaining3,050=163quest/2,887world-drop;**next8AL:7BlessedQiraji quest weapons21242/21244/21268/21269/21272/21273/21275**,markedqueue,thenAQclassarmour. Queueconservation5,688=2,638researched+3,050pending;registry214+2,638=2,852. All1,162 undocumented publicationcases remaincomplete/currentorigins/liveexceptions notclosed.954livebookroutes/sixdungeon/access/phase/retention exceptions remain. Main/Beta8 tag/source rechecked10Nov07:10UTC unchanged. No release/main/billing action.
