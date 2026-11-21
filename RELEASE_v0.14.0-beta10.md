# GetGear v0.14.0-beta10

Public release of the cumulative build accepted by the user in WoW Forever: private `.20261121.12`, source `f248b098a60beef89d8e3112dba19fa0b329905f`. All 29 gameplay Lua modules and all three bundled textures are byte-identical to that build. Release preparation changes only version metadata and public documentation.

## Download and install

Download **[GetGear-v0.14.0-beta10.zip](https://github.com/magicaddons/getgear/releases/download/v0.14.0-beta10/GetGear-v0.14.0-beta10.zip)** from Assets. Exit WoW Forever, back up the previous addon and SavedVariables, then extract the **GetGear** folder into `_forever_/Interface/AddOns/`. Confirm `_forever_/Interface/AddOns/GetGear/GetGear.toc` exists and enable GetGear in the game. Type `/getgear` to begin.

Supported client: **WoW Forever, addon interface 16001**. Use the installable ZIP rather than GitHub's automatic source archives. A companion `.sha256` file verifies the download, and the package includes a per-file manifest and checksums.

## Features and recent improvements

- Level 1–60 gear browsing for all nine original classes and both factions, with equipment-slot views, faction-aware acquisition leads, comparisons and optional stat priorities.
- Compact adjustable tracker, progress actions, crafting/material planning, quest/vendor bag objectives, map directions and saved account inventory.
- Faster overlay calculations within refreshes, retaining the accepted recommendation and material behaviour.
- Indexed equipment search by name or item ID, focused item details and character-specific starred wishlists.
- Shared outline/filled star textures in the guide, tracker and search; immediate wishlist reordering and count updates.
- Improved long-name wrapping and row action placement, with corrected refreshes when hidden rows return after filtering or resizing.
- All cumulative inventory refresh, tracking, navigation, eligibility, recipe evidence and settings fixes retained.

## Upgrade and usage

Use `/getgear overlay` for the tracker and `/getgear settings` for display and stat preferences. Click the tracker's magnifying glass to search and click stars to manage your wishlist. Expand rows for source/material details and use acquired, skip or hide actions to manage progress. Stars do not bypass known eligibility restrictions; Preview Guide remains read-only.

The cumulative build's SavedVariables schema is unchanged. Migration from v0.12.x can reset older per-character progress and display settings; keep backups. Alt Inventory requires logging into each character and opening its personal bank to refresh snapshots.

## Scope and verification

The user reports successful in-game acceptance of the private build. Publication adds no gameplay changes. Release verification runs the existing integrated regression gate against the extracted installation package on Lua 5.1 and Lua 5.4, including all modules, startup simulation, stars, overlay, tracking, maps, inventory and the protected acquisition snapshot. No fresh in-game testing is claimed.

This remains a public beta: the catalogue is not a best-in-slot ranking, and published data does not guarantee live item availability, loot, vendor stock, quest access, recipes or coordinates. Offline inventory is a last-known snapshot; mail, auctions and guild/account banks are not automatically tracked. Other game clients are unverified.

No project-wide software license was present in the approved source. Public download and installation are owner-authorized; no new open-source license or broader modification/redistribution rights are inferred. See the packaged README for licensing information.

[Full installation and usage guide](https://github.com/magicaddons/getgear/blob/v0.14.0-beta10/README.md) · [Report an issue](https://github.com/magicaddons/getgear/issues)
