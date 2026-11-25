# Before-and-after catalogue coverage

Baseline: c600da4fa50ab103ebbfa19f96bf1c6ade586fcf. After: this checkpoint.
Counts describe separate domains; recipes overlap equipment. The runtime has
7,735 distinct item IDs, not a sum of equipment + recipes + sources + quests.

| Measure | Before | After |
| --- | ---: | ---: |
| Distinct item IDs (equipment + bag planning) | 7,735 | 7,735 |
| Equipment records | 7,707 | 7,707 |
| Equipment craft records (overlap equipment) | 1,254 | 1,254 |
| Planning bag records | 28 | 28 |
| Acquisition source entities | 975 | 975 |
| Quest records | 716 | 716 |
| Modeled acquisition routes (equipment + bags) | 7,450 | 7,450 |
| Fully verified equipment records | 0 | 0 |
| Partially verified equipment records | 7,615 | 7,615 |
| Legacy/unverified equipment records | 92 | 92 |
| Exact published material/output matches | 1,222 | 1,254 |
| Unmatched equipment crafting joins | 32 | 0 |
| Missing recipe spell IDs restored in this checkpoint | 0 | 8 |
| Preferred book/spell commerce requirements | 0 | 54 |
| Unresolved guide/book skill contradictions | 54 | 54 |
| Unresolved equipment tooltip responses | 92 | 92 |
| Unresolved enchantment effect contradictions | 1 | 1 |
| Known coordinate conflicts retained | 13 | 13 |
| Geographic conflicts resolved in this checkpoint | 0 | 0 |
| New equipment adopted | 0 | 0 |
| Duplicate runtime records removed | 0 | 0 |
| Acquisition alternatives restored in this checkpoint | 0 | 0 |
| Newly certified incorrect current-game facts | 0 | 0 |

The eight corrections restore missing identity fields, not eight newly proven
incorrect live-game values. One generic cloak-classification defect is also fixed.
All previous accepted corrections remain present. No independent live witness
or current-client measurement was obtained.

Publication material coverage: **1,254/1,254 = 100%** (before 97.45%).
Partial-record coverage: **7,615/7,707 = 98.81%**, meaning at least some supported
fields, never whole-record accuracy. Complete verification: **0/7,707 = 0%**.

Equipment field coverage: **83,529/247,695 applicable fields = 33.72%** have
partial publication support. The explicit schema includes 292,866 total fields
(38 per equipment record), including 45,171 not-applicable craft-domain cells.
The remaining applicable fields are 12,186 legacy/unverified and 151,980 missing
information. Presence of a restriction or effect is not verification of its full
current-game semantics. Every source/quest contributes explicit field rows, and
the 28 bags have a separate field ledger with retained capacity evidence.

Independent discovery: 12,789 distinct published equipment IDs; 3,584 references
of green-or-better quality outside the runtime need individual review. This is
a candidate count, including uncertain versions/factions/placeholders, not a
confirmed missing-obtainable-item count. 240 runtime IDs lack a matched accepted
inventory row. All 900 historical publication-pass holds remain intact. 156,726
raw reference rows include overlapping partitions and variants; not unique gear.

## Equipment coverage by slot

| Slot | Records | Partially verified | Legacy/unverified | Fully verified |
| --- | ---: | ---: | ---: | ---: |
| Back | 4 | 4 | 0 | 0 |
| Chest | 854 | 839 | 15 | 0 |
| Feet | 772 | 757 | 15 | 0 |
| Hands | 760 | 745 | 15 | 0 |
| Head | 604 | 589 | 15 | 0 |
| Legs | 752 | 736 | 16 | 0 |
| Main Hand | 515 | 514 | 1 | 0 |
| Neck | 145 | 145 | 0 | 0 |
| Off Hand | 339 | 339 | 0 | 0 |
| Ranged | 142 | 142 | 0 | 0 |
| Relic | 57 | 57 | 0 | 0 |
| Ring | 325 | 325 | 0 | 0 |
| Shoulder | 643 | 628 | 15 | 0 |
| Thrown | 1 | 1 | 0 | 0 |
| Trinket | 149 | 149 | 0 | 0 |
| Two-Hand | 1 | 1 | 0 | 0 |
| Two-Hand Axe | 88 | 88 | 0 | 0 |
| Two-Hand Mace | 82 | 82 | 0 | 0 |
| Two-Hand Polearm | 44 | 44 | 0 | 0 |
| Two-Hand Staff | 124 | 124 | 0 | 0 |
| Two-Hand Sword | 75 | 75 | 0 | 0 |
| Waist | 645 | 645 | 0 | 0 |
| Wand | 57 | 57 | 0 | 0 |
| Wrist | 529 | 529 | 0 | 0 |

## Equipment coverage by class

Memberships overlap: an item can be shared by several classes. These are not
additional unique items, and a preview class/faction is not proof of a native
character combination.

