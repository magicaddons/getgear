# Regression and performance validation

The final local integrated gate passed **207 top-level checks**, all **55 gameplay
Lua suites on Lua 5.1 and Lua 5.4**, all 32 runtime modules, build/release tooling,
feature-contract checks, catalogue/source/recipe/faction/navigation audits and
the protected acquisition snapshot. Exact commands and results are retained in
`validation-checks.json` and `validation-summary.json`. Additional targeted audit
tests passed after the final web-link and numeric tooltip-field evidence was
compiled. CI and the mandatory extracted-package gate repeat the integrated
gate on the exact committed delivery; their receipts accompany the package.

Commands:

    PATH=/workspace/toolchain/lua54/usr/bin:$PATH python tools/validate_recommendations.py --output /workspace/artifacts/catalogue-audit-20261125/final-source-validation --lua51 /workspace/toolchain/lua51/usr/bin/lua5.1 --luac51 /workspace/toolchain/lua51/usr/bin/luac5.1
    python tools/reconcile_presentation_snapshot.py --verify-only
    python -m unittest discover -s tests/build -p test_catalogue_verification.py -v

The new Python regressions exercise safe literal parsing, exact recipe joins,
ambiguity/wrong-profession/wrong-material rejection, all eight persisted
corrections and 54 preferences, full equipment field-ledger coverage and
provenance, numeric damage/speed/resistance/proc parsing without invented zeroes,
the provider-denial circuit breaker, cloak header recognition and negative
name/effect cases. The new Lua suite checks actual packaged runtime recipe IDs,
unchanged materials, preferred values and qualifications, and retained coordinate
holds on both interpreters.

The retained suites cover duplicate/cross-reference/schema integrity, material
quantities, equipment/class/faction eligibility, alternate acquisition routes,
recommendations/comparisons, preview, inventory scope, saved settings/stars,
map-marker lifecycle and unavailable data. The catalogue-wide presentation
audit exercises real shared formatters for all 7,707 equipment records and
1,254 crafts with no item queries or model mutation. An initial gate detected
overlong research wording in compact commerce text; that wording was shortened,
the audit passed, and the complete gate was rerun. No audit was weakened or
exception added to hide that failure.

Performance and idle/coalescing regression results are retained in
`performance-receipt.txt`. Existing overlay, tracker resize, source-navigation,
inventory and UI-state budgets passed on both interpreters. No new per-frame
catalogue walk, polling or network request is introduced. Eight data joins are
applied once during module loading, while the 54 requirement notes use existing
formatting paths. A new live-client frame-time measurement is not claimed.

`PRESERVATION.json` verifies that exactly eight item-fact fields were added, every
other exported item fact and every class/model/eligibility projection stayed
exact, and 29 of 32 Lua modules are byte-identical to the integrated baseline.
Only RecipeKnowledge.lua, CommercePolicyData.lua and AcquisitionPolicy.lua
change among runtime modules. Inventory, UI, Core, map renderer and comparisons
remain exact. The full original audit manifest, all historical holds and the
17-file approved snapshot are preserved.

## Actual Forever acceptance still required

1. Install the complete cumulative private ZIP. Confirm its TOC version, retained
   settings/stars/progress and Alt Inventory identity/bank scope behaviour.
2. Inspect the eight repaired recipes at appropriate profession skills. Compare
   actual learned spell IDs and reagent quantities. Verify that incomplete or
   blocked acquisition information stays qualified.
3. For several of the 54 Leatherworking cases, compare the physical book and
   profession window with the preferred requirement and conflicting guide value.
   Test below/at the actual requirement without treating a printed guide as truth.
4. Inspect the five unavailable-publication recipe versions separately from
   normal same-name items. Verify actual availability before lifting any hold.
5. Verify effect 1248665 with a real enchantment receipt. Verify disputed NPC
   positions with matching GUID, build and UI-map measurements; preserve reported
   points and area navigation until those facts are established.
6. Repeat ordinary looting, map changes, section resizing, item search, comparison
   and inventory scope operations. Use the existing performance instrumentation
   for actual-client frame pacing and interaction with other addons.

Offline tests do not establish current loot, stock, teaching, prerequisites,
effect mechanics, physical NPC positions or actual-client rendering.
