GETGEAR — CUMULATIVE PRIVATE TEST BUILD
Version: 0.14.0-private-cumulative.catalogue-audit.20261125.1

Complete accepted Beta 11 baseline plus the preserved overlay idle/group changes,
the Alt Inventory identity/snapshot fix and reviewed catalogue/commerce corrections.
Includes 32 Lua modules, three textures and the accepted historical data snapshot.
Alliance characters remain the supported gameplay scope. Native Forever acceptance
is pending; no public release or mainline merge is part of this testing build.
Install the complete supplied private ZIP using the instructions below.

Tracker group menu: All (starred first), Starred, or Other (non-starred).
Pages are independent per group. Slot filters apply to every group.
Inventory scope: same-realm/faction uses recovered identity; unresolved records
remain available in Other / unknown, All and individual scopes. Scope choices
remain transient and reopening starts at Same realm/faction.
Catalogue: corrected published names/levels/titles, shared commerce access and
qualified coordinates. Published evidence does not prove live loot or stock;
research gaps, disputed skill requirements and unknown identity remain explicit.

SUPPORTED CLIENT
WoW Forever, addon interface 16001. Other clients are not verified.
Levels 1–60, class-equippable gear and acquisition planning for Alliance characters.

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
- Alt Inventory shows recorded bags/banks immediately. Existing banks need no
  revisit to recover sufficient legacy metadata; login can establish a missing
  faction. Open a bank only when you want to refresh its contents. Offline counts
  are last-known snapshots, not live access.
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
Private testing build. Catalogue/source information can be dated, incomplete or uncertain;
it does not guarantee current loot, vendor stock, quests, recipes or coordinates.
This is not a best-in-slot ranking. Bank snapshots can become stale; mail,
auctions and guild/account banks are not automatically tracked. This combined build awaits in-game acceptance. Automated Lua compatibility/regression tests
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
