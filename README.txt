GetGear v0.14.0-beta9 — Public Testing Release
==============================================
Gear planning and acquisition guidance for WoW Forever, levels 1–60.
Alliance remains the documented route focus; known source restrictions and
uncertainties are preserved. This is a public beta, not a stable release.

INSTALL OR UPGRADE
------------------
1. Exit WoW Forever completely.
2. Back up the existing Interface/AddOns/GetGear folder outside AddOns, and
   back up GetGear account/character SavedVariables in WTF. Keep your progress.
3. Extract the ZIP's single GetGear folder into Interface/AddOns. Move the old
   addon folder out first so files from earlier tests do not remain behind.
4. Confirm Interface/AddOns/GetGear/GetGear.toc exists without extra nesting.
   Do not install multiple GetGear copies simultaneously or rename the folder.
5. Launch the game, enable GetGear and use /getgear. Settings are available at
   /getgear settings; /getgear overlay toggles the compact tracker.

The AddOns version should be 0.14.0-beta9. No new SavedVariables migration is
introduced relative to the tested v0.14.x builds. Retain backups when upgrading
from older versions. GetGear requires no TomTom or other third-party addon.

WHAT'S IMPROVED
---------------
- Class-aware equipment permissions and stat/school filtering, with Show-all
  still available for unusual but class-equippable choices.
- Cleaner compact acquisition and recipe instructions; full alternatives and
  requirements remain in the Guide.
- Context-sensitive map pins, delayed map readiness handling, useful published
  dungeon approaches, source choices and preserved native waypoints.
- Recipe learning requirements, specialisations, reputation/currency/material
  costs and potential offhand planning while using a two-handed weapon.
- All 7,707 items included in the presentation audit. The approved catalogue
  and acquisition dataset are unchanged from PRIVATE TEST 4.

PLEASE HELP TEST
----------------
Report problems at https://github.com/magicaddons/getgear/issues
Include version, class/level, affected item name/ID, relevant settings, expected
and actual result, screenshot and any full Lua error. /console scriptErrors 1
can help capture errors. Do not farm an uncertain source solely to verify it.

KNOWN LIMITATIONS
-----------------
Some recipe-learning sources, locations and current acquisition conditions
remain unverified. Published map areas are not exact current NPC positions;
dungeon approaches are not boss-floor coordinates or a guarantee of access.
Current vendor stock, loot, quest access, map behaviour and client interactions
still need community testing. Unknown sources remain explicitly qualified.
Automated checks and the user's private in-game testing do not confirm every
route, class, client state or other-addon interaction. The 900 held candidates
have not been added.

SOURCE CREDITS
--------------
Everloot: https://everloot.app — community observation data, CC BY-SA 4.0
https://creativecommons.org/licenses/by-sa/4.0/
Everloot-derived reference data is adapted/combined and remains subject to
CC BY-SA 4.0. Observations do not imply guaranteed future loot or rates.
Playfulls: https://playfulls.com/database — public community source references;
https://playfulls.com/methodology
WoW Forever Friends: https://www.wowforeverfriends.org — Classic-reference
item/NPC data, not proof of current Forever acquisition.
Forever client cache: https://github.com/Napalmsteak/WoW-Classic-Item-Caches
Recipe/client references: AHledger and the dated client snapshots documented
in the repository. Individual publication checks cite Wowhead Forever and
other source URLs in the reviewed evidence registers. No Blizzard affiliation.
