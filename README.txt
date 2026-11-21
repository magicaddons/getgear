GETGEAR 0.14.0-private-cumulative.20261121.13 — PRIVATE UI TEST
==========================================================
Separate testing follow-up to public v0.14.0-beta10. Not a public release.
The overlay group headings are removed and the item identity area moves up
2 pixels. All other 28 Lua modules and all three textures are unchanged from
public source efe67f9d9a75daf85545d9dda37b0c238d638010.
Back up the public version before installing this testing ZIP. The same folder
layout and SavedVariables schema apply. This follow-up needs user approval
before publication; the existing public Beta 10 remains unchanged.

DOWNLOAD
https://github.com/magicaddons/getgear/releases/tag/v0.14.0-beta10
Public download above is the unchanged Beta 10. Install the supplied distinct
private testing ZIP to test this overlay refinement; do not use source archives.

SUPPORTED CLIENT
WoW Forever, addon interface 16001. Other clients are not verified.
Levels 1–60, all nine original classes, both factions.

INSTALL / UPGRADE
1. Exit the game. Back up AddOns/GetGear and GetGear SavedVariables in WTF.
2. Extract the ZIP and replace the GetGear folder in _forever_/Interface/AddOns/.
3. Confirm _forever_/Interface/AddOns/GetGear/GetGear.toc exists; no nesting.
4. Start the game, enable GetGear in AddOns, and type /getgear.
Use your actual Forever install path. Cumulative-build settings/stars/progress
retain the same schema. Migration from v0.12.x can reset older character
progress/preferences; keep backups. Account inventory is saved snapshots.

BASIC USE
- /getgear opens/closes the guide; /getgear overlay toggles the tracker.
- Browse Available Now, Next 5 Levels, Earlier Gear and equipment slots.
- Click the tracker's magnifying glass; search by item name or ID.
- Click outline/filled stars to add/remove character-specific wishlist items.
  Starred Items appear first; stars do not bypass eligibility restrictions.
- Expand rows for acquisition and crafting details. Mark acquired, skip or hide
  items with row actions. Resize the tracker and expand/collapse its sections.
- /getgear settings opens display options and stat priority preferences.
- Use map actions for supported sources, choices and directions.
- Browse Alt Inventory after logging into each character and opening its bank.
  Offline counts are last-known snapshots, not live access.
- Preview Guide is read-only for other classes/levels and does not edit stars.

OTHER COMMANDS
/getgear status       Catalogue/talent diagnostics
/getgear inventory    Account inventory diagnostics
/getgear bankdiag     Bank container diagnostics
/getgear notify       Toggle source-aware level notifications

RECENT IMPROVEMENTS
Overlay computation improvements; indexed equipment search; shared star
textures; immediate wishlist reordering/counts; wrapped row actions and hidden
row refresh corrections. Earlier cumulative tracking, inventory, navigation,
class/faction eligibility, stat priorities and settings fixes remain included.

LIMITATIONS
Public beta. Catalogue/source information can be dated, incomplete or uncertain;
it does not guarantee current loot, vendor stock, quests, recipes or coordinates.
This is not a best-in-slot ranking. Bank snapshots can become stale; mail,
auctions and guild/account banks are not automatically tracked. User acceptance
was reported for the private build. Automated Lua compatibility/regression tests
do not constitute new in-game verification or exhaustive live route testing.

LICENSING
No project-wide software license was present in the approved source. This
owner-authorized release permits public download and installation; no new
open-source license or broader modification/redistribution grant is added.
Third-party game names and referenced data retain their respective owners'
rights. Contact the project owner for licensing questions.
GetGear is a community addon, not an official Blizzard product.

HELP / RELEASE NOTES
https://github.com/magicaddons/getgear
https://github.com/magicaddons/getgear/issues
Include addon version, class/level, item ID/name, symptoms and any Lua error.
