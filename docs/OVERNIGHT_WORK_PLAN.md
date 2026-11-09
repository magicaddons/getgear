# GetGear: continuous Codex research and checkpoint plan

**Current steering (9 November 2026, resumed after Beta 8): continue all outstanding offline acquisition research and validation unattended on the development branch. Beta 8 is published and must not be overwritten/republished. No new build, package, tag, release or main changes. See the exact remaining case queue and continuation handover below.**

**Prepared 2026-11-09; revised for Codex on 2026-11-09 with user authorisation.** This procedure permits sustained work through multiple sequential batches in one session. It is not evidence that unattended tasks have completed. Durable checkpoints remain necessary because tool, network, credential, context and session failures are still possible in Codex.

## Session scope and continuation

- Follow the user's authorised research/correction scope across successive checkpoints without requiring a new prompt after every batch. There is no one-batch, one-source-category or one-CI-run limit per session.
- Keep each individual batch coherent and reviewable. Finish its evidence, appropriate validation, commit and any CI bot review before starting the next batch. Do not accumulate multiple unvalidated addon changes.
- Prioritise actionable lower-level gear acquisition inside the overlay and detailed guide: exact item/book/spell IDs, named enemies/vendors/quests, locations, faction and published requirements, preserving alternate routes and uncertainty. Research can span professions and source categories sequentially; exhaust credible available evidence without inventing facts or repeatedly searching exhausted leads.
- Continue until the authorised scope is complete, the user pauses/changes direction, or a material blocker prevents safe progress. Try available authorised fallbacks for tool/credential failures; continue independent work where possible. If blocked or interrupted, record the exact state, pending validation, commit/run IDs and next steps. Do not treat a completed checkpoint as an interruption.
- Release permissions are unchanged: no ZIP/build/package, tag, public release, merge, release workflow or main modification without explicit user authorisation.

## Entry gate for every run

1. Read `AGENTS.md`, `docs/RECONCILIATION_PROGRESS.md`, `docs/source-audit-1-60/RELEASE_GATE.md`, `docs/source-audit-1-60/reconciliation-20261109/README.md`, and recent GitHub Actions results.
2. Verify current branch HEAD; inspect CI bot-generated commits before writing. Select the next coherent unresolved group for the first batch; repeat the checkpoint cycle for subsequent groups within the authorised scope. Do not repeat already finished case IDs.
3. Source research: record the item ID, exact name, profession, book item ID, claimed source route, original confidence, new publication URL and date, what the source really demonstrates, and whether Forever live verification is missing.
4. Make only supported, additive changes. Prefer a separate reference evidence record, with user-facing caveats, over altering primary item facts. Assert ID/name consistency.
5. For a batch changing addon behaviour, source data, generators, tests or workflows, run local full reconciliation/regressions and the full no-release workflow. Wait for successful CI and inspect any generated report commit before starting the next batch; otherwise repair or record the exact blocker. For documentation-only work, perform targeted evidence/link/integrity checks, state that no new full CI ran, and retain the latest validated code result.
6. Persist an incremental handover entry with item-level results, counts, commit SHA, passing CI URL where applicable, outstanding uncertainties, and the precise next group. Never claim an incomplete research pass is validated. Continue to the next batch without another permission request when already covered by the user’s scope.

## Work queue

