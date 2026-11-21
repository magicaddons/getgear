# Equipment slot filtering handover

Implemented on the working development branch. No release, tag, merge or
catalogue update is part of this change.

## Files and architecture

- `GuideState.lua`: ordered slot choices, validation, shared classification,
  non-mutating list filtering and count formatting. These are separate helpers;
  `GetItems`, eligibility and progress methods are unchanged.
- `Core.lua`: additive defaults for `overlay.slotFilter` and
  `detail.slotFilter` in the existing character SavedVariables. Schema stays 4.
  Missing/invalid selections become `all`; existing settings are preserved.
- `UI.lua`: one reusable dropdown used by both interfaces. Each refresh obtains
  the original, fully calculated view, then filters it before paging/capping and
  rendering. Preview filters its own sorted class list. Each selector refreshes
  only its own interface. Bags bypasses the detailed selector without clearing
  its saved choice; the inventory browser hides it and keeps its existing data.
- `tests/beta4-slot-filters.lua`: catalogue, visibility, metadata, state and
  persistence regressions.
- `tests/beta4-slot-ui.lua`: executes the actual UI and callbacks using stateful
  WoW frame mocks, including measured text and recorded anchors.
- `.github/workflows/test-early-crafts.yml`: runs both new regressions in the
  existing PR validation job. The release validation helper already discovers
  all top-level Lua tests; no release workflow was dispatched.
- `README.md` and this document: usage, evidence and remaining live checks.

The overlay adds a 22px selector and 6px spacing below the header. Its section
start and height budget both move by 28px. The detailed guide adds a toolbar row
and moves paging/content down by 29px. Existing measured row layouts, ingredient
expansion, map buttons and comparison rendering stay in place. Scrolling stays
at its current offset/page where valid and clamps when content becomes shorter.

## Classification

Classification uses canonical `record.slot` and `record.armorType`, including
inherited catalogue facts. It never examines item names, tooltips or source text.

| Filter | Catalogue slots / metadata |
| --- | --- |
| Head, Neck, Back, Chest, Hands, Waist, Legs, Feet | Corresponding slot |
| Shoulders, Wrists | `Shoulder`, `Wrist` |
| Rings, Trinkets | `Ring`, `Trinket`, covering both equipped positions |
| Weapons | `Main Hand`, every existing `Two-Hand` variant, confirmed off-hand weapons |
| Off Hand | `Off Hand`; compatible one-handed/off-hand weapons confirmed by inventory type |
| Ranged | `Ranged`, `Thrown`, `Wand`, `Relic` |
| Bags | `Bag`, used in the overlay and Hidden; dedicated Bags remains unchanged |

The generated taxonomy combines generic One-Hand and Main Hand as `Main Hand`.
For the overlapping hand categories only, the helper uses the existing
synchronous `C_Item.GetItemInventoryTypeByID` API, also used by GearCompare,
with `C_Item.GetItemInfoInstant` / `GetItemInfoInstant` equip-location fallback.
Inventory types 13 and 22 establish one-handed/off-hand weapon compatibility;
main-hand-only (21), shields (14), held items (23), and two-handed equipment do
not gain an incorrect extra category. Each input record is appended at most once
per filtered list, preserving identity and relative order.

When metadata is absent, errors, or is secret, canonical slots still work.
Known off-hand melee subtypes can still appear in Weapons, but an ambiguous
`Main Hand` record is not guessed to fit Off Hand. There are no tooltip scans,
item-cache load requests, catalogue annotations or changes to class eligibility.
Live metadata availability and dual-wield restrictions need client verification;
the dropdown itself never broadens eligibility for a class/character.

## Counts, caps and empty states

Totals are taken from the current view after its existing visibility rules and
before the new slot filter. Matches count the filtered list, before paging.
Normally the label is `Showing 8 of 117 recommendations`. When the existing
32-row overlay cap or 40-row detail page limits actual rendering, the label is
explicit, for example `Showing 32 of 117 (50 slot matches)`. A collapsed overlay
shows zero rendered rows while retaining the match count.

