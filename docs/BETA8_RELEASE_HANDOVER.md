# Beta 8 release handover — research paused, publication blocked

The user explicitly asked to pause research and consolidate/publish the next version. **Do not resume research.** Packaging/tag/prerelease authorisation remains valid; no merge/main change authorised.

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

## Exact publication blocker

`gh release create` reached GitHub metadata creation but asset upload returned **HTTP403** at `uploads.github.com`. An initial incomplete create was cleaned up by gh. A retained **draft** now exists: release ID **439010698**, tag_name `v0.14.0-beta8`, **assets empty**. Draft URL: https://github.com/magicaddons/getgear/releases/tag/untagged-8f551a13a9bcb4bf7902 . **No public Beta 8 release or downloadable GitHub asset exists yet.** The source tag does exist.

Current managed environment observations are current; network policy is restricted/enforced. Its effective host list includes github.com/api.github.com and asset-download hosts but **does not include uploads.github.com**. Repository API access, tag push and draft creation work. No evidence requires rotating credentials. The cloud environment-change tool is unavailable in this chat. User has been asked to add `uploads.github.com` to allowed domains in environment settings and apply. Do not disable proxy/TLS, change endpoints to bypass policy or expose secret values.

## Resume publishing after the setting is applied

1. Refresh managed environment status; confirm current observations and enforced policy include `uploads.github.com`. Keep inherited proxy/trust settings.
2. Confirm exact tag target remains `543e5a248a018f8a9144e64aca655d242cf274e0`, and inspect retained draft ID/tag/assets. Do not force/replace tag or overwrite an existing public release.
3. Verify local prepared ZIP/checksum against the above digest. Upload ZIP and checksum **to the existing draft** with normal `gh release upload v0.14.0-beta8 ... --repo magicaddons/getgear`; if a prior attempt partially uploaded, inspect/download/compare before deciding how to complete it.
4. Download draft assets if supported and byte-compare, then publish the authorised prerelease with `gh release edit v0.14.0-beta8 --repo magicaddons/getgear --draft=false --prerelease --latest=false`.
5. Verify public prerelease metadata, actual tag commit, both uploaded assets, downloaded ZIP/checksum bytes, archive CRC/manifest and SHA256. Record publication URL/time and final branch handover commit. Keep main unchanged. Never report a public release until this succeeds.

Research stays paused. Further live UI/item-cache/vendor/quest/source acceptance remains incomplete, documented in release notes; this version is a beta, not a stable release or release candidate.
