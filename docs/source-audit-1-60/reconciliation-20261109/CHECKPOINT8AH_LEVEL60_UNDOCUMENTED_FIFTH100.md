# Checkpoint 8AH — level-60 undocumented acquisition cases, fifth 100

Status: complete at publication-research level; full local/non-release CI42767428623 PASS and direct bot2d2489de659371978519ae16927abed6c35e71ad reviewed. This checkpoint does not establish current live acquisition.

## Scope and resume point

The marked queue selected 100 exact IDs, 274184–280917. All are now individually researched and recorded in the 2,775-entry equipment research registry. The previous 2,675 objects are unchanged. Frozen queue remaining: 3,127 (50 undocumented, 190 quest, 2,887 world-drop). After CI succeeds and its bot commit is reviewed, continue **8AI: the final 50 undocumented level-60 cases, IDs 280918–284716**. Do not repeat 8AH without a verified deficiency.

Per-item canonical/published names, class checks, requirements, source roles, HTTP status and fingerprints are in [working evidence](checkpoint8ah_working_evidence.json). The [100-case table](checkpoint8ah_undocumented_equipment.csv) and [108-query discovery index](checkpoint8ah_discovery_index.json) keep the individual scope reviewable.

## Findings and confidence

| Group | Cases | Confirmed publication facts | Acquisition limitation |
| --- | ---: | --- | --- |
| Premier armour | 39 | Exact primary IDs/names, Epic/BoP, item level65/equip60; 23 Shaman and 16 Paladin class masks match the canonical catalogue | No primary acquisition table or explicit rank. Missing rank does not prove ungated purchase. |
| Premier offhands/shields | 4 | Exact primary rank14 tooltips; two Held In Off-hand Tomes and two Barricade shields | Four exact-ID secondary unnamed location leads, no independent named merchant inventory/current price or stock |
| Watcher rings | 16 | Primary published aliases, equip60, faction2819 standing4/5/6/7; independent primary faction reward-list joins | Equip/reward standing is not an independently read purchase condition or reputation-earning route |
| Hyjal-family armour | 41 | Exact ID/name/BoP/item65/equip60/class/set facts in the public aggregate cache | Full primary item requests return404; cached origins are Unknown. No current unavailable, raid-drop or craft conclusion |

The primary pages for 59 items have no explicit unavailable/seasonal warning and no acquisition table. This statement does not extend to the unreadable 41 pages. Four representative missing primary pages (280450/280899/280905/280917) also failed through the connected reader; that does not turn404 into a retirement warning.

### Premier location and gate evidence

- 278157 Tome of Restoration: secondary Dalaran.
- 278158 Tome of Power: secondary Champions' Hall and Dalaran.
- 278468 Grand Marshal's Barricade: secondary Dalaran.
- 278469 High Warlord's Barricade: secondary Orgrimmar and Dalaran.

Each exact secondary record publishes Dalaran16.3,71.3, but names no seller. These are qualified RaidDex location leads, not current actor/inventory joins. All four primary tooltips explicitly retain Grand Marshal / High Warlord (Rank14); current purchase acceptance remains untested. The Tomes are equipment, not learning books. Shield names/stat effects are not profession recipes.

The full general primary PvP guide previously read9Nov contains none of these43 Premier IDs. Its system policy cannot establish exact inputs, seals, upgrade quantities or current sellers. The previously recorded official temporary capital-vendor outage is dated evidence, not a fresh stock check or permanent retirement. The reused 174-NPC/96-inventory survey matches none of these100; it is neither exhaustive nor a fresh current-stock survey.

### Watcher names, reputation and ownership

The primary aliases differ from the preserved canonical names, matching the existing audit's independent-name disagreement flags. The independent [The Watchers faction2819](https://www.wowhead.com/forever/faction=2819) list joins all16 by numeric ID, name and standing. The [build70707 change log](https://daybreakforever.com/changes/1.60.1.70707) corroborates the published rename families.

| Standing | IDs | Published prefix |
| --- | --- | --- |
| Friendly4 | 275968–275971 | Initiate's |
| Honored5 | 275972–275975 | Tracker's |
| Revered6 | 275976,275977,275979,275980 | Watcher's |
| Exalted7 | 275981–275984 | Warden's |

Ferocious maps to Ferocity, Brilliant to Brilliance, **Vigilant to Resolve**, and **Stalwart to Vigilance**. Do not exchange the latter two by interpreting their old names. Canonical identity/name/stat/eligibility stays intact; the acquisition metadata now makes the exact published alias visible. Later display-name reconciliation should preserve numeric identity and account for the published version.

Unique-Equipped: Watcher's Ring(1) is the family equip limit, not Unique ownership or proof a lower ring is consumed. Standing tiers have different item levels/rarities; no upgrade recipe follows from that ordering.

