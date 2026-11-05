# GetGear v0.12.13 Beta — login freeze fix

**WoW Forever · Alliance · levels 1–30**

This release fixes the character-login hang isolated in-game to GetGear's `ITEM_DATA_LOAD_RESULT` handler.

## Changes
- Respond only to item IDs requested by GetGear, ignoring other addons' item events.
- Request each missing item ID at most once per login session, preventing repeated invalid/cache-miss requests.
- Coalesce successful item load events into deferred, rate-limited interface refreshes; no synchronous refresh recursion.
- Apply the same request guard to UI icons, gear comparisons and account inventory item names.
- Bag, equipment, profession and level changes continue refreshing normally.
- Preserves all v0.12.12 item and recommendation data, crafting additions, acquisition guidance, SavedVariables and checklist progress (234 items, 426 recommendations, 37 spec views).

## Verification
- Lua 5.4 syntax and crafting data regression checks.
- New event simulation covers duplicate requests, failed items, unrelated events, burst coalescing, requests during redraw and independent bag-event processing.
- **Live Forever client testing is still required.** The in-game diagnosis established that disabling the original event fixes the freeze, but this new guarded implementation has not yet been live-tested.

## Installation
Exit WoW. Download **GetGear-v0.12.13-private-test-beta.zip** from Assets (not the source archive), back up the previous addon folder if desired, and replace the existing `_forever_/Interface/AddOns/GetGear` folder with the new one. Do not merge the folders. Saved progress is stored separately and should remain unchanged.
