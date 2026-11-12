#!/usr/bin/env python3
"""Offline proof-boundary checks, including how newly researched data propagates."""
import importlib.util
import csv
import json
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("navigation", ROOT / "tools/build_acquisition_navigation.py")
nav = importlib.util.module_from_spec(spec)
spec.loader.exec_module(nav)

with tempfile.TemporaryDirectory() as temp:
    nav.REPORT = Path(temp)
    for filename in ["reviewed_equipment_sources.json", "reviewed_recipe_sources.json"]:
        (nav.REPORT / filename).write_text("[]")
    for filename in ["dungeon_items_reconciled.csv", "remaining_equipment_research_queue.csv"]:
        (nav.REPORT / filename).write_text("itemID\n")
    gear = {"1": dict(itemID=1, name="Vendor fixture", sourceType="Vendor", eligibility=[511]),
            "2": dict(itemID=2, name="World fixture", sourceType="World drop", eligibility=[511]),
            "3": dict(itemID=3, name="Quest fixture", sourceType="Quest", eligibility=[511])}
    def response(kind, entity_id, **facts):
        return dict(url=f"https://www.wowhead.com/forever/{kind}={entity_id}", sha256="a" * 64, **facts)
    proof = {"items": [response("item", 1, lists={"sold-by": [{"id": 100, "name": "Vendor"}]}),
                        response("item", 2, lists={"dropped-by": [{"id": 100, "name": "Random sample"}]})],
             "quests": [response("quest", 10, quest={"name": "Quest", "itemrewards": [[3, 1]]},
                                 objectiveZone="Westfall", objectiveSource="npc:100", objectiveInstructions="Published delivery objective.",
                                 seriesQuestIDs=[11], objectiveMapper={"objectives": {"40": {
                                     "zone": "Westfall", "levels": [[{"type": 1, "id": 100, "name": "Vendor", "point": "start", "coord": [20, 30]}]]}}})]}
    path = nav.REPORT / "checkpoint_test_evidence.json"
    path.write_text(json.dumps(proof))
    data, coverage, gaps, _ = nav.build(gear)
    assert coverage[0]["status"] == "verified_coordinate_data"
    assert data["quests"]["10"]["objectiveInstructions"]=="Published delivery objective." and data["quests"]["10"]["objectiveSource"]=="npc:100" and data["quests"]["10"]["objectiveZone"]=="Westfall", "future full quest objective guidance shares the same generated model"
    assert "2" not in data["items"], "one random loot table sample cannot establish a named farm"
    assert not data["chains"], "see-also/series IDs cannot become mandatory prerequisite edges"
    (nav.REPORT / "reviewed_equipment_sources.json").write_text(json.dumps([{
        "itemID": 2, "originUnknown": True, "confidence": "published-reference-origin-unverified"}]))
    unknown, unknown_coverage, unknown_gaps, _ = nav.build(gear)
    assert "2" not in unknown["items"], "an unknown source must not acquire a random loot sample pin"
    assert unknown_coverage[1]["status"] == "missing", "unknown origin is a research gap, not inapplicable navigation"
    assert any(g["itemID"] == 2 and g["gap"] == "actionable_location_missing" for g in unknown_gaps)
    (nav.REPORT / "reviewed_equipment_sources.json").write_text("[]")
    assert any(g["gap"] == "quest_chain_relationships_unverified" for g in gaps)
    (nav.REPORT / "navigation_quest_chains.json").write_text(json.dumps({"10": {"steps": [10], "routeVerified": True, "prerequisitesVerified": False}}))
    assert any(g["gap"]=="quest_chain_relationships_unverified" for g in nav.build(gear)[2]), "known travel order must not erase unverified prerequisite research"
    (nav.REPORT / "navigation_quest_chains.json").unlink()
    assert data == nav.build(gear)[0], "offline results must be deterministic"
    # A future research checkpoint expands the same source without UI/item special cases.
    proof["actors"] = [response("npc", 100, name="Vendor", maps={"40": [{
        "uiMapName": "Westfall", "uiMapId": 52, "coords": [[20, 30], [50, 60]]}]})]
    path.write_text(json.dumps(proof))
    data, coverage, gaps, _ = nav.build(gear)
    locations = data["sources"]["npc:100"]["locations"]
    assert len(locations) == 1 and "x" not in locations[0], "never turn a roaming footprint into a fake precise centroid"
    assert locations[0]["bounds"] == dict(xMin=20, xMax=50, yMin=30, yMax=60)
    assert coverage[0]["status"] == "directions"
    (nav.REPORT / "reviewed_equipment_sources.json").write_text(json.dumps([{
        "itemID": 2, "navigationRoutes": [{"kind": "crafting_requirement", "source": "npc:100", "instructions": "Fixture special forge"}],
        "navigationResearchGaps": [{"gap": "container_quest_relationships_unverified", "sourceID": "item:900", "questID": 999, "detail": "Fixture unresolved prerequisite relationship"}]}]))
    future = nav.build(gear)[0]
    assert future["items"]["2"]["routes"][0]["kind"] == "crafting_requirement", "future reviewed special locations use the same registry/model"
    assert any(g["sourceID"]=="item:900" and g["questID"]==999 for g in nav.build(gear)[2]), "indirect container quest gaps stay in shared acquisition research tracking"
    (nav.REPORT / "reviewed_equipment_sources.json").write_text("[]")
    proof["actors"].append(response("object", 700, name="Chest fixture", maps={"40": [{"uiMapName": "Westfall", "coords": [[20, 30]]}]}))
    proof["items"].append(response("item", 3, lists={"contained-in-object": [{"id": 700, "name": "Chest fixture"}]}))
    path.write_text(json.dumps(proof))
    (nav.REPORT / "reviewed_equipment_sources.json").write_text(json.dumps([{
        "itemID": 3, "navigationRoutes": [{"kind": "object", "source": "object:700", "instructions": "Published key context"}]}]))
    shared = [r for r in nav.build(gear)[0]["items"]["3"]["routes"] if r["kind"]=="object"]
    assert len(shared)==1 and shared[0]["instructions"]=="Published key context", "typed unlock context and primary object relation share one destination"
    (nav.REPORT / "reviewed_equipment_sources.json").write_text("[]")
    proof["items"][0]["crossVersionWarning"] = True
    path.write_text(json.dumps(proof))
    assert "1" not in nav.build(gear)[0]["items"], "disputed versions must not produce a pin"
    (nav.REPORT / "checkpoint_future_partial_evidence.json").write_text(json.dumps({"items": {"2": {
        "relations": {"contained-in-object": [{"id": 700}]}}}}))
    _, coverage, _, _ = nav.build(gear)
    assert coverage[1]["status"] == "missing", "unfinished research is a gap, not a verified route"
    assert not nav.coordinate(True) and not nav.coordinate(-1) and not nav.coordinate(101)
    assert "\\u0001" not in nav.lua("\1"), "generated Lua must use Lua 5.1 escapes"
    (nav.REPORT / "dungeon_items_reconciled.csv").write_text("itemID,dungeon,reconciledRole\n1,Dungeon pattern drops — exact boss unconfirmed,crafted-pattern\n")
    gear["1"]["profession"]="Fixture profession"
    unresolved=nav.build(gear)
    assert not any(r["kind"]=="dungeon" for p in unresolved[0]["items"].values() for r in p["routes"]), "generic dungeon label is not a navigable entrance"
    gear["4"] = dict(itemID=4, name="Fishing fixture", sourceType="World drop", eligibility=[511])
    proof["items"].append(response("item", 4, lists={"fished-in": [{"id": 40, "name": "Westfall"}]}))
    proof["items"][1]["lists"]["fished-in"]=[{"id": 40, "name": "Westfall"}]
    path.write_text(json.dumps(proof))
    fish=nav.build(gear)[0]
    assert fish["items"]["4"]["routes"][0]["kind"]=="fishing" and "x" not in fish["sources"]["zone:40"]["locations"][0]
    assert "2" not in fish["items"], "incidental fishing must not give broad random enemy drops a destination"
    proof["currencies"] = [response("currency", 515, title="Darkmoon Prize Ticket - Currency - Forever")]
    path.write_text(json.dumps(proof))
    currency = nav.build(gear)[0]["currencies"]["515"]
    assert currency["name"] == "Darkmoon Prize Ticket" and currency["verification"] == "published-reference"
    assert currency["evidence"]["url"].endswith("currency=515"), "future currency labels retain primary proof without hardcoded UI names"
    proof["quests"][0]["requiredPhysicalItems"] = [{"itemID": 1000, "name": "Provided husk", "quantity": 1, "provided": True}]
    path.write_text(json.dumps(proof))
    assert nav.build(gear)[0]["quests"]["10"]["requiredItems"][0]["provided"] is True, "source-provided items retain their meaning through generation"
    (nav.REPORT / "reviewed_equipment_sources.json").write_text(json.dumps([{
        "itemID": 2, "originUnknown": True, "navigationRoutes": [{"kind": "named_drop", "source": "npc:100",
        "directionsOnly": True, "verification": "legacy-reference", "instructions": "Historical source; current acquisition unverified."}]}]))
    written, coverage, gaps, _ = nav.build(gear)
    assert written["items"]["2"]["routes"][0]["directionsOnly"] is True
    assert coverage[1]["status"] == "directions", "withheld markers cannot count as working point navigation even when coordinates exist"
    assert any(g["itemID"]==2 and g["gap"]=="map_target_withheld" for g in gaps)
    reviewed = json.loads((nav.REPORT / "reviewed_equipment_sources.json").read_text())
    del reviewed[0]["navigationRoutes"][0]["directionsOnly"]
    (nav.REPORT / "reviewed_equipment_sources.json").write_text(json.dumps(reviewed))
    assert nav.build(gear)[0]["items"]["2"]["routes"][0]["directionsOnly"] is True, "legacy verification itself must withhold a current marker"
    proof["items"].append(response("item", 900, selectedContains=[{"id": 2, "name": "World fixture"}]))
    proof["quests"][0]["quest"]["itemrewards"] = [[900, 1]]
    proof["quests"][0]["quest"]["reqlevel"] = 50
    path.write_text(json.dumps(proof))
    (nav.REPORT / "reviewed_equipment_sources.json").write_text(json.dumps([{
        "itemID": 2, "navigationRoutes": [{"kind": "quest_container", "questID": 10, "containerItemID": 900,
        "instructions": "One possible content; current quest access and rolls unverified."}]}]))
    container, coverage, _, _ = nav.build(gear)
    assert container["items"]["2"]["routes"][0]["kind"] == "quest_container"
    assert container["items"]["2"]["category"] == "world_drop", "a container alternative must not turn the equipment into a direct quest reward"
    assert container["quests"]["10"]["reqlevel"] == 50 and coverage[1]["status"] == "directions"
    assert "npc:100" in container["sources"], "indirect quest actors must survive source pruning"
    reviewed = json.loads((nav.REPORT / "reviewed_equipment_sources.json").read_text())
    reviewed[0]["navigationRoutes"][0]["directionsOnly"] = True
    (nav.REPORT / "reviewed_equipment_sources.json").write_text(json.dumps(reviewed))
    withheld, _, withheld_gaps, _ = nav.build(gear)
    assert withheld["items"]["2"]["routes"][0]["directionsOnly"] is True
    assert any(g["itemID"] == 2 and g["gap"] == "map_target_withheld" for g in withheld_gaps), "disputed quest-container locations must retain written-only policy"
    del reviewed[0]["navigationRoutes"][0]["directionsOnly"]
    (nav.REPORT / "reviewed_equipment_sources.json").write_text(json.dumps(reviewed))
    proof["items"][-1]["selectedContains"] = [{"id": 999}]
    path.write_text(json.dumps(proof))
    assert not any(r["kind"] == "quest_container" for r in nav.build(gear)[0].get("items", {}).get("2", {}).get("routes", [])), "the full wrapper must contain this exact equipment ID"
    assert nav.build(gear)[1][1]["status"] == "missing", "a failed authored source is missing evidence, not inapplicable navigation"
    proof["items"][-1]["selectedContains"] = [{"id": 2}]
    proof["items"][0]["lists"]["reward-from-q"] = [{"id": 10, "itemrewards": [[900, 1]]}]
    del proof["quests"][0]["quest"]["itemrewards"]
    path.write_text(json.dumps(proof))
    assert "2" not in nav.build(gear)[0]["items"], "a wrapper's quest summary plus a full-page header is not an independently projected full quest reward"
    proof["quests"][0]["quest"]["itemrewards"] = [[900, 1]]
    proof["items"][-1]["crossVersionWarning"] = True
    path.write_text(json.dumps(proof))
    assert "2" not in nav.build(gear)[0]["items"], "a disputed wrapper must not establish a current container route"
    proof["items"].append(response("item", 901, identity={"name": "Starter document"}, lists={"starts": [{"id": 10}]}))
    proof["quests"][0]["starterZone"] = "Westfall"
    proof["quests"][0]["starterInstructions"] = "Obtain and read the starting document; current unlocks unverified."
    path.write_text(json.dumps(proof))
    starter = nav.build(gear)[0]["quests"]["10"]
    assert starter["starterItems"][0]["itemID"] == 901 and starter["starterZone"] == "Westfall"
    proof["items"][-1]["lists"] = {"provided-for": [{"id": 10}]}
    path.write_text(json.dumps(proof))
    assert "starterItems" not in nav.build(gear)[0]["quests"]["10"], "a provided quest input is not necessarily a quest-starting item"
    gear["5"] = dict(itemID=5, name="Unnamed-map chest fixture", sourceType="Chest", eligibility=[511])
    proof["items"].append(response("item", 5, lists={"contained-in-object": [{"id": 902}]}))
    proof["actors"].append(response("object", 902, name="Unknown-map chest",
                                    lists={"contains": [{"id": 5, "name": "Unnamed-map chest fixture"}]},
                                    maps={"1583": [{"coords": [[0, 0]]}]}))
    path.write_text(json.dumps(proof))
    unnamed, coverage, _, _ = nav.build(gear)
    assert not unnamed["sources"]["object:902"]["locations"] and coverage[-1]["status"] == "missing", "anonymous 0,0 rows without a map namespace are unresolved, not verified coordinates"

