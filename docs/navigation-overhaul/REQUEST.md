# GetGear — Comprehensive Navigation, Dungeon Entrance & Source Integrity Handover

**Project:** GetGear — World of Warcraft Forever
**Task:** Systemic navigation corrections, complete dungeon entrance audit, source quality reconciliation and regression prevention
**Priority:** High
**Scope:** All classes, factions, levels, equipment slots, bags, recipes, quests and acquisition sources

## 1. Authoritative development baseline

**Repository:** `magicaddons/getgear`

**Latest tested cumulative build:** `0.14.0-private-cumulative.20261118.4`

**Development branch:** `fix/cumulative-four-issues-20261118`

**Source commit:**
`cea9cdef9cc161959e3b3787dc0a0e025fbeb6e7`

**Canonical integration branch:** `integration/cumulative`

The `.4` build preserves all 29 runtime modules and passed 152 automated checks, with zero failures.

Start from the latest `.4` implementation, not from the older canonical commit or `main`.

Before implementation:

1. Fetch and verify the latest GitHub branches.
2. Confirm ancestry and the current canonical baseline.
3. Read `AGENTS.md`, `FEATURE_ACCEPTANCE.json`, `CUMULATIVE_BASELINE.json`, and `docs/SOURCE_CONTROL_AND_BUILDS.md`.
4. Preserve all accepted cumulative functionality and development history.
5. Create a separate development branch for this investigation.

Follow the mandatory commit, push, remote verification and testing-package integrity procedures.

Do not modify `main`, merge into the canonical branch or publish a public release.

---

## 2. Findings from actual in-game testing

The following observations come from testing cumulative `.4` in the WoW Forever client.

### Confirmed working

**Tracker-section divider**

Dragging and resizing the tracker sections now behaves correctly. Preserve the performance improvements and avoid reintroducing expensive refreshes while dragging.

**Slot filtering**

All tested overlay slot controls are working correctly. The unwanted dropdown arrow has been removed.

**Some acquisition markers**

Markers now appear and remain visible for certain equipment/vendor sources. However, this improvement is not consistent across all acquisition routes.

### Outstanding failures

**A. Excessively long NPC map labels**

Example: Brown Leather Satchel.

Current label:

`Ellandrieth, General Goods (Brown Leather Satchel)`

Expected:

`Ellandrieth`

For every NPC involved in obtaining equipment, bags, recipes or quests, the primary map-marker label should display only the NPC's actual name.

This includes vendors, recipe vendors, trainers, quest starters, quest turn-in NPCs and other named acquisition NPCs.

Preserve profession, item, quest, vendor, currency and access details in the guide or tooltip where useful.

Implement a shared, structured NPC-name formatter. Do not merely truncate strings at commas or parentheses, as legitimate NPC names may contain punctuation.

**B. Incorrect Stockades marker**

Example: Veteran's Chain Helm (item 250498).

Selecting the Stockades acquisition source places a marker on the Stormwind City map, apparently away from the dungeon entrance.

GetGear currently stores an exterior entrance approach at approximately `41.0, 57.0`.

Other Forever-specific references suggest approximately `50.4, 66.2`, but these competing coordinates must be independently checked against the correct Forever map before adoption.

Investigate why the existing source was accepted, whether the stored point is an approximate approach rather than a portal, and whether coordinate/map transformations are correct.

Do not replace one unverified coordinate with another.

**C. Missing Wizbang's Gunnysack marker**

Item 2082.

Selecting its acquisition location opens the Darkshore map and displays an NPC name, but no visible GetGear marker is placed.

Investigate quest-source resolution, coordinate availability, target construction, canvas placement, map ID and lifecycle.

**D. Disappearing Deviate Hide Pack marker**

Item 918, quest 1486.

Selecting the location opens the map and initially displays a marker around Wailing Caverns.

The marker disappears approximately 0.5 seconds later.

This persists despite the recent general marker-lifecycle corrections.

Investigate quest-log update handling, selected source identity, target replacement, route regeneration and delayed refresh events.

The published Wailing Caverns approach is not necessarily the precise location of quest giver Nalpak. Preserve this distinction.

