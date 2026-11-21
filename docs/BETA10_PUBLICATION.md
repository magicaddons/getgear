# Approved Beta 10 publication

Release source/tag: `efe67f9d9a75daf85545d9dda37b0c238d638010`, `v0.14.0-beta10`.
The owner approved public distribution of private cumulative `.20261121.12`.
All 29 Lua modules and three textures match accepted source
`f248b098a60beef89d8e3112dba19fa0b329905f`; release changes are metadata/docs only.

The source passed GitHub run `44877549287`. The extracted installation package
passed all 182 integrated checks, including 47 gameplay suites on each Lua
5.1/5.4, 81 build-tool tests and 20 release-tool tests. The approved 17-file
snapshot, normal directory structure, final startup and archive CRC passed.
No fresh in-game verification was performed.

Approved ZIP: `release-packages/GetGear-v0.14.0-beta10.zip`.
SHA-256: `38ddf7f3fe50086cfd3197a45ccac29e30152a4f3fc0289b52d005fd1df85421`.

Local GitHub authentication created draft `453506690` and the exact annotated
tag, but the uploads host returned HTTP 401 for both asset uploads. No assets
were uploaded and the draft was left unpublished. The existing Beta 9 packaging
workflow cannot represent Beta 10's star assets and manifest; it must not be
used to rebuild or replace these approved bytes.

The manual `publish-public-beta10.yml` workflow uses the existing fail-closed
release transaction with its scoped Actions token. Run once with `publish=false`
to check the pinned ZIP/source/feature contract and tag; then `publish=true` to
upload the same bytes, download-verify both assets and publish the existing draft.
Only the publishing job grants contents write. It never executes addon code,
creates a release/tag, changes the release source, or replaces an existing asset.
This maintenance change adds publication infrastructure only; the approved
runtime/tag/ZIP remain unchanged. The normal private testing-package gate is
unchanged.
