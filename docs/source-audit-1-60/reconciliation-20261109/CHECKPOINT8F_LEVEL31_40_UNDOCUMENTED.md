# Checkpoint 8F — 93 undocumented-source items and an omitted craft

Publication research: 9 November 2026 UTC; baseline 0ae9c49. All 93 exact canonical identities researched without repeating completed equipment IDs. [Cases](checkpoint8f_equipment_evidence.csv), [structured source proof](checkpoint8f_publication_evidence.json), [merchant joins](checkpoint8f_merchant_references.csv), [NPC references](checkpoint8f_drop_references.csv), [quest rewards](checkpoint8f_quest_references.csv), [actor joins](checkpoint8f_actor_references.csv), [requirements](checkpoint8f_item_requirements.csv), [creation inputs](checkpoint8f_creation_references.csv).

Result: **12 quest, nine vendor, eight NPC, three item-use/summoning and one learned-craft references; six caveated secondary named leads; four generic world-drop labels; 50 unresolved origins**. All remain live-unverified. No selected case has a qualifying three-install observation in the final snapshot. All 60 initially blank-origin cases received exact-name/ID searches; wrong-ID names and Classic/retail mappings were rejected as current proof. Structured facts/URLs/primary response fingerprints are retained; no full stories/articles or fabricated hashes for connected-web reads.

## Omitted craft correction

**Centaur Hoofwarmers #274490** is a learned Leatherworking craft: [spell #1294289](https://www.wowhead.com/forever/spell=1294289), [pattern #274491](https://www.wowhead.com/forever/item=274491), learning skill165, **12 Thick Leather4304 +2 Heavy Silken Thread8343**. Exact item/book/spell and quantities match independently fetched records.

