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
