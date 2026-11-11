# Checkpoint 8BK — level-42 acquisition and shared navigation research

63 cases completed at **published-source level**, with no personal or current-build live verification. The immutable source proof is `checkpoint8bk_working_evidence.json`; exact cases and fingerprints are in `checkpoint8bk_equipment_evidence.csv`. CI and inspected bot closure are recorded separately in `checkpoint8bk_validation.json` when complete.

## Findings and confidence

- **59 broad drops:** independently checked own-item pages and full enemy inventories. All 63 selected items are BoE: 57 Uncommon, five Rare and one Epic. Broad-drop examples remain examples, with no invented precise farming pin or current drop-rate claim.
- **Iridescent Scale Leggings [4478](https://www.wowhead.com/forever/item=4478):** exact own-item and full [Scale Belly 1552](https://www.wowhead.com/forever/npc=1552) references agree. Published Stranglethorn Vale footprint: eight points, x43.2–44.0/y45.4–49.2. Shared navigation opens useful area directions, without converting a roaming footprint to a precise point. Published Forever equip42/item47, 226 armor and 14 Fire/Frost resistance differ from historical Classic 40/45, 217 armor and 13 resistance. Existing catalogue gates/stats are preserved.
- **Talisman of the Naga Lord [5029](https://www.wowhead.com/forever/item=5029):** exact own-item and full [Lord Sakrasis 2541](https://www.wowhead.com/forever/npc=2541) references agree. Published Stranglethorn Vale footprint: three points, x28.2–28.6/y62.2–62.6. Area navigation is available; current spawning, supply, loot probability and exclusivity remain unknown.
- **Lord Sakrasis’ Scepter [5028](https://www.wowhead.com/forever/item=5028):** own acquisition tables are empty and the full Lord Sakrasis inventory omits it. Historical secondary claims explicitly rely on Classic loot. Its name and holy-spring effect are insufficient acquisition evidence. Full [Holy Smite 1326019](https://www.wowhead.com/forever/spell=1326019) independently lists the item, establishing an effect association, not a source. The 56 Holy effect and removed Spirit are not a Paladin, trainer or recipe unlock. Origin remains unverified; no misleading pin.
- **Snarling Fang [285043](https://www.wowhead.com/forever/item=285043):** published new BoE One-Hand Dagger, equip42/item47, 35–66 damage/1.80 speed, +6 Stamina/+9 Attack Power. No acquisition table is returned. Other client-cache listings establish an item record rather than a current origin. No inferred gnoll source or pin.
- **Widowmaker [4091](https://www.wowhead.com/forever/item=4091):** published restriction is plain **Unique**, not Unique-Equipped. Rare BoE One-Hand Dagger, equip42/item47, 42–78 damage/1.90 speed, +7 Strength/+8 Agility. This qualification remains visible in acquisition instructions without changing eligibility or stat data.

## Containers and discrepancies

229 independent full NPC joins, 53 object joins and 118 physical-container joins corroborate selected item IDs/names. Keep **21 NPC reverse omissions and 47 physical-container reverse omissions** explicit; none proves current absence, retirement or a particular table cap. Flurry Axe 871 has a positive full Black Slayer reference; its own references to Zul’Farrak Zombie, Subterranean Diemetradon and Theradrim Guardian are not independently positive. No boss attribution is inferred.

New full [Mithril Bound Trunk 21228](https://www.wowhead.com/forever/item=21228) has 19 possible contents and published fishing-zone references to Stranglethorn Vale, Tanaris, Azshara, Feralas and Riverglades. Its full contents omit 24 selected own-item references. Zone IDs/zone-level ranges are neither precise schools nor Fishing skill requirements. No guaranteed gear roll or current catchability is established. Other omissions: AQ40 crate 21512 (two), AQ30 crate 21511 (five), Cuergo 9265 (12), Reinforced Steel Lockbox 4638 (four).

Reuse completed quest-container research: AQ30/AQ40 alternatives, Kum’isha/defense/sphere discrepancies, Nilith’s published Tailoring travel sequence, Lard’s lunch input and separate Thrown reward, egg/machine/crate/extraordinary-egg/goodies route, and Cuergo’s distinct keys/objects. Source skill/faction/minimum levels belong to acquiring the container, not wearing its possible BoE contents. Mandatory quest graphs, newer quest actors/factions, current event/access/opening/consumption rules and random reward rolls remain qualified. No completed research or known failed URL was retried.

## Shared navigation and future research

Both named routes enter the existing single context-sensitive pin/model. Unknown origins now count as **missing**, even for a historically world-drop-labelled item; they cannot be reported as navigation not applicable. An offline generator fixture and real-catalogue runtime assertions protect that boundary. New coordinates, ordered quest routes, source requirements and indirect container prerequisites continue through the same registry, generator, detailed guide, audit and `navigation_research_gaps.csv`.

Full nine-class audit: **682 published point-data / 1,271 directions / 3,172 missing / 2,582 not applicable**, with 6,450 overlapping gap rows. These are data/route coverage counts; actual in-game rendering remains **zero verified**. Existing map API limitations and full manual matrix remain in `NAVIGATION_RESTORE.md`.

## Evidence and validation

86 case primary responses: 69 new, 17 cached. Including explicitly retained completed context: 194 unique primary responses, 69 new and 125 retained/cached. 63 exact-ID/name discovery queries plus three shared special-case queries; secondary Classic, client-only and AH claims are not promoted to current live acquisition facts. Zero new failed primary reads; 127 previously failed URLs retained without retry.

The first reconciliation attempt correctly rejected two summaries that omitted the required explicit word “unverified”. Corrected those two summaries and ran a fresh complete reconciliation (`8bk2`, exit0), followed by full validation. The failed attempt and actual successful eight HTTP-response fingerprints are separately retained in `checkpoint8bk_reconciliation_attempts.json`; no response replay/fallback or false initial PASS claim.

Successful fresh source comparison: Playfulls **23,605 items / 9,246 definitions**, every raw row, full source object and metadata value exact against independently inspected 8BJ bot bodies. Everloot **1,672 raw / 1,431 qualifying**: no new/removed/selected relationship or build/firstSeen change. Five retained relations update lastSeen; only NPC12718’s location relation also changes installs3→4. Three item relations are Copper Ore/Rough Stone→copper node1731 and Refreshing Spring Water→vendor3934; two NPC location relations are9087/12718. Counters/timestamps do not establish new loot or a current-build observation. Original five-row delta retained before diagnostic snapshot advance; no duplicate diagnostic fetch.

Full local **19 PASS**: 15 Lua suites, three offline Python suites and required files/syntax (26 addon modules, four Python tools and Lua exporter). After queue/generator input updates, regenerate shared navigation and validate the final state. All 4,762 prior equipment metadata objects, original 954 recipe metadata records, eight companion CSVs, supplementary craft metadata and 363-candidate file remain unchanged. Exactly 63 additive-summary cells change. Catalogue retains **7,707 identities / 36,341 class objectives / 1,254 crafts / 4,857 ingredient identities**, settings and all eligibility/stat/armor/BoE filters.

Registry **4,825**, evidence index **6,296**, displayed references **6,295**, book IDs **759**. Frozen queue **5,688 = 4,611 publication-researched + 1,077 pending**. This is approximately81% of the frozen queue, not81% of every remaining research/acceptance obligation.

## Exact continuation

Complete non-release CI and inspect every direct bot change, then **8BL: all 56 pending level-43 world-drop cases in numeric item-ID order**, already marked in the queue. Do not repeat completed8B–8BK cases or unchanged failed URLs. Retain 363 outside-scope candidates pending systematic all-slot/Back/Thrown and ten omitted-cloak validation, six unresolved dungeon links, 954 current-live book routes, manual navigation acceptance and final integrity work. Do not adopt candidates automatically or close live/coordinate gaps without evidence.

Only the existing development branch is used. Main/Beta8, builds/packages/releases, billing and subscriptions remain untouched. Continue with the existing automation; no duplicate worker or new automation.
