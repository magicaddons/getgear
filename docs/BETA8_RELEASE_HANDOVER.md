# Beta 8 release handover — published; research paused

## Beta 8 published and independently verified — 9 November 2026

The user manually published the existing release. **Publication complete:** [GetGear v0.14.0-beta8](https://github.com/magicaddons/getgear/releases/tag/v0.14.0-beta8), release ID **439010698**, published `2026-11-09T11:12:24Z` (21:42:24 Adelaide). Verification completed `2026-11-09T11:15:02Z` (21:45:02 Adelaide).

- GitHub API: `draft=false`, `prerelease=true`, exact tag `v0.14.0-beta8`. Public release page shows Pre-release and no Latest badge; `GET /repos/magicaddons/getgear/releases/latest` returns HTTP 404, confirming Beta 8 is not designated latest. The release API does not expose a stored `make_latest` field; no release metadata was changed during verification.
- Remote annotated tag still resolves to `543e5a248a018f8a9144e64aca655d242cf274e0` (tag object `0a088935f66d7a683f4db32a448157e15b5e6f39`).
- Downloaded both published assets using `gh release download`: ZIP asset **727191556**, 519,620 bytes; checksum asset **727191517**, 92 bytes. Both actual byte lengths and SHA-256 hashes match GitHub asset metadata.
- ZIP SHA-256: `f8435b632cede83dd79ddded6348a7e2f9995da08fe13e4f859466a10a97a732`. Downloaded ZIP is byte-for-byte identical to the original user-supplied validated ZIP.
- Checksum-file SHA-256: `9768a0046ccd0ea6b1fbaffd5d8f3e2f61d6e01c50437970eaf4b5dc9e7667bc`. Exact content: expected ZIP digest, two spaces, `GetGear-v0.14.0-beta8.zip`, newline. It matches the locally created checksum bytes.
- ZIP CRC passes; exact 29-file membership and every member SHA-256 match the [recorded package manifest](source-audit-1-60/reconciliation-20261109/beta8_package_verification.json). All 28 repository-backed archive files also match the tagged source bytes; `BUILD_INFO.txt` matches its recorded manifest hash. No files were extracted into or changed in the addon.

Latest full code validation remains [non-release CI 42602679107](https://github.com/magicaddons/getgear/actions/runs/42602679107): PASS, 14/14 regressions and 24 Lua modules, inspected bot commit `a907d939aea29fa9683a740514c4a8171b1318e3`. This closeout performed targeted download/metadata/package/documentation checks only; no new full CI, build, regeneration, upload, publication or research was performed.

Documentation closeout starts from development HEAD `a70b80614dfc486959b17d8c0265f1a3bf237ee4`; the resulting documentation commit is recorded by Git history on `work/full-acquisition-reconciliation-20261109`. Main remains `cf7fa410f841cc19c84f4514e6b98ec435ff2ec4`. **Research remains paused.** Current live-source and in-client acceptance limitations remain open; publication is not live verification.

## Validated and ready

- Version/tag: `v0.14.0-beta8` (annotated tag already pushed).
- Exact tag/package source: `543e5a248a018f8a9144e64aca655d242cf274e0`.
- Code validated in CI / inspected bot commit: `a907d939aea29fa9683a740514c4a8171b1318e3`.
- [Full non-release CI 42602679107](https://github.com/magicaddons/getgear/actions/runs/42602679107): all steps passed, 14/14 regressions, 24 Lua modules, compilation/full source reconciliation and required generated files. Local results also 14/14. The later source commit changes only documentation/support text; every packaged Lua module and TOC byte matches validated CI.
- 2,177 source summaries; 954 recipe-book and 214 other equipment reviewed cases. Unknown origins, unavailable-page flags and cross-version caveats retained; not all live sources verified.
- ZIP `GetGear-v0.14.0-beta8.zip`: 519,620 bytes, 24 Lua modules +five support files =29 exact files. CRC, safe paths/types, committed bytes, version and source attribution checked.
- SHA256: `f8435b632cede83dd79ddded6348a7e2f9995da08fe13e4f859466a10a97a732`.
- Permanent [package/manifest proof](source-audit-1-60/reconciliation-20261109/beta8_package_verification.json), [local results](source-audit-1-60/reconciliation-20261109/beta8_local_validation.txt), [GitHub results](source-audit-1-60/reconciliation-20261109/beta8_github_validation.txt).
- Prepared workspace artifacts: `/workspace/release-artifacts/getgear-beta8/` (ZIP, checksum, publication notes and proof). Original staging: `/tmp/getgear-beta8-release/`. These filesystem locations may not survive replacement of the environment; the tag is the authoritative immutable source. Do not rebuild from a later documentation-only branch HEAD and mislabel it as the existing tag's package.


## Historical upload blockers — resolved by manual publication

The original automated upload was denied while uploads.github.com was absent from network policy. After the applied policy allowed that host, the retry returned HTTP 401 and left the draft empty. The user subsequently uploaded both assets and published the same release through GitHub. These are historical failures, not current publication blockers. Do not upload or publish again.
