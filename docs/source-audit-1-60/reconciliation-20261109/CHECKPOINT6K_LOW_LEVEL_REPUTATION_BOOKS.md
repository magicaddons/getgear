# Checkpoint 6K — 48 lower-level Nightclaw reputation books

9 November 2026; baseline `ba1ebb1` after successful dungeon-book validation.

## Exact book and seller evidence

All 48 level-1–30 entries in the triage's reputation-only cohort have exact Forever book pages naming **Vayn Moongaze (NPC 254151)** as seller. Exact book names, crafting spell IDs and created gear IDs match independent repository mappings. [48-case identity/gate/price/hash register](checkpoint6k_recipe_evidence.csv); [NPC map, quest metadata, source hashes and access conflicts](checkpoint6k_nightclaw_access_evidence.json).

| Profession | Books | Friendly | Honored |
|---|---:|---:|---:|
| Blacksmithing | 12 | 8 | 4 |
| Leatherworking | 24 | 16 | 8 |
| Tailoring | 12 | 8 | 4 |
| Total | 48 | 32 | 16 |

Each gate comes from that exact book's tooltip/JSON, faction 2758 (Nightclaw Druids), not a family assumption. Learning skills are 50, 55 or 60, distinct from finished-gear equip level. Listed seller prices are 9s50c, 11s or 13s15c; reference prices can differ from other guides due to discounts or source state. Stock -1 does not establish current unlimited availability. None of these 48 pages has the explicit unavailable-item flag found in the earlier three conflicting Tailoring books.

[Seller NPC page](https://www.wowhead.com/forever/npc=254151) maps Zephras Isle, uiMapID 2521, x 63.3–64.1 / y 36.0–38.1. [Nightclaw guide](https://www.wowhead.com/forever/guide/reputation/nightclaw-druids-quests-quartermaster-rewards) gives 63.8,36.0 at the cave entrance in Shadowgale Forest. [Profession vendor guide](https://www.wow-professions.com/forever/npc/vayn-moongaze) independently names Nightclaw Cavern. NPC comment 6468441, dated **8 November**, reports no shop option, only ear-quest turn-in. Other dated comments discuss movement/disappearance. These are specific player reports, not independently verified universal availability or an established game bug. Both overlay and full-guide text explicitly flag **shop access disputed; live unverified**. No guaranteed shopping instruction or live stock confirmation is introduced.

## Useful access directions with unresolved conflicts

The guide references Lotheluum Starbreeze in Valanaar (64.0,75.0), Unnerving Silence, then Elegael Thornpaw (61.6,39.2) and Shadowgale Forest quests. The ear follow-up involves Vayn and cultists in Shadowgale Forest, Shrine of Akir and Gustberry Lowlands. Opening/ear quest metadata requires level 8, even though some finished gear is equipable sooner. The full guide now includes these directions, with explicit publication/quest-log caveats.

- [Unnerving Silence 94484](https://www.wowhead.com/forever/quest=94484): exact metadata has race 95; the guide broadly describes all-race access. Do not silently remove the race restriction from the evidence or turn it into a finished-gear eligibility restriction.
- [Mercy Falls on Deaf Ears 93165](https://www.wowhead.com/forever/quest=93165): exact metadata lists races 3,6,95 and start/end Vayn Moongaze 254151. Objective says five ears; guide says ten. Current all-race quest access is unresolved.
- [More Al'Aketh Ears 93459](https://www.wowhead.com/forever/quest=93459): objective prose says ten ears and names Vayn Moonclaw, while objective table says five and end-NPC metadata links Vayn Moongaze 254151. Reward metadata says 200 reputation; older comments mention other values. No fixed ear totals, grind estimate, drop rate or race-wide unlock is claimed.
- [Zone travel guide](https://www.wowhead.com/forever/guide/zephras-isle-zone-overview-maps-locations-and-trainers-34862) describes skyboats from northern Dalaran and near Thunder Bluff to Valanaar, including non-Skyborne visitors. Travel access does not prove quest or shop access. Both distinctions remain explicit.

The profession-guide domain was blocked by the shell's network proxy (403 tunnel), but the connected web tool successfully read it. Exact book/NPC/quest/guide pages were retrieved directly using the configured audit User-Agent; hashes are recorded. No credentials or source restrictions were bypassed.

## Generated changes and validation

**Local full validation PASS; GitHub PENDING.** Python compilation/full online reconciliation; three required files; all 24 TOC module syntax checks; 14/14 regressions. Source summaries 1,218 → 1,266; additive runtime book IDs 205 → 253; reviewed registry 141 → 189. New regressions cover exact IDs, Friendly versus Honored, disputed shop access, in-guide directions and no assumed all-race route. Existing full-catalogue invariants preserve identities, classes, filters/settings, sources and ingredients.

Fresh regeneration also retrieved an upstream Playfulls update (23,048 → 23,074 items). Most CSV changes are source-row renumbering, checked by decoding and comparing JSON with only `sourceRow` removed. Two actual published relationships were added: Fist of the Damned 10804 → Ogom the Wretched, Sunken Temple, and Fleetfoot Greaves 11627 → Houndmaster Grebmar, Blackrock Depths. The latter's report/index confidence changes from generic unverified reference to community reference; its summary still says live unverified. Existing roles/routes and requiresLiveCheck remain unchanged; neither becomes observed/live-confirmed. Only 48 new summaries and that one index provenance change occur. Recipe source types/ingredients/statuses remain unchanged.

Reputation-only cohort now 48/94 researched; 46 higher-level entries remain. All lower-level Favor (71), quest/mixed (8), other vendor (45) and dungeon-book (17) leads were already researched. Next: 54 lower-level generic-drop books, then 23 no-alternative entries, followed by remaining higher-level source groups and broader equipment gaps. The six unresolved finished-gear dungeon links and 954 live book-verification routes remain open. No packaging, release, tag, merge or main changes.
