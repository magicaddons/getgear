# GetGear

**An in-game gear progression and crafting guide for World of Warcraft Forever.**

GetGear helps Alliance players plan equipment upgrades from **levels 1–30**, see where to obtain recommended items, track their progress, and work out the materials needed for crafted gear.

> **Beta status:** GetGear is in active development and testing. WoW Forever-specific item information, acquisition routes, and some client interactions still require verification in the live game.

## Download

**[Download GetGear v0.12.10 Beta](https://github.com/magicaddons/getgear/releases/tag/v0.12.10)**

On the release page, expand **Assets** and download **`GetGear-v0.12.10-private-test-beta.zip`**.

**Use the ZIP listed under Assets**, not GitHub's automatically generated *Source code (zip)*, which is intended for browsing the repository rather than installing the packaged addon.

## Features

- **Class and specialization gear guides:** Level 1–30 recommendations for all nine WoW Forever classes, currently focused on Alliance.
- **Compact on-screen tracker:** Keep relevant equipment objectives visible while playing; expand an item for more details.
- **Detailed gear guide:** View acquisition notes for quest rewards, dungeon drops, vendors, crafted items and other sources.
- **Crafting planner:** See required professions, documented recipe information, individual ingredients, and combined material totals.
- **Account-wide inventory browser:** Search saved bag and personal-bank snapshots from characters you have logged into, helping you locate items and materials across alts.
- **Progress tracking:** Mark objectives acquired or skipped, hide entries, and keep your checklist between sessions.
- **Preview mode:** Browse other classes, specializations and levels without changing your active character's checklist.
- **Bag upgrade guidance:** Compare bag upgrades and their acquisition or crafting requirements.
- **In-game item details:** Item tooltips, equipment comparisons, and map navigation where supported.

## Installation

1. Download the latest beta ZIP from [Releases](https://github.com/magicaddons/getgear/releases).
2. Close World of Warcraft.
3. Extract the ZIP and copy its **`GetGear`** folder into your WoW Forever client's `Interface/AddOns/` folder.
4. Check that `GetGear.toc` is directly inside `Interface/AddOns/GetGear/`, not inside an extra nested folder.
5. Launch WoW Forever and enter **`/getgear`** to open the guide.

If updating from an earlier version, replace the old `GetGear` addon folder. You can back up your SavedVariables first; v0.12.10 is designed to preserve existing GetGear progress.

## Using the account-wide inventory

GetGear keeps **last-known inventory snapshots**, not a live feed from offline characters.

1. Log into each character whose items you want to track.
2. Open the character's personal bank to allow available bank contents to be scanned.
3. Open **`/getgear`** and select **Alt Inventory** to search the recorded items.

Counts can be incomplete or out of date if a character's bags or bank haven't been scanned recently. A **`+`** beside a count indicates that it may be a known minimum rather than a complete total. Items on other realms or factions are not assumed transferable.

## Current scope and limitations

- **Alliance levels 1–30** are the current gear-guide focus; Horde and later levels are not yet covered.
- Some dungeon drops, quest sources, vendor locations, recipe availability, learning requirements and item bindings rely on Forever-indexed evidence and still need live-server confirmation.
- Account-wide inventory covers saved personal bags and bank snapshots; it does not track mail, auction house, guild banks or account-wide bank storage.
- The newer personal-bank scanning and inventory-browser UI still need further in-client testing.
- Recipe availability and crafting capabilities of offline alts are not yet tracked.
- The addon is a **beta**, not a fully verified guide for every item or server build.

## What's new in v0.12.10

- Corrected four level-25 leather helms previously misidentified as trainer-taught crafts; their documented dungeon-drop sources no longer add crafting materials.
- Preserved the separate crafted level-20 leather hoods and their patterns.
- Fixed acquisition text being truncated at punctuation, including descriptions containing **Mr. Smite**.
- Retained prior gear-data, UI, inventory and crafting-description corrections.

See the [v0.12.10 release](https://github.com/magicaddons/getgear/releases/tag/v0.12.10) for the downloadable build.

## Feedback and bug reports

If you find an incorrect item, source, crafting requirement, recommendation or UI issue, please [open a GitHub issue](https://github.com/magicaddons/getgear/issues).

Helpful details include:

- GetGear version, character class, specialization and level
- Item name and item ID, if available
- What the addon shows versus what you expected
- An in-game screenshot or tooltip when possible
- Lua error text, if one appears

For account-inventory discrepancies, include the character/realm, expected item counts and whether the discrepancy persists after a reload or restart.

---

*GetGear is a community addon project and is not an official World of Warcraft or Blizzard product.*
