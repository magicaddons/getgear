# Separate performance investigations

## Inventory and looting

Confirmed GetGear mechanism: Core synchronously called RefreshAll separately for player UNIT_INVENTORY_CHANGED, PLAYER_EQUIPMENT_CHANGED and BAG_UPDATE_DELAYED. Each visible tracker refresh enumerates and filters recommendations, compares stats, sorts results and rebuilds bounded row contents/materials. AltInventory separately scanned every bag for each BAG_UPDATE_DELAYED. The existing guard avoids catalogue work when both windows are hidden, but still repeated bag scans. Item-data callbacks already use a separate debounce and only accept IDs requested by GetGear; that mechanism remains intact.

The new `tests/inventory-events.lua` loads all 29 real runtime modules including Core, UI and AltInventory. It emits twelve repetitions of the three inventory events, with real catalogue/recommendation code and synthetic container/frame/timer APIs. Before and after use the same fixture on the same host, with the baseline runtime exported from Git. Lua 5.4.7 representative measurements:

| Scenario, 36 input events | .7 list enumerations | New list enumerations | .7 bag snapshots | New snapshots | .7 CPU seconds | New CPU seconds |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Tracker visible, guide closed | 36 | 1 | 12 | 1 | 1.861584 | 0.048031 |
| Both hidden | 0 | 0 | 12 | 1 | 0.000257 | 0.000060 |
| Tracker and detailed guide visible | 72 | 2 | 12 | 1 | 3.024174 | 0.093053 |

These are illustrative single-run synthetic CPU times, including full deferred work after advancing the test clock. They are not wall-clock response latency, in-game FPS, a confidence interval, or a guaranteed speedup. Operation-count budgets are the permanent deterministic regressions. Shared-host load, interpreter and garbage collection affect timings.

Correction: inventory-driven UI refreshes share a fixed 100ms deadline; bag snapshots share a 50ms deadline. Events arriving during the window update the final state without postponing that deadline. The UI flushes any newer pending bag snapshot before reading the account browser, preventing a deadline-ordering stale-state defect. Logout remains synchronous and invalidates pending scans. Without C_Timer the previous synchronous behavior remains available. Settings/progress are untouched. Other refresh reasons retain their existing behavior; hidden-window guards are preserved.

The tests also cover repeated separated bursts, an intervening late bag event, stale timer cancellation, non-player events, final logout contents, timer-free clients and profile capture. The same regression fails on the exported .7 runtime because the old event storm repeatedly rebuilds the overlay.

`/getgear perf start` enables session-only event counters and aggregates inclusive elapsed milliseconds, calls and net heap changes for RefreshAll, RefreshUI, RefreshOverlay, GetItems, GetCombinedMaterialRows, ScanBags and ScanBank. `/getgear perf stop` prints the results and restores the original methods. No sampling timer or wrapper remains while disabled. The client uses debugprofilestop where available, with GetTime as fallback. Only the enabled capture asks collectgarbage for its current count; it never forces collection. Unsupported memory inspection is guarded. Nested durations overlap; do not sum them. Net heap changes include garbage collection and instrumentation overhead and are not total bytes allocated. There is no demonstrated allocation-reduction claim.

## Tracker section resizing

This is a separate path. History confirms the older defect: before `cea9cdef9cc161959e3b3787dc0a0e025fbeb6e7`, UpdateSplitFromCursor called RefreshOverlay during movement and persisted settings on each update; content-size clamps could pull the divider away from its requested position. The accepted .7 already contains that commit's geometry-only LayoutOverlaySections and release-only persistence. Reintroducing a second resize implementation or another throttle is unsupported by current measurements.

Both baseline and current runtime execute the actual UI callbacks against wrapped objective rows and 200 material rows. Across 1,200 moving ticks: zero GetItems/comparison/material/filter calls and zero new frames. A representative baseline Lua 5.4 profile took 0.003266 seconds; the extended fixture's current run took about 0.003 seconds. The new `tracker-resize-budget.lua` adds 5,000 stationary ticks with zero geometry writes, heavy calls or frames (representative 0.002651 seconds), then verifies movement clamps stale scroll offsets and repeated/outside/hidden releases detach OnUpdate and preserve the split. No UI.lua change was needed.

## Unverified client causes and next measurements

The synthetic storm establishes duplicated GetGear work; it does not establish the actual looting event distribution or attribute the user's hitching to GetGear. ItemTree and other addons were not run here. Bank-open scans still follow existing synchronous bank behavior; this task does not claim their cost is eliminated. Isolated single events still require one real list rebuild, whose client cost must be measured before considering caching or other architectural work.

Capture comparable short looting sequences with tracker visible, tracker hidden, and guide open, first with GetGear alone and then with the normal addon set. Record event/call counts and inclusive timing, plus whether hitching occurs. Separately drag the section divider with both sections populated, try stationary holds and outside releases, and compare saved split after reopening. Capture without instrumentation as well: measurement adds overhead. If lag remains with no heavy GetGear work, use client profiling to identify layout/native UI/other-addon costs before proposing another change. Automated passes cannot close either real-client performance concern.
