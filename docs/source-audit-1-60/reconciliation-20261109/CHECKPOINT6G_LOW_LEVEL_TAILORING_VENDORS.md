# Checkpoint 6G — 13 lower-level non-Favor Tailoring vendor leads

9 November 2026; baseline `f00932b` after the quest-book CI closeout.

## Evidence result

Researched all 13 level-1–30 Tailoring entries in the non-Favor vendor cohort. Ten books have exact teaches-recipe tables confirming craft spell and created item, named sold-by tables, and independent NPC-page map references. Twenty-nine book→vendor relationships are retained with each vendor’s own listed coin price, stock-limit field and NPC map source. Listed prices vary by vendor/discount; they are not guaranteed live quotes. Stock=1 is treated as a limited-stock publication reference, never proof of a current remaining item. No new navigation pins were created.

[Thirteen case records and XML/HTML hashes](checkpoint6g_recipe_evidence.csv); [29 seller/NPC map references and hashes](checkpoint6g_vendor_references.csv). The reviewed register contains exact prices, source NPC IDs, complete published map data and the source hashes. Descriptions include named sellers/zones in the overlay; full guide adds published map-coordinate ranges, individual listed prices and stock/access caveats. Coordinate ranges are the fetched NPC map’s actual ranges, not a claimed current sighting or averaged invented point.

## Ten actionable publication-level books

| Gear ID | Gear | Exact book page | Learning skill | Vendor count |
|---:|---|---|---:|---:|
| 6240 | Blue Linen Vest | [6270](https://www.wowhead.com/forever/item=6270) | 35 | 5 |
| 6242 | Blue Linen Robe | [6272](https://www.wowhead.com/forever/item=6272) | 45 | 5 |
| 6263 | Blue Overalls | [6274](https://www.wowhead.com/forever/item=6274) | 75 | 5 |
| 6264 | Greater Adept's Robe | [6275](https://www.wowhead.com/forever/item=6275) | 90 | 6 |
| 4319 | Azure Silk Gloves | [7114](https://www.wowhead.com/forever/item=7114) | 120 | 2 |
| 4322 | Enchanter's Cowl | [14630](https://www.wowhead.com/forever/item=14630) | 130 | 2 |
| 277046 | Cloudy Stormsewn Cowl | [276982](https://www.wowhead.com/forever/item=276982) | 175 | 1 |
| 277047 | Cloudy Stormsewn Epaulets | [276983](https://www.wowhead.com/forever/item=276983) | 175 | 1 |
| 277054 | Azure Stormsewn Cowl | [276990](https://www.wowhead.com/forever/item=276990) | 175 | 1 |
| 277055 | Azure Stormsewn Epaulets | [276991](https://www.wowhead.com/forever/item=276991) | 175 | 1 |

Four exact book tooltips, 276982/276983 and 276990/276991, identify **Friendly with Earthen Ring** and **Friendly with Kirin Tor**, respectively. This is book-specific purchase/learning reference information, not a new class or equip gate. No Friendly condition was copied onto unrelated linen, wool or silk patterns. Books 276982/276983 list Sutara Plainstalker in Mulgore; 276990/276991 list Archmage Alvareaux in Alterac Mountains. The source NPC pages were independently fetched to resolve zone names and map references.

## Three availability conflicts, not shopping recommendations

Exact Forever item pages for [Phoenix Bindings book 211247](https://www.wowhead.com/forever/item=211247), [Invoker’s Cord book 215369](https://www.wowhead.com/forever/item=215369) and [Invoker’s Mantle book 215370](https://www.wowhead.com/forever/item=215370) say the book is unavailable to players and omit the teaches-recipe table. Their XML tooltips still name the expected craft spell, and imported sources list vendors/drops. This is an unresolved availability conflict, potentially inherited/historical data, not proof of a current purchase/drop route or proof that the finished gear can never be learned another way.

The initial identity-research assertions failed closed for these three missing recipe tables. They are recorded separately with `published-forever-availability-conflict` and `warningOnly=true`; warnings appear inside the addon. No shop directions were promoted from their conflicting tables. No new required book/pattern learning gate is added for these warning-only entries; all catalogue identities and existing eligibility remain intact pending stronger evidence.

## Validation and continuation

**Local PASS:** Python compile/full online reconciliation, 3 required files, all 24 Lua modules, all 14 regressions and complete pre-existing item-field invariants. Thirteen additive summaries changed; original CSV identities, source roles, recipe/material classifications and gates retained. Source index 1,156 → 1,169; runtime additive book IDs 147 → 156 (one supported case already had a book ID). Initial local regeneration required the conflict summaries to include the explicit live-unverified caveat; corrected wording before testing/CI, with no source-fact change. **GitHub PASS:** [Non-release CI 42553881354, attempt 2](https://github.com/magicaddons/getgear/actions/runs/42553881354/attempts/2) PASS, including all 14 regression outputs, full source reconciliation, required files and 24-module syntax. Source commit `3c994430d106775553d4fe05bc3617851487f97d`; inspected bot final HEAD `f99901f30b3757a159221de2b7e472afc8d851fb`. Evidence index and CSV/README output exactly match local validation; only generation/source-as-of timestamps and three Everloot response hashes changed. Attempt 1 failed at Playfulls HTTP 403 before tests; one failed-job retry passed unchanged. No failed or pending validation remains unexplained. Tests cover exact ten book IDs/skills, published map visibility, limited-stock wording, four item-specific reputation gates, absence of gate leakage and all three warning-only cases. Full-catalogue deep invariants remain enforced. Source materials, item stats, equip gates, class filters, settings and saved states are unchanged.

Non-Favor vendor cohort: 13/131 researched (including 3 conflicts), 118 remain; at gear levels 1–30, 13/45 researched, 32 remain (25 Leatherworking, 6 Blacksmithing, 1 Engineering). Favor review remains 71/188; quest/mixed 8/37. All six dungeon and 954 recipe-book live-verification queues remain open. No live-stock confirmation, ZIP/build/package, release, tag, merge or main action.
