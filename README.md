# GetGear

An in-game gear catalogue, crafting planner and item tracker for **World of Warcraft Forever**, covering levels **1–60**, class-equippable gear for **Alliance characters**. Horde gameplay and acquisition routes are outside the supported beta scope.

## Download

[Download GetGear v0.14.0-beta11](https://github.com/magicaddons/getgear/releases/tag/v0.14.0-beta11) · [Direct installable ZIP](https://github.com/magicaddons/getgear/releases/download/v0.14.0-beta11/GetGear-v0.14.0-beta11.zip) · [Release notes](https://github.com/magicaddons/getgear/blob/v0.14.0-beta11/RELEASE_v0.14.0-beta11.md)

Choose **GetGear-v0.14.0-beta11.zip** under Assets. GitHub's automatic “Source code” archives are development snapshots and are not the installation package.

This is the **latest recommended public beta**. It preserves the cumulative private build `.20261121.14` accepted by the user in WoW Forever (`5b75e2cffe1fa40cd0b17b6472be53d3da53f747`). Release preparation changes version metadata and documentation only; the Lua modules and bundled textures are unchanged. Broad source coverage still includes uncertain acquisition information.

## Supported client

WoW Forever, addon interface **16001**, is the supported client. Compatibility with Retail, other Classic versions or other private-server clients has not been established.

## Installation and upgrades

1. Exit WoW Forever completely. Back up your existing `GetGear` folder and GetGear SavedVariables under `WTF` before upgrading.
2. Download and extract the release ZIP.
3. Copy its single **GetGear** folder into `_forever_/Interface/AddOns/`, replacing the previous GetGear folder. Use your actual WoW Forever installation path.
4. Confirm `_forever_/Interface/AddOns/GetGear/GetGear.toc` exists. Avoid a nested `GetGear/GetGear` folder or duplicate copies.
5. Start the game, enable GetGear in the AddOns list, and type **`/getgear`**.

Existing cumulative-build settings, stars and progress use the same SavedVariables schema. Upgrading from v0.12.x can reset older per-character acquired/skipped/hidden states and display preferences; retain your backup. Account inventory consists of saved snapshots.

## Basic usage

- Open the detailed guide with `/getgear`, or toggle the compact tracker with `/getgear overlay`. Browse Available Now, Next 5 Levels, Earlier Gear and equipment-slot views.
- Click the tracker's magnifying glass to search equipment by name or item ID. Select a result for details. Click an outline star to add an item to this character's wishlist; click the filled star to remove it. Starred items appear in their own section. Stars do not override equipment or acquisition restrictions.
- Use row actions to mark items acquired, skip or hide them, and expand entries for sources and crafting materials. The tracker supports resizing, wrapping and expandable sections; `/getgear settings` opens its display options.
- Set Balanced, Priority or Advanced stat preferences in settings. Optional filters include positive stat changes, armour-only improvements, ordinary green world drops, crafting ability and bag upgrades.
- Click a map action where supported to inspect acquisition choices and directions. Missing or uncertain coordinates remain qualified.
- Open Alt Inventory to browse last-known bags and personal banks. Log into each character and open its bank to refresh its snapshot. Offline inventory is not live remote storage.
- Preview Guide lets you browse other classes and levels without changing your character's progress or stars.

| Command | Action |
|---|---|
| `/getgear` | Open or close the guide |
| `/getgear overlay` | Toggle the compact tracker |
| `/getgear settings` | Open display settings |
| `/getgear status` | Catalogue and talent diagnostics |
| `/getgear inventory` | Account inventory diagnostics |
| `/getgear bankdiag` | Bank container diagnostics |
| `/getgear notify` | Toggle source-aware level notifications |

## What's included

Class-equippable gear, faction-aware acquisition leads, talent-aware and optional custom stat priorities, crafting recipes and material totals, quest/vendor bag planning, item tooltips and comparisons, map navigation, character-specific stars and saved account inventory. The public package includes every one of the approved build's 29 Lua modules and its map and star textures.

Beta 11 adds the accepted compact-overlay heading removal, tighter item-header spacing and systemic Alliance acquisition filtering (including Ragefire Chasm exclusion while retaining valid alternative sources). It includes cumulative overlay computation improvements, indexed item search, shared outline/filled star artwork, immediate wishlist reordering and counts, corrected wrapped row actions, and hidden-row refresh fixes. It retains the earlier inventory, tracking, navigation, eligibility and settings improvements.

## Limitations and feedback

The catalogue is a planning aid, not a best-in-slot ranking or a guarantee that an item is obtainable. Published sources, vendor stock, quests, recipes, maps and item records can be incomplete, dated or unverified in the live client. Known class/faction/race restrictions apply; unresolved access remains uncertain. Bank snapshots can become stale, and mail, auctions and guild/account banks are not automatically tracked.

User acceptance applies to the tested private build. Automated Lua 5.1/5.4 regressions and startup simulations do not establish fresh in-game verification or validate every class, item and route.

[Report an issue](https://github.com/magicaddons/getgear/issues) with your addon version, class, level, item ID/name, expected and observed behaviour, and any Lua error or screenshot.

## Development and releases

`main` is the latest user-approved production source. Develop on separate branches; integrate through a pull request only after automated validation and user acceptance. Public versions have distinct tags. Private testing packages stay separate, and development pushes never publish public releases. See [the development and build workflow](docs/SOURCE_CONTROL_AND_BUILDS.md).

## Licensing

No project-wide software license was present in the approved source. This owner-authorized release provides the addon for public download and installation; it does not add an open-source license or infer broader modification or redistribution permissions. Third-party game names and referenced data retain their respective owners' rights. Contact the project owner for licensing questions.

GetGear is a community addon and is not an official Blizzard product.