1. **Dungeon tail (6 cases).** These do not block recipe-source research. Leave unproven loot/spawn associations open until genuinely stronger Forever item-specific evidence appears. IDs: 10801, 11945, 11946, 14525, 23173, 273044. Two coffer references are container leads, not enemy NPCs.
2. **Recipe books — vendor group (68 records).** Checkpoint 5H completed initial publication assessment; Checkpoint 7A recovered all exact book/spell/gate/cost pages, joined all 68 IDs to independent Aisarra inventory and integrated details into runtime. Exact Friendly Advice quest identity/chain and current access remain unresolved. Do not copy ranks/slots or infer live stock.
3. **Recipe books — trainer-labelled group (886 records).** Checkpoints 6B–6U individually publication-researched all 886 cases; exact triage/reviewed set equality passes. All 954 queued book cases now have reviewed runtime metadata. Keep 165 no-named-route origins, 16 further book origins with trainer alternatives, five unavailable versions and disputed access explicit. Publication completion does not establish live availability/book necessity. Do not repeat exhausted leads without stronger evidence.
4. **Other gear acquisition uncertainty.** Checkpoint 7B individually researches 14 lower-level quest items and exposes their exact reward/choice/object/actor/chain details without changing catalogue eligibility. Checkpoint 7C researched all 93 selected lower-level vendor cases (194 exact inventory joins), including 19 explicit cross-version warnings and two unknown origins. Checkpoint 7D completed the 107 selected lower-level Source not documented items: 41 named-source references, eight unavailable-page flags, ten cross-version warnings and 48 explicit gaps. Research has resumed after verified Beta 8 publication. Remaining work: broad world-drop coverage and higher-level vendor/quest/undocumented sources, with unchanged catalogue identity/class/equip filters. Then inspect `docs/source-audit-1-60/unresolved_items.csv` for vendor, quest, dungeon, and crafted-source issues; use item-ID-specific Forever evidence. Avoid wholesale replacement of existing gear.
5. **Final integrity/regression pass.** Reconcile 7,707 equipment identities, 36,341 class objectives, 1,252 indexed recipes, crafting mats, nine-class legality, overlay positive-stat and armour-only opt-in, default-hidden green world BoEs, saved setting migrations, inventory/mats, preview layout, non-targetable/world drop classifications, performance and no fake loot rates.
6. **In-game acceptance plan.** Supply a short matrix for source labels, recipe books/vendors, mixed positive/negative stat changes, empty slots, tracked/all materials, settings persistence, and UI readability. Ask for approval **only** for packaging/tagging/release/merging—not for ordinary offline research, validation or development commits.

## Error and time-budget rules

- Multiple source categories, item groups and CI runs may be completed sequentially in a session. Each batch has an explicit item set, evidence note and appropriate validation. Do not fire parallel writes to the same branch or overlap validation runs.
- Use version-locked reads and compare-and-swap/expected HEAD on branch writes. Review generated evidence artifacts after a CI bot push.
- A failed tool call or chat input stream must not lose progress: publish findings as a checkpoint entry at the end of a completed sub-batch. If validation is incomplete, mark the entry **PENDING**, never PASS.
- If connector/network access is unavailable, do not hallucinate a commit, source, or CI pass. Use an authorised working fallback where available. If a required validation or write remains blocked, preserve findings, report the exact blocker and stop dependent work safely.
- Periodically propose concrete improvements (e.g. reference-provenance confidence tiers, staleness markers, duplicate-source checks, cross-item source invariants, missing-recipe identification, and provenance regression tests) without introducing changes not covered by tests.
- **Prohibited without explicit approval:** compiling/packaging ZIP, release, tag, public publishing or modification/merge to `main`.

## Handover to Codex Cloud

Connect `magicaddons/getgear`, select the development branch, and configure a cloud environment with Python 3 and Lua 5.4; enable access needed for public data retrieval and GitHub Actions monitoring. Put this file and `AGENTS.md` in Codex's agent context. Ask Codex to continue through the authorised research scope in sequential bounded batches, checking tests and pushing source evidence at each applicable checkpoint. Resume from GitHub’s recorded progress rather than an old chat context; no fresh prompt is required between successful batches. Do not assume Codex automations are already configured.

## Resumed queue — checkpoint 8A

