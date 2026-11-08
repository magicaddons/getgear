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
