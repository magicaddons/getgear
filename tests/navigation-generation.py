#!/usr/bin/env python3
"""Offline proof-boundary checks, including how newly researched data propagates."""
import importlib.util
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
                                 seriesQuestIDs=[11], objectiveMapper={"objectives": {"40": {
                                     "zone": "Westfall", "levels": [[{"type": 1, "id": 100, "name": "Vendor", "point": "start", "coord": [20, 30]}]]}}})]}
    path = nav.REPORT / "checkpoint_test_evidence.json"
    path.write_text(json.dumps(proof))
    data, coverage, gaps, _ = nav.build(gear)
    assert coverage[0]["status"] == "verified_coordinate_data"
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
    proof["actors"].append(response("object", 902, name="Unknown-map chest", maps={"1583": [{"coords": [[0, 0]]}]}))
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

print("PASS navigation generation: future evidence propagation, source deduplication, no fake centroids/random farms/prerequisites, partial/disputed evidence remains unresolved")
