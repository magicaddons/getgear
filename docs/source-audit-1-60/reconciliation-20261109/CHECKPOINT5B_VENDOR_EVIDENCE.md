# Recipe vendor source checkpoint 5B — five additional Grovekeeper patterns

Date: 2026-11-09. Scope: **five new item-ID-locked pattern leads** from the 68 named-vendor recipe-book queue, continuing checkpoint 5A. **Evidence-only**, no changes to runtime recipe, class, filter, material or acquisition records.

| Crafted item ID | Pattern item ID | Published source and evidence | Gating confidence | Live purchase observed? |
| --- | --- | --- | --- | --- |
| 273884 Grovekeeper Trousers | 273952 | [WoW Forever tier-set crafting guide](https://conquestcapped.com/guides/wow-forever/wow-forever-tier-sets-1/) names this finished piece as an Aisarra Nightmeadow vendor pattern in Mount Hyjal; the [repository vendor queue](recipe_vendor_book_checks.csv) locks pattern and craft IDs | **Guide-level** legs group: Friendly with Guardians of Hyjal and Friendly Advice quest. Do not claim exact pattern tooltip independently read. | No |
| 273886 Grovekeeper Shoulderpads | 273954 | Same [Forever guide](https://conquestcapped.com/guides/wow-forever/wow-forever-tier-sets-1/) lists Grovekeeper Shoulderpads among Aisarra's recipes; [repo queue](recipe_vendor_book_checks.csv) locks the book ID | **Guide-level** shoulder group: further reputation progress and Shoulders specialization; exact book tooltip not independently retrieved. | No |
| 273887 Grovekeeper Stompers | 273955 | [Forever guide](https://conquestcapped.com/guides/wow-forever/wow-forever-tier-sets-1/) lists Grovekeeper Stompers; [Forever crafted item page](https://www.wowhead.com/forever/item=273887/grovekeeper-stompers) confirms the finished item; repo queue locks book ID | **Guide-level** feet group: further reputation progress and Boots specialization. Crafted item page alone is not proof of the book's vendor stock. | No |
| 273888 Grovekeeper Kilt | 273956 | [Wowhead Forever craft spell 1292925](https://www.wowhead.com/forever/spell=1292925/grovekeeper-kilt) explicitly lists Pattern: Grovekeeper Kilt and Aisarra Nightmeadow vendor in Mount Hyjal; repo queue locks item ID 273956 | **Direct Forever craft-to-book-to-vendor link**, but the exact pattern tooltip's quest/reputation gates were not retrieved; the [Forever guide](https://conquestcapped.com/guides/wow-forever/wow-forever-tier-sets-1/) says legs recipes require Friendly and Friendly Advice | No |
| 273891 Grovekeeper Sandals | 273959 | [Wowhead Forever pattern page](https://www.wowhead.com/forever/item=273959/pattern-grovekeeper-sandals) explicitly identifies the book, vendor location and purchase restriction; repository queue names Aisarra Nightmeadow | **Direct Forever book tooltip**: Leatherworking 300; Guardians of Hyjal reputation progress and Boots specialization. No precise reputation threshold established. | No |

## Findings and confidence

- These five books are **additional** to checkpoint 5A's three (273953, 273957, 273958): **8 of 68** named-vendor references have now been individually researched at different evidence levels. **All 68 still require live inventory confirmation.** Research progress is not live-verification progress.
- The guide reports the legs patterns cost 8 Malleable Essence of Nature and hands/shoulders/feet cost 6. This is **guide-reported** and not independently verified as live pricing; do not rewrite acquisition costs.
- The three first rows have a vendor claim in a published Forever guide and a separately existing exact book-ID mapping in the repository. That combination is **weaker than a directly retrieved pattern page**; do not label them independently item-page-verified.
- The published recipe vendor queue gives each pattern a named Aisarra Nightmeadow row and an empty NPC/zone duplicate. The empty row must not be interpreted as a second vendor.
- No live vendor stock, actual purchases, faction access, or exact reputation thresholds have been observed. **Do not promote source confidence to `forever-observed`.**

## Next bounded batch

Inspect the remaining Grovekeeper entries (beginning books 273960–273966) by exact item ID; prefer each pattern tooltip and capture the difference between legs quest gates and slot specialization gates. Then proceed to other profession/faction vendors. Preserve original 954 uncertain-source total, including 68 vendor and 886 trainer-labelled books, until live verification or an explicitly defined evidence policy supports reclassification.

## Validation

Documentation-only; no addon runtime, test or generated source files changed. GitHub Actions workflow `reconcile-all-acquisition.yml` does not trigger on documentation-only paths, and the available connector has no workflow-dispatch action. The most recent verified **full non-release CI pass remains [42493307958](https://github.com/magicaddons/getgear/actions/runs/42493307958)** at earlier code SHA `6f25de68e51064a0bd7d3344c55782c200674681`. This checkpoint is **not newly CI validated**. No ZIP, tag, release or merge.
