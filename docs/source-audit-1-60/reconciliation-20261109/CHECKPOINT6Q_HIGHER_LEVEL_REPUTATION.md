# Checkpoint 6Q — 46 remaining reputation-only books

9 November 2026; baseline `283c0a0` after full vendor-cohort validation.

## Findings and evidence

Individually fetched all 46 higher-level reputation-only book XML/item pages: Blacksmithing 22, Leatherworking 19, Tailoring four, Alchemy one. Every exact book name, spell and created-equipment ID matches the independent catalogue mapping; no unavailable-item flag appears.

**29 cases have named vendors, with 31 seller relationships across six NPCs.** Lokhtos Darkbargainer accounts for 25 book references; other sellers include Lieutenant General Andorov, the Argent quartermasters and Dala Fairmaw. Guide text supplies exact sellers/zones, per-seller listed coin/item price, stock caveats and map footprints where available. Lokhtos and Andorov have named dungeon/raid locations without map coordinates; no ordinary outdoor vendor or exact pin is implied.

**17 physical book origins remain unlocated:** 12 Cenarion Circle Leatherworking books 275586–275597, Icebane plans 22703–22705, Stormcarver 251469 and Bagh Nakh 251470. All 17 exact craft-spell pages list only the matching teaching item; none establishes trainer, vendor, quest or enemy acquisition. Exact-ID checks of the previously retrieved related vendor inventories found no matching sale. Targeted searches for Bileblister Claws, Stormcarver and Bagh Nakh added identity/requirement references, not stronger named current sources. These cases are explicitly unresolved, without a fabricated quartermaster assignment, historical trainer claim, targeted farm or new required-book ID.

- [46 exact requirement/identity/hash cases](checkpoint6q_recipe_evidence.csv).
- [31 seller/price/stock/map references](checkpoint6q_vendor_references.csv).
- [17 unresolved origins and exact spell-page evidence](checkpoint6q_unlocated_origins.csv).
- [Six NPC pages, all 17 spell tables and empty exact inventory-match result](checkpoint6q_supplementary_evidence.json).

The overlay now distinguishes a named vendor reference from a requirement-only book whose origin is unknown. The full guide explains what was checked and why a reputation threshold alone is not a shopping direction. Published book requirements do not become finished-gear equip/class restrictions or current live access claims.

## Book-specific safeguards

**Icebane is not a faction-wide template.** Exact tooltip/JSON for [22703](https://www.wowhead.com/forever/item=22703) lists Exalted Argent Dawn; [22704](https://www.wowhead.com/forever/item=22704) lists Revered Argent Dawn; [22705](https://www.wowhead.com/forever/item=22705) instead lists **Revered Hydraxian Waterlords**, faction ID 749. The unusual Bracers reference is retained as a publication-level fact needing current verification, not “corrected” to another book's faction. No Lord Hydraxis/quartermaster source is inferred from the gate.

**Stormcarver and Bagh Nakh** exact pages list Revered Timbermaw Hold. Nearby Timbermaw vendor inventories and generic recipe references did not establish a sale for these exact book IDs. Their origins remain unresolved.

**Cenarion Circle** Claws/Clenchers books individually list Friendly; their corresponding belts/boots individually list Honored. No seller or slot-family acquisition rule is invented from the faction or from other Cenarion recipes.

**Alchemist's Stone book 13517** explicitly names Exalted **Barkskin Burrow**. Dala Fairmaw's published map is Mount Hyjal, but Barkskin Burrow is not silently replaced with Guardians of Hyjal. The tooltip does not establish a numeric faction ID. The exact item-currency price is retained by name/ID from the same source page; obtaining that currency and current purchase access remain unverified.

## Validation and continuation

**Local full validation PASS; GitHub PASS.** Source commit `6363333fe84a0db2883c745a8a9bd4d152701add`; [non-release CI 42567624643](https://github.com/magicaddons/getgear/actions/runs/42567624643) completed all steps; full logs confirm 14/14 regressions and 1,621 summaries. Inspected direct bot child/final HEAD `657d91e527e29dfdb787c4925d32eecd963409a1`: only provenance timestamp and three Everloot response hashes differ; generated runtime index and evidence match local validation. Python compilation/full online source reconciliation; three required files; all 24 TOC Lua module syntax checks; 14/14 regressions. Tests lock all 46 exact standings, vendor book IDs, omission of new required-book IDs for the 17 unresolved origins, the Hydraxian-versus-Argent negative case and separate Barkskin identity. Existing full catalogue/source/mat/class/filter/settings/layout/performance checks pass.

Index 1,575 → 1,621; additive runtime book IDs 537 → 566 (29 named book routes); reviewed registry 498 → 544. Only 46 additive generated CSV summaries change. Original identities/order, source/confidence/method fields, requiresLiveCheck, crafting ingredients and class/equip/filter behaviour remain intact. No published reference becomes confirmed live acquisition.

**94/94 reputation-only triage cases individually publication-researched:** 48 earlier low-level Nightclaw seller references, 29 higher-level named vendor routes and 17 still-unlocated book origins. Nightclaw shop/access conflicts remain open. The 16 earlier trainer-alternative cases also retain unknown physical-book origins; the current research does not claim all book origins known. Trainer triage now **544/886 researched; 342 remain**: 24 dungeon, 167 generic drop, 151 no-alternative. Next: remaining dungeon books, then generic drops and source gaps. Six finished-gear dungeon and 954 book live-verification routes unchanged. No ZIP/build/package, release, tag, merge or main changes.
