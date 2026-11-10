# Checkpoint 8AU — 72 world-drop cases at catalogue levels 12–13

Integrated with exact fallback repair and final full sequential local PASS 10 November 2026 UTC;non-release CI/bot review pending. Previous full PASS8AT:[42833637279](https://github.com/magicaddons/getgear/actions/runs/42833637279),source `426c317a20dd1cbd0841cbc92caebc7e89b1687e`,inspected bot `25f9313584a5dc9d030b8d91071d73512221b88c`.

## Scope and evidence

All72 exact queued IDs(40level12/32level13) individually identity-locked.52broad drop lists/20named-enemy cases;71UncommonBoE andoneRareBoP:Adept’sGloves4768. All72lack a class-only mask,plainUnique or primary unavailable/seasonal warning. Names do not imply Mage/Warlock/Shaman/Druid/profession/rank gates. The gloves’ current published Rare/BoP facts are distinct from the other71items;no catalogue identity/equip/class/stat rewrite is needed.

[Structured proof](checkpoint8au_working_evidence.json):137actual full HTTP fingerprints(124new/13explicitly reused),seven reused actual8AT feed responses,72exact-ID/name/foursharedqueries. No new direct read failures. [Discovery index](checkpoint8au_discovery_index.json) stores actual URL/flags projections,not original secondary HTTP hashes/articles.12earlier8AS failed URLs are reused as failure knowledge without unchanged retries,currentstatus/negativeinventory/retirement claims.

923matching full item↔NPC drop joins. Twenty named cases include22distinct item/actor edges:827WickedBlackjack lists both Highwayman122/Knuckleduster449;2821Mo’groshMasher lists Enforcer1179/Emogg14267;Slark519 independently lists3188CoralClaymore and6180Slarkskin. HarvestReaper115 differs fromHarvestGolem36;MurlocOracle517 differs fromSlark519. NPC names/classification do not make them instance bosses or impose equip classes. Adept’sGloves4768 has a full ElderMysticRazorsnout3270 reverse join and isBoP,not ordinary AHtrade.

## Objects and disagreements

145 of146 item→world-object references have independent full contents matches. One disagreement remains:Seer’sBoots2983 lists GiantClam19018,but the independently read clam contents omit2983. Preserve this one-sided lead and omission;do not advertise a current clam farm or infer the boots are unavailable. Other ordinary loot/chest routes remain intact.

WarPaintBindings14723 independently appears in RegulatorValve61935 contents. The object also lists Samophlange900 as an objective. Full900 requests closing three valves and returning to ControlConsole4141;the console independently starts/ends900. It gives no gear reward. Minimum10/display14/Both and50Ratchet470 **gain** do not establish a standing gate,a profession,equip requirement or that900is currently necessary to loot14723. Object interaction/current phase remains unverified;series links are not independently verified prerequisite rules.

Six earlier world objects remain exact IDs;three Kolkar containers retain the explicitly reused Key5020 chain from8AT. KeyUnique/access conditions are not gearUnique,recipe ingredients,one-key consumption fees or reusable guarantees. LargeBatteredChest75293 has no current waypoint. AllianceChest’s name is not a faction gate.17fished-in item tables do not add wearerFishing requirements.

## Mysterious Lockbox and four alternative fortune routes

Physical container-item references total16across13gear:fourTrunk20708,nineWarEffortSupplies21509 andthreeMysteriousLockbox19425. The first two remain item-side only/earlier403,not current crate origins/rewards. Full19425 independently contains4571WarKnife/6380InscribedBuckler/6553Bard’sTrousers. Its returned200-row contents may be capped;no guaranteed one-of-each or current roll probabilities. The crate isBoP/Unique/itemlevel1;those properties do not transfer to the threeBoE gear items.

All four full quests and the crate’s reverse reward list agree on **one19425crate per completion**,not fixed gear or all three contents:

| Quest | Starting/provided paper | Exact end object | Published area |
| --- | --- | --- | --- |
|7937|19423 Sayge’sFortune#23|180025 MysteriousEastvaleHaystack|ElwynnForest|
|7938|19424 Sayge’sFortune#24|180024 MysteriousDeadminesChest|TheDeadmines|
|7944|19443 Sayge’sFortune#25|180055 MysteriousWailingCavernsChest|WailingCaverns|
|7945|19452 Sayge’sFortune#27|180056 MysteriousTreeStump|Mulgore|

Four paper starts/fourprovided-for/fourobjective-of andfourindependent full end-object joins are preserved. The papers areBoP/Unique/use10,and each begins its own quest;Provided1does not mean free paper or all four papers as fees. Allfourquestsminimum10/display60/Both/noexplicitclassmask grant50DarkmoonFaire909reputation **gain**,not a standing/equip gate or level60requirement on gear12–13. No repeatable label does not prove current one-time/repeatability rules. The haystack/chests/stump are quest-end objects,not NPCs or direct gear-loot crates. Deadmines/Wailing end maps lack coordinates;other published footprints are not guaranteed current waypoints. Current Faire access,paper supply,quest acceptance,crate retention/repeatability and contents remain untested.

Paper19424 unexpectedly names Ansekhwa11869,and his full loot table independently lists it. The full NPC heading is WeaponMaster/ThunderBluff. Keep this published two-sided paper reference as an anomaly against the quest narrative’s Sayge context,not a confirmed current trainer-kill farm,gossip distribution,gear source or faction/equip requirement. Other three papers lack named full-page origins. Do not copy this anomaly to every fortune or assume Sayge inventory was independently read.

## Attributed observations

45Everloot observations across29items:43NPC/twoLargeBatteredChest75293 object edges,buildnull/3–6installs.43own item tables list the actor;31have independent full reverse support(29NPC/twoobject). Two actors are absent from returned200-row item lists:2079→BristlebackThornweaver3261 and3196→Verog3395;their full NPC tables include the gear and the API reports agree. Possibly capped item lists are not negative inventories. Preserve attributed observations without personal/currentbuild/exclusive-source/rate claims. Data:[Everloot](https://everloot.app),[CC BY-SA4.0](https://creativecommons.org/licenses/by-sa/4.0/).

## Confirmed fallback defect — exact repair, final local PASS

[Fallback review](checkpoint8au_fallback_review.json) reproduces a cold-client false hide of4768using the actualGearCompare andactualWorldDropBoEIndex with uncachedGetItemInfo. Both the actual current full item and retained hash-matched Forever cache show Rare/BoP,yet the older provisional Classic/AHledger index includes4768. Loaded client data already correctly overrides;the defect is fallback-only. EquipmentCache tuple6is a sourceCode,not rarity,no catalogue rarity rewrite.

The complete2341-entry fallback-vs-cache audit finds **only4768** contradictory;all2341IDs are present. The implemented repair removes that exact entry,retains2340others,prevents an obsolete-input generator rebuild reintroducing it,and adds meaningful actual-index/cold-client/live-override and offline-generator regressions. No broader filter/class/stat/equip/settings changes. Current live client remains authoritative,including if it reports greenBoE in future. This genuine verified deficiency warrants the bounded correction inside8AU. The before-fix expected failing local reproduction is not a failed CI run;targeted and full final local regressions pass,with non-release CI/direct-bot review still required.

## Resume

Integrate72 source records/preserve3225prior objects;complete the exact fallback repair/provenance/regressions,then fresh actual same-run capture exit0/fulllocal and non-release CI/bot review. Keep137source fingerprints and all unresolved boundaries above. Registry3225/index4696/display4695/books759;frozen2677includes72untilvalidation. Next8AV:all87world-drop cases at cataloguelevels14–15(38+49),numeric item-ID order,verifiedqueue. Thenhigherworld/9A201candidates/systematicBackscopeaudit/finalintegrity/acceptanceplan. Sixdungeonexceptions/954livebookroutes remain open. No main/Beta8/build/package/tag/release/billing action.

## Final local integration and upstream review

[Local results](checkpoint8au_local_results.txt):final8aufinal actualcapture exited0 before14Lua+2offlinePython/24modules/fourreports/3toolsyntax PASS(17localPASS). [Fallback repair](checkpoint8au_fallback_review.json):only4768removed/2340peers exact;reviewed data registry,generator protection,actual-index/liveoverride and offline real-generator fixture pass. NoGearComparelogic change or lost defaultgreen-BoE behavior.

[Additional delta scope](checkpoint8au_delta_scope_review.json) fingerprints73more full pages(72items/oneNPC;72new/onecached). One already-reviewed15477gets a new attributed Dustrunner3113report,exactitem+NPC corroborated,3installs/buildnull/lastrecorded5Nov. Its original details/fingerprints remain;3224otherpriorobjects exact.71other newobserved item IDs are excluded byexistingquality/class/slotpolicy:40poor/commongear,10consumables,fourtradegoods,fivequestitems,12misc/junk/key. This neither importsnewgear nor changesoriginal954book/recipe scope. Fourpoorcloaks do notcloseBackscope audit. Core137+delta73=210distinctfullresponses,not210completednewqueuecases.

[Initial raw delta](checkpoint8au_raw_upstream_review.json):PF+9outside/disjoint201→210pending9A,oneFacingTruthnavigationpathenrichment,4998index-onlyrows,51uninterpretedfield10changes(selected0),fourstat-summarytext/rawtagcells867/280604notadoptedasgame/effect/class/stat changes.9156priorfullsourceRows exact/onepathenriched/oneTheLastBarovdefinition added. EV+133edges(109itemNPC2itemobject22NPClocation)/26updates(22lastSeen7installs3overlap),no removed/build/firstSeen.45coreobservations unchanged.

[Final raw comparison](checkpoint8aufinal_raw_upstream_review.json):23450/9158/1549raw1315qualified completePFresponseobjects/bytes/hash andEVedgefields exactunchanged frominitialreview. Eightfinal actualsame-runHTTPbodies/provenance/registryhash match. Original initial/final captures/reviews remain separate;no replay or diagnosticrefetch. [Final companion remaps](checkpoint8aufinal_companion_remap_review.json) and[semantic comparison](checkpoint8au_upstream_review.json):73summarycells(72new+15477update),only15477observed-count fact,1616sourceRow-onlycells across8CSVs,noothersemantics.

Registry3297/index4768/display4767/books759/crafts1254/ingredients4857/7707identities36341objectives/filters/settings/sixdungeonexceptions preserved. Frozenremaining2605worlddrop;8AV87levels14–15(38+49)marked,CI/bot stillrequired beforecontinuing.9A210candidate/systematicBack audit and954livebookroutes remain. No main/release action.
