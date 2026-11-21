# Cumulative stability corrections — 18 November 2026

Authoritative starting point: `integration/cumulative`,
`685e612896c7297b18594bd28e448a21cac22dec`. The live remote head, all29 modules,
the cumulative contract, original b31e30e ancestry and four navigation commits
were checked before branching to `fix/cumulative-four-issues-20261118`.
The original recovery/scaling/readiness/instance-alias work is preserved.
The requested private build is `0.14.0-private-cumulative.20261118.4`.

This work covers the four owner-reported issues. The item-looting/game-hitching
investigation is a separate task. No main/canonical branch, tag or release is changed.

## Confirmed mechanisms and corrections

1. **Tracker section lag and inconsistent dragging.** The original splitter's
   mouse update calls `RefreshOverlay`, rebuilding candidates, slot/stat/source
   filters, comparisons, row text/measurements, materials and inventory coverage.
   It also writes the saved split while moving. Layout then clamps the requested
   ratio to current content height, making the grip resist the cursor when a list
   is short. The real UI fixture with140 recommendations, wrapped titles and200
   material rows records14,472 heavy calls over1,200 original movement ticks,
   versus zero after this change; both reuse existing frames. On this host the
   illustrative Lua5.4 timings were1.172175s versus0.004147s. These are synthetic
   CPU measurements, not game FPS or an installed-client performance claim.
   `UI.lua` now caches completed section extents and changes only viewport heights,
   anchors and necessary scroll clamps during dragging. Explicit ratios are
   independent of row count. Final settings are saved on release, outside release
   or hide; the movement handler is removed. No recommendation cache invalidation
   or idle drag loop was added. Existing overlay/detail corner resizing already
   recomputes content only on release; title dragging only saves position.

2. **Short-lived acquisition markers.** `Core.lua` unconditionally cleared the
   selected marker in the debounced0.2-second handler for every `QUEST_LOG_UPDATE`,
   `QUEST_ACCEPTED` and `QUEST_TURNED_IN`. Opening/refreshing the map can produce
   quest-log updates; these events do not end a vendor/drop/craft context. Driving
   the real Core callback reproduces the erroneous deletion. This is a confirmed
   code mechanism consistent with the reported delay, not proof of which events
   occurred in the owner's installed client. No native waypoint/pin-pool deletion
   was found: the marker is a GetGear-owned canvas child.
   The handler now revalidates only a quest marker whose selected stage/choice
   actually changed. Other acquisition contexts survive ordinary quest updates.
   `MapNavigation.lua` observes native map-ID, canvas scale/size, data-provider
   refresh, show/hide and addon-load events with guarded, once-only hooks. Zoom
   compensation, outdoor approaches, source choices and diagnostics remain.
   The independent driver is used only for bounded first-open readiness (at most
   three seconds); it has no recurring update after rendering or timeout. Later
   real events can recover readiness. Close hides the marker and reopening its
   map restores the selected destination, preserving accepted cumulative behavior.
   Replacement, explicit clear, world/session reset and changed quest stages end
   the old context. No marker recreation timer or native waypoint write is used.

