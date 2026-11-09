# GetGear 1–60 acquisition reconciliation — release-readiness gate

**Status: not approved for another build or public release (9 November 2026).**
This is an offline evidence-reconciliation branch; it is not a verified in-client release candidate.
The existing public v0.14.0-beta7 prerelease is separate from this work. No subsequent ZIP, tag, release, merge or change to `main` has been authorised.

## Latest validated state
- Development branch: `work/full-acquisition-reconciliation-20261109`.
- [Completed checkpoint and provenance](../RECONCILIATION_PROGRESS.md); [regenerated reconciliation summary](reconciliation-20261109/README.md).
- **7,707** equipment IDs retained, with **36,341** class-item objectives across nine classes.
- **1,252** previously indexed crafting recipes matched the reference dataset and their original ingredient lists remain unchanged. Checkpoint 1 additionally corrected *Idol of the Dream* (220606), a previously omitted Enchanting craft.
- **577** historically dungeon-associated entries reviewed: **552** actual dungeon equipment entries, **24** equipment entries associated with potentially dungeon-acquired patterns, and **1** finished Enchanting craft incorrectly imported as dungeon loot.
- **6** dungeon equipment entries remain source-unverified after Checkpoint 4, including **2** Dark/Relic Coffer container leads; **14** additional named encounter-role references were reviewed with Forever-specific sources. **9** Scarlet Graveyard rare references were documented in checkpoint 2 and **2** named-trash entries in checkpoint 3.
- Nine earlier journal references plus three newly reviewed rare encounters are classed `rare-boss`; Rift Bracers and Vicar’s Robe remain `trash`, and **2** historical coffer entries are `container-lead`. All are references, **not** verified current live loot probabilities.
- **954** recipe-book sources still need live confirmation: **68** named-vendor references and **886** trainer-labelled recipes with separate book IDs.
- Player-observed and community listings must remain labelled by evidence quality; a client encounter name is not a confirmed drop rate.

