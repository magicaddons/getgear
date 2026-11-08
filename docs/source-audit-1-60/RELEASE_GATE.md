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
- **31** dungeon equipment entries still need a better boss/trash/specific mob classification or current-server evidence.
- **954** recipe-book sources still need live confirmation: **68** named-vendor references and **886** trainer-labelled recipes with separate book IDs.
- Player-observed and community listings must remain labelled by evidence quality; a client encounter name is not a confirmed drop rate.

## Automated validation
- [Comprehensive reconciliation workflow 42489073921](https://github.com/magicaddons/getgear/actions/runs/42489073921): **passed** source regeneration, syntax checks, 9-class catalogue, sources, recipe materials, armour rules, compact overlay filtering, preview layout and performance regressions.
- The tests include a regression preventing the crafted Idol of the Dream from being treated as dungeon equipment.
- This workflow **does not package an addon** or publish anything. All files are committed only to the development branch.
- Automated Lua tests do not establish real Forever item-cache behaviour, vendor stock, actual drop rates or on-screen layout in the live client.

## Next work, one bounded category at a time
1. **Dungeon equipment source quality:** resolve a small, evidence-supported group from [31 remaining leads](reconciliation-20261109/dungeon_source_followups.csv). Do not call a rare/elite mob a boss merely because Classic databases attach its name to loot.
2. **Recipe learning source quality:** only after dungeon work, investigate specific groups among [954 unconfirmed books](reconciliation-20261109/recipe_source_followups.csv). Distinguish the recipe item's existence from trainer teaching, vendor stock and reputation/specialisation gates.
3. **Other acquisition uncertainties:** review the earlier [complete equipment queue](unresolved_items.csv) using Forever-specific observations; retain items with unconfirmed routes rather than deleting them.
4. **Live acceptance:** inspect source strings, the crafting materials view, per-character settings, and SavedVariables migration on an installed Forever client.

## Required before requesting build approval
- Any new source-data change must pass the full nine-class tests again.
- Verify representative early levelling items, including Goblin Mail Leggings (1943), Blackwater Cutlass (1951) and Guard's Chain Shirt (250489), plus newly corrected Idol of the Dream (220606).
- Confirm new source descriptions remain clear and uncertainty is visible in the compact overlay and detailed guide.
- Report unresolved sources openly instead of claiming complete live verification.
- **Ask for explicit permission before creating a ZIP, tag, release or modifying `main`.**

No user action is required for further offline source research; eventual in-game checks can be optional and targeted.
