# Checkpoint 6B — actionable low-level Blacksmithing recipe sources

9 November 2026. Baseline: `afcb5a2fd7c658c23d5194fd8b04fe9865a0d4c6`. One bounded Merchant’s Favor vendor category: all 10 Blacksmithing entries at character levels 12–25 in the 188-book queue. No new live-stock confirmation.

## Purpose and source standard

The user prioritised complete, accurate, actionable in-addon directions over an earlier RC. Continue source research before RC, prioritising lower-level gear and named drop enemies, recipe vendors, quests and locations. Do not stop at external research notes when supported information can be shown inside the addon. Preserve uncertainty, the complete catalogue and all existing eligibility/settings/filter/material behaviour.

## Exact case register

| Gear ID | Gear | Level | Book ID and direct tooltip | Craft spell | Book learning skill |
|---:|---|---:|---|---:|---:|
| 250515 | Protector's Chain Belt | 12 | [251367](https://www.wowhead.com/forever/item=251367/plans-protectors-chain-belt) | 1252264 | 45 |
| 250516 | Acolyte's Chain Belt | 12 | [251368](https://www.wowhead.com/forever/item=251368/plans-acolytes-chain-belt) | 1252265 | 45 |
| 250517 | Crusader's Chain Belt | 12 | [251369](https://www.wowhead.com/forever/item=251369/plans-crusaders-chain-belt) | 1252266 | 45 |
| 250510 | Protector's Gloves | 15 | [251362](https://www.wowhead.com/forever/item=251362/plans-protectors-gloves) | 1252259 | 80 |
| 250512 | Crusader's Gloves | 15 | [251364](https://www.wowhead.com/forever/item=251364/plans-crusaders-gloves) | 1252261 | 80 |
| 250507 | Crusader's Boots | 17 | [251359](https://www.wowhead.com/forever/item=251359/plans-crusaders-boots) | 1252256 | 85 |
| 250529 | Guard's Silvered Chain Helm | 20 | [251381](https://www.wowhead.com/forever/item=251381/plans-guards-silvered-chain-helm) | 1252278 | 95 |
| 250532 | Crusader's Silvered Chain Helm | 20 | [251384](https://www.wowhead.com/forever/item=251384/plans-crusaders-silvered-chain-helm) | 1252281 | 95 |
| 250522 | Crusader's Silvered Chain Shirt | 22 | [251374](https://www.wowhead.com/forever/item=251374/plans-crusaders-silvered-chain-shirt) | 1252271 | 110 |
| 250527 | Crusader's Silvered Chain Leggings | 25 | [251379](https://www.wowhead.com/forever/item=251379/plans-crusaders-silvered-chain-leggings) | 1252276 | 125 |

Each direct Wowhead Forever book tooltip was read and name/skill checked. Each links the specific taught craft; repository book/spell/profession mappings are locked by generator assertions. Book-learning skill is displayed as reference information and does not change crafting/equip eligibility gates. No recipe materials were edited.

## Vendor and location evidence

