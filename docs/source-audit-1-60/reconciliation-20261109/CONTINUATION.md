# GetGear unattended research continuation

## Current authority and protected baseline

User resumed research on 9 November 2026 after published Beta 8 verification. Branch `work/full-acquisition-reconciliation-20261109`, recovered remote HEAD `f6c7b1986fec1840bd88b0320f5f071b55e1e679`. Main stays `cf7fa410f841cc19c84f4514e6b98ec435ff2ec4`. Beta 8/tag source remains `543e5a248a018f8a9144e64aca655d242cf274e0`; do not overwrite/republish it or build/package/publish any new release. Historical pause/upload instructions are superseded.

## Scheduling and usage

One enabled automation, **Continue GetGear research**, is attached to this existing chat, every two hours (`RRULE:FREQ=HOURLY;INTERVAL=2`), personal timezone Australia/Adelaide. Created successfully 2026-11-09T12:11:18Z. Automation reference for future pause at completion: `Automation_7353739dfe2c81918900f688ab8984b8`; source thread `01a1c037-5b56-765b-9263-070c54db609e`. Never create another continuation. Returned environment selection is inherited; concrete inherited environments and next-run time were null, so future provisioning/execution is not independently verified.

Tools expose no included-usage balance, weekly exhaustion indicator or allowance-refresh control. Scheduling does not guarantee execution through usage exhaustion or an exact refresh time. Preserve durable checkpoints on every completed batch, let later scheduled runs attempt continuation if permitted, pause on reported weekly exhaustion, and never purchase credits, redeem resets or alter subscriptions. On full offline research/validation completion pause this automation and report remaining live/client exceptions.

## Concurrency

Use this existing conversation only. If already active or another researcher owns this branch, skip the scheduled run. Fetch and compare remote HEAD before writing/pushing, inspect CI bot children, serialize validation, never force push. Same-environment runs should hold an exclusive `flock` on `/tmp/getgear-full-research.lock` for the work cycle; a lock is only local protection, so also inspect branch/CI state. Do not remove a held lock or assume a stale local checkout is authoritative.

## Checkpoint 8A — queue baseline

All 954 queued books (886 trainer-labelled +68 original vendor), 214 selected equipment cases and prior dungeon classifications already researched. These remain publication references and do not close current live routes (954 books, six dungeon exceptions). Latest full local/CI PASS: 42602679107; bot HEAD a907d939aea29fa9683a740514c4a8171b1318e3; later commits through recovered HEAD are release/documentation closeout. Latest three non-release runs all completed successfully; none pending at entry.

The frozen [5,688-case queue](remaining_equipment_research_queue.csv) selects canonical noncraft/nondungeon vendor, quest, undocumented, world-drop and reputation families, minus exact reviewed-equipment IDs. Counts: vendor 1,403; quest 234; undocumented 1,162; world-drop 2,887; reputation two. Generic source summaries are earlier structural reconciliation, not an individual merchant/quest/object/drop-route review. Research of these cases adds detail or records honest exceptions without erasing prior stronger sources.

**Next checkpoint 8B:** all 95 remaining vendor items at catalogue levels 1–30. Do not re-review 7C's 93 cases. Fetch exact Forever item pages, identity-lock, preserve alternate routes, independently join merchant inventories by exact item ID/name, check costs/stock/requirements and qualified locations. Missing/version-disputed inventory remains unresolved. Then remaining lower-level quests, higher-level vendor/quest/undocumented, world-drop, reputation and final full integrity/acceptance plan. Further batches can subdivide these coherent groups.

8A targeted checks: queue unique IDs, canonical name/level equality, zero intersection with reviewed-equipment registry, exact family partition and 95 next-batch IDs. PASS; documentation only, no regeneration/full CI. Commit identity is recoverable from Git history (do not insert a self-referential commit hash).

## Checkpoint 8B complete

