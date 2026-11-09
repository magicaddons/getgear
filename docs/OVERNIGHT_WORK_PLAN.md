# GetGear: continuous Codex research and checkpoint plan

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
2. **Recipe books — vendor group (68 records).** Publication research completed in Checkpoint 5H; current live-stock confirmation remains outstanding. Revisit in small clusters when stronger evidence appears, by vendor, reputation, specialisation and source family. Separate observed live stock from Forever-published reference-only vendor listings, missing stock and gated plans. Watch for replicated vendor leads, especially Aisarra Nightmeadow.
3. **Recipe books — trainer-labelled group (886 records).** Checkpoints 6B–6R individually researched 568 records, including all 266 lower-level entries and all Favor/quest/other-vendor/reputation/dungeon cohorts. Publication research does not establish live acquisition. Next: 167 generic-drop and 151 no-alternative cases (318 remaining). Preserve exact book/version IDs, starts/turn-ins, reward choices, alternate routes, specific purchase gates and unresolved access. No book necessity, cumulative faction gate or live loot inferred from existence, price or a recipe family.
4. **Other gear acquisition uncertainty.** Inspect `docs/source-audit-1-60/unresolved_items.csv` for vendor, quest, dungeon, and crafted-source issues; use item-ID-specific Forever evidence. Avoid wholesale replacement of existing gear.
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
