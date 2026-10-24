GETGEAR v0.12.10 BETA - DUNGEON HELM AND SOURCE TEXT FIXES
==============================================

A World of Warcraft: Forever Alliance gear progression and crafting-planning
addon. Supports all nine classes and levels 1-30.

INSTALL
-------
1. Exit WoW.
2. Back up your current GetGear folder and SavedVariables if desired.
3. Replace Interface/AddOns/GetGear with this package's GetGear folder.
   Do not keep an old WoWForeverGearGuide addon folder alongside it.
4. Start the game, and use /getgear to open the detailed guide.

ACCOUNT INVENTORY - INTRODUCED IN v0.12.1
----------------------------------
1. Log into your first character. Your ordinary bags will be scanned.
2. Visit your character's bank and allow its tabs to finish loading.
3. Log into your other character(s) and repeat. Cached inventories of
   offline characters are retained as last-known snapshots.
4. Open /getgear > Alt inventory to launch the new searchable browser.
5. Search by item name (or item ID), and click any item to see which saved
   characters hold it, how many they have in their bags/bank, and scan dates.
6. The Scope button cycles through same-realm/faction, current character,
   eligible alts, other realms/factions, all saved characters and each
   recorded character individually.
7. Click Return to guide to resume your normal gear checklist.

The browser covers ALL captured item IDs, not just materials in GetGear's
crafting database. Item names depend on the client item cache and may briefly
show as Item #ID until the client loads their names.

A + beside a number means some character bags/banks in that scope have never
been successfully scanned (or were only partially read). It is a known
MINIMUM, not proof there is nothing more elsewhere. An offline character's
numbers may also be stale. Browse All saved characters is for reference;
items across realms/factions are NOT automatically transferable.

The existing per-material tooltips and diagnostic command remain available:
  /getgear inventory 2589  - show last-known Linen Cloth location totals
  /getgear inventory       - show scan status for cached characters in chat
  /getgear bankdiag        - diagnostic enumeration of bank tab slot IDs

OTHER GUIDE FEATURES
--------------------
- Nine Alliance class guides with spec filters and 404 gear recommendations.
- Recommended, upcoming, skipped, completed and earlier gear categories.
- Source and acquisition notes with map navigation where known.
- Profession skill and recipe information where the client supplies it.
- Crafting materials breakdown and bag count comparisons.
- Detailed-window read-only guide preview for classes/levels 1-30.
- Compact overlay intentionally has NO inventory-browser controls.
- Per-character checklist state stored separately from account inventory.

KNOWN LIMITATIONS
-----------------
- Account inventory and bank snapshots are not a live remote inventory feed.
- No guild bank, account/warband bank, mail, auction house or cross-realm
  transfer validation. The personal bank scan uses Forever's purchased
  character bank tab API and still requires more live-client testing.
- Recipe knowledge/profession skills on offline characters are not yet tracked.
- Some WoW Forever gear acquisition routes remain unconfirmed and labelled.
- The browser is a UI beta: test resizing, long lists, saved snapshots and
  item tooltips before treating it as ready for distribution.
- GetGear v0.12.10 preserves v0.12.0 SavedVariables names and formats.

Please report: character/realm, number of bank tabs, expected item/count,
actual count, whether it persists after completely closing and reopening WoW,
and any Lua errors.

Existing v0.12.2 fixes retained: Inventory browser scrollbar has clearance from the
right-hand detail pane. Older ordinary weapons can move to Earlier Gear
when live DPS, stats, quality, slot type and effect checks safely confirm
they are outclassed. Detailed window dragging is restricted to the title bar,
with cleanup after interrupted drag/resize input. The Alt-Tab cursor issue
remains subject to actual client testing.

GetGear v0.12.3 overlay refinements:
- "TOTAL MATERIALS (INCOMPLETE LIST)" now explains missing recipe data and unscanned saved bank/bag snapshots on hover. Unseen characters cannot be detected.
- Compact objective expansion shows concise source information; the full route and caveats remain in Guide.
- Objectives and Materials scroll frames reserve consistent dark scrollbar gutters.
- Display-settings tooltip now describes conservative ordinary-weapon obsolete filtering.

