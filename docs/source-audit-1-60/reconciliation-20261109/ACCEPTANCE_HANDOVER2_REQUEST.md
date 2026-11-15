# GetGear — Private Beta In-Game Acceptance Handover

**Date:** 14 November 2026  
**Repository:** `magicaddons/getgear`  
**Development branch:** `work/full-acquisition-reconciliation-20261109`  
**Scope:** Investigate, implement and validate fixes arising from 10 reported in-game issues.

## Objective

The latest private beta has undergone live testing on a level-25 Alliance Priest. Ten issues were identified involving inappropriate gear recommendations, equipment eligibility, stat comparisons and acquisition-location navigation.

These findings expose several likely systemic weaknesses. Fix the underlying logic across the complete level 1–60 catalogue and all nine classes, rather than implementing isolated item-specific workarounds.

**You are authorised to investigate, implement, test and commit these fixes on the development branch. You are NOT authorised to create a ZIP, build a release package, create a tag, publish a release, merge branches or modify `main`.**

Before modifying anything, read `AGENTS.md`, `docs/RECONCILIATION_PROGRESS.md`, the latest release gate and acceptance handover. Verify the current branch HEAD and review any intervening commits.

The private beta being tested may not exactly match the latest development HEAD. Establish the relevant code version and distinguish already-fixed issues from remaining regressions.

---

# Workstream 1 — Comprehensive class-aware equipment filtering

**Priority: Critical**

This workstream addresses Issues #1, #5, #7 and contributes to Issue #10.

## Issue #1 — Flame Gown incorrectly recommended to Priest

Item: **Flame Gown (253965)**

The item provides an offensive Fire spell-damage bonus and additional general attributes.

A Priest cannot benefit from offensive Fire spell damage, yet GetGear displays this item as an ordinary upgrade.

Previous repository inspection indicated:

- `EquipmentCache.lua` classifies the item as `mana`.
- `GeneratedStatFlags.lua` has broad spell/mana flags without sufficient spell-school specificity.
- `GearRelevance.lua` handles some physical/spell restrictions and Mage talent filtering, but not comprehensive class-specific spell-school exclusions.

Investigate whether these limitations remain in the current HEAD.

## Issue #5 — Azure Silk Pants incorrectly recommended to Priest

Item: **Azure Silk Pants (7046)**

The item has +6 Intellect and +10 Frost Damage.

Although Intellect is useful, offensive Frost damage is irrelevant to a Priest.

It should not appear as an ordinary Priest upgrade simply because it contains a positive generic attribute.

Treat this and Flame Gown as test cases for a common school-specific filtering rule.

## Issue #7 — Rogue-oriented daggers recommended to Priest

Reported examples:

- Black Venom Blade
- Meteor Shard
- Talon of Vultros

These weapons are appearing because of minor positive changes such as:

- +1 Agility
- +0.1 Weapon DPS
- +3 Fire Resistance

The Meteor Shard comparison showed substantial penalties to Spirit, Spell Damage and Spell Healing, yet the item remained recommended because of minor positive physical or defensive stats.

### Required implementation

Introduce or strengthen a central, reusable class-aware stat-relevance model.

Requirements:

1. Evaluate meaningful offensive and defensive stat categories by class.
2. Distinguish generic spell damage/healing from school-specific offensive damage.
3. Recognise spell schools that each class can actually use.
4. Exclude irrelevant school-specialised gear from default recommendations, without blindly rejecting legitimate mixed-school or generic spell-power equipment.
5. Prevent trivial melee DPS, Agility or other irrelevant gains from independently qualifying caster equipment.
6. Avoid treating small resistance increases as sufficient to recommend otherwise unsuitable equipment.
7. Preserve legitimate caster daggers, healing gear and hybrid-class equipment.
8. Handle all nine classes, including Paladin, Druid and Shaman, without assuming they have only one role.
9. Allow optional talent awareness where reliable, but do not introduce mandatory specialisation selection or rigid best-in-slot scoring.
10. Keep unfamiliar or incomplete stat evidence from causing unjustified exclusions.