with tempfile.TemporaryDirectory() as temp:
    nav.REPORT = Path(temp)
    (nav.REPORT / "reviewed_recipe_sources.json").write_text("[]")
    for filename in ["dungeon_items_reconciled.csv", "remaining_equipment_research_queue.csv"]:
        (nav.REPORT / filename).write_text("itemID\n")
    (nav.REPORT / "reviewed_equipment_sources.json").write_text(json.dumps([{
        "itemID": 2, "navigationRoutes": [{"kind": "vendor_container", "source": "npc:100", "containerItemID": 900,
        "instructions": "Recover the receipt book to unlock the shop; random contents and current stock unverified."}]}]))
    gear = {"2": dict(itemID=2, name="Random gear", sourceType="World drop", eligibility=[511])}
    proof = {"items": [response("item", 900, selectedContains=[{"id": 2}],
                              relations={"sold-by": [{"id": 100, "name": "Vendor"}]})],
             "actors": [response("npc", 100, name="Vendor",
                                 maps={"40": [{"uiMapName": "Westfall", "uiMapId": 52, "coords": [[20, 30]]}]},
                                 selectedSells=[{"id": 900, "avail": 1, "cost": [[72000, [], []]]}])]}
    path = nav.REPORT / "checkpoint_test_evidence.json"
    path.write_text(json.dumps(proof))
    data, coverage, _, _ = nav.build(gear)
    route = data["items"]["2"]["routes"][0]
    assert route["kind"] == "vendor_container" and route["offer"]["avail"] == 1
    assert data["items"]["2"]["category"] == "world_drop", "buying a random container does not make the gear direct vendor stock"
    assert "npc:100" in data["sources"] and coverage[0]["status"] == "verified_coordinate_data"
    # Store the researched wrapper destination once; future gear needs no
    # per-item navigation record or duplicated vendor/quest instructions.
    proof["items"][0]["containerNavigationRoutes"] = [{
        "kind": "vendor_container", "source": "npc:100", "instructions": "Unlock the shop first; random contents."}]
    (nav.REPORT / "reviewed_equipment_sources.json").write_text("[]")
    path.write_text(json.dumps(proof))
    assert nav.build(gear)[0]["items"]["2"]["routes"][0]["kind"] == "vendor_container"
    saved_sales = proof["actors"][0].pop("selectedSells")
    path.write_text(json.dumps(proof))
    data, coverage, gaps, _ = nav.build(gear)
    assert "2" not in data["items"] and coverage[0]["status"] == "missing"
    assert any(g["gap"] == "container_vendor_relation_unverified" for g in gaps), "a seller summary plus NPC header cannot prove a full vendor inventory"
    proof["actors"][0]["selectedSells"] = saved_sales
    proof["items"][0]["selectedContains"] = [{"id": 999}]
    path.write_text(json.dumps(proof))
    assert "2" not in nav.build(gear)[0]["items"], "the exact gear must be in the full wrapper"
    proof["items"][0]["selectedContains"] = [{"id": 2}]
    proof["items"][0]["crossVersionWarning"] = True
    path.write_text(json.dumps(proof))
    assert "2" not in nav.build(gear)[0]["items"], "a disputed wrapper does not establish a current container vendor route"
    proof["items"][0]["crossVersionWarning"] = False
    proof["items"][0]["containerNavigationRoutes"] = [{"kind": "npc_container", "source": "npc:100"}]
    proof["items"][0]["relations"] = {"dropped-by": [{"id": 100, "classicEra": 1}]}
    proof["actors"][0]["selectedDrops"] = [{"id": 900, "classicEra": 1}]
    path.write_text(json.dumps(proof))
    npc, coverage, _, _ = nav.build(gear)
    route = npc["items"]["2"]["routes"][0]
    assert route["kind"] == "npc_container" and route["verification"] == "legacy-reference" and route["directionsOnly"]
    assert coverage[0]["status"] == "directions", "a precise NPC point cannot turn Classic-only container loot into a current farm marker"
    proof["actors"][0].pop("selectedDrops")
    path.write_text(json.dumps(proof))
    assert "2" not in nav.build(gear)[0]["items"], "an origin summary plus NPC header cannot prove a full NPC inventory"
    proof["actors"][0]["selectedDrops"] = [{"id": 900}]
    proof["items"][0]["selectedContains"] = [{"id": 999}]
    path.write_text(json.dumps(proof))
    assert "2" not in nav.build(gear)[0]["items"], "the exact full NPC-dropped wrapper must contain the equipment"
    proof["items"][0]["selectedContains"] = [{"id": 2}]
    proof["items"][0]["crossVersionWarning"] = True
    path.write_text(json.dumps(proof))
    assert "2" not in nav.build(gear)[0]["items"], "disputed NPC-dropped wrappers remain unresolved"

