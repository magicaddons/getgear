# Navigation rendering and NPC location integrity

Continuation of `bee893e7c3f285afc23b90731422f14ae34ae3e1` (private `.6`).
Isolated branch: `dev/navigation-renderer-integrity-20261118`.
Canonical head verified at start: `685e612896c7297b18594bd28e448a21cac22dec`.
Original `b31e30e92256a00dbb3b75347d77731b52a0f06f` and all four recovered
successors through `e61c16c1a136d3972b0af5b18821ceec1a2239f7` remain ancestors.
The new private testing identity is `0.14.0-private-cumulative.20261118.7`.
Exact final GitHub/CI/package receipts accompany the delivery outside the checkout.

## Rendering findings

**Confirmed shared defect: frame levels.** `.6` sets the owned frame to
`canvas:GetFrameLevel()+100`. Blizzard's MapCanvas manager starts native pins
at absolute level 2000; the world map adds exploration at 2001 and fog above it.
Exploration uses a frame with its own ARTWORK textures, not a texture on Child.
A texture's OVERLAY layer only orders it within its own frame: it cannot defeat
a higher sibling frame. `IsShown()` and `IsVisible()` do not measure occlusion.
A low frame can have a correct anchor, nonzero alpha, visible parents and correct
scale while exploration/map artwork covers its icon. A label extending beyond
an opaque overlay can remain partly visible. The native-level geometry model
reproduces the failed ordering; source excerpts and immutable reference links
are in `research/framexml.json`.

The shared correction uses the current map's pin-level manager's TOPMOST level
plus one. A guarded compatibility fallback uses an absolute level 2100. It retains
the canvas parent and the canvas's strata, rather than raising the marker above
all UI. Normal native/registered custom overlays, map redraws, canvas changes,
resize, zoom/pan and UI-scale events reapply owned placement. No native frame,
pin pool, waypoint or other addon setting is changed. Arbitrary other addons
that deliberately draw above the native pin manager remain an actual-client
coexistence check; no universal ordering against unknown UI is claimed.

**The scale mathematics is correct.** Native `MapCanvasMixin:ApplyPinPosition`
parents pins to `GetCanvas()` (ScrollContainer.Child), uses inverse pin scaling
and divides coordinate offsets by the pin scale. The `.6` formula matches that
mechanism. Keep it. Regressions now compute physical screen rectangles using
nested effective scales and check the destination against the marker's physical
centre across 60 reported-route/zoom/UI-scale combinations, including the owner's
1200.0000610352 x 668 canvas and 0.6956087215218 scale.

**Clipping is separate from logical visibility.** The viewport differs from the
full, zoomed/panned canvas. Diagnostic rectangles now use effective scales to
compare physical pixels. Off-viewport pins stay off viewport; labels do not float
at the edge pretending that their destination is visible. When the marker itself
intersects the viewport, its name/area qualification is kept inside the viewport.
There is no hardcoded Redridge/Darkshore/Wetlands visual workaround.

**Asset inspection.** MapPin.tga is unchanged from its original repository asset:
64 x 64, uncompressed true-colour RGBA, 32 bits per pixel, 8 alpha bits, with
transparent and fully opaque pixels and substantial nontransparent content.
Its rendered PNG was visually inspected. Texture setup has an explicit owned
OVERLAY region, full icon anchors, opaque alpha/white vertex tint and a readable
shadowed label. Package validation retains the exact source asset. Header/pixel
and file-inclusion checks cannot prove the installed client's decoder/GPU output.
No missing/corrupt-asset finding was demonstrated.

**Historical comparison.** The old runtime on `main` (`4ba2a850c4e3933b85f40c82a50b98314f117d80`)
used `C_Map.SetUserWaypoint`/UiMapPoint and let the native renderer draw the pin.
That can explain the owner's memory of an earlier visible ACA marker, but no
historical build has been replayed in a client here, so there is no independently
verified "last working" version. `4c7f3d6` introduced the shared owned-canvas marker
at Child+20; `d4c868a`/`b264a3e` used Child+100; `b40a8f6` added the correct inverse
scaling; subsequent `.6` work improved readiness/identity/lifecycle while retaining
that low frame level. Recover native layering through the manager, while keeping
owned-marker lifecycle and the player's waypoint untouched. No renderer rollback.

**Actual-client distinction.** The layering mechanism is established from code
and the native UI reference. It is a strong explanation for both absent icons
and partial labels. The exact installed Forever frame levels, exploration state,
clipping and rendered pixels cannot be measured in this environment. Those
specific observed failures are not declared accepted until the owner runs
`ACCEPTANCE.md`. A successful Show(), API visible flag, or automated model is
never presented as pixel-level acceptance.

## Coordinate findings and full catalogue audit

The baseline has 975 sources and 1010 location records: 856 typed NPCs,
17 objects, one zone and 101 bag-quest actors. There are 662 nonzero bounds
records across 621 sources. Every source appears in `location-audit.json`,
`location-audit.csv` and `LOCATION_AUDIT.md`, including records with no coordinates.
Each row retains identity/category, original evidence/fingerprints, old geometry,
raw observations where retained by the original research, accepted geometry,
confidence, conflicts, unresolved state and next verification action.