All 95 selected vendor cases publication-researched/integrated; full local PASS 14/14,24 modules. GitHub full PASS 42616476682 (source 9f90939f1db03bb17fac0af249052f4394016ec9); direct bot child bad361a997d6d24d66bf1f81ecd9e6289ebd0342 inspected: timestamp/three response hashes only. All 14 logs verified through connector. Next 8C may begin. Frozen queue now marks these 95 researched; 5,593 remain, with **34 lower-level quest-family IDs marked 8C**. See exact evidence note. Automation start was adjusted to two hours after setup (`DTSTART:20261109T141544Z`, Adelaide 10 November 00:45:44), then every two hours; enabled, next-run field still null. No usage/billing controls changed.

## Checkpoint 8C complete

All 34 selected lower-level quest-family IDs publication-researched: 32 rewards/two provided-only objects. Full local PASS 14/14,24 modules,3 files; GitHub PASS 42617823815, source 55d2a7cd1524465bed9c58408a6bb32ed920d86c, inspected bot 0cae6bb54173ad3a3d6296c5ae4a19adf5dca30f changes run/data-as-of timestamps and three response hashes only. All 14 PASS logs inspected. Runtime index 2,178; equipment 343; recipes 954. Remaining frozen queue 5,559; **71 vendor level 31–40 IDs marked 8D** are next. Preserve exact-role and access exceptions; source evidence/failed object reads documented in case note.

## Checkpoint 8D complete

71 vendor level 31–40 cases researched; full local PASS 14/14, 24 modules, 3 files. GitHub PASS 42618811590; source c1daede10d072a461847185be86d4e0ef5b00eee, inspected bot d4110ea3c1bf821df92cb3939be64285a0ce1efe changes run timestamp/three response hashes only; all 14 PASS logs verified. Equipment 414, index 2,210, recipes 954. Exact queue 5,488 remaining; **ten quest-family level 31–50 IDs marked 8E** are next, followed by 31–40 undocumented cases. Four exact missing Mail/Lamellar origins stay unresolved.

## Checkpoint 8E complete

Ten quest-family level 31–50 cases researched; full local PASS 14/14, 24 modules, 3 files and Python syntax/online reconciliation. GitHub PASS 42620153753; source a2a21769e9e0949cab0ab09e4cbaff59acbdf871, inspected bot c7cb16e8b9af3fd80838a43db882cb7085fd56e3 changes timestamp/three response hashes only; all 14 PASS logs inspected. Equipment 424 / index 2,215 / recipes 954. Exact queue 5,478 remaining; **93 undocumented-source level 31–40 IDs marked 8F** are next. Keep Library threshold/Horde acceptance, Arena unknown minimum/current chest, and centaur giver/phase/version exceptions explicit.

Latest documentation closeout abridges evidence dictionaries to used structured facts/provenance, omitting quest story/article prose. All 210 new cases retain matching source fingerprints; runtime/registry unchanged. Do not reconstruct full source articles in committed proof artifacts.

## Checkpoint 8F currently in progress

Use CHECKPOINT8F_IN_PROGRESS.md and checkpoint8f_working_evidence.json as the durable resume point. All93 item pages,35 quest/series pages, primary NPC/spell/input evidence and60 exact discovery searches are saved. Integration/full validation PENDING; do not mark93 queue cases complete or reuse8E CI as an8F pass. New verified missing craft274490 requires material/profession/supplement audit integration; secondary drop badges are not observed loot. Current runtime remains equipment424/index2,215/originalbookregistry954; queue5,478 includes these93 still-unreviewed integration cases. Finish specified joins, conversion inputs and supported craft correction, then full local/CI/bot review.

## Current 8F — local PASS, GitHub pending

Use CHECKPOINT8F_LEVEL31_40_UNDOCUMENTED.md, superseding initial preservation note. All 93 cases integrated, full local PASS 14/14, 24 modules, Python/reconciliation and four required reports. Craft274490 adds two material rows; exact comparison preserves all 1,253 older crafts/4,855 ingredients and identities/class objectives. Totals1,254 crafts/4,857 ingredients, index2,308/display2,307/equipment517; original recipe registry954 plus separate supplemental audit.

GitHub run pending source push: complete/inspect bot before **8G: 207 vendor level41–50 IDs marked in queue**. Remaining queue5,385. Source/observation/reporting deltas reviewed in case note; original954 book queue/six dungeon exceptions remain. Two scheduled continuation messages arrived while active and duplicate invocations were skipped; no separate worker/new automation. Scheduled delivery has worked; usage balances/refresh guarantees remain unavailable. Process locks can expire across idle/restart, so check actual active work/remote/CI as well as renewing a local lock.

