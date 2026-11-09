# Checkpoint 6S — 119 accessible higher-level drop books; 48 source checks blocked

9 November 2026; baseline `1008be5` after complete dungeon-book validation.

**Research coverage is PARTIAL: 119/167 higher-level generic-drop cases researched; 48 remain PENDING HTTP 403.** The full workflow validation below applies to the submitted 119-case changes and complete existing addon, not a completed 167-case research pass. No new runtime record was added for the blocked 48.

## Accessible source evidence

All 119 accepted cases have complete exact Forever XML/item responses. Book name, teaching spell and created-equipment ID match independent catalogue identities, with one explicit singular/plural exception: book 15738 says Heavy Scorpid Gauntlets, while gear 15078 is named Heavy Scorpid Gauntlet in the catalogue. Exact spell/created item IDs were checked; no gear name was changed and name assertions were not globally relaxed. No unavailable-item flag, vendor or quest table appears on these 119 pages.

- [119 exact cases, source hashes, learning skills and scope](checkpoint6s_recipe_evidence.csv).
- [10,982 NPC/location relationships](checkpoint6s_book_drop_references.csv), from 10,382 retrieved NPC rows. **34 tables contain 200 rows and may be truncated.** All other tables are also explicitly non-exhaustive references, not complete current loot inventories or recommended farms.
- [189 book/container relationships](checkpoint6s_container_references.csv).
- [357 book/object/location relationships](checkpoint6s_object_references.csv), from 182 object-table rows with multi-location expansion. Game objects retain their own identity and are not labelled enemy NPCs or bosses.
- [15 exact specialisation references](checkpoint6s_specialisations.csv).
- [Source zone identities, 49 independently fetched/title-matched NPC pages/maps, missing-location rows and two exact spell checks](checkpoint6s_location_evidence.json).

The overlay names narrow leads or clearly labelled zone examples for broad tables; the full guide includes all retrieved enemy names/locations, object/container alternatives and source-specific specialisations. Sparse outdoor NPC map footprints are reference ranges, not invented central waypoints or current sightings. **55 NPC rows omit location**; they remain under Location unverified. Negative location categories remain unresolved source IDs. A familiar encounter name is not used to guess its zone. All 64 positive source-zone identities were established from prior primary zone/NPC-map evidence or additional exact zone pages; zone identity does not confirm current book loot.

## Non-generic cases recovered within the old generic-drop cohort

- **Serenity book 12827** lists Blacksmithing Plans object 176325 in Stratholme; **Corruption book 12830** lists distinct object 176327 there. Names are not identity equality. Precise object position/presence/current contents remain unverified. These recipe-book relationships do not resolve the six separate finished-gear dungeon cases.
- **Edge of Winter book 17706** and **Gloves of the Greatfather book 17722** list Smokywood Pastures Special Gift 17726 and Ticking Present 21327. Gift/container access and current event availability/dates remain unverified; no year-round availability or guaranteed reward is claimed.
- **Warder's Boots book 251400** and **Black Cord book 254044** have no named acquisition source in the retrieved tables. Exact spell pages list only the matching teaching books. Both origins remain unresolved, with no newly required-book ID or fabricated trainer/vendor/farm.
- **Heavy Scorpid Gauntlet** retains its book-specific Blackrock Soldier reference, distinct from other Scorpid slots; specialisations are not spread across related patterns. Existing crafted-item identities, gear class/equip gates and ingredients remain primary.

## Exact source-access blocker

[48-case pending register](checkpoint6s_source_access_pending.csv) records each untouched gear/book/spell ID, profession, attempted URL/stage, HTTP 403 and any successfully received partial XML hash. Requests used the generator's configured User-Agent. A diagnostic retry of book 12706 XML also returned 403. The response did not establish the cause; no account/credential diagnosis is inferred. GitHub repository and CI access remained working. Successful same-batch response bytes were reused for the explicit name exception, never fabricated for blocked pages. No repeated blanket retry or unsupported Classic fallback was substituted for current publication evidence.

Targeted register integrity confirms **119 reviewed + 48 pending = all 167 selected IDs**, with no overlap. Partial XML by itself was not enough to enter a blocked case into runtime. Future work should retry the pending IDs only when source access recovers, rather than repeat the 119 completed cases.

## Validation and remaining scope

**Local full validation PASS; GitHub PASS.** Source commit `0dce24d6925468a5eea9470d04ea2b61212f06db`; [non-release CI 42570251543](https://github.com/magicaddons/getgear/actions/runs/42570251543) completed all steps; full logs confirm 14/14 regressions and 1,764 summaries. Inspected direct bot child/final HEAD `f391c847534a8897cab3cc0320ae077d77a97718`: only provenance timestamp and three Everloot response hashes differ; generated runtime index and evidence match local validation. Python compilation/full online reconciliation, three required files, syntax for all 24 TOC modules and 14/14 regressions. Source-table negative location categories were explicitly retained during research parsing; no failed draft parse entered the reviewed register. New tests cover all 119 accepted identities, two distinct object IDs, gift-access caveats, unknown origins without new required IDs, the singular-name exception and explicit 200-row truncation. Existing full catalogue/source/material/class/filter/settings/layout/performance tests pass.

Index 1,645 → 1,764; additive runtime book IDs 590 → 707 (117 publication routes; two unlocated origins omitted); reviewed registry 568 → 687. Generated CSV semantic changes are only 119 additive summaries. Original identities/order, source/confidence/methods, requiresLiveCheck, ingredients and class/equip/filter rules remain unchanged. No published reference becomes confirmed live acquisition.

Generic-drop cohort **173/221 researched** (54 earlier lower-level +119 here); 48 higher-level cases remain source-access-blocked. Trainer triage **687/886 researched; 199 remain**: these 48 generic-drop cases and 151 no-alternative cases. Current plan: finish this checkpoint's CI/bot review, then investigate independent no-alternative work while retaining the exact blocked queue. All six finished-gear dungeon and 954 book live-verification routes remain open. No ZIP/build/package, release, tag, merge or main change.
