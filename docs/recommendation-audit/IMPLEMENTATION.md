# Recommendation-system implementation and validation

Development handover: 15 November 2026. No release approval is implied.

## Baseline and initial findings

The supplied checkout was clean at main `4ba2a850`, but its gameplay modules
predated the accepted Beta9 source. The existing release manifest pins
`04992876bd4f50b66d6b6dd78d00b32cd0594cd3`. That exact source and its subsequent
documentation checkpoint `0958954a` were fetched and integrated on the separate
`recommendation-sources-stat-priorities` branch in `11971048`. Main's release
tooling and Beta9 ZIP were retained. This is necessary preservation work, not a
replacement of the accepted navigation, class/stat filtering or source audit.

The accepted implementation had three material gaps:

1. `GetBagPlanningObjectives` returned immediately when the selected crafted
   bag added no capacity. This also hid independently useful vendor/quest bags.
   Only Canvas Latchbag was implemented, with a Dwarf/Gnome convenience gate
   absent from the published quest restrictions. Worn bags could also be
   mistaken for spare replacements by a general item-count API.
2. Structured faction/class restrictions were applied to navigation but not
   consistently to guide/tracker lists, materials or descriptions. Horde
   characters received an empty guide. A low-level opposing-home-territory rule
   could suppress legitimate neutral routes. Raw multi-faction research prose
   could still direct a player to an ineligible seller even with a correct pin.
3. The existing overlay accepted a meaningful individual positive stat, with
   conservative role/armour/resistance rules. It had no per-character priority
   or custom-weight configuration, and no shared net-benefit ranking.

## Implementation

### Bags

`BagQuestData.lua`, generated from the frozen evidence JSON by
`tools/build_bag_quest_catalogue.py`, adds a separate bag-only overlay. It does
not add bags to the ordinary equipment/stat catalogue or rewrite existing
equipment/recipe source records. The equipment navigation exporter explicitly
skips this overlay when regenerating equipment routes.

Quest/vendor alternatives now run independently of the four existing tailoring
tiers. Four replaceable personal slots are checked; backpack, bank, reagent,
profession, ammunition and unknown-family containers are protected. Each quest
candidate supplies one reward copy, targets a strictly smaller ordinary bag and
reports the exact capacity gain. Equal/smaller rewards disappear. Inventory
contents are scanned once for all alternatives; known worn bags are not spares.
Unique ownership/equipped identity and already-owned bag/bank cases are handled
conservatively. A possibly worn Unique bag with an unreadable ID is not called
a spare. Completed one-time quests, skipped/acquired objectives and hidden
entries are respected without resetting progress. Supply Bag's published
repeatable exchanges remain qualified by their actual costs and Unique status.

Navigation reuses the shared quest progress/actor/area/entrance model. Existing
quest records and side-specific itineraries win over the bag overlay. Ordered
published series with unverified unlock rules do not silently skip across
unknown prerequisite gaps. Missing starting-item origins remain explicit;
turn-in NPCs/objects are not invented as quest starters.

### Source access and geography

`GetEligibleAcquisitionRoutes` is the shared projection for source access,
including quest side/class/race restrictions and per-service seller/trainer
side metadata. Items with multiple routes retain their eligible alternatives.
An already learned recipe does not require obtaining its book again. A known
recipe with explicit bind-on-equip finished-item evidence retains qualified
commission/trade access; it never exposes an opposing book seller or claims a
current offer exists. Unknown binding does not invent that alternative. Recipe
book quest minima do not become the finished item's equip/access minimum. No
alternative vendor, quest or current seller is fabricated.

Available/upcoming/tracker lists, tracked materials, notifications, source
descriptions and navigation use this model. Known quest minima can raise a
recommendation's effective target level without mutating canonical equip gates
or expiring it before it becomes obtainable. Other-class preview remains
browsing, not a comparison against the real character's equipment. Completed
and Hidden remain reviewable. Both factions can use the proficiency catalogue.

Opposing starting-territory travel is no longer an exclusion. Neutral Barrens
quests/drops and shared Silverpine dungeons remain legitimate leads. Travel
warnings and existing appropriate-trainer preferences remain informational;
neither zone ownership nor distance creates an eligibility restriction.
The guide displays eligible route descriptions and their requirements. Original
multi-faction source research remains intact in catalogue provenance, rather
than being deleted or presented as a current direction to the other faction.

