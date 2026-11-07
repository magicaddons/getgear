GETGEAR v0.14.0 BETA 4 — UNIFIED ALL-CLASS 1–60 GUIDE
====================================================
PRIVATE TEST BUILD ONLY. Public/stable v0.12.14 is unchanged.

WHAT THIS ADDON DOES
--------------------
GetGear lists Alliance equipment that your class can equip across levels 1–60,
with sources, craft materials, quest/dungeon leads, a movable compact tracker
and a full detailed guide. It is an equipment information tool, not a
best-in-slot list or a prescriptive build recommendation engine.

HOW TO INSTALL
--------------
1. Exit WoW Forever completely.
2. Optional: copy your existing _forever_/Interface/AddOns/GetGear folder
   outside AddOns, and back up GetGear's WTF SavedVariables.
3. Replace that AddOns/GetGear folder with this ZIP's GetGear folder.
   Avoid nested GetGear/GetGear and duplicate addon folders.
4. Start WoW Forever. Type /getgear. Do NOT use /gg.

BETA 4 FORMAT CHANGE: Old acquired/skipped/hidden objective progress will
reset once on first login. Display preferences also reset. The separate
account-wide bags/bank ledger is not intentionally cleared. Roll back to
v0.13.0-beta3 or stable v0.12.14 only after quitting WoW.

DESIGN AND FILTERING
--------------------
- No manual specialization selector, spec-specific preview, or /getgear spec.
- One unified item catalogue, independent class proficiency masks and a
  single set of presentation filters for every item, regardless of source.
- At character level 15, target levels 10 and lower move into Earlier Gear,
  11–15 are Available Now, and 16–20 are Upcoming. This recalculates on level.
  Known quest-chain acquisition requirements may raise the practical target.
- Default relevance excludes obvious spell-only cloth on Warriors, test/QA
  records, holiday costume hats, unverified generic world-drop listings, and
  items with undocumented sources. Utility, resistances, Hunter Intellect
  and hybrid options remain broadly available.
- Mage only: read the COMMITTED Forever C_Traits group points. If Fire, Frost
  or Arcane clearly dominates, a modifier that provides damage ONLY for a
  different one of those schools is suppressed. Items with useful generic
  spell power, healing, intellect or mixed benefits are never school-blocked.
  If the APIs/talent split are ambiguous, the guide fails OPEN.
- "Show all valid equipment" opts into older/off-build/novelty candidates,
  but NEVER developer/QA placeholder items.
- Personal "Hide crafted gear I can't make" toggle is separate, OFF by
  default; recipes and materials are indexed even if another character
  will craft the item.
- Detailed Guide: Earlier Gear, Available Now, Next 5, Completed/Skipped,
  Hidden and Bags. Preview browses all nine classes at levels 1–60.
- Compact tracker is capped at 32 items; detailed pages at 40 items.
- Maps, materials, bag upgrades, and account inventory remain supported.

IMPORTANT DATA LIMITATIONS
--------------------------
The broad Forever item-cache snapshot is from 21 October 2026 and does not
prove all 7,707 indexed items can be obtained in the live game. Unconfirmed
quest, dungeon, vendor or recipe routes remain marked as such. The 259
researched item facts include updates through launch, but are not universal
evidence of source availability. Report incorrect entries with item IDs,
your class and current level.

COMMANDS
--------
/getgear             Open/close the detailed guide
/getgear overlay     Toggle compact tracker
/getgear settings    Open display options
/getgear status      Show catalogue and auto talent-detection diagnostics
/getgear notify      Toggle verified-source level notifications
/getgear inventory   Show account inventory diagnostics
/getgear bankdiag    Inspect Forever bank container IDs

TESTING
-------
Read BETA_0140_NOTES.txt for focused regression checks. No public release,
merge or stable tag was created for this beta.
