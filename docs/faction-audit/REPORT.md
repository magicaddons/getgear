# Global filtering and eligibility correction — 17 November 2026

Branch: `settings-ui-refinement`, preserving validated starting commit
`d500ce5364cb343ca162093c04e64245c9017605`.
Final implementation/CI identifiers and command receipts are in
[validation.json](validation.json). No release, package, tag or merge is authorized.

## Permanent policy

`AGENTS.md` now establishes the requested permanent principle: a reported example
starts an investigation of the underlying rule throughout the add-on. Every fix
must identify its root cause, determine the full applicable scope, correct shared
logic/data, audit analogous cases, add positive and negative regressions, and
report affected counts and limitations. An isolated exception requires evidence
that its cause is unique. Absence of more reports does not establish isolation.

[GLOBAL_FILTERING_POLICY.md](../GLOBAL_FILTERING_POLICY.md) adds the corresponding
review/release checklist. The non-release gate now validates the faction evidence,
its generated overlay, every catalogue entry and the relevant presentation paths.
Input/policy changes trigger CI; documentation-only validation receipts do not.

## Findings and generalized corrections

The girdle report exposed three interacting defects:

1. **Lost source metadata.** Published, committed merchant evidence explicitly
   records inventory faction and item reputation requirements, but older navigation
   projection discarded `inventoryFaction` and item-side data. Rutherford Twing
   NPC15126 therefore had a vendor route without an effective faction gate.
   The runtime checked `route.serviceSide`, `offer.side` and `actor.serviceSide`,
   but none contained the already researched restriction for this example.
2. **Missing item requirement layer.** Proficiency/class masks cannot express a
   battleground reputation affiliation. Item requirements, faction-attributed
   acquisitions and an individual seller's restrictions need different treatment.
   BoP alone does not prove an equip restriction, and a shared/tradeable alternative
   must not be discarded because one source belongs to the opposing faction.
3. **Inconsistent presentation boundaries.** Acquisition eligibility was applied
   to Available/Upcoming/Tracker and some materials paths, but Preview returned
   the raw class index. Earlier Gear, Show-all and other consumers could bypass
   access checks. Independent finished-item trade was implemented only for a small
   subset of crafted records with preexisting binding/spell metadata.

A new **independent eligibility overlay**, `FactionEligibilityData.lua`, restores
only name/ID-locked faction, binding and per-offer facts. It does not regenerate
or alter `AcquisitionNavigationData.lua`, the approved acquisition snapshot,
item identities, statistics, recipes or held candidates.

`AcquisitionNavigation.lua` now owns the shared item-use check, per-route faction
projection, supported acquisition alternatives, preview context and binding access.
`GearRelevance.lua` checks hard access before relevance/Show-all; `GuideEngine.lua`
uses the same source rules for Preview. `Materials.lua` also gates dynamic bag
materials. `GetGear.toc` loads the additional data module; version/schema are unchanged.

No item-family/name blacklist, faction-variant substitution table, manual spec menu
or class-specific filtering patch was introduced. The eight girdle IDs occur as
regression examples, not production exceptions. The six reviewed battleground
reputation affiliations are domain data, corroborated by exact-name published
item-side records and tooltip requirements; unknown reputations are not guessed.

## Shared rules

- **Equipment proficiency** remains in the existing class/weapon/armor logic.
- **Item use requirements:** recognized explicit faction/race/reputation
  requirements cannot be bypassed by trade, custom weights or Show-all.
- **Acquisition attribution:** a published side plus BoP is a conservative fallback
  about access, not an equip restriction. An explicit shared/friendly route or
  already learned craft can establish an independent legitimate method.
- **Per-source access:** quest faction/class/race conditions and qualified
  vendor/recipe offers are checked centrally. The supplement fills missing
  metadata and retains explicit shared facts. Published series alone do not prove
  mandatory prerequisites; no new chain-access or reputation-earning rules are invented.
- **Alternatives:** all supported routes are evaluated. Known finished-item BoE
  access can retain an otherwise usable item when direct sources are restricted;
  learned crafting does not require reacquiring a faction-specific book. Current
  cached client binding overrides older evidence; uncached information is not
  explicitly requested during scans. Trade text states that offers/listings are
  unknown and never points to a forbidden seller.