## Automated validation
- [Comprehensive reconciliation workflow 42489073921](https://github.com/magicaddons/getgear/actions/runs/42489073921): **passed** the original crafted-item correction and full validation.
- [Checkpoint 2 workflow 42490031007](https://github.com/magicaddons/getgear/actions/runs/42490031007): **passed** the nine specific Scarlet Graveyard rare-boss references, report regeneration, Lua syntax, 9-class catalogue, sources, recipe materials, armour rules, compact overlay filtering, preview layout and performance regressions.
- [Armour-only overlay CI 42490932171](https://github.com/magicaddons/getgear/actions/runs/42490932171): **passed** full nine-class tests, two ordinary armour stat aliases, default-off opt-in, setting persistence and tracked/all-material correctness.
- [Checkpoint 3 named-trash CI 42491517157](https://github.com/magicaddons/getgear/actions/runs/42491517157): **passed** source regeneration, 7,707 equipment and 1,252 recipe checks, nine-class regressions, Lua syntax, UI filters, materials, preview and performance. The regenerated reports and evidence index are saved in [commit 059e188](https://github.com/magicaddons/getgear/commit/059e18829305a1b195d0ee310277da86a507fe8b).
- The tests include a regression preventing the crafted Idol of the Dream from being treated as dungeon equipment.
- This workflow **does not package an addon** or publish anything. All files are committed only to the development branch.
- Automated Lua tests do not establish real Forever item-cache behaviour, vendor stock, actual drop rates or on-screen layout in the live client.

- **Checkpoint 4 PASS:** [20-case evidence register](reconciliation-20261109/CHECKPOINT4_EVIDENCE.md) and [577-row consistency audit](reconciliation-20261109/CHECKPOINT4_CONSISTENCY.md). [Non-release workflow 42493307958](https://github.com/magicaddons/getgear/actions/runs/42493307958) passed the complete nine-class, source-generation, Lua syntax, overlay/filtering, materials, preview and performance suite. This does **not** prove live loot or approve a build.

**Checkpoint 5B evidence-only:** [five additional Grovekeeper vendor leads](reconciliation-20261109/CHECKPOINT5B_VENDOR_EVIDENCE.md) have individual evidence classifications; 8/68 researched overall, 68/68 still require live stock verification. Documentation-only; no new CI. No release approval.

**Checkpoint 5C evidence-only:** [seven Grovekeeper books 273960–273966](reconciliation-20261109/CHECKPOINT5C_VENDOR_EVIDENCE.md) reviewed; **15/68** vendor book references researched, **68/68** still require live stock confirmation, **954** total book-route uncertainties unchanged. No runtime edits and no new CI; prior PASS 42493307958 remains the latest validated code run.

**Checkpoint 5D evidence-only:** [seven books 273967–273973](reconciliation-20261109/CHECKPOINT5D_VENDOR_EVIDENCE.md) researched; **22/68** vendor books individually reviewed, **68/68** still live-stock-unverified, **954** total book-route uncertainties unchanged. Direct Forever item tooltip establishes specific 273968 reputation/quest gate. No runtime edits or new CI; prior PASS 42493307958 remains latest validated code run.

**Checkpoint 5E evidence-only:** [seven exact Forever book tooltips 273974–273980](reconciliation-20261109/CHECKPOINT5E_VENDOR_EVIDENCE.md) reviewed and queue-ID cross-checked: **29/68 vendor books individually researched**, **39/68 remain unreviewed**, **68/68 vendor-stock references still live-unverified**, **886 trainer-labelled references still unresolved** and **954 total unresolved recipe-book routes**. No runtime code/source changes. Targeted source-register validation passed, but **no new full CI was run**; the last full no-release CI pass remains 42493307958. No release approval.

**Checkpoint 5F evidence-only:** [13 Justice/Conviction books](reconciliation-20261109/CHECKPOINT5F_VENDOR_EVIDENCE.md) reviewed with source-confidence distinctions; **42/68** individually researched, **26** remaining. All 68 vendor stock sources remain unverified live. Targeted source-register checks PASS; no new full CI, no runtime changes, no release authority.

**Checkpoint 5G evidence-only:** [13 book sources 273994–274006](reconciliation-20261109/CHECKPOINT5G_VENDOR_EVIDENCE.md) investigated with three direct item tooltips and ten named guide references; **55/68** reviewed, **13** still to review. All **68** live stock unverified, all 954 uncertain learning sources open. Targeted checks PASS, no new full CI or runtime changes.

**Checkpoint 5H / published-vendor research closeout:** [68-case index](reconciliation-20261109/vendor_book_research_index.csv), [summary](reconciliation-20261109/VENDOR_BOOK_RESEARCH_COMPLETE.md), and [final 13 cases](reconciliation-20261109/CHECKPOINT5H_VENDOR_EVIDENCE.md). **68/68** vendor-book references have been individually researched, but **0/68 live vendor-stock purchases** observed. All 68 remain unverified live; 886 trainer-labelled records still outstanding (954 total). Targeted 68-row schema/relationship audits PASS. No runtime source-data updates, no new full CI, no release approval.

**Checkpoint 6A — trainer-labelled learning-method triage:** [all 886 grouped](reconciliation-20261109/TRAINER_BOOK_TRIAGE.md), [886-record research index](reconciliation-20261109/trainer_book_triage_index.csv), [7 independent Forever-specific case reviews](reconciliation-20261109/CHECKPOINT6A_TRAINER_SOURCE_EXAMPLES.md). **886/886 structural source checks PASS, but all 886 acquisition routes remain unverified live**. Eight research families distinguish Merchant's Favor (188), other vendors (131), quests (36+1 mixed), reputation (94), boss/dungeon (41), generic drop (221), no source (174). AHledger's universal trainer label must not be treated as direct trainer evidence. No runtime change and no new CI beyond prior full PASS 42493307958. Next focus: Merchant's Favor source batches. Still no build or public release approval.

## Next work, one bounded category at a time
1. **Dungeon equipment source quality:** the role checkpoint is complete; [6 source-confirmation leads](reconciliation-20261109/dungeon_source_followups.csv) remain and should only be resolved with new Forever item-specific evidence. Avoid assuming live event spawns, City of Dalaran loot, Scholomance historic drops, or coffer contents.
2. **Recipe learning source quality — next active checkpoint:** investigate groups among [954 unconfirmed books](reconciliation-20261109/recipe_source_followups.csv). Distinguish the recipe item's existence from trainer teaching, vendor stock and reputation/specialisation gates.
3. **Other acquisition uncertainties:** review the earlier [complete equipment queue](unresolved_items.csv) using Forever-specific observations; retain items with unconfirmed routes rather than deleting them.
4. **Live acceptance:** inspect source strings, the crafting materials view, per-character settings, and SavedVariables migration on an installed Forever client.

## Required before requesting build approval
- Any new source-data change must pass the full nine-class tests again.
- Verify representative early levelling items, including Goblin Mail Leggings (1943), Blackwater Cutlass (1951) and Guard's Chain Shirt (250489), plus newly corrected Idol of the Dream (220606).
- Confirm new source descriptions remain clear and uncertainty is visible in the compact overlay and detailed guide.
- Verify armour-only negatives stay hidden for Priests/casters, that optional tank opt-in works, and that armour display deltas remain legible in-client.
- Report unresolved sources openly instead of claiming complete live verification.
- **Ask for explicit permission before creating a ZIP, tag, release or modifying `main`.**

No user action is required for further offline source research; eventual in-game checks can be optional and targeted.

## Full non-release validation refresh — 9 November 2026

**Local PASS; GitHub PASS.** [Full evidence and generated-change review](reconciliation-20261109/FULL_VALIDATION_20261109.md). Fresh baseline 2dd4d453501aef7bf6d7fb9d3b831dff7dc245c5; online reconciliation, Python compile, 3 required files, all 24 Lua modules and all 14 workflow regressions passed after regeneration. Catalogue, ingredients, eligibility, settings and filters retained. Refresh includes two qualifying recorded Everloot gear observations and one book observation; publications alone remain unconfirmed. Six dungeon and 954 recipe routes stay open. No live-client acceptance or release approval. [Non-release CI 42547493799](https://github.com/magicaddons/getgear/actions/runs/42547493799) completed successfully, including all 14 regressions. Validated input commit: `458292015cd3e3720efde22502fbaa1c7a0468de`. Verified final bot HEAD: `50db73df97eedead6af702f183690785775ec392` (only provenance timestamp and three response hashes changed). Documentation-only closeout follows that commit; no new CI required for this outcome record.