with tempfile.TemporaryDirectory() as temp:
    nav.REPORT = Path(temp)
    for filename in ["reviewed_equipment_sources.json", "reviewed_recipe_sources.json"]:
        (nav.REPORT / filename).write_text("[]")
    for filename in ["dungeon_items_reconciled.csv", "remaining_equipment_research_queue.csv"]:
        (nav.REPORT / filename).write_text("itemID\n")
    gear = {"2": dict(itemID=2, name="Crafted fixture", sourceType="Crafting",
                     profession="Blacksmithing", recipePatternItemID=900, eligibility=[511])}
    quest_url = "https://www.wowhead.com/forever/quest=10"
    proof = {"legacy": {"sourceURL": quest_url, "sha256": "a"*64,
                       "questDetails": {"id": 10, "name": "Saved recipe quest", "reqlevel": 50, "side": 3,
                                        "itemrewards": [[900, 1]]}},
             "actors": [response("npc", 100, name="Saved actor",
                                mapper={"40": [{"uiMapName": "Westfall", "uiMapId": 52, "coords": [[20, 30]]}]})]}
    path = nav.REPORT / "checkpoint_test_evidence.json"
    reference = dict(itemID=2, bookItemID=900, questID=10, questURL=quest_url, questPageSHA256="a"*64,
                     startKind="npc", startID=100, startName="Saved actor", endKind="npc", endID=100, endName="Saved actor")
    def save_reference():
        with (nav.REPORT / "checkpoint_test_quest_references.csv").open("w", newline="") as handle:
            writer = csv.DictWriter(handle, fieldnames=list(reference))
            writer.writeheader()
            writer.writerow(reference)
    path.write_text(json.dumps(proof))
    save_reference()
    restored, coverage, _, _ = nav.build(gear)
    assert restored["quests"]["10"]["starts"] == ["npc:100"] and restored["quests"]["10"]["ends"] == ["npc:100"]
    assert coverage[0]["status"] == "verified_coordinate_data" and restored["items"]["2"]["category"] == "crafting"
    reference["questPageSHA256"] = "b"*64
    save_reference()
    assert "2" not in nav.build(gear)[0]["items"], "a mismatched saved page fingerprint cannot create a source"
    reference["questPageSHA256"] = "a"*64
    reference["bookItemID"] = 999
    save_reference()
    assert "2" not in nav.build(gear)[0]["items"], "the exact book must be a full legacy quest reward"
    reference["bookItemID"] = 900
    save_reference()
    proof["current"] = response("quest", 10, quest={"id": 10, "name": "Current quest", "itemrewards": [[999, 1]]},
                                actors=[{"id": 200, "name": "Current actor", "point": "start", "type": 1}])
    path.write_text(json.dumps(proof))
    current = nav.build(gear)[0]
    assert "2" not in current["items"] and current["quests"]["10"]["starts"] == ["npc:200"], "current full metadata/actors must retain precedence"
    del proof["current"]
    reference.update(startKind="item", startID=901, startName="Starting volume")
    save_reference()
    proof["startingItems"] = [{"itemID": 901, "name": "Starting volume",
                              "hashes": {"https://www.wowhead.com/forever/item=901": "c"*64,
                                         "https://www.wowhead.com/forever/item=901&xml": "d"*64},
                              "tables": {"starts": [{"id": 10}], "provided-for": [{"id": 10}]}}]
    proof["legacy"]["requiredPhysicalItems"] = [{"itemID": 901, "name": "Starting volume", "quantity": 1, "provided": True}]
    path.write_text(json.dumps(proof))
    starter, coverage, _, _ = nav.build(gear)
    q = starter["quests"]["10"]
    assert q["starterItems"][0]["itemID"] == 901 and q["requiredItems"][0]["startsQuest"]
    assert not q["starts"] and q["ends"] == ["npc:100"] and q["starterOriginUnresolved"]
    assert coverage[0]["status"] == "missing", "a known turn-in does not resolve the first destination for an item-started quest"

