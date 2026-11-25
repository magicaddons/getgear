# Provenance and historical dependency audit

The owner's new policy is authoritative in `docs/RESEARCH_SOURCE_POLICY.json`.
`tools/research_sources.py` enforces allowed hosts, Forever URL paths, the full
blacklist, HTTPS, redirects, platform provenance and native-observation receipts.
Historical Python research entry points and the old endpoint-probe workflow now
use that boundary. The standalone mixed-provenance export workflow is quarantined
and fails before any download; its original text remains in Git history. The dated
GitHub tooltip/recipe caches are quarantined as generation inputs, including
local-cache imports, pending individually reviewed original lineage. Historical
files remain auditable; a permitted hosting platform never verifies their facts.

## What was inspected

All tracked textual research/code/data documents were scanned locally for source
URLs and fingerprints. `sourceInventory.json.gz` records each file and every
distinct URL/file reference; `providerCounts.json` groups them by host/policy.
This inventory makes **no external request** to the listed URLs. Reference counts
include historical discovery lists, comments and tests; they are not counts of
verified facts or independent witnesses. The new audit directory is separately
manifested, so its own report cannot recursively fingerprint itself.

The frozen `docs/source-audit-1-60/provenance.json`, navigation source assessment,
Alliance correction report, all named acquisition/runtime modules, generators,
cached publication excerpts and derived data were inspected. The full runtime
leaf register keeps uncertain fields uncertain, including source routes, NPCs,
quests, chains, recipes, currencies, maps, availability and entrance data.
Current commerce overrides and exact new route checks have separate ledgers.

## Historical GitHub relationships

| Historical input | Evidence inspected now | Finding and disposition |
| --- | --- | --- |
| Everloot GitHub recipe/encounter extracts | Author README, data policy and source ledger on GitHub | The author separates own client-file recipe/encounter projections from player uploads and other inputs. No blacklisted origin was established for those exact extracts. Their unpinned historical applicability is unresolved; they are not blanket-classified as a blacklisted mirror. Fresh exact spell/output/reagent checks replace reliance on them where successful. |
| Everloot API observations | Existing GetGear provenance and current author documentation | Outside the approved provider list as a direct service. Old observations are historical third-party reports, not our native-client observations. Dataset-specific build and witness provenance must be reviewed before reuse. |
| AHLedger catalogues and crafting API | Retained GetGear provenance, generators and reconciliation tables | Directly unapproved. Historical learning classifications, quantities and availability cannot independently verify current facts. Matching current spell/output/material facts are revalidated separately. |
| MAF2414/wow-forever-talents | Author README on GitHub | It names Wago.Tools DB2 exports and an older cached workflow. Wago is unapproved here. No ownership/data relationship to the blacklisted wowforevertalents.com was established; similar names alone prove nothing. |
| nobody174/wow-forever | Author README on GitHub | The current author explicitly credits WCLBox item statistics/names, alongside several other sources. This is mixed provenance with a blacklisted component. The historical GetGear download was not pinned to an immutable revision, so every old field cannot be mapped retrospectively to the current README. It remains unverified rather than being laundered through GitHub. |
| Napalmsteak/WoW-Classic-Item-Caches | Author README on GitHub, retained dated cache metadata | Describes embedded Wowhead tooltips and broad source categories across versions. It is a derivative publication, not direct current-client evidence. Fresh direct Forever tooltips revalidate specific printed fields independently of the cache download. |

`github-provenance.json` retains URLs, retrieval dates, document fingerprints and
fact-specific findings. No blacklisted site was fetched to investigate these
relationships, and no third-party repository's game dataset was newly imported.

## Direct and indirect scope

The original identity/level/class/stat-role cache and generated stat flags affect
all catalogue/class projections. Historical recipe imports affect reagents,
spell IDs and learning classifications; reconciliation feeds affect loot roles,
source summaries and navigation. The baseline provenance names AHLedger,
Everloot, MAF and other unapproved providers. Navigation history additionally
uses Azeroth DB, Warcraft Tavern, Method, Mobalytics, LFCarry, guild sites and
other unapproved publications. Blacklisted references found in local history
include Forever Codex, ForeverDiff, WCLBox, 60.tools and others; the exact complete
inventory is machine-readable rather than silently omitted.

Historical provenance sometimes records an aggregate feed instead of the exact
original fact/row/build. That missing lineage cannot be reconstructed merely
from matching values. Those facts remain previously sourced/currently unverified
or missing evidence. The register does not falsely declare every uncertain field
blacklisted, and does not declare it clean because it has a Wowhead item link.

The 17-file historical acquisition snapshot and 900 accepted candidate holds
remain unchanged. Historical labels such as `client`, `confirmed` or `published`
inside those files are not current verification under this policy. The new
fact/route ledgers, their evidence scope and explicit unresolved queues govern
the reaudit outcome.
