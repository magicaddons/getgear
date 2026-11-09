# Checkpoint 8I — 25 level-55 vendor items

Publication research on 9 November 2026 UTC, baseline `b105f7b`. [25 exact cases](checkpoint8i_vendor_equipment.csv), [primary proof](checkpoint8i_publication_evidence.json), [64 merchant joins](checkpoint8i_merchant_references.csv), [individual requirements](checkpoint8i_item_requirements.csv). All canonical identities match; all earlier789 reviewed equipment cases excluded and preserved.

**25 named vendor-reference cases**, all current stock/access/live acquisition unverified. Exact item pages independently match **64 merchant rows across six NPC pages** by ID/name/normalized price/stock. No selected item page has an alternate quest, NPC-drop or creation-spell table. None has an explicit unavailable/seasonal warning in these responses; absence of a warning is not proof of availability.

## Faction gates, versions and prices

- Twelve Frostwolf/Stormpike belts and pendants require **Honored** with their respective faction. Each item keeps its individual merchant rows and price.
- Nine shared Alterac Valley off-hand/weapon/ring items list both **Stormpike Guard Exalted and Frostwolf Clan Exalted** in aggregated tooltips. Independently checked inventory rows carry their own faction conditions. These are **purchase alternatives**, not both opposing standings required for one sale. Inventory standing0 is not Neutral; explicit playerConditions preserve the rank.
- Four Arathi weapons require **Exalted** with their own faction. Ironbark Staff20069 is the Samuel Hawke/League of Arathor version; same-name20220 is the Rutherford Twing/Defilers version. Prices/access are not interchangeable.
- Per-seller prices differ, sometimes by one copper. Stormpike Plate Girdle19091 lists **4g74s42c** at Gaelden and **4g74s43c** at Thanthaldis; each matches its reverse inventory. Other larger differences are also retained separately. Do not force one global price or invent a discount formula. Prices remain publication values, not verified current charges or a guarantee that honour/marks are unnecessary in the current game.
- The six Tome/Lei/Touch off-hands are finished gear, **not recipe books or trainer teaching**. Spell-school names do not invent Mage/Warlock restrictions. Current equip55 is distinct from item level and historical equip60 comparison fields; no canonical stats/class/equip/recipe data changed.

## Locations and availability

| Merchant | Published location |
|---|---|
| [Jekyll Flandring13219](https://www.wowhead.com/forever/npc=13219) | Alterac Mountains x62.8/y59.4–59.6 |
| [Thanthaldis Snowgleam13217](https://www.wowhead.com/forever/npc=13217) | Alterac Mountains x39.4–39.6/y81.4–81.6 |
| [Gaelden Hammersmith13216](https://www.wowhead.com/forever/npc=13216) | No usable map in fetched page |
| [Grunnda Wolfheart13218](https://www.wowhead.com/forever/npc=13218) | No usable map in fetched page |
| [Samuel Hawke15127](https://www.wowhead.com/forever/npc=15127) | Arathi Highlands x46/y45.2–45.6 |
| [Rutherford Twing15126](https://www.wowhead.com/forever/npc=15126) | Arathi Highlands73.4,29.8 |

Map footprints are published references, not live sightings; no current instance/world pin invented for unmapped merchants. All64 rows show no finite stock limit; that is not current inventory confirmation. Current faction/phase/battleground access, charges, reputation earning rates, starting standing and rank rules remain unverified. No win-count, honour-rank/currency, event timing or restock claim.

## Validation and continuation

**Full local PASS:** fresh online reconciliation/Python syntax,24 Lua modules,four reports,14 regressions ([output](checkpoint8i_local_results.txt)); all789 earlier registry entries exactly retained and all25 source fingerprints match primary proof. Index2,543/display2,542/books759. **GitHub CI pending:** finish/inspect bot before advancing. Preserve all7,707 catalogue identities/36,341 objectives,1,254 crafts/4,857 ingredients, nine-class gates/filters/settings/layout and stronger sources. No release/build/package/tag/merge/main action.

After verification: equipment814; remaining frozen queue **5,088** (vendors1,005; quests190; undocumented1,004; world-drop2,887; reputation2). **Next8J:63 vendor cases at catalogue level58**, followed by bounded groups of942 level60 vendors and other remaining families. Original954 current book routes/six dungeon exceptions and current-source uncertainties remain open.
