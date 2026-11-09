# Checkpoint 6P — 86 remaining non-Favor vendor-book cases

9 November 2026; baseline `9ae0be9` after complete quest-cohort validation.

## Results and traceable evidence

All 86 higher-level entries in the other-vendor triage individually investigated: 25 Blacksmithing, 35 Leatherworking, 23 Tailoring, three Engineering. **85 supported publication-level book routes; one unavailable-book conflict.** Exact XML names, teaching spells and created item IDs match the catalogue for the supported cases; the conflict has matching tooltip identity but no teaches-recipe table.

- [86 identity/skill/hash cases](checkpoint6p_recipe_evidence.csv).
- [108 seller relationships across 45 independently fetched NPC pages/maps](checkpoint6p_vendor_references.csv); 35 limited-stock table references and 73 stock-quantity-unverified references. Per-seller listed coin/item costs remain reference prices, not guaranteed current charges or stock.
- [137 alternate book/NPC/location references](checkpoint6p_book_drop_references.csv), separate from finished crafted equipment. Broad/historical-capable source tables are not an exclusive farm, live loot proof or rate.
- [Four book/quest alternatives](checkpoint6p_quest_references.csv), involving three quest IDs.
- [56 specific purchase/learning condition records](checkpoint6p_purchase_conditions.csv): 39 exact named-faction standings, 10 Leatherworking specialisations, four Hyjal quest/slot conditions and three unresolved multi-faction interpretations.
- [NPC maps/hashes and supplementary public-source record](checkpoint6p_location_evidence.json).

Overlay summaries name sellers/zones and book-specific gates. Full guide adds reference map footprints, individual prices/stock caveats, alternatives and conditions. Plugger Spazzring and Shen'dralar Provisioner have named dungeon locations but no mapper coordinates; no precise point is fabricated. Original gear/recipe/source/class/filter facts are preserved.

## Distinct versions and gates

**Turtle Scale Gloves:** [normal book 8385](https://www.wowhead.com/forever/item=8385) teaches spell 10509 for gear 8187, with supported vendor/drop references. [Book 217271](https://www.wowhead.com/forever/item=217271) instead names spell 439118 for different gear 217270; its exact page says unavailable to players and lacks a teaches-recipe table. A warning is attached only to that version, without a new required book ID, deletion or eligibility change. Same display name is not identity equality. No Rock Elemental/vendor reference is copied onto the unavailable version. Cumulative reviewed availability conflicts now four, including the earlier three Tailoring books.

**Spiritcaller 276542–276545:** exact book pages list Aisarra Nightmeadow and item-currency 274030, whose same-page identity is **Malleable Essence of Nature**. Kilt costs eight; Gloves/Mantle/Boots six each. Kilt's exact condition is Friendly Guardians of Hyjal plus Friendly Advice. Each other book names its own Gloves/Shoulders/Boots specialisation and further reputation progress without an exact rank. No Kilt rank, quest or slot is copied across them. Current item-currency acquisition and purchase gates remain unverified.

**Centaur conditions:** books 251390/251458 list Honored Magram and Exalted Gelkis, whereas Stormcloth Gloves 254682 lists Exalted Magram and Honored Gelkis. The pages do not establish how those conditions combine or whether they apply to seller access, learning or purchase. Friendly quest reward leads coexist. Addon text explicitly declines to infer cumulative standings, seller alternatives or a quest bypass; no new gear filter is introduced.

**Magnus Frostwake:** the three Blacksmithing books' guide details include a [published Spectral Essence/Scholomance ghost-access lead](https://www.wow-professions.com/forever/npc/magnus-frostwake), in a house at Caer Darrow. This guide can retain historical requirements; current trinket/quest/visibility access is not independently verified. Only the directly researched access context is used, not old comments as live proof.

Ten exact Leatherworking books retain published Dragonscale/Tribal/Elemental requirements. Named reputation requirements come from each exact tooltip and faction ID (Argent Dawn, Timbermaw Hold, Zandalar Tribe, Cenarion Circle); no rank is inferred from neighbouring slots or price.

## Quest alternatives and source-access limits

- [Big, No, MASSIVE Iron Axes 92818](https://www.wowhead.com/forever/quest=92818/big-no-massive-iron-axes): choice between plans 251390/251458, minimum-level field 30. Quest page directs two Massive Iron Axes to Grolkar 253163 in Magram Village, Desolace, with Friendly Magram. Book-table faction differs from the page's presentation; current faction access remains unresolved. Choosing one book is not both rewards.
- [I Need a Tailor 92814](https://www.wowhead.com/forever/quest=92814/i-need-a-tailor): choice of Stormcloth Gloves pattern 254682 or Silk Reagent Bag pattern 253974, minimum-level field 30. Quest page directs one White Bandit Mask to Molkar, Gelkis Village, with Friendly Gelkis. Current prerequisites/learning gates remain unverified, distinct from the higher book-tooltip standings.
- **Step Two: More Rock 96026:** the exact Mithril Warhammer book 251460 table lists a guaranteed book reward, minimum 38 and Horde. Direct quest retrieval failed HTTP 403 and the connected tool could not read its canonical page. No giver, objective or precise Riverglades location was invented. The supported vendor route remains available; the quest alternative is explicitly partial publication evidence.

Some direct quest requests returned 403 after all book/NPC pages had been fetched successfully. Connected canonical pages supplied the two centaur quest texts; the third remains limited to its exact book-table facts. No source hash is fabricated for a connected-only page, and partial research is not represented as a fully known quest chain.

## Validation and remaining work

**Local full validation PASS; GitHub PASS.** Source commit `79f94fb5cab9ab931f5166a9ad78c80900834806`; [non-release CI 42566787446](https://github.com/magicaddons/getgear/actions/runs/42566787446) completed all steps; full logs confirm 14/14 regressions and 1,575 summaries. Inspected direct bot child/final HEAD `c7dfa2432b9afd62d7f439a736a28f1fb7568feb`: only provenance timestamp and three Everloot response hashes differ; generated runtime index and evidence match local validation. Python compilation/full online reconciliation, three required files, all 24 TOC Lua modules and 14/14 regressions. New tests cover all 85 supported book IDs, separate same-name gloves versions, no required ID for the unavailable book, exact specialisations/Hyjal slots, ghost-access context, centaur ambiguity and the explicit inaccessible quest limitation. Complete existing source-negative, nine-class, catalogue, materials, settings/filter, layout and performance regressions pass.

Index 1,489 → 1,575; additive runtime book IDs 452 → 537; reviewed registry 412 → 498. Only 86 additive CSV summaries change; existing identities/order, sources/confidence, requiresLiveCheck, crafting ingredients and class/equip/filter rules remain intact. Published stock/gates/drop references do not become current live claims.

**131/131 other-vendor triage cases publication-researched** (127 supported, four unavailable-book conflicts), with live stock/gates and specific uncertainties still open. Trainer triage now **498/886** researched; **388 remain**: reputation 46, dungeon books 24, generic drop 167, no-alternative 151. Next: remaining reputation cases, then dungeon/drop/source gaps. Six finished-gear dungeon and 954 book live-verification routes remain open. No packaging, ZIP, tag, release, merge or main changes.
