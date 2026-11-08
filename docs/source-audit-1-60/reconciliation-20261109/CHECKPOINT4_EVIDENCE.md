# Checkpoint 4: Forever encounter roles versus unverified loot (9 November 2026)

This checkpoint reviews all 20 pending dungeon-source classifications. Published Forever encounters and guide loot tables are **reference evidence only**; some guides reuse Classic loot associations. Neither a named NPC nor a current client item row proves actual live drops, rates, event availability or spawn windows. The original item sources and acquisition-confidence fields remain intact.

## 14 published role identifications

| Item ID | Item | Encounter and role | Evidence / caveat |
|---:|---|---|---|
| 9457 | Royal Diplomatic Scepter | Gnomeregan: Dark Iron Ambassador (rare-boss) | [Forever Dungeon Journal item listing](https://www.wowhead.com/forever/dungeon-journal/gnomeregan/dark-iron-ambassador-rare); rare spawn |
| 10804 | Fist of the Damned | The Temple of Atal'Hakkar: Ogom the Wretched (boss) | [Forever boss encounter and historic item-to-NPC lead](https://www.wowhead.com/forever/guide/the-temple-of-atalhakkar-dungeon-overview-location-rewards); item loot in Forever unconfirmed |
| 11633 | Spiderfang Carapace | Blackrock Depths: Hedrum the Creeper (boss) | [Forever guide encounter loot reference](https://www.wowhead.com/forever/guide/blackrock-depths-dungeon-overview-location-rewards); random Ring of Law encounter |
| 11726 | Savage Gladiator Chain | Blackrock Depths: Gorosh the Dervish (boss) | [Forever guide encounter loot reference](https://www.wowhead.com/forever/guide/blackrock-depths-dungeon-overview-location-rewards); random Ring of Law encounter |
| 11728 | Savage Gladiator Leggings | Blackrock Depths: Ok'thor the Breaker (boss) | [Forever guide encounter loot reference](https://www.wowhead.com/forever/guide/blackrock-depths-dungeon-overview-location-rewards); random Ring of Law encounter |
| 11729 | Savage Gladiator Helm | Blackrock Depths: Hedrum the Creeper (boss) | [Forever guide encounter loot reference](https://www.wowhead.com/forever/guide/blackrock-depths-dungeon-overview-location-rewards); random Ring of Law encounter |
| 11730 | Savage Gladiator Grips | Blackrock Depths: Eviscerator (boss) | [Forever guide encounter loot reference](https://www.wowhead.com/forever/guide/blackrock-depths-dungeon-overview-location-rewards); random Ring of Law encounter |
| 11731 | Savage Gladiator Greaves | Blackrock Depths: Anub'shiah (boss) | [Forever guide encounter loot reference](https://www.wowhead.com/forever/guide/blackrock-depths-dungeon-overview-location-rewards); random Ring of Law encounter |
| 12952 | Gyth's Skull | Upper Blackrock Spire: Gyth (boss) | [Forever guide encounter loot reference](https://www.wowhead.com/forever/guide/upper-blackrock-spire-dungeon-overview-location-rewards); live drop unverified |
| 16669 | Pauldrons of Elements | Upper Blackrock Spire: Gyth (boss) | [Forever guide encounter loot reference](https://www.wowhead.com/forever/guide/upper-blackrock-spire-dungeon-overview-location-rewards); live drop unverified |
| 16695 | Devout Mantle | Upper Blackrock Spire: Solakar Flamewreath (boss) | [Forever guide encounter loot reference](https://www.wowhead.com/forever/guide/upper-blackrock-spire-dungeon-overview-location-rewards); Father Flame encounter |
| 18760 | Necromantic Band | Scholomance: Death Knight Darkreaver (boss) | [Forever item page with historic NPC loot reference](https://www.wowhead.com/forever/item=18760/necromantic-band); quest-summoned |
| 22242 | Verek's Leash | Blackrock Depths: Verek (rare-boss) | [Forever guide encounter loot reference](https://www.wowhead.com/forever/guide/blackrock-depths-dungeon-overview-location-rewards); rare spawn |
| 23169 | Scorn's Icy Choker | Scarlet Monastery: Graveyard: Scorn (rare-boss) | [Forever beta class-guide rare-elite item reference](https://www.wowhead.com/forever/guide/classes/warlock/demonology/level-30-dps-overview); historical Scourge-event spawn availability unverified |

**Confidence distinctions:** Dark Iron Ambassador's rare loot is explicitly listed in the Forever Dungeon Journal (strongest link). Scorn is listed in a Forever **beta** class guide; its historical event-based spawn is not verified on current servers. The BRD/UBRS groups appear in Forever-labelled dungeon guides, but these guides may contain historical loot tables. For Fist of the Damned (10804) and Necromantic Band (18760), the item-to-NPC link is historical while the boss encounter is separately documented on Forever pages; these are labelled accordingly. Never treat these entries as observed live drops.

## Two containers, not enemies: still in the unresolved queue

- **11945 Dark Iron Ring:** historic Dark/Relic Coffer **container lead**, not boss or trash. [Source](https://foreverchanges.pro/item/11945/dark-iron-ring). No Forever coffer content record independently verifies this item.
- **11946 Fire Opal Necklace:** historic Dark/Relic Coffer **container lead**, not boss or trash. [Source](https://www.wowhead.com/forever/item=11946/fire-opal-necklace). No Forever coffer content record independently verifies this item.

## Four further unresolved sources

- **10801 Slitherscale Boots:** Spawn of Hakkar is named in a community listing, but boss/trash role and live loot link remain unverified.
- **14525 Boneclenched Gauntlets:** Ras Frostwhisper is a documented Forever boss, but [historical item associations](https://foreverchanges.pro/item/14525) do not establish his live loot for this item.
- **23173 Abomination Skin Leggings:** Sever appears in historical Scourge-event lists; current Forever appearance and loot unverified.
- **273044 Arcanowisp Robes:** Arcanic Enigma in City of Dalaran is a [community reference](https://tavernforever.com/en/loot/city-of-dalaran/) but [Forever beta reporting](https://www.wowhead.com/forever/guide/classes/mage/frost/level-30-dps-overview) cautioned no confirmed City loot.

**Result:** 14 named roles, 2 correctly marked container leads (still open), 4 other unresolved = **6 remaining item-source verification leads**. Total dungeon equipment 552; full catalogue 7,707; recipe-book followups 954. No ZIP, release, tag or main branch changes.

## Validation and whole-register consistency

- **PASS:** [non-release workflow 42493307958](https://github.com/magicaddons/getgear/actions/runs/42493307958); source regeneration, full nine-class Lua regression, material rules, overlay armour-only and green world-BoE filters, preview and performance.
- **PASS:** [all 577 historic rows checked](CHECKPOINT4_CONSISTENCY.md), exactly 552 dungeon equipment, 24 crafted-pattern leads and one incorrectly labelled finished craft. No duplicate IDs or NPC/container classification errors under documented assertions.
- Generated data commit: [dee3f9b](https://github.com/magicaddons/getgear/commit/dee3f9b004473519523dca957ce2b28d22083537). No packaging/tag/release/merge.
