# Owner acceptance: private cumulative .7

Actual Forever rendering cannot be tested in the Codex environment. Owner
acceptance is required; automated checks do not establish visible pixels.

Exit Forever, back up the old GetGear folder outside AddOns and preserve
WTF/SavedVariables. Extract the verified ZIP into a clean GetGear folder.
Confirm version `0.14.0-private-cumulative.20261118.7` and the source SHA in
BUILD_INFO.txt matches the accompanying receipt. Keep the delivery files together.

| Selection | Expected |
| --- | --- |
| Veteran's Silvered Chain Leggings250523 and Guard's Silvered Chain Shirt250519 | Redridge1433, Stondry Darkhammer10.4,74.7. Visible opaque pin and name, including over unexplored artwork. |
| Wizbang's Gunnysack2082 | Relevant verified quest stage in Darkshore1439; starter reference37,44 when applicable. Visible pin and readable name. Active quest guidance follows genuine stage/native objective data. |
| Elite Shoulders4835, Wenna Silkbeard npc2679 | Wetlands1437,25.6,25.8; visible pin and NPC name. For Dark Iron Entrepreneur npc3180, expect a qualified small published area46.4..46.6,18.2, not a falsely precise pin. |
| Green Silken Shoulders7057, Georgio Bolero npc1346 | Stormwind City1453,53.2,81.4; compare beside the tailoring shop near reported53.3,81.4. Never the old43.2,73.4 corner. |
| Alexandra Bolero npc1347, applicable recipe choice | Small shop region x53.2,y81.4..81.6, name plus conflict qualification. Record her exact client position to resolve the remaining small published disagreement. |
| Deviate Hide Pack918 / quest1486 | Nalpak's qualified Wailing Caverns approach remains beyond0.5 seconds and ordinary quest-log refreshes. No false exact interior NPC/portal position. Genuine acceptance/objective/turn-in changes end obsolete context. |
| Brown Leather Satchel | Visible correctly positioned vendor pin; primary text only the applicable NPC (e.g. Ellandrieth), with service prose retained in directions. |
| Stockade | Stormwind1453, published50.35,66.18 or applicable native entrance. Compare actual portal. |
| Excavation Site | Wetlands1437, separate published portal47.8,56.3 and meeting-stone approach53.4,65.3; compare each named point in client. |

For the first three pin cases, test normal/minimum/maximum zoom, pan across and
away from the destination, restore the destination, resize/maximise the map,
change UI scale, switch maps and reopen. Repeat first selection after login with
lazy map loading. Test explored/unexplored artwork and with/without the usual
map overlay addons. Pins that are naturally off viewport while panned away
should not float a misleading label at its edge.

For a failure, run `/getgear navdiag` immediately, after about one second and
after close/reopen. Capture the map screenshot and complete chat output. Include
client build, map addons, faction/class/level, exact selected source and quest
state. Diagnostics are read-only; do not clear or replace native waypoints.

Interpret the output together:

- `markerLevel` should exceed `nativeTopLevel` with a native manager; record
  canvas/marker strata and levels if an icon is still covered.
- `positionErrorPixels` should be near zero for precise points. `anchor`,
  parent identities and effective scales establish the coordinate calculation.
- `markerRect`, `iconRect`, `labelRect`, `canvasRect`, `viewportRect` use screen
  pixels. Intersection false can be normal when panned away; it is a failure if
  opening a whole-zone map places the expected destination outside view.
- `iconShown`, `iconVisible`, `iconAttached`, alpha, effective alpha, dimensions,
  draw layer and texture identify missing/transparent/unattached icons. These
  flags cannot prove no other frame covers the icon.
- Bounds destinations deliberately show `areaShown=true`, an uncertainty label
  and `iconShown=false`. Their centred label is not an asserted NPC midpoint.
- `placementFailure` identifies a missing/hidden/zero canvas, wrong map or
  invalid geometry. Keep the complete selectionID even if chat wraps it.

Please confirm visible arrow/name placement for Stondry, Wizbang, Wenna and
Georgio, area behavior for Alexandra, the lifecycle examples, dungeon approaches
and saved-feature preservation. Record any new hitching with this build; a
separate gameplay-performance investigation is still planned.
