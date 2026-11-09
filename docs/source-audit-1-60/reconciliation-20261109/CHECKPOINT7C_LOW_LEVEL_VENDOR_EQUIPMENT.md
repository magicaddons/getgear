# Checkpoint 7C — 93 lower-level vendor-associated equipment cases

9 November 2026; baseline `3b2d3413b5abe65c89f516c9b9ad6110c2e411a9` after validated quest batch.

## Full bounded case research

All **93 catalogue items through level 30** with vendor-associated classification and no generated source detail individually fetched by canonical URL. Exact main item IDs/names match; all pages loaded successfully. Source qualities before this batch: 78 Classic references, 15 player-reported/manual cases. Stronger existing source/instructions/confidence remain primary.

Result: **72 named vendor-reference cases, 19 explicit cross-version warnings, two unresolved origins.** Across the 91 pages with sellers, **194 item/merchant relationships** independently joined by exact item ID and name to **73 merchant inventories**, with all costs matching after normalising equivalent empty-array formats. All 73 NPC titles match and have published map data. **62 merchant rows** have positive limited-stock table quantities; these are not current inventory or restock timers. Names, locations, price references and map footprints supplied in the full guide; summary shows merchant examples when many exist. No nearest/faster/guaranteed vendor recommendation.

[All 93 cases](checkpoint7c_vendor_equipment.csv); [194 exact merchant/map/cost references](checkpoint7c_merchant_references.csv); [40 item-specific reputation requirements](checkpoint7c_item_requirements.csv); [19 version warnings](checkpoint7c_cross_version_warnings.csv); [source response hashes, NPC maps, faction/coin context and independent inventory audit](checkpoint7c_vendor_publication_evidence.json).

### Individual gates and source confidence

- **Warsong Outriders:** individual Honored versus Revered tooltips retained; exact seller Kelm Hargunth, The Barrens 46.6,8.4. Illiyana Moonblaze, Ashenvale x61.4–61.6/y83.8 is a separate Alliance reference for relevant items. Some inventory rows encode standing 0 despite a tooltip rank: this is **not Neutral access proof**. No copied family rank or invented honor-rank/win count. Faction pages provide Warsong Gulch context, not current reputation rates.
- **The Defilers:** Friendly talisman, Honored girdles and Revered greaves/boots read individually. Rutherford Twing's Arathi Highlands map point 73.4,29.8 is a published reference. Arathi Basin faction context does not prove current stock.
- **Darkspear Raiders:** seven exact items retain individually read Honored/Revered gates. Creeg Bothunk, The Barrens x65/y34.4–34.6 is the matched seller, not another battleground quartermaster. Retrieved faction page describes the Darkspear Islands opposition; current entry/gain rates remain unverified. Blizzard full-page retrieval returned HTTP403; no claim its full article was read.
- **Ratchet:** Winklespark, The Barrens x62.4–62.6/y37.4–37.6; Friendly and Honored gates preserved individually. No unverified grind recipe or faction earning rate supplied. Existing player reports remain unchanged.
- **Empty Fish Bucket 276273:** Jang 15078, Stranglethorn Vale 27.4,76.8, listed cost **one Extravagant Extravaganza Coin 274026**. Exact coin tooltip identifies Fishing Extravaganza winners and Jang prize exchange. No gold conversion, guaranteed coin reward, event schedule or current stock invented.
- Ordinary bows, weapons and armour retain all retrieved named seller alternatives, price differences and stock limitations, including wide map footprints for moving merchants. No centre waypoint is fabricated from a range.

### Cross-version and unlocated cases are not usable-stock claims

Exact tooltips warn **19 versions** were added in Season of Discovery and may not be in Forever: Galvanic Icon **206386**, Insignias **209611–209626**, Protector's Sword **212582**, Legionnaire's Sword **212586**. These receive explicit ID-specific warnings rather than a direction asserting they can currently be bought. Merchant/cost rows remain visible only as qualified cross-version references. Galvanic Icon's rune/spell 415019 and one-copper Rune Broker listing are not proof of a current Forever relic/rune/vendor. Normal Horde Insignias 18834/18845/18846/18849–18853 do not inherit these warnings. Same-name item/class variants remain separate; class restrictions in source text do not rewrite catalogue eligibility.

**Defiler's Lamellar Girdle 20178 and Greaves 20182** have exact identities and Honored/Revered tooltip requirements, but no named seller/drop/quest route. Checked Rutherford inventory omits both exact IDs. Do not copy his other item stock or assume new Horde Paladin access. Absence is not proof of impossibility or an explicit unavailable flag; keep origin, price and current access unresolved. No catalogue entry is hidden/removed/reclassified.

## Fresh observed evidence, kept distinct from publication

[Three source-correlated community observation relationships](checkpoint7c_upstream_observations.json): Rugged Spaulders **5254 → Rethilgore 3914**, Robes of Arugal **6324 → Archmage Arugal 4275**, Belt of Arugal **6392 → Archmage Arugal 4275**, all Shadowfang Keep. Existing generator thresholds require evidence=observed, item→NPC drop relation, at least three installations and name/ID/community-instance corroboration. Local snapshot has three installs for each, with exact last-seen timestamps retained. These are actual additional community observation records, not promotion of a published vendor/Classic table into live proof. The original primary confidence/instructions remain unchanged; no drop rate, guaranteed loot or personal in-session observation asserted.

Fresh Everloot total 1,283 →1,317 locally, affecting 12 catalogue observation-count cells and three derived dungeon confidence records; two generated runtime summaries change, while the third retains stronger manual display precedence. Six previously unresolved dungeon cases remain unresolved; the 954 book live-check queue remains unchanged.

## Validation and continuation

**Local full validation PASS; GitHub PENDING.** Python compilation/full reconciliation succeeded with the audit User-Agent against all three configured services. Required files 3/3; all 24 TOC Lua modules parse; **14/14 workflow regressions** pass. Tests cover all 93 IDs, no recipe/pattern pollution, exact-variant warnings without spreading to normal Insignias, two genuine origin gaps, class-name variants, Honored-versus-Revered differences, standing-0 safeguard, fishing coin/event limits and Rune Broker uncertainty. Existing whole-catalogue deep comparisons and class/filter/material/settings/layout/performance tests pass.

Runtime index 1,977 →**2,070** summaries; equipment registry 14 →**107**; recipe registry remains **954**; added book IDs remain **759**. Generated changes are 93 new summaries plus the explicitly reviewed observed-source changes, not only provenance churn. All 7,707 identities, 36,341 class objectives, 1,253 runtime crafts/4,855 ingredients and original equip/class/source/filter facts remain intact.

Next: lower-level undocumented-source cases, then remaining source gaps and acceptance planning after CI/bot review. Research completion of these 93 cases is not current stock confirmation or completion of all 7,707 gear sources. No ZIP/build/package/tag/release/merge/main changes.
