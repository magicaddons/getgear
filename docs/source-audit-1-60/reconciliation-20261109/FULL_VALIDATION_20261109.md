# Full non-release reconciliation validation — 9 November 2026

## Entry state and scope
Fresh `git ls-remote` confirmed required development HEAD `2dd4d453501aef7bf6d7fb9d3b831dff7dc245c5`. The environment initially checked out a clean local `work` branch at `cf7fa410f841cc19c84f4514e6b98ec435ff2ec4`. Preserved that branch as `preserved-work-beta7` to avoid the Git ref namespace collision, then checked out `work/full-acquisition-reconciliation-20261109`, configured its explicit fetch refspec and upstream, and verified clean state at the fresh remote HEAD. Read AGENTS.md, durable progress, overnight plan, release gate, generated README and latest completed non-release CI 42493307958. No research batch or handwritten addon changes.

## Local result: PASS
- Python compilation: `python3 -m py_compile tools/reconcile_acquisition_1_60.py`, exit 0.
- Full online reconciliation: `python3 tools/reconcile_acquisition_1_60.py`, exit 0; provenance timestamp `2026-11-09T01:46:51.631776+00:00` (12:16 Adelaide).
- Three workflow-required generated files exist and are nonempty.
- Lua 5.4.7 available at `/workspace/.getgear-tools/lua/usr/bin`; `luac5.4 -p` passed all 24 GetGear.toc modules.
- All 14 workflow regressions passed **after regeneration**: beta4-catalogue, beta4-filters, beta4-talents, beta4-performance, beta7-evidence, beta7-material-names, beta7-coverage, beta7-source-visibility, beta7-armor-priority, beta7-preview-layout, beta7-stat-flags, overlay-stat-filter, overlay-green-boe-filter, beta7-acquisition-reconciled (all under tests/, .lua).
- Catalogue 7,707 identities, 36,341 class objectives, nine classes; 1,252 indexed recipes retained, 1,253 runtime crafts / 4,855 ingredients named. Performance: 45 class/level checks, zero bulk item-cache requests. Recipe inputs, eligibility, settings, filters, generator and handwritten addon modules have no diff.
- Generated CSV row-by-row review retained IDs, names, levels, original routes/evidence, roles and recipe materials status. `git -c core.whitespace=cr-at-eol diff --check` passed; plain diff-check flags the existing Python CSV writer's CRLF endings, not content whitespace changes.

## Access rechecked with the generator User-Agent
`GetGear-Open-Source-Acquisition-Audit/1.0 (github.com/magicaddons/getgear)` returned HTTP 200 for all four probes:
- https://playfulls.com/database — 140,468 bytes, SHA256 a732e5637241d32346c87fad43beb40ecf3eb83c1a8f4937911ada2289b52e7f.
- https://www.wowforeverfriends.org/items/items.json — 16,908,600 bytes, SHA256 e0a86115fc289b5c9914b6212e0b178f3e2e1777429c08eaaf4b586277c01fba.
- https://www.wowforeverfriends.org/library/data/npcs.json — 6,121,482 bytes, SHA256 5c5a4524a3ad6a25c20902291d244baf32bb5f6b33c65c35847c7f5e1dcfb5f1.
- https://everloot.app/api/edges?evidence=observed&limit=500 — 103,303 bytes. Live API response metadata can change between probe and generation; permanent generation hashes are in provenance.json.
Full generator also fetched Playfulls shards, Forever cache, client encounters and all three Everloot pages successfully. Everloot pagination reports complete, 1,119 raw edges / 955 qualifying item relationships; Playfulls 23,041 items; Forever cache 10,315.

## Generated change review
Only AcquisitionEvidenceIndex.lua and ten generated reports changed. Most CSV churn is upstream sourceRow offsets. No row-count or identity changes; 1,077 summaries and all dungeon roles unchanged (552 equipment, 24 patterns, 1 misclassified craft; 577 historical records).
- 10410 **Leggings of the Fang** → Lord Cobrahn NPC 3669: Everloot 3 installations, lastSeen 2026-11-08T20:29:36Z, corroborating Playfulls Wailing Caverns boss listing.
- 10411 **Footpads of the Fang** → Lord Serpentis NPC 3673: 4 installations, lastSeen 2026-11-08T20:57:45Z, same dungeon corroboration. These two qualify as recorded observations under the unchanged generator rule, not promotion from publication alone. Observation-labelled dungeon records increase 13 → 15; this is not a guaranteed current drop rate or this session's own live test.
- Nine IDs switch cache-only reference to community reference, retaining live-unverified caveats: 10807, 10838, 11632, 11746, 11748, 11764, 11817, 22240, 22241. Two use the upstream zone alias Sunken Temple.
- Craft 252503 **Wisdom’s Leather Pants**, book 252797, spell 1255110: new Everloot book dropped_by NPC 5775 **Verdan the Everliving**, 4 installations, lastSeen 2026-11-08T20:59:54Z. Candidate method changes unresolved → drop; trainer-reference-with-pattern-item classification and requiresLiveCheck=True remain. No finished-item boss-drop assertion and no ingredient change.
- Six unresolved dungeon IDs remain 10801, 11945, 11946, 14525, 23173, 273044. All 954 recipe routes remain queued (68 vendor / 886 trainer-labelled). Published vendor references still do not establish live stock, trainer teaching or book-specific purchase gates.
- Regression negative cases retain Goblin Mail Leggings 1943 caveat, Blackwater Cutlass 1951 reviewed source, Guard’s Chain Shirt 250489 dropped book 251341, crafted Idol 220606 / formula 249529, prior Blighted Leggings 7709 observation and source precedence. Armour-only default-off opt-in, positive-stat safety, green BoE default-hidden filter, settings migration, tracked/all materials and full guide checks passed.

## GitHub result
**PASS:** [non-release workflow 42547493799](https://github.com/magicaddons/getgear/actions/runs/42547493799), dispatched on validation commit `458292015cd3e3720efde22502fbaa1c7a0468de`, completed successfully at 2026-11-09T01:49:11Z (12:19 Adelaide). Reconciliation, required-file checks, complete manifest Lua syntax, all 14 regressions, report artifact upload and development-only report commit steps succeeded.

Verified and fast-forwarded bot final commit `50db73df97eedead6af702f183690785775ec392`, direct child of the dispatched commit. Its entire diff is provenance.json only: three Everloot HTTP response hashes and generation timestamp; no evidence rows, index, confidence or addon changes. Local generated evidence matches CI apart from that request metadata. Final documentation closeout follows this bot commit and does not change validated code/data; its commit SHA is available from the development branch history.

CLI log download hit a Forbidden response at the Actions results-receiver host; GitHub connector job-log retrieval succeeded, so full test output was inspected through that fallback. This was not a validation blocker. No failed or pending validation run remains.

No ZIP, packaging/build, tag, release, merge, release workflow or main modification. Offline tests do not verify live client layout/item cache, current vendor stock, trainer inventories, spawn availability or drop probabilities. In-game acceptance and release approval remain outstanding.
