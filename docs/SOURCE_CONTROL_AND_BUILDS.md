# Durable cumulative source and testing builds

The authoritative cumulative development baseline is the **current GitHub head**
of [`integration/cumulative`](https://github.com/magicaddons/getgear/tree/integration/cumulative).
It was established at recovered `e61c16c1a136d3972b0af5b18821ceec1a2239f7`.
`main` contains an older runtime and is not a substitute cumulative baseline.
The safeguards implementation lives on a separate infrastructure branch; it is
not automatically merged into the canonical branch.

`CUMULATIVE_BASELINE.json` records the original cumulative commit
`b31e30e92256a00dbb3b75347d77731b52a0f06f` and its four direct subsequent commits:

| Commit | Accepted integration correction |
| --- | --- |
| `b40a8f6be675354b798d7101d1f78e94c8a458a9` | Shared marker scaling and acquisition navigation audit |
| `704146309aed8bdd477ecfe72dccd17bd4569a06` | Raw navigation evidence and catalogue coverage guards |
| `0c198ef5e622cc438f696cd78c36d8f0892862fd` | First-open native map readiness |
| `e61c16c1a136d3972b0af5b18821ceec1a2239f7` | Existing instance aliases for source destinations |

The recovered head is exactly four commits ahead of the original cumulative
commit. Both the canonical baseline and this infrastructure implementation
preserve that complete history. The recovery branch remains intact.

## Starting and completing development

Read the current `AGENTS.md` first. Fetch the current canonical branch, query its
live SHA and check ancestry before selecting a starting revision:

```sh
git fetch origin integration/cumulative
git ls-remote --exit-code origin refs/heads/integration/cumulative
git log -5 --oneline FETCH_HEAD
git merge-base --is-ancestor e61c16c1a136d3972b0af5b18821ceec1a2239f7 FETCH_HEAD
git switch -c dev/your-task FETCH_HEAD
```

Choose a unique isolated development branch. Retain the current canonical SHA
in the task's validation record. For continuing branches, ensure the current
remote canonical head is an ancestor of HEAD. If the baseline has advanced,
review and integrate it on the development branch before building. Moving the
canonical branch itself requires owner authorization for reviewed, accepted
work; this task does not merge the infrastructure branch into it.

A completed checkpoint means tests pass, intended changes are committed, the
development branch is pushed and its **exact** full HEAD is verified on GitHub.
For example, after applicable validation and committing:

```sh
git push origin HEAD:refs/heads/dev/your-task
python3 tools/release/source_integrity.py \
  --remote-branch dev/your-task \
  --recovery-output /workspace/artifacts/your-task-recovery
```

The validator checks the origin identifies `magicaddons/getgear` on GitHub,
queries real branch heads, fetches current canonical objects and validates
ancestry. Local tracking refs, a successful prior push and a branch containing
HEAD somewhere in its history are insufficient: the designated branch must
point to exactly HEAD. Credentials are used only in child-process memory and
are never written into build metadata or argv. In CI, the only repository token
permission is `contents: read`; checkout does not persist credentials.

Record the branch URL, full SHA, commands/results, CI run and actual-client
limitations in the handover. Documentation receipts may refer to the parent
implementation SHA; record the final receipt SHA outside its own contents.

## Building a future authorized testing package

**This infrastructure task creates no new gameplay testing ZIP.** The commands
below are for future owner-authorized testing work. Push and verify first:

```sh
python3 tools/release/build_test_package.py \
  --remote-branch dev/your-task \
  --output /workspace/artifacts/unique-testing-build \
  --lua51 /path/to/lua5.1 --luac51 /path/to/luac5.1
```

Python 3.12+, Lua 5.1 and Lua 5.4 are required; `lua5.4` and `luac5.4` must be on
PATH. The output directory must not exist and must be outside the checkout.
Retain a distinct private TOC version for each newly authorized gameplay build.
The filename includes the version and full commit SHA, preventing a later source
revision with an old version label from silently replacing an existing build.

The mandatory gate:

1. Rejects dirty/untracked source, missing HEAD, wrong origins, unpushed commits,
   inaccessible remotes and remote-head mismatches. It hashes **every tracked
   file** against the commit, catching edits hidden by assume-unchanged flags.
2. Requires the current remote canonical baseline and every recovered accepted
   commit in HEAD's ancestry. There is no authentication/offline bypass.
3. Exports all source, tools, contracts, tests and evidence fixtures from Git's
   committed objects into a frozen temporary source directory. Ignored/local
   files cannot become packaging or validation inputs.
4. Validates the cumulative feature contract, creates a private staged candidate,
   extracts it and runs the complete existing functional gate against those
   extracted runtime modules on Lua 5.1 and 5.4. Evidence fixtures stay outside
   the installable addon. A failing candidate never becomes a final delivery.
5. Checks source/fixture/extracted-runtime drift, writes deterministic metadata,
   verifies every member against committed source, checks checksums and repeats
   GitHub/HEAD validation immediately before promoting the output directory.

The final ZIP contains `BUILD_INFO.txt`, `PACKAGE_MANIFEST.json` and `SHA256SUMS`.
The manifest records full commit/tree SHAs, development branch, current canonical
baseline, build/version identifier, ordered runtime module inventory, per-file
SHA-256/size, feature acceptance and stable extracted-regression results.
`SHA256SUMS` covers all other ZIP members including the manifest and BUILD_INFO;
it excludes itself. The whole-ZIP SHA-256 is a sibling `.zip.sha256` file, avoiding
a self-referential checksum. A sibling manifest adds ZIP filename/size/checksum,
and `validation/` retains full commands, logs, timing, summaries and audit output.
Keep this complete delivery directory together.

ZIP ordering, timestamps, permissions, JSON ordering and internal results are
deterministic. Timings and temporary paths live only in external receipts. Unit
tests build the same **synthetic mini-addon** twice and require byte-identical
ZIPs. For reproducibility use the same Python/zlib and interpreter versions;
compression libraries can differ across environments. The CI workflow pins and
checksums its Lua packages. No new GetGear gameplay ZIP was produced to test this
infrastructure.

Local candidates can be used for diagnosis but are unapproved and must never be
presented as verified cumulative packages. There is intentionally no flag to
promote them without the full gate. Historical public releases and their
byte-pinned packaging path remain unchanged; they do not authorize or replace
the private testing gate.

## GitHub Actions

`recommendation-validation.yml` validates all development branches (`**` except
`main`) and pull requests without path filters that could omit new dependencies.
It runs the frozen acquisition-snapshot check, full integrated gate and (for
non-PR development refs) live exact-source verification. PR validation exercises
the merge candidate; GitHub provenance is checked on real branch HEADs, not on
GitHub's synthetic merge ref.

Normal pushes and PRs upload validation receipts only. A future explicit manual
`workflow_dispatch` with `build_testing_package=true` on a development branch
runs the same gated builder and uploads the complete verified directory as an
Actions artifact, retained for 30 days. The default is false. No GitHub Release,
tag, merge or source write is involved. The optional package dispatch was not
run for this task. In repositories where GitHub exposes manual dispatch only
for workflows on the default branch, that UI option becomes available after a
separately owner-approved integration; meanwhile the local gated CLI works.

## Push and remote failures

Preserve the local commit; do not reset it to make verification pass. If a push
fails, run the source validator above: a remote-verification failure attempts a
full-history Git bundle and SHA-256 in the recovery directory. The builder does
the same on remote failure and exposes no approved delivery. If the bundle also
fails, report that separately. Do not force-push, rewrite or delete a recovery
branch. A local bundle is emergency recovery, not safe remote publication.

Verify or restore a bundle with:

```sh
sha256sum --check GetGear-recovery-FULL_SHA.bundle.sha256
git bundle verify GetGear-recovery-FULL_SHA.bundle
git clone GetGear-recovery-FULL_SHA.bundle recovered-getgear
```

Uncommitted edits are not in a bundle: commit intended work first. The automated
recovery test clones a bundle and verifies that its HEAD includes the unpushed
checkpoint. Report push/verification failures explicitly and do not describe a
testing package as safely published or backed up until GitHub is verified.
