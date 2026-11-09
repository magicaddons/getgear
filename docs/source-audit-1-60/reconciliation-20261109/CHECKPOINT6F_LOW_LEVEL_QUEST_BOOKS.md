# Checkpoint 6F — eight lower-level quest-related recipe books

9 November 2026; baseline `a2cb198` (lower-level Favor closeout). This starts the user-approved longer research plan, prioritising lower-level quest directions before higher-level Favor entries.

## Method and exact identity checks

Fetched XML and complete Forever item pages for all eight books. Parsed each exact teaches-recipe link, item/spell/profession identity, and reward-from-q references. Fetched all nine quest pages and eight distinct start/end NPC pages. Parsed quest-page reward JSON independently of the book’s reward-from list, checked that each exact book is guaranteed or a choice reward, and matched named start/end NPCs. Source response SHA256 for each book/quest/NPC is retained in [book evidence](checkpoint6f_recipe_evidence.csv) and [nine quest routes](checkpoint6f_quest_references.csv). No historic comment was promoted to current source evidence.

| Crafted item ID | Gear | Book | Learning skill | Published quest routes |
|---:|---|---:|---:|---|
| 3471 | Copper Chain Vest | [3609](https://www.wowhead.com/forever/item=3609) | 30 | [Supplying the Front #1578](https://www.wowhead.com/forever/quest=1578) |
| 6468 | Deviate Scale Belt | [6476](https://www.wowhead.com/forever/item=6476) | 90 | [Deviate Eradication #1487](https://www.wowhead.com/forever/quest=1487) |
| 6709 | Moonglow Vest | [6710](https://www.wowhead.com/forever/item=6710) | 65 | [Moonglow Vest #1582](https://www.wowhead.com/forever/quest=1582) |
| 6731 | Ironforge Breastplate | [6735](https://www.wowhead.com/forever/item=6735) | 100 | [Gearing Redridge #1618](https://www.wowhead.com/forever/quest=1618) |
| 7913 | Barbaric Iron Shoulders | [7978](https://www.wowhead.com/forever/item=7978) | 135 | [On Iron Pauldrons #2752](https://www.wowhead.com/forever/quest=2752) |
| 7914 | Barbaric Iron Breastplate | [7979](https://www.wowhead.com/forever/item=7979) | 135 | [Barbaric Battlements #2751](https://www.wowhead.com/forever/quest=2751) |
| 7915 | Barbaric Iron Helm | [7980](https://www.wowhead.com/forever/item=7980) | 150 | [Horns of Frenzy #2754](https://www.wowhead.com/forever/quest=2754) |
| 277672 | Rough Copper Chain Boots | [277673](https://www.wowhead.com/forever/item=277673) | 50 | [The Quarry's Smith #95217](https://www.wowhead.com/forever/quest=95217); [This Is Spinal Axe #96874](https://www.wowhead.com/forever/quest=96874) |

## Actionable facts and limitations

- **Copper Chain Vest, book 3609:** Alliance quest 1578 starts with Tormus Deepforge in Ironforge; completion is Thorvald Deepforge in Loch Modan’s southern guard tower. Quest turn-in: 6 Copper Axes and 6 Copper Chain Belts. Its generic drop route remains alongside the named quest. The book page displays a 200-row dropped-by pool; completeness, current realm validity and probabilities were not established, so it is not converted into a chosen farming target.
- **Rough Copper Chain Boots, book 277673:** Alliance quest 95217 starts/ends at Frast Dokner in Dun Morogh, published minimum level 7; deliver 12 Copper Bars and 4 Toughened Boar Hides. Horde quest 96874 starts/ends at Ug’thok in Orgrimmar, published minimum level 6; bring 5 Weathered Spines from Thunder Ridge beasts and 5 Rough Grinding Stones. Published quest-class and Alliance race restrictions remain source-access notes, not gear filters.
- **Moonglow Vest, book 6710:** Alliance quest 1582 with Lotherias in Darnassus, published minimum level 8. Delivery: 1 Embossed Leather Gloves, 5 Embossed Leather Boots, 5 Embossed Leather Cloaks.
- **Ironforge Breastplate, book 6735:** Alliance quest 1618 starts with Tormus Deepforge in Ironforge and finishes with Verner Osgood in Redridge Mountains; deliver 4 Runed Copper Belts and 4 Heavy Copper Mauls. Do not confuse quest start zone with delivery destination. The page’s placeholder minimum level 1 is retained in evidence but not presented as established access.
- **Deviate Scale Belt, book 6476:** quest 1487 with Ebru at Wailing Caverns; published minimum level 15, both factions. Kill 7 each of Deviate Ravager/Viper/Shambler/Dreadfang, then select the pattern as a **choice reward**, not a guaranteed extra reward. NPC mapper data is continent-level Kalimdor, so no dungeon-coordinate pin is inferred; precise NPC position remains unverified. Original reported source confidence stays intact.
- **Barbaric Iron Shoulders/Breastplate/Helm, books 7978/7979/7980:** Horde quests 2752/2751/2754 with Orokk Omosh in Orgrimmar list minimum quest level 32, although gear equips at 27/27/30. The gear equip gates are unchanged. Quest turn-ins are respectively 4 Bronze Battleaxes + 4 Bronze Warhammers; 2 Patterned Bronze Bracers + 2 Bronze Greatswords + 2 Sharp Claws; 2 Solid Iron Mauls + 2 Silvered Bronze Boots + 2 Silvered Bronze Gauntlets. Published quest-class restrictions are retained as access caveats.

These are published Forever pages that can retain Classic-era quest data/comments. They establish a traceable reference, not current realm quest availability or a fully verified prerequisite chain. No undocumented prerequisite, reputation gate, cross-faction trade access or NPC coordinate was guessed. Item learning skill is not substituted for quest profession-skill prerequisites. Quest delivery items are informational notes and do not alter or enter the crafting materials tracker.

## Integration and safeguards

Eight new book acquisition summaries show named quests, start zones/NPCs, faction and useful access caveats in the overlay. Full-guide details retain separate turn-in destinations and supplies, choice rewards, class/race access notes and the mixed quest/drop route. Reviewed publication metadata may supplement a previously reported item; original source confidence, descriptions, instructions and existing manual summaries remain primary and unchanged. Full-catalogue structural tests protect every pre-existing field except explicitly additive summary/book metadata. A targeted test preserves Deviate Scale Belt’s original reported confidence.

**Local PASS:** Python compilation, online full reconciliation, required-file checks 3/3, all 24 Lua syntax checks and 14/14 regressions. Eight quest-book exact assertions, separate destination/choice/mixed-route checks, reported-confidence preservation and full-catalogue field preservation pass. Source index 1,148 → 1,156 summaries; book IDs 139 → 147. CSV row counts/identities/gates/material classifications unchanged; eight additive summaries changed. **GitHub PENDING.** No new live-source confirmations. Favor research stays 71/188, with 117 higher-level leads remaining; eight of the 37 quest/mixed cohort now researched, 29 remain above gear level 30. Six dungeon and 954 recipe-book verification routes remain queued. No ZIP/package, build, release, tag, merge or main action.