- [Stondry Darkhammer’s published inventory](https://www.wow-professions.com/forever/npc/stondry-darkhammer) individually links these ten book IDs and lists 30 Merchant’s Favor each. Alliance destination: Three Corners, Redridge Mountains. Blank reputation cells are not interpreted as proof of no gate.
- [Gor’mak published inventory and location](https://azeroth.wiki/forever/map/the-barrens/gor-mak) lists all ten corresponding book names; the existing Playfulls exact-ID export independently links each to Gor’mak/The Barrens (Horde). Destination: near Crossroads. These are publication-level seller references, not current stock observations.
- [Stondry location listing](https://azeroth.wiki/forever/map/redridge-mountains/stondry-darkhammer) gives 10.3, 74.5; the old Veteran’s Belt patch uses 8.01, 74.81. Avoided introducing new navigation pins or silently replacing that older location until this discrepancy is reconciled. Named settlement/zone directions are shown instead.
- Direct shell access to wow-professions was denied by this environment’s proxy; the connected web tool successfully opened the inventory. Playfulls and client-cache network fetches succeeded.

## Conflicting and alternate evidence retained

- [Protector’s Belt book 251367](https://playfulls.com/item/251367-plans-protectors-chain-belt) currently displays “No source yet” while its database export carries vendor/Favor references. The Wowhead vendor-zone section and named vendor inventories independently support a published vendor lead; no live certainty is inferred from the export.
- [Book 251362](https://www.wowhead.com/forever/item=251362/plans-protectors-gloves): a player comment reports a Ragefire Chasm final-boss drop. No exact boss name or qualifying independent observation is established by that comment.
- [Book 251364](https://www.wowhead.com/forever/item=251364/plans-crusaders-gloves): a player comment reports a Ruins of Lordaeron drop without identifying an enemy.
- [Book 251381](https://www.wowhead.com/forever/item=251381/plans-guards-silvered-chain-helm): a player comment reports Verdan the Everliving in Wailing Caverns.
- All three are displayed as **Player report … unverified**, separate from vendor references. They do not assert that the finished crafted gear drops or that a trainer does/does not teach it. Comments lack a verified realm/build/date in the retrieved text.

## Implementation and integrity

The machine-readable reviewed_recipe_sources.json stores exact IDs/names/spells, citations, cost, learning skill, review date and liveVerified=false. The generator hashes the register in provenance.json and adds ten reference summaries/pattern IDs. AcquisitionEvidence preserves original source text and confidence. The same research is visible in the compact overlay and appended to the detailed guide. Manual and recorded-observation summaries keep precedence. No unrelated UI or filter changes.

Full source refresh: 1,077 → 1,087 summaries, 68 → 78 additive book-ID entries. Source-confidence and original recipe classifications remain separate. All 7,707 equipment identities, 36,341 class objectives, 1,252 indexed recipes, 552 dungeon equipment, six dungeon followups and 954 book followups remain. No false closure of live queues.

Generated-diff review: sourceRow shifts affect 48 dungeon rows and 28 recipe rows; item 11823 (Luminary Orb) switches cache reference to Playfulls community reference with identical unverified boss text, not observed status. CSV row counts, ID ordering, names, levels, original evidence/routes, dungeon roles, materialsStatus, classification and requiresLiveCheck were compared and retained.

## Validation

**Local PASS:** Python compilation and full online reconciliation; three required generated files; Lua 5.4.7 syntax for all 24 manifest modules; 14/14 workflow regressions. Added ten exact book/source assertions, player-report uncertainty checks, real detailed-guide formatter execution and negative tests protecting original observations/materials/class masks. `git -c core.whitespace=cr-at-eol diff --check` passed.

**GitHub PASS:** [non-release run 42550577399](https://github.com/magicaddons/getgear/actions/runs/42550577399) completed at 2026-11-09T02:23:07Z (12:53 Adelaide), with all reconciliation, required-file, 24-module syntax, 14-test regression, artifact and development report-commit steps successful. Validated source commit `a05bd5fdd615730fefa0e97e2a823c5427707945`; verified bot final HEAD `26756f6367f10aa0ceeff91dd3d6dce8ce4ed3c1`. Compared bot output to the locally validated generation: identical evidence index and CSV/README contents; only three Everloot response hashes and timestamp differ in provenance.json.

Git/CLI credentials briefly failed before push (Bad credentials / could not read Username). Published the nine reviewed source/documentation files through the connected GitHub integration with an expected-HEAD lease; CI regenerated the reports only after validation. CLI access subsequently recovered. Local commit `0043385c0e48390fce9c727ea47bb42d56b7c551` was preserved on `preserved-local-checkpoint6b`; required local development branch now tracks the verified CI result. No user credential action was needed. Documentation-only outcome closeout follows the bot commit.

## Remaining work and next bounded batch

**10/188 Favor leads** now individually reviewed and integrated; **178/188 remain**. None of these ten is live-stock verified. The original 68/68 level-60 vendor publication reviews remain complete; all 954 book verification routes remain open. Next: early-level Tailoring Favor books, then Leatherworking, grouped by exact book and seller; include contradictory/drop/quest routes. After Favor, the remaining 37 quest/mixed, 225 other-vendor/reputation, 41 dungeon, and generic/unknown groups remain. Do not equate today’s ten-item pass with completion of the wider research programme.

No ZIP, packaging, release, tag, merge or main modification. In-client acceptance remains outstanding.
