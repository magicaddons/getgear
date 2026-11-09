# Checkpoint 6I — seven remaining lower-level non-Favor vendor books

9 November 2026; baseline `285cc40` after Leatherworking vendor closeout.

## Exact source checks

Fetched exact Forever XML and item pages for six Blacksmithing and one Engineering book; matched book name, spell ID and created equipment ID in teaches-recipe tables. Sold-by tables supply 12 exact book/vendor references. Independently fetched all ten distinct vendor NPC pages (including the two shared reputation vendors) to resolve zone names and published map ranges. Each seller keeps its own listed coin price and stock field, with live prices/discounts/stock/access explicitly unverified.

[Blacksmithing case/hash evidence](checkpoint6i-blacksmithing_recipe_evidence.csv), [Engineering case/hash evidence](checkpoint6i-engineering_recipe_evidence.csv), [Blacksmithing vendor/map references](checkpoint6i-blacksmithing_vendor_references.csv), [Engineering vendor/map references](checkpoint6i-engineering_vendor_references.csv).

| Crafted item ID | Gear | Book page | Spell | Learning skill |
|---:|---|---|---:|---:|
| 3851 | Solid Iron Maul | [10858](https://www.wowhead.com/forever/item=10858) | 3494 | 130 |
| 3849 | Hardened Iron Shortsword | [12162](https://www.wowhead.com/forever/item=12162) | 3492 | 135 |
| 277040 | Cloudy Skyforged Helm | [276976](https://www.wowhead.com/forever/item=276976) | 1301526 | 175 |
| 277041 | Cloudy Skyforged Pauldrons | [276977](https://www.wowhead.com/forever/item=276977) | 1301527 | 175 |
| 277048 | Azure Skyforged Helm | [276984](https://www.wowhead.com/forever/item=276984) | 1301534 | 175 |
| 277049 | Azure Skyforged Pauldrons | [276985](https://www.wowhead.com/forever/item=276985) | 1301535 | 175 |
| 4372 | Lovingly Crafted Boomstick | [13309](https://www.wowhead.com/forever/item=13309) | 3939 | 120 |

## Actionable directions and related quest supplies

- **Solid Iron Maul, book 10858:** Jannos Ironwill in Arathi Highlands, Muuran in Desolace, Jazzrik in Badlands. Current source tables differ in listed prices and stock-limit fields; no universal respawn time, unlimited stock or live price is asserted. This plan matters for the two Mauls required by Horns of Frenzy, so the Barbaric Iron Helm guide now also names these supply-plan sellers. Quest delivery items remain informational and do not change the helm’s crafting reagents.
- **Hardened Iron Shortsword, book 12162:** Jutak in Stranglethorn Vale, Sumi in Orgrimmar, Kaita Deepforge in Stormwind City. Stock/access caveats apply separately to each published listing.
- **Lovingly Crafted Boomstick, book 13309:** Fradd Swiftgear in Wetlands, Jinky Twizzlefixxit in Thousand Needles. Both named routes remain, with individual prices/map references and current stock unverified.
- **Cloudy Skyforged Helm/Pauldrons, books 276976/276977:** exact tooltips require Friendly with Earthen Ring; seller Sutara Plainstalker in Mulgore.
- **Azure Skyforged Helm/Pauldrons, books 276984/276985:** exact tooltips require Friendly with Kirin Tor; seller Archmage Alvareaux in Alterac Mountains.

Every book’s reputation gate was read directly, not copied from another profession’s matching family. No drop/quest table was returned for these seven exact books on the fetched pages; absence there does not prove an exclusive vendor route. All publication/map information stays separate from original item confidence, class/gear gates and material lists. No new live-source confirmation or new map pins.

## Validation and remaining work

**Local PASS:** Python compile/full online reconciliation, all 3 required-file checks, 24 Lua module syntax and 14/14 regressions. Seven new summaries and one existing quest-supply detail updated; index 1,194 → 1,201, runtime additive book IDs 181 → 188. CSV row identities, original source facts/roles, recipe/material classifications and gates retained; whitespace check passed with existing CSV CRLF recognised. **GitHub PASS:** [Non-release CI 42555186373](https://github.com/magicaddons/getgear/actions/runs/42555186373) PASS: full source reconciliation, three required files, syntax for all 24 modules, all 14 regression outputs, artifacts and report commit. Source `96f357e00872bbc42fbcb9c8ec619b6bcb3c4b33`; verified bot final HEAD `35485f4257c84b07e38cecb64cabbb3c9b15b253`. Full logs and bot parent/diff inspected: evidence/index match local validation, only provenance timestamps/response hashes differ. Regression covers all seven exact books/skills, named multi-vendor routes, all four item-specific reputation gates and the cross-referenced quest-supply description. Full-catalogue existing-field invariants and previous filter/settings/material checks remain enforced.

All **45/45 level-1–30 non-Favor vendor leads** have now received exact book research: **42 supported publication-level directions plus 3 unavailable-book conflicts**. This is research coverage, not 45 confirmed live vendors. Across the complete non-Favor vendor cohort, 45/131 researched and 86 higher-level cases remain. Favor cohort 71/188 and quest/mixed cohort 8/37 unchanged. Next lower-level groups: 17 dungeon/book-drop leads, 48 reputation-only leads, 54 generic-drop leads and 23 no-alternate-source leads. Six dungeon and 954 recipe-book live-verification queues remain open. No ZIP/build/package, tag, release, merge or main action.
