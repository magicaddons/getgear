# Beta 11 approved-source promotion

Accepted cumulative source: `fix/alliance-acquisition-20261121`, exact HEAD
`5b75e2cffe1fa40cd0b17b6472be53d3da53f747`. The owner's release request confirms
in-game acceptance and authorizes promotion, integration PR/merge, tag and public
Beta 11 publication. This release introduces no gameplay changes.

## Integration review

Live `main` before integration was
`10899e5d4d15c4bcb5542518d27c5ab62c7c9a07`. The common ancestor was
`4ba2a850c4e3933b85f40c82a50b98314f117d80`; main had three unique commits and
the accepted development source had 623. Those three main commits add the
byte-pinned Beta 10 package/publisher and public download documentation. The
accepted branch contains the complete cumulative runtime, evidence, tests and
tools. Most added files are historical acquisition/reconciliation evidence.

The controlled release branch merges the exact accepted source with main's
release infrastructure. Only README.md conflicted; it is deliberately resolved
as current public Beta 11 documentation with Alliance-only support. No Lua merge
conflicts or automatic runtime combinations occur. Every one of the 29 Lua
modules and all three textures is independently byte-compared to the accepted
commit. All 17 protected acquisition snapshot files retain their recorded hashes.
Every existing main file is retained, including both immutable release ZIPs,
security checks, release helpers and useful documentation.

Release metadata sets TOC version `0.14.0-beta11` and removes the private-test
header. Remaining TOC metadata and ordered load inventory are unchanged.
Public READMEs/release notes point to Beta 11 and explain installation, usage,
Alliance scope, feedback, beta limitations and actual licensing permissions.
The Beta 10 wording that implied supported Horde gameplay is corrected; its
published ZIP bytes are preserved.

## Continuing workflow and packaging

Main is the latest user-approved production source. Development branches must
contain current main as well as the historical recovery anchor. A real disposable
Git-history regression confirms an old development branch is rejected after
production advances. No existing development/recovery branch is deleted or
rewritten. Future promotion requires validation, user acceptance and a PR.

The public packager now includes both required star textures and runs the full
existing integrated gate against extracted payloads. A missing-texture regression
protects installation completeness. Deterministic ZIP construction, source
attribution, version/hash gates and immutable Beta 9 handling remain intact.
All public publishers are manual-only, including retained historical workflows;
a regression prevents push/PR-triggered publication. The generic publisher keeps
its existing read-only build and isolated draft inspection/publication boundaries,
and rejects a tagged source outside approved main history.
Private builds retain their separate authenticated, cumulative testing gate.

## Verification record

Full validation commands and results are recorded with release delivery receipts:

```sh
python3 tools/reconcile_presentation_snapshot.py --verify-only
python3 tools/validate_recommendations.py --output OUTSIDE_CHECKOUT \
  --lua51 /path/to/lua5.1 --luac51 /path/to/luac5.1
python3 tools/release/package.py SOURCE OUTPUT TAG FULL_SOURCE_SHA ZIP_SHA256 ORIGINAL
```

The gate covers all gameplay Lua regressions on Lua 5.1/5.4, syntax, feature/build
and release safeguards, source generators, catalogue/source/faction alternatives,
Ragefire Chasm exclusion, saved stars, slot/tracking/stat behaviour, overlay
layout/performance, inventory/materials and map navigation. The public packager
repeats that gate against extracted installation bytes and checks every member
against committed source. Release automation independently rebuilds and checks
the approved ZIP SHA-256 before publication.

The integration audit checks credential patterns and unsafe development files;
only the three known textures and two retained historical ZIPs are binary files.
Installation archives use an explicit member allowlist and contain no research,
logs, tests, tools, credentials or previous release packages. Existing security
workflows are preserved. Pattern scanning is not an exhaustive security audit.

No fresh WoW client session is claimed. The owner's acceptance applies to the
approved cumulative build; automated mocks and Lua checks do not establish live
loot/source facts. GitHub prereleases cannot receive the stable “Latest” badge;
Beta 11 is the latest recommended public beta through README/direct release links.

Completed pre-merge source validation: **185 checks passed, 0 failures**;
29 modules, 48 gameplay suites on each Lua 5.1/5.4, 82 build-tool unit cases
and 22 release-tool unit cases. All 17 protected acquisition snapshot files
remain exact. Actionlint 1.7.7 passed all workflow files. The release-specific
diff has no whitespace errors; inherited historical CSV line endings and
archived formatting are preserved without rewriting accepted evidence.
