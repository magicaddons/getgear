# GetGear v0.14.0 Beta 7 — levels 1–60

**Public beta / pre-release for World of Warcraft Forever (Alliance).** This is a major change from the older v0.12.14 release. It expands the guide to **levels 1–60** and replaces prescriptive specialization lists with a single class-equippable catalogue.

## Highlights

- **All nine classes, levels 1–60:** 7,707 distinct item IDs with 36,341 class-equippable item objectives, including original researched records and additional Forever client-cache equipment. Items are candidates for your judgement, not individually verified upgrades.
- **Unified guide:** No manual spec selection. **Available Now**, **Next 5 Levels** and **Earlier Gear** use rolling level windows, with a read-only class and level Preview Guide.
- **Better default armour filtering:** Warriors and Paladins primarily see mail before level 40 and plate after; Hunters and Shamans switch from leather to mail at 40. Lower-armour alternatives remain available with **Show all valid equipment**. In particular, leather such as **Ceremonial Leather Harness** no longer clutters the default Warrior list.
- **Preview Guide layout fix:** **Display settings** no longer overlaps the class selector. The control sits alongside the Full 1–60 option in preview and returns to the normal position outside preview.
- **Crafting reconciliation:** Dated client recipe data supplies material ingredients for 1,244 catalogue-crafted items; 1,060 previously missing lists were populated and 43 conflicting lists corrected against the source snapshot.
- **Acquisition leads:** Additional client-referenced boss, vendor and quest names, with clear indication when source availability, location or eligibility remains unverified.
- **Compact tracker, detailed guide, progression status, alt inventory snapshots, bags, material totals, source-aware map links and optional personal craftability filtering** remain available.

## Install

1. In **Assets** below, download **`GetGear-v0.14.0-beta7.zip`**. **Do not use** GitHub's auto-generated *Source code* archive.
2. Completely exit WoW Forever and back up the existing `GetGear` addon folder and its `WTF` SavedVariables.
3. Extract the archive and place its **`GetGear`** folder under `_forever_/Interface/AddOns/`, replacing the previous addon. Confirm `_forever_/Interface/AddOns/GetGear/GetGear.toc` exists.
4. Log in and use **`/getgear`**.

**Migration warning:** Upgrading from **v0.12.x** to the restructured v0.14.x catalogue can reset previously acquired, skipped and hidden progress, along with display preferences. Account inventory data is intended to be retained, but back up SavedVariables before installing.

## Data quality / known limitations

This is a **beta**, not a guarantee that every indexed item is obtainable on the live realm. A broad cache is dated **21 October 2026** and a recipe source snapshot **31 October 2026**. Vendor/quest observations are sampled. **1,439 vendor identities, 204 quest identities and 107 dungeon entries without identified bosses** remain unresolved in the available source data. Some dungeon items could be trash drops rather than boss loot. Recipe learning sources, thresholds, bind restrictions and faction eligibility are not uniformly verified. Horde acquisition paths are outside this release's current focus.

Nine-class catalogue, regression, ingredient, performance, armour-filtering and Preview Guide layout checks passed in automated testing. **Individual in-game routes and all live UI interactions still need community verification.** Please report errors with item ID, class, level and screenshot.

## Project information

- [Full features and current installation instructions](https://github.com/magicaddons/getgear#readme)
- [Source audit and reconciliation limitations](https://github.com/magicaddons/getgear/blob/main/docs/BETA7_RECONCILIATION.md)
- [Issues and feedback](https://github.com/magicaddons/getgear/issues)

*GetGear is a community project and is not affiliated with Blizzard.*
