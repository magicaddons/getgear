# Checkpoint 8AM — 45 AQ class armour quests

Status: publication research and full sequential local validation PASS; non-release CI/bot review pending. Current live access, input acquisition, accepted exchanges and retention remain unverified.

## Scope, counts and evidence

45 selected armour IDs21329–21391 cover five pieces for each of nine classes. [Case table](checkpoint8am_quest_equipment.csv), [primary evidence](checkpoint8am_working_evidence.json), [discovery index](checkpoint8am_discovery_index.json), [local validation](checkpoint8am_local_results.txt), [semantic review](checkpoint8am_upstream_review.json) and [raw source comparison](checkpoint8am_raw_upstream_review.json) retain exact IDs, actor roles, costs and full-response fingerprints.

125 distinct full primary sources:45 gear +45 quests +9 inputs +25 NPCs +one explicitly reused faction page. Five input NPC responses were previously read; their exact new input joins were checked without calling them fresh network/live observations.45 exact-ID discovery queries returned historical Classic/cMaNGOS, client-only and derivative pages. Those are leads/context, not independent proof of current loot or availability. Search-result flags are projections, not full-secondary-page reads.

Registry2,904; prior2,859 objects exact. Index4,484/display4,483/books759; crafts1,254/ingredients4,857 unchanged. Exactly45 additive-summary cells changed and zero other derived semantics/offsets. Five new indexed IDs are Stormcaller21372–21376; the other40 were already generically indexed. Frozen remaining2,998 =111quest +2,887world-drop. **After CI/bot review continue8AN:18 pending AQ20 class weapon/ring cases21392–21417.** Previously completed cloaks are not reopened.121 outside-canonical9A candidates remain separate/unvalidated.

## Fixed rewards, exact costs and standing

All45 full quest records grant one fixed armour piece, not a reward-choice bundle or all five set pieces. All90 independent actor start/end joins match. Each full quest objective requires its exact token quantity1, exact idol quantity2 and two distinct scarab IDs quantity5 each. Ten arbitrary scarabs are not interchangeable.50 available full-input/quest reverse joins agree:45 token joins plus five Idol of War joins.

| Pieces | Actor | Published quest-completion standing | Cases |
| --- | --- | --- | --- |
|Head and legs|Andorgos15502 (head), Kandrostrasz15503 (legs)|Brood of Nozdormu910 Friendly|18|
|Shoulders and feet|Andorgos15502 (shoulders), Kandrostrasz15503 (feet)|Nozdormu Neutral|18|
|Chest/robes|Vethsera15504|Nozdormu Honored|9|

The standing ranks come from each actual full quest objective/body. The independently reused full faction910 response separately lists all45 quests in both its objective-of and gain tables. Each200 reputation value is a GAIN, not a200-point requirement. Completion standing is not silently turned into an equip, vendor-purchase, profession-learning or hidden character filter.

| Exact token | Published input NPC references |
| --- | --- |
|20926 Vek'nilash's Circlet|15275 Emperor Vek'nilash|
|20930 Vek'lor's Diadem|15276 Emperor Vek'lor|
|20927 Ouro's Intact Hide /20931 Skin of the Great Sandworm|15517 Ouro|
|20928 Bindings of Command /20932 Bindings of Dominance|15299 Viscidus,15509 Huhuran|
|20929 Carapace of the Old God /20933 Husk of the Old God|15727 C'Thun|

All ten exact token/NPC reverse tables agree. Each token's full tooltip is BoP and its explicit class mask includes the relevant gear/quest class; different token IDs/class groups are not substituted. These are token references, not direct finished-armour drops, independently observed current rates, guaranteed supply or additional Twin Emperor loot rolls.

Idol of War20882 is the one newly readable idol: full input/quest rows and all16 exact input/NPC reverse joins agree. It has an explicit class mask and no binding line; this does not promise current trade/AH stock. Those16 input references do not establish16 independent encounters or finished-armour loot.

Fifteen other selected scarab/idol full pages have known8Q HTTP403 failures. Those failures are explicitly reused without retries or fabricated response hashes. The new45 full quest objectives establish their exact names/IDs/quantities; they do not establish independent input binding, current farms or another publisher. Quest mapper source markers do not become independently corroborated input drops.

## Class, faction, repeatability and access limits

All45 gear/quest class masks match; each class has five pieces. Paladin2 quests/gear publish Alliance (five); Shaman64 publish Horde (five); the other35 quests publish Both. Full quest markup and JSON agree on these sides. Original canonical eligibility is preserved; current character acceptance remains untested. Names/set bonuses/stats/reagent masks do not introduce a new class, spec or profession gate.

37 quests explicitly publish repeatable; eight do not:8622 Stormcaller's Hauberk,8631 Enigma Leggings,8633 Enigma Robes,8637 Deathdealer's Boots,8638 Vest,8639 Helm,8640 Leggings and8669 Genesis Shoulderpads. Absence of a label is not proof of one-time completion. No repeatability/frequency/reset/replacement rule is copied across records.

All gear is Epic/BoP/equip60 and lacks plain Unique, unavailable or seasonal warnings. Item levels vary78/81/88 and are not equip levels. Original stats/armour/class filters and crafting recipes remain intact. Exchange materials do not make the gear a learned profession craft or impose its profession on the wearer.

All three independently read actor NPC pages have empty maps. Ahn'Qiraj is quest context; no precise/current point, spawn, phase, raid-clear condition or access route is invented. Primary publication does not establish present server acceptance or retention.

## Validation and next testing

Completed fresh unchanged-generator capture exit0, then full14 Lua regressions, offline Python guard,24 modules/four reports/helper syntax, semantic and raw reviews sequentially: PASS. Seven actual same-run HTTP responses match provenance, without extra diagnostic feed requests/replay. Playfulls23,366/9,153 and Everloot1,399raw/1,199qualified exact facts/counters are unchanged; zero selected observed edges. API refresh timestamps are not loot events.

All7,707 canonical identities/36,341 class objectives, prior2,859 metadata objects,1,254 crafts/4,857 ingredients, settings/filters and six dungeon exceptions are preserved. Queue conservation5,688 =2,690researched +2,998pending; registry214 +2,690 =2,904.954 current-live book routes and the six dungeon links remain open.

In-game acceptance should test actual actor/phase access, class/faction acceptance, each exact token/idol/scarab quantity, completion standing versus gain, fixed reward, repeatability and retained ownership. Continue next18 AQ20 cases after CI; no build/package/tag/release/main/Beta8/billing action.
