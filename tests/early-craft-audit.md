# Early crafted gear progression audit (v0.12.11 baseline)

**Scope:** Alliance classes and specializations, recommended equipment usable at character levels 1–15. Source-only candidate for the next GetGear beta; **not a published release**.

## Why

At level 6, a Priest sees high-value level-10 sashes but misses the intermediate green Tailoring equipment. The existing tracker deliberately looks ahead five levels; these objectives were absent from the Priest catalogue, rather than gated by unlearned Tailoring. The audit also identified omitted meaningful crafted equipment in other class guides.

## Verified additions

| Finished item | ID | Required character level | Profession | Suggested guides | Evidence |
| --- | ---: | ---: | --- | --- | --- |
| Red Linen Robe | 2572 | 5 | Tailoring; pattern 2598 requires skill 25 to learn | Priest, Mage, Warlock | https://www.wowhead.com/forever/item=2598 |
| Red Linen Vest | 6239 | 7 | Tailoring; pattern 6271 requires skill 35 | Priest Shadow, Mage, Warlock | https://www.wowhead.com/forever/item=6271 |
| Blue Linen Vest | 6240 | 7 | Tailoring; pattern 6270 requires skill 35 | Priest Holy/Discipline | https://www.wowhead.com/forever/item=6270 |
| Green Linen Bracers | 4308 | 7 | Tailoring; trainer, minimum learning skill unverified | Priest, Mage, Warlock | https://www.wowhead.com/forever/spell=3841 |
| Embossed Leather Gloves | 4239 | 8 | Leatherworking; trainer, minimum learning skill unverified | Rogue, Hunter, Druid Feral, Shaman Enhancement | https://www.wowhead.com/forever/spell=3756 |
| Embossed Leather Boots | 2309 | 10 | Leatherworking; trainer, minimum learning skill unverified | Druid Balance/Restoration, Shaman Elemental/Restoration | https://www.wowhead.com/forever/spell=2161 |
| Fine Leather Gloves | 2312 | 10 | Leatherworking; pattern 2408 requires skill 50 | Druid Balance/Restoration, Shaman Elemental/Restoration | https://www.wowhead.com/forever/item=2408 |
| Copper Chain Belt | 2851 | 6 | Blacksmithing; trainer, minimum learning skill unverified | Warrior, Paladin | https://www.wowhead.com/forever/spell=2661 |
| Rough Boomstick | 4362 | 5 | Engineering; trainer, minimum learning skill unverified | Hunter | https://www.wowhead.com/forever/item=4362 |
| Copper Chain Boots | 3469 | 4 | Blacksmithing; existing catalogue item | Add Paladin (already recommended to Warrior) | https://www.wowhead.com/forever/spell=3319 |

The first nine are NEW catalogue entries; Copper Chain Boots already existed and is a new Paladin class recommendation only.

## Deliberate exclusions

- Existing starter Leatherworking and Blacksmithing crafts in the Druid/Warrior/Rogue/Hunter/Paladin/Shaman guides were retained rather than duplicated.
- Early Enchanting wands were already in Priest/Mage/Warlock recommendations. Other Enchanting output is not general wearable equipment.
- Engineering goggles require the **wearer** to have Engineering; they must not be presented as universally equippable early upgrades. Rough Boomstick does not require Engineering to equip, but Hunter must know gun proficiency and have bullets.
- Cooking, Alchemy, First Aid, Mining, Herbalism and Skinning do not provide comparable direct craftable wearable equipment upgrades for this level range.
- Cloth shirts, statless white craft levelling items, or upgrades unlikely to improve a class/spec were excluded.
- Leather caster pieces intentionally excluded from Hunter and Rogue.
- Unverified trainer **learning** minima remain unknown; the tool never uses yellow skill-up breakpoints as teaching minima.

## Ingredient audit

- 7 new recipes require **Coarse Thread**, correctly item ID **2320** (NOT Fine Thread, item 2321). This was caught and corrected during final testing.
- Hunter Rough Boomstick ingredients: Copper Tube **4361**, Handful of Copper Bolts **4359**, Wooden Stock **4399**.
- Specific pattern items and their learning minima are linked above. These should not be confused with the character level to equip finished pieces.
- Live vendor/trainer stock is not guaranteed by client-indexed evidence; descriptions flag uncertainty.

## Verification

- Source-only staging on branch `fix/early-crafted-gear-1-15`; the TOC loads `EarlyCraftedProgression132.lua` after `LaunchEvidence131.lua` and before runtime UI.
- **9 new catalogue entries; 22 new recommendations.** Expected totals: **234 catalogue items, 426 recommendations, 37 class/spec preview views**.
- Local Lua 5.4 execution passed on pre-launch baseline with the new module and no collisions; the GitHub Actions Lua 5.4 test passed against the current **v0.12.11** source, including all catalog and specialization assertions.
- Level-6 Priest with All specs: Red Linen Robe available; Red and Blue Linen Vests, Green Linen Bracers appear within the next-five-level window.
- Preserved `/getgear`, old saved objective IDs, previous acquisition fixes and the personal/account inventory storage keys.
- **Not live-tested inside WoW Forever.** The published v0.12.11 package remains untouched.

To put these changes in players' hands, a new installable ZIP and release will require separate explicit build authorization.
