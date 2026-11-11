# Checkpoint 8BO — level46, container sources and shared direction safeguards

All60cases publication-researched/integrated: **60broad drops/allBoE/54Uncommon/fiveRare/oneEpic**. Source evidence: `checkpoint8bo_equipment_evidence.csv` and immutable `checkpoint8bo_working_evidence.json`. Historical pending fields are superseded by `checkpoint8bo_local_validation.json` and final `checkpoint8bo_validation.json`. No personal/current-build live availability or map rendering is claimed.

## Exact item and container findings

- [Six Demon Bag7734](https://www.wowhead.com/forever/item=7734): EpicBoE/equip46/item51, explicitly **Unique-Equipped**, not plain possessionUnique. Current item tooltip shows **30minute** use cooldown. Full [spell14537](https://www.wowhead.com/forever/spell=14537) independently lists the item. No acquired recipe/source, guaranteed effect distribution, three-minute item cooldown or measured current combat result is inferred from its use effect or another version.
- [Stonerender Gauntlets17007](https://www.wowhead.com/forever/item=17007): MailBoE/equip46/item51; published+20Strength/+11Stamina/+7Intellect/up to9magical damage **and healing**. Historical Spirit20/NatureResistance10 and old amounts are not substituted; stat/equip/class/armor/recipe logic is preserved.
- [Reinforced Locked Chest13918](https://www.wowhead.com/forever/item=13918): CommonLocked physical item55wrapper,55possible contents, **no origin list**. Do not infer fishing, vendor, NPC, school or opening skill from a similar name. Origin/opening/access gaps are retained in the shared list.
- [Heavy Junkbox16885](https://www.wowhead.com/forever/item=16885): Commonclass12/slot0/Locked/item50,35possible contents. Own tables:129kill/203pickpocket references. Three full actors independently corroborate each mode: kill examples6195Spitelash Siren/1787Skeletal Executioner/1789Skeletal Acolyte; pickpocket examples6004Cultist/6005Thug/6006Adept. These acquire the wrapper, not automatically every gear item inside. Exact current opening methods/threshold/costs remain unknown. No Rogue/lock-skill wearer gate; objective-of use is not a gear reward origin.

## AQ50 crate: keep source versions separate

[Ahn’Qiraj War Effort Supplies21513](https://www.wowhead.com/forever/item=21513): distinct CommonBoP/item50wrapper, structuredminimum50 without rendered Requires line,145possible contents. Fourteen full source quests and formal actors checked:

- Alliance:8499/8500 each20Thorium Bars;8509/8510 each20Arthas’ Tears;8522/8523 each20Runecloth Bandages. Each source minimum1 and rewards **10physical Alliance commendations plus one crate**, including More versions.
- Horde:8600/8601 each10Rugged Leather;8609/8610 each20Runecloth Bandages;8615/8616 each20Baked Salmon. Each source minimum1 and rewards **10physical Horde commendations plus one crate**, including More versions.
-8850Alliance/8855Horde: minimum50, **30physical commendation signets→one crate**. No additional commendation reward.

These are alternatives, not fourteen combined fees. Do not copy the older crate’s seven-commendation follow-ups or twenty-signet exchange. No explicit Repeatable label occurs on these full pages; More/raw flags do not prove current repeatability. Current phase/unlocks/NPC presence/opening/rolls remain unverified. Source faction/minimum1or50 and boxBoP do not replace equip46/BoE/class on possible gear; donation inputs are not new gear crafting ingredients. Full per-quest names, quantities, source NPCs and footprints are retained in runtime detailed guidance.

## Greater Darkmoon Prize: vendor currency versus legacy objective

[Greater Darkmoon Prize19296](https://www.wowhead.com/forever/item=19296):99possible contents/renderedRequires45/RightClicktoOpen. Its exact seller table and full [Gelvas Grimegate14828](https://www.wowhead.com/forever/npc=14828) inventory agree on **40currency515**, independently named [Darkmoon Prize Ticket](https://www.wowhead.com/forever/currency=515). No finite positive stock. Published Faire footprints: Elwynn41.4–41.6/68.8–69.0; Mulgore37.2/37.8. Neither establishes the current active camp or live inventory.

Full [quest7933](https://www.wowhead.com/forever/quest=7933), still titled40Tickets, minimum45/display60/Both, starts/ends with Gelvas and rewards one prize. It returns **no physical objective**, explicitly recording removal of the old40physical-ticket objective. Do not infer a current physical19182fee, free quest reward,80combined payment or current repeatability. Primary record differs from recycled Classic guides. Current quest cost/acceptance/unlocks and Faire timing remain open; a fixed prize is not guaranteed gear.

## Colossal Bag: provided delivery inputs and different turn-ins

[Colossal Bag of Loot21528](https://www.wowhead.com/forever/item=21528): BoPphysical/item60/structured51/no renderedRequires/134possible contents. Three independent full source quests, each minimum51/display60/Both, provide one husk and reward one bag:

| Quest | Published start, Silithus49.4–49.6/37.2 | Provided input | Published turn-in |
| --- | --- | --- | --- |
| [8857Ashi](https://www.wowhead.com/forever/quest=8857) | Nestor15798 | AshiHusk21534 | Oglethorpe7406, Stranglethorn28.2/76.2 |
| [8858Regal](https://www.wowhead.com/forever/quest=8858) | Eazel15799 | RegalHusk21535 | Oilfist14625, SearingGorge38.0–38.2/26.4–27.0 |
| [8859Zora](https://www.wowhead.com/forever/quest=8859) | Sophia15797 | ZoraHusk21533 | Tyrosus11034, EasternPlaguelands81.4–81.6/58.0 |

All six full formal NPC relations and each full input’s provided-for/objective-of relations agree. Husks are **provided**, not separately farmed boss drops. Three alternatives are not three required kills/husks. Earlier/current phase/unlocks/researcher presence remain unknown; start at the published researcher when available, not an invented boss farm. Money/reputation rewards are not payments or inferred summed reputation totals. InputUnique/maxcount restrictions and source51/BoP do not change gear equip46/BoE. Fixed bag reward does not guarantee a selected item.

## Shared navigation and source integrity

Verified currency names now flow from primary currency evidence into the shared model. The client’s valid localized currency name takes precedence; absent/empty API results use the published name, unknown IDs retain an honest numeric fallback. No new required retail API or hardcoded UI currency label/location. Quest directions display **Provided by quest** separately from **Required item**, preserving input meaning and avoiding false collection fees. Generator/runtime tests cover both safeguards. The single pin, source chooser, marker lifecycle, settings and character-only progress rules remain intact; generic random drops receive no misleading farm pin.

**190NPC/77object/103physical-container positive joins;44NPC/fiveobject/20container reverse omissions**. Object omissions:8113/9954/10075→ArenaChest179697(full158),10063/11989→SolidChest153453(full232). Container omissions: Cuergo9265(two),MithrilBoundTrunk21228(three),MithrilLockbox5758(five),AQ40crate21512(six),MysteriousLockbox19425(four). No assumed caps/current absence/retirement. Completed Arena, Kum’isha junk/sphere/defense, olderAQ, Nilith, Lard, egg/goodies, Cuergo keys, fishing and fortune contexts reused.

## Seventeen outside-scope cloak leads

Full new-container audit found seventeen Backslot16cloaks absent from active7707and the prior363candidate register: **8266,10098,10108,10120,10138,10148,10159,10174,10185,10212,10224,10231,10249,10258,10267,13007,13122**. All own pages independently agree with their full GreaterPrize/AQ50crate/ColossalBag references: **21positive source joins;15Uncommon/twoRare/allBoE/no published class/version/unavailable warning**. Existing363candidate rows are unchanged; register now **380unique candidates**, zero active adoptions. Full ALLslot/Back/eligibility/version/current-source validation remains pending; Clothsubclass does not impose caster-only cloak eligibility. Deduplicate with the known omitted-cloak issue during that audit. Evidence is in `checkpoint8bo_candidate_scope_review.json` and the existing candidate CSV, not a disconnected research list.

## Validation and continuation

**150checkpoint primary responses:121new/29cached** (including17candidate own pages);288with completed retained context:121new/167cached.60exact-ID/name queries/fourshared queries; zero new failed reads/127known failed URLs not retried.18new full quests/**35formal actor joins, all positive**. Source URLs/fingerprints/discrepancies retained; secondary Classic/client/event claims are not live evidence.

Final unchanged **8bo3reconciliationexit0/eightactualHTTPfingerprints**, after wording and candidate supplement. Earlier8bo/8bo2also succeeded; captures are separate, no replay/failure/retry claim. **19final localPASS**:15Lua/threeofflinePython/required-files/syntax26modules/fourPython tools/Lua exporter. Actual generated515name and all three provided-husk flags also checked. New price/input tests plus all map/guide/quest/vendor/ACA/dungeon/rare/random/incomplete-source regressions pass; actual rendering remains manual.

Playfulls **23,605items/9,246definitions**: every raw row/name/fullsource/metadata/display/acquisition fact exact actual8BN. Everloot **1,672raw/1,431qualifying**: every relation/field exact actual8BNlocal. Zero new/removed/updated/selected/opaque changes; factual diagnostic snapshots unchanged, no duplicate diagnostic fetch/fallback. All4,996prior gear objects/954recipes/eightcompanionCSVs/supplementary craft metadata unchanged;15listed unchanged companion/snapshot files checked, candidate extension explicitly reviewed. Exactly60additive-summary cells change.

Registry **5,056/index6,527/display6,526/bookIDs759**. Catalogue **7,707identities/36,341classobjectives/1,254crafts/4,857ingredients** and all filters/settings preserved. Frozen5688=**4,842publication-researched+846pending**, approximately85%of that queue only;380outside candidates separate. Navigation **682point-data/1,275directions/3,172missing/2,578not applicable**, **6,758overlapping gaps**, rendering verified0.

Next: complete18PASS non-release CI/directbot review, then **8BP:all51pendinglevel47cases,numeric item-ID order**, markedqueue. Before final validation, audit newly encountered full containers for outside gear and validate/register leads; check existing completed metadata (`bookItemID` for books) and cached sources before extra research. Reuse these new contexts.380candidates/ALLslotBackThrown/knownomittedcloaks/sixdungeonexceptions/954current-livebooks/manualmap/finalintegrity remain. One existing automation/sameworker;no main/Beta8/build/package/tag/release/billing changes.