[Continuation handover](source-audit-1-60/reconciliation-20261109/CONTINUATION.md) and [frozen exact-ID queue](source-audit-1-60/reconciliation-20261109/remaining_equipment_research_queue.csv) distinguish individual reviewed metadata from generic generated summaries. Next 8B: remaining 95 vendor cases at levels 1–30; then remaining lower-level quests, higher-level vendor/quest/undocumented cases, broad world-drop references and reputation exceptions. Completed recipe and dungeon work is not reopened absent stronger evidence. Every queue case needs a traceable researched disposition, including explicit unresolved/version/access exceptions; publication coverage never closes live verification.

## Queue advance — checkpoints 8B/8C validated

8B individually researched 95 remaining lower-level vendor items; full local/CI PASS 42616476682. 8C researched 34 remaining lower-level quest-family items; full local/CI PASS 42617823815, inspected bot 0cae6bb54173ad3a3d6296c5ae4a19adf5dca30f. Equipment registry 343, recipes 954, runtime summaries 2,178. Remaining exact queue 5,559; **next 8D: 71 vendor cases at catalogue levels 31–40**. Follow the latest continuation/progress entry over historical next-step text.

## Queue advance — checkpoint 8D validated

71 vendor cases at levels 31–40 complete; full local/CI PASS 42618811590, inspected bot d4110ea3c1bf821df92cb3939be64285a0ce1efe. Equipment 414, recipes 954, runtime summaries 2,210; remaining queue 5,488. **Next 8E: ten quest-family cases at levels 31–50**, then 31–40 undocumented source cases. No release permission.

## Queue advance — checkpoint 8E validated

Ten quest-family cases at levels 31–50 complete; full local/CI PASS 42620153753, inspected bot c7cb16e8b9af3fd80838a43db882cb7085fd56e3. Equipment 424, recipes 954, runtime summaries 2,215; remaining queue 5,478. **Next 8F: 93 undocumented-source cases at levels 31–40**. Preserve structured facts/joins/fingerprints without full source narratives.

## Checkpoint 8F validated — next 8G

