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
