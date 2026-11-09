# GetGear unattended research continuation

## Current authority and protected baseline

User resumed research on 9 November 2026 after published Beta 8 verification. Branch `work/full-acquisition-reconciliation-20261109`, recovered remote HEAD `f6c7b1986fec1840bd88b0320f5f071b55e1e679`. Main stays `cf7fa410f841cc19c84f4514e6b98ec435ff2ec4`. Beta 8/tag source remains `543e5a248a018f8a9144e64aca655d242cf274e0`; do not overwrite/republish it or build/package/publish any new release. Historical pause/upload instructions are superseded.

## Scheduling and usage

One enabled automation, **Continue GetGear research**, is attached to this existing chat, every two hours (`RRULE:FREQ=HOURLY;INTERVAL=2`), personal timezone Australia/Adelaide. Created successfully 2026-11-09T12:11:18Z. Automation reference for future pause at completion: `Automation_7353739dfe2c81918900f688ab8984b8`; source thread `01a1c037-5b56-765b-9263-070c54db609e`. Never create another continuation. Returned environment selection is inherited; concrete inherited environments and next-run time were null, so future provisioning/execution is not independently verified.

Tools expose no included-usage balance, weekly exhaustion indicator or allowance-refresh control. Scheduling does not guarantee execution through usage exhaustion or an exact refresh time. Preserve durable checkpoints on every completed batch, let later scheduled runs attempt continuation if permitted, pause on reported weekly exhaustion, and never purchase credits, redeem resets or alter subscriptions. On full offline research/validation completion pause this automation and report remaining live/client exceptions.

## Concurrency

Use this existing conversation only. If already active or another researcher owns this branch, skip the scheduled run. Fetch and compare remote HEAD before writing/pushing, inspect CI bot children, serialize validation, never force push. Same-environment runs should hold an exclusive `flock` on `/tmp/getgear-full-research.lock` for the work cycle; a lock is only local protection, so also inspect branch/CI state. Do not remove a held lock or assume a stale local checkout is authoritative.

## Checkpoint 8A — queue baseline

All 954 queued books (886 trainer-labelled +68 original vendor), 214 selected equipment cases and prior dungeon classifications already researched. These remain publication references and do not close current live routes (954 books, six dungeon exceptions). Latest full local/CI PASS: 42602679107; bot HEAD a907d939aea29fa9683a740514c4a8171b1318e3; later commits through recovered HEAD are release/documentation closeout. Latest three non-release runs all completed successfully; none pending at entry.

The frozen [5,688-case queue](remaining_equipment_research_queue.csv) selects canonical noncraft/nondungeon vendor, quest, undocumented, world-drop and reputation families, minus exact reviewed-equipment IDs. Counts: vendor 1,403; quest 234; undocumented 1,162; world-drop 2,887; reputation two. Generic source summaries are earlier structural reconciliation, not an individual merchant/quest/object/drop-route review. Research of these cases adds detail or records honest exceptions without erasing prior stronger sources.

**Next checkpoint 8B:** all 95 remaining vendor items at catalogue levels 1–30. Do not re-review 7C's 93 cases. Fetch exact Forever item pages, identity-lock, preserve alternate routes, independently join merchant inventories by exact item ID/name, check costs/stock/requirements and qualified locations. Missing/version-disputed inventory remains unresolved. Then remaining lower-level quests, higher-level vendor/quest/undocumented, world-drop, reputation and final full integrity/acceptance plan. Further batches can subdivide these coherent groups.

8A targeted checks: queue unique IDs, canonical name/level equality, zero intersection with reviewed-equipment registry, exact family partition and 95 next-batch IDs. PASS; documentation only, no regeneration/full CI. Commit identity is recoverable from Git history (do not insert a self-referential commit hash).

## Checkpoint 8B complete

All 95 selected vendor cases publication-researched/integrated; full local PASS 14/14,24 modules. GitHub full PASS 42616476682 (source 9f90939f1db03bb17fac0af249052f4394016ec9); direct bot child bad361a997d6d24d66bf1f81ecd9e6289ebd0342 inspected: timestamp/three response hashes only. All 14 logs verified through connector. Next 8C may begin. Frozen queue now marks these 95 researched; 5,593 remain, with **34 lower-level quest-family IDs marked 8C**. See exact evidence note. Automation start was adjusted to two hours after setup (`DTSTART:20261109T141544Z`, Adelaide 10 November 00:45:44), then every two hours; enabled, next-run field still null. No usage/billing controls changed.

## Checkpoint 8C in validation

All34 selected lower-level quest-family IDs publication-researched:32 rewards/two provided-only objects. Full local PASS14/14,24 modules,3 files. GitHub pending source push; finish and inspect bot before next batch. Runtime index2,178; equipment343; recipes954. Remaining frozen queue5,559; **71 vendor level31–40 IDs marked8D** are next. Preserve exact-role and access exceptions; source evidence/failed object reads documented in case note.
