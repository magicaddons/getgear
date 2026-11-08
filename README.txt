GETGEAR 0.14.0 BETA 7 — ALLIANCE LEVELS 1–60
================================================
PUBLIC BETA / PRE-RELEASE. Not a finished, fully verified item database.
Official download: https://github.com/magicaddons/getgear/releases/tag/v0.14.0-beta7

ABOUT
-----
GetGear is an in-game guide for gear that each of the nine Alliance classes
can equip between levels 1 and 60. It lists useful leads and materials, not
a ranked best-in-slot list or a prescribed specialization build.

FEATURES
--------
- Unified class catalogue across levels 1–60; no manual spec picker.
- Available Now, Next 5 Levels, Earlier Gear, Completed/Skipped, Hidden,
  Bags, and a read-only guide preview for all classes and levels.
- Compact overlay with up to 32 shown records; detailed pages of 40.
- Default body armour priorities, including the level-40 plate/mail changes.
  Enable "Show all valid equipment" for unusual class-equippable alternatives.
- Source leads for quests, bosses, vendors, crafting and world drops, with
  uncertainty clearly indicated where the live Forever route is unknown.
- Crafting recipes and materials from a dated Forever client snapshot;
  combined material totals and optional personal "can't craft" filter.
- Progress state, item tooltips, stat comparisons, map navigation where
  supported, bag objectives, and saved account inventory snapshots.
- Preview Guide Display settings are positioned to avoid control overlap.

INSTALL / UPGRADE
-----------------
1. Exit WoW Forever completely.
2. Back up AddOns/GetGear and its WTF SavedVariables.
3. Extract the official GitHub Release ZIP. Copy the single GetGear folder
   into _forever_/Interface/AddOns/, replacing the old folder.
4. Ensure _forever_/Interface/AddOns/GetGear/GetGear.toc exists (no nesting).
5. Open the game and type /getgear. Do not use /gg.

WARNING: Moving from v0.12.x to the unified v0.14.x schema can reset old
per-character acquired/skipped/hidden statuses and display preferences.
Account inventory is intended to remain, but back it up as well.

KEY COMMANDS
------------
/getgear             Open/close detailed guide
/getgear overlay     Toggle compact tracker
/getgear settings    Display options
/getgear status      Catalogue / talent-detection diagnostics
/getgear notify      Toggle source-aware level notifications
/getgear inventory   Inventory diagnostics
/getgear bankdiag    Bank-container diagnostics

SOURCES, SCOPE & REPORTING
--------------------------
The 7,707-item catalogue (36,341 class-equippable item objectives) is based
partly on a Forever item snapshot from 21 Oct 2026. Recipe reagents for 1,244
crafted items come from 31 Oct 2026 client-derived data. Not all entries,
vendor stock, quests, boss drops, recipe-learning sources and skill levels
are verified obtainable in the current game. Alliance is the route focus.

Bank and bag contents for offline alts are last-known snapshots only;
inventory does not imply live remote access.

Read the public release notes and current README.md at:
https://github.com/magicaddons/getgear
Report errors with item IDs, class, level, source and screenshots at:
https://github.com/magicaddons/getgear/issues