**E. Missing Redridge vendor markers**

Two reproduction examples:

- Veteran's Silvered Chain Leggings — item 250523
- Guard's Silvered Chain Shirt — item 250519

Both open Redridge Mountains without displaying a marker or NPC name.

GetGear's existing data identifies:

- NPC: Stondry Darkhammer
- Location: Three Corners, Redridge Mountains
- Coordinates: approximately 10.4, 74.7

The location information already exists in the catalogue.

This strongly suggests a source-to-navigation conversion or rendering defect, rather than simply missing research.

Audit all other equipment and recipes using the same vendor/source structures.

**F. Raptorclaw Greaves — unresolved dungeon entrance**

Selecting the location for Raptorclaw Greaves, an Excavation Site: Wetlands dungeon item, reports:

"No trustworthy outdoor entrance point is available from the client or reviewed references."

GetGear's existing Excavation Site: Wetlands definition has an empty entrance-coordinate list.

However, published information describes the dungeon's location above Whelgar's Excavation Site, and external guides provide potentially usable coordinates.

Research and verify the correct exterior entrance rather than assuming the location is unknowable because the current dataset is incomplete.

---

## 3. Comprehensive dungeon entrance audit

This is a major requirement.

Do not limit research to the six reported examples or a handful of existing dungeons.

The current `navigation_instance_entrances.json` dataset contains:

- 32 dungeon/instance definitions.
- 20 definitions with entrance coordinates.
- 12 definitions without coordinates.

All 32 definitions currently cite the same Wowhead Forever dungeon overview guide.

That overview may be useful, but a single source is insufficient for a complete and reliable navigation database.

### Required investigation

Establish the complete dungeon and instance roster applicable to the supported WoW Forever client.

Include:

- Original Classic dungeons.
- Forever-added dungeons.
- Alternative names and aliases.
- Multiple entrances and wings.
- Exterior portals.
- Approaches to entrances inside caves or buildings.
- Relevant quest-giver locations near dungeon entrances.

Research every applicable dungeon, including those already containing coordinates.

For each entrance record, establish:

1. Canonical dungeon identity.
2. Alternative names and aliases.
3. Exterior zone and appropriate UI map ID.
4. Entrance coordinates in the correct map coordinate system.
5. Whether the point represents an actual portal, cave entrance, general approach or approximate area.
6. Current evidence and source provenance.
7. Conflicting published locations.
8. Whether a valid native client entrance record is available.
9. Whether the destination has been verified in the actual Forever client.

Where several entrances exist, preserve separate route choices.

Never substitute an interior boss or NPC coordinate for an exterior portal.

### Completeness requirement

Research every missing entry independently.

Do not stop after checking the existing overview guide.

If a source does not provide coordinates, search additional appropriate sources before declaring the entrance unresolved.

For unresolved records, document:

- Sources examined.
- Relevant findings.
- Reason the evidence is insufficient.
- Exact missing information.
- The next verification method required.

Do not invent locations simply to achieve full coverage.

---

## 4. Source reliability and database audit

The owner has identified a recurring problem: GetGear sometimes describes locations as unknown even though useful information can be located quickly through ordinary research.

Investigate both source quality and the data-processing pipeline.

### Source inventory

Identify every external source currently contributing to:

- Dungeon entrances.
- NPC positions.
- Vendor locations.
- Recipe vendors.
- Quest starters and turn-ins.
- Acquisition coordinates and map IDs.

Record how each source is used and its known limitations.

### Proposed evidence hierarchy

**Tier 1 — Current Forever client evidence**

Actual in-game observations and applicable client API/map data.

Preferred for verifying live coordinates, map compatibility and marker behaviour.

**Tier 2 — Forever-specific published references**

Wowhead Forever item, NPC, quest, zone and dungeon records.

Assess the relevant page individually; do not assume every published guide coordinate is correct.

**Tier 3 — Independent Forever databases**

For example, ForeverDB and other sources with demonstrable Forever-specific or client-derived information.

Use to corroborate, supplement or challenge existing evidence.

**Tier 4 — Credible community research**

