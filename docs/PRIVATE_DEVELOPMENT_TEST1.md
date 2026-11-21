# GetGear — PRIVATE DEVELOPMENT TEST 1

Version: **0.14.0-private-test1.20261113**. World of Warcraft Forever, interface 16001.
For private in-game acceptance only. This is neither Beta 8 nor a public release.

## Install and identify

1. Exit WoW completely. Back up `Interface/AddOns/GetGear` and the account and
   character `WTF` SavedVariables for GetGear. Preserve your existing progress.
2. Extract the single `GetGear` folder from this private ZIP into
   `_forever_/Interface/AddOns/`, replacing the old addon folder after backing it up.
   Do not install two GetGear copies or rename the folder: its icon path and
   SavedVariables identifiers intentionally remain `GetGear`.
3. Confirm `_forever_/Interface/AddOns/GetGear/GetGear.toc` exists, without an
   extra nested folder. The addon list must say **GetGear (PRIVATE TEST 1)** and
   its TOC version must be `0.14.0-private-test1.20261113`.
4. Enable Lua error reporting (`/console scriptErrors 1`), log in, and run
   `/getgear status`, `/getgear`, `/getgear overlay`, and `/getgear settings`.
   No new migration is introduced. Existing schema-4 progress/settings should
   persist. Keep backups, especially if coming from the older 0.12.x schema.

`BUILD_INFO.txt` records the exact development source commit. `MANIFEST.json`
and `SHA256SUMS.txt` describe the installed payload. No other addon or TomTom
is required; only normal Forever-client/Blizzard UI APIs are used.

## Acceptance checklist, in priority order

Use the compact overlay and detailed guide side by side. The lookup command
`/getgear map ITEMID` uses the same resolver even when an item is not visible
for your current class/level; it does not change eligibility.

- [ ] **Startup and overlay:** no Lua errors; normal guide, settings and overlay
  open. A single compact gold pin fits the existing row without overlapping
  item name, upgrade comparison, hide or minimize controls. Hover explains
  the destination and keeps source uncertainty visible.
- [ ] **Vendor and multiple sources:** `/getgear map 2506`. Choose different
  Hornwood Recurve Bow merchants, including later chooser pages. Left-click
  navigates or selects a source; right-click offers alternatives. The chosen
  label/location agrees with the guide; repeated clicks replace the old target.
- [ ] **Simple quest:** `/getgear map 263329` (Flutterfly Swatter). Confirm the
  named source/zone and qualified written fallback where precise data is absent.
- [ ] **Chain, progress, different start/turn-in and dungeon quest:**
  `/getgear map 2042` (Staff of Westfall). Unknown progress uses the published
  Gryan/Westfall start; inspect quest 65's Wiley/Redridge turn-in separately.
  With a researched stage actually active/completed, verify the chosen next
  step against your quest log. Distinguish the VanCleef dungeon objective from
  Gryan's starting/turn-in role. Unknown prerequisites must remain qualified;
  completed does not mean a particular reward was acquired.
- [ ] **ACA/currency/reputation:** `/getgear map 250513` and
  `/getgear map 220606`. Check Stondry/Alynsia, Redridge, Merchant's Favor and
  the published Honored requirement. Distinguish buying/learning the recipe
  from crafting the equipment. Do not assume current stock/access from a pin.
- [ ] **Limited recipe and trainers:** `/getgear map 5780` shows named recipe
  vendors and limited-stock qualifications. `/getgear map 2844` and
  `/getgear map 2845` show Alphonse Dumas trainer destinations and learning
  skills 15/20. Learning skill, wearer level and published fee remain distinct.
- [ ] **Dungeon boss and recipe:** `/getgear map 1155` uses the Blackfathom
  Deeps entrance with Kelris guidance. `/getgear map 252455` keeps the
  Blackfathom/Razorfen Kraul recipe possibilities separate; it must not claim
  the finished helm drops. Use written guidance if a native entrance cannot
  be resolved; no guessed boss-floor marker.
- [ ] **Rare and objects:** `/getgear map 1404` uses Prince Nazjak's Arathi
  area, not an invented exact spawn. `/getgear map 18706` and
  `/getgear map 9359` keep Arena Master / Captain's Chest, key and physical
  footlocker context distinct. Check NPC/object name and actual map region.
- [ ] **Honest negative cases:** item 1713 (Ankh of Life) has no dedicated
  random-drop farm pin. Item 273884 retains unresolved location information;
  no precise marker should be fabricated. Outside candidate 285066 has not
  been added to the current catalogue.
- [ ] **Lifecycle and native map:** start with a native user waypoint. Alternate
  at least 20 pins; change zones/maps/floors, return, zoom/resize, close with
  Escape/map toggle, reopen, and accept/complete a quest. Require one correct
  labelled addon marker/area, no stale or accumulated markers, normal closing,
  and unchanged native quest markers and user waypoint. Retry in combat;
  safe written directions should replace unsupported map actions.
- [ ] **Filtering and persistence:** positive-stat filtering, armour-only opt-in
  (default off), default-hidden green world BoEs, class/level/body-armour rules,
  level-40 mail/plate transitions, acquired/skipped/hidden state and preview
  remain consistent. The full guide stays available. Change a harmless setting
  and `/reload`; confirm it and existing progress persist.
- [ ] **Recipes/materials and inventory:** compare ingredient quantities and
  tracked/all material scopes before/after navigation. No recipe, reagent or
  completion state should change from clicking a pin. Account/alt inventory
  remains a last-known snapshot. Preview all nine classes; actual character
  class/faction and quest state must still govern applicable source choices.

## What the offline checks cannot establish

Actual client startup/rendering, frame templates, native entrance coverage,
secure/combat restrictions or taint, map scaling/clipping, other-addon
interactions, real quest progression, NPC presence, stock, fees, loot, unlocks
and availability need in-game testing. A published location is not live proof.

The completed catalogue remains 7,707 IDs / 36,341 class objectives / 1,254
crafts / 4,857 ingredient rows. Navigation audit: 885 published point-data
items, 1,581 directions, 3,085 missing actionable locations and 2,156 not
applicable. No actual-client rendering was verified during packaging. Six
specific dungeon links and 954 book-route live checks remain qualified.
The 900 outside-catalogue baseline candidates are not adopted.

For a failure, record this test version and `BUILD_INFO.txt` source commit,
client build/locale, class/level, item ID, chosen source/quest state, expected
versus actual result, screenshot and full Lua error/stack if present. Record
other enabled addons. Do not treat an unread source or an omitted table row
as evidence that the item is retired. Stop toward release until these tests
are reviewed; no public release, tag or merge is authorized by this package.

## Package and provenance notes

All 26 gameplay Lua files, the map-pin asset and data model come from the
recorded committed source. Packaging alone replaces TOC title/version/notes,
adds private source metadata and uses this file as the installed `README.txt`.
`SOURCE_CREDITS.txt` preserves the repository's source attribution text.
No gameplay code, source qualifications, class filters or catalogue data are
changed by those metadata/instruction substitutions. Folder and SavedVariables
names are unchanged. This ZIP is supplied privately through the task workspace;
it is not uploaded as a GitHub release, tag or public binary asset.
