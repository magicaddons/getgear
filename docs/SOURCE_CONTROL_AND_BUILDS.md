# Source control, production and testing builds

`main` is the authoritative **latest user-approved production source**. Beta 11 promotes the complete accepted cumulative implementation from `fix/alliance-acquisition-20261121` at `5b75e2cffe1fa40cd0b17b6472be53d3da53f747`. Development happens on separate branches. Integration into `main` requires automated validation, user acceptance and a controlled pull request. No push or private testing build automatically publishes a public release.

## Start from current production

Read `AGENTS.md`, fetch `origin`, query the current remote `main` and start an isolated branch from it. Continuing branches must incorporate current approved `main` before delivering a testing package. Preserve existing worktrees and development/recovery branches. Never force-push, rewrite published history or delete development branches to solve integration problems.

`CUMULATIVE_BASELINE.json` retains the historical `integration/cumulative` recovery anchor and original cumulative commit `b31e30e92256a00dbb3b75347d77731b52a0f06f`, with four subsequent commits through `e61c16c1a136d3972b0af5b18821ceec1a2239f7`. That anchor remains an ancestry minimum; `productionBranch: main` additionally requires current production ancestry. The old integration branch is no longer the starting point for new work. Historical recovery details remain in `CUMULATIVE_INTEGRATION.md` and `CUMULATIVE_BRANCH_AUDIT.json`.

## Complete a checkpoint

1. Run the approved snapshot check and applicable validation. Runtime, generator, contract, build or workflow changes require the full integrated gate.
2. Commit intended changes and push the isolated branch. Verify the live GitHub branch points to the exact full HEAD, then read CI through completion.
3. Record branch, full SHA, validation commands/results and remaining client checks. Documentation-only follow-ups retain earlier full validation receipts without claiming a fresh full run.

`tools/release/source_integrity.py --remote-branch dev/YOUR_BRANCH --recovery-output /workspace/artifacts/recovery` checks clean committed files, live exact development HEAD, historical cumulative ancestry and current remote `main` ancestry. Tracking refs alone are insufficient. It refuses `main` as a development delivery branch. Credentials remain in child-process memory, never metadata, argv or logs.

## Private testing packages

Installable testing packages require owner authorization. Use `tools/release/build_test_package.py --remote-branch dev/YOUR_BRANCH --output /workspace/artifacts/UNIQUE_BUILD --lua51 /path/to/lua5.1 --luac51 /path/to/luac5.1`. Lua 5.4 and its compiler must also be on PATH. Use a distinct private TOC version and a new output directory outside the checkout.

The builder verifies clean committed GitHub source and both ancestry baselines, freezes committed packaging inputs, checks the cumulative feature contract and validates every extracted runtime module on Lua 5.1/5.4 using the full integrated gate. It rechecks source and remote identity before exposing final output. Keep BUILD_INFO.txt, PACKAGE_MANIFEST.json, SHA256SUMS, ZIP checksum and validation receipts together. Local candidates are not approved delivery packages. Do not bypass this gate for private testing.

Private testing ZIPs and Actions artifacts remain separate from public releases. Ordinary development/PR validation creates receipts only. The read-only `recommendation-validation.yml` allows private packaging only through explicit manual `build_testing_package=true` on a development branch, default false.

## Public releases

Follow [BETA_RELEASE_WORKFLOW.md](BETA_RELEASE_WORKFLOW.md). Public releases use distinct immutable version tags on integrated approved `main` and installation ZIPs with published SHA-256 checksums. The public packager requires the complete feature contract, all runtime textures, source-byte identity and the full extracted-runtime gate. The manual publisher requires an existing exact tag/draft and explicit commit/checksum inputs; publication defaults off. Do not overwrite existing assets or reuse Beta 10 for a later beta.

The source gate remains read-only. Trusted inspect/publish helpers have scoped release permissions and never execute release payloads. Historical security checks and immutable release packages remain available. Mainline code, dependency, contract and workflow changes must pass automated checks; user acceptance is required before promoting new gameplay. Automated tests do not establish real-client acceptance or current live acquisition facts.

## Recovery and reproducibility

On remote failure preserve local commits. The source validator can produce a verified Git bundle with SHA-256 outside the checkout; that bundle is emergency recovery, not a GitHub backup. Never describe a package as remotely protected until the exact commit is verified.

Packages sort members, fix timestamps/permissions and use DEFLATE level 9. Reproduce with the same Python/zlib and Lua versions; compression upgrades may change ZIP bytes. Keep all provenance and external validation receipts. Evidence fixtures, credentials, tools, tests, old archives and development logs are excluded from installation ZIPs.
