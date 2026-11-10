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

## Checkpoint 8L validated — next 8M

Full local and GitHub PASS: [42663990981](https://github.com/magicaddons/getgear/actions/runs/42663990981), source `cc28ef28cb9f58faea8c2a6c45399fcb725a98c1`; inspected direct bot/final validated HEAD `f3857cddf86cf6b8e37123e8dabcdae4eadd7196`. All14 PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment1,077/index2,757/display2,756/books759; crafts1,254/ingredients4,857. Remaining4,825; **next8M:first100 remaining level60 vendors** (23254 through227070), marked queue. Rank-named current purchase paths and all current-source uncertainties retained. No release/main action.

## Checkpoint 8M integrated — GitHub pending

[Third100 level60 vendor cases](CHECKPOINT8M_LEVEL60_PVP_THIRD100.md):100 exact item/merchant joins/four unmapped NPCs;96 current purchase paths unresolved,four exact seasonal version warnings. Warning flags not propagated to other IDs; four Tomes remain finished off-hands. Shared8K system context reused. Full local PASS14/14,24 modules,four reports; GitHub PENDING. Equipment1,177/index2,857/display2,856/books759; crafts1,254/ingredients4,857 unchanged. All1,077 earlier entries retained;100 additive summaries only. Remaining4,725; next8N:first100 remaining level60 vendor IDs marked queue. No release/main action.

## Checkpoint 8M validated — next 8N

Full local and GitHub PASS: [42665123374](https://github.com/magicaddons/getgear/actions/runs/42665123374), source `811035f8d8b6839067e82d38a6d090d51cf04f6f`; inspected direct bot/final validated HEAD `55bffb10c8717085b81a2b36cb9cc61309b4c7c1`. All14 PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment1,177/index2,857/display2,856/books759; crafts1,254/ingredients4,857. Remaining4,725; **next8N:first100 remaining level60 vendors** (227071 through227172), marked queue. Four exact version warnings and current purchase uncertainty retained. No release/main action.

## Checkpoint 8N integrated — GitHub pending

[Fourth100 level60 vendor cases](CHECKPOINT8N_LEVEL60_PVP_FOURTH100.md):100 exact joins/two unmapped NPCs;72 current-access-unverified references/28 exact version warnings, all corroborated by same-item seasonal/unconfirmed fields (not independent publisher claims). Shared8K policy reused without inferred ranks/currency/retirement. Full local PASS14/14,24 modules,four reports; GitHub PENDING. Equipment1,277/index2,957/display2,956/books759; crafts1,254/ingredients4,857 unchanged. All1,177 earlier entries retained;100 additive summaries only. Remaining4,625; next8O:first100 remaining level60 vendor IDs marked queue. No release/main action.

Upstream comparison improvement at8N: use upstream_snapshot_provenance.json and its three factual projection/definition/edge files when raw feed totals or shard hashes change. Compare exact edges and resolved source fields, not lastSeen-based guesses; uploads can contain older events. Preserve/refresh snapshots only after reviewing changes. Current baseline: Playfulls23,241 items/9,150 source definitions; Everloot1,375 raw edges/1,178 qualifying relationships.8M→8N has39 field10-only row changes, no source-entry-index changes and no derived source adoption. Previous complete raw edge payload/pre8I shard history was unavailable; exact new-edge identities/two historical added IDs are not claimed. All uncertainties documented in checkpoint8n_raw_upstream_review.json. Snapshots are diagnostics with Everloot CC BY-SA4.0 attribution, not new current-acquisition facts.

## Checkpoint 8N validated — next 8O

Full local and GitHub PASS: [42666508212](https://github.com/magicaddons/getgear/actions/runs/42666508212), source `befe841ba8a0f5b48551ede3e80f8382b5da15ad`; inspected direct bot/final validated HEAD `2fd9b88ec273213d73fc32756d1be3f1174e0712`. All14 PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment1,277/index2,957/display2,956/books759; crafts1,254/ingredients4,857. Remaining4,625; **next8O:first100 remaining level60 vendors** (227173 through231582), marked queue. Raw-source review records39 unused-field-only changes and1,375 raw/1,178 qualifying Everloot edges with no new derived source adoption; exact historical delta limitations explicit and factual snapshots preserved. No release/main action.

## Checkpoint 8O research preserved — integration pending

8O research preserved in CHECKPOINT8O_IN_PROGRESS.md/checkpoint8o_working_evidence.json:100 identities,114 merchant joins,16 exchanges/23 inputs/48 reverse cost joins,22 exact version warnings.84 PvP cases and16 item exchanges must remain distinct; profession-use290 is not learned crafting or purchase access, and Scourgestones12843 are not Valor Tokens12844. Runtime/full validation/queue advance PENDING; all100 remain8O/unreviewed, registry1,277/index2,957/remaining4,625. Latest full PASS42666508212/bot2fd9b88 retained. Finish saved integration then full local/CI/bot; no release/main action.

## Checkpoint 8O integrated — GitHub pending

[100 level60 vendor cases](CHECKPOINT8O_LEVEL60_VENDOR_EXCHANGES.md):84 PvP references/16 item exchanges,114 merchant joins/48 input reverse joins,22 exact seasonal warnings. Bound outputs/profession-use290 separate from base BoE craft, learned recipes and purchase gates. Exact Scourgestones12843, not ValorTokens12844; barter is not free. Full local PASS14/14,24 modules,four reports; GitHub PENDING. All1,277 earlier objects retained;100 summary changes only. Equipment1,377/index3,057/display3,056/books759; crafts1,254/ingredients4,857 unchanged. Remaining4,525; next8P:first100 remaining60-vendor IDs231583–231691, marked queue, after CI/bot review. No release/main action.

## Checkpoint 8O validated — next 8P

Full local and GitHub PASS: [42710850319](https://github.com/magicaddons/getgear/actions/runs/42710850319), source `533bafd48f81fb25c265ed71a86de6e0320b7a5e`; inspected direct bot/final validated HEAD `103cd7f27f3f87ef3cbb281db7dca64e7c6e9b20`. All14 CI PASS logs verified;24 modules/four reports; local14 rerun on bot data PASS. Material fresh-feed deltas reviewed in checkpoint8o_bot_upstream_review.json: Robe of the Moccasin6465/Lord Cobrahn3669 five-install observed edge; Pattern2601/Deviate Shambler5761 five-install book edge (not finished2585); six other canonical edge counters and two prior Cobrahn counters. Six dungeon exceptions/954 book-route queue remain open. Playfulls23,280/9,152:39 new IDs,0 changed resolved facts on previous rows,10,660 index-only shifts/61 uninterpreted field10 updates. Everloot1,398/1,198:23 exact added edges/49 counter-time updates/0 removals; selected8O edges0. Client encounter names unchanged, only build metadata. Diagnostic snapshots refreshed with attribution/fingerprints; not runtime inputs. Equipment1,377/index3,057/display3,056/books759; crafts1,254/ingredients4,857. Remaining4,525; **next8P:first100 remaining60-vendor IDs231583–231691**, marked queue.84 PvP/16 exchange cases preserve exact costs/bindings/use-professions and22 version warnings. No release/main action.

## Checkpoint 8P integrated — GitHub pending

[100 level60 PvP vendor cases](CHECKPOINT8P_LEVEL60_PVP_FIFTH100.md):100 exact merchant joins/two unmapped NPCs;95 current-access-unverified/five exact seasonal-version warnings. Shared8K policy reused; no inferred Honor/rank/current charge/retirement. Full local PASS14/14,24 modules,four reports; GitHub PENDING. All1,377 earlier objects retained;100 summaries only. Equipment1,477/index3,157/display3,156/books759; crafts1,254/ingredients4,857 unchanged. Remaining4,425; next8Q:first100 remaining60-vendor IDs231692–235479, after CI/bot review. Feeds unchanged from audited8O; no release/main action.

## Checkpoint 8P validated — next 8Q

Full local and GitHub PASS: [42711806965](https://github.com/magicaddons/getgear/actions/runs/42711806965), source `b5590f1cb16d00cbf373abce5128c81755ea0354`; inspected direct bot/final validated HEAD `3aef918f3e028d0134038d6c5f1f25cbb80cc310`. All14 CI PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment1,477/index3,157/display3,156/books759; crafts1,254/ingredients4,857. Remaining4,425; **next8Q:first100 remaining60-vendor IDs231692–235479**, marked queue.95 current-access-unverified references/five exact version warnings remain publication facts. No release/main action.

## Checkpoint 8Q integrated — GitHub pending

[100 level60 vendor cases](CHECKPOINT8Q_LEVEL60_NOZDORMU_EXCHANGES.md):65 exact PvP inventory joins/35 Anachronos item-page exchanges;23 embedded input identities, unread NPC/input reverse tables explicitly retained.35 tooltip/rank fields agree; ten exact class masks preserved;13 seasonal warnings (five rings/eight PvP). No old three-path quest mapping, current purchase gate, free barter or invented input farm. Full local14/24/4 PASS; GitHub pending. All1,477 prior objects unchanged;100 summaries only. Equipment1,577/index3,257/display3,256/books759; crafts1,254/ingredients4,857. Remaining4,325; next8R100 IDs235480–240047 after CI/bot review. No release/main action.

## Checkpoint 8Q validated — next 8R

Full local and GitHub PASS: [42712734634](https://github.com/magicaddons/getgear/actions/runs/42712734634), source `644718a8324879753e3eb05ef9bd6c395f40b318`; inspected direct bot/final validated HEAD `89b23cebec03ebd1e88f890cfd71cc7120877b9b`. All14 CI PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment1,577/index3,257/display3,256/books759; crafts1,254/ingredients4,857. Remaining4,325; **next8R:first100 remaining60-vendor IDs235480–240047**, marked queue.65 exact PvP reverse joins/35 item-only Anachronos references,23 embedded input identities and missing independent NPC/input reads remain explicit.13 exact version warnings; no invented current gate/farm/quest or all-tier purchase requirement. No release/main action.

## Checkpoint 8R integrated — GitHub pending

[100 level60 vendor cases](CHECKPOINT8R_LEVEL60_SANCTIFIED_EXCHANGES.md):92 alternative two-merchant Sanctified exchanges/eight PvP references;192 exact joins,276 cost components/57 unnamed inputs.57 input pages404/cache names0, no invented names/binding/farm/reverse evidence. Repair Chalice1232438→239117 is an item-effect lead, not learned craft.16 outgoing Inquisition conversions are not selected origins.92 class masks/one exact seasonal warning preserved. Full local14/24/4 PASS; GitHub pending. All1,577 prior objects unchanged;100 summaries only. Equipment1,677/index3,357/display3,356/books759; crafts1,254/ingredients4,857. Remaining4,225; next8S100 IDs240048–246062 after CI/bot. No release/main action.

## Checkpoint 8R validated — next 8S

Full local and GitHub PASS: [42713893409](https://github.com/magicaddons/getgear/actions/runs/42713893409), source `0f83f331cb27d873276707242ae734d33dc9d75c`; inspected direct bot/final validated HEAD `b274ae9211d05348e007cdc2206407d774bce36a`. All14 CI PASS logs verified;24 modules/four reports. Bot changes only run timestamp/four response hashes (Playfulls landing/three API pages); exact content-addressed shards, runtime/counts/reports unchanged. Equipment1,677/index3,357/display3,356/books759; crafts1,254/ingredients4,857. Remaining4,225; **next8S:first100 remaining60-vendor IDs240048–246062**, marked queue.92 alternative exchanges/192 total joins retain57 unnamed404 inputs and item-effect/secondary leads without new crafts; one exact warning and16 outgoing conversions retained. No release/main action.

## Checkpoint 8S integrated — GitHub pending

[100 Sanctified vendor cases](CHECKPOINT8S_LEVEL60_SANCTIFIED_ALTERNATIVES.md):200 exact item-page cost joins/216 inventory options. Eight246055–246062 output pages omit two Leonid alternatives each;16 prior known input pages independently match full four-cost sets. Preserve discrepancy/alternatives, not cumulative ingredients or exclusive prices.57 unnamed-input gaps reused; no duplicate research/new crafts. Full local14/24/4 PASS; GitHub pending. All1,677 prior objects unchanged;100 summaries only. Equipment1,777/index3,457/display3,456/books759; crafts1,254/ingredients4,857. Remaining4,125; next8T:all42 remaining vendors272095–272958, after CI/bot. No release/main action.

## Checkpoint 8S validated — next 8T

Full local and GitHub PASS: [42714767876](https://github.com/magicaddons/getgear/actions/runs/42714767876), source `1b8027e1743f71367904d4fa20d28b5fab7c166e`; inspected direct bot/final validated HEAD `28ca2642e553d16d295f1fcdfe65da6653064330`. All14 CI PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment1,777/index3,457/display3,456/books759; crafts1,254/ingredients4,857. Remaining4,125; **next8T:all42 remaining frozen vendor cases272095–272958**, marked queue.200 primary cost joins/216 inventory options retain eight collapsed-output-page discrepancies and16 prior input-page full4-cost-set matches;57 unnamed gaps reused. No release/main action.

## Checkpoint 8T integrated — GitHub pending

[Final42 vendor cases](CHECKPOINT8T_FINAL_VENDORS_CURRENCY.md):11 exact Darkspear Exalted and31 Pix currency3469 references;42 merchant/31 currency joins. Cap165 differs from item226404250 limits; earning/purchase55 assumptions are dated25Oct, not current-confirmed. Full local14/24/4 PASS; GitHub pending. All1,777 prior objects retained;42 summaries only. Equipment1,819/index3,468/display3,467/books759; crafts1,254/ingredients4,857. Frozen vendor1,403/1,403 publication-researched,0 remaining. Frozen remaining4,083; next8U2 reputation28 cases19525/20099 after CI/bot. Later9A:39 upstream IDs verified outside canonical CSV, separately registered candidates requiring scope/version/eligibility/acquisition audit, no automatic adoption/count inflation. No release/main action.

## Checkpoint 8T validated — next 8U

Full local and GitHub PASS: [42715855405](https://github.com/magicaddons/getgear/actions/runs/42715855405), source `8d7ee4002f5898fcfe82432b5c10502cb7b333fc`; inspected direct bot/final validated HEAD `0336f59e06cdb0feafa150b2c3fc1d011a9ecb6b`. All14 CI PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment1,819/index3,468/display3,467/books759; crafts1,254/ingredients4,857. Count correction verified against logs:31 Pix IDs already had generic generated references, so42 reviewed summaries add11 new index IDs and enrich31 existing ones; no3499 total is claimed. Frozen vendor1,403/1,403 publication-researched; remaining4,083. **Next8U:19525 Lorekeeper's Ring and20099 Highlander's Cloth Girdle (reputation28)**, marked queue; then22 undocumented51–54. Later9A39 disjoint catalogue coverage candidates remain separate/unvalidated, with no automatic adoption. Currency earning/current access and all prior live exceptions retained. No release/main action.

## Checkpoint 8U integrated — GitHub pending

[Two reputation28 cases](CHECKPOINT8U_LEVEL28_REPUTATION.md):19525/20099 exact merchant joins with explicit Honored conditions.19525 standing0 does not remove playerConditions;20099 Neutral actor reaction does not lower item rank; repeated condition not extra grind. Full local14/24/4 PASS, GitHub pending. All1,819 prior objects unchanged;two summaries only. Equipment1,821/index3,470/display3,469/books759; crafts1,254/ingredients4,857. Reputation2/2 publication-researched; frozen remaining4,081. Next8V22 undocumented51–54, marked queue, after CI/bot. Later9A39 coverage candidates separate/unvalidated. No release/main action.

## Checkpoint 8U validated — next 8V

Full local and GitHub PASS: [42716468554](https://github.com/magicaddons/getgear/actions/runs/42716468554), source `e392b3af3f23dfe1fdb276efcc7416bedabedb1b`; inspected direct bot/final validated HEAD `d0a5d94adc4b9b406ae945b58d735e8e442a7b1c`. All14 CI PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment1,821/index3,470/display3,469/books759; crafts1,254/ingredients4,857. Frozen remaining4,081; vendor/reputation queues publication-researched, live routes still open. **Next8V:all22 undocumented51–54**, marked queue, endpoints227947/286640 by level-then-ID ordering. Two exact Honored conditions retain standing0/actor-reaction distinctions and no new numeric gate. Later9A39 coverage candidates remain separate/unvalidated. No release/main action.

Concurrency guard renewed by this same active worker at approximately22:55UTC9Nov, bounded45-minute maximum. It is an own-work lease, not another research task. Never remove another worker’s guard or infer liveness solely from a bare cat/lock. Preserve commits before usage interruption; scheduled continuation may resume after refresh, with no quota-state guarantee or charge/reset actions.

## Checkpoint8V publication research preserved — integration pending

22 primary identities, four Dala Revered vendor/token reverse joins, exact18023 unavailable/227947 seasonal flags; qualified conflicting277117/preview284266/speculative284065/286640/auction282026/generic-world labels documented in CHECKPOINT8V_IN_PROGRESS.md and checkpoint8v_working_evidence.json. Eight auxiliary NPC checks,28 discovery queries/focused sources saved; no repeated source pass needed. Runtime/full validation/queue advance PENDING. Registry1821/index3470/remaining4081, all22 still8V. Latest full PASS8U42716468554/botd0a5d94 retained; finish integration/full local/CI/bot then next100 undocumented55. No release/main action.

## Checkpoint8V integrated — GitHub pending

[22 undocumented51–54](CHECKPOINT8V_LEVEL51_54_UNDOCUMENTED.md):4 Dala Revered/token reverse joins; exact18023 unavailable/227947 seasonal flags;277117 conflict/284266 unnamed preview/2 speculative/auction282026/2 generic categories/9 gaps retained with qualified evidence. No fake NPC/outfit/drop/recipe/current-table inference. Full local14/24/4 PASS, CI pending. All1,821 prior objects unchanged;22 summaries only. Equipment1,843/index3,492/display3,491/books759; crafts1,254/ingredients4,857. Frozenremaining4,059; next8W100 undocumented55 IDs16367–272630, after CI/bot. Later9A39 coverage candidates separate. No release/main action.

## Checkpoint8V validated — next8W

Full local and GitHub PASS: [42718647114](https://github.com/magicaddons/getgear/actions/runs/42718647114), source `fcad7a674238f17b8b3fb3028eb36fb613240c38`; inspected direct bot/final validated HEAD `a4c1f978d88dce5fdda48ea0a768fd17ca56c463`. All14 CI PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment1,843/index3,492/display3,491/books759; crafts1,254/ingredients4,857. Frozenremaining4,059; **next8W:first100 undocumented55 IDs16367–272630**, marked queue. Four exact Dala/Bead Revered routes, exact flags and qualified unresolved/conflicting/preview/speculative/market evidence retained without sourceType/stat/gate/material changes. Later9A39 coverage candidates remain separate/unvalidated; all original current-live exceptions remain open. No release/main action.

## Checkpoint8W research preserved — integration pending

100 exact primary IDs/100 discovery queries/99 selected IDs,1 DalaExalted25-bead merchant/token join,18355 unavailable flag,29 secondary-rank8/primary-omission discrepancies and68 Premier/one cloth origin gaps preserved in CHECKPOINT8W_IN_PROGRESS.md/checkpoint8w_working_evidence.json/discovery_index.json.171 cachedNPCpages/95 actual inventories reused; no seller matches beyondDala, not exhaustive current-vendor proof. Runtime/fullvalidation/queueadvance pending; all100 still8W. Registry1843/index3492/remaining4059; latest fullPASS8V42718647114/bota4c1f97. Finish saved integration/full local/CI/bot then next100 undocumented55. No release/main action.

## Checkpoint8W integrated — GitHub pending

[100 undocumented55 cases](CHECKPOINT8W_LEVEL55_UNDOCUMENTED_FIRST100.md):1 Dala25-bead/Exalted exact vendor+token join;18355 unavailable;29 exact secondary-rank8/primary-omission discrepancies;68 Premier+1 cloth origin gaps.171 reusedNPCpages/95 actual inventories bounded, not all current merchants; selectedobservedFeedCounts0 not impossibility. Full local14/24/4 PASS, CI pending. All1,843 prior objects exact;100 summaries only. Equipment1,943/index3,592/display3,591/books759; crafts1,254/ingredients4,857. Frozenremaining3,959; next8X100 undocumented55 IDs272634–273363, after CI/bot. Later9A39 separate coverage candidates. No release/main action.

## Checkpoint8W validated — next8X

Full local and GitHub PASS: [42721186621](https://github.com/magicaddons/getgear/actions/runs/42721186621), source `8183aa43eed1976694f5060be87e379d27a0e36e`; inspected direct bot/final validated HEAD `a425567c922e9df649a79d60b4f10f7151f78b22`. All14 CI PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment1,943/index3,592/display3,591/books759; crafts1,254/ingredients4,857. Frozenremaining3,959; **next8X:first100 undocumented55 IDs272634–273363**, marked queue. One exact Dala25-bead/Exalted route,18355 unavailable notice,29 secondary-rank8/primary-omission version discrepancies and69 remaining origin gaps retained. All98 explicit class masks match canonical; bounded171 NPC/95 inventory survey is not exhaustive current stock. No sourceType/stat/gate/material changes. Later9A39 coverage candidates remain separate/unvalidated; all original current-live exceptions remain open. No release/main action.

## Checkpoint8X research preserved — integration pending

100 exact Premier55 identities/101 discovery queries,100 class masks; all primary acquisition tables empty/no explicit availability flags. Seven unnamed vendor-category leads and Builder rank10/primary general no-rank discrepancy qualified, no exact current route invented.171 cachedNPC/95 inventories reused,0 selected matches, bounded only. Evidence CHECKPOINT8X_IN_PROGRESS.md/checkpoint8x_working_evidence.json/discovery_index.json. All100 remain8X/unreviewed, registry1943/index3592/remaining3959. Latest fullPASS8W42721186621/bota425567; integrate then full local/CI/bot, next8Y last76 undocumented55. No release/main action.

## Checkpoint8X integrated — GitHub pending

[100 undocumented55 cases](CHECKPOINT8X_LEVEL55_UNDOCUMENTED_SECOND100.md):7 unnamed vendor-category leads/93 unresolved Premier origins;100 explicit class masks match, no primary acquisition/availability flags. Rank10 secondary/general rare-no-rank policy discrepancy qualified, no current gate/actor/currency inferred. Full local14/24/4 PASS; CI pending.1943 prior objects exact;100 summaries only. Equipment2043/index3692/display3691/books759; crafts1254/ingredients4857 unchanged. Exact upstream3 outside-canonical IDs11824/18320/276745,0 prior source facts/anonymous edges changed; diagnostic snapshots updated and42 pending9A candidates distinct from frozen queue. Remaining3859 (undoc782/quest190/world2887). Next8Y76 undocumented55 IDs273364–276419 after CI/bot. No release/main action.

## Checkpoint8X validated — next8Y

Full local and GitHub PASS: [42722678316](https://github.com/magicaddons/getgear/actions/runs/42722678316), source `3675f2a5ae2e9743a1bb9a8159ccf0a3f589430c`; inspected direct bot/final validated HEAD `0b9467fd8d894adf3fd1bd157a0d1d9b8e5064fb`.14 CI PASS logs verified;24 modules/four reports. Bot changes only timestamp/three response hashes; runtime/reports/counts unchanged. Equipment2043/index3692/display3691/books759; crafts1254/ingredients4857. Seven unnamed vendor leads/93 unresolved origins and rank-policy discrepancy retained; all100 explicit class masks match. Exact upstream review:3 added outside-canonical/no-origin IDs11824/18320/276745,0 prior source facts/edges changed;9A now42 separate pending candidates. Frozenremaining3859; **next8Y:all76 remaining undocumented55 IDs273364–276419**, marked queue. Original live book/dungeon/availability/input/currency exceptions remain open. No release/main action.

## Checkpoint8Y research preserved — integration pending

76 final undocumented55 identities/72 exact class masks,87 queries; primary acquisition/availability tables empty. Eight weak unnamed vendor leads/one attributed274969 Biggins contributor report (price notseen), primary12781 omitsselected/no map. Dated official capitalPvPvendor temporary outage directly verified, documented in checkpoint8y_pvp_access_update.json/8K followup; no permanent retirement/current-price/rank inference. Two nonPremier origins remain gaps; user outfits/Holy proc/cache reveals not source/class proof. Evidence CHECKPOINT8Y_IN_PROGRESS.md/working_evidence/discovery_index. All76 still8Y; registry2043/index3692/remaining3859, latest fullPASS8X42722678316/bot0b9467f. Integrate/full local/CI/bot then next8Z bounded undocumented56+; later9A42 candidates separate. No release/main action.

## Checkpoint8Y integrated — GitHub pending

[Final76 undocumented55](CHECKPOINT8Y_LEVEL55_UNDOCUMENTED_FINAL76.md):8 weak unnamed vendors/1 attributed274969 Biggins one-contributor report/65 Premier+2 other gaps. Primary12781 omitsselected/no map, no current cost/rank inferred; secondary guide price-row/slot mapping explicitly unconfirmed. New direct official dated known-issues thread still lists capitalPvPvendors temporarily unavailable, not permanent retirement/everyBG outage; shared8K followup saved. Full local14/24/4 PASS; CI pending.2043 prior objects exact;76 summaries only. Equipment2119/index3768/display3767/books759; crafts1254/ingredients4857 unchanged. All276 undocumented55 publication-researched; remaining3783 (undoc706/quest190/world2887). Next8Z10 undocumented56–57, level-then-ID269503–284253, after CI/bot. Later9A42 candidates separate; live exceptions remain open. No release/main action.

## Checkpoint8Y validated — next8Z

Full local and GitHub PASS: [42723894319](https://github.com/magicaddons/getgear/actions/runs/42723894319), source `88eba26e0c2fc0448138825e1644fc1cf373679e`; inspected direct bot/final validated HEAD `f5b9f56ea3840decb9b0f1628320737d2e6fa7fa`.14 CI PASS logs/24 modules/four reports verified. Bot changes README public-relationship count/provenance only, no runtime/index/catalogue/recipe/dungeon changes. Exact fresh edge diff:1399raw/1199qualifying, one reagent2320(CoarseThread)→NPC5783 sold_by3-install edge,4 previous edge counter/time updates,0 removed/0 selected76. No ingredient/new-craft change or event-time inference; separately fingerprinted diagnostic snapshot refreshed. Equipment2119/index3768/display3767/books759,crafts1254/ingredients4857.8weak leads/1 attributed Biggins/67 origin gaps retain dated official capitalPvPvendor outage and unconfirmed price mapping, not permanent retirement/current stock/rank/cost. All276 undocumented55 publication-researched. Remaining3783; **next8Z:all10 undocumented56–57, level-then-ID269503–284253**, marked queue. Later9A42 candidates/current-live exceptions open. Remote maincf7fa410/Beta8 tag0a088935→source543e5a24 rechecked unchanged. No release/main action.

## Checkpoint8Z research preserved — integration pending

10 exact undocumented56–57 identities/22 queries/2NPC primaryreads.284268 item-only GrizzleSnowpaw10199 named loot ref, primaryNPC85rows omitselected; no current rate/reverse/live claim.282070 namesakeGruklash8979 omitsselected, no source inference. Other9 origins unresolved, secondaryHorde-only/other-version-unavailable/cache/set/recipe labels qualified.174NPC/96inventories0matches bounded. Proof CHECKPOINT8Z_IN_PROGRESS.md/working_evidence/discovery_index. All10 still8Z,registry2119/index3768/remaining3783/latest fullPASS8Y42723894319/botf5b9f56. Integrate/full local/CI/bot then8AA100undoc58. No release/main action.

## Checkpoint8Z integrated — GitHub pending (10Nov continuation)

[Ten undocumented56–57](CHECKPOINT8Z_LEVEL56_57_UNDOCUMENTED.md):284268 item-side GrizzleSnowpaw10199 named reference, NPC85rows omitselected; no reverse/current-rate/live claim.282070 namesake8979 omitsselected, no attribution. Nine origin gaps preserve other-version unavailable/secondary faction/cache/set/Unique distinctions. Full final local14/24/4 PASS; CI pending.2119 prior objects exact;10 summary cells only. Equipment2129/index3778/display3777/books759;crafts1254/ingredients4857 unchanged. Frozenremaining3773 (undoc696/quest190/world2887). Next8AA100undocumented58 IDs12616–17616 afterCI/bot; then45/one59/550level60. Later9A42 candidates separate. Research9Nov retained,10Nov remote/concurrency verified/lease renewed; no repeats/release/main action.

## Checkpoint8Z validated — next8AA (10NovUTC)

Full local and GitHub PASS: [42754551200](https://github.com/magicaddons/getgear/actions/runs/42754551200), source `9e572770bfc472385fcec507193f1c577d0a9665`; inspected direct bot/final validated HEAD `e38d38634bb2f368cb007d4c7262f727fcd9283d`.14 CI PASS logs/24 modules/four reports verified. Bot no runtime/code/index changes;6 CSV1439 sourceRow-only cells/0 semantic changes, README/provenance source metadata only. Exact raw8X→8Z Playfulls23313/9153:30 added IDs/1Pimgib dungeon definition/0 prior names or resolved facts/0removed;3054index-only rows/89uninterpretedfield10 changes. Everloot1399/1199 exact edges/counters unchanged/0selected10. Diagnostic snapshots refreshed, no timestamps-as-new-event inference. All30 new IDs outsidecanonical; later9A now72 separate pending candidates, no automatic adoption. Equipment2129/index3778/display3777/books759,crafts1254/ingredients4857. One item-side Grizzle10199 reference/nine honest origin gaps retained; no sourceType/gate/recipe/stat mutations. Remaining3773; **next8AA:first100 of145 undocumented58 IDs12616–17616**, marked queue. Other45/one59/550level60,quest190/world2887/liveexceptions remain open. No release/main action.

## Checkpoint8AA research preserved — integration pending

100 exact undocumented58/108queries/94classmasks.94 secondaryrank7/8/10-versus-primary-omission discrepancies,88 exactsecondary seller/coinrows,0cachedinventorymatches; no current gate/charge inferred.17223publisheditemeffect21180/21181pair,17074input404/Classic-source only, no new craft/material or bossloot.12970/13080secondary same-name availability disputes/3plain gaps; no primary unavailableflags. Proof CHECKPOINT8AA_IN_PROGRESS.md/working_evidence/discovery_index; all100 still8AA,registry2129/index3778/remaining3773/latest fullPASS8Z42754551200/bote38d386. Integrate/full local/CI/bot then8AB45undoc58. Later9A72 candidates/live exceptions separate. No release/main action.

## Checkpoint8AA integrated — GitHub pending

[100 undocumented58](CHECKPOINT8AA_LEVEL58_UNDOCUMENTED_FIRST100.md):94 rank7/8/10 version discrepancies,88 secondary seller/coinrows not current access;17223itemeffect21180/21181(not learnedcraft/inputClassicloot),2 same-name secondaryavailability disputes/3gaps. Full final local14Lua+offlinePython/24modules/fourreports PASS; CI pending.2129 earlier objects exact,100 summaries+14525 qualifiedsummary;3canonical dungeon community reference/confidence updates. New community14525promotion failed original local regression; generator identity/actor guard repaired,original Lua requirements/all6dungeon followups retained. Exact upstream21 newfeed IDs=3canonical+18outside,0previous indexed facts/edges changed;Playfulls23334/9153,Everloot1399/1199;9A90 candidates separate. Equipment2229/index3878/display3877/books759,crafts1254/ingredients4857. Remaining3673(undoc596/quest190/world2887);next8AB45undoc58 IDs17617–271936 afterCI/bot. No release/main action.

## Checkpoint8AA validated — next8AB

Full local and GitHub PASS: [42756875646](https://github.com/magicaddons/getgear/actions/runs/42756875646), source `de75e8e7ec8fb1b6338bc165531e86836aefea3f`; inspected direct bot/final validated HEAD `d25cab1bf0a1c9820e99ce026c6132335406473e`.14 Lua regressions plus offlinePython source-boundary check/24modules/fourreports PASS;15CI PASS lines verified. Bot only timestamp/three response hashes, no runtime/report/count change. Equipment2229/index3878/display3877/books759,crafts1254/ingredients4857.2129 prior reviewed objects exact;94 rank-version discrepancies/88 secondary coinrows,17223 itemeffect,2availability disputes/3gaps qualified. New3canonical dungeon community references retain unconfirmed rates;14525 staysqueued after conservative identity/exact-actor guard repair,all6original followups/original Lua assertions preserved. Exact upstream21newfeed IDs=3canonical+18outside,0 previously indexed facts/edges changed;Playfulls23334/9153,Everloot1399/1199.90 separate9A candidates not adopted. Remaining3673; **next8AB:all45 remaining undocumented58 IDs17617–271936**, marked queue. Thenone59/550level60/quest190/world2887/current-live exceptions. No release/main action.

## Checkpoint8AB research preserved — integration pending

45 final undocumented58 identities/49queries/10 nine-class mask projections;36 exact primary unavailable warnings,7 exact Bryanna263569 merchant cost/standing joins(3Honored/4Revered,Theramore2799),17617 historical secondaryrank7/Palanseer coin row versus primary omission,211941 origin unknown(actual guide row contradicts misleading search snippet). Cached NPC174/96 reused, not fresh stock.20288rawmask2561 projectsWarrior with out-of-scope2560; no class import. All45 still8AB,registry2229/index3878/remaining3673/latest fullPASS8AA42756875646/botd25cab1. Proof CHECKPOINT8AB_IN_PROGRESS.md/working_evidence/discovery_index. Resume integrate45; preserve2229 prior objects; fresh reconcile/full14Lua+offlinePython/24modules/fourreports/local+CI/bot; then8ACone59/550level60.90 separate9A candidates/live exceptions remain. No release/main action.

## Checkpoint8AB integrated — GitHub pending

45 finalundocumented58/36 exactprimaryunavailablewarnings/7 Bryanna merchantjoins(3Honored/4Revered,Theramore2799)/1historicalrankdiscrepancy/1Yarigap. Full14Lua+offlinePython/24modules/fourreportslocalPASS;CIpending.2229priorobjectsexact,45summarycellsonly,all6dungeonfollowupsretained. Equipment2274/index3923/display3922/books759;crafts1254/ingredients4857. Fresh23334/9153/1399raw1199qualifiedfeedfactsexact,0selectedobservededges;90pending9Acandidatesseparate. Remaining3628(undoc551/quest190/world2887);next8ACsole59 item211940 Ecks’av’sTribalGuardian then8ADfirst100level60. See CHECKPOINT8AB_LEVEL58_UNDOCUMENTED_FINAL45.md/evidence/local/rawreview. No release/mainaction.

## Checkpoint8AB validated — next8AC

Full local and GitHub PASS:[42758142459](https://github.com/magicaddons/getgear/actions/runs/42758142459),source `d574c2993b9b5903be04da9c189b3531c5148399`; inspected directbot/finalvalidated `d205851bda1f894eb969459f543292113c0e2263`.14Lua+offlinePython/24modules/fourreports PASS;15CItestPASS lines. Botonlytimestamp/three responsehashes, no runtime/report/countchanges. Equipment2274/index3923/display3922/books759;crafts1254/ingredients4857.36exactunavailablewarnings/7Bryanna cost-standingjoins(3Honored/4Revered,2799)/17617historicalrankdiscrepancy/211941sourceunknown;10maskprojections/20288extraout-of-scopebits retainedonlyinaudit.2229priorobjectsexact;45summarycellsonly;all6dungeonfollowupsopen. FreshPlayfulls23334/9153/Everloot1399raw1199qualifiedexactfacts/countersunchanged;90separate9Acandidatesunvalidated. Remaining3628(undoc551/quest190/world2887); **next8AC:soleundocumented59 item211940 Ecks’av’sTribalGuardian**,markedqueue,then8ADfirst100undocumented60. Existing single self-owned automation reconfirmedenabled10Nov04:48,lastwake04:12;noadditionalautomation. Noquota-meter/guaranteedrefreshclaim. Remote maincf7fa410/Beta8tag0a088935→543e5a24recheckedunchanged. No release/mainaction.