- **Relevance:** talent orientation, Balanced net deltas, Priority, Advanced,
  preferred armor, obsolete-item handling and travel practicality remain separate.
  Show-all lifts relevance filters but not confirmed access/use restrictions.
- **Surfaces:** compact candidates, full guide, Earlier Gear, Preview, materials,
  source summaries, choices and markers share the same access decision. Historical
  Completed/Hidden entries remain reviewable without erasing saved progress.
  Preview uses the current faction and selected class without borrowing another
  class's active quests, race or recipe progress.
- **Unknown data:** missing, malformed or contradictory information does not
  create a faction veto. No item/NPC name, zone ownership, neutral merchant or
  school/role attribute is used as faction proof. A lack of an explicit restriction
  is not represented as independent confirmation of unrestricted access.

Faction equivalents emerge from filtering the complete catalogue. The appropriate
Highlander's/Defiler's version remains available when other requirements allow it;
there is no hardcoded cross-faction conversion.

## Catalogue-wide audit

The audit covers **all7707 existing equipment IDs** and their source records,
all nine classes and both factions, with a separate matrix of **16 faction-valid
original class combinations**. No new equipment/candidate was adopted.

| Result | Count |
| --- | ---: |
| Matching full published Forever tooltips | 7699 |
| Supported faction requirement/attribution records | 420 |
| Item-use requirements from reviewed reputation affiliations | 238 |
| Separate acquisition attributions | 182 |
| Alliance/Horde attributed records | 220 / 200 |
| Supplementary per-item/book merchant-offer facts | 286 |
| Explicit quest-side evidence entries reviewed | 585 |
| Reputation/multiple-clause requirements requiring qualification | 209 |
| Missing or mismatched tooltip records | 8 |
| No explicit faction requirement found in matching tooltip/evidence | 7070 |

The complete evidence classifications are in
[catalogue-evidence-audit.csv](catalogue-evidence-audit.csv); the independent
runtime eligibility audit is [catalogue-eligibility.csv](catalogue-eligibility.csv).
Every selected publication fact retains its original file/pointer, source URL and
page SHA256 in [evidence.json](evidence.json). The full tooltip cache is pinned by
SHA256; no network refresh is required by the normal build/check or CI.

Compared with `d500ce5`, **449 items change eligibility** under faction-valid class
combinations: **364 lose invalid access** on at least one side, and **85 retain
newly recognized legitimate trade/alternative access**. Exact IDs, names, factions
and changed class sets are listed in [eligibility-changes.json](eligibility-changes.json).
This is wider than one item, class, slot, faction or level. The existing source
coverage CSV is regenerated from the same shared runtime rules and checked in CI.

Examples directly checked include all four girdle level variants:

| Equip level | Horde Defiler's Cloth Girdle | Alliance Highlander's Cloth Girdle |
| --- | --- | --- |
| 28 | 20164 | 20099 |
| 38 | 20166 | 20098 |
| 48 | 20165 | 20097 |
| 58 | 20163 | 20047 |

The opposing variants are excluded in all stat modes and Show-all; valid
counterparts remain for every proficiency-eligible class. Shared AV equipment
such as **Lei of the Lifegiver19312**, whose tooltip lists both Stormpike and
Frostwolf clauses, is not falsely turned into a single-faction item. Neutral
Barrens quests, shared dungeons, independent crafts and multi-source equipment
retain their legitimate routes.

Map-button auditing now distinguishes **character_restricted** from a missing
location. Current Alliance level25 reference counts:921 point,1192 area,525
written/native,209 character-restricted,2704 missing actionable targets,2156 not
applicable. The209 restrictions are not newly missing coordinates. Source points,
areas and instructions are unchanged; ineligible routes no longer produce pins.

## Recent systemic fixes rechecked

| Reported issue | Shared cause/rule and regression scope |
| --- | --- |
| Feral Druid caster recommendations | Existing nine-class committed-talent detection and role/net scoring retained;54 tree/faction fixtures, fallback, explicit Priority/Advanced and tracked/all materials rerun |
| Barrens/Silverpine recommendations | Hard source access remains distinct from low-level travel practicality; both factions, alternatives, neutral quests, shared dungeons and uncertain data rerun |
| Defiler's/Highlander's rewards | New item-use/attribution/per-offer layer plus global access boundary; all7707 IDs, all applicable classes, multiple slots/levels/methods and views audited |
| Compressed leggings title | Existing shared content-measured header retained;360 title/width/font/state/pin geometry combinations rerun, with no item-name special case |

