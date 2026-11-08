# Beta 7 acquisition reconciliation — evidence register (INCOMPLETE)

This branch is **not** a published Beta 7 build. `main` remains unchanged. The staged
`SourceEnrichment.lua` is an overlay so the baseline 259 researched facts and 7,678
cached records can remain byte-for-byte unchanged while evidence is audited.
The complete catalogue contains **7,707 unique item IDs** (some researched
identities overlap the cache). Source corrections must not change item IDs,
wearability masks, minimum equip levels or the unified nine-class index.

## Starting evidence

The user-supplied `GetGear-v0.14.0-beta7-coverage.json` (2026-11-08)
summarised a *previous local, unpublished* Beta 7 candidate, which was not
checked into GitHub and is **not available from the coverage totals alone**.
Counts in that report: 1,244/1,244 crafted items with ingredient arrays,
1,228 crafted learning sources unverified, 1,439 vendor identities unknown,
204 quest identities unknown, and 107 dungeon bosses unknown.
Those counts **do not describe this branch's three-item overlay**.
They should be treated as goals/baseline, not proof of the generated 3,206
local enrichments having been restored.

## Reconciled examples

| Item ID | Item | Acquisition evidence | Confidence and limits |
|---|---|---|---|
| 250513 | Veteran's Chain Belt | Plans item 251365 sold by Stondry Darkhammer (ACA), Redridge Mountains 10.4, 74.7; Blacksmithing 45; four reagents | Published Forever plan & vendor; live vendor stock not personally observed |
| 271098 | Golemguard Chest | Plunder, third boss in Hall of Thanes | Forever Dungeon Journal, not an observed live drop rate |
| 2864 | Runed Copper Breastplate | Blacksmithing spell 2667, 12 Copper Bars, 1 Shadowgem, 2 Rough Grinding Stones; Plans world drop and plan-use threshold 55 in Forever sources | Published Forever client/plan evidence; individual live creature sources unconfirmed; some mirrors retain conflicting old skill figures |

Primary links:
- https://www.wowhead.com/forever/item=251365/plans-veterans-chain-belt
- https://www.wowhead.com/forever/guide/azeroth-commerce-authority-reputation-professions
- https://www.wowhead.com/forever/dungeon-journal/the-hall-of-thanes/plunder
- https://www.wowhead.com/forever/spell=2667/runed-copper-breastplate
- https://www.wowhead.com/forever/item=2883/plans-runed-copper-breastplate
- https://azeroth.wiki/forever/professions/blacksmithing/veteran-s-chain-belt
- https://azeroth.wiki/forever/professions/blacksmithing/runed-copper-breastplate

**Validation:** `lua5.4 tests/beta7-evidence.lua .` after Lua is installed.
The test loads the actual addon manifest and checks nine class catalogues,
item counts, expected reagent sets, route details and source integrity.
Not a substitute for in-client testing.

## Outstanding before calling the full 1–60 reconciliation complete

1. Recover or recreate the unpublished enrichment generator and item-level
   source evidence, not just the JSON coverage summary.
2. Cross-reference current **live** Forever vendor inventories, quest reward
   items, boss drops, world drops and trainer/pattern acquisition; preserve
   data-version dates and licenses.
3. Explicitly separate item sources, *recipe* sources, recipe learn minima,
   profession colour thresholds and item required character levels.
4. Do not invent vendor names, quest NPCs, instance waypoints, drop chances,
   faction access or reputation requirements merely to increase coverage.
5. Generate a new per-item coverage report, test source accuracy and all nine
   classes 1–60, then perform a separate in-game validation.
6. Only after thorough checks consider a private Beta 7 test build; do not
   publish as stable or modify `main`.

This register is intentionally candid about partial progress.
