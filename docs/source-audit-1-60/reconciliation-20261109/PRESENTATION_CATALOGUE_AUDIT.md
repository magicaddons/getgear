# Catalogue-wide presentation audit — 14 November 2026

User extends the two UI refinements to every current catalogue item/recipe. Baseline `9e35db97db4cd811dde3bf3f091082f2dad2450d`, active branch `work/full-acquisition-reconciliation-20261109`, fresh remote/clean worktree verified before changes. This is presentation/data-preservation QA, not renewed acquisition research. No package/release/main/Beta8/tag/candidate adoption.

## Scope and reproducibility

`tools/export_acquisition_presentation.lua` loads the actual complete catalogue and shared `GetAcquisitionSummary`, `GetCompactRecipeSummary`, `GetAcquisitionNavigationChoices`, `GetAcquisitionMarkerLabel` and real `UI.lua:DescribeOverlay` logic. Every ID is examined even when that character could not equip it: this is formatter coverage, not a claim that every record appears in the overlay. All nine classes plus unknown-class API state × Alliance/Horde/unknown faction at synthetic level60. Quest-source records additionally exercise unknown/active/ready/completed states, with explicit artificial API fixtures and no player-position/native entrance assumptions. Targeted tests separately cover level11HordeDruid and the reported item2300.

**7,707 items, including1,254 crafting recipes;276,750 formatting contexts;640,754 label-helper calls;13,970 unique per-item target variants across3,411items.** Of those target variants6,509 are coordinate/area-backed candidates; others include written-only, missing-location and client-only entrance targets. These are not counts of rendered/working live pins. The exporter asserts byte-for-byte serialized equality of the full catalogue+navigation model before/after all calls and zero item-cache requests.

`tools/audit_acquisition_presentation.py` applies independent output checks for redundant prefixes, specific research/implementation wording, empty recipe summaries, mixed-method omissions, explicit learning/standing/specialisation clauses, limited-stock/currency/material/coin requirements for the named selected offer and long descriptions. Alternative offers are not treated as simultaneous mandatory costs. Quest descriptions are not required to display the cost of a separate same-NPC vendor route. **220characters is a review trigger, not a measured font/line budget**; no runtime string is blindly truncated to meet it.

The baseline is frozen from the actual four formatter files at9e35db9, with their SHA256 values and affected before-texts in `presentation_audit_baseline.json`; it is not regenerated in CI. Offline commands:

```
python3 tools/audit_acquisition_presentation.py
python3 tools/reconcile_presentation_snapshot.py --verify-only
```

Coverage: `presentation_audit_coverage.csv` (all7707IDs), `presentation_audit_corrections.csv` (affected before/after), `presentation_audit_results.json` (counts/criteria/category coverage), and `presentation_preserved_inputs.json` (protected baseline hashes). Normal and expanded compact text are both audited; full-guide source data are not shortened.

## Results

| Measure | Baseline findings | After corrections |
|---|---:|---:|
| Items with at least one flagged presentation | 4,609 | 0 remaining flags |
| Recipes within those affected items | 600 | 0 remaining flags |
| Distinct problematic per-item text variants | 8,567 | 0 remaining flags |
| Additional legacy destination-label variants | 1 | 0 remaining flags |
| Empty recipe descriptions | 157 | 0 |
| Omitted mixed methods, structured recipes | 11 | 0 |
| Omitted labelled book-specialisation/plain-specialisation | 22+9 | 0 |
| Omitted labelled book learning requirements | 29 | 0 |
| Named-offer limited-stock check failures | 29 | 0 |
| Named-offer purchase-token check failures | 139 | 0 |

These measures overlap; do not sum them. A text variant is `(itemID,text)`, deduplicated across normal/expanded states; absent recipe text counts as a missing-description variant. One item can have different faction/quest-state variants. The lone additional label is Kresh's legacy outdoor reference, currently written-only because its coordinate is legacy-qualified; correcting its prospective primary name does not imply that it draws a precise marker. Existing point/area marker labels were already clean at baseline. The total includes wording/verbosity review findings, not4,609 newly discovered acquisition-data errors.

All13existing structured route categories are exercised (item counts overlap): vendor1400, recipe_vendor432, trainer148, dungeon555, named_drop433, recipe_drop60, quest277, quest_container229, npc_container73, vendor_container58, object45, fishing1, legacy27. Generic world drops and unresolved/no-route records are also checked through the normal catalogue fallback. All11structured mixed-method recipes and219recipes with explicitly labelled requirement clauses are examined; typed offer gates/costs/stock are checked separately, including recipes without those prose clauses. The raw recipe-method fields remain38trainer/4initial/835pattern/2multiple/3unknown/372unclassified; the formatter does not rewrite them.

## Systemic corrections

