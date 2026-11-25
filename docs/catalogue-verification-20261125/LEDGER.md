# Ledger schema and evidence lineage

The machine-readable audit is a collection of linked ledgers, not a single
whole-record verification flag. Every gameplay record is qualified.

| File | Coverage |
| --- | --- |
| `verification-ledger.jsonl.gz` | Every equipment ID × 38 explicit field categories, including missing fields. |
| `record-ledger.json.gz` | One rollup per equipment ID; class membership, level, slot and field-status counts. |
| `source-quest-field-ledger.jsonl.gz` | Every runtime source and quest record, with explicit unknown service/location/prerequisite fields. |
| `bag-field-ledger.jsonl.gz` | Every planning bag, including capacity and explicit unknown fields. |
| `web-crafting-joins.json` | Exact Create Item output links from 23 full spell pages, including five availability flags; hashes identify structured fact extracts, never unavailable full response bytes. |
| `crafting-reconciliation.json` | Every equipment craft's exact-output/material reconciliation. |
| `independent-equipment-inventory.json.gz` | Reverse inventory, source variants, absent IDs and preserved historical holds. |
| `independent-recipe-inventory.json.gz` | All accepted independent profession rows, including outputs outside GetGear. |
| `independent-acquisition-inventory.json.gz` | 6,875 deduplicated published source/offer references, retaining raw publisher type codes and recipe-book identities. |
| `acquisition-bidirectional-reconciliation.json.gz` | Exact-ID comparisons of every modeled route against independent source references; name-only or absent matches remain qualified. |
| `unresolved-issues.json.gz` | Candidate, route, field contradiction and evidence-access followups with attempted work and resolving evidence. |
| `change-register.json` | Every new runtime fact/preference: original, corrected, reason, provenance and scope. |
| `recipe-corrections.json` | Exact name/profession/output/material locks used by runtime generation. |
| `commerce-skill-evidence.json` | All 54 preferred values, original guide/book numbers and exact spell proofs. |
| `source-register.json.gz` | New request receipts and reused tooltip/entity sources, purposes, limitations and rationale. |
| `search-source-register.json` | Web lookup context and alternate research leads; no invented response hashes. |
| `publication-extracts.json.gz` | Structured game-fact extracts from successful pages and every request/extraction failure. |

Statuses are `partially-verified`, `legacy-or-unverified`, `contradictory`,
`missing-information` and `not-applicable`. Direct current-client verification,
reliable independent collector corroboration and confirmed current-game
incorrectness require evidence not obtained here. A publication preference is
not silently relabeled as any of those stronger states. No record rollup is
comprehensively verified. Missing/omitted effects or restrictions never become
negative facts.

For each field, `runtimeValue` and `publishedValue` are distinct. The evidence
names the actual field's publication, retrieval timestamp and response SHA-256.
Recipe/output/list joins do not borrow an unrelated item's tooltip proof.
Acquisition fields reference their full runtime model instead of duplicating
every route under every field. `evidenceScope` states the claim's boundary.
Source mapper coordinates describe publication samples, not measured NPC spawns.

Structured extracts and complete raw responses have different fingerprints.
`sha256` in an extracted publication record describes the retained original
response, not the re-serialized extract. Raw bodies and append-only receipts
remain under `/workspace/artifacts/catalogue-audit-20261125/raw`; exact extracted
game facts and response fingerprints are committed in this repository. A web
lookup's rewritten text has no fabricated full-response fingerprint. See the
search register for that weaker retrieval path. No arbitrary source JavaScript
is evaluated; only literal data is parsed.

Completed historical evidence remains in `docs/source-integrity-20261124`, with
its entire original manifest exact. Its fact/route/bag ledgers retain the prior
history and corrections. Historical labels such as independently-verified are
interpreted within their stated publication scope, not promoted to current-client
verification. The new record/field rollups use the conservative vocabulary above.

All source references, variants, categories and class memberships can overlap.
Only explicitly distinct IDs are used as unique-item denominators. Recipe
records overlap equipment; candidate records are outside runtime and never
increase its record count. Hashes prove artifact identity, not factual accuracy.