GetGear v0.12.6 display refinements:
- For mapped crafting objectives, remove duplicate profession/recipe vendor
  text from the compact overlay: the Materials header shows profession/skill
  and the map pin supplies the vendor location.
- Reduce reserved spacing for any remaining brief overlay source/caveat text.
- Give the Account Inventory selected-item detail scrollbar its own dark
  gutter, matching the existing inventory list and compact overlay gutters.
- Full instructions and source caveats remain in the detailed Guide.

Note: UI appearance must still be confirmed in the actual WoW Forever client.


V0.12.6 DATA/INTERFACE CHANGES (23 OCTOBER 2026)
------------------------------------------------
- 14 independently documented Alliance recipe-vendor routes added.
- Recipe teaching corrections and uncertainty classification separated from
  crafting skill-up thresholds; no unsupported trainer level inferred.
- Navigation confidence no longer upgrades Classic-only drop or quest sources.
- Compact overlay removes Acquired/Skip; actions remain in full guide.
- Detailed guide navigation is organised into two logical rows.
- Account Inventory selected panel aligned to the left list top.
- Nested ingredient expansion supports outputCount for future verified yields;
  Healing Potion yield is still disputed, so the current calculation is
  conservative and must be checked in game.
- Existing per-character checklist and account inventory keys unchanged.

IMPORTANT: A source record in the Forever client is not proof of a live
server drop, trainer inventory or reward. This beta is not externally
certified for all 225 item stats, bind rules or acquisition paths.


V0.12.7 DATA INTEGRITY UPDATE (23 OCTOBER 2026)
-----------------------------------------------
- Incorporated researched client-indexed learning-method candidates for 110 recipes,
  including trainer, pattern/plans, initial and disputed/multiple sources.
- A client recipe is NOT proof of current server-side trainer/vendor stock.
- Removed unsupported skill numbers from both structured data and displayed prose.
  Skill-up yellow, green and grey thresholds are not learning requirements.
- Four stat conflicts tracked by item ID. Runtime client comparison wins;
  do not silently overwrite stats using lower values from undated databases.
- No item additions or removals, no changed SavedVariables format.
- Remaining recipe spell IDs, real trainer inventory, drop routes and bindings
  are not certified as fully current without authoritative build/live evidence.


V0.12.8 COMPACT OVERLAY AND ALIGNMENT FIXES (23 OCTOBER 2026)
-------------------------------------------------------------
- Removed duplicate trainer guidance from the expanded compact crafting rows;
  the Materials heading already shows "Leatherworking - Trainer" (and equivalent
  professions) or the learned state. The full Guide retains source details.
- For other crafted gear, suppress source text when the mapped vendor button
  already provides the route. When relevant, retain useful initial-learning
  details, unmapped named vendors, and disputed/Classic-reference caveats.
  Removed generic "Requires a pattern or plans" filler with no acquisition route.
- Aligned the selected item title, totals and note with character details in
  the Account Inventory right panel (8px correction).
- No item/reagent/recommendation/status/SavedVariables data changes.


V0.12.9 PRIVATE TEST BETA - EVIDENCE RECONCILIATION (23 OCTOBER 2026)
-----------------------------------------------------------------
- Removed Ephemeral Grips from Hunter and Rogue recommendations. Caster
  recommendations remain. Rogue Fletcher's Gloves no longer show for Combat
  (Riposte/parry penalty); optional for Assassination and Subtlety.
- Retained Combat Rogue one-handed axes and Ring of Power Regulation for
  Retribution Paladin. No previously saved objective status is deleted.
- Resolved many recipe learning requirements from explicit Forever teaching
  pattern and trainer evidence, without substituting yellow skill-up thresholds.
