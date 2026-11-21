# General map-aware location review — cumulative .9

Development baseline: accepted private cumulative `.20261119.8`, source `3ad2ec83be36624dab99cf2200352d8032930307`, installable ZIP SHA-256 `c11910e0adb97b8abbc55da1d6efc00ff3f1f16c98e770640e1fa72d26c1be82`. Its archive payload was compared byte-for-byte with development before changes. Work is isolated on `dev/location-evidence-review-20261119`. All recovered canonical ancestors remain intact.

## Repair and scope

The review pipeline previously admitted new primary coordinates through a hardcoded six-capital table. `MapCatalog` now admits explicit zone/UI-map joins from every map in GetGear's exported map inventory. There are 52 current valid map IDs. Continent references remain valid map records but cannot silently become local NPC pins. Numeric IDs are strictly positive integers, coordinates are finite numbers within inclusive0–100, and ambiguous/unvalidated frames remain withheld. No map-coordinate conversion is invented.

`location_classification.py` performs evidence decisions offline inside the existing reproducible navigation projection. It distinguishes `verified-npc-point`, `reported-point`, `multiple-spawn-points`, `approximate-area` and `unknown`. Verification requires a traceable NPC-position observation, client build, correctly matching NPC GUID, and an explicit physical-position verification statement. A player proximity measurement, a publication, a small area or repeated copies cannot become an independently verified spawn.

For map-bound observations, the classifier measures distances with that map's world-axis extents. A 15 reference-yard navigation tolerance is a conservative, documented policy rather than a statistical error bound. Complete-link clustering prevents a chain of nearby samples from joining distant positions. Selection uses an actual supported observation, preferring explicit build-attributed point reports and then geometric representativeness. It never invents a box centre. A retained footprint wider than the tolerance cannot be replaced by a single point just because only some raw observations survive.

Untraced publications for the same NPC share one unresolved evidence family, regardless of URL/domain/hash or repetition. Only traceable collector/observation identities create separate families. Pooled historical mapper observations retain their whole source-provenance candidate set instead of falsely attaching each point to one arbitrary response. Supplemental records retain checksummed structured extracts and explicit map bindings; those checksums are not presented as hashes of unavailable full responses.

Explicit fixed-spawn identities override proximity: distinct documented spawns remain separate choices even when close or at identical map coordinates. Undocumented separated observations remain areas; samples alone cannot establish a patrol or multiple fixed spawns. Stable spawn identities pass through the existing acquisition-target API so overlapping fixed-spawn choices are not deduplicated. The marker renderer itself is unchanged.

## Audit results against .8

All 116 service-NPC area records were reviewed, with the 79 records outside the former capital review prioritised in the retained report and supplementary research.

| Cohort | Reviewed | Changed from area to reported point | Retained area |
| --- | ---: | ---: | ---: |
| Outside former capital review |79|63|16|
| Previous capital review |37|31|6|
| Total |116|94|22|

These are entity-record counts, not numbers of map pixels, observations or independently verified spawns. The comparison against all 975 .8 source geometries shows exactly 94 changed records, all within this audited cohort; every other source geometry is unchanged. The historical cumulative location audit's broader geometry-correction total uses its older frozen baseline and is not the count of changes in this milestone.

No current record is newly certified as an exact physical spawn. All 94 promoted records are credible reported navigation points, and all 116 retain uncertainty about independently verified exact positions. There was insufficient evidence to reclassify any current record as a documented distinct-spawn set; the genuine multiple-spawn path has positive/negative permanent fixtures and runtime-choice regressions.

`service-audit.json` contains every reviewed record, its .8 location, final location, priority, decision, accepted/rejected observations, provenance, evidence-family count and remaining uncertainty. `baseline-geometry.json` and permanent tests guard all unaffected .8 geometry. The other service NPCs and all remaining catalogue sources retain their geometry; this review does not assert that all vendors/trainers are stationary.

## Mivin and other point decisions

