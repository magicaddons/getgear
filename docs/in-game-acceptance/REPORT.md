# In-game acceptance implementation — 17 November 2026

Branch: `settings-ui-refinement`. Starting validated state:
`28e9964d221f9186f93f23e9bbf3ae3990db4128`.
Implementation and CI identifiers are recorded in [validation.json](validation.json).
No addon package, tag, release, merge or main-branch change is authorized or performed.

## Root causes and production changes

1. **Wrapped tracker names:** the title, level, body and minimized-row height
   used independent fixed offsets. `UI.lua` now measures the name after setting
   its actual width/text, puts the level seven units below its final line, then
   measures the level before placing dependent content. The original 26-unit
   single-line level offset and 47-unit minimized row remain at ordinary font
   metrics. Comparisons, source text, material rows, background, click target and
   scroll extent grow from the completed header. Newly allocated rows also use
   the current content width; pin space is reserved before measurement. Resize,
   display-size and UI-scale refreshes repeat the measurements.
2. **Talent relevance:** `TalentAwareness.lua` returned early for every class
   except Mage. The class-wide hybrid relevance filter and the tracker's
   first-positive-stat test then accepted caster utility despite physical losses.
   The shared detector now reads all nine classes' actual named tree groups.
   `StatPriorities.lua` adds conservative Balanced planning factors and scores
   complete comparison deltas, requiring a gain in a role's principal attributes
   rather than utility alone. `GearCompare.lua` uses that evaluation for focused
   talent builds; inconclusive builds keep the existing class-wide fallback.
   `GearRelevance.lua` retains the existing Balanced Mage pure-school safeguard
   while allowing explicit Priority/Advanced choices to override that inference.
3. **Acquisition practicality:** structured faction eligibility was correct but
   did not assess the inconvenience of an ordinary low-level farming route.
   `AcquisitionNavigation.lua` now assesses each eligible route separately,
   preserves uncertain/shared routes, filters only conclusive minor remote
   acquisitions from the compact presentation, and prefers a published friendly
   or current-zone alternative when there is evidence for that preference.
   Native/preferred quest destinations retain precedence. `Core.lua` refreshes
   recommendations on zone changes without clearing a user-selected map marker.

Changed production files: `UI.lua`, `TalentAwareness.lua`, `StatPriorities.lua`,
`GearCompare.lua`, `GearRelevance.lua`, `AcquisitionNavigation.lua`, `Core.lua`.
`GuideState.lua` and `AcquisitionSummary.lua` were audited and retain their shared
calls to the comparison/source helpers; their code is unchanged. No catalogue,
recipe, material, equipment eligibility, saved-variable schema or preference-key
change was needed. The existing validation workflow's snapshot policy is retained;
its explanatory comment now describes the current acceptance scope.

## Talent interpretation and stat modes

The detector uses `C_ClassTalents.GetActiveConfigID`,
`C_Traits.GetConfigInfo`, `GetGroupDisplayInfoByTreeID` and
`GetGroupCurrencyInfo`. It reads `currencyInfos.spent`; staged/pending fields do
not contribute. There is no retail specialization lookup or talent-writing API.
All three named groups must be recognized exactly once. Invalid, duplicate,
nonfinite, negative or unavailable data clears the previous inference.

A focused orientation requires at least **three committed points**, a **two-point
lead**, and **70% of all invested points**. Unspent, early, mixed and unknown
states are distinguished in memory. Tree names support multi-word names and
parenthesized display suffixes; unrecognized/localized names fail open. Existing
talent events refresh the detector and visible windows; no inference is saved.

| Class | Trees and planning orientation |
| --- | --- |
| Warrior | Arms/Fury: physical; Protection: tank |
| Paladin | Holy: healing; Protection: spell/tank hybrid; Retribution: physical |
| Hunter | Beast Mastery/Marksmanship/Survival: ranged |
| Rogue | Assassination/Combat/Subtlety: physical |
| Priest | Discipline: broad caster/healing hybrid; Holy: healing; Shadow: caster |
| Shaman | Elemental: caster; Enhancement: physical; Restoration: healing |
| Mage | Arcane/Fire/Frost: caster; existing exclusive-school preference retained |
| Warlock | Affliction/Demonology/Destruction: caster; no new school exclusions |
| Druid | Balance: caster; Feral Combat: physical; Restoration: healing |

**Balanced:** with a focused build, physical/healing/caster utility has modest
nonzero weight in net tradeoffs, but utility alone is insufficient. For example,
Feral Intellect/spell/healing gains can accompany a meaningful physical gain;
merely possessing caster stats is never an equipment veto. Losses also count.
Unknown comparisons, potential off-hand replacements and unreadable weapon DPS
remain inconclusive. Without reliable talent evidence, the existing class-wide
positive-stat behavior remains. The detailed guide keeps the class-wide catalogue.

