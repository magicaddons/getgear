# Checkpoint 5H — final vendor-book batch 274007–274019
2026-11-09. **13 book-item/gear/spell mappings reviewed. No verified live merchant purchases.**

| Book ID | Finished item | Skill/spell | Best published evidence | Individually evidenced gate | Live stock observed? |
|---:|---|---|---|---|---|
| 274007 | Spiritcaller Greaves (273939) | Leatherworking 300 / spell 1292976 | [Named Forever recipe guide](https://www.zockify.com/forever/professions/leatherworking/recipes/) | Exact book gate not independently established | No |
| 274008 | Demonheart Leggings (273940) | Tailoring 300 / spell 1292977 | [Named Forever recipe guide](https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes) | Exact book gate not independently established | No |
| 274009 | Demonheart Gloves (273941) | Tailoring 300 / spell 1292978 | [Named Forever recipe guide](https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes) | Exact book gate not independently established | No |
| 274010 | Demonheart Spaulders (273942) | Tailoring 300 / spell 1292979 | [Named Forever recipe guide](https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes) | Exact book gate not independently established | No |
| 274011 | Demonheart Boots (273943) | Tailoring 300 / spell 1292980 | [Named Forever recipe guide](https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes) | Exact book gate not independently established | No |
| 274012 | Legplates of Glory (273944) | Blacksmithing 300 / spell 1292981 | [Named Forever recipe guide](https://www.wowhead.com/forever/guide/professions/blacksmithing/overview) | Exact book gate not independently established | No |
| 274013 | Gauntlets of Glory (273945) | Blacksmithing 300 / spell 1292982 | [Direct Forever book](https://www.wowhead.com/forever/item=274013) | Further Guardians reputation + Gloves specialisation | No |
| 274014 | Shoulders of Glory (273946) | Blacksmithing 300 / spell 1292983 | [Named Forever recipe guide](https://www.wowhead.com/forever/guide/professions/blacksmithing/overview) | Exact book gate not independently established | No |
| 274015 | Greaves of Glory (273947) | Blacksmithing 300 / spell 1292984 | [Direct Forever book](https://www.wowhead.com/forever/item=274015) | Further Guardians reputation + Boots specialisation | No |
| 274016 | Legguards of Glory (273948) | Blacksmithing 300 / spell 1292985 | [Direct Forever book](https://www.wowhead.com/forever/item=274016) | Friendly Guardians reputation + Friendly Advice | No |
| 274017 | Handguards of Glory (273949) | Blacksmithing 300 / spell 1292986 | [Direct Forever book](https://www.wowhead.com/forever/item=274017) | Further Guardians reputation + Gloves specialisation | No |
| 274018 | Pauldrons of Glory (273950) | Blacksmithing 300 / spell 1292987 | [Direct Forever book](https://www.wowhead.com/forever/item=274018) | Further Guardians reputation + Shoulders specialisation | No |
| 274019 | Sabatons of Glory (273951) | Blacksmithing 300 / spell 1292988 | [Direct Forever book](https://www.wowhead.com/forever/item=274019) | Further Guardians reputation + Boots specialisation | No |

## Audit judgement
- The last 13 contain **one Spiritcaller** (Leatherworking), **four Demonheart** (Tailoring), and **eight Glory** (Blacksmithing). [Leatherworking list](https://www.zockify.com/forever/professions/leatherworking/recipes/), [Tailoring guide](https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes), and [Blacksmithing guide](https://www.wowhead.com/forever/guide/professions/blacksmithing/overview) corroborate item names, craft skill and published acquisition references; GetGear retains the exact book and spell IDs.
- **Six direct Forever Glory book tooltips** (274013, 274015, 274016, 274017, 274018, 274019) support the indicated reputation/quest or specialisation wording. The seven remaining books are named-guide-level references; their **individual purchase gates are not verified**. Do not infer a precise rank or copy a requirement across a family.
- Every item has one named Aisarra Nightmeadow (Mount Hyjal) reference and one blank vendor row. The blank row does not indicate another merchant. No live stock, live cost or successful purchase is independently observed.
- **Targeted 13/13 row audit PASS** for unique books, gear IDs, spell IDs, professions, source statuses and duplicate anonymous vendor handling. **Complete 68/68 consistency audit PASS**, with two legitimate non-linear crafting spell ID mappings at books **273952 and 273953**, which use offset 1018968 instead of the remaining 66 books' 1018969. Do not derive spell IDs solely from book IDs.
- No runtime item/source/filter/ingredients/UI changes. Documentation-only, so no new full non-release CI run; last full [PASS 42493307958](https://github.com/magicaddons/getgear/actions/runs/42493307958). No ZIP, release, tag or main modification.

**Research coverage: 68/68 published vendor-book source records assessed. Live verification: 0/68. Trainer-labelled records: 886 untouched.** Stop vendor research here until new live stock evidence emerges; next distinct development task is to plan/reconcile the trainer-labelled books.
