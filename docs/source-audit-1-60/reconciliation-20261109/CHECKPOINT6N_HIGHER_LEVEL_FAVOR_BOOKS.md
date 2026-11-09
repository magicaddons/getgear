# Checkpoint 6N — remaining 117 Favor books and useful currency directions

9 November 2026; baseline `56406bf` after lower-level triage closeout.

## Exact book research

All **117 higher-level Favor leads** individually researched: Blacksmithing 30, Leatherworking 43, Tailoring 29, Enchanting 10, Engineering 5. Every exact Forever book XML/item response supplies the expected spell/created-equipment mapping and exactly two named sellers. No unavailable-item flag or alternate quest/drop table appears. Both faction sellers list the same per-book currency-3402 cost; absence of alternatives here is not proof they cannot exist.

[117 book/skill/cost/rank/source-hash records](checkpoint6n_recipe_evidence.csv); [234 seller relationships](checkpoint6n_vendor_references.csv); [12 explicit name exceptions](checkpoint6n_name_exceptions.csv); [supplementary guide and source-access evidence](checkpoint6n_context_evidence.json).

| Profession | Alliance / Horde sellers | Books |
|---|---|---:|
| Blacksmithing | Stondry Darkhammer / Gor'mak | 30 |
| Leatherworking | Daniel Stitchsong / Pawani | 43 |
| Tailoring | Mivin Shadowweave / Jim'bek | 29 |
| Enchanting | Alynsia / Beneris | 10 |
| Engineering | Fritz Fizzle / Fizzlefuse | 5 |

Alliance item tables identify Redridge Mountains; Horde tables identify The Barrens. Published camp guides place the sellers at Three Corners and outside the west gate of the Crossroads. Source NPC IDs are locked per profession and zone. No generic camp coordinate is converted into a precise individual seller pin.

Costs: 60 Favor (49 books), 90 (49), 120 (11), 180 (5), 240 (2), 360 (1). Exact tooltip gates: **60 Friendly and 57 Honored**. Tooltips say “with this faction” without naming one; camp-faction names are retained as guide context, not independently verified book-specific live gates. In particular, 180-Favor Engineering goggles are Friendly but the 180-Favor Brilliant Wand is Honored: cost cannot be used to infer reputation. No gate is copied across a recipe family or class.

Twelve published book titles use a different singular/plural suffix from the catalogue's finished item: four Wristguard/Wristguards plans (251433–251436) and eight Leather/Mail Shoulder/Shoulders patterns (252848, 252850–252852, 252900–252903). The explicit case table retains both names and exact spell/created-item IDs. The gear catalogue is not renamed. Identity assertions were not globally relaxed.

## Currency, reputation and lower-level follow-up

[Current profession guide](https://www.wow-professions.com/forever/merchants-favor-durotar-supply-azeroth-commerce) distinguishes sealed-crate Favor turn-ins from customer-delivered Craftsman's Writs for reputation. These concise published directions now appear in all **188 Favor cases**, including the earlier lower-level records: requested material bundle → sealed crate → Marcy Baker (Alliance Three Corners) or Dokimi (Horde Crossroads camp). Current requirements, rewards and availability remain unverified; no fixed earning rate or crate count is claimed. [Wowhead camp/recipe guide](https://www.wowhead.com/forever/guide/azeroth-commerce-authority-reputation-professions) independently supplies camp/faction context. Older crate/rep descriptions are not silently treated as a current guaranteed reputation method.

The separately read [Fizzlefuse vendor guide](https://www.wow-professions.com/forever/npc/fizzlefuse) explicitly links book IDs 280321, 280322 and 280323 to Friendly Durotar Supply and Logistics. This strengthens the **publication-level** Horde faction evidence for the three lower-level Engineering books from Checkpoint 6E. Their current live purchase gates remain unverified; no field is promoted to live-confirmed. The earlier dated 6E note records the former uncertainty, while this checkpoint and current addon text provide the newer named evidence.

## Source access and validation

All 117 XML/item pages were successfully retrieved with the audit User-Agent in this batch. The first parse stopped on the twelve spelling differences before accepting those cases. Repeat requests then returned HTTP 403; the already-successful same-batch response bytes were reparsed with the explicit ID/name exceptions, and hashes recorded. Later direct NPC requests also returned 403, so no new NPC map/coordinate evidence is claimed. The connected web tool read supplementary guides and independently checked Stondry/Gor'mak's identity/zone. No missing source bytes, login bypass or live evidence was invented.

**Local full validation PASS; GitHub PENDING.** Python compilation/full online source reconciliation, three required files, syntax for 24 TOC modules and 14/14 regression tests. Initial local regression 13/14 exposed an old assertion that a belt must have no details at all; shared Favor directions now legitimately add details. The assertion now checks the real safeguard: glove drop names/claims must not leak onto the belt, while currency directions remain present. The complete suite then passed. New tests lock every new book/cost/rank, Friendly-versus-Honored counterexamples and specific Horde publication evidence.

Index 1,343 → 1,460 summaries; additive runtime book IDs 306 → 423; reviewed registry 266 → 383. Generated CSV semantic changes are 117 new summaries plus three corrected lower-level Engineering summaries. Runtime details also gain shared currency directions on the earlier 71 Favor records. Existing identities, classes/equip gates, source classifications/confidence, ingredients, filters/settings and original learning-method facts remain unchanged. Full-catalogue and prior source-negative regressions pass.

**188/188 Favor leads publication-researched**, live stock still unverified. Trainer-labelled cohort 383/886 researched; **503 remain**: quest/mixed 29, other vendor 86, reputation 46, dungeon 24, generic drop 167, no-alternative 151. Next: remaining quest/mixed books, then non-Favor vendors/reputation and drop/source gaps. All six finished-gear dungeon links and 954 book live-verification routes remain open. No ZIP/build/package, tag, release, merge or main modification.
