# GetGear 1–60 development data scope (unreleased)

**Branch:** `work/gear-1-60-expansion` (draft PR #4). Do **not** treat this
branch as an installable replacement for published v0.12.14 without an
in-client test and release approval.

## What changed

- Restored the omissions reported by a level-13 Warrior:
  - Runed Copper Pants (3473), level 8 for Warrior/Paladin; Hunter/Shaman
    are additionally eligible once their mail proficiency unlocks at 40.
  - Thick War Axe (3489), level 12 for Warrior/Paladin/Hunter/Rogue/Shaman.
    Rogues may train one-handed axes in WoW Forever.
- Retained 23 hand-reviewed crafted gear entries for levels 31–60, including
  profession materials and the difference between crafting skill-up thresholds
  and proven recipe-learning requirements.
- Added a **dated source-caveated** import from
  [Napalmsteak's Forever item cache](https://github.com/Napalmsteak/WoW-Classic-Item-Caches).
  The cache contains 10,058 client-indexed rows and was last refreshed
  **October 21, 2026** (beta-era snapshot).
- Parsed 7,722 records as plausibly equipable green-or-better armor, weapons,
  jewelry or relevant relics within levels 1–60. Kept **7,492 records not
  already represented by the curated GetGear catalogue**. Current offline
  totals are **7,751 items** and **36,518 class-specific equipment objectives**.
  These are candidates, **not all validated live upgrades**.
- The importer excludes unconfirmed-client facts, items without a proven
  equip level (unless low-level starter gear), unsupported slots, faction/
  race-restricted items that need individual review, and items outside 1–60.
  Full exclusion counts and the exact cache SHA256 are in
  [generated-forever-audit.json](generated-forever-audit.json).

## Provenance and confidence rules

1. Hand-verified GetGear records win over generated rows for item identity,
   crafting materials, recipe skill, source, notes and existing progress ID.
   The generated data only adds missing class-eligible objectives.
2. Item existence, name, equip level, basic slot and class proficiency come
   from the Forever beta-client cache. The in-game client tooltip remains
   authoritative for stats and effects.
3. The cache's **quest, dungeon, vendor, drop and PvP labels do not establish
   live availability**. Generated items set acquisition confidence to
   `classic-reference`, use visibly tentative source labels and are excluded
   from level-up alerts requiring a confirmed acquisition route.
4. Source-listed crafted gear without a verified profession/recipe is
   marked `craftOnly`. The optional strict "Hide crafted gear I can't make"
   preference hides those records until reliable craftability is documented.
   Missing reagent lists are marked as incomplete, never treated as zero mats.
5. Equipment compatibility is based on known Forever proficiencies:
   Hunter/Shaman mail from level 40; Warrior/Paladin plate from level 40;
   Rogues can use one-handed axes. Explicit class-locked epics stay locked,
   e.g. Truefaith Vestments to Priest and Robe of the Void to Warlock.
6. Existing per-character statuses, hidden items and other settings retain
   their original `item_<ID>` keys. The import does not change SavedVariables.

## Performance and validation

- Indexed recommendation identities remove quadratic duplicate scans when
  thousands of new class objectives are registered.
- Detailed gear lists render **40 rows per page**; the compact overlay limits
  itself to **32 displayed objectives**. The complete list remains in the
  detailed window, without deleting objectives.
- The list processor applies character-level gates before expensive equipped
  checks. Obsolete comparisons for **uncached generated items** do not
  request thousands of item-data loads at once; visible/hovered entries
  still request item data lazily.
- In a GitHub Actions Linux/Lua 5.4 offline run, the full class dataset loaded
  in about **0.18 seconds**, versus 4.50 seconds before removing the quadratic
  fallback. This is **not** an estimate of WoW client load time.
- CI covers nine classes, 37 spec views, original 1–30 baselines, source-checked
  crafted items, early omissions, per-character progress, strict craftability,
  item refresh guards and a 5,000-item request-storm simulation.
- `tools/build_forever_catalog.py` is a reproducible importer. The separate
  cache-rebuild GitHub Action is **manual-only**; it neither publishes a
  release nor automatically commits data on ordinary pull requests.

## Outstanding before public release

- Confirm UI responsiveness and memory use in the actual Forever client,
  especially late-level gear lists and item tooltip loading.
- Cross-check item IDs/levels/class restrictions against the November live
  client; the October cache may contain changed, phased or unavailable gear.
- Verify or replace Classic-reference dungeon, quest, reputation, vendor
  and profession sources with observed Forever routes.
- Fill missing crafting reagents and recipe learning requirements progressively.
- Audit faction-restricted quest rewards, weapons with unusual proficiency
  exceptions, and the remaining 2,336 excluded cache rows case by case.
- Keep v0.12.14 published unchanged until a release candidate is approved.

Source copyright/attribution: item data and names © Blizzard Entertainment;
Forever cache assembled by Napalmsteak from Wowhead item tooltips. GetGear
redistributes **compact factual item identifiers and classifications**, not
the upstream HTML tooltip bodies or artwork.
