# Alt inventory scope correction — private testing

Version: `0.14.0-private.inventory-scope.20261125.1`.
Development branch: `fix/alt-inventory-scope-20261125`.

## Baseline and isolation

Fetched current remote production `main` at
`de1037a8a20593430d1c27e123685980d6da909b` (Beta 11). Its ancestry
preserves original cumulative `b31e30e92256a00dbb3b75347d77731b52a0f06f`,
all four subsequent recovery commits through
`e61c16c1a136d3972b0af5b18821ceec1a2239f7`, and the remote historical
integration anchor `685e612896c7297b18594bd28e448a21cac22dec`.

The isolated branch additionally fast-forwards to the existing cumulative
performance/UI checkpoint `4d5fdb6e4171abf576735dcd0b48d36132da4e89` from
`dev/overlay-idle-groups-20261123`. This retains its event reductions, drag-only
resize callback and independent All/Starred/Other recommendation pages. The
inventory source is identical between production and that checkpoint. The
separate `dev/source-integrity-20261124` catalogue research branch was inspected
for separation and left untouched; its acquisition-policy changes are not
adopted. No main/integration ref, tag, release or public build is advanced.
The approved 17-file acquisition snapshot remains exact.

## Reproduction and root cause

The latest cumulative runtime still has these independently reproduced defects:

1. `Current()` writes `c.faction=faction` unconditionally. `Identity()` converts
   a temporarily missing `UnitFactionGroup` result to `"Unknown"`. A synthetic
   logout with that API unavailable therefore erases a previously valid Alliance
   faction while retaining the bags and bank. Logging into another Alliance
   character then excludes that offline inventory. The baseline regression
   explicitly fails with `transient logout API erased known faction: Unknown`.
2. Browser eligibility and material-tooltip eligibility separately compare raw
   realm/faction strings. `Moon Guard` and `MoonGuard`, or missing realm metadata
   with a sufficient `Realm:Name` identity key, are excluded even though the
   inventories are present. The mixed legacy/formatting fixture expects 35 units
   in eligible scope but the latest baseline returns only 1. A formatting change
   also makes the old writer create a second character key, separating an old
   bank from the current character's new bag record.
3. Unknown faction strings can compare equal to each other. Equality of two
   unknown values is not evidence of shared faction or transferability.

`baseline-reproduction.txt` and `baseline-logout-reproduction.txt` preserve the
actual failing baseline runs. These establish code defects in the latest build,
not the exact trigger in the user's incident. No Forever client, user
SavedVariables or runtime identity values were supplied. Timing of actual
Forever API failures and the reported characters' precise metadata remain live
verification items. No specific character/realm/faction is assumed responsible.
History shows that raw identity comparison predates the recent event/performance
changes; those changes did not introduce a new scope predicate. There was no
inventory metadata migration in the old implementation.

## Correction and compatibility

One shared identity predicate now serves browser eligibility and material
summary transfer totals. It treats character-name casing consistently and trims realm names, comparing case/spacing/hyphen/
apostrophe formatting consistently. Explicit positive integer realm IDs (numeric
or string `realmID` values) take precedence when both sides have them. A valid
`Player-<realmID>-...` GUID can supply the ID. The player identity reads
`GetRealmName`, falls back to `GetNormalizedRealmName`, then the explicit realm
returned by `UnitFullName`; the latter's empty same-realm return is not guessed.
Conflicting known IDs never match merely because text matches.

Faction comparison accepts canonical Alliance/Horde tokens case-insensitively
and the client's explicit `FACTION_ALLIANCE`/`FACTION_HORDE` labels. Unknown,
missing, unsupported or conflicting identity does not establish transferability.
Horde cases are defensive shared-rule tests, not a new supported content claim.

Initialization adds account-ledger `inventorySchemaVersion=2`, independent of
per-character settings schema 4. It recovers missing names/realm text from the
historical writer's `Realm:Name` keys, canonicalizes recognized faction evidence,
and records realm ID/GUID when available for the current character. It never
infers an offline faction from the logged-in character, race, class or realm.
Unrecognized numeric realm fields are not silently treated as realm IDs without
an explicit ID field or GUID. Explicit metadata wins over key fallback.

Equivalent formatting keys for the same character reconcile once at addon
initialization. The primary retains the newest bag and bank snapshots separately
by scan timestamp; a complete bank takes priority over partial bank evidence.
Equal timestamps choose the stable sorted primary. Counts are never added across
aliases. Original alias records remain stored with `inventoryAliasOf`, including
their alternate snapshot evidence. Browsing and summaries enumerate the primary
once. New scans reuse that primary instead of creating formatting duplicates.
Repeated initialization and serialized restart remain idempotent.

Contradictory GUIDs/factions are retained separately, marked
`inventoryIdentityConflict`, and excluded from transfer totals. An ID-less record
between conflicting known realm IDs is retained without attribution; known IDs
remain distinct. These records stay visible in Other / unknown, All, and their
individual scopes. Conflicting current identity blocks overwriting that record;
it needs evidence/review, not a guessed merge. Missing faction can be established
by logging into that character without opening its bank; prior recorded bank
contents/timestamps remain intact. An unavailable live API cannot overwrite a
previously established faction, realm ID or GUID. Missing realm APIs cannot
replace good identity with empty metadata.

No inventory table, checklist, star, preference or account database is reset.
Snapshot replacement on a successful collection is still intentional last-known
state; obsolete snapshots are not summed with newer ones.

## Scope and UI behavior

| Scope | Behavior |
| --- | --- |
| Same realm/faction | Known same realm and faction, including the current character |
| Current character | Current identity only; independent of transfer eligibility |
| Eligible alts | Known same realm/faction excluding current identity |
| Other / unknown realm/faction | Other realm/faction and unresolved identity |
| All saved characters | All primary records, explicitly for reference |
| Individual character | That primary record regardless of transfer eligibility |

