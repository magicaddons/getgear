# GetGear v0.14.0 Beta 8 — acquisition research and tracker improvements

A consolidated **public beta / prerelease** for WoW Forever, with Alliance as the supported route focus. This is a testable checkpoint, not a claim that every indexed item is currently obtainable.

## What's included

- **2,177 conservative acquisition summaries**, including individually reviewed metadata for **954 recipe-book cases and 214 other equipment cases**. The detailed guide provides named enemies/merchants, locations, quest and object directions, fishing leads, costs, requirements and alternatives where evidence supports them.
- Book acquisition remains separate from finished-gear drops and crafting ingredients. Individual reputation, quest and slot-specialisation gates are preserved; same-name item versions are kept distinct.
- Explicit warnings for unavailable-page flags, Season of Discovery/cross-version records and unresolved origins. Published references remain labelled; no invented drop rates or guaranteed vendor stock.
- Compact tracker filtering for positive stat changes, optional armour-only improvements and default-hidden green world BoEs. Full guide coverage remains available.
- Corrected crafted **Idol of the Dream** and clearer dungeon boss/trash/rare/container distinctions. Nine-class eligibility, existing settings, recipe ingredients and guide functionality retain regression protection.
- **7,707 equipment IDs**, **36,341 class objectives**, **1,253 runtime crafts /4,855 ingredient rows**; no new SavedVariables schema migration in this beta.

## Install or upgrade

Download **GetGear-v0.14.0-beta8.zip** from this release's Assets. Exit the game, back up the existing addon folder and WTF SavedVariables, then replace the old `GetGear` folder under `_forever_/Interface/AddOns/`. Confirm `GetGear/GetGear.toc` exists without an extra nested folder. Open with `/getgear`.

Upgrading from v0.12.x to the v0.14.x catalogue can reset old character progress/display preferences; keep backups. Beta 7 users receive this consolidation without a newly introduced schema reset.

## Validation and limits

Python compilation/full source reconciliation, all **24 Lua modules** and all **14 regressions** passed locally and in [GitHub validation](https://github.com/magicaddons/getgear/actions/runs/42602679107). Inspected validated code commit: `a907d939aea29fa9683a740514c4a8171b1318e3`. The ZIP is checked for its exact module/support-file manifest and matching committed bytes; a SHA256 checksum is supplied.

**Six dungeon source links and 954 current recipe-book routes still need live verification.** Some indexed entries are explicitly flagged unavailable or cross-version; other gear origins and current eligibility remain unknown. Full in-game UI, item-cache, quest/script, vendor-stock, map and settings acceptance still requires testing. Automated tests and community observations do not guarantee future loot/stock or certify every route. This is a beta, not a release candidate or stable release.

[Current evidence/release gate](https://github.com/magicaddons/getgear/blob/v0.14.0-beta8/docs/source-audit-1-60/RELEASE_GATE.md) · [Project instructions](https://github.com/magicaddons/getgear/blob/v0.14.0-beta8/README.md) · [Report an issue](https://github.com/magicaddons/getgear/issues)