[Forever Tavern](https://forever-tavern.com/reputations/the-watchers/) shows client/reference prices5/8/12/20gold, explicitly warns that a requirement does not prove vendor/price/current availability, and leaves quartermaster location and reputation earning undocumented. Fifteen exact-ID AHledger discovery extracts additionally claim these reference prices; the missing sixteenth extract is not borrowed from a sibling. None is an accepted current merchant price.

A [Daybreak systems](https://daybreakforever.com/discoveries/systems) reader mentions a separate Honored ring-vendor condition. Its search extract mentions159370 and First One's Free, but the actual reader did not expose that numeric row or a selected item/NPC/quest join. This is an unconfirmed discovery lead, not an imposed gate on every Friendly ring. Retail Marin Bladewing, Duskwood Night Watch, Anachronos and speculative Alcaz locations are not joined to these IDs.

### Missing primary Hyjal pages and different-ID crafts

All41 exact records are present in the [public Forever cache](https://raw.githubusercontent.com/Napalmsteak/WoW-Classic-Item-Caches/main/Forever%20Cache.json), with Unknown source and no named boss. Class checks match six Mage, six Rogue, six Warlock, six Hunter, **12 Warrior**, and five Priest entries. Both Glory variants are Warrior, including the tank-style set; neither becomes Paladin or specialization-only gear by name.

Twenty-eight items have a same-name lower-ID canonical alternative. Search hits for those crafted versions, recipes/books and BoE/Artisan-tier tooltips are separate versions, not source evidence for selected280xxx IDs. Selected heads/chests and set membership likewise do not create a recipe.

The [exact280450 Manaflare Robes secondary page](https://forever.undrwrldcub.com/db/items/item-280450/) calls its origin Unknown and Hyjal Summit merely expected from model tags. That is speculation, not a selected item-to-boss join or proof of current raid availability.

Both aggregate datasets were actually read and fingerprinted: cache18,590,138bytes/SHA25686a387d5274635ebff1589b8702792fc8c0bfdb55df2ae29ec31a4c894f18e3a; [AHledger items](https://www.wowforeverfriends.org/items/items.json)16,908,600bytes/SHA256e0a86115fc289b5c9914b6212e0b178f3e2e1777429c08eaaf4b586277c01fba. AHledger contains none of the100 selected IDs; its coverage/15Oct update are retained as limitations. Cache update times are not loot events. The41 item pages have no successful item-response hash: only the actual aggregate HTTP hash and explicitly labelled record-projection hashes are recorded. Daybreak full HTTP requests were proxy403; connected-reader findings have no fabricated full-response hashes.

## Validation and next development work

[Local results](checkpoint8ah_local_results.txt), [semantic comparison](checkpoint8ah_upstream_review.json) and [raw feed comparison](checkpoint8ah_raw_upstream_review.json) record:

- Full14 Lua regressions, offline Python dungeon-link guard,24 manifest modules, four required reports and capture-helper syntax: PASS.
- Runtime index4,424/display4,423; book-only IDs759; canonical7,707/class objectives36,341; crafts1,254/ingredients4,857.
- Exactly100 additive-summary cells changed; zero other derived semantic or source-offset changes. Prior2,675 research objects and all six dungeon exceptions preserved.
- Seven actual same-run HTTP response bytes/hashes match provenance, with no duplicate diagnostic feed fetches.
- Playfulls23,352/9,153 definitions and Everloot1,399 raw/1,199 qualifying relation facts/counters unchanged; zero selected observed edges. The107 outside-canonical9A candidates remain separate and unaudited.

Next in-game work must verify named current sellers, ring quest/purchase/earning conditions, actual prices, stock, equip-limit behavior and41 missing-page origins. Existing954 live book routes and six dungeon exceptions remain open. No release build/package/tag/publish, Beta8 replacement, main modification or billing action.


## Checkpoint 8AH validated — next 8AI

Full local/GitHub PASS: [42767428623](https://github.com/magicaddons/getgear/actions/runs/42767428623), source a58c8f204786bb839854bbc9c6a13b6d1f4dcf29; inspected direct bot/final validated 2d2489de659371978519ae16927abed6c35e71ad. All14 Lua regressions, offline Python guard,24 modules/four reports/helper syntax pass;15 timestamped CI test-PASS lines inspected. Bot changes only run time/three Everloot response hashes; no runtime/report/index/count changes or claimed independently captured bot response bytes.

100 cases complete:39 Premier armour origin/rank gaps, four primary rank14 tooltips with four unnamed location leads,16 exact Watcher aliases/faction2819 equip-standing joins,41 primary404/cache-identified unknown origins.80 class projections match canonical;28 different-ID namesakes do not transfer crafts/binding/source; both Glory variants remain Warrior. Unique-equipped ring family limit is not ownership/consumption; reference prices and general Honored/unknown quest condition do not establish selected purchases. Canonical names/stats/eligibility preserved, aliases visible in research metadata.

Equipment2,775/index4,424/display4,423/books759;crafts1,254/ingredients4,857. Previous2,675 objects exact;100 summary cells only/all six dungeon exceptions retained. Seven same-run actual HTTP captures match provenance; local Playfulls23,352/9,153 and Everloot1,399raw/1,199qualified exact facts/counters unchanged; zero selected observed edges.107 outside-canonical9A candidates remain separate/unvalidated. Frozen remaining3,127:50 undocumented/190quest/2,887world-drop. **Next8AI: final50 undocumented60 IDs280918–284716**, marked queue. Main/Beta8 tag/source rechecked10Nov06:16UTC unchanged. All current-live book/dungeon/access/supply/retention exceptions remain. No release/main/billing action.
