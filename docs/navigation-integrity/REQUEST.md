# GetGear — Navigation Renderer & NPC Location Integrity Handover

**Project:** GetGear — World of Warcraft Forever  
**Priority:** High  
**Task:** Correct persistent map-marker rendering failures and systematically reconcile inaccurate NPC coordinates  
**Development approach:** Root-cause investigation, data-driven corrections and catalogue-wide regression prevention

## 1. Authoritative source and baseline

Repository: `magicaddons/getgear`

Latest private testing build:

`0.14.0-private-cumulative.20261118.6`

Development branch:

`dev/navigation-source-overhaul-20261118`

Source commit:

`bee893e7c3f285afc23b90731422f14ae34ae3e1`

Canonical branch:

`integration/cumulative`

Previously verified canonical commit:

`685e612896c7297b18594bd28e448a21cac22dec`

The `.6` build preserves 29 runtime modules and passed 156 automated checks.

Before beginning:

1. Fetch the latest GitHub state and verify the existing development branch, commit and cumulative ancestry.
2. Read the repository's current `AGENTS.md`, feature acceptance contract and source-control/build instructions.
3. Review `docs/navigation-overhaul/REPORT.md`, `SOURCES.md`, `ACCEPTANCE.md` and `CONTINUATION.md`.
4. Preserve the completed `.6` navigation research and all accepted functionality.
5. Create an isolated continuation branch from the verified `.6` implementation.

Do not start from `main` or an older cumulative build.

Do not overwrite or discard the completed dungeon/source audit.

Do not merge into `integration/cumulative`, change `main` or publish a release without explicit authorisation.

---

## 2. Current situation

The owner has completed additional testing of `.6` in the actual WoW Forever client.

Although map data and quest-marker lifecycle handling were substantially improved, several acquisition markers still fail to render visibly.

A separate issue has also been demonstrated: some NPC markers are rendered in incorrect locations even though the NPC's actual position is readily identifiable.

These are not hypothetical failures inferred from synthetic tests.

They have been observed directly in-game, including screenshots and GetGear's own diagnostics.

**The objective of this task is to fix both systemic failure mechanisms, not merely patch the reported examples.**

---

## 3. Problem A — Invisible or incorrectly rendered map markers

### Reproduction A1: Azeroth Commerce Authority items

Examples:

- Veteran's Silvered Chain Leggings — item 250523
- Guard's Silvered Chain Shirt — item 250519
- Other ACA vendor recipes and equipment

These items point to Stondry Darkhammer in Three Corners, Redridge Mountains.

Published source coordinates:

`10.4, 74.7`

Selecting the acquisition marker opens the Redridge Mountains map, but no GetGear arrow or NPC name is visible.

The owner recalls this functionality working correctly in much earlier GetGear versions.

### Actual-client diagnostics

The owner executed:

`/getgear navdiag`

Immediately after opening the Redridge acquisition location.

The output reported:

```text
status=map
reason=nil
mapID=1433
destinationMapID=1433
selectionID=Recipe vendor|Redridge Mountains|...|Stondry Darkhammer...
entranceID=nil
source=nil
questID=nil
label=Stondry Darkhammer
zone=Redridge Mountains
markerShown=true
markerVisible=true
canvasVisible=true
canvasWidth=1200.0000610352
canvasHeight=668
canvasScale=0.6956087215218
markerScale=1.437589764595
```

The full selection identifier was wrapped across chat lines in the screenshot; use the saved reproduction details rather than assuming the abbreviated string above is the complete identifier.

These results establish that:

- The correct destination map is selected.
- The correct NPC name is resolved.
- GetGear has an active marker context.
- The marker frame reports that it is shown and visible.
- The map canvas reports that it is visible.
- The inverse marker scale is numerically consistent with the canvas scale.

**Nevertheless, the marker is not visibly rendered at the intended destination.**

This is a crucial distinction.

