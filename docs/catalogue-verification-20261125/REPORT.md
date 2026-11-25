# GetGear catalogue verification — evidence-limited checkpoint

The catalogue is **not exhaustively verified or demonstrably complete**. This
checkpoint preserves the latest combined inventory/catalogue implementation,
adds eight supported runtime recipe identities, establishes an independent
equipment inventory and makes the remaining evidence gaps explicit. No record
is certified as comprehensively verified against the current live game.

The baseline is `c600da4fa50ab103ebbfa19f96bf1c6ade586fcf`, the completed combined
Alt Inventory/catalogue build, rather than the older production runtime alone.
Production `de1037a8a20593430d1c27e123685980d6da909b` and all five required recovery
commits are ancestors. The prior 30 name, three level and three quest-title
corrections, inventory fix, shared Alliance access policy, settings, progress,
comparison, preview and navigation functionality are preserved. The complete
previous audit manifest and approved 17-file acquisition snapshot remain exact.

## Changes implemented

Eight crafted items lacked a recipe spell ID despite exact published
name/output/profession/material-quantity matches: Copper Mace 2844, Copper Axe
2845, Copper Bracers 2853, Hillman's Cloak 3719, Heavy Woolen Cloak 4311,
Pearl-clasped Cloak 5542, Azure Silk Cloak 7053 and Novice's Practice Wand 247789.
The generated supplement fills only missing spell identities. It preserves all
ingredients, quantities, skill minima, acquisition alternatives and eligibility.
All runtime consumers receive the shared item fact; there is no item-specific UI
workaround. The machine change register retains original values and exact proofs.

All 54 commerce skill disputes concern Leatherworking. The book requirement and
exact teaching-spell inventory agree in every case; the commerce guide differs.
The runtime now identifies that preferred published requirement and retains the
conflicting guide value and live-game qualification. This resolves which
publication to prefer, **not** the current-client truth or the underlying guide
contradiction. It does not conflate learning skill, crafting skill or wearer level.

The equipment importer required an armour subtype after Back, which discarded
ordinary cloak headers. Its generic classifier now accepts the actual Back
table cell. Item names and effects containing “Back” cannot trigger it. This
corrects future classification; it does not regenerate the quarantined cache or
silently adopt the 900 historical publication-pass candidates. The active
equipment count remains 7,707, including four Back records.

## Outstanding discrepancies investigated

| Cohort | Result |
| --- | --- |
| 92 missing equipment tooltips | All retained with exact prior outcomes and independent inventory comparison. Two new full item pages returned 404; the broader collection encountered an access block. No item was removed on this basis. |
| 32 unmatched crafting joins | All 32 reconciled as publication facts: eight missing spell IDs and 24 short tooltips without output links. Full spell effects identify the exact outputs; every reagent list agrees. Teaching and availability remain separate questions. |
| 54 commerce skill disagreements | Exact book/spell agreement supports a preferred value for all 54; all guide conflicts remain registered. No live requirement is claimed. |
| Enchantment 249539 / spell 1248665 | Teaching text says six defense; nested/indexed spell evidence says nine. No numeric effect selected. |
| Coordinate disputes | Six commerce and seven other NPC conflicts remain withheld from precise pins. Existing reported points/areas remain qualified; none becomes a verified physical spawn. |
| Additional recipe minima | 96 spell-list learnedat versus baseline-effective-minimum differences, including three of the newly joined recipes, remain explicit. No blanket replacement of crafting minima with learning thresholds. |

An alternate published Manaflare set page still lists six of the unavailable
IDs as placeholders. The corresponding pattern and crafted output use distinct
identities. This supplies a reasonable obfuscation/version investigation avenue,
not permission to merge same-name records. The attributed tier-itemization
article also reports placeholder set bonuses and uncertain recipe origins after
beta vendor changes. Its reported attribution is not treated as an independently
retained Blizzard item-by-item confirmation. See `search-source-register.json`.

