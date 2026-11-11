#!/usr/bin/env python3
"""Build shared navigation from committed acquisition evidence. No network or item mutations."""
from __future__ import annotations

import argparse
import collections
import csv
import hashlib
import json
import re
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPORT = ROOT / "docs/source-audit-1-60/reconciliation-20261109"
CLASSES = ["PRIEST", "MAGE", "WARLOCK", "DRUID", "ROGUE", "HUNTER", "SHAMAN", "WARRIOR", "PALADIN"]
ENTITY = re.compile(r"/(?:forever/)?(npc|object|quest|item)(?:=|/)(\d+)")


def lua(value):
    if value is None:
        return "nil"
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        return repr(value)
    if isinstance(value, str):
        # WoW uses Lua 5.1 string escapes, not JSON's \uXXXX syntax.
        encoded = json.dumps(value, ensure_ascii=False)
        return re.sub(r"\\u([0-9a-fA-F]{4})", lambda m: "\\%03d" % int(m[1], 16), encoded)
    if isinstance(value, list):
        return "{" + ",".join(lua(x) for x in value) + "}"
    return "{" + ",".join("[" + lua(k) + "]=" + lua(v) for k, v in sorted(value.items(), key=lambda x: str(x[0]))) + "}"


def read_csv(path):
    with path.open(encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle))


def rows(value):
    return value if isinstance(value, list) else []


def coordinate(value):
    return isinstance(value, (int, float)) and not isinstance(value, bool) and 0 <= value <= 100