`markerShown=true` and `markerVisible=true` do not establish that the arrow texture and label are actually visible on screen at the correct coordinates.

### Reproduction A2: Wizbang's Gunnysack

Item 2082.

Selecting its acquisition location opens Darkshore.

Part of what appears to be the destination label is visible, but the actual marker arrow is absent.

The label may be clipped, obscured or positioned incorrectly.

The marker should identify the relevant verified quest-source location.

### Reproduction A3: Elite Shoulders

The owner selected a Wetlands acquisition location for Elite Shoulders.

The correct zone map opened, but the arrow was not visible.

Part of the associated map text appears to be drawn near an obscured or unexplored portion of the map.

Verify the exact item/source identity from the catalogue before constructing a regression fixture.

### Additional lifecycle regression

The owner previously observed Deviate Hide Pack (item 918) briefly displaying a marker that disappeared approximately 0.5 seconds later.

The `.6` overhaul contains a specific fix for an acquisition-identity overwrite responsible for that behaviour.

Preserve that correction and ensure the next changes cannot reintroduce it.

The owner has not yet confirmed the `.6` behaviour for every previous lifecycle example.

---

## 4. Required investigation — Map renderer

Investigate the actual map-marker renderer in `MapNavigation.lua`, including its interaction with the Forever map canvas.

Particular attention should be paid to:

- `WorldMapFrame:GetCanvas()`
- `WorldMapFrame.ScrollContainer.Child`
- `GetCanvasScale()`
- `SetParent()`
- `SetScale()`
- `SetPoint()`
- `SetFrameLevel()`
- `SetFrameStrata()`
- Map zoom and pan.
- Canvas clipping.
- Exploration overlays.
- Texture visibility.
- Map opening and lazy canvas creation.
- World-map frame resizing and changing maps.

The current implementation attaches an owned GetGear frame to the map canvas, applies inverse scaling and positions the marker using map coordinates.

Investigate whether the coordinate offsets are being interpreted correctly relative to the canvas and marker scale.

Do not assume the current mathematics is correct merely because synthetic tests pass.

### Historical comparison is mandatory

The owner specifically remembers ACA markers functioning properly in an older GetGear version.

Inspect the Git history and identify the most recent implementation that correctly rendered ACA vendor markers, where possible.

Compare:

- Marker parent frame.
- Coordinate positioning.
- Texture setup.
- Scaling.
- Frame layering.
- Canvas attachment.
- Visibility and lifecycle handling.

Determine what changed between the working historical implementation and the current one.

**Do not blindly revert the renderer.**

The historical implementation may lack subsequent improvements to quest context, lifecycle handling, zoom behaviour and map compatibility.

Recover the relevant working mechanism while preserving modern functionality.

### Verify the arrow asset

Inspect `MapPin.tga` and the marker's texture setup.

The package builder explicitly includes this asset, but inclusion alone does not prove that the game renders it correctly.

Check effective texture dimensions, visibility, alpha, draw layer, clipping and compatibility with the actual Forever UI.

### Improve diagnostics

Extend `/getgear navdiag` to report useful rendering information such as:

- Selected destination coordinates and bounds.
- Marker frame position and on-screen rectangle.
- Parent and anchor identity.
- Canvas position and screen rectangle.
- Effective scales.
- Texture shown/visible status.
- Texture alpha and effective alpha.
- Frame strata and frame level.
- Whether the calculated marker rectangle intersects the visible map viewport.
- Whether the label and icon are both attached and positioned.
- The reason for any failed placement.

Use read-only diagnostics.

Do not interfere with Blizzard's native waypoint system or other addons.

Avoid introducing continuous polling or expensive frame-by-frame recomputation.

### Acceptance requirement

Opening a destination with valid coordinates must visibly display the GetGear marker at the correct map position.

A successful frame `Show()` call alone must never be treated as proof of visual correctness.

