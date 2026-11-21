# GetGear — Stabilisation, Regression Prevention & Performance Investigation

## Objective

GetGear has reached an important milestone. The latest cumulative `.7` build represents a significant improvement over earlier releases, particularly in map-marker reliability.

The next development phase should prioritise stability, correctness, performance and regression prevention rather than adding features.

**Primary objective:** Establish a dependable, fully tested cumulative build while preserving functionality that has already been validated in the actual WoW Forever client.

## 1. Current in-game acceptance results

The user has extensively tested the latest `.7` build on two different characters, navigating multiple equipment categories and acquisition sources.

Confirmed observations:

- Bag map markers are now displaying correctly.
- Stondry Darkhammer's marker appears on the Redridge Mountains map, with the correct NPC name.
- Marker rendering over map artwork has improved significantly.
- The user has tested many other markers across categories and is comfortable with their current behaviour.
- Overall, `.7` is a substantial improvement over previous builds.

**Treat the existing map implementation as provisionally accepted. Do not rewrite or replace it without a demonstrated technical necessity.**

Two minor issues remain:

1. Some stationary NPCs are still described as having an "approximate published area", despite potentially having reliable, precise coordinates.
2. Marker labels near map boundaries can appear noticeably off-centre because the boundary-handling logic shifts them to remain visible.

Neither is currently considered a blocker.

## 2. Preserve the working baseline

Before modifying code:

1. Identify the exact source commit and packaged contents corresponding to the working `.7` release.
2. Preserve a reproducible baseline.
3. Verify that all previously completed functionality is present.
4. Record the current automated test results.
5. Identify any differences between the working package and the current development branch.

We previously encountered a serious packaging regression where a cumulative ZIP contained an outdated runtime and omitted completed functionality.

This must not happen again.

All subsequent development and packaging must proceed from the verified cumulative baseline, not an assumed branch state.

Do not remove, revert or silently replace existing features.

## 3. Establish a comprehensive permanent regression suite

This is the highest-priority engineering deliverable.

Audit the existing test framework and expand it into a permanent regression suite covering GetGear's supported functionality.

Build upon existing tests rather than unnecessarily replacing them.

### A. Equipment recommendations

Verify:

- Class equipment eligibility across all nine classes.
- Correct faction restrictions.
- Alliance/Horde acquisition practicality.
- Level-range filtering.
- Talent-aware recommendation filtering.
- Appropriate recommendations for ambiguous talent distributions.
- Balanced, Priority and Advanced stat evaluation.
- Correct handling of positive and negative stat deltas.
- Two-handed versus one-handed/off-hand comparisons.
- Empty equipment slots.
- Removal of irrelevant or non-equippable recommendations.
- Correct handling of random BOE drops.
- Items hidden because of existing user preferences.

Use representative fixtures covering multiple levels, classes, factions and acquisition methods.

### B. Equipment-slot filtering

Verify that slot filtering works consistently in the compact overlay and detailed guide.

Test:

- All Slots.
- Each individual equipment slot.
- Transitions between slots.
- Switching characters.
- Changing character level.
- Hiding and restoring items.
- Maintaining filter selections where appropriate.
- Interaction with available, upcoming, completed and hidden recommendations.
- Bags and other special views.

Ensure that filtering does not lose recommendations or corrupt persistent settings.

### C. Acquisition information

Validate:

- Quest rewards and quest chains.
- Dungeon boss drops.
- Dungeon trash drops.
- Vendor purchases.
- Trainer availability.
- Crafting recipes.
- Recipes obtained through drops, vendors or trainers.
- Profession skill requirements.
- Crafting materials and totals.
- Faction restrictions.
- Acquisition source descriptions.

Specifically investigate the general class of problems previously seen with items such as Veteran's Chain Helm, where recipe learning sources or skill requirements were reported as unverified.

Use known examples as regression fixtures, but do not hardcode isolated fixes.

### D. Map-navigation regression suite

This area requires especially strong protection because of the repeated problems in previous builds.

Test:

- Correct map selection.
- Correct map hierarchy and zone IDs.
- Visible marker creation.
- Marker positioning.
- Marker rendering above map artwork.
- NPC label display.
- Map-boundary behaviour.
- Opening and closing maps.
- Repeated clicks.
- Switching zones.
- Switching acquisition categories.
- Dungeon entrance navigation.
- Quest, vendor, trainer, recipe and bag navigation.
- Valid handling of genuinely uncertain coordinates.

A particularly important regression case:

**Opening the correct zone map without displaying a visible marker must be treated as a failure when a valid marker location is available.**

Where the actual game client cannot be simulated, test the coordinate transformations, map API calls, marker state and rendering inputs through suitable fixtures or mocks.

Clearly identify which behaviours still require in-game validation.

### E. Settings and UI

Verify:

- Alphabetical ordering of relevant display settings.
- Balanced, Priority and Advanced mode selection.
- Advanced weight inputs and persistence.
- Character-specific saved settings.
- Talent-awareness settings.
- Item hiding and restoration.
- User-controlled crafting eligibility filtering.
- Preview Mode.
- Account Inventory Browser.
- Correct text wrapping and spacing.
- Resizing and scrolling.
- No unintended changes to existing configuration values after upgrading.

### F. Automated release-package validation

Tests must run against both the development source and the exact cumulative package intended for delivery.

The packaged release must be checked for:

- Complete module inventory.
- Correct versions of all modules.
- Required data files.
- Correct TOC and loading order.
- Missing or obsolete files.
- Lua 5.1 compatibility.
- Lua 5.4 compatibility where applicable.
- Correct inclusion of previously completed functionality.
- No accidental return to older source implementations.

Generate a manifest that allows the release package to be compared against the verified source tree.