## Validation and preserved behavior

The integrated local gate passes **130 commands**:29 runtime modules and three
Lua tools parsed on Lua5.1/5.4;27 Lua suites on both; five offline Python suites
including six faction-evidence unit cases; source/presentation/bag audits; frozen
faction overlay generation; exhaustive eligibility snapshots; and20 mocked
release-safety unit tests. The final audit classification was also checked for
byte-identical results on both interpreters.

New Lua coverage executes62704 class/faction records,320 level/view cases,
all girdle variants and all three stat modes; positive/negative trade, learned
crafting, per-offer versus merchant restrictions, race fallback, unknown evidence,
shared sources, preview, materials, dynamic bags and history. It verifies zero
explicit item-cache requests and cached-current-binding precedence. Existing
save/reload, equipment eligibility, bags, map lifecycle, talent and layout suites
remain in the gate. Non-release CI must validate the exact implementation SHA;
its completed result is recorded in validation.json.

All7707 equipment identities,36669 class objectives,900 candidate holds, the
approved17-file acquisition snapshot, previous settings/progress, recipe/material
facts and existing release assets remain intact. Original classes/factions are
not inferred from item names. The historical catalogue import helper contains
Alliance-oriented assumptions; it was inspected but not used to rebuild or expand
the accepted catalogue. This audit establishes coverage of the committed catalogue,
not every possible Forever server item.

Fresh reconciliation ran diagnostically in an isolated copy and failed the
unchanged `rare-boss==12 and trash>=137` guard (actual trash136). No fresh output
was adopted into the working catalogue. The failure is recorded separately in
[fresh-diagnostic.json](fresh-diagnostic.json) and its log. It is not a passing
reconciliation or permission to incorporate unrelated research data.

## Remaining uncertainty and actual-client checks

The209 qualified requirement records include legitimate neutral reputations and
multiple opposing-faction clauses, not209 proven invalid items. The8 absent/
mismatched tooltips and4150 equipment records without structured routes retain
explicit uncertainty. Neutral/new reputation allegiance, current stock, purchase
conditions, earning methods, live loot and undisclosed prerequisites are not
invented. Published side/requirements and known tradeability do not prove a
current offer or that the character has already earned the required standing.

The8 tooltip gaps are Hornwood Recurve Bow2506, Copper Mace2844, Copper Axe2845,
Copper Bracers2853, Reinforced Bow3026, Heavy Recurve Bow3027, Ashwood Bow5596
and Novice's Practice Wand247789. They remain uncertain rather than excluded.

Tests are offline and use synthetic frames/client APIs. Actual Forever rendering,
current talent API semantics, active quest overrides, reputation interpretation,
client binding and source availability still need in-game acceptance:

1. On an Alliance cloth wearer at28, confirm #20164 is absent from tracker,
   Available, Upcoming, Earlier and Preview even with Show-all, Priority and
   unusual Advanced weights. #20099 should remain eligible when other conditions
   allow. Repeat in reverse on Horde and at38/48/58 for the paired variants.
2. Check additional battleground/reputation rewards and multiple armor/weapon/
   accessory slots on faction-valid Warrior, Paladin, Hunter, Rogue, Priest,
   Shaman, Mage, Warlock and Druid characters. Inspect actual reputation/merchant
   requirements; no purchase/loot is guaranteed by the planning list.
3. Verify shared AV item19312, neutral Stepping Stones79192/Farmer's Shovel3334,
   Wailing Caverns and Shadowfang Keep remain accessible. Check a restricted
   seller plus a legitimate alternative, a finished BoE trade option, a learned
   recipe and an unknown source. Forbidden sellers must not reappear as map pins.
4. Confirm Completed/Hidden history survives, restoring an ineligible hidden
   objective does not make it an available recommendation, and all-materials/
   dynamic bag totals exclude ineligible sources. `/reload` and switch characters;
   stat-priority weights, toggles and progress must stay independent.
5. Recheck the Feral tunic20575 comparison, talent changes/fallback and Balanced/
   Priority/Advanced choices. Resize/minimize wrapped Blackened Defias Leggings
   #10400 beside Heavy Spiked Mace4778; verify source text, materials, click targets,
   backgrounds and scrolling. Test map-marker lifecycle and source directions.

No addon ZIP, release, tag, merge or main change is part of this work.
