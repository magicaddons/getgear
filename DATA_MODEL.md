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

Historical staged releases remain available in Git history. The scripts
tools/build_beta4_catalogue.lua, tools/build_beta4_school_hints.py and
tools/rewrite_beta4_generated.py derive the consolidated data from the
pre-Beta4 branch's final effective item facts and the SHA-locked October 21
Forever beta cache. They are **development tools**, not addon files.

The initial Beta4 build resets per-character progress and presentation
preferences with `schemaVersion=4`. Account-wide inventory tracking is
intentionally separate.

### Limitations

Cached equipment facts are NOT proof of acquisition on the live realm.
Hand-authored research is preserved as evidence, not as a special permission
to bypass universal filtering. An uncertain talent API or split fails open;
users can also opt into the complete class-equippable catalogue.
