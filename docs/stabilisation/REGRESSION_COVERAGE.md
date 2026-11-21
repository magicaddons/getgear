# Permanent stabilisation coverage

Run `tools/validate_recommendations.py --output <outside-checkout> --lua51 <lua5.1> --luac51 <luac5.1>` with Lua 5.4 on PATH. The same command runs against extracted runtime modules in the mandatory `build_test_package.py` gate. GitHub Actions runs it for development pushes and pull requests. Read `AGENTS.md` before building.

| Requested behavior | Permanent executable coverage |
| --- | --- |
| Nine classes, level ranges, valid equipment, armour transition at 40 | beta4-catalogue, beta4-filters, beta7-armor-priority, class-stat-eligibility |
| Faction/use/access distinctions, alternative sources, travel practicality | faction-global-eligibility, source-faction-eligibility, acquisition-practicality, catalogue source/faction audits |
| Talents including ambiguous distributions | beta4-talents, talent-recommendations |
| Balanced/Priority/Advanced, positive and negative deltas, empty slots, one/two-hand sets, unknown stats | recommendation-priorities, overlay-stat-filter, stat-priority-settings |
| Random world BoE versus dungeon drops and user preferences | overlay-green-boe-filter, beta7-source-visibility |
| All slot classifications and transitions; nine classes/two factions/seven levels; hidden/completed/upcoming/earlier; fresh character preferences | beta4-slot-filters (126 integrated class/faction/level scenarios plus entire catalogue classification) |
| Actual guide/tracker callbacks, totals before caps, hide/restore, preview, Bags/account browser, scroll and wrapping | beta4-slot-ui, beta7-preview-layout, overlay-wrapped-layout |
| Quest stages/chains, vendor/trainer/recipe/bag/dungeon navigation, hierarchy, coordinate transformations, repeated/open/close/zone/category changes | acquisition-navigation, acquisition-map-readiness, navigation-marker-system, map-marker-lifecycle, navigation-overhaul |
| Valid coordinates must produce a shown marker; native frame levels above artwork, pixel transforms, asset opacity | navigation-rendering-integrity, navigation-marker-system; catalogue navigation audit |
| Minimum label displacement, every edge/corner, scaling, known-point versus uncertain-region semantics | map-label-boundaries (new); navigation-location-review; Mivin retains uncertain published footprint |
| Profession/source evidence independent of skill; Helm fixture and analogous sources across professions | recipe-source-integrity (all 1,254 crafts, 104 reconciled minima, 72 source/profession combinations); recipe generator/integrity audits |
| Recipe materials, nested conversions and totals/names | beta7-evidence, beta7-material-names, material-name-resolution, beta7-acquisition-reconciled |
| Settings alphabetical order, three modes and Advanced weights, focus events, additive schema4 persistence and character isolation | stat-priority-settings, beta4-slot-filters |
| Account ledger empty/failing/unloaded snapshots, purchased personal bank tabs, faction/realm separation | account-inventory (new) |
| Real inventory event storms, latest state, visible/hidden/detail work, logout, timer-free fallback and profiling | inventory-events (new) |
| Tracker section drag heavy-call/frame budgets, outside/hidden release, stationary cursor geometry and scroll clamps | beta4-slot-ui; tracker-resize-budget (new) |
| Complete TOC startup on both Lua versions; bounded row counts and catalogue stress | full-toc-startup, beta4-performance |
| Module omission, stale runtime/source drift, loading order, unsafe ZIP members, source/remote integrity, deterministic bytes/manifest/checksum, failing extracted gate | Python tests/build and tests/release; validate_feature_acceptance; build_test_package and test_package_metadata |

Lua suites are behavioral cases, not individually counted assertions. Python unittest totals are reported separately; generated audit rows are coverage measurements, not extra passing tests. No new third-party test dependency is required.

## Actual-client boundary

Mocks model map calls, frame geometry/levels, event dispatch, timers, text metrics and saved state. They cannot establish GPU visibility, font wrapping/clipping in every locale, frame pacing, actual event timing, other-addon cost, or live loot/vendor/trainer/quest availability. Approved data uncertainty and the 17-file frozen acquisition snapshot remain intact. The in-game acceptance checklist covers those limits.