class Evidence:
    def __init__(self):
        self.sources = {}
        self.quests = {}
        self.items = collections.defaultdict(dict)
        self.maps = collections.defaultdict(set)
        self.inputs = []

    def location(self, zone, area_id=None, raw=None):
        raw = raw or {}
        if not isinstance(zone, str) or not zone:
            return None
        result = {"zone": zone, "verification": "published-reference"}
        if area_id is not None:
            try:
                result["areaID"] = int(area_id)
            except (ValueError, TypeError):
                pass
        map_id = raw.get("uiMapId", raw.get("uiMapID"))
        if isinstance(map_id, int) and map_id > 0:
            result["uiMapID"] = map_id
            self.maps[zone].add(map_id)
        points = [p for p in rows(raw.get("coords")) if isinstance(p, list) and len(p) >= 2 and coordinate(p[0]) and coordinate(p[1])]
        bounds = raw.get("bounds")
        if points:
            bounds = dict(xMin=min(x[0] for x in points), xMax=max(x[0] for x in points),
                          yMin=min(x[1] for x in points), yMax=max(x[1] for x in points))
        if isinstance(bounds, dict) and all(coordinate(bounds.get(k)) for k in ["xMin", "xMax", "yMin", "yMax"]):
            if bounds["xMin"] <= bounds["xMax"] and bounds["yMin"] <= bounds["yMax"]:
                result["bounds"] = bounds
                if bounds["xMin"] == bounds["xMax"] and bounds["yMin"] == bounds["yMax"]:
                    result.update(x=bounds["xMin"], y=bounds["yMin"])
        return result

    def source(self, kind, source_id, name=None, provenance=None):
        key = f"{kind}:{int(source_id)}"
        source = self.sources.setdefault(key, dict(kind=kind, sourceID=int(source_id), locations=[], evidence=[]))
        if name:
            source["name"] = name
        if provenance and not any(x["url"] == provenance["url"] and x["sha256"] == provenance["sha256"] for x in source["evidence"]):
            source["evidence"].append(provenance)
        return key, source

    @staticmethod
    def append_location(source, location):
        if location and location not in source["locations"]:
            source["locations"].append(location)

    def quest(self, quest_id, data=None):
        result = self.quests.setdefault(str(quest_id), dict(questID=int(quest_id), starts=[], ends=[], objectives=[], relatedQuests=[]))
        if isinstance(data, dict):
            for key in ["name", "reqlevel", "side", "reqclass", "itemrewards", "itemchoices"]:
                if key in data:
                    result[key] = data[key]
        return result

    def visit(self, node, evidence_file):
        if isinstance(node, list):
            for child in node:
                self.visit(child, evidence_file)
            return
        if not isinstance(node, dict):
            return
        url = node.get("url") or node.get("sourceURL")
        match = ENTITY.search(url) if isinstance(url, str) else None
        if match and node.get("sha256"):
            kind, raw_id = match.groups()
            source_id = int(raw_id)
            provenance = dict(url=url, sha256=node["sha256"], file=evidence_file)
            if kind in ["npc", "object"]:
                name = node.get("title", "").split(" - ")[0] or node.get("name")
                _, source = self.source(kind, source_id, name, provenance)
                maps = node.get("maps") or node.get("mapper") or {}
                if isinstance(maps, dict):
                    for area_id, maps_for_area in maps.items():
                        for area in rows(maps_for_area):
                            self.append_location(source, self.location(area.get("uiMapName") or area.get("name"), area_id, area))
                for area in (rows(maps) + rows(node.get("publishedLocationFootprints")) + rows(node.get("publishedAreas"))):
                    self.append_location(source, self.location(area.get("name") or area.get("zone"), area.get("zoneID"), area))
            elif kind == "item":
                item = self.items[source_id]
                item["evidence"] = provenance
                identity = node.get("identity") or node.get("item") or {}
                if isinstance(identity, dict):
                    item["identity"] = identity
                item["disputed"] = item.get("disputed", False) or bool(node.get("crossVersion") or node.get("seasonOfDiscoveryWarning") or node.get("unavailable") or node.get("primaryUnavailable") or node.get("crossVersionWarning"))
                for field in ["relations", "acquisitionLists", "lists", "tables"]:
                    for relation, values in (node.get(field) or {}).items():
                        if isinstance(values, list):
                            # Later audit excerpts may contain fewer rows than the
                            # original response. Retain all cited alternatives.
                            item.setdefault(relation, [])
                            for value in values:
                                if value not in item[relation]:
                                    item[relation].append(value)
                            if relation in ["reward-from-q", "choice-of-quest"]:
                                for q in values:
                                    if isinstance(q, dict) and q.get("id"):
                                        self.quest(q["id"], q)
            elif kind == "quest":
                q = self.quest(source_id, node.get("quest"))
                q.setdefault("name", node.get("title", "Quest #" + str(source_id)).split(" - ")[0])
                q["evidence"] = provenance
                if node.get("requiredPhysicalItems"):
                    q["requiredItems"] = node["requiredPhysicalItems"]
                for quest_id in node.get("seriesQuestIDs", []):
                    if quest_id not in q["relatedQuests"]:
                        q["relatedQuests"].append(quest_id)
                for area_id, area in (node.get("objectiveMapper") or node.get("mapper") or {}).get("objectives", {}).items():
                    for level in area.get("levels", []):
                        for point in level:
                            if point.get("type") not in [1, 2] or not point.get("id"):
                                continue
                            role = point.get("point")
                            bucket = "starts" if role == "start" else "ends" if role == "end" else "objectives"
                            key, source = self.source("npc" if point["type"] == 1 else "object", point["id"], point.get("name"), provenance)
                            raw = {"coords": point.get("coords") or [point.get("coord")]}
                            self.append_location(source, self.location(area.get("zone"), area_id, raw))
                            if key not in q[bucket]:
                                q[bucket].append(key)
                for point in rows(node.get("actors")):
                    role = point.get("point") or point.get("role")
                    point_id = point.get("npcID") or point.get("objectID") or point.get("id")
                    if role in ["start", "end"] and point_id:
                        key, _ = self.source("object" if point.get("objectID") or point.get("type") == 2 else "npc", point_id, point.get("name"), provenance)
                        if key not in q["starts" if role == "start" else "ends"]:
                            q["starts" if role == "start" else "ends"].append(key)
                markup = rows(node.get("markup")) + rows(node.get("actorFacts"))
                for text in markup:
                    if not isinstance(text, str):
                        continue
                    for role, actor_kind, actor_id, name in re.findall(r"quest-(start|end).*?\[url=/?forever/(npc|object)=(\d+)[^]]*\]([^[]+)\[/url\]", text):
                        key, _ = self.source(actor_kind, actor_id, name, provenance)
                        bucket = "starts" if role == "start" else "ends"
                        if key not in q[bucket]:
                            q[bucket].append(key)
        for child in node.values():
            if isinstance(child, (dict, list)):
                self.visit(child, evidence_file)


