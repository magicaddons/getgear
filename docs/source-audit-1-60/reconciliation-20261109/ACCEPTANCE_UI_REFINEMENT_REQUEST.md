# GetGear — Private Testing Feedback & UI Refinement Handover

Repository: `magicaddons/getgear`

Development branch: `work/full-acquisition-reconciliation-20261109`

Reference: `docs/source-audit-1-60/reconciliation-20261109/ACCEPTANCE_HANDOVER2.md`

## Context

Following the latest private testing build, two UI presentation issues have been identified.

Everything else tested so far appears to be working satisfactorily. This is not comprehensive acceptance of all functionality, but no additional defects have been reported in this testing round.

Both issues should be addressed through **systemic presentation improvements**, not item-specific exceptions.

GetGear's established design philosophy remains:

- Provide useful acquisition information without requiring players to alt-tab.
- Keep the compact overlay concise and readable.
- Retain detailed information in the full guide.
- Avoid redundant technical wording.
- Preserve accurate source data, uncertainty and navigation behaviour.
- Allow players to make their own equipment decisions.

---

## Issue 1 — Unnecessarily verbose world-map marker labels

### Observed behaviour

When opening acquisition navigation for Va'yn Moongaze, the map displays:

`Gear: Va'yn Moongaze (published area)`

The marker itself appears, but the label contains unnecessary wording.

### Required behaviour

Display:

**Va'yn Moongaze**

Remove the redundant `Gear:` prefix and the technical `(published area)` suffix.

### General implementation rules

Apply consistent, player-friendly naming across all GetGear map markers.

Examples:

- NPC or vendor: NPC name
- Dungeon: Dungeon name, with entrance distinction where genuinely necessary
- Quest objective: Relevant quest objective or target name
- Recipe source: Actual vendor, trainer or relevant source name
- Other locations: Clear, concise destination name

Do not expose internal categories, provenance terminology or source-confidence labels in the primary map marker text.

Avoid replacing one generic prefix with another.

### Important safeguards

- Preserve the underlying distinction between precise coordinates, approximate locations, published areas and unverified sources.
- Do not imply an exact NPC location when only an approximate area is known.
- Where uncertainty affects the player's ability to find a destination, retain a concise explanation in the detailed guide or contextual tooltip.
- Do not alter coordinates, source evidence or faction restrictions.
- Preserve the existing single-marker lifecycle, delayed rendering handling, map switching and native quest/waypoint markers.

This is primarily a **marker-label formatting change**, not a request to redesign navigation.

---

## Issue 2 — Excessive recipe-source text in compact overlay

### Observed behaviour

On a level-11 Horde Druid, the compact overlay recommends Embossed Leather Vest.

The recipe-source section displays several lines resembling:

`Recipe source: Leatherworking 35; Adele Fielder — Elwynn Forest; 3 other qualified locations (published reference; current stock/access unverified).`

For an ordinary recipe available through standard Leatherworking training, this is excessive.

The player does not need named trainers, alternative locations and research caveats cluttering the compact overlay.

### Required behaviour

For Embossed Leather Vest, display:

**Recipe: Leatherworking trainer (35)**

The important information is the profession, acquisition method and required skill.

### General implementation rules

Introduce consistent, source-aware compact recipe descriptions.

**Standard trainer recipes**

Format:

`Recipe: [Profession] trainer ([Skill])`

Example:

`Recipe: Leatherworking trainer (35)`

Do not list individual trainers or alternative trainer locations in the compact overlay when a recipe is routinely taught by standard trainers.

**Vendor recipes**

Show the relevant vendor name, with a map button where actionable location information exists.

Preserve material purchase requirements, currency, reputation, limited stock or faction restrictions when genuinely relevant.

**Dropped recipes**

Identify the actual acquisition source, such as a mob, dungeon boss or other known drop source.

Do not represent random drops as guaranteed acquisitions.

**Quest or reputation recipes**

Show the meaningful quest, faction, reputation or other prerequisite.

**Recipes with genuinely uncertain acquisition methods**

Preserve appropriate uncertainty. Do not classify a recipe as standard trainer-taught merely because one trainer is mentioned in the source records.

### Information hierarchy

**Compact overlay:** The shortest accurate acquisition instruction that helps the player understand how to obtain the recipe.

**Full guide:** Complete trainer/vendor alternatives, locations, requirements, provenance, acquisition qualifications and other details.

Avoid displaying generic research metadata such as:

- "Published reference"
- "3 other qualified locations"
- "Current stock/access unverified"

These should not appear in the compact overlay for normal, reliably trainable recipes.

For genuinely uncertain vendor stock or access, retain concise, useful qualifications.

### Important safeguards

- Do not change recipe IDs, profession requirements, required skill levels, actual acquisition methods or source records.
- Do not remove relevant faction, reputation, quest, currency or availability restrictions.
- Do not remove materials lists or materials tracking.
- Preserve existing recipe visibility and known-recipe handling.
- Do not alter the underlying acquisition navigation routes.
- Do not introduce hardcoded formatting exceptions for Embossed Leather Vest.

This is a **source-aware summarisation improvement**, not an acquisition-data rewrite.

---

## Validation and regression requirements

After implementation:

1. Confirm Va'yn Moongaze displays only its NPC name on the map, while the underlying approximate-location information remains intact.
2. Test map labels for additional vendors, quests and dungeons.
3. Confirm repeated navigation actions do not create duplicate or persistent markers.
4. Confirm Embossed Leather Vest displays the concise trainer description with the correct skill.
5. Check representative recipes across all four acquisition categories: trainer, vendor, drop and quest/reputation.
6. Verify that genuinely restricted recipes still communicate important requirements.
7. Confirm detailed acquisition data remains accessible through the full guide.
8. Check compact overlay readability, line spacing and text overflow.
9. Run existing Lua regressions, syntax checks and relevant automated validation.
10. Confirm no unrelated changes to gear eligibility, stat comparisons, item visibility, materials, catalogue membership or saved settings.

## Scope and release restrictions

Implement only these two presentation improvements and any directly necessary supporting changes.

Do not restart broad acquisition research.

Preserve the existing 7,707 item identities and 900 pending candidate holds.

Do not merge into `main`, modify Beta 8, publish a release or create a new testing package without separate authorisation.

## Deliverables

When complete, report:

1. Root cause of each issue.
2. Files and functions modified.
3. Before-and-after example text.
4. Automated validation results.
5. Any remaining limitations or client-side checks required.

**Stop after implementation, validation and reporting. Await authorisation for another private testing build.**