**Design principle:** GetGear should recommend meaningful candidate upgrades without deciding which of several legitimate upgrades is best.

The full guide should preserve class-equippable items even when optional relevance filters hide them from the compact overlay.

The existing **Show all valid equipment** setting must continue to expose unusual/off-spec but legitimately equippable items.

### Regression tests

Test all nine classes, using representative:

- Fire, Frost, Shadow, Holy, Arcane and Nature damage gear.
- Generic Spell Damage and Spell Healing equipment.
- Caster daggers and physical DPS weapons.
- Mixed-school and hybrid-role equipment.
- Resistance-only and armour-only improvements.
- Items with positive and negative stat deltas simultaneously.

Include the exact reported items as regression fixtures.

---

# Workstream 2 — Catalogue-wide equipment eligibility and comparison audit

**Priority: Critical**

## Issue #10 — Twilight Maul incorrectly recommended to Priest

Item: **Twilight Maul**

The item is a two-handed mace.

A Priest cannot equip two-handed maces, but GetGear presented it as an upgrade, including a positive Weapon DPS comparison.

This is a fundamental equipment-eligibility failure, not merely a relevance-filtering problem.

### Required implementation

Perform a catalogue-wide audit of equipment eligibility across all nine classes.

Use the class's **potential weapon proficiencies**, not the weapon skills currently trained by the player's character.

For example:

- A Priest who has not trained Daggers should still be shown eligible daggers.
- A Priest must never be recommended two-handed maces.
- Actual class restrictions cannot be bypassed by Show all valid equipment.

Audit:

- Weapon types and subclasses.
- Shields and held-in-off-hand equipment.
- Class-specific and restricted items.
- Armour types and level-dependent armour permissions.
- Equipment slots and dual-wield restrictions.
- Generated catalogue class masks and runtime eligibility checks.

Class eligibility must be enforced before stat relevance.

Investigate whether the issue originates in source-data masks, equipment subclass mapping, the guide engine, or the overlay filtering pipeline.

Do not solve it by blacklisting Twilight Maul.

## Issue #9 — Orb of Mistmantle cannot be compared while using a staff

Item: **Orb of Mistmantle**

Current message:

> A two-handed weapon is equipped; requires a one-handed weapon.

This is technically accurate but unhelpful for an equipment-planning addon.

### Required implementation

Allow meaningful comparison of off-hand items even when the player currently has a two-handed weapon equipped.

Present two distinct concepts where applicable:

**Potential item benefits**

Show the off-hand item's actual stats, relative to an empty off-hand slot, rather than suppressing the comparison.

**Net equipment replacement**

When sufficient information is available, show the net changes from replacing the two-handed weapon with a one-handed weapon plus off-hand.

Do not assume the player owns or will equip an unspecified one-handed weapon. If a complete net comparison is unavailable, explain this briefly while still displaying the potential benefits.

Support the reverse scenario: considering a two-handed weapon while currently using a one-handed weapon plus off-hand.

Preserve the existing protections against unknown item data, incomplete cache information, incorrect empty-slot assumptions and double-counting stats.

## Issue #8 — Duplicate Fire Resistance in comparison

Meteor Shard displayed:

- +3 Fire Resistance
- +3 Fire resistance

The same attribute appears twice with different capitalisation.

Investigate stat-key aliases and normalisation in `GearCompare.lua`.

Ensure equivalent client stat keys are correctly deduplicated without adding duplicate values or accidentally discarding genuinely separate bonuses.

Test all resistance schools, armour aliases and generic spell-damage/healing aliases.

---

# Workstream 3 — Acquisition map markers and dungeon navigation

**Priority: High**

Issues #2, #4 and #6 share likely navigation/rendering weaknesses.

## Issue #2 — Flame Gown map opens but NPC marker is absent

Clicking **Open acquisition location** opens Redridge Mountains correctly.

The tooltip contains coordinates for the acquisition NPC, but no marker appears on the map.

The acquisition-location data is therefore at least partially present.

Previous inspection of `MapNavigation.lua` found that it immediately attempts to install/show the marker after opening the map. If visibility fails, the directions fallback can clear the active marker.

