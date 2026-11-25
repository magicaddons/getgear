# Corrected, retained, downgraded and unresolved data

Complete per-ID lists, old/new values and evidence are machine-readable:

| Disposition | Complete list |
| --- | --- |
| 30 corrected names and 3 corrected level requirements | `contradictions.json`; generated `ResearchPolicyData.lua.itemCorrections` retains old values and exact current tooltip hashes |
| All 7,707 retained equipment records | `catalogue-revalidation.csv`; zero item deletions |
| Every source-route decision, including 360 unapproved-evidence holds | `route-evidence-decisions.json` |
| Every changed Alliance acquisition audit row with before/after alternatives | `acquisition-changes.json` |
| 317 published commerce offers, 54 skill conflicts, complete/missing IDs | `commerce-audit.json` |
| 28 retained, matching published bag capacities | `bag-revalidation.json` |
| Every recipe material outcome | `catalogue-revalidation.csv`; `materialDisagreements.json` is empty because no exact matched list disagreed |
| All raw item/model leaf claims and unresolved provenance | `fact-register.jsonl.gz` |
| Historical source URLs/fingerprints and provider classifications | `sourceInventory.json.gz`, `providerCounts.json`, `github-provenance.json` |

The three level corrections are 13400, 13402 and 18674: recorded 54, published
required 55. Full name changes include updated shoulder plurals, the current
name of item 2315, item 273044 and the differentiated 275968–275984 signets;
the JSON is authoritative and lists each exact ID rather than an inferred range.

The current NPC publications disagree with six ACA guide points; those six have
zone-only directions. Alynsia retains its matching published sample, not a live
observation. Seven other NPCs have explicit same-area coordinate conflicts:
12045, 235892, 236573, 2394, 255897, 263569 and 9553. Adele Fielder's precise
point and Shaper's Terrace's approach depend on unapproved evidence and are held.
`ResearchPolicyData.lua.coordinateConflicts` and commerce evidence retain both
values. No camp point becomes an individual vendor pin.

Ten added typed ACA alternatives are listed in `added-acquisition-routes.json`:
250507, 250510, 250512, 250515, 250516, 250517, 250522, 250527, 250529 and 250532.
`new-book-associations.json` lists 41 filled exact book associations;
`projected-legacy-routes.json` lists 42 existing source-less routes now projected
to evidenced ACA actors. Original routes remain preserved.

Quest placeholders 93165, 93459 and 94484 receive current published titles.
Unverified NPC aliases 256, 610954 and 61934 are withheld only from quest roles
already containing the positively documented equivalent object. This does not
assert those NPC IDs cannot exist. Historical actor lists are retained.

The historical 17-file snapshot and candidate holds remain byte-exact.
`FEATURE_ACCEPTANCE.json` adds three policy modules and a regression group;
it retains all previous feature groups. The navigation source-count minimum
changes from 24,520 to 22,016 because active evidence checks now respect explicit
holds and reviewed additions. Every other navigation minimum and every zero-loss
assertion remains. The old recommendation signature fixture remains in history;
the new fixture fingerprints intentionally changed source/level outputs while
retaining all workload, pooling, event and allocation assertions.

Unresolved means unresolved: 92 equipment retrievals, 32 crafting material joins,
one commerce enchantment effect contradiction, 54 conflicting skill values, six ACA and seven other NPC coordinate conflicts, and the detailed
non-commerce quest/loot/stock/teaching/build questions are not converted into
verified facts by structural tests. `change-report.json` links all categories.
