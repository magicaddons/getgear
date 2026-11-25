# Commerce affiliation and Alliance accessibility

The approved ACA guide places Alliance's camp at Three Corners, Redridge,
10.5/72.7; its DSL counterpart places Horde's camp outside Crossroads, Barrens,
42/34. These are camp references, **not individual vendor pins**.

Individual guide points are shown below as evidence, not automatic active pins.
Fresh NPC map samples disagree with six entries; those vendors have zone-only
directions. Alynsia has one matching NPC sample, still a published reference.

| Profession | NPC ID and name | Published guide point |
| --- | --- | --- |
| Enchanting | 256732 Alynsia | 11.2, 71.6 |
| Alchemy | 256729 Nina Surefire | 11.0, 72.3 |
| Cooking | 256731 Kalsey Sanden | 10.8, 72.7 |
| Engineering | 256733 Fritz Fizzle | 10.5, 74.3 |
| Blacksmithing | 256730 Stondry Darkhammer | 10.4, 74.7 |
| Tailoring | 256735 Mivin Shadowweave | 10.0, 73.0 |
| Leatherworking | 256734 Daniel Stitchsong | 10.0, 72.9 |

`commerce-audit.json` lists all 317 offer/book IDs, the available exact spell and
output IDs, costs, currency 3402, book-specific reputation text, both skill
values, missing joins, NPC IDs, positions, retrieval dates and evidence hashes.
The recorded commerce faction numeric ID remains unknown. The current guide and
tooltips are from the same provider; they do not count as independent witnesses.

The live action projection uses these rules:

1. An Alliance commerce route requires the exact book/vendor offer in the ACA
   guide. A shared book does not grant access to a Barrens commerce seller.
2. Any explicit Horde service metadata or contradictory Alliance/Horde service
   combination rejects the service. Missing fields never prove neutrality.
3. Both raw price formats and exact legacy string currency names (one price triple and a list of price alternatives)
   receive the same currency/affiliation decision. Existing offer costs agree
   with the guide for all matched recorded ACA offers.
4. A new Alliance route needs the book's explicit teaching spell and output
   link, matching the catalogue's exact spell, book and profession. Ten
   previously missing typed alternatives meet that test; 41 book associations
   are filled and 42 existing source-less routes are projected using exact structured
   NPC names and zones; none is inferred from a camp.
5. All original routes remain in source data. Accepted alternatives, known
   learned recipes and verified finished-item trade remain independent methods.
6. Book-specific generic reputation wording is contextualised to ACA for Alliance.
   The 54 guide/book learning-skill conflicts are displayed with both numbers;
   no convenient value is silently selected.

The shared eligibility/access rule serves preview, overlay, guide, stars,
slot filters, descriptions, learning requirements, bags and navigation choices.
An unavailable learning source has explicit unverified wording and no rejected
vendor destination. A recorded Horde service affiliation does not ban separate
loot from that NPC; acquisition method matters.

Geography is a different policy. Ordinary outdoor routes solely in Barrens,
Durotar, Mulgore, Tirisfal or Silverpine are suppressed in default Alliance
recommendations. Shared quests, accessible dungeons such as Wailing Caverns,
explicit neutral services such as Ratchet, valid alternatives and owned bags
survive. Show-all may lift practicality; it cannot lift hard service/faction
exclusions. RFC remains excluded by its Orgrimmar containment. Valid item records
and shared quest-chain steps are never deleted because of territory.

Sources: [ACA guide](https://www.wowhead.com/forever/guide/azeroth-commerce-authority-reputation-professions),
[DSL guide](https://www.wowhead.com/forever/guide/durotar-supply-and-logistics-reputation-professions).
These are current published references; their actual stock/positions still need
in-game acceptance.

All 317 offers have current book receipts. 290 expose physical output links;
21 teach non-item enchantments and six unlock account titles. Of the physical
outputs, 231 exact equipment/book/spell/profession joins match catalogue records.
Book 249539 says +6 Defense in its teaching text and +9 in its nested effect.
This unresolved contradiction is recorded; no live effect value is chosen.
