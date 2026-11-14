# Manual beta release publishing

Workflow: **Publish verified GetGear beta**, `.github/workflows/publish-beta.yml`.
Merge the infrastructure-only maintenance PR into `main`. Do not merge the
acquisition development branch or move any release tag. Dispatch from **main**;
other workflow refs are deliberately skipped. No push event publishes a release.

## Beta 9 is blocked until its original ZIP is recovered

The existing unpublished draft is **445097507**, tag `v0.14.0-beta9`, source
`04992876bd4f50b66d6b6dd78d00b32cd0594cd3`. Never recreate it. Its only accepted
ZIP is `GetGear-v0.14.0-beta9.zip` (2,023,756 bytes), SHA-256:

```
c78667f180a103f1f6392c0275f052b16d4432a6d830a3495bbab412ef386a15
```

The original `/workspace/release-artifacts/getgear-beta9/` directory was missing
in the infrastructure environment. The development branch's
`docs/BETA9_RELEASE_HANDOVER.md` records `BUILD_RECIPE.py` there, but neither that
recipe nor the ZIP is in Git. Its durable manifest was copied to
`tools/release/beta9-manifest.json` from development commit
`0958954a542380173e4382e66bfd950738415162` solely as release verification evidence.
This infrastructure does **not** claim to have reproduced Beta 9's ZIP bytes.

Recover the original package separately. Verify the hash above, then add the
exact ZIP as `release-packages/GetGear-v0.14.0-beta9.zip` on `main` through a
separate reviewed PR. This gives the runner access to immutable, reviewed bytes
without a new upload credential or dependency on a local workspace. A rebuild is
acceptable only after its complete archive hash is proven identical; matching
individual source files is insufficient. Do not approve a replacement hash.
The workflow will stop before any release mutation if the package is absent or
incorrect. It checks all historical member hashes and source-backed bytes, not
just the outer ZIP hash.

## Run after merging (and recovering the Beta 9 ZIP)

1. Open **Actions → Publish verified GetGear beta → Run workflow**.
2. Select branch **main** and enter:
   - `tag`: `v0.14.0-beta9`
   - `expected_commit`: `04992876bd4f50b66d6b6dd78d00b32cd0594cd3`
   - `expected_sha256`: the hash above
   - Leave **publish unchecked** for the first run.
3. Inspect build/regression logs and the `verified-beta-package` run artifact.
   A successful dry run reads draft/assets but uploads nothing to the release.
4. Only when ready to publish, dispatch again with the same inputs and **publish
   checked**. This is explicit authorization to upload both assets and publish.
5. The publishing job downloads both assets back through GitHub's asset API and
   compares their complete bytes before setting `draft=false`, `prerelease=true`,
   `make_latest=false`. The job log and run summary report the public URL, expected
   to be `https://github.com/magicaddons/getgear/releases/tag/v0.14.0-beta9`.

Equivalent commands (operator's own GitHub authentication; **no PAT required by
this workflow**):

```sh
gh workflow run publish-beta.yml --repo magicaddons/getgear --ref main \
  -f tag=v0.14.0-beta9 \
  -f expected_commit=04992876bd4f50b66d6b6dd78d00b32cd0594cd3 \
  -f expected_sha256=c78667f180a103f1f6392c0275f052b16d4432a6d830a3495bbab412ef386a15 \
  -f publish=false
```

Use `publish=true` only for the explicit publishing run. Preparing this PR does
not dispatch the workflow, upload assets, or change any release.

## Future betas

Create an existing beta tag `vX.Y.Z-betaN` and a **single draft** whose
`target_commitish` is the full tagged source SHA. Prepare/review release notes
in that draft. For example, an operator may use `gh release create TAG --draft
--prerelease --verify-tag --target FULL_SHA --notes-file NOTES` after verifying
that no release already exists. The workflow itself never creates tags/releases.

Use a dry run with the intended tag/commit and a provisional 64-character
lowercase checksum to discover the deterministic build hash in the log (that run
will fail on a mismatch without uploading). Review the package/source and approve
the actual hash, then dry-run again with that hash before explicitly publishing.
Future packaging sorts member names, fixes timestamps/permissions, uses DEFLATE
level 9 and records the exact source SHA. Python/zlib upgrades can alter compressed
bytes; always review/check the hash rather than assuming toolchain equivalence.
The TOC version must match the tag; layout changes require reviewed infrastructure
updates. All TOC Lua modules, GetGear.toc, MapPin.tga, README.txt, optional
DATA_MODEL.md and generated BUILD_INFO.txt are packaged. Tests/docs/git files are
excluded. Lua 5.1/5.4 syntax and all tagged Lua regressions run against the extracted
modules (the Lua 5.1 shim adapts the **test runner** load API only); source Python
generator regressions also run offline. Evidence fixtures are linked only into
the temporary test directory, never the installable archive.

## Settings and safety

- Enable GitHub Actions and allow the pinned official `actions/checkout`,
  `actions/upload-artifact` and `actions/download-artifact` actions, with access to
  Ubuntu package mirrors. No new repository secrets, PATs or external services.
- Keep the default workflow token read-only. The workflow starts with no
  permissions; build/inspect request only `contents: read`. Only the explicit
  publishing job requests `contents: write` using built-in `github.token`.
  Organization policies must permit this job-level grant. Do not enable PR write
  access, bypass branch protections or grant workflow-wide write access.
- Protect/review changes to `main`, workflows and `tools/release/`; only trusted
  maintainers should dispatch. Published source code/tests execute only in the
  read-only build job, without persisted checkout credentials or a token in
  their environment. The write job checks out only the trusted infrastructure.
- All runs of this workflow share a concurrency group with cancellation disabled.
  GitHub can replace an older pending run if several are queued. Avoid manual
  draft/tag changes or other publishers during a run; Actions concurrency cannot
  lock external actors or historical workflows. Historical publishers are left
  unchanged; do not dispatch them for new betas.
- Published releases, wrong commits, duplicate drafts, unexpected asset names,
  incomplete uploads and differing existing bytes abort. No delete, clobber,
  force-push or tag mutation is implemented. A partial upload failure leaves a
  draft; rerun reuses only byte-identical verified assets and never overwrites.
  Unknown/incomplete assets require manual investigation; the helper does not
  delete them. A dry run detects these conflicts without changing them.
- Checks finish before publication. If GitHub returns an ambiguous network error
  during the final publish request, inspect the existing release before retrying;
  publishing is a single API operation, not a rollback transaction.

## Local validation

```
python3 -m unittest discover -s tests/release -v
actionlint .github/workflows/publish-beta.yml
```

The safety tests use a fake GitHub client: successful publication/resume, disabled
publication, wrong local hashes, moved tags, already-public releases, duplicate
releases, wrong target, unknown assets, differing downloads and failed uploads.
The archive tests also cover deterministic future builds and unsafe member rejection.
No test performs a live release mutation. Beta 9's missing-original rejection
was also exercised locally. The tagged gameplay was checked with a separately
labelled test ZIP; that fixture is not an accepted Beta 9 release artifact.

Local results: actionlint 1.7.7 passed; 11 offline safety tests passed. A real
synthetic future-beta source built identically twice and passed both Lua runtimes.
Beta 9 source fixtures passed 52 syntax checks, 38 Lua regressions and four Python
generator tests. Exact accepted Beta 9 archive validation remains blocked by the
missing original bytes; no live upload/publication test was performed.