**Priority:** uses the existing selected-stat multiplier and complete class-valid
net deltas. Inferred role factors do not override the selected stat.

**Advanced:** uses exactly the saved custom weights, including unusual hybrids;
there are no inferred role multipliers. Turning off the Balanced positive-stat
checkbox does not bypass explicit weighted scoring. Character preferences,
weights, status, hidden objectives and save/reload behavior are unchanged.

**Show all valid equipment** lifts inferred recommendation/convenience filters;
proficiency, QA exclusions and confirmed source restrictions still apply.
Completed/Hidden history and class preview remain available under their existing
rules. Guide headings now show detected talent investment for every class.

## Concrete item verification

The independently published Forever tooltip cache was fetched once, without
regenerating any runtime data. Its exact Black Whelp Tunic record and full-cache
SHA256 are retained in [black-whelp-tooltip-evidence.json](black-whelp-tooltip-evidence.json).
The recipe website returned HTTP403; that failure was not treated as evidence.

**Black Whelp Tunic #20575:** item level20, requires15, leather chest, BoE,
78 armor, +5 Intellect, +3 universal spell damage/healing. Pattern #20576,
spell #24940, Leatherworking75; materials remain 8 Medium Leather, 8 Black Whelp
Scale, 1 Cured Light Hide and 2 Fine Thread. The accepted pattern reference is
Amy Davenport in Redridge; current stock/access remains unverified.

The real comparison code reconstructs all six reported deltas against a synthetic
baseline of 73 armor, 3 Stamina and 1 Agility: +5 Intellect, -3 Stamina, +3 Spell
Damage, +3 Spell Healing, -1 Agility, +5 Armor. That baseline is inferred from the
user's report; the equipped item's actual ID was not provided. Focused Feral
Balanced produces **-3.7 planning units** and hides this tradeoff. Balance and
Restoration retain it; appropriate Priority/Advanced choices and Show-all restore
it. This establishes the reported regression, not every possible live comparison.

Representative accepted Barrens sources were inspected before rule changes:

| Item | Source type and identity | Published faction evidence |
| --- | --- | --- |
| Centaur War Chain #285339, level14 | Named drop: Rocklance, NPC5841 | Barrens location; no structured faction restriction |
| Feather Padded Treads #285345, level16 | Named drop: Sister Rathtalon, NPC5830 | Barrens location; no structured faction restriction |
| Signet of the Zhevra #285330, level18 | Named drop: Swiftmane, NPC5831 | Barrens location; no structured faction restriction |
| Farmer's Shovel #3334 | Alternative quest79192, Stepping Stones | Shared side3; also retains its separate named-drop routes |
| Pristine Sash #253925 | Pattern sellers Jim'bek248202 / Mivin Shadowweave256735 | Separate Horde/Alliance seller restrictions |
| Leggings of the Fang #10410 | Wailing Caverns, Lord Cobrahn | Shared dungeon route, not a Horde territory exclusion |

These are published/previously observed references, not new live loot confirmation.

## Practicality policy and navigation

- Eligibility is evaluated first using the existing per-route faction/class/race/
  quest/vendor rules. Geography never becomes a hard eligibility restriction.
- Below level30, an ordinary named drop, object/container source or qualified
  seller can be inconvenient when every known eligible location has reliable
  evidence placing it in an opposing leveling/home region, away from the current
  zone. Unknown locations, unqualified legacy references and incomplete routes
  remain uncertain; zone names alone do not delete items.
- A shared dungeon or eligible neutral quest remains available. Neutral/unknown
  sellers are not assumed hostile from their zone. Known friendly/current-zone
  routes, learned recipes and verified tradeable finished items can provide
  alternatives. Trading language explicitly states that listings are unknown.
- Only a **conclusively minor** comparison is filtered: every comparable occupied
  replacement must gain no more than25% of its weighted changed-stat baseline.
  This relative threshold respects small/large Advanced weight scales. Empty
  slots, missing stats/DPS, documented special effects, zero positive baselines
  or a substantial gain keep the acquisition available. Using only changed
  baseline attributes makes the exception more generous, not stricter.
- At level30+, or already in the source zone, the low-level travel filter does
  not apply. Show-all lifts convenience filtering. The full guide and source
  chooser retain every eligible inconvenient route and its factual instructions.
- Retainability is separate from destination preference. Shared/unknown routes
  do not displace a destination merely because they were retained. Only known
  friendly/local alternatives improve convenience ranking; native/preferred
  quest navigation wins ties. No distances, coordinates or prerequisite access
  are invented.

Review against the starting implementation found four selected-location changes
in an Alliance level25 reference context: #820, #886, #899 and #2020 now prefer
published Westfall/Elwynn alternatives. All original choices remain. The button
coverage audit changes only #886 from area to point: 1022 point,1213 area,534
written/native,2782 missing,2156 not applicable. No new missing target is introduced.