## Checkpoint 8F validated — next 8G

Full local and GitHub PASS: [42654914045](https://github.com/magicaddons/getgear/actions/runs/42654914045), source `801ae96935e90d4baae1952262bd24dfde67855d`; inspected direct bot/final validated HEAD `c283e82aaee5b284e49d524433174ea82e4697db`. All 14 PASS log lines verified; 24 modules/four reports. Bot changes only provenance timestamps/data-as-of and three response hashes; counts/runtime/reports unchanged. Equipment517/index2,308/display2,307; crafts1,254/ingredients4,857. Remaining5,385; next8G:207 vendor cases at41–50. No release/main change.

## Checkpoint 8G integrated — GitHub pending

[207 vendor items41–50](CHECKPOINT8G_LEVEL41_50_VENDORS.md):196 primary named-reference cases (30 explicit version warnings), seven secondary Everlook leads, four exact gaps. 227 two-sided/23 merchant-only edges; blocked27 item pages distinguished. All517 previous registry entries intact; equipment724/index2,470/display2,469/books759/crafts1,254/ingredients4,857. Full local PASS14/14,24 modules,four reports; GitHub PENDING, finish/bot-review before8H. Fresh comparison only207 additive summaries, no other derived semantic changes. Remaining5,178; next8H:65 undocumented41–50. No release/main action.

## Checkpoint 8G validated — next 8H

Full local and GitHub PASS: [42656807047](https://github.com/magicaddons/getgear/actions/runs/42656807047), source `3c7041809db0b49c6f9c8e3f0a56465dd4af444f`; inspected direct bot/final validated HEAD `54346df61203ada57c6ce16fd9da83b87e6511f9`. All14 PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment724/index2,470/display2,469; crafts1,254/ingredients4,857. Remaining5,178; **next8H:65 undocumented41–50**. Main/Beta8 tag independently unchanged; no release action.

## Checkpoint 8H integrated — GitHub pending

[65 undocumented-source items41–50](CHECKPOINT8H_LEVEL41_50_UNDOCUMENTED.md):13 exact vendor references, one quest reward, one item-use assembly, one attributed beta drop report, one generic label,48 honest origins. Lasso provided220216 differs from reward219345; later Lynnore reverse quests absent. Jang9380 and Fist17733 cannot inherit different same-name loot IDs. Full local PASS14/14,24 modules,four reports; GitHub PENDING. Equipment789/index2,535/display2,534/books759; crafts1,254/ingredients4,857 unchanged.65 additive summaries only, all724 prior entries/fingerprints retained. Remaining5,113; next8I:25 vendors at55. No release/main action.

## Checkpoint 8H validated — next 8I

Full local and GitHub PASS: [42658598705](https://github.com/magicaddons/getgear/actions/runs/42658598705), source `d1d0e8d3309e1d857db1a52007daaaa4f557ba51`; inspected direct bot/final validated HEAD `a229094ea988037908d330aa1c1b9c339e212313`. All14 PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment789/index2,535/display2,534/books759; crafts1,254/ingredients4,857. Remaining5,113; **next8I:25 vendors at55**. No release/main action.

## Checkpoint 8I integrated — GitHub pending

[25 level55 vendor cases](CHECKPOINT8I_LEVEL55_VENDORS.md):64 exact merchant joins/six NPCs; two missing maps; seller-specific faction gates/prices preserved. Opposing Exalted requirements are alternatives; standing0 is not Neutral. Full local PASS14/14,24 modules,four reports; GitHub PENDING. Equipment814/index2,543/display2,542/books759, crafts1,254/ingredients4,857 unchanged. All789 prior registry entries retained; remaining5,088; next8J:63 vendors at58. No release/main action.

## Checkpoint 8I validated — next 8J

Full local and GitHub PASS: [42660857813](https://github.com/magicaddons/getgear/actions/runs/42660857813), source `ecc4b2882c3340e985a9b8576bc78e7b759aea56`; inspected direct bot/final validated HEAD `b54a4afa7fd38c7c5e9f494546c95f46a1e98663`. All14 PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment814/index2,543/display2,542/books759; crafts1,254/ingredients4,857. Remaining5,088; **next8J:63 vendors at58**. No release/main action.

## Checkpoint 8J integrated — GitHub pending

[63 level58 vendor cases](CHECKPOINT8J_LEVEL58_VENDORS.md):59 exact merchant joins/seven NPCs and four exact missing Mail/Lamellar origins. Darkspear58 ranks directly evidenced, no copied lower-tier data. Full local PASS14/14,24 modules,four reports; GitHub PENDING. Equipment877/index2,578/display2,577/books759; crafts1,254/ingredients4,857 unchanged. All814 prior entries retained;63 additive summaries only. Remaining5,025; next8K:first100 remaining level60 vendor IDs numerically sorted/marked queue. No release/main action.

## Checkpoint 8J validated — next 8K

Full local and GitHub PASS: [42661663397](https://github.com/magicaddons/getgear/actions/runs/42661663397), source `2dca2c05b45a78c94e10e71d434d80293d180a25`; inspected direct bot/final validated HEAD `884c9284bdf966d0eb4c44131655f7f104dd044f`. All14 PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment877/index2,578/display2,577/books759; crafts1,254/ingredients4,857. Remaining5,025; **next8K:first100 remaining level60 vendor IDs**, marked in queue (12584 through18826). Main/Beta8 tag independently unchanged. No release action.

## Checkpoint 8K integrated — GitHub pending

[100 level60 PvP vendor cases](CHECKPOINT8K_LEVEL60_PVP_FIRST100.md):100 exact coin-table joins/four unmapped NPCs, zero current exact-ID purchase paths confirmed. Official-announcement mirror/current guide describe Honor/upgrade policy; exact version/currency/rank mapping remains unresolved. No Premier substitution, invented rank or unavailable flag. Full local PASS14/14,24 modules,four reports; GitHub PENDING. Equipment977/index2,678/display2,677/books759; crafts1,254/ingredients4,857 unchanged. All877 prior entries retained;100 additive summaries only. Remaining4,925; next8L:first100 remaining60-vendor IDs marked queue. No release/main action.

## Checkpoint 8K validated — next 8L

Full local and GitHub PASS: [42662988658](https://github.com/magicaddons/getgear/actions/runs/42662988658), source `c9d8fd597510b2f82c4ee911bb0be5f3faae14a3`; inspected direct bot/final validated HEAD `1457558187acb64620c2b2d43deeacde73a9cbce`. All14 PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment977/index2,678/display2,677/books759; crafts1,254/ingredients4,857. Remaining4,925; **next8L:first100 remaining level60 vendors** (18827 through23253), marked queue. Current PvP exact-ID currency/rank/upgrade access remains unresolved. No release/main action.

Local lock resilience: use a bounded own-work lease, e.g. `flock -n /tmp/getgear-full-research.lock timeout 2700 cat` in a retained PTY, renewing at checkpoints if still active. An indefinite orphan guard must not block resumption after quota interruption. Never remove another worker's held lock. A bare lock/cat process alone is not research liveness; also verify this chat/remote progress/CI and distinguish an active prior worker from the current invocation. Current guard was acquired at17:17 UTC with a45-minute maximum; process sessions can end earlier on restart. No new research task/automation was created.

## Checkpoint 8L integrated — GitHub pending

[Second100 level60 vendor cases](CHECKPOINT8L_LEVEL60_VENDORS_SECOND100.md):98 named cases/114 exact joins/11 NPCs;63 rank-named current paths unresolved,35 explicit reputation references,two missing shoulder origins. Five merchants unpinned. Shared8K policy reused without repeated research or guessed gates/currency/retirement. Full local PASS14/14,24 modules,four reports; GitHub PENDING. Equipment1,077/index2,757/display2,756/books759; crafts1,254/ingredients4,857 unchanged. All977 earlier entries retained;100 additive summaries only. Remaining4,825; next8M:first100 remaining level60 vendor IDs marked queue. No release/main action.