Scope clicks synchronously re-filter saved tables and render rows. They do not
scan containers, rebuild snapshots, or call recommendation/material rebuilds.
An unresolved-character notice is visible even when unresolved records are
excluded by the selected scope; the tooltip explains recovery and conflicts.
Item search still handles names case-insensitively and item IDs. Bag/bank totals,
per-character locations, timestamps and partial/missing storage markers remain
separate. Reference-mode totals are not claims of tradeability.

Existing intended persistence is preserved: browser scope/search/selection are
transient presentation state and reopening starts at Same realm/faction. Scope
choices were never saved preferences; no new setting or schema reset is added.
Per-character saved slots/stars/checklists and account snapshots still persist.

## Full inventory lifecycle audit

| Path | Finding / validation |
| --- | --- |
| Bag collection | Existing event-driven collector runs independently of UI. Fixed non-backpack API failure previously allowing a partial snapshot to erase recorded bags; a failed required bag read now preserves the entire snapshot. Readable empty bags still clear old contents. |
| Bank collection | Uses purchased CharacterBankTab enums, excluding account bank. Fixed purchased tab with zero slots while loading replacing a complete bank with a partial count. Missing purchased-tab enumeration preserves an existing snapshot; a first partial scan may still be recorded and labelled. |
| Opening/closing bank | Existing delayed opening scans and close fallback remain bounded; callbacks after closure do nothing. No continuous polling is added. |
| Logout | Bags remain synchronous, cancelling obsolete queued scans. An open bank also takes a final synchronous snapshot; unavailable reads preserve the previous one. |
| Login/character switching | Current metadata is established even if container APIs are not ready. Shared account data survives character/module switches; new snapshots replace only the current character's bags. Temporary API failures preserve prior identity. |
| SavedVariables | Account ledger remains independent of per-character settings. Serialized table round-trip and module reload preserve alias metadata, storage, timestamps, schema and alternate evidence. Native client disk writes remain untested. |
| Filtering / tooltips | Shared canonical predicate replaces two inconsistent raw-string checks. Unknown/unknown never qualifies. |
| Search / aggregation | Name/ID search, storage-specific quantities and per-character locations tested. Alias snapshots are not counted twice. |
| Refresh / render | Real UI callbacks tested for immediate results across 180 scope clicks with zero container/snapshot/recommendation/material rebuild work. Existing inventory-event coalescing and UI refresh timing retained. |

Nil container-item results remain the client's representation of empty slots;
without an error/unloaded-slot signal the addon cannot distinguish an actually
empty slot from an incorrectly empty client API response. The fix preserves
read failures and known loading states, without inventing contents or polling.

## Automated coverage and performance

The cumulative gate uses every gameplay Lua suite on Lua 5.1 and 5.4, source and
packaging tests, syntax checks, catalogue/navigation audits, cumulative feature
acceptance and the frozen acquisition snapshot. New regression suites cover the
realm/faction inclusion/exclusion matrix, formatting, explicit realm IDs/GUIDs,
legacy keys, localized evidence, unavailable APIs, aliases and contradictions,
stale current faction, actual bag collection across two characters, module and
serialized restart, search/locations and UI scope clicks. The existing inventory
suite additionally covers hidden/overlay/detail collectors and bounded bursts.
See `VALIDATION.md` and the delivery's complete validation receipts for results.

Performance changes are limited to identity comparisons at read time and a
quadratic metadata reconciliation at initialization, not during gameplay scope
changes. No per-frame callback, continuous timer, new event stream or scope-driven
collection is introduced. Existing once-per-item name requests remain unchanged.
Fixed 50-character/50-item-ID browsing and 36-event inventory bursts are compared
against the byte-exported cumulative baseline on both Lua versions. Timing is a
synthetic measurement, not a prediction of native frame pacing. Live movement,
looting/gathering and rendering still require Forever verification.

## In-game checklist (pending)

1. Exit Forever; back up GetGear and its SavedVariables. Install the complete
   private ZIP into `Interface/AddOns/GetGear`, retaining saved data. Verify the
   exact private version and BUILD_INFO source identity.
2. Before visiting banks, open Alt inventory in Same realm/faction. Previously
   recorded same-realm/faction alts must appear with their original bank counts
   and scan dates. Compare known counts against the prior build in All scope.
3. Cycle Current, Eligible alts, Other / unknown, All and individual records
   repeatedly, including both factions/other realms where available. Check
   excluded records do not enter transfer totals; search by item name and ID;
   select an item and verify bags/bank, character, realm and dates.
4. For an unresolved legacy faction, log into that character, then relog without
   reopening its bank. Verify known bank data becomes eligible without a new bank
   timestamp. Keep genuinely contradictory records for review; do not reset data.
5. With both GetGear windows closed, loot/gather, move items, open the bank, move
   bank items and close it. Reopen the browser; verify bags, bank, empty storage
   and quantities. Repeat with the tracker open, and logout with the bank open.
6. Switch characters, `/reload`, exit/restart and reopen. Confirm account counts
   and per-character progress/stars/preferences survive; the browser deliberately
   reopens in its default Same realm/faction presentation scope.
7. Repeat the same movement/loot/gather route with tracker open/closed. Use the
   existing `/getgear perf start` and `/getgear perf stop` captures if needed.
   Scope changes must not cause rescans or unrelated recommendation rebuilds.
   Check immediate bank loading/partial labels on the actual Forever APIs.

No live-client acceptance or permission to publish a public release is inferred
from automated results. Source SHA, exact remote proof, private ZIP checksum and
full extracted-runtime validation are kept together in the final delivery.