## Validation and preserved data

Final command receipts, summary and CI metadata are linked from [validation.json](validation.json).
The local integrated gate passes **121 commands**: 28 runtime modules and two tools
parsed on both Lua5.1/5.4, all26 Lua regression suites on each interpreter, four
offline Python suites, source/presentation/bag audits and20 mocked release-safety
unit tests. The non-release CI result must match the implementation SHA.

New regressions include360 real-row synthetic layout combinations;54 named-tree/
faction combinations; nine classes and both factions across recommendation modes,
ambiguity/errors, exact reported tunic deltas, utility preservation, tracked/all
materials, zone/talent events, neutral/shared/starting/uncertain regions,
alternatives, scaled custom weights, strong/empty upgrades and navigation priority.
Existing suites cover equipment eligibility, weapon/ring replacement safeguards,
save/reload persistence, recipe/material/bag behavior, map markers, guide history,
available/upcoming/preview and catalogue performance.

The approved17-file acquisition snapshot,7707 equipment identities,36669 class
objectives and900 held candidates remain intact. Existing release assets/ZIPs,
TOC/version and other data modules are untouched. The source-eligibility audit
matches its accepted CSV byte-for-byte.

A fresh unchanged-generator diagnostic ran **in a separate temporary source
copy**, leaving this checkout's catalogue untouched. It failed the existing
`rare-boss==12 and trash>=137` ingestion assertion: upstream currently yields
136 trash records. [fresh-diagnostic.json](fresh-diagnostic.json) and
[fresh-diagnostic-log.txt](fresh-diagnostic-log.txt) record this separately.
Unadopted output was retained externally and the temporary copy restored its
snapshot. This is not a passing reconciliation or adopted research update;
non-release validation continues to verify the approved snapshot.

## Actual-client limitations and acceptance checklist

Automated tests use synthetic frames and C_Traits fixtures. They do **not** prove
Forever's actual font wrapping, event timing, committed/staged talent semantics,
localized tree labels, live stock/loot, travel feasibility, custom client combat
rules or current auction supply. Planning factors are heuristics, not DPS/healing
simulation. Unknown API/source/stat data intentionally retains some recommendations.
Proc/set effects not exposed in the comparison remain a manual consideration.

For the next separately authorized private in-game test:

1. At level14, compare **Blackened Defias Leggings #10400** and **Heavy Spiked
   Mace #4778** at narrow/default/wide tracker widths and multiple UI scales.
   Check title/level separation, comparisons, source text, materials, blue
   background, title click target and scrollbar extent. Minimize/expand each,
   then resize and reuse rows; single-line names should stay compact.
2. On a Druid with at least3 points clearly concentrated in Feral Combat, verify
   the guide's detected tree. Inspect **Black Whelp Tunic #20575** and record the
   live equipped chest ID/full tooltip. With the six reported deltas, it should
   leave the default compact tracker while remaining in the guide. If the live
   deltas differ, assess that actual net tradeoff instead.
3. Test Balance, Restoration and an ambiguous mixed Druid build. Commit a talent
   change/respec and verify immediate recommendation/material refresh, without
   manual specialization menus. Repeat detection/fallback checks on Warrior,
   Paladin, Hunter, Rogue, Priest, Shaman, Mage and Warlock; verify Mage pure-school
   behavior separately from generic spellpower and explicit custom school weights.
4. Check Balanced, Intellect Priority and a deliberately caster-weighted Advanced
   Feral build. Toggle Show-all and the positive-stat filter; confirm explicit
   weighted choices remain effective and proficiency/faction restrictions hold.
   `/reload`, relog and switch characters; saved modes, weights and progress
   must persist independently. Reset only the intended preferences.
5. On low-level Alliance/Horde characters, inspect a minor known opposing-region
   drop versus a worthwhile/empty-slot upgrade. For Alliance, use #285339,
   #285345 or #285330 when class-equippable and comparable. The minor remote
   default can disappear; the full guide/Show-all must retain legitimate access.
   Enter the source zone and verify automatic refresh.
6. Confirm shared **Wailing Caverns #10410** and **Shadowfang Keep** destinations
   remain available. Confirm **Stepping Stones quest79192 / Farmer's Shovel3334**
   is not labelled Horde-only. Inspect the side-correct #253925 pattern seller.
   On an appropriate sword user, #886 should show the published Elwynn alternative
   while retaining its other sources in the chooser. Check actual map-marker
   placement, native quest priority and one-marker lifecycle.
7. Verify Completed, Hidden, Available, Upcoming and Preview; crafted-material
   checklists and tracked/all totals; owned/bag/quest recommendations; recipe
   information and source instructions. Unknown-source items should retain their
   existing uncertainty labels and player-directed access.

Stop after the validated source and this report. Packaging, publishing, tags,
merging and release assets require separate authorization.