After the shell access block, the web lookup tool supplied the remaining full
spell pages. Their Create Item links were clicked to verify numeric output IDs;
the retained exact spell responses supply the matching reagent IDs/quantities.
`web-crafting-joins.json` records this distinct retrieval path without inventing
original response hashes. Five spell pages flag unavailable recipes. The
corresponding runtime records already qualify those exact versions as unresolved
or unavailable publications and keep normal same-name recipes separate.
Material/output agreement does not lift those qualifications.

## Completeness and source limits

Independent slot-partitioned armour/weapon lists yield 12,789 distinct equipment
references, including 3,584 references of green-or-better quality outside the
active catalogue. These include version, faction, quality, placeholder and
historical-hold questions; they are **not** 3,584 confirmed obtainable omissions.
There are 240 canonical IDs without a matching accepted independent list row.
Reconciliation runs in both directions and preserves the external variants.
An independent acquisition inventory retains 6,875 deduplicated source/offer
references, including physical recipe books. Exact-ID alternatives are compared
in both directions; an unmatched reference is not silently called live loot or
a quest reward, and name-only routes are identified as insufficient for that join.

The 156,726 reference rows include overlapping partitions and item variants.
They are neither unique items nor independent observations. Some requested
publisher facets were ignored, empty or truncated. Forty-eight extracts are
rejected rather than allowed to establish completeness. The recipe inventories
cover all six professions represented in equipment crafts; attempted secondary
profession paths were rejected when the publisher ignored their facets.

The 24 November successful tooltips, source entities, recipe evidence and bag
capacity checks are reused. New full pages and independent lists belong to the
same Wowhead evidence family. Their agreement is **partial game verification**,
not independent corroboration from multiple collectors. Official indexed
hotfixes provide freshness context, without overwriting unmeasured effects.
All prohibited sources remain excluded; no quarantined historical dataset was
downloaded or imported. Historical restricted references remain local audit
history rather than current evidence.

New collection persisted 3,432 request outcomes: 256 retrieved and 3,176 failed.
A broad HTTP 403 access block prevented most full source/quest/spell-page work.
The initial collector submitted its pending queue eagerly and did not stop soon
enough after denials. It now uses batches of six and stops after a denial-heavy
batch; a regression guards this. Failed requests are retained and never counted
as verified entities, proof of absence or independent research witnesses.
No repeated automatic retries or access-control workaround was used.

## Coverage and remaining work

All 7,707 equipment records have 38 explicit field categories: **292,866 rows**,
of which 247,695 apply to those records. There are 83,529 partially verified
publication fields (33.72% of applicable fields), 12,186 legacy/unverified fields,
151,980 missing-information fields and 45,171 not-applicable fields. Missing
publication data never means zero stats, unrestricted use or confirmed removal.

Equipment rollups are 7,615 partially verified (98.81%) and 92 legacy/unverified
(1.19%); **fully verified: 0/7,707**. The high partial-record percentage means
some supported fields exist, not that all those records are recommendation-ready.
Published material matches are **1,254/1,254 (100%)**, up from 1,222/1,254.
Source/quest field coverage adds 16,194 explicit rows. All 28 planning bags retain
their qualified identity/capacity evidence and separate field ledger. There are
7,735 distinct item IDs across equipment and bag planning; recipes overlap the
equipment domain and must not be added again to that unique-item total.

The unresolved register includes every new completeness candidate and all 7,423
prior equipment acquisition alternatives. Their states distinguish missing,
withheld, historical publication and current guide evidence. Loot, stock,
teaching, quest prerequisites, hard restrictions, set/proc mechanics, exact NPC
positions and current-build applicability still need original applicable evidence.
The 27 bag quest routes and original bag qualifications remain separate from the
7,423 equipment routes; total modeled acquisition routes remain 7,450.

`COVERAGE.md` and `coverage.json` provide denominators and class/slot/level
breakdowns. `LEDGER.md` documents all ledgers, source registers and lineage.
`CHECKPOINT.md` provides reproducible commands and the exact next evidence work.
`VALIDATION.md` distinguishes automated validation from actual-client acceptance.
The cumulative private ZIP must come from the mandatory exact-remote-source and
extracted-runtime gate. No production merge, tag or public release is authorized.
