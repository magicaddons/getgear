# Checkpoint 6M — 23 lower-level source-gap cases

9 November 2026; baseline `43f2390` after complete generic-drop validation.

## What research established

All 23 gear-level-1–30 records in the no-alternative triage cohort received fresh exact book XML/item and craft-spell page research. Book name, spell and created equipment identities match independent repository records; no unavailable-item flag appears. The original triage reflects an earlier community database state, not an exhaustive current source inventory.

- **16 spell pages list trainers:** three Copper Boots recipes, two Novice Sashes, five Officer/Sentinel/Warder/Prefect/Justicar Belts, and six Slipper recipes. **267 exact recipe/trainer relationships**, **49 distinct NPCs**. Their physical book origins remain unresolved, so no newly required book ID or book-only route is introduced. Full guide names all listed trainers with source-zone names, published map footprints and Alliance/Horde reaction context. Current teaching, costs and gates remain unverified.
- **Seven book pages list enemies:** three Chain Helms, three Leather Pants and Earthen Leggings. **36 exact book/NPC/zone relationships**. Matching spell pages list the same physical books as teaching items. This is a book route reference, not finished-gear loot or proof that trainers cannot also teach the recipe.

[23-case identity/hash/source register](checkpoint6m_recipe_evidence.csv); [267 trainer relationships](checkpoint6m_trainer_references.csv); [36 book-drop relationships](checkpoint6m_book_drop_references.csv); [49 trainer maps, Gravelsnout map and additional zone identity evidence](checkpoint6m_location_evidence.json). All primary pages were retrieved with the configured audit User-Agent. No live training, purchase, loot, rates or sightings are claimed.

## Item-specific distinctions

[Protector's Chain Helm book 251352](https://www.wowhead.com/forever/item=251352) names Dextren Ward; [Acolyte's Chain Helm book 251353](https://www.wowhead.com/forever/item=251353) instead names Kam Deepfury and Bazil Thredd among its alternatives. Dextren is not copied onto Acolyte, nor Bazil onto Protector. [Crusader's Chain Helm book 251354](https://www.wowhead.com/forever/item=251354) retains its own six-enemy table. Each source set is held at exact book ID level.

[Trapper's Pants book 252793](https://www.wowhead.com/forever/item=252793), [Defender's Pants book 252794](https://www.wowhead.com/forever/item=252794) and [Wisdom's Pants book 252797](https://www.wowhead.com/forever/item=252797) have distinct Deadmines/Stockade/Shadowfang/Blackfathom alternatives. No shared family rule is inferred. [Earthen Leggings book 254000](https://www.wowhead.com/forever/item=254000) lists Gravelsnout Surveyor in Thousand Needles; the NPC page's 29 map points are represented as a reference footprint, not a fabricated central waypoint.

For the trainer cases, for example [Gemmed Copper Boots spell 1252229](https://www.wowhead.com/forever/spell=1252229) has 26 teachers, [Novice Arcanist's Sash spell 1257368](https://www.wowhead.com/forever/spell=1257368) has 23, and [Gilded Slippers spell 1257426](https://www.wowhead.com/forever/spell=1257426) has 13. Every other exact spell's teachers were fetched independently. Trainer listing and NPC reaction/map publication still do not prove live teaching, a current fee or safe access for every character.

## Safeguard and validation

The generator recognises `bookOriginUnknown` on the 16 trainer-alternative records and omits a generated pattern ID. The runtime comment that incorrectly equated book existence with necessity has been corrected. Existing catalogue source/method fields are preserved; this change supplies an independently traced alternative rather than rewriting those fields. Regressions enforce no newly invented book ID for all 16 cases and exact book identities for the seven drop cases, along with no cross-helm source copying.

**Local full validation PASS; GitHub PENDING.** Python compilation/full online reconciliation, three required files, all 24 TOC Lua modules and 14/14 regressions. Index 1,320 → 1,343; additive runtime book IDs 305 → 306 (six of the seven drop books already mapped before this overlay); reviewed registry 243 → 266. Only 23 generated additive CSV summaries change; original identities/order, source facts/confidence, requiresLiveCheck, class/equip eligibility, settings/filters, ingredients and recipe classifications remain unchanged. Existing full-catalogue invariants pass. No rate or source confidence becomes a live claim.

**All 266 level-1–30 entries in the 886-book trainer-labelled triage have now been individually researched:** Favor 71, quest/mixed 8, non-Favor vendors 45 (including three availability conflicts), reputation 48, dungeon 17, generic drop 54, no-alternative 23. This is publication research completion for that subset, not live acquisition confirmation or an assertion that the entire lower-level gear catalogue is complete. Sixteen physical book origins still lack a located source; trainer alternatives are published leads. Three unavailable-book conflicts and Nightclaw shop/quest-access conflicts remain explicit.

Remaining higher-level triage work: Favor 117, quest/mixed 29, other vendors 86, reputation 46, dungeon books 24, generic drop 167, no-alternative 151 — **620 entries**. Next: return to the higher-level Favor cohort by profession, while preserving lower-level priority if stronger evidence for unresolved cases appears. The independent six finished-gear dungeon and 954 book live-verification queues remain open. No ZIP/build/package, release, tag, merge or main change.
