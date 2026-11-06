# GetGear v0.12.14 Beta — personal crafting filter and cleaner comparisons

**WoW Forever · Alliance levels 1–30 · nine classes**

This release incorporates the staged comparison cleanup and a new, optional per-character gear filter requested by players who prefer to see only equipment they can currently craft themselves.

## New: Hide crafted gear I can't make

Open **/getgear settings** and enable **Hide crafted gear I can't make**.

- **Off by default** — unchanged behaviour. GetGear continues recommending worthwhile crafted gear even if another player would have to craft it.
- **On** — hides crafted-only gear that the current character cannot confidently craft because their profession is missing, their confirmed required skill is too low, or the recipe has not been positively detected as learned.
- **Important:** Open your profession window at least once after logging in so GetGear can scan learned recipes. If the client has not exposed a recipe, this strict opt-in filter hides that gear until positive evidence is available.
- Other acquisition routes (quest rewards, dungeon drops, vendors, and items that can also drop as finished gear) remain visible, as do ordinary bag upgrades.
- Updates automatically as the client reports profession/recipe changes; affects current/next-level lists, upcoming equipment, and material totals.
- Completed and Hidden history remain accessible; Preview Guide remains unfiltered.
- Per-character SavedVariables store the setting, with no change to saved gear statuses.

## Removed repetitive comparison warnings

- Warrior weapon rows no longer append **"Warrior: compare weapon DPS, speed and effects manually; stat deltas are incomplete."** beneath already-calculated damage and stat values.
- Equivalent Feral Druid and generic all-class tooltip disclaimers were removed.
- Existing Strength, Stamina, Armor and Weapon DPS deltas remain unchanged, including two-hand-vs-main-and-off-hand comparisons.
- A few redundant Warrior and Feral Druid gear notes were shortened.
- Conservative obsolete-gear detection still checks stats/DPS/effects before classifying items. This patch does not change the comparison engine.

## Testing and compatibility

- Regression tests passed: **35 Lua modules**, **234 catalogue items**, **426 recommendations**, **37 class/spec previews**; level-6 Priest regression; item-event/login guard regression; nine-class comparison regression; strict craftability filter with recipe/skill/alternate-route/material/history checks.
- Installable ZIP package integrity verified by GitHub Actions.
- Preserves v0.12.13 login-data refresh fix, prior early-game crafting updates, existing material records, saved progress and the sole command `/getgear`.
- **Live-client testing remains necessary** for specific profession APIs and learnable recipes; addon is beta.

## Install

Under **Assets**, download **`GetGear-v0.12.14-private-test-beta.zip`**. Do **not** use GitHub's automatically generated source-code ZIP.

Close WoW Forever, replace the existing `GetGear` addon folder with the ZIP's `GetGear` directory under `_forever_/Interface/AddOns/`, then log in and type `/getgear`.

Previous versions remain available, including [v0.12.13](https://github.com/magicaddons/getgear/releases/tag/v0.12.13).

For problems, please [open an issue](https://github.com/magicaddons/getgear/issues) including version, character class/level/spec, whether the crafting filter is enabled, and screenshots or Lua errors.
