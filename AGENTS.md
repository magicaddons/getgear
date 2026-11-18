# GetGear coding-agent guide

## Permanent source-control and cumulative build policy

This policy takes precedence over all historical task-specific instructions,
including old no-push, STOP, branch-selection and packaging statements. The
owner's current request always controls task scope. Historical instructions are
preserved for evidence in `docs/history/AGENTS-before-source-integrity.md`; they
are not an active work queue or authorization to publish a package.

Repository: `magicaddons/getgear`. Before starting any development session:

1. Fetch `origin` and identify the **current remote** `integration/cumulative`
   head. Read `CUMULATIVE_BASELINE.json`, `FEATURE_ACCEPTANCE.json`,
   `docs/SOURCE_CONTROL_AND_BUILDS.md` and `docs/CUMULATIVE_INTEGRATION.md`.
2. Verify that the canonical remote baseline preserves original cumulative
   `b31e30e92256a00dbb3b75347d77731b52a0f06f` and the four subsequent commits
   through recovered `e61c16c1a136d3972b0af5b18821ceec1a2239f7`.
3. Start an isolated development branch from the verified remote baseline, or
   verify the current development branch contains it before continuing. Do not
   choose the old runtime on `main` merely because a checkout is named `work`.
   Preserve other worktrees, accepted features and the approved acquisition data.

Every completed development checkpoint MUST:

1. Pass its applicable automated tests (the full integrated gate for code,
   generators, tests, contracts, packaging or workflow changes).
2. Commit all intended source, tool, test and documentation changes.
3. Push the isolated development branch to GitHub.
4. Verify GitHub's branch points to that **exact full HEAD SHA**, using a live
   remote query, not a local tracking ref. Read applicable CI through completion.
5. Record the remote branch, full commit SHA, validation commands/results and
   any remaining actual-client checks in the handover. A committed validation
   report can identify its parent implementation; record the final receipt SHA
   and remote verification separately to avoid a self-referential commit hash.

Pushes to isolated development branches are permitted and required within an
owner-authorized development task. Never modify `main`, merge, create a release
or tag, or publish a build without owner authorization. Advancing the canonical
integration branch requires reviewed, accepted work and owner authorization;
never automatically merge unfinished work into it. Never force-push, delete or
rewrite a recovery branch to resolve a mismatch.

A local commit or temporary workspace must never be the sole copy of a completed
checkpoint. On push/remote-verification failure, preserve the local commit and
run `tools/release/source_integrity.py` with `--recovery-output` to produce a
verified Git bundle and SHA-256 where possible. Report the failure and bundle
location clearly. A local emergency bundle is not a GitHub backup. Do not claim
safe publication or completed remote protection until the exact commit is verified.

## Mandatory testing-package gate

Creating an installable testing ZIP requires owner authorization. The current
infrastructure task authorizes no new gameplay testing ZIP, release, merge or
main change. Unit tests may use disposable synthetic packaging fixtures.

For every future authorized cumulative testing package use
`tools/release/build_test_package.py --remote-branch <development-branch>` with
an output directory outside the checkout. This gate has no authentication bypass.
It requires clean committed source, the exact HEAD on the designated GitHub
branch, current canonical ancestry, the feature acceptance contract, exact
committed packaging inputs, and the complete extracted-runtime Lua 5.1/5.4 gate.
It repeats source/remote checks before exposing the final delivery directory.

Keep BUILD_INFO.txt, PACKAGE_MANIFEST.json, SHA256SUMS, the ZIP checksum and full
validation receipts together. Never present a local candidate as an approved
cumulative testing package. Do not substitute manual ZIP creation or an older
release workflow for this gate. Removing an accepted feature requires explicit
owner approval and a reviewed contract/test update.

## Permanent systemic-fix and regression policy

For every bug, treat the named character, class, faction, item, recipe, quest,
source or view as a reproduction case, not the scope boundary. Identify and fix
the shared data, eligibility, recommendation, acquisition, scoring or rendering
rule. Audit its full applicable scope across all classes, factions, levels,
slots, professions, source types and presentation surfaces. Prefer reusable,
evidence-backed rules; justify genuinely unique mechanics separately. Add
positive and negative regressions across that scope, including faction-valid
original class combinations. Report root cause, affected counts, preservation,
uncertainty and remaining actual-client checks before declaring completion.

Keep equipment/use/crafting/acquisition eligibility separate from stat/build/
travel relevance. Evaluate every supported acquisition alternative; one blocked
route does not veto an item. Unknown facts remain uncertain. Show-all/off-spec
and custom priorities may lift relevance, never confirmed hard eligibility.
Preserve saved settings/progress, all accepted features, 900 historical candidate
holds and the approved 17-file acquisition snapshot. Do not bulk-import paused
navigation experiments or turn continent sentinel coordinates into local pins.

Published references, historical Classic tables and anonymous observations do
not prove live Forever loot, teaching, inventory or current-client rendering.
Do not restart completed research or repeat known failed URLs without new
reason. See `docs/GLOBAL_FILTERING_POLICY.md`, `docs/navigation-audit/REPORT.md`
and the cumulative feature contract for accepted behavior and manual checks.

## Validation

Use `tools/validate_recommendations.py` with Lua 5.1/5.4 and output outside the
checkout. It includes feature-contract/build regressions, every gameplay Lua
suite, catalogue/navigation audits and release-tool tests. Verify the approved
snapshot with `tools/reconcile_presentation_snapshot.py --verify-only`; fresh
upstream diagnostics run separately and never silently replace accepted data.
Documentation-only follow-ups need targeted integrity checks and must retain the
latest full validation receipt without claiming a new full run. No real-client
acceptance is inferred from synthetic automated tests.