| Pattern seller | Published location | Individual inventory gate | Currency cost |
|---|---|---|---|
| [Molkar #253140](https://www.wowhead.com/forever/npc=253140) | Desolace 35.6,92 | Honored Gelkis Clan Centaur | 15 Carved Centaur Totems #254432 |
| [Gorhak #253139](https://www.wowhead.com/forever/npc=253139) | Desolace 66.2,79.4 | Exalted Magram Clan Centaur | 60 totems |

Both exact reverse merchant joins match ID/name/cost/condition; currency identity independently checked. Aggregated book ranks are seller-specific references, not both clans required for one purchase; standing 0 is not Neutral access. No false global price/pin. Stock/phase/standing access/totem supply remain unverified.

SourceEnrichment adds this missing craft/book/material data. Pattern BoP and boots BoE are distinct; the recipient of finished boots need not learn Leatherworking. [Exact module comparison](checkpoint8f_craft_preservation.json) proves **all 1,253 earlier craft definitions/4,855 ingredient rows unchanged**, all 7,707 name/level/slot/eligibility records and36,341 objectives retained. Sole addition: **1,254 crafts/4,857 rows**. Historical catalogue/1,252-recipe CSVs unchanged.

[Supplementary definitions](supplementary_crafts.json) and [generated audit](supplementary_crafts_reconciled.csv) separately cover Idol of the Dream and these boots. Original954 book queue unchanged; supplementary book purchases also live-unverified. Generator validates supplemental identities/ingredients; source metadata exposes the pattern without invented trainer teaching. Workflow now watches SourceEnrichment, its test and the supplemental input, and requires a fourth report while retaining earlier checks.

## Distinctions and exceptions

- **Hammer #8708:** [spell #11209](https://www.wowhead.com/forever/spell=11209), [Signet #8703](https://www.wowhead.com/forever/item=8703), Blacksmithing185; [quest #2765](https://www.wowhead.com/forever/quest=2765), minimum 40, independent Galvan #7802 join. Quest explicitly lists Warrior/Paladin/Hunter; these are route restrictions, not a replacement Hammer equip mask. **One-hour weapon duration versus three-hour Signet cooldown**. Not a permanent learned recipe; complete current quest access unverified.
- **Reforged Blade #9718:** [item-use spell #11923](https://www.wowhead.com/forever/spell=11923), Broken Blade #9719/Blacksmithing190, anvil/hammer tool, four Steel Bars/four Strong Flux/two Elemental Fire/two Heavy Grinding Stones. Published input drops are not drops of the reforged output; no invented trainer recipe.
- **Narpas Sword #217497:** [current item-effect1302286](https://www.wowhead.com/forever/spell=1302286), Scroll #217496 +Hypnotic Blade #7714. Exact sword/scroll explicitly Mage; sword equip 34/BoP. Older440236 is separate publication data, not a verified second live route. Scroll origin unresolved; no invented library/trainer/vendor or ordinary Blacksmithing.
- **Nine Theramore versions** exactly match Bryanna Embreeze, The Barrens 63.4,58.6, individual coin costs/ranks. Do not fill earlier seven different low-level inventory gaps with these IDs.
- **Eight NPC references:** seven reverse loot lists match. **Ambassador's Bloodrobes286639** has an item-page Bloodrage7895 claim but the NPC loot list omits this exact ID: discrepancy retained. **Briny Sash274605** has no usable Captain Dreadrise location; no invented coast/dungeon/pin.
- **Quest phase/actor gaps:** Proof of Concept92873 has Magram Honored, unusual published426 Well Cursed Bones, end-only Orgrul/Shen'dralas; no invented start or silently corrected quantity. Test Your Theory93045 has Gelkis Honored/end-only Nerlokh; ritual/dispelling choices are not finished-gear drops. Khan Jehn93196 remains Side None/no actors, distinct from Horde/Gelkis kill route93128. Lost for Words92878 and Partial Mystical Notes95384 have narrative destinations but no current actors encoded.
- **Mirage Mirror #277844:** quest #97821 requires different quest-object278744 with the same name; minimum 37/no actors/Side None. No same-ID consumption/return or fabricated giver.
- **Six secondary named leads:** Uldaman274425/274428/274430/274485→Obsidian Sentinel; Golem Fist #282551→War Golem/Badlands; Slicer #283255→Gravis Slipknot/Alterac. Publisher cache/confirmed badges are not independently observed item-to-NPC edges. Its [Uldaman overview](https://foreverchanges.pro/dungeons/uldaman) explicitly labels mappings/chances/boss levels Classic-derived. No copied rare/boss role/rate/pin or current certainty.
- **Four generic world-drop labels:** no named farm/observation; Molok/Witherbark names do not prove NPC drops. Existing classification/filter semantics preserved.
- **50 unresolved origins:** exact gaps retained; same-name rings/clubs often have different IDs. Prismstone price mirror uses retail-source data/no realm scan. No unavailable flags invented from missing data.
- **Axes274484/274485:** [Aspects of Doom1294234](https://www.wowhead.com/forever/spell=1294234) uses274484, lists274485 as reagent and creates Pendulum9425. Separate assembly fact, not either axe's origin, ordinary profession teaching or exact current consumption/retention. Existing Pendulum sources not replaced from this alone.

## Fresh upstream deltas

[Semantic comparison](checkpoint8f_upstream_review.json) and [raw observations/identity checks](checkpoint8f_upstream_observations.json): final feeds **23,239 Playfulls items/1,365 Everloot edges/1,170 qualifying relationships**. Early23,211/1,320 snapshot retained separately, hashes not conflated.

- Five Deathbone14620–14624 gain Instructor Malicia/Scholomance **community references**, not observed loot.
- Seven catalogue observation-count cells gain edges; nine existing dungeon observations gain installs/timestamp details. No rates or personal observations.
- Four existing book observations gain installs. New **book #253904→NPC3671**, five installations, independently identified as Pattern: Filigreed Silky Gown→Lady Anacondra. Book, not finished gown, observation; published Gilnid alternative retained, no exclusive route/automatic teaching conclusion.
- Besides93 additive summaries, two supplemental classifications and these explicit semantic changes,416 dungeon/488 recipe cells are offset-only. Original954 queue/six dungeon exceptions remain.

## Validation and next checkpoint

**Local full PASS:** Python syntax/fresh online reconciliation, all 24 Lua modules, **four required reports**, all 14 regressions. [Output](checkpoint8f_local_results.txt). Negative cases cover temporary versus learned crafting, duration versus cooldown, missing actors/same-name input IDs, reverse-loot omission, separate ranks/costs, no false observed/role claims, wrong IDs/honest gaps, unchanged generic-source/filter behaviour and supplementary recipe rows. Full catalogue/material/class/overlay/settings/layout/performance invariants pass.

Index 2,308/displayed 2,307 (boots retain manual craft summary), added books759, reviewed equipment 517, original recipe registry954 plus separately audited supplemental crafts. Full local and GitHub PASS: [42654914045](https://github.com/magicaddons/getgear/actions/runs/42654914045), source `801ae96935e90d4baae1952262bd24dfde67855d`; inspected direct bot/final validated HEAD `c283e82aaee5b284e49d524433174ea82e4697db`. All 14 PASS log lines verified; 24 modules/four reports. Bot changes only provenance timestamps/data-as-of and three response hashes; counts/runtime/reports unchanged. Equipment517/index2,308/display2,307; crafts1,254/ingredients4,857. Remaining5,385; next8G:207 vendor cases at41–50. No release/main change. Remaining individual queue **5,385**: vendors 1,237; quests 190; undocumented 1,069; world-drop 2,887; reputation 2. **Next 8G:207 vendor cases at levels 41–50**, then remaining undocumented 41–50/higher-level cases.

Current stock/spawn/phase/origin/retention/price and client acceptance remain open. No build/package/tag/release/merge/main changes. Two duplicate scheduled continuations received while this chat worked were skipped; no duplicate task/worker/automation created.
