# Checkpoint 7B — 14 lower-level quest equipment routes and fresh-source review

9 November 2026; baseline `eb4f16aa9cfe8d66af438bcc267ebe2d2f5baac5`, after validated completion of the 954-book publication queue.

## Exact reward and access research

Fourteen lower-level quest-associated catalogue entries had no generated source detail. Some already had strong manual/player evidence: this research supplements rather than replaces those facts. All 14 canonical item pages and ten exact reward-quest pages loaded successfully; every exact item ID appears in its quest page's reward or reward-choice list. An additional seven Crown chain pages and three Scramble prerequisite pages support the routes. Minimum quest level, complete chain access, practical level and item equip/class eligibility remain separate.

[14 exact items/quests](checkpoint7b_quest_equipment.csv); [runtime-reviewed equipment metadata](reviewed_equipment_sources.json); [quest facts, actor maps, objectives and chain hashes](checkpoint7b_quest_publication_evidence.json).

| Gear | Published route now supplied in guide | Important limit |
|---|---|---|
| Ashwood Bow 5596 | Crown of the Earth 935: Corithras, Dolanaar → Fandral, Darnassus; chain 920/921/928/929/933/7383, named moonwells and phials | Choose bow or Thicket Hammer; quest minimum 1 does not establish full-chain availability at 1; alternate 934 lacks actors |
| Gravestone Scepter 7001 | Blackfathom Villainy 1200 Alliance /6561 Horde: Thaelrid in BFD; Kelris head → Selgorm, Darnassus /Bashana, Thunder Bluff | Minimum 18; choose one of four rewards; head loot is not a scepter boss drop; preserve observed In Search of Thaelrid chain instructions |
| Juju Hex Robes 16606 | Garments of Spirituality 5648: Tai'jin, Razor Hill; heal/fortify Kor'ja south of town | Published Troll Priest quest, minimum 5; not a new gear wearability rule |
| Acolyte's Sacrificial Robes 16607 | Garments of Darkness 5650: Beryl, Brill; heal/fortify Deathguard Kel north of cemetery | Published Undead Priest quest, minimum 5; displayed quest level 4 does not override minimum |
| Moonsight Rifle 217314 /Precision Bow 217315 | Scramble 79980: Pocket Litter 424005, Stonetalon → Mound of Dirt 424012 | Minimum 14, weapon choices; exact variants remain distinct from other same-name items/crafts |
| Windshaped Shield 263305 | A Firm Response 93746: Ayessa, Zephras Isle; confront Belathaan near Shrine of Akir | Minimum 4; scripted quest objective, not an assumed shield drop; preserve distinction from linked quest 93735 |
| Ursine Hammer 270027 | What Comes Around... 386: Guard Berton, Lakeshire; Targorr head from Stockade | Alliance minimum 22, one of three choices; existing single-player reported confidence retained |
| Raptorscale Pants 281267 | Bloodtalon Matriarch 97223: Xar'Ti, Sen'jin; eggs 277128 from matriarch 268530 off Durotar | Horde minimum 5; pants are quest reward, not matriarch gear loot; reference spawn range only |
| Five friendship bracelets 281269–281273 | Rocks to Rests 97326: Thra behind Grommash Hold, Orgrimmar; collect eight Smooth Boulders 277952 from objects 661446/661448/661449 | Horde minimum 5; **choose one of five**, not all five; object contents/positions published, respawns/current access unverified |

Scramble's faction variants are individually identified: **Alliance 79008** begins at Westfall remains 415107 and goes to Barrens remains/plank 415106/417072; **Horde 79007** begins at Barrens remains 415106 and goes to Westfall remains/plank 415107/424010. Both continue Stepping Stones 79192 to Pocket Litter, then Scramble to Mound of Dirt. Faction object IDs are not interchanged. Map references are traceable to exact objects; current phasing/triggers remain unverified, particularly where guide comments conflict. Later sleeping-bag stages are not prerequisites for the weapon reward. No ghost/death shortcut is recommended. [Published quest chain guide](https://www.wowhead.com/forever/guide/cozy-sleeping-bag-locations-rewards) and exact quest/object pages are separately hashed; commentary is not promoted to independent observation.

