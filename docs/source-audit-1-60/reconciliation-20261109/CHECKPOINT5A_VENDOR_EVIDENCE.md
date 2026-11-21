# Recipe vendor source checkpoint 5A — three Grovekeeper patterns

Date: 2026-11-09. Scope: **3 of the 68 vendor-reference recipe-book records**. Evidence-only, no runtime data or recipe ingredient changes. The vendor source queue remains 68 requiring **live verification**; three have now received direct item-ID-locked published-source confirmation.

| Finished item ID | Pattern ID | Published Forever evidence | Explicit published gating | Live verified? |
| --- | --- | --- | --- | --- |
| 273885 Grovekeeper Grips | 273953 | [Wowhead Forever pattern](https://www.wowhead.com/forever/item=273953/pattern-grovekeeper-grips), vendor Aisarra Nightmeadow, Mount Hyjal | Leatherworking 300; progress Guardians of Hyjal reputation and choose **Gloves** specialization | No |
| 273889 Grovekeeper Mitts | 273957 | [Wowhead Forever pattern](https://www.wowhead.com/forever/item=273957/pattern-grovekeeper-mitts), same vendor | Leatherworking 300; progress Guardians of Hyjal reputation and choose **Gloves** specialization | No |
| 273890 Grovekeeper Mantle | 273958 | [Wowhead Forever pattern](https://www.wowhead.com/forever/item=273958/pattern-grovekeeper-mantle), same vendor | Leatherworking 300; progress Guardians of Hyjal reputation and choose **Shoulders** specialization | No |

These Forever pages directly name the pattern and seller and include the purchase restrictions. Their published vendor tables list stock; this is **database-reported stock, not an observed live merchant inventory**. No player purchase, actual realm stock, faction eligibility or current reputation thresholds have been verified.

## Data-quality finding
The generated `recipe_vendor_book_checks.csv` includes for each of these three patterns both a **named** vendor row (`Aisarra Nightmeadow`, Mount Hyjal) and an **unnamed** vendor row with empty NPC and zone. The empty duplicate is not evidence of a second vendor. In a later data-quality pass, add a regression that counts only identified source edges as vendor confirmations and never exposes empty NPC rows as distinct merchants. This checkpoint does not alter the generator or source rows.

## Disposition and next batch
- Published vendor + book pairing for these three: **direct Forever item-reference evidence**.
- Live availability and full gating: **unverified**; keep all three in the 68-record live-check queue.
- No player-facing source, ingredients, class eligibility, overlay or acquisition confidence changed.
- Next small group: other Grovekeeper vendor patterns, beginning 273952, 273954–273956, 273959; inspect each exact pattern page and record individual specialisation/reputation/quest gates.
- No CI run triggered: this is a documentation-only checkpoint, and the non-release workflow's push path filter excludes documentation. Last complete non-release CI pass remains [42493307958](https://github.com/magicaddons/getgear/actions/runs/42493307958). A future source-code change must trigger and pass that workflow before being marked validated.