with tempfile.TemporaryDirectory() as temp:
    nav.REPORT = Path(temp)
    for filename in ["reviewed_recipe_sources.json", "reviewed_equipment_sources.json"]:
        (nav.REPORT / filename).write_text("[]")
    for filename in ["dungeon_items_reconciled.csv", "remaining_equipment_research_queue.csv"]:
        (nav.REPORT / filename).write_text("itemID\n")
    gear = {"1": dict(itemID=1, name="Raid gear", sourceType="World drop", eligibility=[511]),
            "2": dict(itemID=2, name="Chest gear", sourceType="Chest", eligibility=[511]),
            "3": dict(itemID=3, name="Vendor gear", sourceType="Vendor", eligibility=[511])}
    def page(kind, entity, **facts):
        return dict(url=f"https://www.wowhead.com/forever/{kind}={entity}", sha256="a"*64, **facts)
    proof = dict(
        zones=[page("zone", 9000, title="Fixture raid - Zone - WoW Forever",
                    zone=dict(id=9000, name="Fixture raid", instanceType="Raid"),
                    markup=["[ul][li]Instance type: Raid[/li][/ul]"])],
        actors=[page("npc", 100, title="Raid source - NPC - Forever",
                     lists={"drops": [dict(id=1, name="Raid gear")]},
                     maps={"9000": [dict(uiMapName="Fixture raid", uiMapId=999, coords=[[20,30]])]}),
                page("object", 200, title="Chest - Object - Forever",
                     lists={"contains": [dict(id=2, name="Chest gear")]},
                     maps={"40": [dict(uiMapName="Westfall", uiMapId=52, coords=[[20,30]])]}),
                page("npc", 300, title="Vendor - NPC - Forever",
                     lists={"sells": [dict(id=3,name="Vendor gear",cost=[[12345,[],[]]])]},
                     maps={"40": [dict(uiMapName="Westfall",uiMapId=52,coords=[[20,30]])]})],
        items=[page("item", 1, identity=dict(id=1,name="Raid gear"),
                    lists={"dropped-by": [dict(id=100,name="Raid source")]}),
               page("item", 2, identity=dict(id=2,name="Chest gear"),
                    lists={"contained-in-object": [dict(id=200,name="Chest")]}),
               page("item", 3, identity=dict(id=3,name="Vendor gear"),
                    lists={"sold-by": [dict(id=300,name="Vendor")]})])
    evidence_path = nav.REPORT / "checkpoint_raid_evidence.json"
    reviewed = [dict(itemID=1, originUnknown=True, confidence="published-forever-named-enemy-reference", navigationRoutes=[
        dict(kind="named_drop", source="npc:100", requiresFullLootJoin=True)]),
        dict(itemID=3,navigationRoutes=[dict(kind="vendor",source="npc:300",requiresFullSaleJoin=True,
            sourceSide=1,sourceRequirements=["Requires Silverwing Sentinels - Exalted"])])]
    reviewed_path = nav.REPORT / "reviewed_equipment_sources.json"
    reviewed_path.write_text(json.dumps(reviewed))
    def generate():
        evidence_path.write_text(json.dumps(proof))
        return nav.build(gear)
    data, coverage, _, _ = generate()
    assert data["instances"]["Fixture raid"] and data["instanceDetails"]["Fixture raid"]["areaID"]==9000
    assert coverage[0]["status"]=="directions", "instance actor coordinates are not verified world entrance coordinates"
    assert coverage[1]["status"]=="verified_coordinate_data", "full object contents and exact own reference can establish a destination"
    vendor=data["items"]["3"]["routes"][0]
    assert vendor["offer"]["side"]==1 and vendor["sourceRequirements"]==["Requires Silverwing Sentinels - Exalted"]
    assert vendor["offer"]["cost"]==[[12345,[],[]]] and data["items"]["3"]["category"]=="vendor"
    proof["actors"][2]["lists"]["sells"]=[]
    assert "3" not in generate()[0]["items"], "an authored full vendor join cannot fall through to a one-sided seller pin"
    proof["actors"][2]["lists"]["sells"]=[dict(id=3,name="Different version")]
    assert "3" not in generate()[0]["items"], "a different-name vendor row is not this exact equipment"
    proof["actors"][2]["lists"]["sells"]=[dict(id=3,name="Vendor gear",cost=[[12345,[],[]]])]
    proof["actors"][0]["lists"]["drops"]=[]
    data, coverage, gaps, _=generate()
    assert "1" not in data["items"] and coverage[0]["status"]=="missing"
    assert any(g["itemID"]==1 and g["gap"]=="full_loot_join_unverified" for g in gaps)
    proof["actors"][0]["lists"]["drops"]=[dict(id=1,name="Different version")]
    assert "1" not in generate()[0]["items"], "a same-ID different-name full row cannot establish this exact gear"
    proof["actors"][0]["lists"]["drops"]=[dict(id=1,name="Raid gear")]
    proof["items"][0]["lists"]["dropped-by"][0]["classicEra"]=1
    reviewed[0]["navigationRoutes"][0]["entranceOnly"]=True
    reviewed_path.write_text(json.dumps(reviewed))
    route=generate()[0]["items"]["1"]["routes"][0]
    assert route["verification"]=="legacy-reference" and route["directionsOnly"], "an authored full-join route cannot promote a Classic item-side reference to a current farm"
    assert route["entranceOnly"], "a separately verified instance can offer native entrance geography while retaining legacy loot qualification"
    proof["actors"][1]["lists"]["contains"]=[]
    assert "2" not in generate()[0]["items"], "a one-sided object reference is missing evidence, not implemented navigation"
    reviewed.append(dict(itemID=2, navigationRoutes=[dict(kind="object",source="object:200",requiresFullLootJoin=True)]))
    reviewed_path.write_text(json.dumps(reviewed))
    assert "2" not in generate()[0]["items"], "failed authored full contents cannot fall through to a weaker automatic object pin"
    proof["actors"][1]["lists"]["contains"]=[dict(id=2,name="Chest gear",classicEra=1)]
    data, coverage, _, _=generate()
    assert data["items"]["2"]["routes"][0]["directionsOnly"] and coverage[1]["status"]=="directions"
    reviewed[2]["navigationRoutes"][0]["directionsOnly"]=True
    reviewed_path.write_text(json.dumps(reviewed))
    assert len(generate()[0]["items"]["2"]["routes"])==1, "automatic object discovery must preserve an authored withheld marker"
    proof["zones"][0]["zone"]["id"]=9001
    data, _, gaps, _=generate()
    assert "Fixture raid" not in data["instances"], "zone URL, identity, name and primary instance quickfacts must agree"
    assert any(g["gap"]=="instance_definition_unverified" for g in gaps)
    assert not data["items"]["1"]["routes"][0].get("entranceOnly"), "new entrance hints cannot bypass missing instance definitions"
    proof["zones"][0]["zone"].update(id=9000,instanceType="Dungeon")
    proof["zones"][0]["markup"]=["[ul][li]Instance type: Dungeon[/li][/ul]"]
    assert generate()[0]["instanceDetails"]["Fixture raid"]["kind"]=="dungeon", "future verified dungeon evidence uses the same model as raids"
    gear["4"]=dict(itemID=4,name="Crafted gear",sourceType="Crafted",profession="Blacksmithing",recipePatternItemID=900,eligibility=[511])
    proof["items"].append(page("item",900,identity=dict(id=900,name="Plans: Fixture"),lists={"sold-by":[dict(id=300,name="Vendor")]}))
    proof["actors"][2]["lists"]["sells"].append(dict(id=900,name="Plans: Fixture",cost=[[100,[],[]]]))
    (nav.REPORT / "reviewed_recipe_sources.json").write_text(json.dumps([dict(itemID=4,navigationRoutes=[
        dict(kind="recipe_vendor",source="npc:300",requiresFullSaleJoin=True,sourceRequirements=["Published vendor unlock"])])]))
    recipe=generate()[0]["items"]["4"]["routes"][0]
    assert recipe["kind"]=="recipe_vendor" and recipe["bookItemID"]==900 and recipe["sourceRequirements"]==["Published vendor unlock"]
    proof["actors"][2]["lists"]["sells"][-1]["name"]="Crafted gear"
    assert not any(r.get("source")=="npc:300" for r in generate()[0]["items"].get("4",{}).get("routes",[])), "recipe navigation requires the exact book, not the finished equipment in a vendor row"
    zero=nav.Evidence().location("Fixture raid",9000,{"uiMapId":999,"coords":[[0,0]]})
    assert zero["zone"]=="Fixture raid" and "x" not in zero and "bounds" not in zero, "published 0,0 placeholders retain zone context without becoming a floor or entrance point"

print("PASS navigation generation: future evidence propagation, source deduplication, no fake centroids/random farms/prerequisites, partial/disputed evidence remains unresolved")
