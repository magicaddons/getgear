# Regression, performance and private installation acceptance

The integrated gate is `tools/validate_recommendations.py` with Lua 5.1 and 5.4.
Its final complete receipt is retained beside the private installation package;
`validation-summary.json` and `validation-checks.json` record the completed local
checkpoint run: 195 checks, 32 modules and all 49 Lua suites on each of
Lua 5.1 and 5.4, with zero failures. The 17-file protected snapshot is exact.
Partial diagnostic runs are not reported as full passes.

Coverage includes all retained cumulative suites, the source-policy negative
tests, exact commerce guide reproduction, generated research-policy reproduction,
actual startup, every gameplay Lua suite on both interpreters, saved/restored
stars, class previews, slot filters, source summaries, material planning, bags,
map pins, marker geometry, all faction-valid original combinations and source
alternatives. The new service matrix covers nine class contexts, all 60 levels
and all 24 stored equipment slot labels (12,960 contexts), including positive
and negative commerce/territory/neutral/dungeon/quest cases.

The production UI matrix covers 108 class/faction/boundary-level contexts and
12,852 slot views. The navigation audit covers 7,732 equipment/bag IDs, 74,004
class/faction checks, 8,564 usable location rows and 809 simulated distinct
marker destinations. Zero usable destinations lose their navigation button;
zero item-cache requests are introduced by that audit. The 28-bag research
inventory includes planning tiers outside the navigation audit's level-30 state.

Performance gates retain ordinary-movement idle assertions, debounced rapid loot
and mining/skill events, shared guide/overlay calculation budgets, frame pooling,
slot changes, item-cache handling, immediate star refresh and GC-paused heap
growth limits. New projections are computed at addon load; runtime code adds no
network requests, timers, combat polling or catalogue-wide movement/loot scans.
Measured synthetic timing/allocation results are in the final receipt. They are
not client frame latency or proof the real overlay hitch is fixed.

## Required real-client acceptance

1. Install the delivered `.20261124.15` ZIP with the game closed, keeping the old
   addon outside AddOns and retaining SavedVariables. Confirm TOC/BUILD_INFO.
2. Open Prefect's Waistguard and representative recipes from all supported
   equipment professions. Alliance directions must select ACA vendors in
   Redridge, never the DSL sellers. Check the new 10 learning alternatives,
   a skill-conflict example and a genuinely unverified learning source.
3. Resolve the six conflicting ACA positions and verify all seven NPCs and actual inventory/currency/rank
   gates in the current client. The camp reference must not substitute for a
   vendor point. Record build, IDs, API/tooltip observations and contradictions. Six disputed
   positions must offer directions without precise pins until resolved.
4. Exercise All/Starred/Other, restored stars, slot filters, preview, custom
   priorities, compact/detail text, materials, bag alternatives and map choices.
   Explicitly Horde-only routes must stay excluded in show-all; neutral Ratchet,
   WC and shared quests must remain available. RFC must remain inaccessible.
5. Check reload/relog, cold item caches, combat, ordinary movement, repeated loot,
   gathering/skill changes, map open/close and stars. Capture remaining overlay
   hitches with the retained performance instrumentation and actual client build.

No public release, promotion or mainline merge is performed by this checkpoint.