If actual client rendering cannot be verified in the Codex environment, explicitly report that limitation and provide the owner with a focused acceptance procedure.

---

## 5. Problem B — Incorrect NPC destinations caused by broad coordinate bounds

### Reproduction B1: Green Silken Shoulders

Character: Level 31 Night Elf Priest.

The owner selected the acquisition marker for Green Silken Shoulders.

GetGear opened Stormwind City and displayed a marker for the recipe's Artisan Tailor, Georgio Bolero.

The owner was standing immediately beside Georgio Bolero in the Tailoring shop.

The in-game player coordinates were approximately:

`53.3, 81.4`

However, GetGear placed the marker in the western portion of Stormwind, far from the actual trainer.

### Existing GetGear source record

NPC:

`Georgio Bolero`

NPC ID:

`1346`

Map:

`Stormwind City`

UI map ID:

`1453`

Stored coordinate bounds:

```text
xMin = 43.2
xMax = 53.2
yMin = 73.4
yMax = 81.6
```

The currently displayed marker is consistent with the northwest corner of this broad rectangle:

`43.2, 73.4`

The owner's observed position beside Georgio Bolero is near the opposite corner of the stored area.

Independent published NPC references should be examined to verify the correct current Forever position.

### Confirmed source-processing mechanism

In `tools/build_acquisition_navigation.py`, the source-location generator combines multiple records within the same location grouping.

It constructs a bounding rectangle using minimum and maximum coordinates.

For nonzero-area bounds, it removes the precise `x` and `y` fields.

In `MapNavigation.lua`, when a destination has bounds rather than a precise point, the marker icon is anchored to the area's top-left corner.

Consequently, GetGear can transform several location observations into a large area and then display its corner as though it were an actionable NPC destination.

That is inappropriate for a known stationary NPC such as a city trainer.

**The coordinate information may be available in the source evidence, but its precision or meaning is being lost during reconciliation.**

### Related concern

Alexandra Bolero and other Stormwind tailoring-related NPCs also have broad stored location bounds.

Investigate analogous records throughout the catalogue instead of treating Georgio as an isolated error.

---

## 6. Required investigation — NPC coordinate reconciliation

Audit the complete acquisition-source catalogue.

The navigation-overhaul source inventory contains approximately:

- 975 total source records.
- 856 typed NPC sources.
- 101 bag-quest actors.
- 17 objects.
- One zone source.

These should all be considered for potential analogous defects.

### Distinguish location types

The data model should clearly distinguish:

**Stationary NPC**

A known vendor, trainer or quest giver with a specific supported location.

Display the best verified precise point.

**Roaming NPC**

An NPC that legitimately moves through an area.

Represent the supported route or area appropriately, with uncertainty clearly identified.

**Multiple legitimate spawn points**

Preserve separate locations or a clearly identified set of spawn areas.

**Approximate published region**

Display the region without pretending that one corner is the precise NPC position.

**Conflicting evidence**

Preserve the disagreement and confidence information until resolved.

**Coordinates from another map frame**

Do not combine them with local coordinates unless a verified conversion exists.

### Generator corrections

Review both the existing acquisition generator and the additive navigation-review system:

- `tools/build_acquisition_navigation.py`
- `tools/build_navigation_review.py`
- Relevant checkpoint evidence.
- Current `AcquisitionNavigationData.lua`.
- NPC and quest evidence overlays.

Determine why broad coordinate ranges are being created and whether their source points represent:

- Genuine NPC patrol routes.
- Old or different-version positions.
- Distinct NPC spawn points.
- Quest mapper observations.
- Coordinate extraction mistakes.
- Different map coordinate frames.
- Incorrectly merged evidence.

Do not automatically average or merge conflicting positions.

Do not simply select the last or first coordinate.

Do not treat an arbitrary bounding-box corner as a precise NPC destination.

Preserve the evidence and determine which location representation is appropriate.

### Source reliability