| Class | Records | Partially verified | Legacy/unverified | Fully verified |
| --- | ---: | ---: | ---: | ---: |
| DRUID | 3,851 | 3,844 | 7 | 0 |
| HUNTER | 5,004 | 4,996 | 8 | 0 |
| MAGE | 2,471 | 2,463 | 8 | 0 |
| PALADIN | 5,525 | 5,505 | 20 | 0 |
| PRIEST | 2,548 | 2,535 | 13 | 0 |
| ROGUE | 3,777 | 3,769 | 8 | 0 |
| SHAMAN | 5,109 | 5,090 | 19 | 0 |
| WARLOCK | 2,461 | 2,453 | 8 | 0 |
| WARRIOR | 5,923 | 5,909 | 14 | 0 |

## Equipment coverage by level

Stored available levels are inventoried, not substituted for every printed
wearer requirement. All supported levels are included.

| Level | Records | Partially verified | Legacy/unverified | Fully verified |
| --- | ---: | ---: | ---: | ---: |
| 1 | 99 | 99 | 0 | 0 |
| 2 | 2 | 2 | 0 | 0 |
| 3 | 14 | 14 | 0 | 0 |
| 4 | 16 | 16 | 0 | 0 |
| 5 | 56 | 56 | 0 | 0 |
| 6 | 55 | 55 | 0 | 0 |
| 7 | 46 | 46 | 0 | 0 |
| 8 | 37 | 37 | 0 | 0 |
| 9 | 27 | 27 | 0 | 0 |
| 10 | 65 | 65 | 0 | 0 |
| 11 | 34 | 34 | 0 | 0 |
| 12 | 61 | 61 | 0 | 0 |
| 13 | 69 | 69 | 0 | 0 |
| 14 | 54 | 54 | 0 | 0 |
| 15 | 102 | 102 | 0 | 0 |
| 16 | 71 | 71 | 0 | 0 |
| 17 | 91 | 91 | 0 | 0 |
| 18 | 90 | 90 | 0 | 0 |
| 19 | 68 | 68 | 0 | 0 |
| 20 | 129 | 128 | 1 | 0 |
| 21 | 89 | 89 | 0 | 0 |
| 22 | 106 | 106 | 0 | 0 |
| 23 | 84 | 84 | 0 | 0 |
| 24 | 76 | 76 | 0 | 0 |
| 25 | 126 | 126 | 0 | 0 |
| 26 | 87 | 87 | 0 | 0 |
| 27 | 75 | 75 | 0 | 0 |
| 28 | 140 | 140 | 0 | 0 |
| 29 | 97 | 97 | 0 | 0 |
| 30 | 135 | 135 | 0 | 0 |
| 31 | 80 | 80 | 0 | 0 |
| 32 | 77 | 77 | 0 | 0 |
| 33 | 79 | 79 | 0 | 0 |
| 34 | 74 | 74 | 0 | 0 |
| 35 | 112 | 112 | 0 | 0 |
| 36 | 78 | 78 | 0 | 0 |
| 37 | 81 | 81 | 0 | 0 |
| 38 | 108 | 108 | 0 | 0 |
| 39 | 72 | 72 | 0 | 0 |
| 40 | 236 | 236 | 0 | 0 |
| 41 | 79 | 79 | 0 | 0 |
| 42 | 114 | 114 | 0 | 0 |
| 43 | 78 | 78 | 0 | 0 |
| 44 | 76 | 76 | 0 | 0 |
| 45 | 121 | 121 | 0 | 0 |
| 46 | 74 | 74 | 0 | 0 |
| 47 | 101 | 101 | 0 | 0 |
| 48 | 140 | 140 | 0 | 0 |
| 49 | 85 | 85 | 0 | 0 |
| 50 | 259 | 259 | 0 | 0 |
| 51 | 87 | 87 | 0 | 0 |
| 52 | 99 | 99 | 0 | 0 |
| 53 | 120 | 120 | 0 | 0 |
| 54 | 103 | 103 | 0 | 0 |
| 55 | 401 | 401 | 0 | 0 |
| 56 | 116 | 116 | 0 | 0 |
| 57 | 106 | 106 | 0 | 0 |
| 58 | 292 | 292 | 0 | 0 |
| 59 | 28 | 28 | 0 | 0 |
| 60 | 2,030 | 1,939 | 91 | 0 |

## Remaining issue categories

Issue rows overlap equipment and routes; they are not additional item counts.

| Category | Issue rows |
| --- | ---: | ---: |
| acquisition-availability | 7,423 |
| commerce-coordinates | 6 |
| commerce-guide-skill | 54 |
| enchantment-effect | 1 |
| equipment-completeness-candidate | 3,584 |
| equipment-response | 92 |
| recipe-availability-flag | 5 |
| recipe-skill-semantics | 96 |
| source-coordinates | 7 |
