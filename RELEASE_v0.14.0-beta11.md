# GetGear v0.14.0-beta11 — Alliance public beta

The latest recommended GetGear beta for **WoW Forever, Alliance characters, levels 1–60**. This release promotes the user-accepted cumulative `.20261121.14` build (`5b75e2cffe1fa40cd0b17b6472be53d3da53f747`) into `main`. All 29 gameplay Lua modules and all three textures are byte-identical to that accepted build. Only release metadata, documentation and build/workflow safeguards change.

## Download and install

Download **[GetGear-v0.14.0-beta11.zip](https://github.com/magicaddons/getgear/releases/download/v0.14.0-beta11/GetGear-v0.14.0-beta11.zip)** and its [SHA-256 checksum](https://github.com/magicaddons/getgear/releases/download/v0.14.0-beta11/GetGear-v0.14.0-beta11.zip.sha256). Use this installation ZIP, not the automatic source archives.

Exit WoW Forever and back up your addon and SavedVariables. Extract the single `GetGear` folder into `_forever_/Interface/AddOns/`, replacing the old folder. Confirm `_forever_/Interface/AddOns/GetGear/GetGear.toc` exists and enable GetGear. `/getgear` opens the detailed guide; `/getgear overlay` toggles the tracker; `/getgear settings` opens settings. See the [README](https://github.com/magicaddons/getgear/blob/v0.14.0-beta11/README.md) for usage.

## Included improvements

- Compact overlay layout polish, removal of redundant recommendation headings and tighter item-header spacing.
- Shared star textures, immediate wishlist sorting and counts, wrapped row actions and correct hidden-row refreshes.
- Systemic Alliance acquisition access: Ragefire Chasm and other Horde-capital routes are excluded from normal Alliance recommendations. Valid documented alternatives remain eligible; saved stars cannot bypass access checks.
- Earlier accepted tracking, equipment-slot filtering, stat comparisons/priorities, performance, inventory, crafting materials, recipes and map navigation remain intact.

## Validation and limitations

The complete existing cumulative regression gate runs against the source and extracted installation payload on Lua 5.1 and Lua 5.4, with feature-contract checks, startup simulations, acquisition/faction/catalogue audits, generator checks and release safeguards. The protected 17-file acquisition snapshot remains exact. Release packaging is deterministic and records the integrated source commit in BUILD_INFO.txt.

User acceptance was performed on the cumulative private build. No fresh in-game testing is claimed. This is beta software: current live loot, quests, recipes, vendor stock and coordinates can remain uncertain. Horde gameplay/acquisition and other clients are unsupported. Offline inventory is a last-known snapshot. Existing cumulative SavedVariables use the same schema; upgrades from v0.12.x can reset older character settings/progress, so keep backups.

[Report bugs or unexpected recommendations](https://github.com/magicaddons/getgear/issues) with version, class/level, faction, item ID/name, expected/actual behaviour and any Lua error or screenshot.

No project-wide software license is present. Public download and installation are owner-authorized; no new open-source license or broader modification/redistribution rights are granted. Referenced game names and data retain their respective owners' rights.

Beta 10 remains available as an earlier release. Beta 11 is a GitHub pre-release and the recommended download in the repository README; GitHub reserves its automatic “Latest” stable-release designation for non-prereleases.