**A successful source-tree test run is not sufficient if the delivered ZIP differs from the tested implementation.**

## 4. Minor map refinements

These should be narrowly scoped improvements.

### A. Approximate NPC locations

Investigate why certain stationary NPCs, including Mivin Shadowweave, are represented as approximate published areas.

Determine whether the uncertainty originates from:

- Missing coordinate data.
- Source-data quality.
- Conflicting coordinates.
- Map-coordinate conversions.
- Acquisition-source classification.
- Fallback positioning logic.

Where verified exact coordinates exist, use them.

Where coordinates genuinely remain uncertain, retain appropriate qualification.

Do not fabricate precision or remove uncertainty labels simply to make the UI cleaner.

Apply any correction through generalised source-handling logic, not an NPC-specific exception.

### B. Marker label positioning

Review `fitLabel()` and the associated boundary-handling behaviour.

Desired behaviour:

- Centre labels above markers whenever possible.
- Shift labels only when required to remain visible.
- Minimise the amount of displacement.
- Preserve readability.
- Prevent clipping at all map boundaries.
- Avoid interfering with marker placement.

Keep this change cosmetic. Do not disturb the now-working map-marker layer and rendering logic.

## 5. Separate performance investigation

There are two previously reported performance concerns.

### A. Looting-related hitching

The user has noticed increased game hitching in some circumstances while GetGear is open, particularly when looting.

Other addons, including ItemTree, may also contribute.

Investigate GetGear's potential involvement without assuming it is responsible.

Focus on:

- BAG_UPDATE and related inventory events.
- Repeated inventory scans.
- Recommendation recalculation frequency.
- Unnecessary full catalogue scans.
- Excessive UI rebuilding.
- Repeated sorting or filtering.
- Event storms.
- Garbage creation and allocation pressure.
- Unnecessary work while the overlay is hidden or idle.

Where possible, introduce lightweight instrumentation to measure event frequency, execution time and allocations.

Compare representative scenarios with the overlay visible and hidden.

### B. Tracker resize-control lag

The tracker section resize control has previously behaved erratically when dragged, sometimes causing severe lag or failing to resize smoothly.

Investigate independently of the looting issue.

Check whether resize operations are causing excessive:

- Layout recalculation.
- UI object creation.
- Redrawing or repositioning.
- Full list reconstruction.
- Other synchronous work.

Use appropriate throttling or deferred updates only if supported by the actual performance findings.

### Performance requirements

1. Identify and document root causes before implementing significant changes.
2. Establish a measurable baseline where practical.
3. Fix confirmed GetGear bottlenecks.
4. Preserve existing behaviour and responsiveness.
5. Add regression or benchmark checks where practical.
6. Clearly identify any observations that cannot be verified outside the WoW client.

Do not claim that hitching is resolved solely because automated tests pass.

Treat looting and resizing as separate investigations unless evidence demonstrates a shared cause.

## 6. Regression-prevention policy

All fixes must follow the established GetGear development policy:

**A bug observed on one character, item, faction, location or acquisition source must be investigated as a potentially systemic issue.**

Use reported examples as test cases, not as the boundaries of the fix.

For each confirmed defect:

1. Identify the underlying cause.
2. Determine which other classes, items, sources or UI views could be affected.
3. Implement a general, data-driven correction.
4. Add a regression test.
5. Validate relevant analogous cases.

The suite must remain permanently available for future development.

Where supported by the existing repository infrastructure, integrate it into GitHub Actions so regressions are detected automatically on future changes.

Tests should fail meaningfully when a previously fixed behaviour breaks.

Avoid superficial checks that merely confirm a function exists without validating its behaviour.

## 7. Scope control

This is a stabilisation milestone, not a feature expansion.

Do not:

- Redesign the overlay.
- Rebuild the map-marker system.
- Remove established features.
- Introduce new recommendation systems.
- Restructure unrelated modules without necessity.
- Change recommendation philosophy.
- Perform speculative optimisations without evidence.
- Introduce unnecessary dependencies.
- Claim actual client validation from mocked tests.

Prefer small, reviewable changes.

If performance investigation reveals a substantial architectural problem, document it and propose a separate remediation workstream rather than combining a risky rewrite with minor UI fixes.

## 8. Required verification and deliverables

Before declaring completion:

1. Run the complete existing and expanded regression suites.
2. Validate all Lua modules and supported Lua versions.
3. Run available GitHub CI checks.
4. Execute relevant performance benchmarks.
5. Validate the exact packaged release.
6. Confirm that existing functionality remains intact.
7. Document limitations requiring actual in-game verification.

Deliver:

- A cumulative installable GetGear ZIP.
- Exact source commit SHA.
- SHA-256 package checksum.
- Release manifest.
- Detailed regression-test report.
- Summary of new permanent tests.
- List of fixed defects and verified causes.
- Performance investigation report with measured findings where available.
- Outstanding issues and limitations.
- A short, focused in-game acceptance checklist.

Include the before/after regression-test counts and explain any failed, skipped or unavailable tests.

The handover must distinguish clearly between:

- Verified fixes.
- Automated-test coverage.
- Performance measurements.
- Unverified hypotheses.
- Issues requiring real-client confirmation.

## Completion criteria

This milestone is successful when:

- The accepted `.7` functionality has been preserved.
- A comprehensive permanent automated regression suite is established.
- The cumulative release package passes validation.
- Minor map-label and coordinate issues are resolved where reliable evidence allows.
- GetGear performance concerns have been investigated and measurable improvements implemented where justified.
- No new regressions are introduced.
- The resulting build is suitable for focused final in-game acceptance testing.

**The priority is reliability and regression prevention, not the number of code changes.**

Preserve what works, fix what is demonstrably broken, and ensure future development cannot easily reintroduce previous failures.