Investigate whether asynchronous map initialisation, canvas readiness, map-ID mismatch, marker parenting, frame levels or incompatible client APIs are responsible.

These are hypotheses, not confirmed causes.

### Required fix

A coordinate-backed destination must reliably produce a visible, correctly positioned marker once the map is ready.

Do not treat temporary invisibility during map initialisation as proof that the destination has no usable marker.

Ensure markers survive appropriate initialisation and refresh events, but are cleaned up correctly when navigating elsewhere or closing the relevant UI.

Preserve the player's native waypoint.

## Issue #4 — Shadowfang Keep entrance cannot be located

Item: **Robes of Arugal**

The acquisition button identifies Shadowfang Keep's dungeon entrance.

Clicking it instead displays:

> A precise entrance is not available from this client. No marker was guessed.

This is not satisfactory when the entrance's outdoor location is independently documented.

### Required fix

Use an ordered entrance-location strategy:

1. Valid client-provided entrance coordinates.
2. Independently verified entrance coordinates maintained within GetGear.
3. Qualified written directions only when no trustworthy position exists.

Open the appropriate outdoor zone, such as Silverpine Forest for Shadowfang Keep, and mark the entrance.

Do not invent coordinates or treat historical Classic locations as live-verified without appropriate evidence.

## Issue #6 — Blackfathom Deeps duplicate acquisition options

Item: **Gaze Dreamer Pants**

The acquisition selector displays two options:

1. Dungeon entrance: Blackfathom Deeps entrance.
2. Location: Blackfathom Deeps outer ruins, Zoram Strand.

Observed behaviour:

- The first option gives the missing-entrance warning.
- The second opens Ashenvale but provides no map marker.

Investigate the relationship between structured dungeon routes, area references and client entrance data.

### Required fix

Where multiple records describe the same practical entrance destination, consolidate them into one useful navigation choice.

Preserve genuinely distinct destinations, including outer ruins and a separate instance portal where they represent materially different locations.

Provide a visible marker for a verified entrance or published location with usable coordinates.

Avoid displaying redundant destination choices that lead nowhere.

### Dungeon-wide audit

Do not restrict these fixes to Shadowfang Keep and Blackfathom Deeps.

Audit every dungeon and raid referenced by GetGear's current catalogue.

Ensure:

- A shared instance entrance uses a consistent canonical location.
- Multiple items from the same dungeon resolve to the same appropriate entrance.
- Boss-specific acquisition labels remain informative.
- Dungeon entrances are not confused with boss positions.
- Verified coordinate data is handled separately from approximate or unverified information.
- Missing client APIs do not unnecessarily prevent navigation.
- Markers work in the actual Forever client.

Add automated fixtures for multiple destinations, map transitions, delayed canvas readiness, repeated clicks, map close/reopen and marker cleanup.

Automated simulation is not sufficient proof of actual in-game rendering. Document any remaining live-client verification requirements.

---

# Workstream 4 — Alliance vendor selection and acquisition-button coverage

**Priority: High**

## Issue #3 — Shining Gown displays Horde vendor and has no map button

Item: **Shining Gown**

The overlay lists:

- Alliance vendor: Mivin Shadowweave, Three Corners, Redridge Mountains.
- Horde vendor: Jimbek, near the Crossroads.

However, the item has **no Open acquisition location button**.

GetGear is designed as an Alliance-focused guide.

### Required implementation

1. Prefer faction-accessible Alliance vendor routes in the default overlay.
2. Do not clutter the Alliance overlay with Horde-only vendor instructions.
3. Preserve appropriate underlying research data and source provenance rather than destructively deleting Horde records.
4. If a valid Alliance vendor location is known, offer the acquisition button.
5. Multiple vendor references must not prevent navigation.
6. If multiple usable Alliance acquisition locations exist, provide a sensible selector.
7. Investigate whether source text is not being converted into structured navigable location records.
8. Avoid treating published vendor references as confirmed current inventory or stock.