Full local and GitHub PASS: [42654914045](https://github.com/magicaddons/getgear/actions/runs/42654914045), source `801ae96935e90d4baae1952262bd24dfde67855d`; inspected direct bot/final validated HEAD `c283e82aaee5b284e49d524433174ea82e4697db`. All 14 PASS log lines verified; 24 modules/four reports. Bot changes only provenance timestamps/data-as-of and three response hashes; counts/runtime/reports unchanged. Equipment517/index2,308/display2,307; crafts1,254/ingredients4,857. Remaining5,385; next8G:207 vendor cases at41–50. No release/main change.

## Checkpoint 8G integrated — GitHub pending

[207 vendor items41–50](source-audit-1-60/reconciliation-20261109/CHECKPOINT8G_LEVEL41_50_VENDORS.md):196 primary named-reference cases (30 explicit version warnings), seven secondary Everlook leads, four exact gaps. 227 two-sided/23 merchant-only edges; blocked27 item pages distinguished. All517 previous registry entries intact; equipment724/index2,470/display2,469/books759/crafts1,254/ingredients4,857. Full local PASS14/14,24 modules,four reports; GitHub PENDING, finish/bot-review before8H. Fresh comparison only207 additive summaries, no other derived semantic changes. Remaining5,178; next8H:65 undocumented41–50. No release/main action.

## Checkpoint 8G validated — next 8H

Full local and GitHub PASS: [42656807047](https://github.com/magicaddons/getgear/actions/runs/42656807047), source `3c7041809db0b49c6f9c8e3f0a56465dd4af444f`; inspected direct bot/final validated HEAD `54346df61203ada57c6ce16fd9da83b87e6511f9`. All14 PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment724/index2,470/display2,469; crafts1,254/ingredients4,857. Remaining5,178; **next8H:65 undocumented41–50**. Main/Beta8 tag independently unchanged; no release action.

## Checkpoint 8H integrated — GitHub pending

[65 undocumented-source items41–50](source-audit-1-60/reconciliation-20261109/CHECKPOINT8H_LEVEL41_50_UNDOCUMENTED.md):13 exact vendor references, one quest reward, one item-use assembly, one attributed beta drop report, one generic label,48 honest origins. Lasso provided220216 differs from reward219345; later Lynnore reverse quests absent. Jang9380 and Fist17733 cannot inherit different same-name loot IDs. Full local PASS14/14,24 modules,four reports; GitHub PENDING. Equipment789/index2,535/display2,534/books759; crafts1,254/ingredients4,857 unchanged.65 additive summaries only, all724 prior entries/fingerprints retained. Remaining5,113; next8I:25 vendors at55. No release/main action.

## Checkpoint 8H validated — next 8I

Full local and GitHub PASS: [42658598705](https://github.com/magicaddons/getgear/actions/runs/42658598705), source `d1d0e8d3309e1d857db1a52007daaaa4f557ba51`; inspected direct bot/final validated HEAD `a229094ea988037908d330aa1c1b9c339e212313`. All14 PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment789/index2,535/display2,534/books759; crafts1,254/ingredients4,857. Remaining5,113; **next8I:25 vendors at55**. No release/main action.

## Checkpoint 8I integrated — GitHub pending

[25 level55 vendor cases](source-audit-1-60/reconciliation-20261109/CHECKPOINT8I_LEVEL55_VENDORS.md):64 exact merchant joins/six NPCs; two missing maps; seller-specific faction gates/prices preserved. Opposing Exalted requirements are alternatives; standing0 is not Neutral. Full local PASS14/14,24 modules,four reports; GitHub PENDING. Equipment814/index2,543/display2,542/books759, crafts1,254/ingredients4,857 unchanged. All789 prior registry entries retained; remaining5,088; next8J:63 vendors at58. No release/main action.

## Checkpoint 8I validated — next 8J

Full local and GitHub PASS: [42660857813](https://github.com/magicaddons/getgear/actions/runs/42660857813), source `ecc4b2882c3340e985a9b8576bc78e7b759aea56`; inspected direct bot/final validated HEAD `b54a4afa7fd38c7c5e9f494546c95f46a1e98663`. All14 PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment814/index2,543/display2,542/books759; crafts1,254/ingredients4,857. Remaining5,088; **next8J:63 vendors at58**. No release/main action.

## Checkpoint 8J integrated — GitHub pending

[63 level58 vendor cases](source-audit-1-60/reconciliation-20261109/CHECKPOINT8J_LEVEL58_VENDORS.md):59 exact merchant joins/seven NPCs and four exact missing Mail/Lamellar origins. Darkspear58 ranks directly evidenced, no copied lower-tier data. Full local PASS14/14,24 modules,four reports; GitHub PENDING. Equipment877/index2,578/display2,577/books759; crafts1,254/ingredients4,857 unchanged. All814 prior entries retained;63 additive summaries only. Remaining5,025; next8K:first100 remaining level60 vendor IDs numerically sorted/marked queue. No release/main action.

## Checkpoint 8J validated — next 8K

Full local and GitHub PASS: [42661663397](https://github.com/magicaddons/getgear/actions/runs/42661663397), source `2dca2c05b45a78c94e10e71d434d80293d180a25`; inspected direct bot/final validated HEAD `884c9284bdf966d0eb4c44131655f7f104dd044f`. All14 PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment877/index2,578/display2,577/books759; crafts1,254/ingredients4,857. Remaining5,025; **next8K:first100 remaining level60 vendor IDs**, marked in queue (12584 through18826). Main/Beta8 tag independently unchanged. No release action.

## Checkpoint 8K integrated — GitHub pending

[100 level60 PvP vendor cases](source-audit-1-60/reconciliation-20261109/CHECKPOINT8K_LEVEL60_PVP_FIRST100.md):100 exact coin-table joins/four unmapped NPCs, zero current exact-ID purchase paths confirmed. Official-announcement mirror/current guide describe Honor/upgrade policy; exact version/currency/rank mapping remains unresolved. No Premier substitution, invented rank or unavailable flag. Full local PASS14/14,24 modules,four reports; GitHub PENDING. Equipment977/index2,678/display2,677/books759; crafts1,254/ingredients4,857 unchanged. All877 prior entries retained;100 additive summaries only. Remaining4,925; next8L:first100 remaining60-vendor IDs marked queue. No release/main action.

## Checkpoint 8K validated — next 8L

Full local and GitHub PASS: [42662988658](https://github.com/magicaddons/getgear/actions/runs/42662988658), source `c9d8fd597510b2f82c4ee911bb0be5f3faae14a3`; inspected direct bot/final validated HEAD `1457558187acb64620c2b2d43deeacde73a9cbce`. All14 PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment977/index2,678/display2,677/books759; crafts1,254/ingredients4,857. Remaining4,925; **next8L:first100 remaining level60 vendors** (18827 through23253), marked queue. Current PvP exact-ID currency/rank/upgrade access remains unresolved. No release/main action.

## Checkpoint 8L integrated — GitHub pending

[Second100 level60 vendor cases](source-audit-1-60/reconciliation-20261109/CHECKPOINT8L_LEVEL60_VENDORS_SECOND100.md):98 named cases/114 exact joins/11 NPCs;63 rank-named current paths unresolved,35 explicit reputation references,two missing shoulder origins. Five merchants unpinned. Shared8K policy reused without repeated research or guessed gates/currency/retirement. Full local PASS14/14,24 modules,four reports; GitHub PENDING. Equipment1,077/index2,757/display2,756/books759; crafts1,254/ingredients4,857 unchanged. All977 earlier entries retained;100 additive summaries only. Remaining4,825; next8M:first100 remaining level60 vendor IDs marked queue. No release/main action.

## Checkpoint 8L validated — next 8M

Full local and GitHub PASS: [42663990981](https://github.com/magicaddons/getgear/actions/runs/42663990981), source `cc28ef28cb9f58faea8c2a6c45399fcb725a98c1`; inspected direct bot/final validated HEAD `f3857cddf86cf6b8e37123e8dabcdae4eadd7196`. All14 PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment1,077/index2,757/display2,756/books759; crafts1,254/ingredients4,857. Remaining4,825; **next8M:first100 remaining level60 vendors** (23254 through227070), marked queue. Rank-named current purchase paths and all current-source uncertainties retained. No release/main action.

## Checkpoint 8M integrated — GitHub pending

[Third100 level60 vendor cases](source-audit-1-60/reconciliation-20261109/CHECKPOINT8M_LEVEL60_PVP_THIRD100.md):100 exact item/merchant joins/four unmapped NPCs;96 current purchase paths unresolved,four exact seasonal version warnings. Warning flags not propagated to other IDs; four Tomes remain finished off-hands. Shared8K system context reused. Full local PASS14/14,24 modules,four reports; GitHub PENDING. Equipment1,177/index2,857/display2,856/books759; crafts1,254/ingredients4,857 unchanged. All1,077 earlier entries retained;100 additive summaries only. Remaining4,725; next8N:first100 remaining level60 vendor IDs marked queue. No release/main action.

## Checkpoint 8M validated — next 8N

Full local and GitHub PASS: [42665123374](https://github.com/magicaddons/getgear/actions/runs/42665123374), source `811035f8d8b6839067e82d38a6d090d51cf04f6f`; inspected direct bot/final validated HEAD `55bffb10c8717085b81a2b36cb9cc61309b4c7c1`. All14 PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment1,177/index2,857/display2,856/books759; crafts1,254/ingredients4,857. Remaining4,725; **next8N:first100 remaining level60 vendors** (227071 through227172), marked queue. Four exact version warnings and current purchase uncertainty retained. No release/main action.

## Checkpoint 8N integrated — GitHub pending

[Fourth100 level60 vendor cases](source-audit-1-60/reconciliation-20261109/CHECKPOINT8N_LEVEL60_PVP_FOURTH100.md):100 exact joins/two unmapped NPCs;72 current-access-unverified references/28 exact version warnings, all corroborated by same-item seasonal/unconfirmed fields (not independent publisher claims). Shared8K policy reused without inferred ranks/currency/retirement. Full local PASS14/14,24 modules,four reports; GitHub PENDING. Equipment1,277/index2,957/display2,956/books759; crafts1,254/ingredients4,857 unchanged. All1,177 earlier entries retained;100 additive summaries only. Remaining4,625; next8O:first100 remaining level60 vendor IDs marked queue. No release/main action.

## Checkpoint 8N validated — next 8O

Full local and GitHub PASS: [42666508212](https://github.com/magicaddons/getgear/actions/runs/42666508212), source `befe841ba8a0f5b48551ede3e80f8382b5da15ad`; inspected direct bot/final validated HEAD `2fd9b88ec273213d73fc32756d1be3f1174e0712`. All14 PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment1,277/index2,957/display2,956/books759; crafts1,254/ingredients4,857. Remaining4,625; **next8O:first100 remaining level60 vendors** (227173 through231582), marked queue. Raw-source review records39 unused-field-only changes and1,375 raw/1,178 qualifying Everloot edges with no new derived source adoption; exact historical delta limitations explicit and factual snapshots preserved. No release/main action.

## Checkpoint 8O research preserved — integration pending

8O research preserved in CHECKPOINT8O_IN_PROGRESS.md/checkpoint8o_working_evidence.json:100 identities,114 merchant joins,16 exchanges/23 inputs/48 reverse cost joins,22 exact version warnings.84 PvP cases and16 item exchanges must remain distinct; profession-use290 is not learned crafting or purchase access, and Scourgestones12843 are not Valor Tokens12844. Runtime/full validation/queue advance PENDING; all100 remain8O/unreviewed, registry1,277/index2,957/remaining4,625. Latest full PASS42666508212/bot2fd9b88 retained. Finish saved integration then full local/CI/bot; no release/main action.

## Checkpoint 8O integrated — GitHub pending

[100 level60 vendor cases](source-audit-1-60/reconciliation-20261109/CHECKPOINT8O_LEVEL60_VENDOR_EXCHANGES.md):84 PvP references/16 item exchanges,114 merchant joins/48 input reverse joins,22 exact seasonal warnings. Bound outputs/profession-use290 separate from base BoE craft, learned recipes and purchase gates. Exact Scourgestones12843, not ValorTokens12844; barter is not free. Full local PASS14/14,24 modules,four reports; GitHub PENDING. All1,277 earlier objects retained;100 summary changes only. Equipment1,377/index3,057/display3,056/books759; crafts1,254/ingredients4,857 unchanged. Remaining4,525; next8P:first100 remaining60-vendor IDs231583–231691, marked queue, after CI/bot review. No release/main action.

## Checkpoint 8O validated — next 8P

Full local and GitHub PASS: [42710850319](https://github.com/magicaddons/getgear/actions/runs/42710850319), source `533bafd48f81fb25c265ed71a86de6e0320b7a5e`; inspected direct bot/final validated HEAD `103cd7f27f3f87ef3cbb281db7dca64e7c6e9b20`. All14 CI PASS logs verified;24 modules/four reports; local14 rerun on bot data PASS. Material fresh-feed deltas reviewed in checkpoint8o_bot_upstream_review.json: Robe of the Moccasin6465/Lord Cobrahn3669 five-install observed edge; Pattern2601/Deviate Shambler5761 five-install book edge (not finished2585); six other canonical edge counters and two prior Cobrahn counters. Six dungeon exceptions/954 book-route queue remain open. Playfulls23,280/9,152:39 new IDs,0 changed resolved facts on previous rows,10,660 index-only shifts/61 uninterpreted field10 updates. Everloot1,398/1,198:23 exact added edges/49 counter-time updates/0 removals; selected8O edges0. Client encounter names unchanged, only build metadata. Diagnostic snapshots refreshed with attribution/fingerprints; not runtime inputs. Equipment1,377/index3,057/display3,056/books759; crafts1,254/ingredients4,857. Remaining4,525; **next8P:first100 remaining60-vendor IDs231583–231691**, marked queue.84 PvP/16 exchange cases preserve exact costs/bindings/use-professions and22 version warnings. No release/main action.

## Checkpoint 8P integrated — GitHub pending

[100 level60 PvP vendor cases](source-audit-1-60/reconciliation-20261109/CHECKPOINT8P_LEVEL60_PVP_FIFTH100.md):100 exact merchant joins/two unmapped NPCs;95 current-access-unverified/five exact seasonal-version warnings. Shared8K policy reused; no inferred Honor/rank/current charge/retirement. Full local PASS14/14,24 modules,four reports; GitHub PENDING. All1,377 earlier objects retained;100 summaries only. Equipment1,477/index3,157/display3,156/books759; crafts1,254/ingredients4,857 unchanged. Remaining4,425; next8Q:first100 remaining60-vendor IDs231692–235479, after CI/bot review. Feeds unchanged from audited8O; no release/main action.

## Checkpoint 8P validated — next 8Q

Full local and GitHub PASS: [42711806965](https://github.com/magicaddons/getgear/actions/runs/42711806965), source `b5590f1cb16d00cbf373abce5128c81755ea0354`; inspected direct bot/final validated HEAD `3aef918f3e028d0134038d6c5f1f25cbb80cc310`. All14 CI PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment1,477/index3,157/display3,156/books759; crafts1,254/ingredients4,857. Remaining4,425; **next8Q:first100 remaining60-vendor IDs231692–235479**, marked queue.95 current-access-unverified references/five exact version warnings remain publication facts. No release/main action.

## Checkpoint 8Q integrated — GitHub pending

[100 level60 vendor cases](source-audit-1-60/reconciliation-20261109/CHECKPOINT8Q_LEVEL60_NOZDORMU_EXCHANGES.md):65 exact PvP inventory joins/35 Anachronos item-page exchanges;23 embedded input identities, unread NPC/input reverse tables explicitly retained.35 tooltip/rank fields agree; ten exact class masks preserved;13 seasonal warnings (five rings/eight PvP). No old three-path quest mapping, current purchase gate, free barter or invented input farm. Full local14/24/4 PASS; GitHub pending. All1,477 prior objects unchanged;100 summaries only. Equipment1,577/index3,257/display3,256/books759; crafts1,254/ingredients4,857. Remaining4,325; next8R100 IDs235480–240047 after CI/bot review. No release/main action.

## Checkpoint 8Q validated — next 8R

Full local and GitHub PASS: [42712734634](https://github.com/magicaddons/getgear/actions/runs/42712734634), source `644718a8324879753e3eb05ef9bd6c395f40b318`; inspected direct bot/final validated HEAD `89b23cebec03ebd1e88f890cfd71cc7120877b9b`. All14 CI PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment1,577/index3,257/display3,256/books759; crafts1,254/ingredients4,857. Remaining4,325; **next8R:first100 remaining60-vendor IDs235480–240047**, marked queue.65 exact PvP reverse joins/35 item-only Anachronos references,23 embedded input identities and missing independent NPC/input reads remain explicit.13 exact version warnings; no invented current gate/farm/quest or all-tier purchase requirement. No release/main action.

## Checkpoint 8R integrated — GitHub pending

[100 level60 vendor cases](source-audit-1-60/reconciliation-20261109/CHECKPOINT8R_LEVEL60_SANCTIFIED_EXCHANGES.md):92 alternative two-merchant Sanctified exchanges/eight PvP references;192 exact joins,276 cost components/57 unnamed inputs.57 input pages404/cache names0, no invented names/binding/farm/reverse evidence. Repair Chalice1232438→239117 is an item-effect lead, not learned craft.16 outgoing Inquisition conversions are not selected origins.92 class masks/one exact seasonal warning preserved. Full local14/24/4 PASS; GitHub pending. All1,577 prior objects unchanged;100 summaries only. Equipment1,677/index3,357/display3,356/books759; crafts1,254/ingredients4,857. Remaining4,225; next8S100 IDs240048–246062 after CI/bot. No release/main action.

## Checkpoint 8R validated — next 8S

Full local and GitHub PASS: [42713893409](https://github.com/magicaddons/getgear/actions/runs/42713893409), source `0f83f331cb27d873276707242ae734d33dc9d75c`; inspected direct bot/final validated HEAD `b274ae9211d05348e007cdc2206407d774bce36a`. All14 CI PASS logs verified;24 modules/four reports. Bot changes only run timestamp/four response hashes (Playfulls landing/three API pages); exact content-addressed shards, runtime/counts/reports unchanged. Equipment1,677/index3,357/display3,356/books759; crafts1,254/ingredients4,857. Remaining4,225; **next8S:first100 remaining60-vendor IDs240048–246062**, marked queue.92 alternative exchanges/192 total joins retain57 unnamed404 inputs and item-effect/secondary leads without new crafts; one exact warning and16 outgoing conversions retained. No release/main action.

## Checkpoint 8S integrated — GitHub pending

[100 Sanctified vendor cases](source-audit-1-60/reconciliation-20261109/CHECKPOINT8S_LEVEL60_SANCTIFIED_ALTERNATIVES.md):200 exact item-page cost joins/216 inventory options. Eight246055–246062 output pages omit two Leonid alternatives each;16 prior known input pages independently match full four-cost sets. Preserve discrepancy/alternatives, not cumulative ingredients or exclusive prices.57 unnamed-input gaps reused; no duplicate research/new crafts. Full local14/24/4 PASS; GitHub pending. All1,677 prior objects unchanged;100 summaries only. Equipment1,777/index3,457/display3,456/books759; crafts1,254/ingredients4,857. Remaining4,125; next8T:all42 remaining vendors272095–272958, after CI/bot. No release/main action.

## Checkpoint 8S validated — next 8T

Full local and GitHub PASS: [42714767876](https://github.com/magicaddons/getgear/actions/runs/42714767876), source `1b8027e1743f71367904d4fa20d28b5fab7c166e`; inspected direct bot/final validated HEAD `28ca2642e553d16d295f1fcdfe65da6653064330`. All14 CI PASS logs verified;24 modules/four reports. Bot changes only run timestamp/three response hashes; runtime/counts/reports unchanged. Equipment1,777/index3,457/display3,456/books759; crafts1,254/ingredients4,857. Remaining4,125; **next8T:all42 remaining frozen vendor cases272095–272958**, marked queue.200 primary cost joins/216 inventory options retain eight collapsed-output-page discrepancies and16 prior input-page full4-cost-set matches;57 unnamed gaps reused. No release/main action.

## Checkpoint 8T integrated — GitHub pending

[Final42 vendor cases](source-audit-1-60/reconciliation-20261109/CHECKPOINT8T_FINAL_VENDORS_CURRENCY.md):11 exact Darkspear Exalted and31 Pix currency3469 references;42 merchant/31 currency joins. Cap165 differs from item226404250 limits; earning/purchase55 assumptions are dated25Oct, not current-confirmed. Full local14/24/4 PASS; GitHub pending. All1,777 prior objects retained;42 summaries only. Equipment1,819/index3,499/display3,498/books759; crafts1,254/ingredients4,857. Frozen vendor1,403/1,403 publication-researched,0 remaining. Frozen remaining4,083; next8U2 reputation28 cases19525/20099 after CI/bot. Later9A:39 upstream IDs verified outside canonical CSV, separately registered candidates requiring scope/version/eligibility/acquisition audit, no automatic adoption/count inflation. No release/main action.