Prefer applicable Forever-specific client evidence, followed by exact Forever NPC/map references and independently corroborated published locations.

Cross-check source coordinates against map IDs and NPC identities.

Where usable information exists on Wowhead Forever or another reliable Forever-specific source, don't continue reporting the location as unknown merely because the original accepted dataset lacks it.

Do not invent coordinates when the available sources genuinely conflict.

### Data preservation

The `.6` navigation overhaul deliberately retained the approved acquisition evidence snapshot.

Preserve that integrity contract.

Implement corrections through the reviewed, reproducible data-generation process.

Do not silently regenerate or replace the frozen acquisition catalogue.

Any change to the accepted source snapshot must be deliberate, reviewed and justified by the repository's existing policies.

---

## 7. Systemic scope and regression requirements

The owner has an established instruction for GetGear development:

**A bug discovered on one character, item or location is evidence of a potentially add-on-wide defect.**

Every reported example is a regression fixture, not the scope of the fix.

Investigate and test analogous issues across:

- All nine classes.
- Both factions.
- All supported levels.
- Every equipment slot.
- Bags.
- Crafted equipment.
- Recipe vendors.
- Profession and class trainers.
- Quest starters and turn-in NPCs.
- Objects and world vendors.
- Dungeon and raid approaches.
- ACA sources.
- Multiple acquisition alternatives.

### Mandatory regression cases

At minimum include:

1. Stondry Darkhammer — ACA source, Redridge Mountains, missing marker.
2. Wizbang's Gunnysack — Darkshore, partial label without arrow.
3. Elite Shoulders — Wetlands, missing/obscured marker.
4. Georgio Bolero — Green Silken Shoulders, incorrect bounding-box destination.
5. Alexandra Bolero and analogous city NPC location bounds.
6. Deviate Hide Pack — marker lifecycle preservation.
7. Stockades and Excavation Site — preserve the corrected `.6` entrance definitions and map positioning.
8. Brown Leather Satchel — NPC-name-only display and correct marker positioning.

Include cases involving:

- Normal and extreme map zoom.
- Different UI scales.
- Different canvas dimensions.
- Explored and unexplored map areas.
- Native and custom map overlays.
- Map switching and reopening.
- Lazy world-map loading.
- Quest-log updates.
- User-selected source changes.
- Missing and conflicting coordinates.
- Large and small NPC-area bounds.

### Preserve existing cumulative functionality

Do not regress:

- All 29 runtime modules.
- The tracker-section divider fix.
- Slot filtering and controls.
- Marker lifecycle and selection identity corrections from `.6`.
- The full dungeon entrance research.
- NPC-name-only label formatting.
- Balanced, Priority and Advanced stat modes.
- Talent awareness.
- Faction and acquisition practicality filtering.
- Crafting material quantities.
- Recipe-learning requirements and evidence.
- Bag recommendations and quest alternatives.
- Saved settings and player progress.

---

## 8. Performance constraints

The owner has separately reproduced substantial GetGear gameplay hitching during:

- Looting.
- Levelling up.
- Quest turn-ins.

The hitching disappears when the GetGear overlay is closed.

**A separate performance investigation is planned.**

Do not expand the current task into a general gameplay-performance rewrite.

However, the navigation fixes must not introduce new performance problems.

Avoid:

- Permanent per-frame marker polling.
- Repeated full-catalogue searches during map interaction.
- Repeated creation/destruction of marker frames.
- Unnecessary source reconciliation at runtime.
- Continuous expensive map queries.
- Full overlay refreshes merely to reposition map markers.

Preserve the existing lightweight tracker resizing behaviour.

---

## 9. Deliverables

Produce the following:

### A. Root-cause report

Explain separately:

- Why markers can report `markerVisible=true` yet remain visually absent.
- Why partial labels appear in some maps.
- Whether canvas clipping, positioning, layering or the texture is responsible.
- Why stationary NPCs can receive excessively broad bounds.
- How previously available precise coordinates were lost or misinterpreted.
- What changed from the earlier working map-marker implementation.