- `AcquisitionSummary.lua:GetCompactLegacyAcquisitionSummary` now handles older reviewed prose records that previously bypassed compact formatting: broad/random drops, named references, faction-explicit vendor/quest options, container contents, unresolved book origins/learning methods, availability/version warnings and teaching references. Recognised references become short, qualified player instructions. Unfamiliar wording is retained for audit review rather than indiscriminately truncated. Genuine object names such as Knot Thimblejack's Cache are preserved.
- `AcquisitionNavigation.lua:GetCompactAcquisitionRequirements` carries all explicitly labelled learning requirements, gate/specialisation clauses and exact tooltip requirements into the short view, retaining distinctions between learning and wearer requirements. Faction-specific reputation wording selects the applicable named faction or retains both when faction is unknown. No rank/name is invented.
- `GetCompactRecipeSummary` exposes mixed-method alternatives, uses valid existing route labels for legacy vendor destinations, marks context-restricted routes honestly, and provides explicit unknown-learning text instead of silently assuming training. Ordinary Embossed Leather Vest2300 remains exactly `Recipe: Leatherworking trainer (35)` for Alliance/Horde. A known general trainer method is not a fabricated Horde trainer destination.
- `GetAcquisitionCompactSummary` provides consistent named quest/dungeon/vendor/object/source instructions. Container routes explicitly say **possible container contents**; no guaranteed equipment claim. Long quest stage/item/unlock instructions stay in the full Guide, with the quest minimum, class/faction restriction and an explicit required-items/unlocks Guide pointer in compact text.
- `MapNavigation.lua:GetAcquisitionMarkerLabel` also removes the remaining legacy confidence clause from the primary destination name. Underlying verification/bounds/coordinates/instructions and single-marker lifecycle are unchanged.
- `UI.lua:DescribeOverlay` avoids appending a second raw/provenance paragraph when the shared summary already supplies acquisition information. The existing measured wrapping/row height, materials, stat comparison and full Guide remain in place. No extra UI controls or source-specific item blacklists.

Examples (all existing records): Dark Iron Plate11604 retains Armorsmith; Arcanite Reaper12784 retains Master Axesmith; Devilsaur Gauntlets15063 retains Tribal Leatherworking; Black Whelp Slippers252424 points to other methods rather than implying the vendor pattern is mandatory; White Leather Jerkin2311 says its learning source is unverified; container-origin equipment remains a possible outcome. Sentinel's Lamellar Legguards22753 retains Silverwing Sentinels–Exalted and its price, without the publication boilerplate.

## Data preservation and required fresh reconciliation

All22protected source/data/stat/filter/recipe/material/TOC/asset files match9e35db9; the full runtime model also remains read-only throughout the audit.7707identities/36669classobjectives/1254crafts/4857ingredients/5902equipment registry objects/954book registry objects/900candidate holds remain intact. Source uncertainty, faction/class restrictions, navigation routes and coordinates are not rewritten. `tests/beta7-evidence.lua` now accepts canonical `Deadmines` naming and checks the actual named enemy is not promoted to a boss, rather than requiring the old `The Deadmines`/`Trash:` presentation tokens.

Required fresh `uia` reconciliation exited0 with8actual original HTTP response captures. It produced five automatic confidence promotions (1292/3191/6226/6321/6323), additional report observation counts and changed navigation data from newer community feeds. **None were adopted:** complete changed outputs were saved under `/tmp/getgear-presentation-audit/unadopted-uia`, their baseline/new hashes recorded in `presentation_unadopted_feed_review.json`, and all17generated files restored exactly to the approved snapshot. This task does not validate those new actor/drop claims or resume research.

The nonrelease workflow now invokes `tools/reconcile_presentation_snapshot.py`: preflight the17-file approved manifest, run the unchanged original network capture/reconciler once, retain fresh outputs/responses separately under the Actions diagnostic artifact, restore the approved bytes in `finally`, then run the complete suite/audit against the intended dataset. This is explicit preservation, **not HTTP replay/fallback or a claim that the old dataset reflects the new feeds**. Failures still fail CI after preservation. `presentation_data_snapshot.json` documents the active presentation-only scope; when a future task explicitly authorises acquisition-data changes, intentionally update/remove that snapshot gate and restore normal adopting reconciliation. No permission is inferred for a new research queue.

## Validation and remaining exceptions

**Local27PASS:** prior25full checks + catalogue-wide audit + snapshot guard. All19Lua regressions PASS underLua5.1 with only the existing test-fixture compiler adapter; all26addon modules parse under5.1/5.4; new audit tools compile. New actual/synthetic fixtures cover mixed routes, specialisations, unresolved recipes, legitimate Cache names, containers and legacy label qualification. Existing layout, eligibility, school/stat comparisons, source/recipe/material, inventory and zero-item-query performance regressions pass.

**Final nonrelease CI SUCCESS:** [43566380959](https://github.com/magicaddons/getgear/actions/runs/43566380959),job132361039883;27timestampedPASS =25regression/audit checks+2diagnostic capture/preservation checks, plus26addon-module syntax. Source/final validated `7f381939cd9999ce4bac486e3f08609506be7b57`. Complete post-CI remote comparison reviewed: no generated commit and no changed files. The approved acquisition snapshot was restored; fresh diagnostic responses/candidate outputs are retained separately in the Actions artifact, not adopted. Receipt `presentation_ci_results.txt`. No required failed/pending gate remains.

No rule failures remain in the local catalogue audit, but **286recipes still have unresolved learning-source information**. **1,346items** have an unknown/unresolved or character-restricted description in at least one context; that overlap is not a count of missing coordinates or proof of global unavailability. Existing navigation gaps remain unchanged. These are accurately labelled data limitations, not successfully researched locations or confirmed training/vendor routes.

Actual Forever typography, clipping, localized currency names, narrow overlay widths and map rendering/normal interaction still require in-game QA after a separately authorised build. In particular, compare normal/expanded/minimised rows, specialisation/reputation recipes and mixed routes, and check that concise labels retain area explanations in contextual tooltip/full Guide. Automated string checks do not establish pixel-perfect rendering or live stock/loot/access. **COMPLETE — STOP:** final CI, post-CI review and reporting finished; await separate private-build authorization/client findings. No testing ZIP/release was created.