**Confirmed shared defect: evidence union loses meaning.**
`Evidence.location` converted multiple mapper observations into extrema, losing
the points. `build()` then unioned separate same-frame observations again,
removed precise x/y for any nonzero rectangle, and retained no distinction
between patrol, multiple spawns, stationary service or conflicting versions.
The renderer drew a precise-looking icon at xMin/yMin. Thus Georgio's old
43.2..53.2 / 73.4..81.6 became a misleading destination at 43.2,73.4. That
corner is evidence geometry, not a supported NPC position.

The generator now retains all mapper observations, preserves separate geometries
and explicit UI map frames, and labels unresolved alternatives as conflicting
rather than unioning them or accepting a quest mapper sample as precise truth.
Explicit roaming/spawn representations remain distinct. No route or midpoint is
inferred from rectangle size. A single published mapper footprint can remain an
approximate region, with the underlying observations available for review.
Coordinates from an unresolved continent/map frame remain withheld.

The approved 17-file acquisition snapshot is **unchanged**. Corrections use the
separate reproducible `build_navigation_review.py` projection inside the existing
AcquisitionNavigation module. The generator exports a baseline with its own
projection removed, so generation is idempotent and cannot gradually overwrite
its original audit evidence. It does no network access or runtime reconciliation.

**Fresh city review.** Retrieved all 70 exact NPC identities represented across
six capital cities, checking full NPC identity, explicit UI map ID and mapper
geometry. These published references are retained with full-response SHA-256,
byte counts and extracted mapper points in `research/city-locations.json`.
28 sources have accepted geometry corrections, including vendors, profession and
class trainers and quest actors across both factions. Many other references
confirm the existing geometry. These are exact Forever publications, not our
own live observations. Current exact primary records take precedence over older
combined excerpts; the older disagreements remain in the audit, not averaged.

Georgio is a stationary precise point at **53.2,81.4 / map1453**, supported by the
current exact primary mapper, an independent published trainer reference, and
the owner's reported approximate player position beside him (53.3,81.4).
Alexandra's current primary mapper supports only x53.2,y81.4..81.6; secondary
references differ slightly, including an explicitly Classic-qualified result.
Her old cross-city box is replaced by the primary shop region and an explicit
conflict qualification. No unsupported exact point is selected. Lucan Cordell,
Field Marshal Stonebridge and Simon Tanner also gain published single-point
representations. Other changed city services gain their supported small regions.
Windsor's different observations are not collapsed into a stationary point.

**Limits quantified.** 809 sources retain some uncertainty (region/spawn/motion,
missing coordinates or unresolved map frame). That count includes ordinary
published mob areas and compact NPC regions, not 809 newly discovered wrong NPCs.
The full audit is a structural/evidence review of all 975 sources plus fresh
primary checks of 70 capital identities; it is not a claim that every location
was independently revisited online or physically verified. We do not erase valid
published coordinates because an older snapshot lacked them. Unresolved points
have explicit next actions instead of invented positions. Unknown motion,
old-version contamination, extraction errors and genuine spawn distributions
cannot all be distinguished from the retained historical mapper data alone.

All nonzero bounds now render as a shaded area with a centred NPC/source name
and separate uncertainty text. No bounds corner or calculated midpoint becomes
an NPC destination. Source choices remain separate. Directions retain provenance,
source requirements and uncertainty. NPC-name-only primary labels stay intact.

## Regression scope and preservation

Mandatory actual-code fixtures include Stondry (250523/250519), Wizbang2082,
Elite Shoulders4835/Wenna Silkbeard npc2679 (25.6,25.8, Wetlands1437), Georgio /
Green Silken Shoulders7057, Alexandra, Deviate Hide Pack918, Stockade, both
Excavation approaches and Brown Leather Satchel. Elite Shoulders also has
Dark Iron Entrepreneur npc3180 at published area x46.4..46.6,y18.2; that route
retains area semantics. Its precise motion/current presence remain uncertain.

The new renderer regression checks native exploration/registered custom levels,
small area qualification, screen coordinates, alpha, parent/anchor attachment,
offscreen viewport diagnostics, scaling and invalid canvas reasons. Existing
catalogue audits retain all classes, factions, levels, slots, source categories,
multiple alternatives and full coverage floors. Existing real Core event tests
retain .6's source/entrance identity distinction, quest-cache/objective wording
updates, irrelevant quest refresh persistence and genuine quest-stage invalidation.
Lazy loading, canvas replacement, resize, reopen and bounded readiness remain.

All 29 runtime modules, all 39 dungeon definitions/39 approaches/76 aliases,
tracker splitter, slot controls, Balanced/Priority/Advanced, talent/faction/access
rules, materials, recipe requirements, bag alternatives, settings and progress
remain. There is one reused owned marker, bounded three-second first-open
readiness, and event-driven later updates. No idle per-frame polling, catalogue
search for placement, full overlay refresh for pan/zoom or general gameplay
performance rewrite is added. The separate looting/level-up hitch investigation
remains outstanding.

See the exact-commit delivery receipts for the completed Lua 5.1/5.4, source,
navigation, recipe, build-tool, frozen-snapshot, CI and extracted-package gates.
`CONTINUATION.md` and `ACCEPTANCE.md` preserve actual-client next steps.
