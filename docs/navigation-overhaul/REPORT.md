# GetGear navigation overhaul

Development branch: `dev/navigation-source-overhaul-20261118`.
Starting source: `.4`, `cea9cdef9cc161959e3b3787dc0a0e025fbeb6e7`.
Canonical remote baseline checked before development:
`integration/cumulative`, `685e612896c7297b18594bd28e448a21cac22dec`.
Both preserve recovered `e61c16c1a136d3972b0af5b18821ceec1a2239f7` and original
`b31e30e92256a00dbb3b75347d77731b52a0f06f` ancestry. The isolated branch preserves
the entire tested `.4` implementation. Main and integration are not advanced.
Private test identity: `0.14.0-private-cumulative.20261118.6`.

## Confirmed runtime mechanisms

**Entrance identity overwrote acquisition identity.** The map adapter copied
every field from an entrance record onto the selected source target. That
replaced a deterministic quest/source ID with the entrance's local ID, commonly
`main`. On a later quest-log update, the real resolver regenerated the original
source ID; revalidation could not find `main` and cleared the marker. This is a
specific confirmed mechanism for the reported Deviate Hide Pack behavior. The
adapter now preserves source identity and stores entrance identity separately,
including when native entrance coordinates replace a published reference.

**Reference choices did not prove unchanged quest stage.** A starter or turn-in
may remain among reference choices after accepting or advancing a quest. Merely
checking that the old ID exists can preserve an obsolete acquisition context.
Each generated quest target now records the selected reward/stage and whether
the character is not on the quest, active, ready for turn-in, or completed.
Revalidation preserves ordinary quest-log refreshes and clears real stage changes.
There is no continuous quest polling or recommendation recomputation on drag.
Non-dungeon source identities also include the UI map ID, so equal numerical
coordinates in different map frames cannot collapse into one destination.

The `.6` follow-up also separates identity from presentation: initial quest-cache
readiness can change `Quest start` to `Next uncompleted published stage`, and a
native objective counter can change its text without changing the destination.
Those changes now preserve the source ID and refresh native objective text in
place. Temporarily unavailable quest API data is not treated as abandonment or
loss of completion. Regressions drive those exact transitions through Core.
The tested `.5` checkpoint at `4ae9c792ea60d5d9bb5f39826c9a371a268b5eb3`
is retained in history; `.6` is the follow-up testing package.

**Native opening and placement readiness are separate.** An opening API can show
the map before its frame consumes the requested map ID. The bounded readiness
path now requests that ID once through the native frame when available, including
after lazy loading. It does not redirect subsequent browsing or add an idle
update loop. Hidden canvases are not called successfully rendered. Failed
readiness, missing coordinates, unresolved maps and stale source selections
provide written directions. `/getgear navdiag` records source/entrance identity,
map IDs, visibility, canvas geometry and scaling for actual-client diagnosis.

**Descriptive labels were treated as NPC identity.** General-goods bag vendors
and some catalogue recipe locations carry vendor/service/item prose in one label.
The shared formatter now uses explicit NPC fields, typed NPC records or a generated
join to whole canonical NPC names. Four bag vendors have explicit names; 14
catalogue descriptive labels are joined to known NPC identities. Commas and
parentheses in legitimate names survive intact. Details stay in source directions
and tooltips. Nalpak's name identifies his qualified approach without claiming
the instance portal is his exact position.

The Redridge reproductions already produce10.4,74.7 through the real resolver;
Wizbang's starter already produces Darkshore37,44. No missing-coordinate finding
is claimed for those runtime paths. Their map-opening fallback, readiness,
rendering, replacement and route-regeneration behavior now have actual-code
regressions. **The exact installed-client cause of those two missing-marker
reports remains unconfirmed until the owner runs the acceptance checklist.**
The new diagnostics distinguish an unapplied map ID, hidden/zero canvas,
visibility problem and a genuinely replaced quest context. Automated frame doubles
cannot establish that a marker was visible in the owner's Forever installation.

## Entrance and source audit

The previous dataset has32 definitions,20 with coordinates,21 entrance choices.
The review has39 definitions,28 with published coordinates and39 entrance/approach
choices. Eleven definitions retain no accepted coordinates. All records contain
findings, sources examined, disagreements, actual-client status, missing facts
and a next verification method in `entrance-audit.json` and its CSV companion.

The roster retains every existing definition and includes all nine announced
Forever dungeons: Hall of Thanes, Ruins of Lordaeron, Excavation Site: Wetlands,
City of Dalaran, The Drowned City, Krol'dok Stronghold, Alcaz Prison, Blackmaw Hold
and Shaper's Terrace. It adds missing announced raid identities and separates
Ruins/Temple of Ahn'Qiraj from the retained aggregate historical identity.
Historical client-listed raids are not represented as proven current content.
There are76 canonical/alternative-name mappings, including dungeon wings.

Stockade's old41,57 came directly from the overview, not a calculated transform.
The reviewed published client-derived record explicitly links50.35,66.18 to
Stormwind City UI map1453 and independent pages corroborate50.4,66.2. The old
coordinate and its evidence remain in the audit. Current native entrance data
still takes precedence when applicable.

The individual Excavation guide contains map-area11 pins for entrance47.8,56.3
and meeting-stone approach53.4,65.3; the overview omits both. Both become separate
choices on Wetlands map1437, including the real Raptorclaw Greaves route. The
conflicting inferred database point24.5,73.4 is withheld. This is published
reference validation, with actual portal comparison still an owner check.

Scarlet Monastery, Dire Maul and Maraudon retain distinct wing choices using a
documented shared exterior approach and written directions where exact doors
remain uncertain. A generic native portal cannot silently replace those
instruction-specific approaches. Stratholme keeps its two existing gates.
Nalpak keeps only the source-specific Wailing Caverns approach; a native dungeon
portal cannot move his source marker to a different destination.

See `SOURCES.md` and `source-inventory.json` for the provider/file inventory,
fact-specific evidence hierarchy, acceptance decisions and generator defects.
The complete frozen runtime inventory covers975 sources,716 quests and7,440
structured acquisition routes. Many geography facts remain qualified published
references; desk research is not actual-client acceptance.

## Preservation and verification

All29 runtime modules remain. The17-file approved acquisition snapshot is exact;
no loot, vendor stock, class/faction/access rule, equipment/stat identity, recipe
minimum, material quantity, candidate hold, setting or progress is removed.
The104 restored recipe minima and15 unresolved recipe requirements remain under
the existing recipe gate. The lightweight tracker splitter, slot controls,
Balanced/Priority/Advanced settings and talent awareness are unchanged.
The item-looting/game-hitching investigation stays outside this task.

`navigation-overhaul.lua` drives real Core quest events and regenerated resolver
choices, the reported item routes, NPC punctuation, native entrance upgrades,
all39 definitions/39 entrance choices/76 aliases, stage invalidation, lazy map
opening and stale selections. The full catalogue navigation audit now revalidates
each distinct rendered destination through regenerated choices. Generation tests
reject invalid numbers/maps, interior positions, conflicting verification and
unsafe NPC-name inference. The cumulative contract retains every accepted
feature and requires the new regression.

Final exact-commit local/CI/package receipts accompany delivery outside the
checkout. They identify actual counts and commands; no synthetic receipt claims
current-client rendering. `ACCEPTANCE.md` lists owner checks and
`CONTINUATION.md` preserves the unresolved work. The work is not fully accepted
in-game until those checks pass, and uncertain entrances are not described as
solved merely because automated examples pass.