### Stat priorities

Settings adds a second column in the existing settings window, centred to keep
the wider window on normal screens. There are no new overlay controls.

- **Balanced (default):** preserves the established class-aware filters and
  neutral ordering. Its existing allowance for meaningful individual tradeoffs
  is intentional compatibility behavior; it is not a universal weighted score.
- **Prioritise one stat:** class-relevant default weights, with the chosen stat
  multiplied by five. Armour priority uses 0.05 per armour point rather than
  treating one armour point like one primary attribute. An item without a gain
  in the chosen stat can still win through its other net benefits.
- **Advanced custom weights:** each supported attribute has a finite weight
  from 0 to 1000. Missing weights count as zero. Initial values use the normal
  defaults; every value can be edited. Scores sum signed **net deltas**.

For Priority/Custom, a known score must be greater than 0.0001 to qualify.
Known zero, negative and all-zero-weight results do not qualify. Incomplete
comparisons remain visible with an explicit unavailable score. Both list
surfaces use the same predicate and ranking. Show all valid equipment restores
independent browsing while still enforcing hard proficiency/QA restrictions.
The established world-BoE, crafting, age, armour, school and class filters remain
independent. Weighted scoring never handles bag capacity.

Raw stat gains/losses remain in rows and tooltips beside each comparison's
weighted net. Ring/trinket alternatives use the best valid replacement slot.
Two-handed replacements lose both main/off-hand attributes; one-handed
replacements lose the old two-handed stats. An offhand paired with a currently
worn two-handed weapon is potential-only until an explicit one-handed partner
is supplied. Dual-wield weapon DPS is never summed into combat performance;
missing or incomparable weighted DPS makes the score unknown. Reported DPS can
use a readable tooltip, without bulk item-load requests.

Preferences live in `GetGear_CharacterDB.statPriorities`. Existing schema4
progress, hidden flags, display settings and account inventory remain intact.
Restore Balanced defaults resets only these scoring preferences. Invalid
weights/modes are sanitized. Preview does not overwrite character preferences.

## Catalogue audit and evidence

- [All 94 returned normal-bag records](bag-catalogue-audit.csv), including
  unresolved/internal records, capacities, quest IDs and dispositions.
- [Frozen evidence and 75 URL/hash receipts](bag-quest-evidence.json): the full
  returned Bag list, 24 item pages and 50 quest pages, restricted to published
  item/quest metadata and objectives; historical comments are not evidence.
- [All 7,707 equipment source projections](equipment-source-eligibility.csv),
  evaluated across all nine classes and both faction contexts.

There are **23 published quest-bag candidates**, including **22 missing** from
the old bag planner. This is published-source confidence, not live acquisition
verification. The 94-row returned list does not prove database completeness.

