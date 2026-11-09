# Checkpoint 6R — 24 remaining dungeon/enemy book leads

9 November 2026; baseline `7046fb0` after complete reputation-cohort validation.

All 24 higher-level dungeon/enemy leads independently researched: Leatherworking 10, Blacksmithing six, Tailoring four, Engineering three, Enchanting one. Exact book names, teaching spells and created equipment match the independent catalogue. No unavailable-item flag or named vendor/quest alternative appears in the retrieved book tables; absence is not proof no alternative can exist.

[24 identity/skill/source-hash cases](checkpoint6r_recipe_evidence.csv); [29 exact actor/location references](checkpoint6r_book_source_references.csv); [10 book-specific specialisations](checkpoint6r_specialisations.csv); [two object pages, outdoor NPC map and additional zone identities](checkpoint6r_location_evidence.json). All primary pages retrieved with the configured audit User-Agent.

**22 books have 27 published enemy relationships.** Full guide names the exact NPCs and source zones; overlay names the book and alternatives. The tables can retain historical data and are not exhaustive live inventories. No percentages, encounter rank, exclusive source or guaranteed current farm is promoted into evidence. These are learnable-book sources, not finished crafted equipment drops.

**Two books have lootable-object references:**

| Book | Created gear | Published source |
|---:|---|---|
| [11614](https://www.wowhead.com/forever/item=11614) | Dark Iron Mail | Blacksmithing Plans object [173232](https://www.wowhead.com/forever/object=173232), Blackrock Depths |
| [11615](https://www.wowhead.com/forever/item=11615) | Dark Iron Shoulders | Blacksmithing Plans object [173234](https://www.wowhead.com/forever/object=173234), Blackrock Depths |

The two same-name objects retain distinct IDs. They are not enemy NPCs or boss loot. Exact object pages provide no mapper coordinates; current object presence/loot and precise spawn are explicitly unverified. No point is fabricated. These book relationships do not close the original six finished-equipment dungeon links or prove loot for the separate coffer leads.

Additional distinctions retained:

- Dark Iron Sunderer book 11611 lists Hammered Patron and Ribbly's Crony in Blackrock Depths. No different boss is substituted or inferred from a common historical association.
- Craftsman's Monocle book 4415 includes Kurzen Shadow Hunter in Stranglethorn Vale alongside Scarlet Monastery/Gnomeregan references. Its outdoor source is retained rather than forcing every lead into a dungeon. Seven published NPC map points are represented as a reference footprint, not an invented central pin or current sighting.
- Six exact Leatherworking books list Dragonscale/Elemental specialisations. Four Blacksmithing books list Weaponsmith or a specific Master Hammersmith/Master Axesmith requirement. Heartseeker's Weaponsmith reference is not replaced with another weapon's mastery. These are published book requirements, not new finished-gear class/equip filters.
- Shared zone IDs are not expanded into guessed dungeon wings. NPC rank is not loot confirmation; no published reference becomes a live claim.

**Local full validation PASS; GitHub PASS.** Source commit `9cafb45c82b1b48218eabee5cec308cec9dca30a`; [non-release CI 42568313293](https://github.com/magicaddons/getgear/actions/runs/42568313293) completed all steps; full logs confirm 14/14 regressions and 1,645 summaries. Inspected direct bot child/final HEAD `96ac83ad70fb0e528aae627cead5b4325eb53cce`: only provenance timestamp and three Everloot response hashes differ; generated runtime index and evidence match local validation. Python compilation/full online reconciliation, three required files, all 24 TOC Lua modules and 14/14 regressions. New tests cover every exact book ID, objects versus enemies, non-propagation between the two object IDs, outdoor source, individual weapon specialisations and unchanged crafted-gear semantics. Full catalogue/class/source/material/filter/settings/layout/performance invariants pass.

Index 1,621 → 1,645; additive runtime book IDs 566 → 590; reviewed registry 544 → 568. Generated CSV semantics change only in 24 additive summaries; original source/confidence/method fields, identities/order, requiresLiveCheck, class/equip rules, crafting ingredients and settings remain intact.

**41/41 dungeon/enemy triage leads now publication-researched** (including these two object routes), with live acquisition still unverified. Trainer triage **568/886 researched; 318 remain**: 167 generic drop and 151 no-alternative cases. Next: remaining generic-drop books, then final source gaps. All six finished-gear dungeon and 954 book live-verification routes unchanged. No ZIP/build/package, tag, release, merge or main changes.
