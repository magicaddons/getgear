# Cumulative source integrity implementation

Development branch: `infra/cumulative-source-integrity-20261118`.
Canonical baseline created and verified on GitHub:
`integration/cumulative` at `e61c16c1a136d3972b0af5b18821ceec1a2239f7`.
The original cumulative commit and all four later integration commits are
preserved as a direct ancestry chain. The existing recovery branch is untouched.

The infrastructure branch adds a live GitHub provenance gate to private testing
builds, frozen committed inputs, complete internal metadata and checksums,
fail-closed recovery, future-branch CI coverage and an optional manual testing
artifact path. `AGENTS.md` now contains the active policy; its complete previous
bytes are preserved as explicitly historical instructions.

The full local gate passes 145 commands: 29 runtime modules, 32 gameplay suites
on each of Lua 5.1/5.4, 40 build safeguard unit tests, 20 release unit tests and
existing catalogue/navigation/source audits. The 17-file acquisition snapshot
remains exact. `actionlint` 1.7.7 and whitespace checks pass. Tests use disposable
Git histories/bare transport fixtures and synthetic mini-addon archives. No new
GetGear gameplay testing ZIP is produced, and no actual-client acceptance is
claimed. See `validation.json` and the source commit's GitHub Actions receipts
for validation provenance; the final handover records the exact remote head.

Deliberate failures cover unpushed local commits, a remote branch ahead of HEAD,
dirty/untracked/assume-unchanged inputs, missing modules, stale runtime bytes,
missing/inconsistent provenance metadata, inaccessible/wrong remotes, obsolete
canonical ancestry, regression failures, source drift during validation and
remote failure both before and after validation. Successful cases verify pushed
source, ordered metadata/inventory/checksums, byte-identical repeat synthetic
builds and recovery of an unpushed commit by cloning its emergency Git bundle.

Changed files:

- `AGENTS.md`: active permanent policy, permitted development pushes and boundaries.
- `README.md`: discoverable canonical-baseline and mandatory-build-gate links.
- `.gitignore`: Python caches cannot dirty a completed source checkpoint.
- `CUMULATIVE_BASELINE.json`: canonical/recovery/original and four accepted commits.
- `.github/workflows/recommendation-validation.yml`: all future development branches,
  read-only exact-source verification and opt-in private Actions artifacts.
- `tools/release/source_integrity.py`: GitHub, ancestry, complete source hashing,
  emergency bundle and checksum checks.
- `tools/release/build_test_package.py`: frozen inputs, extracted-runtime validation,
  repeated provenance gate and atomic final delivery.
- `tools/release/test_package_metadata.py`: deterministic metadata, inventories and hashes.
- `tools/validate_feature_acceptance.py`: recognize the new metadata members while
  preserving historical functional/archive validation.
- `tests/build/test_source_integrity.py`: real disposable Git histories and recovery cases.
- `tests/build/test_testing_package.py`: synthetic package, metadata and failure cases.
- `tests/build/test_validation_workflow.py`: CI coverage, permissions and manual-package boundary.
- `docs/SOURCE_CONTROL_AND_BUILDS.md`: complete start/checkpoint/build/recovery procedure.
- `docs/CUMULATIVE_INTEGRATION.md`: point historical recovery notes to current authority.
- `docs/history/AGENTS-before-source-integrity.md`: byte-exact historical policy archive.
- `docs/source-integrity/IMPLEMENTATION.md` and `validation.json`: implementation receipt.

The current canonical branch remains the accepted recovered baseline; these
infrastructure changes are on the separate development branch for review.
Adopting them onto another branch requires the owner's normal review/integration
process. This task changes no gameplay Lua, TOC version, accepted catalogue data,
`main`, tags, release assets or existing testing packages. The optional manual
package dispatch is implemented but deliberately not invoked here.
