# Checkpoint 7A — original 68 Hyjal vendor books integrated with exact gates

9 November 2026; baseline `4861faf8601c9be83978f7053a3f24737d6b687b` after completed 886-case trainer-triage publication research.

## Research and in-addon result

The earlier 68-book phase had publication-level guide references, only some individually accessible gate tooltips, and documentation-only findings. Runtime still displayed a generic Aisarra/reputation/quest/slot warning. This batch fetches **68 canonical book pages and 68 exact spell pages**, all successful, to supply individually evidenced requirements inside the guide. Every catalogue name, book ID, profession, skill 300, teaching spell and Create Item gear ID matches. Both non-linear spell mappings at books 273952/273953 remain correct; no book-offset formula used.

[All 68 exact cases, costs and source hashes](checkpoint7a_hyjal_books.csv); [per-book requirements](checkpoint7a_hyjal_gates.csv); [merchant inventory, reagent tables and response hashes](checkpoint7a_hyjal_publication_evidence.json). [Updated 68-book research index](vendor_book_research_index.csv) preserves older community-row counts while updating exact-source/gate proof; the anonymous community row is not a second merchant.

All exact sold-by tables name **Aisarra Nightmeadow 264797, Mount Hyjal**. Independently fetched NPC page lists all 68 exact book IDs plus four separately researched Spiritcaller versions (72 total), with matching costs. Published NPC map point **71.0,51.2**, not an observed current location. No current faction access, unlimited stock or live vendor price inferred.

| Exact tooltip gate | Books | Published book purchase cost |
|---|---:|---|
| Friendly Guardians of Hyjal + Friendly Advice completion | 17 | eight Malleable Essence of Nature 274030 |
| Further Guardians progress + Gloves specialisation, rank unspecified | 17 | six essences |
| Further Guardians progress + Shoulders specialisation, rank unspecified | 17 | six essences |
| Further Guardians progress + Boots specialisation, rank unspecified | 17 | six essences |

Each requirement and cost independently read from its own book; no family-wide copied gate. Exact Friendly Advice quest ID, giver, objectives and prerequisite chain remain unresolved after targeted searching. Do not substitute similarly named quests or invent a pin. Slot specialisations are not base profession specialisations or new gear/class eligibility restrictions. Book learning skill, recipe purchase cost and quest/slot gates remain separate from existing craft difficulty, equip rules and ingredients.

The exact [Malleable Essence of Nature item](https://www.wowhead.com/forever/item=274030/malleable-essence-of-nature) tooltip supplies a **published disenchanting lead: items from Hyjal Summit or Barrow Deeps**. Add this qualified direction to all 68 entries and four earlier Spiritcaller variants 276538–276541. Exact eligible items, yields, skill/access, current availability and live disenchant tables remain unverified. No rates, guaranteed quantities or invented targeted farm. The purchase cost does not alter any crafting ingredient list.

## Narrow generator change and validation

Reviewed metadata can supersede **only the same generator iteration's generic Hyjal community-vendor hint**, for books 273952–274019 with an Aisarra vendor route and vendor-reference classification. An explicit local marker is false for observed/manual/dungeon entries; existing stronger source precedence and runtime manual summary preservation remain intact. No general precedence relaxation or item reclassification.

**Local full validation PASS; GitHub PENDING.** Python compilation/full online reconciliation completed against all three configured sources with the audit User-Agent. Required files 3/3, Lua syntax 24/24 modules, **14/14 regressions**. A preliminary check ran before regeneration completed; final checks were run sequentially after completion. The old broad test expected the obsolete generic warning, and was replaced by exact per-book gates, individual costs, rank limits and slot non-propagation assertions. All 7,707 gear identities, 36,341 nine-class objectives, 1,253 runtime crafts/4,855 ingredients, source-confidence safeguards, settings, filters, layout and performance checks pass.

Runtime index remains **1,963 summaries**, additive book IDs **759** (68 IDs already present); reviewed registry 886 → **954**. Generated CSV semantic changes: exactly 68 additiveSummary cells; four further runtime entries gain only the new qualified currency detail. All original source fields, confidence, ingredients, classes/equip gates and live-check queues unchanged. **954/954 queued book cases individually publication-researched and represented in reviewed runtime metadata**, not current live-acquisition confirmation. All 954 live book routes and six finished-gear dungeon links remain unverified. 165 no-named-route origins, 16 further physical book origins with trainer alternatives, five unavailable versions, Nightclaw access and exact quest/reputation interpretation gaps remain explicit.

Next: audit other gear-source gaps and consolidate remaining research versus in-client acceptance work after non-release CI/bot review. No ZIP/build/package/tag/release/merge/main changes.