- Recorded available finished-item binding evidence separately from trainer
  learning evidence; prioritize live client binding when loaded.
- Removed generic pattern/source filler and redundant descriptions from the
  full Guide and compact overlay; preserve meaningful caveats and vendor routes.
- Corrected Dusky Leather Armor, Copper Chain Pants and several pattern
  requirement descriptions; removed unverified Black Slippers trainer map pin.
- Current structured craft data: 127/162 learning minima supported in the
  evidence register, 159/162 binding types linked to indexed Forever sources.
  The remaining 35 trainer minima and 3 binding types are unverified.
- Current Forever client data/indexes are NOT guarantees of launch server
  trainer stock, item stats, dungeon drops, recipe availability or locations.
- No live WoW Forever client tests have been performed on this beta.

RECOMMENDED IN-GAME CHECKS
--------------------------
1. Run /getgear and open the compact tracker on Hunter and Rogue; ensure
   Ephemeral Grips are absent. In Rogue Combat, Fletcher's Gloves are absent.
2. Switch to Rogue Assassination/Subtlety; optional Fletcher's Gloves remain.
3. On Retribution Paladin, verify Ring of Power Regulation still appears.
4. Expand Fletcher's Gloves and a vendor/pattern craft in the tracker;
   no repeated trainer text or generic 'Requires a pattern or plans' filler.
5. In the full Guide, compare Black Slippers, Copper Chain Pants,
   Skulker's Leather Belt and Dusky Leather Armor acquisition details to
   the current in-game UI. Inspect recipe-learning and binding tooltips.
6. Open /getgear > Alt inventory, select a reagent, test alignment and bank
   counts, and check persistence after /reload and a full restart.
7. Record any Lua error and screenshot, character class/spec, item ID, and
   the relevant in-game tooltip when any instruction is incorrect.


V0.12.10 PRIVATE TEST BETA - DUNGEON HELM CLASSIFICATION (23 OCTOBER 2026)
----------------------------------------------------------------------------
- Reclassified level-25 Brawler's (252512), Defender's (252455), Totemic
  (252456) and Wisdom's (252515) Leather Helms as documented dungeon-boss
  drops rather than Leatherworking crafts. They no longer display a trainer
  learning route or demand crafting materials. Exact boss tables/drop chances
  may vary by Forever server build; acquisition confidence remains labelled.
- The separate level-20 Leather Hoods remain crafted via their own patterns.
  Corrected Brawler's Leather Hood text that still mentioned crafted helms.
- Fixed compact noncrafted-source strings truncated after abbreviations or
  ellipses; e.g. "Mr. Smite" and "What Comes Around..." now render fully.
- No new or removed gear recommendations, no changed SavedVariables keys,
  no /gg alias. /getgear remains the only slash command.
- Catalogue: 225 items; 404 recommendations; 158 remaining crafted items.
  Within these 158 crafts, 127 learning minima and 155 binding statuses
  are indexed with source evidence; other values remain unresolved.
- Previously reported v0.12.9 in-game behavior is preserved except for
  the fixes described above. This package has not been run in WoW itself.

FOCUSED IN-GAME CHECKS FOR v0.12.10
---------------------------------
1. Open the Hunter/Rogue/Druid guide at level 25-30: Brawler's Leather Helm
   should say dungeon drop, and no Leatherworking materials should appear.
2. Open Druid/Shaman guides: Totemic/Wisdom Leather Helms should similarly
   be dungeon loot without materials. Defender's Helm is catalogued but
   currently not separately recommended.
3. Expand the level-20 Brawler's/Totemic/Wisdom Leather Hoods: these SHOULD
   still show Leatherworking materials and the pattern/vendor acquisition.
4. Expand Rogue Thief's Blade: full "Mr. Smite in the Deadmines" source
   should appear without being cut off after "Mr.".
5. /reload and confirm saved acquired/skipped/hidden status and Alt inventory
   are unchanged. Screenshot any unexpected recipe banner or item tooltip.