Audit all vendor, trainer, recipe, quest and acquisition-object routes for similar missing map-button conditions.

**Important:** The existence of descriptive acquisition text must not be confused with proof that actionable coordinates exist. Where coordinates are absent, provide useful qualified directions and distinguish them from precise map markers.

---

# Cross-cutting design requirements

Preserve the project's established philosophy:

**GetGear provides actionable information without unnecessarily dictating player choices.**

The resulting architecture should distinguish:

1. **Can my class equip this?** — Hard eligibility rule.
2. **Can I equip or acquire this yet?** — Level, availability and acquisition requirements.
3. **Is this relevant to my class?** — Conservative default relevance filter.
4. **Does it offer a meaningful potential improvement?** — Class-aware stat comparison.
5. **Do I want to pursue it?** — Player decision.

Do not use current weapon-skill training as a class-eligibility restriction.

Do not implement a rigid universal stat-weight or best-in-slot system.

Preserve:

- Full guide catalogue coverage.
- Existing Show all valid equipment behaviour, subject to real class restrictions.
- Armour-only and positive-stat visibility settings.
- Random green BoE world-drop filtering.
- User-hidden and completed items.
- Crafting visibility and recipe knowledge.
- Material lists and totals.
- Equipment and source identities.
- Quest-chain navigation.
- All existing source-confidence qualifications.
- Existing saved settings and backwards compatibility.
- WoW Forever Lua/client compatibility.
- Performance safeguards and bounded item-cache requests.

The overlay should remain compact. Improve the underlying logic without adding excessive text, redundant buttons or complex specialisation controls.

---

# Validation and regression requirements

Perform the work in coherent, bounded implementation stages, checking for interactions between changes.

Use the repository's established non-release reconciliation and validation workflows.

Required:

1. Run relevant targeted tests before and after the fixes.
2. Add regression tests for every reported item and defect.
3. Test class eligibility across all nine classes.
4. Test class-aware stat relevance and spell-school compatibility.
5. Test one-handed/off-hand/two-handed comparison transitions.
6. Test resistance and spell-stat normalisation.
7. Test Alliance vendor selection and structured acquisition routes.
8. Test dungeon entrance mapping, selector deduplication and map-marker lifecycle.
9. Run all repository-required Lua syntax, catalogue, source, crafting, materials, UI, filtering and performance checks.
10. Run the full required non-release CI and inspect all resulting commits, including any CI-generated changes.

Check whether any current automated tests merely reproduce the incorrect existing behaviour. Update those tests to enforce the newly approved behaviour rather than preserving defects.

Do not silently alter sourced facts, equipment IDs, recipe requirements, acquisition evidence or class masks without documenting the evidence and reason.

---

# Required completion report

After implementing and validating the fixes, provide:

**1. Root cause analysis**

For each of the 10 issues, describe the actual underlying cause, including the relevant source files and functions.

**2. Changes made**

Summarise systemic improvements and any data corrections. Explain how they address other items beyond the reported examples.

**3. Testing results**

Include targeted and full-suite results, CI links, commit hashes and any unresolved failures.

**4. Remaining limitations**

Identify anything that cannot be confirmed without the actual WoW Forever client.

**5. In-game acceptance checklist**

Provide a concise, practical checklist I can perform on my level-25 Priest and, where useful, another class to confirm that all these issues are fixed.

**6. Release readiness**

Explain whether the development branch is ready for another private beta acceptance build, and identify any remaining blockers.

Do not create that build without separate authorisation.

## Execution instructions

Proceed with investigation and implementation of all four workstreams. You do not need to request approval between routine development checkpoints within this authorised scope.

Prioritise **equipment eligibility and class-aware relevance**, followed by stat comparisons, then acquisition navigation and faction filtering. Adjust the internal order if dependencies require it.

Commit and push verified changes to the existing development branch, retain detailed evidence in the project's handover documentation, and inspect the final CI result.

Do not resume the previously completed comprehensive acquisition-research programme unless a specific reported problem requires narrowly scoped additional source verification.

**Stop after implementation, validation and the completion report. No release packaging or publication.**