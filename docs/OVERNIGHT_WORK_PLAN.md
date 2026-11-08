# GetGear: bounded overnight development and Codex handover

**Prepared 2026-11-09.** This is a proposed procedure, not evidence that unattended tasks have completed. It is designed to survive chat/session failures and make a future Codex Cloud migration straightforward.

## Entry gate for every run

1. Read `AGENTS.md`, `docs/RECONCILIATION_PROGRESS.md`, `docs/source-audit-1-60/RELEASE_GATE.md`, `docs/source-audit-1-60/reconciliation-20261109/README.md`, and recent GitHub Actions results.
2. Verify current branch HEAD; inspect CI bot-generated commits before writing. Select **one** small unresolved group. Do not repeat already finished case IDs.
3. Source research: record the item ID, exact name, profession, book item ID, claimed source route, original confidence, new publication URL and date, what the source really demonstrates, and whether Forever live verification is missing.
4. Make only supported, additive changes. Prefer a separate reference evidence record, with user-facing caveats, over altering primary item facts. Assert ID/name consistency.
5. Test the full no-release workflow. Wait for successful CI and any generated report commit; otherwise repair or stop with explicit error.
6. Persist an incremental handover entry with item-level results, counts, commit SHA, passing CI URL, outstanding uncertainties, and the precise next group. Never claim an incomplete research pass is validated.

## Work queue

1. **Dungeon tail (6 cases).** These do not block recipe-source research. Leave unproven loot/spawn associations open until genuinely stronger Forever item-specific evidence appears. IDs: 10801, 11945, 11946, 14525, 23173, 273044. Two coffer references are container leads, not enemy NPCs.
2. **Recipe books — vendor group (68 records).** Review in small clusters (e.g. 5–12 book IDs) by vendor, reputation, specialisation and source family. Separate observed live stock from Forever-published reference-only vendor listings, missing stock and gated plans. Watch for replicated vendor leads, especially Aisarra Nightmeadow.
3. **Recipe books — trainer-labelled group (886 records).** Partition by profession and then character level or recipe skill. For each group distinguish trainer-taught spell, physical learnable book, both, world/drop-only or unknown. Do not infer a contradiction solely because the record is trainer-labelled and has a book ID.
4. **Other gear acquisition uncertainty.** Inspect `docs/source-audit-1-60/unresolved_items.csv` for vendor, quest, dungeon, and crafted-source issues; use item-ID-specific Forever evidence. Avoid wholesale replacement of existing gear.
5. **Final integrity/regression pass.** Reconcile 7,707 equipment identities, 36,341 class objectives, 1,252 indexed recipes, crafting mats, nine-class legality, overlay positive-stat and armour-only opt-in, default-hidden green world BoEs, saved setting migrations, inventory/mats, preview layout, non-targetable/world drop classifications, performance and no fake loot rates.
6. **In-game acceptance plan.** Supply a short matrix for source labels, recipe books/vendors, mixed positive/negative stat changes, empty slots, tracked/all materials, settings persistence, and UI readability. Ask for approval **only** for packaging/tagging/release/merging—not for ordinary offline research, validation or development commits.

## Error and time-budget rules

- One source category, one limited set of item IDs, and one CI validation per run. Do not fire parallel writes to the same branch or overlap validation runs.
- Use version-locked reads and compare-and-swap/expected HEAD on branch writes. Review generated evidence artifacts after a CI bot push.
- A failed tool call or chat input stream must not lose progress: publish findings as a checkpoint entry at the end of a completed sub-batch. If validation is incomplete, mark the entry **PENDING**, never PASS.
- If connector/network access is unavailable, do not hallucinate a commit, source, or CI pass. Report blocker and stop safely.
- Periodically propose concrete improvements (e.g. reference-provenance confidence tiers, staleness markers, duplicate-source checks, cross-item source invariants, missing-recipe identification, and provenance regression tests) without introducing changes not covered by tests.
- **Prohibited without explicit approval:** compiling/packaging ZIP, release, tag, public publishing or modification/merge to `main`.

## Handover to Codex Cloud

Connect `magicaddons/getgear`, select the development branch, and configure a cloud environment with Python 3 and Lua 5.4; enable access needed for public data retrieval and GitHub Actions monitoring. Put this file and `AGENTS.md` in Codex's agent context. Ask Codex to work on one bounded batch, check tests and push with source evidence, then continue from GitHub's recorded progress—not from an old chat context. Do not assume Codex automations are already configured.
