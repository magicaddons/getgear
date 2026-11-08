# GetGear 1–60 — release-readiness gate (9 November 2026)

**Status: development integration validated offline; in-game acceptance testing remains. No public release is authorized.**

## Completed acquisition research

- Reviewed all **7,707 equipment item IDs**, **36,341 class objectives** across nine classes and **1,252 crafted equipment recipes**.
- All **1,252** ingredient lists agreed with the independent Forever recipe extract; the material-name check covered **4,848 ingredient entries**.
- The [reconciliation report](reconciliation-20261109/README.md) adds **1,075** conservatively labelled source descriptions with traceable provenance.
- The former **577 dungeon-associated records** include **24 crafted items whose patterns may drop in dungeons**, rather than direct equipment drops. The other **553** are dungeon equipment records: **386 published boss references**, **135 trash references**, and **32 requiring an exact enemy/boss/trash classification**. Only **13 item/NPC relationships** have matched independently observed player evidence.
- **68** level-60 crafting recipes now link to independently listed book items, with Aisarra Nightmeadow (Mount Hyjal) as a published vendor lead. Actual stock and reputation/quest/specialisation requirements have not been observed in-game.
- Another **886** trainer-classified recipes also have pattern-book items. Their learning routes may overlap; neither trainer nor vendor teaching should be silently inferred.
- The existing green BoE world-drop, non-positive-stat and class spell-power filtering features remain intact. No item stats, class masks, crafting materials or player statuses were discarded.

## Before the next PUBLIC release

1. **In-game acceptance test on a private candidate build**, after explicit user approval to package an installable test ZIP. Verify the Warrior overlay, detailed guide, source labels, material names, boss/trash descriptions, class restrictions and both reversible overlay filters.
2. **Check startup and player state:** fresh login, /reload, item cache warming, level changes, preview mode, an empty equipment slot, and existing SavedVariables. Offline tests do not prove all these work in the real Forever client.
3. **Spot-check source examples** including Goblin Mail Leggings (1943), Blackwater Cutlass (1951) and Guard's Chain Shirt (250489); also check one named boss drop and one generic trash loot source.
4. **Retain well-labelled uncertainty** for the [32 dungeon verification leads](reconciliation-20261109/dungeon_source_followups.csv) and [recipe-book source queue](reconciliation-20261109/recipe_source_followups.csv). Do not delay every future release until an inaccessible or unpublished source becomes available.
5. **Rerun the combined nine-class CI** after any code changes. Review changes against the integration branch and publish only following explicit permission. Keep the public main branch untouched until then.

## What the player needs to do

No manual research is required. If the player naturally encounters a relevant boss, vendor, or recipe book, screenshots of actual loot and vendor inventory can help close evidence gaps. The [optional verification shortlist](reconciliation-20261109/OPTIONAL_IN_GAME_CHECKS.md) is not an assignment.

## Evidence quality and source attribution

A Forever-observed player relationship is different from a Forever client item, a community loot reference or a Classic database lead. Exact recipe-teaching methods, acquisition of the book and craftable-item reagents are separate facts. Sources, dates and attribution are in the [reconciliation provenance](reconciliation-20261109/provenance.json).

**No installable ZIP, tag or public release has been created in this research work.**
