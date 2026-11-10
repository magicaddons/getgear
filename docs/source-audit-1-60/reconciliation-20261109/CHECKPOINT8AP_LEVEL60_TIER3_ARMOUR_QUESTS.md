# Checkpoint 8AP — 72 Tier 3 armour turn-ins

Status: publication research/integration and full sequential local validation PASS; non-release CI/bot review pending. Current NPC/phase access, class/faction acceptance, input farms and retention remain unverified.

## Scope, evidence and exact next checkpoint

72 cases22416–22519 cover eight armour pieces in each of nine named set families. Family names are not new equip/quest-class restrictions. [Case matrix](checkpoint8ap_quest_equipment.csv), [primary evidence](checkpoint8ap_working_evidence.json), [72+3-query discovery](checkpoint8ap_discovery_index.json), [web fallback review](checkpoint8ap_web_fallback_review.json), [local results](checkpoint8ap_local_results.txt), [semantic comparison](checkpoint8ap_upstream_review.json) and [raw feed comparison](checkpoint8ap_raw_upstream_review.json) retain source roles, exact IDs/costs and limitations.

147 full primary pages:72 gear +72 quests +three explicitly reused material pages. Every original full response fingerprint matches actual saved bytes. Seven actual8AO final feed responses are reused and labelled as such,not fresh8AP/live/bot-response identity.72 exact gear/quest reward joins and101 reused-material/quest objective joins agree.144 start/end actor references come from full QUEST pages;there are **zero independent full NPC start/end-list joins**. Do not mislabel quest-side markers as independently read NPC inventories.

Registry3,011;prior2,939 objects exact. Index4,486/display4,485/books759;crafts1,254/ingredients4,857 unchanged. Exactly72 summary cells change;zero other derived semantics/offsets,five companion report bytes unchanged. All72 were already generically indexed. Frozen remaining2,891=4quest+2,887world-drop. **After CI/bot review resume8AQ:four Atiesh IDs22589/22630/22631/22632**,then world-drop queue.195 outside-canonical candidates/systematicBack coverage audit stay separate.

## Piece costs and source roles

Every full quest grants ONE fixed selected piece. Each objective uses one exact Desecrated token,one exact Wartorn scrap kind/quantity and the specified trade materials.285 typed cost rows:69 quests have four inputs;**9100Frostfire Gloves,9108Plagueheart Gloves,9116Gloves of Faith have THREE**(token1+ClothScrap8+Mooncloth4). No Nexus Crystal/fourth material is copied into those three.

33 distinct inputs:24 token IDs22349–22372,four scrap IDs22373–22376,and ArcaniteBar12360,ArcaneCrystal12363,Mooncloth14342,CuredRuggedHide15407,NexusCrystal20725. The exact72-row CSV preserves all quantities; materials are not interchangeable and sharing a slot does not establish identical costs. Arcanite Bar and Arcane Crystal are distinct IDs. These are NPC quest costs,not new learned crafting recipes or wearer profession gates. Three prior actual full material responses12360/14342/15407 independently match101 new quest-objective rows;their origins/recipes are not reopened as new completed research.

| Observed cost family | Token groups | Set families using those exact IDs | Scraps |
| --- | --- | --- | --- |
|Plate|22349,22352–22358|Dreadnaught/Redemption (two)|WartornPlate22375|
|Mixed mail/leather|22350,22359–22365|Cryptstalker/Earthshatter/Bonescythe/Dreamwalker (four)|Chain22374 orLeather22373 per quest,not interchangeable|
|Cloth|22351,22366–22372|Frostfire/Plagueheart/Faith (three)|Cloth22376|

These2/4/3 groupings are observed quest-cost reuse,not independently read token class masks/binding. The24 token/four scrap/two material own pages were among the blocked reads. No BoP/trade/class rule is invented for those inputs.

Reused Playfulls full capture resolves names for all33 inputs.21 tokens have community Naxx input leads:legsLoatheb,headThaddius,shouldersGrobbulus/Patchwerk/Gluth,wristsAnub'Rekhan/Faerlina/Gluth,waistHeigan/Noth/Gluth,handsMaexxna,feetGothik/Razuvious/Gluth,with exact token IDs retained. These are input references,not direct finished-armour drops,current rates,independent NPC reverse joins or guaranteed extra encounter rolls. Three chest tokens22349/22350/22351 and all four scraps have empty source lists;their origins remain unresolved. No guessed FourHorsemen or trash route is filled in.

Material feed labels(Alchemy/Tailoring/Leatherworking/disenchanting;ArcaneCrystal communityMisterGraphed/Riverglades vendor lead) describe inputs only. They do not establish current merchant inventory,price,trade/AH supply,learner requirements or a profession gate on the armour wearer. Source confidence is published quest reference/input origins unverified;no selected gear/input Everloot edge is present in the reused/fresh comparisons.

## Class and faction differences preserved

Full gear records:56 have no class mask,nine have broad1535 and seven explicitly Rogue8. Broad1535 projects to all nine supported classic classes1503;extra bit32 is retained in audit only and does not import a tenth class or bypass armour proficiency. The broad nine are Dreadnaught22416–22423 and BonescytheBracers22483;their tooltips have no single-class line. Seven other Bonescythe pieces explicitly require Rogue. No class restriction is inferred from set names,contact names,stats or bonuses.