| Item IDs | Bag(s), capacity | Acquisition / qualifications |
|---|---|---|
| 1537 | Old Blanchy's Feed Pouch, **8** | Alliance; Poor Old Blanchy #151, minimum9. Forever explicitly changes the old4-slot capacity. |
| 2082 | Wizbang's Gunnysack, **8** | Alliance; Buzzbox525 #1003, minimum7; published four-stage Buzzbox series. Old6-slot capacity is incorrect for Forever. |
| 918 | Deviate Hide Pack,10 | Both; Deviate Hides #1486, minimum13, Wailing Caverns. Reward page retains conflicting choice/guaranteed rows; select the bag if prompted and verify the live window. |
| 1729 /3352 | Gunnysack of the Night Watch / Ooze-covered Bag,10 | Alliance; #58 minimum18, published Night Watch series / #470 minimum19. Quiver/bandolier alternatives are not ordinary bags. |
| 9587 | Thawpelt Sack,14 | Separate Alliance/Horde Platinum Discs voucher turn-ins #2439/#2440, minimum40; earlier Uldaman unlocks remain qualified. |
| 10959 /11324 | Demon Hide Sack,16 / Explorer's Knapsack,14 | Shared published #3628 minimum45 / #626 minimum35. Long/partial unlock chains and physical starting-scroll origin remain explicit. |
| 11845 | Handmade Leather Bag,6 | Horde; Carry Your Weight #791 minimum4. Forever changes the old4-slot capacity. |
| 19291 /22679 | Darkmoon Storage Box,14 / Supply Bag,18 | Shared event/ticket exchange #7934 minimum6 / Argent Dawn repeatable exchanges minimum55. Tickets, event availability, reputation-dependent insignia costs and Unique status are retained. |
| 1652 /221498 | Sturdy Lunchbox / Old Toolbox,12 | Stepping Stones #79192 minimum14 currently lists both distinct rewards. Existing faction-specific starting itinerary is reused; verify the actual reward window. |
| 256935 | Simple Leather Satchel,6 | #92515 minimum4; explicit published race95 restriction, not an unrestricted original-race recommendation. |
| 260307 | Hyjal Postal Satchel,18 | #93269 minimum56; three published postal stages. Faction access/earlier unlocks remain unverified. |
| 270017 | Hunting Satchel,10 | Alliance; Vyrin's Revenge #531 minimum15, two published stages. |
| 276891 | Spidersilk Pouch,12 | Horde; Stronger than Steel #96260 minimum23. |
| 277200 | Scorched Leather Pouch,6 | Horde #95805 minimum1; published Tauren/Undead restriction retained. |
| 277332 | Scuffed Shipping Crate,8 | Both; Parts and Pieces #97253 minimum9 in Ratchet. The Barrens is not a faction veto. |
| 277977 | Canvas Latchbag,6 | Alliance; Grund and Gozwin #97277 minimum4. Published Grund Drokda location/objectives; no invented Dwarf/Gnome-only gate. |
| 279936 /279939 /280088 | Book Bag / Collecting Basket / Soft Saber Sack,6 | #91775 minimum1 (Dwarf/NightElf/Gnome); #86784 minimum4 (Orc/Undead/Tauren); #87288 minimum4 (NightElf/race95). Published race masks and quest series are retained. |

Red Bag226697 is **not recommended**: its primary page marks it unconfirmed.
Normal-list Test/bank containers are excluded. Items1977/13330/277845 without
reviewed acquisition routes remain unresolved. Other nonquest bags are audited
but do not acquire invented quests. The four accepted tailoring tiers and
Brown Leather Satchel vendors remain; this is not a complete new crafting/drop
bag guide or proof of current vendor stock/prices.

Equipment audit: **3,557** items have structured plans containing **7,003**
routes; **4,150** have no structured route. **380** items include an explicit
Alliance route, **227** include a Horde route, and **201** include both faction
variants. **932** have multiple routes. **2,990** structured plans include at
least one route whose faction access is unresolved; **567** have explicit
source-side metadata throughout. These are source-coverage counts, not counts
of live-verifiable farms. Unrestricted metadata is not automatically certified
neutral access. No zone-based restrictions or convenient alternatives were
inferred to close these gaps.

All **7,707 equipment identities /36,669 class entries**, the accepted17-file
acquisition snapshot, original recipe materials and **900 held equipment
candidates** remain intact. No existing release asset is changed.

## Validation and remaining acceptance

The repeatable development gate is `tools/validate_recommendations.py`, with a
read-only GitHub workflow `recommendation-validation.yml`. It runs28 module
syntax checks on Lua5.4 and5.1, all23 Lua regression scripts on both versions,
four offline Python generation regressions, the acquisition button and full
presentation audits, deterministic bag generation/source audit, and mocked
release-tool safety tests. Lua5.1 uses the existing test-only fixture compiler
adapter; addon source is not translated. The integrated gate contains115
command checks; source/preview/UI fixtures are simulated.

Fresh source reconciliation uses the accepted snapshot wrapper and retains
unadopted outputs separately. The local final reconciliation succeeded with
the accepted data restored exactly. Initial PATH and bag-export integration
failures were corrected, not represented as successful runs. An older test
requiring geographical suppression and another requiring an Alliance guide to
repeat the Horde seller were updated to the user's requested behavior; original
Horde research provenance is still asserted. Manifest module counts now include
the two new modules. No existing eligibility/material/source integrity assertion
was removed.

Final local and GitHub receipts, branch/commit URLs and exact preservation
hashes are recorded in [validation.json](validation.json).
Automated results do **not** confirm Forever rendering, live source availability,
quest acceptance or actual inventory-cache behavior.

