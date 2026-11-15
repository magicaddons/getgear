# Bag acquisition, travel convenience and stat priorities

Development only, 15 November 2026. Branch `dev/recommendation-pipeline`.
Baseline `04992876bd4f50b66d6b6dd78d00b32cd0594cd3` is the accepted Beta 9
source, validated by [CI 43569430115](https://github.com/magicaddons/getgear/actions/runs/43569430115).
The workspace initially contained Beta 7; the newer validated source was fetched
before implementation. Published packages, releases, tags and main are unchanged.

## Confirmed causes

1. `BagUpgrades:GetBagPlanningObjectives` returned immediately when
   `GetBagUpgradePlan` found no improvement at its chosen crafted tier. Vendor
   and quest alternatives therefore depended on an unrelated craft. The bag
   planner contained only four crafts, one vendor bag and Canvas Latchbag;
   ordinary equipment's 7,707-item index intentionally excludes containers.
   The only quest bag also required a Dwarf/Gnome character, an unfinished
   quest and space below six slots. A Priest outside those conditions could
   legitimately see no quest option. This is a confirmed implementation gap;
   the user's exact inventory/race/quest state was not supplied or reproduced.
2. The existing navigation travel preference suppressed opposing *starting*
   territories only through level 15. Silverpine Forest, The Barrens and the
   Alliance second zones were absent. There was no user toggle. Existing
   faction/class source checks mostly affected navigation/overlay rather than
   the shared current-item pipeline. `SelectCurrentGuide` disabled Horde lists
   altogether, even though the class equipment masks are faction independent.
3. `ShouldShowOverlayStatChanges` returned true at the first meaningful
   positive delta. It did not price simultaneous losses. Equipment comparison
   already handled empty slots and paired slots conservatively, and explicitly
   labelled an offhand's benefits as potential with a two-hander. The overlay
   qualification nevertheless treated those potential positives as an upgrade.

## Implementation

- `BagCatalogue.lua`: 34 additional ordinary bag identities and separate bag
  quest/source metadata. With the six retained planner identities, 40 bags
  have capacity-based planning support. Original tier recipes/material totals
  remain unchanged. Quest/vendor/drop/craft choices at equal capacity coexist;
  repeatable purchases can fill several slots, one-time rewards provide one.
- `BagUpgrades.lua`: evaluates alternatives even when the crafted plan is nil;
  protects specialty containers and confirmed capacities, avoids duplicate item
  cards, and checks quest completion through modern or legacy APIs.
- `AcquisitionPolicy.lua`: shares source-level hard faction/class/race/level,
  explicit prerequisite and readable vendor-reputation checks. Unknown APIs
  remain unknown. Each route is evaluated independently. Optional geography
  affects the overlay; full-guide travel alternatives remain available.
- `AcquisitionNavigation.lua`: consumes the same plans and hard restrictions,
  preserving existing coordinate/area/entrance/quest marker behavior. Bag
  navigation is a separate read-only view over the preserved source model.
- `GuideEngine.lua`, `GearRelevance.lua`, `CraftingVisibility.lua`: both faction
  class indexes are enabled; current source restrictions precede soft relevance;
  finished quest/vendor/drop alternatives survive personal crafting filters.
- `StatPriorities.lua`: Balanced, Prioritise a Stat and Custom Weights. Weights
  multiply *signed* normalized stat deltas against the actual equipped set.
  A priority triples that stat's default weight; it never ignores losses.
  Values are finite, nonnegative and at most 100. Unedited custom weights retain
  defaults, and zero is supported. Settings live in `GetGear_CharacterDB`.
- `GearCompare.lua`: retains spell/armor/resistance alias normalization and
  paired weapon/ring comparisons; incorporates readable tooltip DPS and keeps unreadable weapon DPS unknown; excludes
  potential-only offhands from upgrade qualification. Readable candidate or
  equipped proc/use effects and unsupported positive or negative stats leave the score
  unknown rather than inventing effect values. Missing item data remains open.
- `Core.lua`, `UI.lua`: initialize preferences without schema reset, refresh on
  quest updates, add a Recommendations panel with the geographic toggle and optional stat controls,
  show concise priority explanations with existing deltas, and sort overlay
  results by weighted gain before applying the existing 32-card limit.

Pipeline: valid identity/proficiency → source hard restrictions → independently
eligible routes → optional compact travel preference → existing real replacement
comparisons → weighted eligibility/order → existing concise presentation.
Bags branch into capacity logic and never enter equipment scoring. Full-guide
lists retain poor weighted choices and the all-valid/off-role option. Hard class
and source restrictions cannot be lifted by preference changes. Existing
five-level ageing, random green BoE filtering, armor-only default, progress and
map lifecycle protections remain.

### Weight units and limits

Weights express preference per reported stat unit, not a calibrated DPS/HPS
simulation. Balanced favors relevant attributes using the existing class rules;
physical classes weight Strength/Agility differently, pure casters ignore melee
DPS, and wand DPS remains relevant. Example defaults: Intellect 1, Spirit 0.7,
Stamina 0.5, Spell Damage 2, Healing 1, Attack Power 0.2, Weapon DPS 5, Health
0.05 and Mana 0.04. Armor defaults to zero until the existing armor preference
is enabled (0.02). Rating points and regeneration use their reported API units,
not a conversion to percentage or invented combat benefit. School bonuses retain
class-school eligibility. Generic spell bonuses normalize into damage/healing
capabilities as before; their separate user weights express those two uses.
These are transparent initial heuristics, not validated class balance advice.
Dual-wield DPS remains unknown because adding two weapon DPS values would be
misleading. A planned one-hand/offhand pair can be compared through the existing
explicit planning API; no owned partner is silently assumed.

## Geographic audit and policy

[Forever zone listing](https://www.wowhead.com/forever/zones/dungeons) and
[Forever world map](https://www.wowhead.com/tbc/classicplus-world-map-outro)
were reviewed alongside individual Forever zone pages. Listed level ranges are
editorial map guidance, not game-enforced requirements. The cutoff below is our
reversible travel preference, not a declaration that a zone is inaccessible.

| Classification | Sources covered | Compact opposing-faction cutoff |
| --- | --- | --- |
| Horde starting territory | Durotar, Mulgore, Tirisfal Glades | through level 20 |
| Alliance starting territory | Elwynn Forest, Dun Morogh, Teldrassil | through level 20 |
| Horde early territory | Silverpine Forest, The Barrens | through level 30 |
| Alliance early territory | Westfall, Loch Modan, Darkshore | through level 30 |
| Capitals | Both factions' three capitals; Stormwind naming alias | through level 20 |
| Contested/neutral | Zephras Isle, Redridge, Duskwood, Wetlands, Ashenvale, Stonetalon, Hillsbrad and later zones | no zone veto |
| Instances | Including Shadowfang Keep/Deadmines/Wailing Caverns | no zone veto |

A character already in a source zone retains that local route. An independently
named neutral travel exception (Parts and Pieces in Ratchet) is retained; a
remote neutral vendor elsewhere in opposing territory can still be impractical.
An appropriate alternative preserves the item. Disabling the convenience toggle
never permits a known opposing-faction quest/vendor route. Unknown/new/localized
zone names fail open instead of guessing faction ownership.

## Bag audit

[Machine-readable review](recommendation-bag-audit.json) covers 59 ordinary bag
names and 68 matching item/variant records from the preserved source snapshot.
40 IDs have runtime planning support; 28 rows are explicitly unresolved/excluded,
including ambiguous same-name variants, event bags, high-level quest unlocks and
missing live source/capacity evidence. They are not automatically adopted.
No previously held equipment candidate was approved, deleted or rewritten.

New researched quest options are Old Blanchy's Feed Pouch #1537 (quest 151),
Hunting Satchel #270017 (531 after 271), Soft Saber Sack #280088 (87288),
Book Bag #279936 (91775), Spidersilk Pouch #276891 (96260, Horde), and
Scuffed Shipping Crate #277332 (97253, both factions). The original Canvas
Latchbag #277977 (97277) remains. Book Bag #279935 is a quest tool, **not** the
six-slot reward. Several bag capacities changed in November hotfixes; newer
colored craft capacities are separately recorded without changing the original
four recipes. All published references remain unverified live.

Primary references:

- [Forever bag guide](https://www.wowhead.com/forever/guide/bags-storage-bank)
- [Poor Old Blanchy](https://www.wowhead.com/forever/quest=151/poor-old-blanchy)
- [Hunting Satchel](https://www.wowhead.com/forever/item=270017/hunting-satchel), [Vyrin's Revenge](https://www.wowhead.com/forever/quest=531/vyrins-revenge)
- [Soft Saber Pelts](https://www.wowhead.com/forever/quest=87288/soft-saber-pelts)
- [Book Return](https://www.wowhead.com/forever/quest=91775/book-return), [actual bag](https://www.wowhead.com/forever/item=279936/book-bag), [quest tool](https://www.wowhead.com/forever/item=279935/book-bag)
- [Stronger than Steel](https://www.wowhead.com/forever/quest=96260/stronger-than-steel)
- [Parts and Pieces](https://www.wowhead.com/forever/quest=97253/parts-and-pieces)
- [Grund and Gozwin](https://www.wowhead.com/forever/quest=97277/grund-and-gozwin)
- [November bag changes](https://www.wowhead.com/forever/news/tailoring-bag-cost-and-size-changes-wow-forever-hotfixes-for-november-11th-2026-383848)

## Validation and Git receipt

Local results and the new read-only, non-release CI workflow are recorded in
`docs/recommendation-validation.json`. All 7,707 equipment identities, 36,669
valid class objectives, 1,254 equipment crafts, source/recipe/navigation inputs
and 900 candidate holds remain protected. Existing tests are retained. Two
legacy assertions were updated to require net tradeoffs: a one-point healing
bonus cannot excuse larger spell/spirit losses; an explicit high healing weight
can restore that preference. Module-count assertions now include the three new
modules; performance/cache-request limits were not relaxed.

The required fresh reconciliation ran through the established snapshot wrapper:
nine original HTTP responses were captured; all 17 approved generated data/report
files were restored exactly. Fresh unrelated source changes were diagnostic-only.
The new CI has read-only repository permissions and cannot commit to a different
branch, package an addon or publish a release.

Final validation: **20 Lua programs pass on Lua 5.4 and Lua 5.1**, including
**330 new assertions**; four Python regressions and two catalogue-wide audits
pass. All 29 addon modules parse on each runtime (58 syntax checks). No local or
CI test failures remain. Protected source/candidate inputs: 97 files byte-exact.

Implementation commits: `ce71c9608784eececd85fb7f79863bbfcd3c0a8c` and
`b3ae8000763287ceeb2d73f699cde5a333e1f680`. Final implementation CI:
[43673339157](https://github.com/magicaddons/getgear/actions/runs/43673339157),
job 132687992055, **success**, all steps successful. Earlier implementation CI
[43672751063](https://github.com/magicaddons/getgear/actions/runs/43672751063)
also passed. The final follow-up commit records documentation/receipts only;
code validation applies to `b3ae800`. The workflow has read-only contents
permission and made no bot commits. No package, tag, release, main modification
or merge was performed. Stop for user review and client acceptance.

## In-game acceptance checklist

No installable archive has been created. After a separately authorized test build:

1. Alliance Priest with four six-slot ordinary bags: at level 9+, inspect Bags
   for Old Blanchy's eight-slot quest reward even though the six-slot craft plan
   adds nothing. At level 20+, complete Vyrin #271 and check Hunting Satchel
   #270017 alongside ten-slot craft choices. Verify a completed reward disappears
   and each one-time quest provides only one copy. Test Human and Dwarf/Gnome
   starting bags; confirm quest availability against the displayed caveats.
2. Toggle "Hide crafted gear I can't make" without Tailoring. Quest/vendor/drop
   bag options and externally crafted bags must remain. Equip upgrades and verify
   capacity recommendations update; specialty/reagent containers stay protected.
3. Use each quest/vendor Map button. Confirm the named giver's zone, active quest
   objectives, one-marker lifecycle and zone-only behavior where coordinates are
   unknown. Inspect full chain/source directions; no fake pinpoint is expected.
4. Alliance characters at 15/25: ordinary Silverpine/Barrens sources should be
   suppressed in the compact overlay, while Shadowfang Keep, contested sources
   and appropriate alternatives remain. Repeat on Horde with Westfall/Loch Modan/
   Darkshore. Confirm local-zone exception, toggle-off restoration and relaxation
   after levels 20/30. Hard faction rewards stay ineligible. Full Guide retains
   inconvenient alternatives. Repeat across the nine class tokens.
5. Priest: compare a +2 Intellect item that loses 6 Spell Damage. Balanced and
   Spell Damage priority must reject it. Choose custom Intellect 10 / Spell
   Damage 1 to verify a deliberate positive tradeoff; zero/decimal weights save,
   while negative/non-numeric values are rejected. Check priority explanations
   and visible positive AND negative deltas. Full Guide retains the poor choice.
6. Swap one-/two-hand weapons, main hand and offhand; a lone offhand with a
   two-hander shows potential benefits but is not a net-upgrade overlay objective.
   Compare a staff against both occupied hands. Test empty slots and both rings.
   Confirm wand/weapon DPS and unknown proc/use effects are labelled conservatively.
7. Reload/logout: Priest priorities and geography persist, Warrior/Rogue remain
   independent, and acquired/skipped/hidden settings survive. Open settings at
   narrow UI scales and confirm controls, decimal entry and overlay clipping.

## Outstanding limits

Live Forever quest availability, prerequisite graphs beyond the explicit Vyrin
step, Book Return's conflicting published race/minimum fields, exact giver
coordinates, event stock/loot, localized stat/DPS strings and actual rendering
still require client checks. Vyrin uses a conservative planning level 20 because
published fields conflict with a 15 minimum; Parts and Pieces uses planning level
14 pending a confirmed minimum. These planning levels must not be advertised as
verified equip or quest requirements. Full Horde acquisition coverage remains
incomplete despite enabling its valid class index. Unknown routes/effects are
qualified, not certified. The 28 bag review rows and existing six dungeon / 954
live recipe-book uncertainties remain open.