Full quests:27 explicit class masks,45 absent. Explicit rows are eight Dreadnaught Warrior,six Cryptstalker Hunter(legs/shoulder/boots/hands/belt/wrists),three Bonescythe Rogue(hands/belt/wrists),one Frostfire Mage(circlet),three Plagueheart Warlock(shoulder/sandals/belt),six Faith Priest(all except robe/sandals). Missing masks are not replaced with a class from the set name and do not establish current cross-class acceptance. Source quest restrictions and legal item equip requirements are separate. Original canonical eligibility/armour filters remain unchanged.

Faction fields agree between gear and quest where published:five Redemption pieces Alliance,eight Earthshatter Horde,59 quests Both. RedemptionWrist22424/Tunic22425/Head22428 are Both;the five other Redemption records are Alliance. Do not copy Alliance across all eight or infer Shaman class restriction merely from Horde. Present cross-faction/class acceptance remains untested.

All72 gear are Epic/BoP/equip60,item86/88/92,with no plainUnique/UniqueEquipped,unavailable or seasonal warning. No family ownership/extra spec/profession gate is invented. All72 quests lack repeatable labels;omission does not establish one-time completion,repeat frequency or replacement.

## Actors and location confidence

Each named contact is referenced by eight full quests for start/end. All listed points are QUEST-SIDE EasternPlaguelands/Light'sHope map markers,not independently read NPC/current positions.

| Set family | Contact | Quest-side point |
| --- | --- | --- |
|Dreadnaught|Korfax16112|81.6,58|
|Redemption|CommanderEligor16115|81.6,58.2|
|Cryptstalker|HuntsmanLeopold16132|81.4,58.4|
|Earthshatter|Rimblat16134|81,59|
|Bonescythe|Rohan16131|81.4,58.4|
|Dreamwalker|Rayne16135|81.2,59|
|Frostfire|AngelaDosantos16116|81.4,58.2|
|Plagueheart|Mataus16133|81.4,58.2|
|Faith|FatherInigo16113|81.4,58.2|

40 full direct reads returned403:30 inputs,nine NPCs,one faction. No response hashes/retries/retirement or unavailable claims are made. A reused aggregate cache contains no selected33 inputs;that is not proof of absence. Alternative web reads expose four readable projections and three blocked/challenge results,not full original HTTP bytes. Korfax's name/EPL zone is readable but selected quest inventories are not;faction529 web comments are not independent72 gain/standing joins. No personal/current stock,spawn or accepted exchange is established.

## Reputation, prerequisite and version limits

Each full reward quest publishes200ArgentDawn529 **GAIN** and no standing objective. This is not an accepted200/9,000/Exalted threshold,gear equip gate or proof of ungated current acceptance. A Classic-labelled secondary9038 page claims250gain/9,000standing/72.0,48.5;the full primary publishes200gain/81.6,58/no standing objective. Those secondary values are not adopted.

Readable Echoes9033 context requires5LivingMonstrosities,5StoneskinGargoyles,8DeathknightCaptains,3VenomStalkers and grants200Dawn. Historical comments/Classic-derived chain listings describe an unlock prerequisite;current necessity for all72 is unverified. These objective kills do not identify token or finished-armour loot.

Readable9123 is the specific Exalted/no-charge ArcaneCloaking entry variant. It is not a claim that every entry variant is free,all72 gear require Exalted orpiece costs are waived.9121/9122 web pages are inaccessible;historical Honored/Revered comment costs are not accepted current data. No scoped current official Naxx access proof appeared in bounded returned results;that is not proof no announcement/current access exists. Old phase1/Thottbot comments,2025other-version hotfixes and generic guides are not currentphase/loot/recipe confirmation.

Nine ninth-set rings23059–23067 are already canonical and pending in the world-drop queue. They are outside these72 selected quests;no armour cost/source is copied onto them and they are not called completed/new candidates. All prior cloak/Back coverage exceptions remain.

## Validation and next testing

Actual unchanged-generator capture exited0 before sequential full14Lua regressions/offlinePython/24modules/fourreports/helper syntax/semantic/raw review:PASS. Seven fresh8AP actual HTTP bodies match provenance/metadata hashes,without extra diagnostic feed requests/replay. Playfulls23,434/9,157 and Everloot1,416raw/1,204qualified exactfacts/counters unchanged;zero selected observed edges. 72 summaries only;all earlier2,939 objects/canonical7,707 identities/36,341 class objectives/1,254crafts/4,857ingredients/settings/filters/six dungeon exceptions retained. Companion report bytes unchanged.

Queue conservation5,688=2,797researched+2,891pending;registry214+2,797=3,011. NextfourAtiesh then2,887world-drop. In-game tests must verify contacts/phase,Echoes/entry necessity,class/faction acceptance,piece-specific materials,exact reward,repeatability/retention.954livebook routes,six dungeon links,input-origin/access exceptions and195candidate/Back scope audits remain. No main/Beta8/build/package/tag/release/billing action.