3. **Recipe requirements and source integrity.** The frozen catalogue omitted
   an exact plans link for Veteran's Chain Helm250498/spell1252247. Its independent
   requirements record contained only the profession, so both formatters fell
   back to unknown. Separately, `recipeLearnMethod='multiple'` was interpreted as
   disputed teaching, and secondary profession/craftability paths read only the
   older raw requirement field. These are distinct information-loss mechanisms.
   `AcquisitionNavigation.lua` now exposes normalized crafting/learning minima,
   per-source classifications/confidence and independent skill confidence. Multiple
   methods alone are not a dispute; explicit disputed evidence remains qualified.
   `RecipeKnowledge.lua` contains a generated, additive supplement, projected after
   the frozen navigation module loads. All original routes and equipment/material
   identities remain. `Materials.lua` and `CraftingVisibility.lua` use the same
   requirement accessor; strict opt-in craftability still requires a learned recipe.
   Supported professions include Alchemy, Cooking and First Aid where applicable.

   All1,254 catalogue crafts were audited:457 Leatherworking,399 Blacksmithing,
   327 Tailoring,37 Enchanting,33 Engineering and one Alchemy. All1,135 previously
   known minima and every original route are preserved;104 additional exact
   spell/output/name/profession joins restore missing minima (51 Leatherworking,
   31 Blacksmithing,19 Tailoring,three Enchanting), leaving15 unresolved.
   Cooking/First Aid have no equipment recipes in this catalogue; synthetic tests
   cover those professions too. The evidence includes117 exact spell pages and51
   book pages. Thirteen spell joins lack an acceptable unique numeric/current
   match; two original crafts have no spell ID. They remain explicitly unknown.
   No difficulty color, NPC elite rank, source count or Classic loot table becomes
   a skill minimum, boss/trash classification or current-live guarantee.

   The referenced [plans251350](https://www.wowhead.com/forever/item=251350/plans-veterans-chain-helm)
   page explicitly teaches spell1252247/output250498, requires Blacksmithing 125
   and lists29 enemies in five dungeon areas. Matching source geography comes
   from accepted evidence plus exact Ramtusk/Ambassador mapper/description joins.
   The overlay says `Recipe: Dungeon drop (multiple sources) (Blacksmithing 125)`
   with a live-loot caveat; the published list may be non-exhaustive; the guide retains individual enemies and the shared
   entrance navigation. No boss/trash roles or percentages were inferred. Broad
   unclassified drop lists stay generic; large lists retain their full evidence
   and citation without dumping hundreds of unknown-location lines into a row.
   Vendor stock/costs, explicit opposing reactions, learning restrictions and
   existing offers are retained. Missing acquisition geography never erases skill.

   `docs/recipe-audit` retains page fingerprints/extracted tables, selected facts,
   baseline routes and unresolved joins. `tools/build_recipe_evidence.py --check`
   validates the generated supplement against exact primary joins; the full gate
   also emits a1,254-row recipe audit. A zone717 HTTP403 was recorded without
   retry; accepted source geography established that map identity instead.

4. **Slot arrow.** Both initial rendering and update rendering in the shared slot
   selector omit the trailing `v`. Dropdown behavior, slot names, alignment,
   independent preferences and all existing filters remain. Real UI regressions
   exercise selection, labels, reload/reopen, hide/restore, preview and bags.

The updated derived source audit changes58 source-count rows and104 category/route
rows; all Alliance/Horde eligible-class and independent-access results are unchanged.
The exact delta is in `derived-source-audit-delta.json`. Learning-header parsing is
scoped before the book Use text so embedded wearer levels/reagent lists cannot
become learning restrictions. The detailed description uses the same documented
summary instead of retaining a superseded unknown-source heading.

## Validation and preserved scope

Use `tools/validate_recommendations.py` with Lua5.1/5.4. It includes the cumulative
feature/build/source-integrity tests, all gameplay Lua suites, full catalogue,
class/faction/stat/slot/talent/material/bag/preview checks, navigation/presentation
coverage audits, recipe supplement generation/consistency and release safety tests.
The new lifecycle test drives the real Core event path and native method hooks;
the splitter test counts actual heavy calls, allocations and persistence timing.

The original17-file acquisition snapshot,7,707 equipment IDs,36,669 class
objectives,900 candidate holds, account/character preferences, inventory browsing,
stat modes and source qualifications remain protected. Two new feature-contract
entries protect recipe normalization and cheap section resizing. Reviewed navigation
hashes advance to these authorized implementations; coverage minima are retained.

Full exact-commit local/CI/package receipts and remaining actual-client checks are
reported with the delivered branch/commit and private ZIP. All generated receipts
and artifacts stay outside the source tree. The mandatory builder freezes committed
source and validates the extracted29-module runtime, exact remote HEAD, canonical
ancestry, metadata and hashes before exposing a delivery directory.

Actual Forever rendering, third-party map-addon interaction and gameplay drag
smoothness remain in-game acceptance. No automated result is described as that test.