Final gate: **PASS locally and in [non-release CI43715444716](https://github.com/magicaddons/getgear/actions/runs/43715444716)**,
job132815857668, source `a6b149632db883829b25b0261f83282efacaf361`. All115 command
checks passed, including23 Lua regressions on each version,28-module syntax on
each version, four Python generation regressions, both catalogue audits and20
mocked release safety tests. Fresh reconciliation passed and restored the
accepted snapshot. [Local receipts](local-checks.txt) and [timestamped CI checks](github-checks.txt)
are retained. The complete decoded job log was independently read through the
GitHub connector; CLI artifact/log redirect downloads returned403, so no local
artifact-byte verification is claimed. There is no failed or pending required
gate. Final receipt/CSV line-ending cleanup is documentation only; runtime
continues to match the tested source commit exactly.

In-game acceptance before any release:

1. With four6-slot bags at level9, confirm Blanchy's8-slot reward and neutral
   Ratchet8-slot crate appear even though the crafted6-slot plan is absent.
   Repeat after equipping8-slot bags; equal/smaller rewards must disappear.
2. Check all four ordinary bag slots, empty slots, profession/ammo containers,
   unreadable family/IDs, an already worn Unique bag, inventory spares and known
   bank ownership. Verify one-copy quest quantities and craft material counts.
3. Check Alliance/Horde/race restrictions, completed quests, acquired/skipped/
   hidden states and reload persistence. Confirm Book Return's bag is retained
   after completion, and the live Stepping Stones/Deviate Hides reward windows.
4. On both factions, verify exclusive quest/vendor/book routes disappear while
   neutral Barrens and shared Silverpine/contested dungeons remain browsable.
   Multiple-source descriptions, chain stages, actor choice and the one owned
   map marker must agree. Verify unclear quest unlocks/current stock directly.
5. Test Balanced, Spirit priority, and custom Spirit5/Intellect3/Stamina1 with
   actual mixed gains/losses. Compare weighted net and all raw deltas in guide
   and tracker. Verify zero/negative results and Show-all browsing.
6. Exercise empty slots, both rings/trinkets, mainhand/offhand/two-handed swaps,
   missing item data, dual wield and potential-only offhands. Verify caster/
   physical exclusions and all class weapon/armour restrictions remain intact.
7. Reload and switch characters; verify independent mode/weights, defaults reset,
   preview isolation, settings fit/wrapping/scale, tracked materials, inventory
   browsing and progress. No real-client validation was performed here.

## Git summary and review scope

- Branch: `recommendation-sources-stat-priorities` (pushed; no PR, merge to main or release).
- `11971048`: integrate the accepted Beta9 gameplay/source handover with current
  main's release tooling, on this isolated branch.
- `a6b14963`: the implementation, evidence, regression suites and validation
  workflow;37 changed files. The subsequent receipt commit changes documentation
  only. [Exact implementation file list](changed-files.txt).
- [Review the implementation against its integrated baseline](https://github.com/magicaddons/getgear/compare/11971048...recommendation-sources-stat-priorities).
  This avoids conflating the prerequisite recovery of accepted gameplay data
  with the three new improvements.
- Main remains `4ba2a850c4e3933b85f40c82a50b98314f117d80`; Beta9 tag still peels
  to `04992876bd4f50b66d6b6dd78d00b32cd0594cd3`. Existing Beta9 ZIP is unchanged:
  2,023,756 bytes, SHA256
  `c78667f180a103f1f6392c0275f052b16d4432a6d830a3495bbab412ef386a15`.
  Release helpers, publishing workflow, accepted catalogue/stat/material data
  and navigation coordinates/marker renderer were hash-checked unchanged.

Primary implementation files: `BagUpgrades.lua` / `BagQuestData.lua` and its
generator/evidence; `AcquisitionNavigation.lua` / `GuideEngine.lua` /
`GuideState.lua` for shared source access; `StatPriorities.lua` /
`GearCompare.lua` / `GearRelevance.lua` / `Core.lua` / `UI.lua` for scoring,
settings and integration; four new regression scripts plus the read-only
validator/workflow. Source and bag coverage CSVs retain the unresolved cases.
