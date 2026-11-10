# Checkpoint 8AN — 18 AQ20 class weapon and ring quests

Status: complete at publication-research level;full sequential local/non-release CI42779018069 PASS;direct bot `5679cee80267cd8eb1e5a98026fdedf95e8e8bdd` reviewed. Current live access, accepted costs, input supply and retained rewards remain unverified.

## Scope and evidence

18 pending IDs21392–21417 cover one weapon and one ring per class. Previously researched cloaks are not reopened. [Case table](checkpoint8an_quest_equipment.csv), [67-source evidence](checkpoint8an_working_evidence.json), [18-query discovery](checkpoint8an_discovery_index.json), [local validation](checkpoint8an_local_results.txt), [semantic review](checkpoint8an_upstream_review.json), [companion-report offset review](checkpoint8an_derived_offset_review.json) and [raw feed comparison](checkpoint8an_raw_upstream_review.json) retain exact identities, costs and fingerprints.67 distinct full primary pages comprise18 gear,18 quests,18 internal spells,four tokens,eight NPCs and one faction. Every full-response hash matches actual saved bytes. Secondary client/beta/derivative search results do not independently establish current loot.

Registry2,922; prior2,904 objects exact. Index4,486/display4,485/books759; crafts1,254/ingredients4,857 unchanged.18 additive-summary cells changed; no other derived facts. Two new indexed Shaman IDs21398/21399; the other16 already generic. Frozen remaining2,980=93quest+2,887world-drop. **After CI/bot review continue8AO:17 AQ-chain/FallenGod quest cases21504–21712**, marked queue.135 outside-canonical9A candidates are separate, not automatically adopted.

## Fixed rewards, cost and reputation

All18 quest records grant ONE fixed selected piece, not a choice bundle/all three set pieces. All36 independent NPC start/end joins match. Each full objective requires exact token1 +exact idol2 +two distinct scarab IDs5each. No arbitrary ten-scarab substitution, AQ40 idol mapping or class-token interchange is inferred.

| Reward | Published completion standing | Actor and independently published Silithus point | Cases |
| --- | --- | --- | --- |
|Ring|Cenarion Circle609 Honored|Windcaller Yessendra15498,52,38|9|
|Weapon|Cenarion Circle609 Exalted|Warden Haro15499,51,38.8|9|

The ranks come from each actual quest objective/body. Full faction609 lists all18 quests in both objective-of and gain tables.100 reputation is a GAIN, not a requirement. These completion requirements are not gear equip/profession gates, Nozdormu910 ranks or200 gain. Quest category3428 does not place the actors inside the temple: full quest text and independent actor maps publish Silithus. Points are publication references, not current phase/spawn/access observations.

| Exact bound token | Selected classes | Published input NPC references |
| --- | --- | --- |
|20884 Qiraji Magisterial Ring|Warrior,Paladin,Shaman,Mage,Druid|Six:15339 Ossirian,15340 Moam,15341 Rajaxx,15348 Kurinnaxx,15369 Ayamiss,15370 Buru|
|20888 Qiraji Ceremonial Ring|Hunter,Rogue,Priest,Warlock|Same six exact NPCs|
|20886 Qiraji Spiked Hilt|Warrior,Paladin,Hunter,Rogue,Shaman|15339 Ossirian,15340 Moam,15369 Ayamiss,15370 Buru|
|20890 Qiraji Ornate Hilt|Priest,Mage,Warlock,Druid|Same four exact NPCs|

Four full token pages independently list all18 selected quests; class masks match.20 exact token/NPC reverse loot joins agree. These identify inputs, not finished-gear drops, current rates, guaranteed supply or extra encounter rolls. All four token tooltips publish BoP. Sixteen selected scarab/idol full pages have known8Q HTTP403 failures and are reused without retries or hashes. New full quest objectives establish exact IDs/names/counts, not independent input binding, farms, current trade/AH stock or another publisher.

## Creation references and restrictions

18 full internal DND spell pages have exact Create Item targets matching the selected gear. None establishes a player-learned profession or usable triggering item. Two see-also lists are alternate references, not teaching tables. In particular **spell29037 is named Summon Sickle of Unyielding Strength DND but creates Signet21393**; spell29034 creates Sickle21392. Spell names do not override output IDs. No free creation, recipe, replacement service, extra craft or ingredient list is introduced.

All18 quests lack a repeatable label; omission is not proof one-time or a reset/replacement rule. Nine rings publish plain Unique, while nine weapons publish unnamed Unique-Equipped. These are distinct item-specific restrictions, not a shared18-item family ownership limit. Current duplicate retention remains untested.

Gear and quest masks match for all nine classes; two Paladin records publish Alliance,two Shaman Horde,other14 quests Both. Original canonical eligibility remains unchanged. All18 gear are Epic/BoP/equip60; item65 rings/item70 weapons are not equip65/70. No primary unavailable/seasonal warning appears. Sickle/Scythe are One-Hand Axes; Blade21395/21413 Main-Hand Swords; Hammer21398/Mace21407/Gavel21410 Main-Hand Maces; Dagger21404/Kris21416 One-Hand Daggers. Names,set bonuses,old feral-AP or healing stats do not create new spec/profession gates or stat corrections.

## Actual feed delta and validation

The full tests passed, then the strict diagnostic guard correctly held queue advancement on genuine upstream changes. No failed source CI was pushed. The already completed capture was examined without refetching feeds; only diagnostic snapshots/candidates changed during that review, and queue advancement followed accepted comparisons.

