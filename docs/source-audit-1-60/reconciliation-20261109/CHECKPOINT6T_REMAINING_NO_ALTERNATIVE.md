# Checkpoint 6T — 151 remaining no-alternative cases

9 November 2026; baseline `5fb0bed` after validated partial generic-drop research.

## Complete case checks; explicit acquisition gaps

All 151 higher-level no-alternative entries individually investigated: Leatherworking 61, Blacksmithing 39, Tailoring 35, Enchanting 10, Engineering six. **Four named book-drop routes; one unavailable-book version; 146 origins still unlocated.** This is completion of the selected publication research, not discovery of all current acquisition sources.

[151 exact cases and source methods](checkpoint6t_recipe_evidence.csv); [four named drop/NPC/map references](checkpoint6t_book_drop_references.csv); [146 explicitly unlocated origins](checkpoint6t_unlocated_origins.csv); [four name exceptions](checkpoint6t_name_exceptions.csv); [all response hashes, exact spell tables and NPC evidence](checkpoint6t_publication_evidence.json).

| Book | Gear | Published book-drop reference |
|---:|---|---|
| 251388 | Hard Gold Leggings | Kurzen Jungle Fighter — Stranglethorn Vale |
| 251399 | Sentinel's Boots | Ragglesnout — Razorfen Downs |
| 254022 | Gilded Handwraps | Saltscale Oracle — Stranglethorn Vale |
| 254046 | Golden Cord | Amnennar the Coldbringer — Razorfen Downs |

The two outdoor NPC pages supply 15 and six map points, represented as reference footprints. Dungeon NPCs have no usable mapper coordinates; no precise pin is invented. Enemy rank is not current loot proof. These references concern the books, not drops of finished crafted gear; no rate, guaranteed reward or exclusive farm is claimed.

For **146 other cases**, exact book pages match the catalogue book/spell/gear IDs and learning skill, and exact spell pages list those same teaching items, but the checked sources establish no named trainer, vendor, enemy, quest or lootable-object acquisition. The old AHledger trainer label is not confirmed teaching; missing trainer tables are not proof trainers can never teach the recipe. No quartermaster, price or farm is inferred. These entries explicitly show unresolved learning/origin instead of inventing an instruction or adding a required-book ID. Book learning skill remains distinct from crafted-gear equip level and recipe difficulty.

## Unavailable look-alike and names

**Golden Scale Gauntlets gear 217273/book 217274/spell 439120** is a distinct version whose exact book page flags unavailable and lacks a teaches-recipe table. The spell creates gear 217273 but only offers a see-also link to normal recipe 11643/gear 9366, not a confirmed teaching source. The new warning does not remove or reclassify that gear, add a required book, or copy the normal version's quest route.

**Normal Golden Scale Gauntlets 9366/book 9367** retain their earlier published Origins of Smithing quest reference. Shared display name does not merge IDs or spread the unavailable flag. Cumulative reviewed unavailable-book conflicts now five.

Four explicit singular/plural pairs (books 252917, 252926, 252881, 252884) have published Shoulders names while the catalogue uses Shoulder. Both book and spell page created-item IDs were independently matched. Catalogue names are unchanged; name assertions were not globally relaxed.

## Canonical-source fallback and limits

The initial short/legacy endpoint pass accepted 123 books, with four name exceptions, one unavailable case and 23 HTTP403 reads. Complete XML/HTML bytes existed for the exceptions and unavailable case. Public, normally linked **canonical URLs** then returned complete data for all 23 remaining book pages and all 151 spell pages. No account, proxy/IP change, captcha bypass or fabricated response was used; the reason shortened endpoints failed was not established.

Book evidence methods: **128 XML+HTML response pairs**, **23 canonical HTML pages**. The latter supply structured main-item identity/equipment metadata and JSON-encoded tooltip text, decoded without executing page scripts; no XML hash is claimed for an unfetched response. All 151 spell pages' Create Item effects match the exact gear IDs. 150 name the matching teaching book; the unavailable version instead has the separate normal-recipe reference. No named trainer table was supplied by these pages. Canonical fallback recovered this cohort; the 48 generic cases from 6S are still a separate pending queue until individually retried and validated.

A targeted read-only profession-heading audit found no affected higher-level no-alternative record that would infer Trainer from an estimate while required skill was unknown. Existing UI learning/skill behaviour and stronger known-recipe state are unchanged; no unrelated UI edit was made.

## Validation and continuation

**Local full validation PASS; GitHub PASS.** Source commit `eada142a6f721db2f6dcba3899aab72d8400ba55`; [non-release CI 42573584742](https://github.com/magicaddons/getgear/actions/runs/42573584742) completed all steps; full logs confirm 14/14 regressions and 1,915 summaries. Inspected direct bot child/final HEAD `433a0847dc457e0578eb3fcaed1fbba6021e62d1`: only provenance changes: Everloot total 1,124 → 1,125, last-page byte count, response hashes and timestamps. Generated runtime index and all derived evidence remain identical to local validation. Python compilation/full online reconciliation, three required files, all 24 TOC Lua module syntax checks and 14/14 regressions. New tests cover all 146 explicit gaps without new book IDs, all four exact enemy routes and no finished-gear drop claim, plus separate unavailable/normal gauntlet versions. Full catalogue/class/source/material/settings/filter/layout/performance invariants pass.

Index 1,764 → 1,915; additive runtime book IDs 707 → 711 (four newly located routes); reviewed registry 687 → 838. Only 151 additive generated CSV summaries change. Original source/confidence/method fields, identities/order, requiresLiveCheck, class/equip rules, filters/settings and recipe ingredients remain intact. Published references do not become confirmed live claims.

**174/174 no-alternative triage entries publication-researched**, including earlier 16 trainer alternatives/seven book-drop routes, these four drops, one version conflict and 146 unresolved origins. Trainer triage **838/886 researched; 48 generic-drop cases remain** from 6S. Next: canonical-page recovery of those exact pending IDs after CI/bot review. Six finished-gear dungeon links and 954 book live-verification routes remain open. No ZIP/build/package, release, tag, merge or main changes.
