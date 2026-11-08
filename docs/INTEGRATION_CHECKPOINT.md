# GetGear unified development checkpoint — 9 November 2026

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
- **Mixed-stat spell-power protection:** [PR #6](https://github.com/magicaddons/getgear/pull/6) has been merged into this development branch. Each item now carries independently sourced (nonexclusive) spell-power, healing, mana, physical and defense flags where available. The generated Forever tooltip index covers **7,699 / 7,707** items; eight lack matching tooltip data. Warrior, Rogue and Hunter hide explicit spell-power items by default, even when they also contain Strength or Stamina. Paladin, Shaman and Druid retain hybrid choices; the existing Show all valid equipment option remains an override. [Evidence and source hash](source-audit-1-60/STAT_FLAGS.md) and nine-class regression tests are included.
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

## Full acquisition reconciliation integrated

[Pull request #7](https://github.com/magicaddons/getgear/pull/7) merged the complete
[1–60 acquisition evidence register](source-audit-1-60/reconciliation-20261109/README.md)
into this branch. Source-specific manual corrections and the two overlay
filters remain unchanged.

- **7,707 items / 1,252 crafted equipment recipes** cross-referenced by ID.
- **1,075** additional, conservative displayed acquisition-source references,
  with original confidence preserved; generic vendor/quest references are
  never presented as confirmed player observations.
- **577** old dungeon-associated records separated into **553 genuine
  equipment drop objectives** and **24 crafted-equipment pattern sources**.
- Among actual dungeon equipment: **386 published boss references**, **135
  trash references**, and **32 still needing exact boss/trash or enemy
  classification**. Only **13 item/NPC relationships** have joined evidence
  from independently observed player installs. Boss/trash references are
  useful directions, not live drop-rate promises.
- **68 newly indexed high-level recipe books** are now linked to their
  crafted output items. Published recipe sources point to **Aisarra Nightmeadow
  (Mount Hyjal)** but live stock remains unverified, and some plans have
  Guardians of Hyjal reputation, quest or slot-specialization gates.
- **886 trainer-labelled recipes also have distinct pattern book IDs**;
  both possible acquisition routes need independent checking, and the
  existence of a book does not by itself contradict trainer learning.
- Original ingredient lists, equipment roles, class masks and SavedVariables
  remain unchanged. All nine classes and existing overlay-filtering regression
  cases passed on [source integration CI](https://github.com/magicaddons/getgear/actions/runs/42488267084).

### New reports

[All sources and confidence levels](source-audit-1-60/reconciliation-20261109/all_items_reconciled.csv) ·
[Dungeon equipment drops](source-audit-1-60/reconciliation-20261109/dungeon_equipment_drops.csv) ·
[32 dungeon verification targets](source-audit-1-60/reconciliation-20261109/dungeon_source_followups.csv) ·
[Recipe learning research](source-audit-1-60/reconciliation-20261109/recipes_reconciled.csv) ·
[Optional in-game verification](source-audit-1-60/reconciliation-20261109/OPTIONAL_IN_GAME_CHECKS.md).

## Not yet claimed

1. **Comprehensive public-source reconciliation is complete, but live
   acquisition verification is not.** The 32 ambiguous dungeon items and
   954 pattern-book origins lack conclusive in-game evidence; all uncertain
   sources remain explicitly labelled. Do not equate published loot-table
   references with guaranteed live drops.
2. **No in-client acceptance testing** of the combined branch yet. WoW's
   real item-info cache, SavedVariables upgrades and overlay layout must
   be exercised before proposing an installable ZIP.
3. The new `work/overlay-hide-green-boe-world-drops` branch has no
   commits as of this checkpoint. Its intended behaviour is already
   implemented on THIS integration branch; avoid importing a later
   duplicate blindly.
4. The mixed-stat spell-power relevance fix **is included** and verified
   on this unified branch. Do not import duplicate code from other tabs.

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