Clearly distinguish confirmed findings from hypotheses.

### B. NPC location audit

Provide a machine-readable and human-readable report covering the acquisition-source catalogue.

Include:

- NPC/source identity.
- Source category.
- Map and zone.
- Original evidence.
- Old coordinate representation.
- Accepted corrected representation.
- Source confidence.
- Conflicts.
- Remaining unresolved records.

Quantify how many records were affected and corrected.

### C. Corrected shared renderer

Deliver a systemic rendering correction, with improved diagnostics and no per-item hardcoded visual workarounds.

### D. Corrected location processing

Deliver reproducible generator changes and targeted reviewed evidence improvements, preserving the accepted catalogue contract.

### E. Regression results

Run the entire cumulative Lua 5.1 and 5.4 regression gates, navigation audits, source-integrity checks, and extracted-package verification.

Do not use reduced catalogue coverage or removed features to make tests pass.

### F. Private testing build

Create the next uniquely identified cumulative private ZIP from the exact verified GitHub development commit.

Include:

- Full source commit SHA.
- GitHub branch and CI results.
- Package manifest.
- SHA-256 checksum.
- Complete validation receipt.
- In-game acceptance checklist.

Do not publish a public release.

---

## 10. In-game acceptance criteria

The owner must ultimately confirm:

**Redridge / ACA**

Stondry Darkhammer's marker appears visibly and remains at the correct vendor location.

**Darkshore**

Wizbang's Gunnysack displays a visible arrow and readable NPC/source label at the appropriate location.

**Wetlands**

Elite Shoulders displays a visible, correctly positioned destination marker.

**Stormwind**

Georgio Bolero is marked near the actual Tailoring shop, approximately where the owner observed him at `53.3, 81.4`, rather than the corner of the existing broad bounding box.

**General behaviour**

Markers remain correctly positioned when zooming, panning, reopening the map and changing map display states.

Quest-related markers persist during irrelevant quest-log updates but respond correctly to genuine stage changes.

The marker and its label are visibly rendered, not merely reported as shown by the API.

No loss of existing GetGear functionality or new gameplay stuttering is introduced.

If these cannot be verified in the Codex environment, do not claim in-game success. Supply focused diagnostic instructions and explicitly request owner acceptance.

---

## 11. Checkpointing, credit limits and resumption

This task may extend across Codex usage windows.

The owner authorises continued work within the normal available usage allowance.

At meaningful checkpoints:

1. Commit completed work.
2. Push the development branch to GitHub.
3. Verify the remote commit.
4. Save findings and outstanding questions.
5. Maintain a durable continuation document.
6. Identify the next action so another session can resume without restarting the investigation.

If the current session reaches its usage limit, stop cleanly and preserve progress.

**Never purchase credits, change subscriptions, use paid resets, attempt to bypass limits or authorise spending on the owner's behalf.**

If the Codex environment supports automatic continuation after the normal five-hour usage window refreshes, attempt to resume the same task when usage is available.

If automatic continuation is unsupported, leave an exact continuation handover and wait for the owner to resume the task manually.

Do not claim that background resumption has been scheduled unless the platform actually supports and has configured it.

---

## 12. Definition of done

This task is complete when:

1. The shared rendering failure has an identified and corrected root cause.
2. Known stationary NPCs no longer produce misleading corner-of-bounds markers.
3. The wider NPC acquisition dataset has been audited for analogous defects.
4. Historical working marker functionality has been investigated.
5. Current `.6` improvements remain intact.
6. All automated validation and source-integrity checks pass.
7. The updated private testing build is verifiably sourced from GitHub.
8. Remaining uncertainties and actual-client acceptance steps are documented.

**Do not consider this complete simply because the reported items receive individual fixes. The goal is to restore reliable, correctly positioned navigation markers across GetGear's entire acquisition system.**