The Crown chain supplies the named water-task locations (north of Aldrassil, Starbreeze Village, Pools of Arlithrien and Oracle Glade) and final delivery actors. Its broader current prerequisites are still not independently live-verified. Actor reference footprints remain reference ranges, not guaranteed exact spawns. Thaelrid has no usable coordinate map; none is invented.

## Integration and safeguards

A separate equipment metadata registry has exact ID/name assertions, explicit publication confidence and liveVerified false. It supplies source summary/details without recipe flags or new pattern IDs. Existing generator observations/manual evidence retain priority; only the same iteration's generic community equipment hint may be superseded. AcquisitionEvidence retains original source/instructions/confidence and class/item/material/settings facts. Full guide displays equipment research through the same existing detail layout as recipe research. The permitted non-release workflow now watches this registry so future source-data-only edits receive full CI.

## Fresh upstream changes reviewed explicitly

Fresh reconciliation differed beyond this new research: Playfulls 23,098 →23,147 indexed items, Everloot 1,127 →1,274 edges, seven new item-specific community dungeon links, 48 catalogue observation-count cells and one recipe-book observation relationship. [Exact upstream review](checkpoint7b_upstream_review.json) records the affected IDs and evidence.

Seven dungeon references (10799,11631,11747,11750,11765,11841,12243) move from client-only to community-reference metadata, **all still requiring live verification**. Smoldering Claw's newly selected Hazzas hint looked different from the old first-listed Dreamscythe hint. Review showed Hazzas was already one of four client leads; exact item page independently lists Dreamscythe, Weaver, Hazzas and Morphaz. The original runtime source retains all four. No conflicting source was erased, exclusive source inferred or live loot asserted; a regression now protects the full original source and unverified status.

New book observation: Dark Leather Tunic 2317/book2409/spell2169 → Fallen Necromancer 255964, three installs, last seen 8 November. Exact NPC loot page includes book2409, and its description places the NPC in Ruins of Lordaeron; no map/pin exists. This NPC/zone was already present in the reviewed book guide. The raw observation is preserved, but no unnamed target guessed, finished-tunic drop inferred, original confidence rewritten or live-check queue closed. Thirteen other book-source JSON differences are source-row offsets only; seven new dungeon associations account for semantic source changes.

## Validation and continuation

**Local full validation PASS; GitHub PENDING.** Python compilation/full online source reconciliation succeeded with the configured audit User-Agent against Playfulls, WoW Forever Friends and Everloot. Required files 3/3; Lua 5.4.7 syntax checks for all 24 TOC modules; **14/14 regressions pass**. Tests cover equipment-versus-recipe metadata, object/quest loot distinctions, exact reward choices, faction variants, priest access facts without class mutation, reported-confidence retention, Crown minimum-versus-chain caveat, scripted confrontation and original four-boss source preservation. Full catalogue/material/settings/filter/layout/performance safeguards pass. The initial integration draft omitted the Raptorscale case and was caught by its exhaustive item-set assertion before any registry was written; corrected before final validation. No partial check is counted as a pass.

Runtime index 1,963 → **1,977** summaries; additive book IDs remain **759**; recipe registry **954** unchanged; equipment registry **14**. Generated changes include 14 new equipment summaries plus the reviewed upstream differences above, not just cosmetic timestamp churn. All original 7,707 identities, 36,341 class objectives, 1,253 runtime crafts and 4,855 ingredients remain intact. Six dungeon and 954 current book verification routes remain open; broader gear-source uncertainty is not closed by this bounded batch. Next: remaining lower-level vendor/undocumented-source gaps after CI/bot verification, then final acceptance planning. No ZIP/build/package/tag/release/merge/main changes.
