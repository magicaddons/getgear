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


## Further recovered-source findings — 2026-11-08

The Nov 8 GitHub Actions source-export artifact (run [42465512234](https://github.com/magicaddons/getgear/actions/runs/42465512234)) was recovered before its Nov 15 expiration. Its dated Forever item cache, 2026-10-31 ForeverTome recipe snapshot and EG Link contributed live-client data support a reproducible **local candidate** for the remaining catalogue. This candidate is **not yet committed** to GitHub and is **not** a packaged addon.

- 7,678 dated cache items plus 29 manual-only researched entries = 7,707 unique catalogue identities; 36,341 class/level objectives preserved.
- 1,244/1,244 cache-crafted items have source-derived reagent lists. The existing addon had 1,060 missing lists filled by the local candidate, while **43 existing lists disagreed** with the recovered client recipes and were corrected in the local candidate, with each before/after list separately retained for review. The remainder already agreed.
- **Greater Mystic Wand (#217287)** has two recipes: Forever spell 14810 uses Lesser Mystic Essence; alternate spell 439134 uses Greater Mystic Essence. Candidate uses standard spell 14810, while retaining this caveat in its report. See [Wowhead Forever spell 14810](https://www.wowhead.com/forever/spell=14810/greater-mystic-wand) and [spell 439134](https://www.wowhead.com/forever/spell=439134/greater-mystic-wand).
- 447/554 cache dungeon records have named boss metadata (415 newly populated in a runtime overlay; others already researched), leaving 107 unknown.
- EG player-contributed observation data matched 56 of 1,495 vendor item identities, with 55 new source labels applied in the local candidate; 1,439 remain without an identified vendor.
- EG cached quest records matched 27 of 231 quest-reward item identities; 204 remain without an identified quest. These matches **do not certify Alliance eligibility or live quest availability**.
- Total new candidate metadata references: 1,244 crafted + 447 named dungeon + 56 vendor + 27 quest, including previously researched overlaps. Client item caches do not prove all items are obtainable today.

The generated overlay passed an offline Lua 5.3 load of original Beta 4 modules: 7,707 unique items, 36,341 class objectives and nine classes unchanged, and precisely 43 previously conflicting reagent lists corrected. The generated data still needs integration on a tested development branch, full source review, in-game validation and a separate decision about producing a Beta 7 private test build. Do **not** mark Beta 7 complete or publish it on this basis.

Examples of independently corroborated reagent corrections: [Tough Scorpid Breastplate takes Thick Leather](https://www.warcraftforever.wiki/wiki/Pattern:_Tough_Scorpid_Breastplate); [Veteran's Silvered Chain Shirt uses Coarse Grinding Stone](https://www.wowhead.com/forever/spell=1252267/veterans-silvered-chain-shirt), whereas older GetGear hand-coded values disagreed. These are representative checks, not certification of all 43 changed lists.