Guides, screenshots and documented observations with identifiable version and location context.

**Tier 5 — Historical or unverified references**

Older Classic databases, cross-version information, unsourced aggregators and uncertain community claims.

Keep explicitly qualified. Never silently promote historical information to confirmed Forever data.

This hierarchy is a starting proposal. Review the actual provenance and reliability of each provider before finalising the policy.

### Important restrictions

Do not indiscriminately remove useful sources.

Instead, identify sources that are inaccurate, outdated, cross-version, incomplete or being used beyond what their evidence supports.

Prune or downgrade specific unreliable feeds or records when justified.

Retain traceability to original evidence.

A source's failure to document something is not proof that the location does not exist or cannot be found elsewhere.

### Generator improvements

Review `tools/build_acquisition_navigation.py` and its upstream source evidence files.

Investigate whether valid coordinates are being:

- Omitted during extraction.
- Rejected by overly restrictive acceptance rules.
- Associated with the wrong map ID.
- Incorrectly classified as continent-only coordinates.
- Lost during generation or reconciliation.
- Replaced by weaker evidence.
- Confused with interior locations.
- Excluded because only one source was previously consulted.

Correct systemic defects in the pipeline, not merely the generated output.

Where practical, produce a reproducible, source-backed generation process with conflict reporting and automated integrity checks.

---

## 5. Systemic map-marker reliability audit

The observed marker failures are inconsistent:

- Some markers render and persist.
- Some appear briefly and disappear.
- Some open a map and display a name but no marker.
- Some open a map with neither marker nor name.
- Some report that usable coordinates are unavailable.
- Some markers appear at questionable coordinates.

These should not be treated as unrelated item-specific bugs.

Investigate the entire navigation pipeline:

**Acquisition source → eligibility and route selection → source identity → coordinate resolution → map ID → map opening → marker creation → lifecycle updates → marker persistence.**

Review:

- `AcquisitionNavigation.lua`
- `AcquisitionNavigationData.lua`
- `MapNavigation.lua`
- `Core.lua`
- Bag and quest navigation adapters
- Related generators, evidence and tests

In particular, inspect delayed quest-log refreshes and the interaction between generated route identifiers and active marker identity.

The current quest-marker revalidation mechanism should be tested against real route regeneration, not just static fixture identities.

Ensure opening the quest log or map does not incorrectly invalidate a still-relevant acquisition marker.

Preserve explicit clearing when the user selects a different destination, abandons the context or legitimately advances a quest stage.

Avoid continuous polling, expensive recomputation or other performance regressions.

Do not interfere with native waypoints or other map addons.

### Consistent fallback behaviour

If a trustworthy coordinate is available, the destination should produce a visible marker.

If only an approximate area is supported, display an appropriate area/approach indication rather than an invented precise point.

If no defensible coordinate is available, provide useful written directions and a clear explanation.

Opening a map with no marker or explanation must not silently appear to be a successful navigation action.

---

## 6. Automated regression coverage

Implement data-driven tests covering the whole catalogue and every supported navigation route type.

Include:

- All available dungeon entrance definitions.
- Every supported entrance alias and multiple-entrance route.
- Vendors and recipe vendors.
- Trainers.
- Quest starters and turn-ins.
- Quest chains and objective updates.
- Bag acquisition routes.
- Crafted equipment and recipe learning sources.
- Dungeon drops and exterior approaches.
- All equipment slots.
- Both factions and all nine classes.
- Different player levels and quest states.
- Map switching, zoom, canvas scaling, close/reopen and delayed map loading.
- Delayed quest-log updates and route regeneration.
- NPC name formatting.
- Unknown and contradictory source evidence.

Every reported item must become a regression test, but the tests must also examine analogous cases throughout the catalogue.

Use the actual code paths wherever practical, rather than simplified test-only substitutes.

Record how many source records, routes, dungeon definitions and marker interactions were audited.

Include negative tests ensuring inaccurate coordinates are not silently accepted.

### Preserve existing functionality

Retain:

- All 29 runtime modules.
- Working tracker-section resizing.
- Working slot filtering and controls.
- Existing map-marker improvements.
- Balanced, Priority and Advanced stat settings.
- Talent awareness.
- Faction/access filtering.
- Bag alternatives.
- Material names and quantities.
- Existing recipe requirements, including the 104 recently restored minima.
- Explicit uncertainty for the 15 unresolved recipe requirements.
- All existing user settings and progress.

Do not introduce new feature regressions while correcting navigation.

The separate general item-looting/game-hitching investigation remains outside this task.

---

## 7. Validation and final deliverables

Perform a complete local regression run and GitHub CI validation.

Produce:

1. A complete dungeon entrance audit with each entrance's evidence and verification status.
2. A source-quality assessment identifying accepted, downgraded, rejected and conflicting sources.
3. A report on the underlying navigation failure mechanisms.
4. Systemic runtime and generator corrections.
5. Catalogue-wide regression results and remaining gaps.
6. An updated cumulative private testing ZIP.
7. A corresponding build manifest and SHA-256 checksums.
8. An in-game acceptance checklist covering all reported examples.

Push the complete development branch to GitHub and verify the exact remote commit before creating the final testing ZIP.

Follow the repository's mandatory source-integrity build procedure.

Do not merge into `main`, publish a release or advance `integration/cumulative` without explicit authorisation.

If some external locations remain genuinely unverifiable, preserve their uncertainty and report the remaining work rather than fabricating results.

---

## 8. Credit exhaustion, checkpoints and automatic resumption

**The owner authorises continued work on this task across available Codex usage windows.**

This is a potentially extensive research and development task. Do not unnecessarily abandon unfinished work simply because it spans multiple sessions or credit windows.

### Checkpoint policy

Break the work into coherent, independently reviewable phases:

1. Source and dungeon roster inventory.
2. Full entrance and evidence audit.
3. Navigation runtime root-cause analysis.
4. Systemic implementation.
5. Catalogue-wide testing and correction.
6. Final packaging and documentation.

Complete as much of each phase as the available usage permits.

At every meaningful checkpoint:

- Save all research and findings.
- Commit intended changes.
- Push the development branch to GitHub.
- Verify the remote commit.
- Document completed work, outstanding work, blockers and exact continuation instructions.

Do not rely on temporary session memory or unpushed local files.

### Usage and credit restrictions

**Never:**

- Purchase additional credits.
- Authorise payment or spending.
- Redeem banked usage resets.
- Change subscription plans.
- Access billing settings.
- Trigger any paid service on the owner's behalf.
- Attempt to bypass platform usage limits.

If usage is exhausted, stop invoking unavailable services and preserve all available work.

### Resuming after the five-hour usage window

If the Codex environment supports automatic task continuation after its usage allowance refreshes, attempt to resume this same task after the applicable five-hour window resets.

Before resuming:

1. Check that usage is available.
2. Fetch the latest remote development branch.
3. Read the checkpoint and continuation documents.
4. Verify the source commit and current task scope.
5. Continue from the next incomplete phase without repeating finished research unnecessarily.

If the platform does not support automatic resumption, background scheduling or waking an exhausted session, do not pretend that it does.

Instead, leave a complete durable continuation handover so the owner can manually restart the task when usage becomes available.

Do not repeatedly poll an exhausted service or consume additional usage merely to check whether it has reset.

This authorisation applies only to the present GetGear navigation/source-integrity task.

---

## 9. Completion criteria

Do not declare this investigation complete merely because the original examples pass synthetic tests.

Completion requires:

- A comprehensive audit of the applicable Forever dungeon entrance roster.
- Reliable, documented and correctly classified entrance data.
- Investigation and correction of systemic navigation inconsistencies.
- Proper source provenance and conflict handling.
- Meaningful regression coverage across acquisition types.
- Preservation of all cumulative functionality.
- Verified GitHub source and CI.
- A complete installable private testing package.

Actual marker placement, visibility and persistence still require in-game acceptance by the owner.

**The objective is not simply to repair the seven reported examples. It is to make GetGear's navigation and location information consistently reliable across the entire add-on, while preventing the same classes of defects from recurring.**
