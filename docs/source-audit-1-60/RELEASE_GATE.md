# GetGear 1–60 audit — release readiness gate

**Decision: Do not propose a new public release yet.** This is a source-data audit, not a verified in-client release candidate.

## What is covered

- All **7,707** known 1–60 item IDs were enumerated and cross-indexed to **36,341** objectives across all nine classes.
- All **1,252** crafting recipes in this equipment catalogue have non-empty ingredient lists that **agree exactly** with the independently published Forever client recipe extract (Everloot 1.60.1.70790): **zero material additions or corrections** were warranted by that source comparison.
- Cross-checks used independent Everloot recipe and dungeon encounter exports, MAF2414's profession extract, AHledger's 2,203 profession references and item-name catalogue, and player-observed Everloot acquisition edges.
- Source confidence levels preserve uncertainty rather than turning client metadata or Classic leads into guaranteed Forever acquisition.
- Offline Lua parsing, nine-class catalogue, class armour eligibility, ingredient names, source-specific and performance tests passed in [full audit CI](https://github.com/magicaddons/getgear/actions/runs/42480971680).
- [Direct dungeon encounter classification refinement](dungeon_role_reconciliation.csv) corrected 41 labels without pretending to prove server-side loot tables.

## Unresolved work and priorities

1. **198 dungeon-associated records** still need an independently supported mob/source identity or boss-versus-trash classification; check [dungeon queue](dungeon_sources_unresolved.csv). Also verify the acquisition route of *all* client-named encounter items instead of assuming encounter roster inclusion proves drops.
2. **68 recipes** have known recipe item IDs but unresolved vendor/trainer/drop/quest acquisition paths; check [recipe learning queue](recipe_learning_unresolved.csv). A separate **1,086** AHledger-trainer classifications are *references*, not confirmed in-game trainer teaching availability.
3. **6,389** equipment records still carry unverified acquisition routes; these require trustworthy Forever-specific evidence or in-game verification. Do **not** hide the gear merely because research is incomplete.
4. **33** independent item-name disagreements and **716** IDs missing from the independent item catalogue need review. Absence does not prove an item was removed; do not auto-delete or rename.
5. **106** catalogue items have observed Everloot drop edges linking to NPC IDs; the optional NPC name census returned an HTTP 429. Preserve these IDs and evidence for later manual lookup rather than invent names.
6. Verify source strings and layout in the **actual Forever client** and validate the installed build against saved-character data. Offline tests do not prove UI functionality or live availability.

## Approval gate

- Resolve or prominently label the highest-priority source gaps and their confidence at item level.
- Review target items at early warrior levelling, especially **Goblin Mail Leggings (1943)**, **Blackwater Cutlass (1951)** and **Guard's Chain Shirt (250489)**. Confirm materials and the clear dungeon/recipe acquisition labels in the overlay.
- Re-run the full nine-class source, materials, armour, performance and UI tests after any code or source-data changes.
- Obtain explicit authorization before creating any installable ZIP or GitHub release; keep the existing `main` branch unchanged in the meantime.

No public addon release, tag or package has been created in this audit.
