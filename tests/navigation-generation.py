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
    assert any(g["gap"] == "quest_chain_relationships_unverified" for g in gaps)
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
        "itemID": 2, "navigationRoutes": [{"kind": "crafting_requirement", "source": "npc:100", "instructions": "Fixture special forge"}]}]))
    future = nav.build(gear)[0]
    assert future["items"]["2"]["routes"][0]["kind"] == "crafting_requirement", "future reviewed special locations use the same registry/model"
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

print("PASS navigation generation: future evidence propagation, source deduplication, no fake centroids/random farms/prerequisites, partial/disputed evidence remains unresolved")