- Playfulls adds14 actual feed IDs, all outside7,707 canonical/disjoint121 previous candidates:647,9465,11679,13177,13182,14522,18304,18305,18327,18340,18343,18349,18534,18695.135 total candidates still need individual9A identity/version/scope/eligibility/acquisition audits. Feed additions are not asserted new game content/current loot.
- Playfulls now23,380 items/9,154 definitions. All9,153 prior resolved definitions are preserved; one new DireMaul community trash definition names Ironbark Protector/Petrified Guardian/Petrified Treant.2,718 definition positions and7,090 item indices change(3,226 canonical/3,864 outside) without prior item acquisition/name/uninterpreted-field10 fact changes.
- Eight generated report comparisons preserve facts. Three primary reports have644 offset-only cells(181dungeon/463recipes); five companions have1,007(176dungeon-drops/1dungeon-followup/415recipe-followups/347trainer/68vendor). Total1,651 offset-only cells, separate from18 summaries. Original six dungeon followups and954 book cases remain.
- Everloot remains1,399raw/1,199qualified. Only NPC3412 `located_in` zone1454 lastSeen changes from9Nov05:43:30 to10Nov07:16:19. No new/removed edges, install/build/item-loot change or selected observed edge. This timestamp is not a loot event/current NPC verification.
- Seven actual same-run captured responses match local provenance. Diagnostic baselines now8ANlocal for both sources; no replay/fallback/extra diagnostic requests. [Snapshot provenance](upstream_snapshot_provenance.json) and [candidate note](ADDITIONAL_CATALOGUE_COVERAGE_CANDIDATES.md) explain the changes.

Capture process exited0 before full14 Lua regressions/offline Python/24modules/fourreports/helper syntax/semantic/raw review. All pass.7,707 canonical identities/36,341 class objectives, prior2,904 metadata objects,1,254 crafts/4,857 ingredients, settings/filters and six dungeon exceptions are retained. Queue conservation5,688=2,708researched+2,980pending;registry214+2,708=2,922.

Next in-game tests: actor/phase access, exact class/faction acceptance, Honored/Exalted completion versus gain, exact input counts/fixed reward, repeatability and retention.954 current-live book routes and six dungeon links remain open. No main/Beta8/build/package/tag/release/billing action.

## Checkpoint 8AN validated — next 8AO

18 AQ20 class weapon/ring cases are complete at publication-research level. Full sequential local and [non-release CI42779018069](https://github.com/magicaddons/getgear/actions/runs/42779018069) PASS; source `4a6c170bb9a12a45a2f8cac90ca382b0ba483581`, inspected direct bot/final validated HEAD `5679cee80267cd8eb1e5a98026fdedf95e8e8bdd`. All14 Lua regressions, offline Python guard,24 modules/four reports/helper syntax passed;15 timestamped CI test-PASS lines inspected. Bot changed only run time and three Everloot response hashes, with no runtime/report/index/count changes or independently captured bot-response byte identity claim.

67 full sources/18 queries support18 fixed rewards,36 actor joins,72 typed inputs,18 token-quest,20 token-NPC,18 faction gain/objective rows and18 exact DND targets. Nine Cenarion609 Honored rings/nine Exalted weapons completion gates separate from100gain/equip/Nozdormu. Exact token1+idol2+two scarabs5each;16 known input403 failures reused without retry/hash. DND29037 namedSummonSickle targetsring21393,notweapon21392/learnedcraft/freecreation. NineUnique rings/nineunnamedUniqueEquippedweapons;all18 lackrepeatlabel,notone-timeproof. Nine class masks/faction fields retained. Independent Silithus actor points not currentphase/access.

Registry2,922/index4,486/display4,485/books759/crafts1,254/ingredients4,857;prior2,904 objects exact.18 summaries/two new indexed Shaman21398/21399;zero other derived facts. Actual local feed delta reviewed before queue advance:14newoutsidecanonical/disjoint121→135pending9A;Playfulls23,380/9,154,one new DireMaul community definition/all9,153prior resolveddefinitions preserved;2,718 positions/7,090index-only rows(3,226canonical/3,864outside),zero prior acquisition/name/field10 facts. Eight reports have1,651 offset-only cells(644primary/1,007companions),no changed acquisition facts/all six dungeon exceptions retained. Everloot1,399raw/1,199qualified onlyNPC3412located_inzone1454lastSeen update,notloot/installs/build/newedge;zero selected observations. Seven actual same-run HTTP captures match local provenance;no extra diagnosticrequests. Baselines now8ANlocal for both sources. Initial strict diagnostic guard held actualchanges;all16localtests passed/no failedCI pushed.

Frozen remaining2,980=93quest+2,887world-drop. **Resume8AO:17 AQ-chain/FallenGod questcases21504–21712**,marked queue;completed cloaks not reopened. Conservation5,688=2,708researched+2,980pending;registry214+2,708=2,922. All1,162 undocumented publicationcases remain complete.135 outsidecanonical candidates still need individual9A audits;954 current-live book routes/six dungeon links/actor-phase-input-supply-acceptance-retention exceptions remain. Main/Beta8 lastremotecheck10Nov07:46UTC unchanged. Existing single self-owned two-hour automation/thisconversation/environment retained;usage meter/guaranteed refresh unavailable. Own bounded lease renewed after verifying previous PID/startticks/exact command;no other holder removed. No main/Beta8/build/package/tag/release/billing action.
