# Checkpoint 5E — vendor-book references 273974–273980 (2026-11-09)

**Scope:** Seven distinct pattern/plan IDs and seven associated crafted equipment IDs, selected as the next sequential group from `recipe_vendor_book_checks.csv`. All seven now have individually retrieved **exact WoW Forever item-page tooltips**. These are published database claims, **not observed in-game vendor stock, transactions, prices or accessibility**. No item, Lua code, recipe, ingredient, filter or source confidence was modified.

| Book / finished equipment / spell | Direct Forever reference | Published acquisition gate on exact book page | Published database vendor | Live verified? |
| --- | --- | --- | --- | --- |
| **273974** Pattern: Manaflare Mantle / 273906 / 1292943 | [Exact book](https://www.wowhead.com/forever/item=273974/pattern-manaflare-mantle) | **Tailoring 300**, further Guardians of Hyjal reputation and **Shoulders** specialization. Exact reputation threshold not stated. | Aisarra Nightmeadow, Mount Hyjal; page displays cost 6 (not live price verified) | **No** |
| **273975** Pattern: Manaflare Boots / 273907 / 1292944 | [Exact book](https://www.wowhead.com/forever/item=273975/pattern-manaflare-boots) | **Tailoring 300**, further Guardians of Hyjal reputation and **Boots** specialization; exact threshold not stated. | Aisarra Nightmeadow, Mount Hyjal; page displays cost 6 | **No** |
| **273976** Plans: Justice Leggings / 273908 / 1292945 | [Exact book](https://www.wowhead.com/forever/item=273976/plans-justice-leggings) | **Blacksmithing 300**, **Friendly** with Guardians of Hyjal and **Friendly Advice** quest. Do **not** add a slot-specialization gate to this exact leg plan. | Aisarra Nightmeadow, Mount Hyjal; page displays cost 8 | **No** |
| **273977** Plans: Justice Gauntlets / 273909 / 1292946 | [Exact book](https://www.wowhead.com/forever/item=273977/plans-justice-gauntlets) | **Blacksmithing 300**, further Guardians of Hyjal reputation and **Gloves** specialization; exact threshold not stated. | Aisarra Nightmeadow, Mount Hyjal; page displays cost 6 | **No** |
| **273978** Plans: Justice Spaulders / 273910 / 1292947 | [Exact book](https://www.wowhead.com/forever/item=273978/plans-justice-spaulders) | **Blacksmithing 300**, further Guardians of Hyjal reputation and **Shoulders** specialization; exact threshold not stated. | Aisarra Nightmeadow, Mount Hyjal; page displays cost 6 | **No** |
| **273979** Plans: Justice Greaves / 273911 / 1292948 | [Exact book](https://www.wowhead.com/forever/item=273979/plans-justice-greaves) | **Blacksmithing 300**, further Guardians of Hyjal reputation and **Boots** specialization; exact threshold not stated. | Mount Hyjal vendor on book page; named Aisarra on the repository's published reference and [independent Forever Paladin recipe listing](https://conquestcapped.com/guides/wow-forever/wow-forever-paladin-tier-set/). Cost 6 in source listing. | **No** |
| **273980** Plans: Justice Legplates / 273912 / 1292949 | [Exact book](https://www.wowhead.com/forever/item=273980/plans-justice-legplates) | **Blacksmithing 300**, **Friendly** with Guardians of Hyjal and **Friendly Advice** quest; distinct from Justice Leggings and the other three Paladin specialisations. | Mount Hyjal vendor on book page; [exact Forever craft spell](https://www.wowhead.com/forever/spell=1292949/justice-legplates) names Aisarra. Published cost 8 in source listing. | **No** |

## Item-ID and provenance checks

- Programmatically checked the seven queue rows against the committed `recipe_vendor_book_checks.csv`: **7/7 unique book IDs**, **7/7 unique finished gear IDs**, **7/7 mapping to the expected skill and spell IDs**, and **7/7** retain `classification=vendor-reference`, `requiresLiveCheck=True`, and confirmed pre-existing recipe material status.
- Each of the seven records has one named vendor lead (`Aisarra Nightmeadow`, Mount Hyjal) and **one second vendor entry with neither NPC nor zone**. The empty entry is a placeholder, **not proof of a second vendor**. None of these anonymous rows was promoted.
- The exact Forever book tooltip is **direct evidence of the displayed skill and purchase gate**, not server-side evidence that the vendor currently stocks the book or the player can buy it. The Wowhead vendor count and stock icon are database metadata. Currency values shown (6 or 8) are reference prices, **not live-confirmed purchase costs**.
- All named `Justice` crafting entries in this checkpoint are **crafted equipment** (IDs 273908–273912) and must not be confused with same-named higher-tier raid loot. No item-to-source classification is changed.
- The wording "further progress your reputation" **does not specify a precise reputation rank**; do not invent Honored/Revered thresholds. For the legs plans the quest and Friendly requirement are exact; do not infer a glove/shoulder/boot specialisation gate for them.
- Existing equipment IDs, class masks, material lists, item-level gates, green BoE and armour-only overlay logic remain unchanged.

## Research progress and validation

- Vendor-book research: previous **22/68** + seven exact-book references = **29/68 individually reviewed**; **39/68 not yet individually reviewed**.
- **All 68/68** vendor references remain unverified as live merchant stock, and the separate **886** trainer-labelled book routes are not yet reconciled. Thus **954** total book-source routes remain open, not 925; research coverage is not source confirmation.
- **6** unresolved dungeon-source item links remain as before, including two unverified container-loot leads. Equipment-source remainder, final audit, and live game acceptance checks are still ahead.
- **Targeted validation PASS:** seven-record source CSV mapping, unique IDs, named/anonymous vendor duplication, and unchanged queue flags checked programmatically before documentation commit. This is **not** a complete Lua test run.
- **No new non-release CI run:** documentation-only change does not match source/logic workflow triggers; environment cannot fetch the public repository for standalone Lua testing, and available connector does not expose workflow-dispatch. Latest full non-release PASS remains [GitHub Actions 42493307958](https://github.com/magicaddons/getgear/actions/runs/42493307958), validating the unchanged addon code. Do not claim a fresh CI result.
- No ZIP, tag, release, `main` merge, or public build.

## Next bounded checkpoint

Research **273981–273987** (seven exact Forever book IDs), paying particular attention to Holy/Protection/Retribution variant names and gloves vs. shoulders vs. boots specialization, while never confusing craftable tier alternatives with raid drops. After vendor-book research, proceed with 886 trainer-labelled book sources, other equipment source gaps, final catalogue/source/filter regression audits and targeted Forever in-game acceptance.