Mivin Shadowweave (`npc:256735`) now uses the reported navigation point **10.0,72.7 / Redridge Mountains, UI map 1433**. Its name remains the primary pin label. Directions explicitly state that the exact physical spawn is not independently verified. The previous x10/y72.4–72.8 bounds, original mapper samples, alternate publications, conflicting-provenance exclusion and uncertainty remain in underlying evidence.

The selected point is explicitly published by [GuildLoot](https://guildloot.de/en/forever/guide/azeroth-commerce-authority/), which attributes its vendor observations to client 1.60.1.70862, and also appears on the exact [ForeverDB NPC page](https://www.foreverdb.app/en/forever/npcs/256735/mivin-shadowweave). Those publications are not counted as two independent observations. The [Azeroth Wiki](https://azeroth.wiki/forever/map/redridge-mountains/mivin-shadowweave) point is retained, and the [Forever Guide](https://guide.wow4ever.se/en/npc/256735) position remains excluded from confidence because its confirmation presentation conflicts with its history provenance. No averaging or Mivin-only runtime condition is used.

Adele Fielder (`npc:1632`) is a second explicit-publication case: the [Forever leatherworking guide](https://www.icy-veins.com/wow-forever/leatherworking-leveling-guide/) supplies `/mappin 1429 46.4 62.2`. This supports a reported point where the historical input retained only bounds. The same general extraction, map validation and classification rules apply. No NPC identity is hardcoded in classifier logic; specific coordinates and citations belong in reviewed data records.

Most other promotions use tightly clustered, retained Forever primary mapper samples for the exact service NPC and map. They remain single-family published navigation evidence, not our own client measurements. Existing contradictory cases, large footprints, missing observations and unknown map dimensions are not automatically cleaned up for appearance.

## Geometry provenance and limits

The registry includes all 52 GetGear map IDs. Matching published Classic-frame UiMap/UiMapAssignment reference metrics exist for 48; direct current Forever table requests were unavailable (403). The source is pinned Questie commit `81dd55a3fafc5eac262eff618340b2bb2e98591f`, with retained CSV copies, row IDs, hashes and reproducible dimension calculations. `maps.json` labels these metrics as reference geometry, not measurements of the installed Forever client. No library/runtime dependency was added.

The four Forever-only map frames have no assumed dimensions. Explicit supported points and documented literal fixed-spawn sets can still be reviewed there, but distance-based clustering of differing positions is withheld. Three audited area records remain areas for that reason. Reference-yard spreads are not guaranteed error radii, and they do not certify spawn precision. Future confirmed map geometry can be added as data without reopening the old capital restriction.

## Remaining area records

| NPC | Reason retained |
| --- | --- |
| Zannok Hidepiercer (npc:12956) | Separated observations without documented fixed-spawn identities. |
| Gavin Gnarltree (npc:225) | Separated observations without documented fixed-spawn identities. |
| Vayn Moongaze (npc:254151) | Map dimensions unavailable; no assumed clustering scale. |
| Stitch Pinwizzle (npc:260570) | Map dimensions unavailable; no assumed clustering scale. |
| Winklespark (npc:265574) | Separated observations without documented fixed-spawn identities. |
| Pexmit (npc:266901) | Map dimensions unavailable; no assumed clustering scale. |
| Franklin Hamar (npc:3091) | Separated observations without documented fixed-spawn identities. |
| Bernard Brubaker (npc:3097) | Separated observations without documented fixed-spawn identities. |
| Wallace the Blind (npc:3534) | Separated observations without documented fixed-spawn identities. |
| Zixil (npc:3537) | Separated observations without documented fixed-spawn identities. |
| Lizzarik (npc:3658) | Separated observations without documented fixed-spawn identities. |
| Valdaron (npc:4189) | Separated observations without documented fixed-spawn identities. |
| Amy Davenport (npc:777) | Separated observations without documented fixed-spawn identities. |
| Pratt McGrubben (npc:7852) | Separated observations without documented fixed-spawn identities. |
| Kara Adams (npc:793) | Separated observations without documented fixed-spawn identities. |
| Antonio Perelli (npc:844) | Separated observations without documented fixed-spawn identities. |
| Alexandra Bolero (npc:1347) | Explicit unresolved published-location conflict. |
| Kuna Thunderhorn (npc:3015) | Separated observations without documented fixed-spawn identities. |
| Saenorion (npc:4225) | Separated observations without documented fixed-spawn identities. |
| Bengus Deepforge (npc:4258) | Separated observations without documented fixed-spawn identities. |
| Skolmin Goldfury (npc:5122) | Retained footprint exceeds tolerance; no supported single-point replacement. |
| Gimble Thistlefuzz (npc:5157) | Retained footprint exceeds tolerance; no supported single-point replacement. |

All reported points also retain physical-spawn uncertainty. This table lists the 22 records that still require area navigation, not the complete set of locations that need live confirmation.

## Preservation and verification

Only AcquisitionNavigation.lua changes among the 29 runtime modules: its generated evidence projection and acquisition-target metadata/explicit-spawn identity handling. MapNavigation.lua, UI.lua, Core.lua, GuideState.lua, AltInventory.lua, the map asset and all other runtime/data modules are byte-identical to .8. The accepted 17-file acquisition snapshot is exact. No recommendation, eligibility, settings schema, progress, inventory coalescing or section-resize implementation is replaced. Clustering/reconciliation performs no work during looting or dragging.

The permanent additions include 39 Python behavioral cases in the existing build-test discovery and one Lua runtime suite on each supported interpreter. They cover non-capital and Forever-only map admission, validated IDs/ranges, source URL/NPC mismatch, invalid coordinates, asymmetric map dimensions, clustering and chain separation, publication lineage/deduplication, player-versus-NPC verification, explicit close/overlapping fixed spawns, retained conflicts, missing geometry, source immutability, all 116 durable decisions, Mivin's selected point, and exact preservation of unaffected .8 geometry. The runtime suite drives generated data through map-target selection and the unchanged marker renderer, requiring visible named point/area markers and distinct spawn choices.

The .8 baseline had 167 top-level checks, 40 Lua suites per interpreter and 66 Python unittest cases. The expanded gate has 169 top-level checks, 41 Lua suites per interpreter and 105 Python unittest cases. The initial full local gate was followed by targeted final data/spawn-identity checks on both Lua versions; final exact-commit CI and the mandatory frozen-source/extracted-runtime build repeat the entire final gate. Completed source SHA, CI URL, package manifest, checksum, exact results and preservation receipts accompany the delivery outside the checkout to avoid self-referential commit hashes.

New tests initially exposed boolean map-ID acceptance and input-order audit instability; these were corrected. Further targeted cases protected documented spawn identities from both broad-footprint suppression and close/overlapping coordinate deduplication. Final receipts, not intermediate development attempts, determine delivery status. No source-tree pass substitutes for exact ZIP/source-member comparison and extracted-runtime validation.

## Focused in-game acceptance

1. Check `.20261119.9`, retained settings/progress/Advanced weights and the two slot filters after reload.
2. Open Mivin from a recipe: Redridge map, visible named point at 10.0/72.7, useful directions with reported-point qualification. Repeat clicks, close/reopen and zoom/scale checks.
3. Check Adele in Elwynn and several other promoted non-capital service records; compare the reported location with the actual NPC without treating a nearby player position as an exact NPC measurement.
4. Check Alexandra and a broad/uncertain service record: retain area rendering and uncertainty. Confirm previously accepted Stondry, bag, quest and dungeon entrance navigation.
5. Repeat the .8 looting and section-resize acceptance scenarios; `/getgear perf start` and `perf stop` remain available. Automated budgets cannot certify client frame pacing or other-addon interactions.

Actual Forever rendering, source availability and exact spawn positions remain in-game checks. No mocked test is claimed as live acceptance.
