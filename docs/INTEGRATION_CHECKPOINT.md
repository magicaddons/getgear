# GetGear integration checkpoint — 8 November 2026

This branch is the **only candidate for the next combined Beta**, not a public
release. It starts from `work/acquisition-reconciliation-1-60` at
`6b7218d2b1f27e10c0274d187f6e83b6a11fab19`, which incorporates the
1–60 catalogue audit and the targeted acquisition-source/material-name work.

## Included and validated

- **Level 1–60 reports:** Complete audit, dungeon exception queues, recipe
  learning source queues, source provenance, and release gates under
  `docs/source-audit-1-60/`.
- **Acquisition labels:** Explicit Deadmines trash-source examples and
  distinguish dropped plans, vendor recipes, and unresolved sources. Classic
  sources are never silently promoted to confirmed Forever loot.
- **Material names:** All 1,252 crafting gear recipes have resolved names in
  the offline test. Other class data is indexed before character selection.
- **Hide non-upgrades:** Ported from
  `work/overlay-positive-stat-filter`. When comparison data for a
  candidate is complete, only negative/zero deltas means omit it from the
  *overlay*. Comparisons with missing data remain visible.
- **Hide green BoE world drops:** New, on by default. Generic world drops
  which are Uncommon + Bind-on-Equip are omitted from the *overlay*. Explicit
  dungeon/quest/vendor/crafted routes are protected, even when those items
  themselves are BoE. The independent Classic + Forever quality index is
  only a cache-miss fallback; live client item information takes precedence.
- **Both rules are reversible:** Settings toggles per character; detailed
  guide still allows browsing, and saved Hidden/Acquired/Skipped states
  aren't changed. Tracked materials reflect the overlay-filtered objectives;
  All-materials mode retains its broader scope.

### Automated checks

[Combined GitHub Actions verification](https://github.com/magicaddons/getgear/actions/runs/42483867287):
all nine classes, full 7,707 equipment catalogue, 1,252 crafting recipes,
43 validated older corrections, material labels, source labels, primary
armour tiers, 1–60 preview layout, overlay comparison cases, green-BoE
cases and module-load performance passed.

Generated fallback provenance and counts:
[BOE_FILTER_INDEX.md](source-audit-1-60/BOE_FILTER_INDEX.md).

## Not yet claimed

1. **Full acquisition reconciliation is not complete.** The audit contains
   unresolved server-side loot and recipe-learning sources. Sources not
   corroborated are labelled conservatively.
2. **No in-client acceptance testing** of the combined branch yet. WoW's
   real item-info cache, SavedVariables upgrades and overlay layout must
   be exercised before proposing an installable ZIP.
3. The new `work/overlay-hide-green-boe-world-drops` branch has no
   commits as of this checkpoint. Its intended behaviour is already
   implemented on THIS integration branch; avoid importing a later
   duplicate blindly.
4. Separate work about class-specific spell/physical relevance may still
   need reconciliation if another tab commits changes. Do not assume
   this feature was included.

## Rules for concurrent sessions

- Each other tab may continue **research** or work in its isolated branch.
- Changes from any branch must be reviewed against this branch by file
  and behaviour, not merged automatically.
- `UI.lua`, `Core.lua`, `GuideState.lua`, and `GearCompare.lua` are the
  conflict-prone files. Do not overwrite them with a complete version
  from a different branch.
- This development branch and its tests are the integration baseline.
  **Do not publish a ZIP, tag, release, or change `main` without explicit
  user authorization.**