def build(inputs):
    evidence = Evidence()
    for path in sorted(REPORT.glob("checkpoint*evidence.json")):
        if "partial" in path.name:
            continue
        body = path.read_bytes()
        evidence.inputs.append(dict(file=path.name, sha256=hashlib.sha256(body).hexdigest()))
        evidence.visit(json.loads(body), path.name)
    # A quest mapper's example point is not more precise than the same NPC's
    # independently documented roaming footprint. Preserve the full area.
    for source in evidence.sources.values():
        grouped = collections.defaultdict(list)
        for location in source["locations"]:
            grouped[location["zone"]].append(location)
        source["locations"] = []
        for zone, variants in grouped.items():
            merged = dict(variants[0])
            boxes = [x["bounds"] for x in variants if x.get("bounds")]
            if boxes:
                merged["bounds"] = dict(xMin=min(x["xMin"] for x in boxes), xMax=max(x["xMax"] for x in boxes),
                                        yMin=min(x["yMin"] for x in boxes), yMax=max(x["yMax"] for x in boxes))
                box = merged["bounds"]
                merged.pop("x", None)
                merged.pop("y", None)
                if box["xMin"] == box["xMax"] and box["yMin"] == box["yMax"]:
                    merged.update(x=box["xMin"], y=box["yMin"])
            map_ids = {x["uiMapID"] for x in variants if x.get("uiMapID")}
            if len(map_ids) == 1:
                merged["uiMapID"] = next(iter(map_ids))
            elif len(map_ids) > 1:
                merged.pop("uiMapID", None)
            source["locations"].append(merged)
    partial_hints = set()
    for path in REPORT.glob("checkpoint*_partial_evidence.json"):
        for raw_id, item in json.loads(path.read_text()).get("items", {}).items():
            relations = item.get("relations", {})
            if relations.get("contained-in-object") and not relations.get("dropped-by"):
                partial_hints.add(int(raw_id))
    equipment = {r["itemID"]: r for r in json.loads((REPORT / "reviewed_equipment_sources.json").read_text())}
    books = {r["itemID"]: r for r in json.loads((REPORT / "reviewed_recipe_sources.json").read_text())}
    dungeon_rows = {int(r["itemID"]): r for r in read_csv(REPORT / "dungeon_items_reconciled.csv")}
    pending = {int(r["itemID"]): r for r in read_csv(REPORT / "remaining_equipment_research_queue.csv")}
    merchants = collections.defaultdict(list)
    merchant_paths = set(REPORT.glob("checkpoint*merchant_references.csv")) | set(REPORT.glob("checkpoint*vendor_references.csv"))
    for path in sorted(merchant_paths):
        evidence.inputs.append(dict(file=path.name, sha256=hashlib.sha256(path.read_bytes()).hexdigest()))
        for row in read_csv(path):
            if row.get("itemID", "").isdigit() and row.get("npcID", "").isdigit():
                merchants[int(row.get("bookItemID") or row["itemID"])].append(row)
    chains_path = REPORT / "navigation_quest_chains.json"
    chains = json.loads(chains_path.read_text()) if chains_path.exists() else {}
    data = dict(version=1, sources=evidence.sources, quests=evidence.quests, items={}, maps={}, chains=chains,
                instances={row["dungeon"]: True for row in dungeon_rows.values() if row.get("dungeon")})
    coverage, gaps = [], []
    for raw_id, gear in sorted(inputs.items(), key=lambda pair: int(pair[0])):
        item_id = int(raw_id)
        plan = dict(itemID=item_id, routes=[])
        meta = equipment.get(item_id) or books.get(item_id) or {}
        own = evidence.items.get(item_id, {})
        craft = bool(gear.get("profession"))
        dungeon = dungeon_rows.get(item_id)
        source_type = gear.get("sourceType", "").lower()
        plan["category"] = "crafting" if craft else "quest" if "quest" in source_type else "vendor" if "vendor" in source_type else "world_drop" if "world drop" in source_type else "reputation" if "reputation" in source_type else "unknown"
        def gap(code, source="", quest="", detail=""):
            gaps.append(dict(itemID=item_id, name=gear["name"], category=plan["category"], sourceID=source, questID=quest,
                             gap=code, detail=detail, researchCheckpoint=pending.get(item_id, {}).get("nextBatch", ""),
                             researchStatus=pending.get(item_id, {}).get("status", "existing-catalogue")))
        def route(kind, **values):
            entry = dict(kind=kind, **values)
            if entry not in plan["routes"]:
                plan["routes"].append(entry)
        book_id = gear.get("recipePatternItemID") or books.get(item_id, {}).get("bookItemID")
        # Reviewed future trainer/special-crafting/unlock routes share the
        # existing source registry and primary NPC/object evidence pool.
        for extra in meta.get("navigationRoutes", []):
            if extra.get("kind") in ["trainer", "crafting_requirement", "object", "unlock"] and extra.get("source") in evidence.sources:
                if not evidence.sources[extra["source"]]["evidence"]:
                    continue
                route(extra["kind"], source=extra["source"], instructions=extra.get("instructions"),
                      verification="published-reference", bookItemID=book_id if craft else None)
        # Reward relationships are read from explicit primary reward arrays, never item-provided state.
        for quest_id, q in evidence.quests.items():
            rewards = rows(q.get("itemrewards")) + rows(q.get("itemchoices"))
            if any(isinstance(x, list) and x and x[0] == (book_id if craft and book_id else item_id) for x in rewards):
                route("quest", questID=int(quest_id), bookItemID=book_id if craft else None)
                if not craft:
                    plan["category"] = "quest"
                if q.get("relatedQuests") and quest_id not in chains:
                    gap("quest_chain_relationships_unverified", quest=quest_id, detail="Related sequence is not proof of mandatory prerequisites or earliest start.")
                if not q["starts"]:
                    gap("quest_start_missing", quest=quest_id, detail="Do not present a turn-in as the starting NPC.")
        source_item = evidence.items.get(book_id if craft and book_id else item_id, {})
        if not own.get("disputed") and not source_item.get("disputed"):
            for seller in rows(source_item.get("sold-by")):
                if not seller.get("id"):
                    continue
                source_key, _ = evidence.source("npc", seller["id"], seller.get("name"))
                offer = {k: seller[k] for k in ["cost", "stock", "avail", "standing", "reqfaction", "reqlevel", "side"] if k in seller}
                route("recipe_vendor" if craft else "vendor", source=source_key, bookItemID=book_id, offer=offer)
            for merchant in merchants.get(book_id if craft and book_id else item_id, []):
                actor_hash = merchant.get("npcPageSHA256") or merchant.get("npcSHA256")
                actor_proof = dict(url=merchant["npcURL"], sha256=actor_hash, file="reviewed merchant reference CSV") if actor_hash and merchant.get("npcURL") else None
                key, actor = evidence.source("npc", merchant["npcID"], merchant.get("npcName"), actor_proof)
                if not actor["locations"] and merchant.get("zone"):
                    evidence.append_location(actor, evidence.location(merchant["zone"]))
                notes = "; ".join(f"Published {field}: {merchant[field]}" for field in ["listedPrice", "stockReference", "stock", "costDescription", "playerConditions"] if merchant.get(field))
                existing = next((x for x in plan["routes"] if x.get("source") == key), None)
                if existing:
                    if notes and notes not in existing.get("instructions", ""):
                        existing["instructions"] = (existing.get("instructions", "") + "\n" + notes).strip()
                else:
                    route("recipe_vendor" if craft else "vendor", source=key, bookItemID=book_id,
                          instructions=notes or meta.get("summary"), verification="published-reference")
            # Earlier book research stored exact item/NPC joins in typed CSVs.
            # Reuse those reviewed relationships; do not parse prose as coordinates.
            if craft and "book-drop-reference" in str(meta.get("confidence", "")) and meta.get("retrievedNPCRows") == 1:
                for filename in meta.get("sourceEvidenceCSVs", []):
                    path = REPORT / filename
                    if not path.is_file() or not path.name.endswith("book_drop_references.csv"):
                        continue
                    fingerprint = dict(file=path.name, sha256=hashlib.sha256(path.read_bytes()).hexdigest())
                    if fingerprint not in evidence.inputs:
                        evidence.inputs.append(fingerprint)
                    for row in read_csv(path):
                        if row.get("itemID") == raw_id and row.get("npcID", "").isdigit():
                            book_proof = next((dict(url=url, sha256=digest, file=filename) for url, digest in meta.get("sourceSHA256", {}).items()
                                               if (match := ENTITY.search(url)) and match[1] == "item" and int(match[2]) == book_id), None)
                            key, actor = evidence.source("npc", row["npcID"], row.get("npcName"), book_proof)
                            if not actor["locations"] and row.get("zone"):
                                evidence.append_location(actor, evidence.location(row["zone"], row.get("zoneID")))
                            route("recipe_drop", source=key, bookItemID=book_id, verification="published-reference",
                                  instructions="Published recipe-book drop, not finished equipment. Current loot and availability unverified.")
            drops = rows(source_item.get("dropped-by"))
            # Random loot-table examples must never become a farm destination.
            fixed = len(drops) == 1 or (drops and len(drops) < 10 and all(x.get("classification") in [2, 3, 4] for x in drops))
            if fixed and ("named-enemy" in str(meta.get("confidence", "")) or craft and "book-drop-reference" in str(meta.get("confidence", ""))):
                for actor in drops:
                    if actor.get("id"):
                        key, _ = evidence.source("npc", actor["id"], actor.get("name"))
                        route("recipe_drop" if craft else "named_drop", source=key, bookItemID=book_id if craft else None, verification="published-reference")
            if not craft and not drops and not source_item.get("sold-by"):
                for obj in rows(source_item.get("contained-in-object")):
                    if obj.get("id"):
                        key, _ = evidence.source("object", obj["id"], obj.get("name"))
                        route("object", source=key, verification="published-reference")
        if dungeon and dungeon.get("reconciledRole") not in ["crafted-item"]:
            plan["category"] = "dungeon_recipe" if craft else "dungeon"
            route("dungeon", dungeon=dungeon.get("dungeon", ""), boss=dungeon.get("enemy", ""),
                  verification=dungeon.get("confidence"), recipe=craft, bookItemID=book_id,
                  instructions=dungeon.get("sourceSummary"))
            gap("dungeon_floor_or_access_unverified", detail="Use client entrance; no inferred boss-floor coordinates, keys or unlocks.")
        legacy = gear.get("acquisitionLocation")
        if isinstance(legacy, dict) and legacy.get("zone"):
            # Existing researched coordinates remain separate from the item itself.
            route("recipe_vendor" if craft and gear.get("recipeVendor") else "trainer" if "Trainer" in gear.get("acquisitionKind", "") else "legacy",
                  location=dict(legacy, verification="legacy-reference" if legacy.get("quality") == "classic-reference" else "published-reference"),
                  label=legacy.get("spot", gear.get("source")), instructions=gear.get("instructions"),
                  cost=gear.get("recipeVendorCost"), currency=gear.get("recipeVendorCurrency"))
        if own.get("disputed") or source_item.get("disputed"):
            plan["routes"] = []
            gap("source_version_disputed", detail="Availability warning must not create a misleading destination.")
        located, exact = False, False
        for entry in plan["routes"]:
            if entry["kind"] == "quest":
                q = evidence.quests[str(entry["questID"])]
                keys = q["starts"] + q["ends"]
            else:
                keys = [entry["source"]] if entry.get("source") else []
            locations = [loc for key in keys for loc in evidence.sources.get(key, {}).get("locations", [])]
            if entry.get("location"):
                locations.append(entry["location"])
            located = located or bool(locations) or entry["kind"] == "dungeon"
            exact = exact or any(coordinate(x.get("x")) and coordinate(x.get("y")) and x.get("verification") == "published-reference" for x in locations)
            for key in keys:
                if not evidence.sources.get(key, {}).get("locations"):
                    gap("source_coordinates_missing", key, entry.get("questID", ""), "Named source exists; precise location not established.")
                elif not any(coordinate(x.get("x")) and coordinate(x.get("y")) for x in evidence.sources[key]["locations"]):
                    gap("precise_coordinate_unverified", key, entry.get("questID", ""), "Published area/roaming footprint only; no invented point or centroid.")
        expected = plan["category"] != "world_drop" or "named-enemy" in str(meta.get("confidence", "")) or bool(plan["routes"]) or item_id in partial_hints or bool(own.get("contained-in-object") and not own.get("dropped-by"))
        status = "verified_coordinate_data" if exact else "directions" if located else "missing" if expected else "not_applicable"
        if status == "missing":
            gap("actionable_location_missing", detail="No safe map target. Keep detailed source evidence; no fabricated marker.")
        if plan["routes"]:
            data["items"][raw_id] = plan
        coverage.append(dict(itemID=item_id, name=gear["name"], category=plan["category"], status=status,
                             routeCount=len(plan["routes"]), inGameRenderingVerified=False,
                             classes=",".join(c for i, c in enumerate(CLASSES) if int(gear["eligibility"][0]) & (1 << i))))
    # Keep map namespaces as data; runtime validates every candidate against the client.
    for name, ids in evidence.maps.items():
        data["maps"][name] = sorted(ids)
    data["audit"] = dict(items=len(coverage), statuses=dict(collections.Counter(r["status"] for r in coverage)),
                         inGameRenderingVerified=0, gapRows=len(gaps))
    used_sources = set()
    for plan in data["items"].values():
        for entry in plan["routes"]:
            if entry.get("source"):
                used_sources.add(entry["source"])
            if entry["kind"] == "quest":
                q = data["quests"][str(entry["questID"])]
                used_sources.update(q["starts"] + q["ends"] + q["objectives"])
    # Retain quest-chain actors too, without creating duplicate location records.
    for chain in chains.values():
        for quest_id in chain.get("steps", []):
            q = data["quests"].get(str(quest_id), {})
            used_sources.update(q.get("starts", []) + q.get("ends", []) + q.get("objectives", []))
    data["sources"] = {k: v for k, v in evidence.sources.items() if k in used_sources}
    return data, coverage, gaps, evidence.inputs


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--inputs", type=Path)
    args = parser.parse_args()
    if args.inputs:
        inputs = json.loads(args.inputs.read_text())
    else:
        executable = shutil.which("lua5.4") or shutil.which("lua")
        if not executable:
            raise SystemExit("Lua is required for the offline catalogue export")
        inputs = json.loads(subprocess.check_output([executable, str(ROOT / "tools/export_navigation_inputs.lua"), str(ROOT)], text=True))
    data, coverage, gaps, evidence_inputs = build(inputs)
    (ROOT / "AcquisitionNavigationData.lua").write_text("local _, GetGear = ...\n-- Generated by tools/build_acquisition_navigation.py; published references, not live verification.\nGetGear.AcquisitionNavigationData=" + lua(data) + "\n", encoding="utf-8")
    for name, records in [("navigation_coverage.csv", coverage), ("navigation_research_gaps.csv", gaps)]:
        with (REPORT / name).open("w", encoding="utf-8", newline="") as handle:
            columns = list(records[0]) if records else ["itemID", "name", "category", "sourceID", "questID", "gap", "detail", "researchCheckpoint", "researchStatus"]
            writer = csv.DictWriter(handle, fieldnames=columns)
            writer.writeheader()
            writer.writerows(records)
    report = dict(data["audit"], categories=dict(collections.Counter(x["category"] for x in coverage)),
                  routeKinds=dict(collections.Counter(route["kind"] for plan in data["items"].values() for route in plan["routes"])),
                  classes={c: dict(collections.Counter(x["status"] for x in coverage if c in x["classes"].split(","))) for c in CLASSES},
                  sourceRecords=len(data["sources"]), questRecords=len(data["quests"]),
                  scope="Every catalogue ID audited. Verified coordinate data means cited published coordinates, not tested in-game rendering. Directions include client-resolved entrances/areas. Missing data is not successful navigation. Gap rows share the existing acquisition research tracking.", inputs=evidence_inputs)
    report["catalogueExportSHA256"] = hashlib.sha256(json.dumps(inputs, sort_keys=True).encode()).hexdigest()
    for path in [REPORT / name for name in ["reviewed_equipment_sources.json", "reviewed_recipe_sources.json", "dungeon_items_reconciled.csv", "remaining_equipment_research_queue.csv", "navigation_quest_chains.json"]] + [ROOT / "tools/export_navigation_inputs.lua", ROOT / "tools/build_acquisition_navigation.py"]:
        if path.exists():
            report["inputs"].append(dict(file=str(path.relative_to(ROOT)), sha256=hashlib.sha256(path.read_bytes()).hexdigest()))
    (REPORT / "navigation_audit.json").write_text(json.dumps(report, indent=2) + "\n")
    print("NAVIGATION", len(coverage), data["audit"]["statuses"], "gaps", len(gaps))


if __name__ == "__main__":
    main()
