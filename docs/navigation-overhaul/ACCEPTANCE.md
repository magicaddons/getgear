# In-game acceptance for private cumulative .6

Exit Forever, back up the current AddOns/GetGear folder outside AddOns, retain
WTF/SavedVariables, and extract the verified ZIP. Confirm version
`0.14.0-private-cumulative.20261118.6` and its BUILD_INFO source SHA. Do not overlay
files from an earlier testing package. None of the checks below was performed
in an actual Forever client by the development environment.

For a failure, run `/getgear navdiag` immediately after selection, again after
about one second and again after a map close/reopen. Record the client build,
character faction/class/level, selected source, quest state and a screenshot.
These are read-only diagnostics; GetGear does not change native waypoints.

| Reproduction | Expected behavior |
| --- | --- |
| Brown Leather Satchel on a Night Elf | Primary map label is `Ellandrieth`; service/item details remain in directions. Check Gotri, Brog Hamfist and Kreg Bilmn on applicable characters too. |
| Veteran's Chain Helm250498, Stockade source | Stormwind City map1453, native exterior entrance when valid or published50.35,66.18 reference. Compare directly against the actual portal and old41,57. Record a screenshot/map ID; do not infer physical correctness from the label. |
| Wizbang's Gunnysack2082 | Select the relevant published quest stage. Darkshore opens with a visible marker, survives an ordinary quest-log refresh, zoom and map reopen. Check native objective guidance when that quest is active. If absent, retain diagnostics to distinguish map-ID/readiness/visibility causes. |
| Deviate Hide Pack918, quest1486 | Nalpak's qualified Wailing Caverns approach remains visible beyond0.5 seconds and after opening the quest log. It is not a precise Nalpak or instance-portal position. Ordinary updates retain it; real acceptance/objective/turn-in changes clear the obsolete context. |
| Veteran's Silvered Chain Leggings250523 | Redridge10.4,74.7, primary label `Stondry Darkhammer`, visible persistent marker. Check both map-opening and later canvas visibility in diagnostics. |
| Guard's Silvered Chain Shirt250519 | Same shared Redridge vendor behavior, with independent recipe/item requirements preserved. |
| Raptorclaw Greaves | Two Excavation Site choices: published entrance47.8,56.3 and meeting-stone approach53.4,65.3 on Wetlands1437. Follow the new uphill road and compare each point to its named destination. Confirm neither marks an interior boss. |

1. Repeat map switches, different floors, zoom/pan, canvas/window resizing,
   close/reopen, first use after login, and quick replacement with a different
   destination. Check other map addons and verify the existing native waypoint
   remains unchanged. A missing marker must produce directions or an explicit
   pending-placement explanation.
2. Accept, abandon, complete objectives and turn in quests in a multi-stage bag
   route. Repeated unchanged quest-log updates must preserve the selected source;
   genuine stage changes must end its old context. Check Alliance/Horde routes,
   low/high-level characters and source alternatives without changing settings.
3. Visit all practical dungeon approaches from `entrance-audit.csv`. Record
   native entrance data and exterior map IDs. Check separate Scarlet Monastery,
   Dire Maul, Maraudon and Stratholme routes. Shared approach markers do not
   establish precise individual wing-door coordinates or key requirements.
4. For the11 definitions without accepted coordinates, retain useful directions
   and check the documented next method. Prioritize Blackmaw Hold's contradictory
   points, then announced raid approaches when current-client access permits.
   Do not treat historical client-listed raids as confirmed available content.
5. Preserve cumulative behavior: smooth tracker splitter movement, arrow-free
   independent slot controls, all stat modes/custom weights, material names and
   quantities, bag alternatives, recipe minima/uncertainty, class/talent/faction
   filtering, reload/relog settings and progress.

Report physical placement and visibility separately: a marker can render at a
wrong published point, and correct source data can still fail to render. Both
are required for final acceptance.
