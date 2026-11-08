# GetGear Beta 4 data architecture

The source of truth for each item is **ResearchedItemFacts.lua** (259
pre-import records containing final researched facts and confidence labels),
falling back to **EquipmentCache.lua** (7,678 additional compact Forever
beta-client records). When an ID occurs in both, the researched item facts
win; the equipability mask/level derived from the client cache is independent.

**GuideEngine.lua** builds one class-wide index directly from equipability
masks; there are no editorial Recommendation tables, spec-profile selectors
or extra Main Hand/Off Hand recommendations. **GuideState.lua** handles
progress and level-window lists. **GearRelevance.lua** applies the same
five-level and stat-role rules to ALL records. **TalentAwareness.lua** reads
WoW Forever's CamelotCombat trait groups, never modifies talents, and
recognizes only a clearly dominant Mage tree for exclusive school bonuses.

**MapNavigation.lua** retains map-opening code; all old patch files,
recipe-source reconciliations and acquisition edits have been folded into
the final researched facts. Runtime helpers for recipe knowledge, bags,
materials, account inventory, item-cache load guards and gear comparisons
are independent, unchanged except for the new source/visibility boundary.

### Original evidence and regeneration

Historical staged releases, and the one-time migration scripts used
to flatten all 259 finalized researched records, remain in Git history.
For future dated item-cache updates, run
`python3 tools/build_beta4_cache.py --input /path/to/Forever\ Cache.json`
and review the generated `EquipmentCache.lua` and audit report before
committing. This wraps `build_forever_catalog.py` and
`rewrite_beta4_generated.py`, retaining compact class eligibility rather
than emitting editorial recommendations. The separate
`build_beta4_school_hints.py` tool computes conservative pure-school
candidates from the SAME cache SHA; its output must be independently
reviewed before merging into `ResearchedItemFacts.lua`.

These are development tools, not addon files. Source facts from the
original manual guides are preserved in the active canonical research data,
and all old amendment modules are retained in Git history only.

The initial Beta4 build resets per-character progress and presentation
preferences with `schemaVersion=4`. Account-wide inventory tracking is
intentionally separate.

### Limitations

Cached equipment facts are NOT proof of acquisition on the live realm.
Hand-authored research is preserved as evidence, not as a special permission
to bypass universal filtering. An uncertain talent API or split fails open;
users can also opt into the complete class-equippable catalogue.


## Beta 7 source reconciliation overlay (development candidate)

After `EquipmentCache.lua`, the generated `GeneratedBeta7Evidence.lua` applies
2026-10-31 client recipe material inputs and conservatively sourced boss,
vendor and quest names. `SourceEnrichment.lua` follows it and applies the
three individually researched item corrections. This order is required by
`GetGear.toc` and checked by `tests/beta7-evidence.lua`.

A changed client recipe reagent list takes precedence over older manually
entered materials, but the original 43 disagreement pairs are preserved
in the separate pre-integration audit candidate and are not presented as
fully live-verified. No generated data assigns a recipe learning skill,
binding status or guaranteed faction/vendor access. The source generator and
7,678-row item audit are committed under `tools/` and `docs/`, respectively.

Unverified source identity is not an equipment eligibility veto: appropriate
items remain visible with unverified-source labels, while conservative
class/role and five-level ageing rules still apply. Public `main` remains
v0.12.14; this Beta 7 work must not be merged without client validation.


### Beta 7 primary armour preference correction

The core equipability mask remains unchanged; a Warrior can technically equip
leather. For the default guide, however, `GearRelevance.lua` now restricts
body-armour choices to the class's **preferred armour type at that level**:
Warrior/Paladin Mail through 39, Plate from 40; Hunter/Shaman Leather through
39, Mail from 40; Rogue/Druid Leather; Priest/Mage/Warlock Cloth. Item slots
such as weapons, cloaks, jewellery and trinkets are not subjected to this tier
rule. The level-1–60 Preview calculates by the item's target level; live
current-item lists use the character level; future items use the expected
future equip level. The explicit "Show all valid equipment" setting bypasses
this soft preference filter without allowing known QA records. Explicitly
researched, reviewed exceptions can be added to the local allow-list.

This was introduced after a live tester found Ceremonial Leather Harness
(#3313, +4 Agility/+3 Spirit) in a Warrior default list. Class proficiency
and stat-role alone were too permissive. Verified by
`tests/beta7-armor-priority.lua` and `tests/beta4-filters.lua`.
