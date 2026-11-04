# GetGear v0.12.11 Beta — pre-launch data update

This beta updates WoW Forever 1–30 gear guidance using identified teaching items in client build **1.60.1.70755** and Blizzard's November 2 development notes.

## What's new

- **Four level-25 Leather Helms:** Brawler's, Defender's, Totemic and Wisdom's now document both their existing finished-item dungeon-loot route and an **optional Leatherworking 125 pattern** route. Patterns have item IDs **252814, 252816, 252817, 252819**, respectively. Pattern boss locations remain unverified. Optional crafting ingredients are not added to the default Materials totals.
- **Four level-20 Leather Pants:** Defender's, Trapper's, Stormrider's and Wisdom's now point to **Leatherworking 100** pattern items, rather than assuming they are trainer-taught.
- **Three level-25 Chain Helms:** Protector's, Acolyte's and Crusader's now point to **Blacksmithing 125** plans items instead of trainer instructions. These are **not** the ACA Silvered Chain Helms.
- Fixed misleading trainer/ACA source directions for these seven crafted items and retained the separately crafted leather Hoods.
- Updated installation notes for the **live `_forever_` client**.

## Checked and intentionally left unchanged

Blizzard mentioned revised quest item levels and some early caster rewards, but the notes did not give the exact affected low-level item IDs or new values. The reviewed pre-launch item changes did not substantiate changes to GetGear's specific ACA vendor offerings or prices. We have therefore **not guessed new quest stats, CASA/ACA prices, or reward sources**. Live item tooltips take precedence where supported.

**Unchanged:** 225 catalogued items, 404 recommendations across nine classes and 37 spec views, 158 mandatory-craft material lists, inventory logic, SavedVariables keys, and the sole slash command `/getgear`.

## Compatibility and testing

- **Offline-tested:** All 32 Lua modules, 404 recommendations, 37 spec views, all corrected pattern routes, status persistence, equipment source classifications, material calculations and clean installation ZIP extraction.
- **Not live-tested in the launch client:** Actual dungeon-pattern boss drops, ACA prices, client bank scanning and interface behavior require an in-game check once the servers open.
- Previous [v0.12.10 Beta](https://github.com/magicaddons/getgear/releases/tag/v0.12.10) remains available as a fallback.

## Installation

Download **`GetGear-v0.12.11-private-test-beta.zip`** from **Assets**. Extract its **GetGear** folder into your live WoW Forever client's `_forever_/Interface/AddOns/` directory. Open the addon with **`/getgear`**. Make a backup of SavedVariables before updating if desired.
