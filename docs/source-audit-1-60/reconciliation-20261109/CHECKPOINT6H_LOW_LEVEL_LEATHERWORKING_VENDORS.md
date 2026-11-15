# Checkpoint 6H — 25 lower-level non-Favor Leatherworking vendor leads

9 November 2026; baseline `57b2d72` after Tailoring vendor/conflict closeout.

## Exact publication research

All 25 books were fetched as exact Forever XML and item pages. Each teaches-recipe table matches the crafted item ID and spell ID; each sold-by row identifies a named vendor, price and stock field. Independently fetched all 24 distinct vendor NPC pages to resolve map zones and coordinate ranges. [25 case records and book response hashes](checkpoint6h_recipe_evidence.csv), [38 book/vendor/map references and NPC hashes](checkpoint6h_vendor_references.csv).

| Crafted item ID | Gear | Book page | Learning skill | Seller count |
|---:|---|---|---:|---:|
| 5780 | Murloc Scale Belt | [5786](https://www.wowhead.com/forever/item=5786) | 65 | 3 |
| 5781 | Murloc Scale Breastplate | [5787](https://www.wowhead.com/forever/item=5787) | 70 | 3 |
| 5782 | Thick Murloc Armor | [5788](https://www.wowhead.com/forever/item=5788) | 145 | 3 |
| 5963 | Barbaric Leggings | [5973](https://www.wowhead.com/forever/item=5973) | 145 | 5 |
| 6467 | Deviate Scale Gloves | [6475](https://www.wowhead.com/forever/item=6475) | 80 | 1 |
| 7284 | Red Whelp Gloves | [7290](https://www.wowhead.com/forever/item=7290) | 95 | 1 |
| 7349 | Herbalist's Gloves | [7361](https://www.wowhead.com/forever/item=7361) | 110 | 1 |
| 7352 | Earthen Leather Shoulders | [7362](https://www.wowhead.com/forever/item=7362) | 110 | 1 |
| 4255 | Green Leather Armor | [7613](https://www.wowhead.com/forever/item=7613) | 130 | 3 |
| 4455 | Raptor Hide Harness | [13287](https://www.wowhead.com/forever/item=13287) | 140 | 1 |
| 4456 | Raptor Hide Belt | [13288](https://www.wowhead.com/forever/item=13288) | 140 | 1 |
| 18948 | Barbaric Bracers | [18949](https://www.wowhead.com/forever/item=18949) | 130 | 2 |
| 20575 | Black Whelp Tunic | [20576](https://www.wowhead.com/forever/item=20576) | 75 | 1 |
| 252424 | Black Whelp Slippers | [252761](https://www.wowhead.com/forever/item=252761) | 35 | 1 |
| 252425 | Dark Leather Boots | [252762](https://www.wowhead.com/forever/item=252762) | 35 | 1 |
| 252426 | Murloc Scale Shoes | [252763](https://www.wowhead.com/forever/item=252763) | 35 | 1 |
| 252461 | Skirmisher's Leather Belt | [252830](https://www.wowhead.com/forever/item=252830) | 150 | 1 |
| 277042 | Cloudy Gustwoven Hood | [276978](https://www.wowhead.com/forever/item=276978) | 175 | 1 |
| 277043 | Cloudy Gustwoven Spaulders | [276979](https://www.wowhead.com/forever/item=276979) | 175 | 1 |
| 277044 | Cloudy Windraveled Cover | [276980](https://www.wowhead.com/forever/item=276980) | 175 | 1 |
| 277045 | Cloudy Windraveled Drapes | [276981](https://www.wowhead.com/forever/item=276981) | 175 | 1 |
| 277050 | Azure Gustwoven Hood | [276986](https://www.wowhead.com/forever/item=276986) | 175 | 1 |
| 277051 | Azure Gustwoven Spaulders | [276987](https://www.wowhead.com/forever/item=276987) | 175 | 1 |
| 277052 | Azure Windraveled Cover | [276988](https://www.wowhead.com/forever/item=276988) | 175 | 1 |
| 277053 | Azure Windraveled Drapes | [276989](https://www.wowhead.com/forever/item=276989) | 175 | 1 |

## Useful directions retained

Every supported book has named vendor/zone references in the overlay; guide details contain each seller’s own listed coin cost, limited-stock wording where applicable, and the exact published NPC map-coordinate range. These are location references and variable listed prices, not guaranteed live stock or prices. Neutral/travelling sellers are not assigned an invented player faction, and no new map pins are created.

The four low-level books 252761/252762/252763/252830 have exact sold-by rows for Granny Finespindle (NPC 258306), and her independently fetched page locates her in Ironforge. Published third-party NPC sightings do not establish stock of those exact books; they stay live-unverified. Eight exact Cloudy/Azure book tooltips identify Friendly with Earthen Ring (276978–276981) or Kirin Tor (276986–276989). No faction gate is inferred from neighbouring book IDs or copied to unrelated recipes.

## Alternate drops, retained separately

Eight books have 11 exact item-page dropped-by references: 5786/5787/5788/7290/7361/13287/13288/20576. [Book/NPC/zone register](checkpoint6h_book_drop_references.csv) preserves the IDs and citations. Named examples include Defias Squallshaper/Defias Pirate in Deadmines, Dragonmaw Scout/Centurion in Wetlands, Shadethicket Raincaller in Ashenvale and Black Dragon Whelp in Redridge Mountains. All are published book-drop leads that may retain historical data, not current observed rates or proof that the finished crafted equipment drops. Overlay names alternate zones; detailed guide names all listed enemies. No rank-based boss classification or probability is inferred.

## Kalldan location conflict

Book 6475’s exact sold-by row names Kalldan Felmoon (NPC 5783). His [primary NPC page](https://www.wowhead.com/forever/npc=5783) provides only a continent-level Kalimdor mapper point. [Azeroth.wiki’s published inventory/location](https://azeroth.wiki/forever/map/the-barrens/kalldan-felmoon) associates him with the Wailing Caverns area in The Barrens; [community map notes](https://shokadezz.com/wow-forever/map) include conflicting old entrance-cave and Cavern of Mists descriptions. The addon therefore names the Wailing Caverns area but explicitly leaves precise position unverified. Continent coordinates are not converted into The Barrens/dungeon coordinates or an authoritative waypoint. Historical Thottbot comments are not treated as current placement proof.

## Validation and continuation

**Local PASS:** Python compile/full online reconciliation, all three generated-file checks, all 24 module syntax checks, all 14 regressions including deep existing-field preservation. Index 1,169 → 1,194 summaries; runtime additive book IDs 156 → 181. CSV review retained all item IDs/names/levels, original source facts, roles, material/classification and gates; 25 additive summaries changed. Whitespace check passed with existing CSV CRLF recognised. **GitHub PASS:** [Non-release CI 42554596517](https://github.com/magicaddons/getgear/actions/runs/42554596517) PASS: full regeneration, required files, 24 Lua module syntax, all 14 regression outputs, artifact upload and report save. Source commit `9a3ae2151b6962777bf0edacff59948a2dfd9601`; verified bot final HEAD `51b923b7145cefd0d1d898d1888712664e09475a`. Checked bot parent/diff and full logs: only provenance timestamps/response hashes differ; generated index and evidence match local validation. Added 25 exact ID/skill/vendor checks, selected alternate-drop and negative non-propagation cases, the continent-coordinate caveat and eight item-specific Friendly gates. Full-catalogue existing-field invariants retain materials/stats/classes/equip gates and settings/filters unchanged.

Non-Favor vendor cohort now 38/131 researched (35 supported directions, 3 availability conflicts), 93 remain; lower-level subset 38/45, seven remain (6 Blacksmithing, 1 Engineering). Favor 71/188 and quest/mixed 8/37 unchanged. Six dungeon and 954 recipe-book live-verification queues remain open. No live stock/training confirmation, ZIP/build/package, release, tag, merge or main change.
