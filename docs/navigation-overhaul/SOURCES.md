# Navigation evidence assessment

This review starts at tested `.4`, commit
`cea9cdef9cc161959e3b3787dc0a0e025fbeb6e7`. The existing acquisition snapshot is
retained byte for byte. New geography and label joins are a separately generated,
reviewable projection in `AcquisitionNavigation.lua`, produced by
`tools/build_navigation_review.py`. No upstream loot, vendor inventory, quest
reward, recipe minimum or equipment eligibility is bulk refreshed.

## Inventory and policy

`source-inventory.json` inventories the runtime's 975 sources, 716 quests and
7,440 acquisition routes across 3,681 items with structured plans. Other catalogue
items retain their existing source/reference behavior; these counts do not mean
the equipment catalogue has only 3,681 items. Source records comprise 856 typed
NPCs, 17 objects, one zone and 101 bag-quest actors. Provider/file counts identify
each evidence input contributing to those records. References are counted, not
independent witnesses. The complete catalogue has 7,707 equipment IDs.

The source graph includes:

| Provider or input | Actual use | Limit and disposition |
| --- | --- | --- |
| Current native `C_Map`/`C_EncounterJournal` | Map names/IDs, current native exterior entrance candidates | Preferred at selection time. A map-name match proves namespace compatibility, not that a published point is physically correct. No real client was available in this environment. |
| Current `C_QuestLog` | Character quest stage, objective waypoint/text | Preferred for the active character. A quest-log event alone does not change a selected destination. |
| Wowhead Forever NPC/object/quest/item/spell records | Names, merchant and teaching joins, source positions, quest actors and restrictions | Keep exact entity/output joins and fingerprints. Related-item lists are weaker than full named entity records; a URL containing Forever does not establish live stock, loot or access. |
| `reviewed_equipment_sources.json`, `reviewed_recipe_sources.json`, checkpoint JSON/CSV | Frozen, reconciled source evidence and typed acquisition alternatives | Retained. The inventory identifies contributing files. Their publication evidence and explicit legacy/cross-version qualifications remain intact. |
| `navigation_quest_chains.json`, bag-quest evidence and reviewed actor locations | Quest itinerary, starter/turn-in identity and source-specific geography | Retained. Published series order does not establish every prerequisite. Nalpak's continent reference is not converted to a local NPC point. |
| Wowhead dungeon overview | Original 32 definitions and 21 approach choices across 20 definitions | Retain useful approach descriptions; downgrade its authority as a complete/current precise-portal database. It omits two Forever dungeons and several numerical entrance facts found in individual guides. Its Stockade point conflicts with map-bound published client-derived data. |
| Individual Wowhead dungeon guides | Structured map-area/pin markup and written approaches | Reviewed per page. Excavation has separate portal/meeting-stone pins; Hall of Thanes marks the High Seat, not its portal. Dalaran has contradictory faction wording, which is not used as an access rule. |
| ForeverDB | Independent published, client-derived map/entrance references and provider attribution | Useful corroboration and source of explicit UI map IDs. Still a published provider claim, not our in-game observation. Its inferred sole-portal-model match for Excavation conflicts with the individual primary guide and is withheld. |
| Blizzard raid overview; Wowhead raid overview | Announced roster, approach descriptions and uncertainty about portals | Distinguish announced raids from historical client-listed instances. Comments beneath a guide are not the guide author's verified location. |
| Azeroth DB | Stockade 50.4,66.2 corroboration | Supports the published location, without independent live-client verification. |
| Guild guide at wow4ever.se | Stockade corroboration and provider source policy | Mixed provenance: it attributes entrances to client build 1.60.1.70938 but also displays a Classic/EG Link location disclaimer. Its numerical agreement is not independent current-client proof. |
| Warcraft Tavern, Method, Mobalytics, LFCarry and other community references | Independent route descriptions, indexed coordinates and conflict discovery | Assess the particular fact, version and map. Direct retrieval failures are recorded. Shaper's Terrace is a qualified indexed approach; its hash explicitly fingerprints our committed retrieval response, not inaccessible provider HTML. |
| Hand-authored bag vendor observations | Existing general-goods positions and vendor identities | Keep existing coordinates and source details. Explicit `npcName` fields carry identity; historical beta observations do not establish today's stock or rendering. |
| `MapNavigation.lua` fallback ID candidates | Compatibility across API namespaces | Candidates must match actual client map names. They are neither location evidence nor coordinate transforms. |

Evidence preference is (1) applicable current client observation/API, (2) exact
Forever primary records, (3) independently attributable Forever databases,
(4) identifiable community research, and (5) historical/unverified references.
This is a fact-specific policy, not a blanket provider ranking: an inferred
client-model match can be weaker than a labelled primary guide map, and an
anonymous comment can be weaker than the article surrounding it.

## Accepted, downgraded and withheld facts

* **Accepted as published references:** individual primary guide entrance and
  approach pins, independently map-bound Stockade 50.35,66.18 on UI map1453,
  Wailing Caverns' separately labelled published portal reference, and the
  qualified Shaper's Terrace approach. None is marked as our live observation.
* **Downgraded:** overview-only precision claims, unlabelled wing-door assumptions,
  guild/aggregator Classic fallback, and inferred portal-model matches. Original
  coordinates and fingerprints remain in `previousEntrances` and the audit.
* **Withheld:** Stockade 41,57 as the current portal; Excavation24.5,73.4 as the
  selected exterior entrance; competing Blackmaw points; anonymous raid-comment
  coordinates; interior boss/NPC positions as entrances; guessed wing portals.
* **Conflicting:** each record's `findings` identifies coordinate disagreements,
  map-frame issues and the next verification method. Broad numerical agreement
  between pages is not automatically counted as independent physical evidence.

## Generator findings

The old generator could omit reviewed dungeons without a preexisting loot/zone
join, merge locations by zone name while discarding differing UI map IDs, and
suppress a catalogue vendor point merely because a same-name actor had a
zone-only location. Those shared rules are corrected. Missing map IDs can inherit
one uniquely supported frame; conflicting frames retain separate geometry, and
unqualified coordinates with multiple frames become a reported unresolved record.
Malformed IDs, interior maps, invalid coordinates and contradictory verification
remain ineligible for precise entrance pins.

The additive projection deliberately avoids rerunning all historical extraction
against the approved acquisition snapshot. It preserves that snapshot and every
original acquisition route, while making the reviewed entrance roster and
structured label identities reproducible. `--check` runs in local validation,
CI and the extracted-package gate.
New coordinates must also match retained primary-map or published client-derived
extraction fixtures with the cited fingerprint. A syntactically valid hash alone
cannot justify an arbitrary coordinate. Indexed-only evidence is checked against
its exact committed retrieval response, with that fingerprint scope explicit.

`research/pages.json` and `research/foreverdb.json` retain successful response
fingerprints, extraction metadata and failures. `research/search-*.json` retain
the indexed discovery receipts; they are discovery evidence, not a claim that
every linked page was independently read in full. HTTP failures were not
repeated merely to obtain a success. `entrance-audit.json` distinguishes full-page
inspection, indexed excerpts, failed retrieval and remaining current-client work.
