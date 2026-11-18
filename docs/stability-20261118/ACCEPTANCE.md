# Private cumulative .4 — installation and in-game acceptance

1. Exit Forever. Back up the old addon folder and move it outside `Interface/AddOns`.
   Retain WTF/SavedVariables. Extract the new ZIP so `GetGear/GetGear.toc` is directly
   inside AddOns. Verify `.20261118.4` and the source revision in BUILD_INFO.txt.
2. Open the compact tracker with a large objective/material list. Choose a slot,
   expand a long title/recipe and hide/minimize an item. Drag **Resize tracker
   sections** slowly and rapidly in both directions, including with one short
   section. The splitter should track the mouse without game-wide lag. Release
   outside the grip, hide while dragging and repeat20 times. Filters, item state
   and contents must persist; reload/relog and verify the final ratio. Also test
   corner resizing of tracker/guide, scrolling, minimum dimensions and UI scale.
   For installed-client profiling, enable scriptProfile and reload if desired;
   compare GetGear CPU usage over the same10-second idle/drag intervals. Disable
   profiling and reload afterwards. Synthetic timings in REPORT.md are not FPS.
3. Keep an existing native waypoint. Open acquisition locations for equipment
   across several slots, vendor/trainer sources, a quest chain, dungeon entrance,
   crafted recipe and bags (including Hunting Satchel/Deviate Hide Pack). Wait
   at least10 seconds. Refresh the quest log, open/close the quest panel, zoom,
   pan, resize the map and switch continent/zone/floor away and back. The owned
   marker should remain/restablish only on its destination map; the native
   waypoint should be unchanged. Close/reopen, choose another destination and
   repeat; there should be one selected marker. Advance the selected quest stage
   and verify the old stage is cleared. Repeat with the usual map addons enabled.
   If it fails, record `/getgear mapstatus`, item/source, map/floor, zoom and addons.
4. In the guide inspect Veteran's Chain Helm250498. Verify Blacksmithing125,
   plans251350, the concise multi-source dungeon label and29 named enemy
   references across Stockade/Scarlet Monastery/Razorfen Kraul/Blackfathom Deeps/
   Gnomeregan. Use the dungeon choices: these are outdoor approaches, not enemy
   or boss-floor coordinates. Live loot/drop rates remain unverified. Check
   other Blacksmithing, Leatherworking and Tailoring recipes; trainer/vendor/
   quest/world or ambiguous drops and special requirements should stay distinct.
   Confirm an unresolved recipe still says unknown rather than acquiring a guessed
   skill. Overlay, guide and strict opt-in craftability must agree on known skill.
5. Both slot controls should read `Slot: All Slots`, `Slot: Head`, etc., without
   an arrow. Exercise every slot, empty results, independent guide/tracker choices,
   counts, bags, preview, Hide/Restore and persistence after reload/relog.
6. Recheck Balanced/Priority/Advanced and saved weights, talent context, faction
   alternatives, material names, account inventory and normal bag recommendations.

The separate item-looting/game-hitch investigation is outside this acceptance run.
