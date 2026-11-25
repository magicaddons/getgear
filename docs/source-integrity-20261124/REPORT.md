# GetGear source integrity and Alliance acquisition reaudit

Private cumulative checkpoint `0.14.0-private-cumulative.20261124.15`, based on
remote production `de1037a8a20593430d1c27e123685980d6da909b` (Beta 11).
Branch: `dev/source-integrity-20261124`. No mainline merge, tag or public release
is authorized. Installation requires the owner's in-game acceptance testing.

## Outcome and evidence boundary

The complete equipment catalogue was inventoried and every equipment ID was
submitted to a fresh approved Forever tooltip lookup. That is **not complete
verification of every catalogue fact**. No current Forever client was available.
No record is claimed independently verified in its entirety.

* 7,707 equipment IDs, nine class catalogues and all 24 stored slot labels.
* 7,615 usable equipment responses; 92 failed/missing responses remain unresolved.
* 30 names and three required levels corrected against current published tooltips.
  Class objectives also receive the raised levels; copied target levels cannot
  retain the old requirement. These are publication-based corrections.
* 1,246 distinct recorded crafting spell tooltips retrieved. Exact output and
  reagent-ID/quantity joins match 1,222 of 1,254 crafting records, with zero
  disagreements among those matched. The remaining 32 are not called verified.
* 28 bag identities/capacities researched; all 28 recorded capacities match the
  published tooltip. Stock, teaching, quest availability and prerequisites remain
  separate unresolved claims unless specifically evidenced elsewhere.
* 317 ACA guide offers, seven individually identified vendors and seven professions
  inspected. There are 54 guide/book learning-skill disagreements, explicitly
  shown as disputed. 290 offers expose a teaching spell and physical output; the other 27 are
  21 non-item enchantments and six title certifications. They do not require a
  physical output item. One enchantment tooltip contradicts its own effect value.
* 10 exact ACA book/spell/output learning alternatives added, 41 missing book
  associations filled and 42 source-less legacy routes projected onto evidenced
  ACA identities. All preexisting
  routes remain in the frozen records. The active currency-aware service policy
  evaluates 414 commerce routes, including both historical factions' sellers.
* 1,653 unique NPC/object/quest entities researched in 1,656 requests (three
  repeated namespace checks are not independent evidence): 907 NPC, 27 object
  and 716 quest responses succeeded; three NPC aliases lack responses. Three
  quest placeholders corrected; redundant unverified NPC aliases are withheld
  only where a positively identified object already fills the same quest role.
* Six ACA coordinate conflicts and seven other NPC coordinate conflicts have
  zone-only directions. An unapproved trainer point and entrance approach also
  lose unsupported precision; source records are preserved.
* 170 recorded dungeon enemy/item joins independently checked against the exact
  named loot tab of current approved Forever guides. This verifies publication,
  not server-side loot. 360 routes dependent on unapproved evidence are withheld
  from actionable Alliance acquisition; original records remain available for audit.

Published Wowhead tooltips and Wowhead guides are **one provider**, including
derivatives originally obtained through a GitHub cache. Fresh retrieval is not
an independent player observation, and matching pages are not independent
corroboration. Endpoint version, retrieval time, response fingerprints and exact
entity IDs are retained; the underlying collection build is often unknown.

## Reports and complete lists

* [Historical provenance/dependencies](PROVENANCE.md)
* [Actual coverage and remaining work](COVERAGE.md)
* [Commerce, faction and geography decisions](COMMERCE.md)
* [Confirmed root causes](ROOT_CAUSES.md)
* [Corrected, retained, downgraded and unresolved records](CHANGES.md)
* [Regression/performance and client acceptance](VALIDATION.md)

Machine-readable evidence includes `summary.json`, `catalogue-revalidation.csv`,
`fact-register.jsonl.gz`, `sourceInventory.json.gz`, `providerCounts.json`,
`route-evidence-decisions.json`, `contradictions.json`, `materialDisagreements.json`,
`commerce-audit.json`, `bag-revalidation.json`, `acquisition-changes.json` and
`change-report.json`. `AUDIT_MANIFEST.json` fingerprints the audit artifacts.
Original response bytes are retained in compressed item/spell JSONL and guide
HTML fixtures. Runtime installation ZIPs exclude research fixtures and tools.

The package gate supplies the exact final commit, runtime manifest, complete
extracted-runtime validation receipts and SHA-256 beside the private ZIP.
Those external delivery receipts avoid embedding a self-referential commit hash
in a committed report. Automated validation never substitutes for acceptance.
