# Independent stat flags for WoW Forever

Flags are independent and nonexclusive. An item can have physical, mana, healing, spell-power and defense bonuses simultaneously. A missing flag or missing source does not mean that a bonus is absent.

- Source: [https://raw.githubusercontent.com/Napalmsteak/WoW-Classic-Item-Caches/main/Forever%20Cache.json](https://raw.githubusercontent.com/Napalmsteak/WoW-Classic-Item-Caches/main/Forever%20Cache.json)
- SHA256: 86a387d5274635ebff1589b8702792fc8c0bfdb55df2ae29ec31a4c894f18e3a
- Catalogue records: 7,707
- Name-matched Forever tooltips: 7,699
- No matching tooltip evidence: 8
- not_in_tooltip_source: 8
- spellPower flag present: 2,020
- healing flag present: 1,894
- mana flag present: 2,772
- physical flag present: 2,871
- defense flag present: 322

## Representative checked items

| Item ID | Name | Bitmask |
|---:|---|---:|
| 250492 | Crusader's Chain Shirt | 11 |
| 250522 | Crusader's Silvered Chain Shirt | 11 |
| 250490 | Protector's Chain Shirt | 19 |
| 250520 | Protector's Silvered Chain Shirt | 19 |
| 250488 | Veteran's Chain Shirt | 8 |
| 250519 | Guard's Silvered Chain Shirt | 24 |
| 250517 | Crusader's Chain Belt | 11 |
| 250502 | Crusader's Chain Helm | 11 |
| 3313 | Ceremonial Leather Harness | 12 |
| 252509 | Trapper's Leather Tunic | 12 |
| 250491 | Acolyte's Chain Shirt | 7 |
| 250501 | Acolyte's Chain Helm | 3 |

## Interpretation

- The spellPower flag means an explicit passive increase to spell/magic damage.
- Spell resistance, spell crit, spell-on-hit procs, and Intellect or Spirit alone do not trigger spellPower.
- Warrior, Rogue and Hunter have a default presentation veto for explicit spellPower.
- Paladin, Shaman and Druid continue to see appropriate hybrid equipment.
- Show all valid equipment bypasses these relevance rules, never QA exclusions.
- Generated flags are loaded after the original item cache so it cannot overwrite them.
- Regenerate this index from newer Forever data before future bulk releases.
