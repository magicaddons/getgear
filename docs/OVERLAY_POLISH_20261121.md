# Private overlay polish .13

Base: published `v0.14.0-beta10`, full source
`efe67f9d9a75daf85545d9dda37b0c238d638010`, which preserves accepted `.12`.
The current canonical baseline remains
`685e612896c7297b18594bd28e448a21cac22dec`; the original cumulative and four
recovery commits remain ancestors. The public release and its bytes are unchanged.

## Small shared layout correction

The compact renderer inserted a 23px group label before starred and ordinary
recommendations whenever any star existed. Remove that overlay-only insertion
and its two label allocations. The recommendation count, composition/sorting,
pagination, slots and star actions are untouched. Every slot/category uses the
same rendering loop, so rows start at zero and retain only their normal 4px gap.
The detailed guide keeps its existing group labels and counts.

Move the overlay identity anchor from 34 to 32px and icon/name top from 41 to
39px using one shared constant. The top-right controls retain their original
22px click targets, 5px top inset and horizontal spacing. The identity click
region still starts 5px below the controls; icon/text alignment, full text width,
measured wrapping, body offsets and row/scroll extents follow the new anchor.
No item-specific layout, recommendation/data change, event/polling driver,
debounce, inventory refresh or computation path is introduced.

Only `UI.lua` changes among the 29 runtime modules. All other 28 modules, three
textures, protected acquisition snapshot and accepted navigation sections stay
byte-identical to the public build. SavedVariables schema is unchanged.

## Validation and handoff

The existing row geometry regression covers 360 width/font/name/state/map-action
combinations plus five pixel scales (0.64–1.5). It asserts the tightened gap,
unchanged action extents, wrapping, alignment, background/click/scroll geometry
and measured material layout. Production row tests cover nine original classes
in 16 valid race/class/faction contexts, all populated Druid slots, future stars,
large lists/page resets, narrow/wide reuse and immediate toggles. They now require
gap-free overlay rows with no group labels, unchanged recommendation counts,
retained detailed guide headings, and the real hide control plus restoration.

Run the complete integrated gate on Lua 5.1/5.4, including existing state
signatures, event/inventory, acquisition, filters, tracking, resizing and
performance budgets. Use the mandatory GitHub-verified private-package builder
after pushing `fix/overlay-polish-20261121`. Keep its manifest, checksum and full
validation receipt together; verify the final remote SHA and exact-commit CI.

This is an offline-tested private follow-up, not an automatically published
update. Actual Forever rendering, mouse feel and preferred spacing still need
the user's in-game review. No fresh in-game testing is claimed.