Empty selected slots say `No recommendations for this slot.` All Slots retains
the original category/faction empty messages. Returning to All Slots restores
the same underlying records and ordering, subject to normal live state changes.
Total Materials continues to use its original full scope.

## Automated verification

Validation on 2026-11-17: **all 11 Lua suites passed under Lua 5.4 and Lua 5.1**;
all 18 active modules parsed in both runtimes. **20 Python release/workflow
safety tests passed**. Lua 5.1 used Lupa's Lua 5.1 runtime and the repository's
`tools/release/lua51-harness.lua`; Lua 5.4 used the environment's shared runtime.
Test dependencies were installed in `/tmp` only. `git diff --check` passed.

Reproduce the feature checks with:

```sh
lua5.4 tests/beta4-slot-filters.lua .
lua5.4 tests/beta4-slot-ui.lua .
lua5.1 tools/release/lua51-harness.lua tests/beta4-slot-filters.lua .
lua5.1 tools/release/lua51-harness.lua tests/beta4-slot-ui.lua .
python3 -m unittest discover -s tests/release -v
```

The cumulative data test covers all 7,707 catalogue items/all target levels via
nine class indexes and levels 1,15,30,39,40,45,60 for nine classes and two faction
states (126 combinations, including the armour proficiency boundary), all
seven character views, class-specific Preview lists, 100+ item lists, canonical
slot coverage, hand overlap and metadata failure, invalid preferences, existing
schema-4 saves, simulated reload/character switching, Hide/Unhide, Skip/Undo,
unchanged material totals and unchanged catalogue/class-index tables. Filtering
requests zero item-cache loads. Inventory/equipment/talent APIs are stubbed;
the existing eligibility, relevance, source and talent regressions supplement it.

The UI test executes the actual dropdown and rendering callbacks: independent
selections, counts before caps/pages, empty-to-populated transitions, paging,
Hide/Restore and Skip/Undo, Preview class switching with read-only progress,
Bags and inventory isolation, reopen, repeated changes, scroll retention,
measured wrapped comparison/source rows, ingredient expand/collapse, map target
binding, minimized rows and collapsed sections.

No WoW client is available in this environment. The executable frame tests are
the available UI evidence; they do not reproduce Blizzard font rendering,
physical mouse capture or actual screen clamping. No in-game screenshots are
claimed.

## In-game acceptance checklist

1. Open overlay and guide with a 100+ item view. Choose different slots in each;
   switch repeatedly and return to All Slots. Check ordering, counts and empty
   messages, the 32-row cap and 40-row pages.
2. Check rings/trinkets; one-hand, main-hand-only, off-hand and two-hand weapons;
   shields/held items; wands, ranged weapons and relics on applicable classes.
3. Hide an item while filtered, change slots, reload and reopen; restore it in
   Hidden. Acquire/skip and undo in Completed/Skipped.
4. Verify independent choices after `/reload`, relogging and switching characters,
   including an existing save and a new character.
5. Check Available, Next 5 Levels, Earlier Gear, Completed/Skipped and Hidden.
   In Preview choose another class/level and verify live progress stays intact.
   Confirm dedicated Bags and Alt Inventory retain their existing behaviour.
6. At minimum and normal frame widths/scales, expand long text and ingredient
   lists, minimize rows/collapse sections, click Hide and map pins, resize/drag
   the section splitter and scroll both lists. Open menus near screen edges and
   close them with selection, the selector or Escape; check for overlap/errors.
7. Confirm aggregate materials, stat comparisons, talent/relevance and acquisition
   settings behave as before. Repeat on all nine classes at representative levels
   including 39/40. Horde should retain its existing unsupported-route behaviour;
   this feature adds no Horde routes or new recommendation modes.

No recommendation generation, weighting, ranking, equipment eligibility,
acquisition rules, inventory calculations or catalogue behaviour was intentionally
changed. Hide, completion and skip states are modified only through their existing
user actions.
