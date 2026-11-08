# Checkpoint 5D — vendor-book references 273967–273973 (2026-11-09)

**Scope:** Seven distinct book IDs and corresponding finished crafted-item IDs, in queue order. This is an **evidence-only** pass. No live Aisarra Nightmeadow stock, player purchase, reputation or specialization test was observed.

| Finished item / book ID | Evidence and limits | Gate evidence | Live stock |
| --- | --- | --- | --- |
| Grovekeeper Treads 273899 / **273967** | [Exact Forever craft spell 1292936](https://www.wowhead.com/forever/spell=1292936/grovekeeper-treads) shows the named pattern in its 'Taught by' section with Aisarra Nightmeadow vendor listing; [Forever leatherworking guide](https://www.zockify.com/forever/professions/leatherworking/recipes/) corroborates. Exact book tooltip not retrieved. | Spell explicitly requires Leatherworking 300 and Sewing Machine. Any boots specialization or reputation threshold is a **family inference**, not directly established for 273967. | No |
| Wildstalker's Legguards 273900 / **273968** | [Exact Forever pattern page](https://www.wowhead.com/forever/item=273968/pattern-wildstalkers-legguards) identifies Aisarra Nightmeadow, Mount Hyjal; [exact craft spell 1292937](https://www.wowhead.com/forever/spell=1292937/wildstalkers-legguards) cross-checks book-to-craft relation. | Pattern directly requires Leatherworking 300, Guardians of Hyjal **Friendly**, and **Friendly Advice** quest. Database vendor cost 8 (currency not independently verified live). | No |
| Wildstalker's Gauntlets 273901 / **273969** | [ForeverChanges finished-item page](https://foreverchanges.pro/item/273901/wildstalkers-gauntlets) names the exact pattern and Aisarra vendor; [Forever leatherworking recipe guide](https://www.zockify.com/forever/professions/leatherworking/recipes/) corroborates. Neither is a live purchase. | Leatherworking 300 in published craft listing. Gloves specialization and higher reputation are **slot-family inference** pending exact tooltip. | No |
| Wildstalker's Spaulders 273902 / **273970** | [Forever hunter set guide](https://www.zockify.com/forever/hunter/sets/) names exact pattern and Aisarra vendor for this slot; [Forever leatherworking recipe guide](https://www.zockify.com/forever/professions/leatherworking/recipes/) corroborates. | Leatherworking 300 published; shoulders specialization/reputation **not directly verified** for this book. | No |
| Wildstalker's Greaves 273903 / **273971** | [ForeverChanges finished-item page](https://foreverchanges.pro/item/273903/wildstalkers-greaves) identifies exact pattern and named Aisarra vendor; guide corroborates. | Leatherworking 300; boots-specific gates **unverified** for exact book. | No |
| Manaflare Pants 273904 / **273972** | [Forever Wowhead tailoring guide](https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes) names pattern and Aisarra Nightmeadow in Mount Hyjal. [Independent guide](https://wowcamp.fun/en/guides/tailoring/) supports vendor family. Exact pattern tooltip not retrieved. | Tailoring 300 in published guide; legs reputation/quest conditions **not independently checked** for this book. | No |
| Manaflare Gloves 273905 / **273973** | [Forever Wowhead tailoring guide](https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes) names exact pattern and Aisarra vendor. | Tailoring 300 in published guide; gloves specialization/reputation **not directly verified** for this book. | No |

## Reconciliation and confidence

- The seven IDs match consecutive distinct records in `recipe_vendor_book_checks.csv`; source queue mappings have not been changed.
- **22 of 68** vendor-book records have now been individually researched (5A 3 + 5B 5 + 5C 7 + 5D 7). **All 68** remain live vendor-stock-unverified, and **all 954** recipe-book routes remain open.
- Exact published pattern tooltip: **273968**. Exact craft spell with linked pattern: **273967**, with 273968 also cross-checked. Finished-item-to-pattern published reference: **273969, 273971**. Named recipe guide: **273970, 273972, 273973**.
- Every one of these queue records has a second vendor row with blank NPC and zone. Do **not** count it as a separate merchant.
- Source-proof and gate-proof levels must be tracked independently; guide-specified acquisition is not proof of live stock, and slot-family gate inference is not a fact for an individual book.
- No Classic-only item-to-source assertion was promoted to live Forever evidence.

## Validation and next action

**Documentation-only.** No Lua, recipe materials, generated source facts, gear filters or class rules changed. Latest complete [non-release CI pass 42493307958](https://github.com/magicaddons/getgear/actions/runs/42493307958) at code SHA `6f25de68e51064a0bd7d3344c55782c200674681` remains the most recent validated code run; no new CI was dispatched for this note. No ZIP, tag, release or merge.

**Next:** research book IDs **273974–273980** in a bounded batch; use exact Forever item pages to establish any reputation/quest/specialization gates, and keep live-stock status unresolved without player observation.
