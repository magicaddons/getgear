# GetGear

**An in-game levels 1–60 gear catalogue and crafting planner for World of Warcraft Forever.**

GetGear helps **Alliance characters across all nine classes** browse class-equippable equipment from **level 1 through 60**, find documented acquisition leads, plan crafting materials, and track items they want to obtain. It is an **equipment information guide**, not a best-in-slot ranking or a specialization-based recommendation engine.

> **Beta status:** Coverage is broad, but not every item or source has been verified in the live WoW Forever client. Where acquisition, recipe or availability information is uncertain, treat it as a lead rather than a guaranteed route.

## Download

### [Download GetGear v0.14.0 Beta 8](https://github.com/magicaddons/getgear/releases/tag/v0.14.0-beta8)

Open the release page and download **`GetGear-v0.14.0-beta8.zip`** from **Assets**.

**Install the release ZIP, not GitHub's automatically generated “Source code (zip)”**, which contains the repository rather than just the installable addon.

[All releases](https://github.com/magicaddons/getgear/releases) · [Beta 8 release notes](https://github.com/magicaddons/getgear/blob/v0.14.0-beta8/RELEASE_v0.14.0-beta8.md) · [Report an issue](https://github.com/magicaddons/getgear/issues)

## Features

- **Levels 1–60, all nine classes:** A unified catalogue of **7,707 distinct equipment item IDs**, indexed into **36,341 class-equippable item objectives**. These are candidates, not 36,341 individually verified upgrades.
- **Simple, class-wide equipment lists:** No manual specialization selector. Browse equipment your class can equip and decide what is useful for your build.
- **Level-aware progression:** **Available Now**, **Next 5 Levels**, and **Earlier Gear** update as you level. Track older items separately without losing their entries.
- **Default armour priorities:** Warrior/Paladin see mail before level 40 and plate from level 40; Hunter/Shaman see leather before 40 and mail from 40; other classes use their usual primary armour type. **Show all valid equipment** restores unusual lower-armour choices when desired, without including known internal/test items.
- **Source and acquisition information:** See researched or client-referenced quest rewards, dungeon drops, vendors, world drops and crafted equipment. Where source confidence is limited, the guide identifies uncertainty instead of inventing a source.
- **Crafting and material planning:** Recipe information and ingredient lists for **1,244 catalogue-crafted items**, with individual and aggregated material totals where available. Profession skill requirements and recipe-learning sources are only shown as confirmed when evidence supports them.
- **Optional personal crafting filter:** **Hide crafted gear I can't make** is **off by default**, so externally crafted and purchasable gear stays visible. Switch it on to hide crafts that the current character cannot positively confirm they can make.
- **Detailed guide and compact tracker:** Browse the main guide or keep an adjustable on-screen tracker; detailed pages and the overlay are bounded for responsiveness.
- **Read-only Preview Guide:** Explore other classes and levels **1–60** without changing your character's progress; its toolbar includes the corrected non-overlapping class, level and display controls.
- **Progress and bag planning:** Mark items acquired or skipped, hide unwanted entries, and inspect bag-upgrade options.
- **Account-wide inventory browser:** Search last-known personal bag and bank snapshots from characters you've logged into. These are snapshots, not a live inventory service.
- **In-game tooltips and maps:** Item stats, equipment comparisons, and map buttons for locations with supported evidence.

## Installation

1. Download **`GetGear-v0.14.0-beta8.zip`** from the [Beta 8 release](https://github.com/magicaddons/getgear/releases/tag/v0.14.0-beta8).
2. **Exit WoW Forever completely.** Back up your existing `GetGear` addon folder and its SavedVariables if you want to preserve or restore your current setup.
3. Extract the ZIP and copy its **`GetGear`** folder to `_forever_/Interface/AddOns/`, replacing the old folder. Remove any nested or duplicate addon copies.
4. Verify the file is at `_forever_/Interface/AddOns/GetGear/GetGear.toc`.
5. Start the game and type **`/getgear`**.

### Upgrading from v0.12.x

The unified 1–60 guide introduces a new per-character progress schema. **Your old acquired/skipped/hidden objective status and display preferences can reset when migrating from v0.12.x.** Back up SavedVariables before upgrading. The separately tracked account inventory is intended to be retained, but a backup is still advisable.

## Beta 8 improvements

- Recipe books: exact vendors, enemies, quests, objects, locations, requirements and alternative routes, with confidence limits.
- Expanded lower-level quest/vendor/drop/fishing directions and warnings for unavailable or cross-version item records.
- Compact tracker shows positive stat improvements, with optional armour-only improvements and default-hidden green world BoEs. The full guide retains class-equippable informational coverage.
- Corrected crafted Idol of the Dream and clearer boss/trash/container references; existing crafting materials, filters and settings safeguards retained.

## Commands

| Command | Action |
|---|---|
| `/getgear` | Open or close the detailed guide |
| `/getgear overlay` | Toggle the compact tracker |
| `/getgear settings` | Open display settings |
| `/getgear inventory` | Open account inventory diagnostics |
| `/getgear status` | Show catalogue and talent-detection diagnostics |
| `/getgear notify` | Toggle source-aware level notifications |
| `/getgear bankdiag` | Inspect bank container diagnostics |

## Account-wide inventory

GetGear records **last-known inventory snapshots** rather than live counts from offline characters. To populate them, log into each character, open their personal bank to permit a scan, then open **Alt Inventory** from the detailed guide. Counts may be incomplete or stale until the relevant character or bank is scanned again. The addon does not automatically track offline mail, auctions, guild banks or account-wide bank storage.

## Current scope and limitations

- **Alliance is the supported route focus.** This release covers equipment levels **1–60**, not a completed Horde acquisition guide.
- The 7,707-item catalogue includes candidates inferred from class proficiency and dated client records; inclusion **does not prove the item is currently obtainable or a practical upgrade**.
- Beta 8 supplies **2,177 conservative acquisition summaries**, including individually reviewed metadata for **954 recipe-book cases** and **214 other equipment cases**. These include honest unknown origins, unavailable-page flags and cross-version warnings.
- **Six dungeon source links and 954 current recipe-book routes** still need live verification. Broader world-drop, vendor and quest coverage remains incomplete; named sources do not imply guaranteed current loot or stock.
- Some recipe acquisition routes, trainer learn minima, binds, reputation requirements and quest eligibility still need client verification. The reagent snapshot is dated **31 October 2026**; the broad item cache is dated **21 October 2026**.
- Full in-game testing across every class, level, quest, map and profession is ongoing. The successful automated regressions do not certify all live client interactions or item availability.

For current evidence, validation and remaining gaps, see the [Beta 8 release gate](https://github.com/magicaddons/getgear/blob/v0.14.0-beta8/docs/source-audit-1-60/RELEASE_GATE.md).

## Feedback and bug reports

Please [open a GitHub issue](https://github.com/magicaddons/getgear/issues) for an incorrect item, source, material list, display problem or Lua error. Include the **GetGear version**, **character class and level**, **item name/ID**, expected versus observed behaviour, and an in-game screenshot or tooltip where possible. For inventory problems, include whether bags and banks were rescanned.

---

*GetGear is a community addon project; it is not an official World of Warcraft or Blizzard product.*
