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
PROFESSION_SKILLS = {"Alchemy": 171, "Blacksmithing": 164, "Enchanting": 333,
                     "Engineering": 202, "Leatherworking": 165, "Tailoring": 197,
                     "Cooking": 185, "First Aid": 129}
ENTITY = re.compile(r"/(?:forever/)?(npc|object|quest|item|currency|zone)(?:=|/)(\d+)")


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
        self.full_quest_rewards = collections.defaultdict(set)
        self.full_npc_sales = collections.defaultdict(dict)
        self.full_npc_drops = collections.defaultdict(dict)
        self.full_npc_teaching = collections.defaultdict(list)
        self.full_object_contents = collections.defaultdict(dict)
        self.instances = {}
        self.quest_starters = collections.defaultdict(list)
        self.legacy_quests = {}
        self.modern_quests = set()
        self.legacy_stats = collections.Counter()
        self.items = collections.defaultdict(dict)
        self.currencies = {}
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
        if raw.get("coordinateScope") == "continent-only":
            # Research can distinguish a coarse instance mapper from a genuine
            # published outdoor position in the same continent coordinate frame.
            result["coordinateScope"] = "continent-only"
            return result
        points = [p for p in rows(raw.get("coords")) if isinstance(p, list) and len(p) >= 2 and coordinate(p[0]) and coordinate(p[1]) and (p[0] != 0 or p[1] != 0)]
        bounds = raw.get("bounds")
        if points:
            bounds = dict(xMin=min(x[0] for x in points), xMax=max(x[0] for x in points),
                          yMin=min(x[1] for x in points), yMax=max(x[1] for x in points))
        if isinstance(bounds, dict) and all(coordinate(bounds.get(k)) for k in ["xMin", "xMax", "yMin", "yMax"]):
            if (bounds["xMin"] <= bounds["xMax"] and bounds["yMin"] <= bounds["yMax"]
                    and any(bounds[k] != 0 for k in ["xMin", "xMax", "yMin", "yMax"])):
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
        if location:
            frame = lambda value: tuple(value.get(k) for k in ["zone", "areaID", "uiMapID"])
            same_frame = [old for old in source["locations"] if frame(old) == frame(location)]
            if location.get("coordinateScope") == "continent-only" or any(old.get("coordinateScope") == "continent-only" for old in same_frame):
                location = dict(location, coordinateScope="continent-only")
                for value in same_frame + [location]:
                    value["coordinateScope"] = "continent-only"
                    for field in ["x", "y", "bounds"]:
                        value.pop(field, None)
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
        # Earlier verified item research stored the primary page fingerprint
        # in a hashes map alongside its extracted tables.
        if not (node.get("url") or node.get("sourceURL")) and isinstance(node.get("hashes"), dict) and isinstance(node.get("tables"), dict):
            for candidate, fingerprint in node["hashes"].items():
                match = re.fullmatch(r"https://www\.wowhead\.com/forever/item=(\d+)", candidate)
                if match and int(match[1]) == node.get("itemID") and isinstance(fingerprint, str) and re.fullmatch(r"[a-f0-9]{64}", fingerprint):
                    node = dict(node, url=candidate, sha256=fingerprint,
                                identity=dict(node.get("equip") or {}, id=node["itemID"], name=node.get("name", "")))
                    break
        url = node.get("url") or node.get("sourceURL")
        match = ENTITY.search(url) if isinstance(url, str) else None
        if match and node.get("sha256"):
            kind, raw_id = match.groups()
            source_id = int(raw_id)
            provenance = dict(url=url, sha256=node["sha256"], file=evidence_file)
            if kind in ["npc", "object"]:
                name = node.get("title", "").split(" - ")[0] or node.get("name")
                _, source = self.source(kind, source_id, name, provenance)
                if kind == "npc":
                    for note in rows(node.get("serviceAccessNotes")):
                        if isinstance(note, str) and note.strip() and note not in source.setdefault("serviceAccessNotes", []):
                            source["serviceAccessNotes"].append(note)
                    # A full NPC's selected quest-role rows can corroborate a
                    # starting destination even when the quest page is unread.
                    # They establish neither rewards, faction nor prerequisites.
                    for field, role in [("selectedQuestStarts", "starts"), ("selectedQuestEnds", "ends")]:
                        for reference in rows(node.get(field)):
                            if isinstance(reference, dict) and type(reference.get("id")) is int and isinstance(reference.get("name"), str):
                                quest = self.quest(reference["id"], {"name": reference["name"]})
                                key = "npc:" + str(source_id)
                                if key not in quest[role]:
                                    quest[role].append(key)
                                quest.setdefault("roleEvidence", []).append(provenance)
                    for sale in rows((node.get("lists") or {}).get("sells")) + rows(node.get("selectedSells")):
                        if isinstance(sale, dict) and type(sale.get("id")) is int:
                            self.full_npc_sales[source_id][sale["id"]] = sale
                    for drop in rows((node.get("lists") or {}).get("drops")) + rows(node.get("selectedDrops")):
                        if isinstance(drop, dict) and type(drop.get("id")) is int:
                            self.full_npc_drops[source_id][drop["id"]] = drop
                    for teaching in rows((node.get("lists") or {}).get("teaches-recipe")) + rows(node.get("selectedTeaches")):
                        if isinstance(teaching, dict) and teaching not in self.full_npc_teaching[source_id]:
                            self.full_npc_teaching[source_id].append(teaching)
                else:
                    for content in rows((node.get("lists") or {}).get("contains")) + rows(node.get("selectedContains")):
                        if isinstance(content, dict) and type(content.get("id")) is int:
                            self.full_object_contents[source_id][content["id"]] = content
                maps = node.get("maps") or node.get("mapper") or {}
                if isinstance(maps, dict):
                    for area_id, maps_for_area in maps.items():
                        for area in rows(maps_for_area):
                            self.append_location(source, self.location(area.get("uiMapName") or area.get("name"), area_id, area))
                for area in (rows(maps) + rows(node.get("publishedLocationFootprints")) + rows(node.get("publishedAreas"))):
                    self.append_location(source, self.location(area.get("name") or area.get("zone"), area.get("zoneID"), area))
            elif kind == "zone":
                zone = node.get("zone") or {}
                markup = rows(node.get("markup"))
                if (zone.get("id") == source_id and isinstance(zone.get("name"), str) and zone["name"].strip()
                        and zone["name"] == node.get("title", "").split(" - Zone - ")[0]
                        and zone.get("instanceType") in ["Raid", "Dungeon"]
                        and any(isinstance(s, str) and "[li]Instance type: " + zone["instanceType"] + "[/li]" in s for s in markup)):
                    self.instances[zone["name"]] = dict(areaID=source_id, kind=zone["instanceType"].lower(), evidence=provenance,
                        verification="published-reference",
                        instructions=node.get("navigationInstructions") if isinstance(node.get("navigationInstructions"), str) else None)
            elif kind == "currency":
                name = node.get("currencyName")
                title = node.get("title", "")
                if not name and title.endswith(" - Currency - Forever"):
                    name = title.removesuffix(" - Currency - Forever")
                if isinstance(name, str) and name.strip():
                    self.currencies[str(source_id)] = dict(name=name.strip(), evidence=provenance,
                                                           verification="published-reference")
            elif kind == "item":
                item = self.items[source_id]
                item["evidence"] = provenance
                identity = node.get("identity") or node.get("item") or {}
                if isinstance(identity, dict):
                    item["identity"] = identity
                if isinstance(node.get("containerNavigationRoutes"), list):
                    item.setdefault("containerNavigationRoutes", [])
                    for value in node["containerNavigationRoutes"]:
                        if isinstance(value, dict) and value not in item["containerNavigationRoutes"]:
                            item["containerNavigationRoutes"].append(value)
                # Full-container research retains exact positive contents joins
                # separately from the item's own acquisition lists.
                if isinstance(node.get("selectedContains"), list):
                    item.setdefault("contains", [])
                    for value in node["selectedContains"]:
                        if value not in item["contains"]:
                            item["contains"].append(value)
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
                            elif relation == "starts":
                                for q in values:
                                    if isinstance(q, dict) and type(q.get("id")) is int:
                                        starter = dict(itemID=source_id, name=identity.get("name") or node.get("title", "").split(" - ")[0], evidence=provenance)
                                        if not any(x["itemID"] == source_id for x in self.quest_starters[str(q["id"])]):
                                            self.quest_starters[str(q["id"])].append(starter)
            elif kind == "quest":
                legacy = node.get("questDetails")
                if isinstance(legacy, dict) and legacy.get("id") == source_id:
                    self.legacy_quests[(str(source_id), node["sha256"])] = (legacy, provenance)
                q = self.quest(source_id, node.get("quest"))
                full_quest = node.get("quest") or {}
                if full_quest.get("id") == source_id or "itemrewards" in full_quest or "itemchoices" in full_quest:
                    self.modern_quests.add(str(source_id))
                for reward in rows(full_quest.get("itemrewards")) + rows(full_quest.get("itemchoices")):
                    if isinstance(reward, list) and reward and type(reward[0]) is int:
                        self.full_quest_rewards[str(source_id)].add(reward[0])
                q.setdefault("name", node.get("title", "Quest #" + str(source_id)).split(" - ")[0])
                q["evidence"] = provenance
                if node.get("requiredPhysicalItems"):
                    q["requiredItems"] = node["requiredPhysicalItems"]
                if isinstance(node.get("sourceRequirements"), list):
                    q["sourceRequirements"] = [value for value in node["sourceRequirements"] if isinstance(value, str)]
                    q["sourceRequirementsUnresolved"] = node.get("sourceRequirementsUnresolved") is True
                if isinstance(node.get("acquisitionDetails"), list):
                    q["acquisitionDetails"] = [value for value in node["acquisitionDetails"] if isinstance(value, str)]
                if isinstance(node.get("actorZones"), dict):
                    q["actorZones"] = {key: value for key, value in node["actorZones"].items()
                                       if isinstance(key, str) and re.fullmatch(r"(?:npc|object):\d+", key)
                                       and isinstance(value, str) and value.strip()}
                for field in ["starterZone", "starterInstructions", "objectiveZone", "objectiveSource", "objectiveInstructions", "turnInZone", "turnInInstructions"]:
                    if isinstance(node.get(field), str):
                        q[field] = node[field]
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
    # Reconnect legacy full recipe-quest metadata only through its exact,
    # previously validated primary-page fingerprint and book reward join.
    # Current full quest records and established actors retain precedence.
    for path in sorted(REPORT.glob("checkpoint*quest_references.csv")):
        references = read_csv(path)
        if not references or not {"questID", "questURL", "questPageSHA256", "bookItemID", "startKind", "endKind"} <= references[0].keys():
            continue
        evidence.inputs.append(dict(file=path.name, sha256=hashlib.sha256(path.read_bytes()).hexdigest()))
        for reference in references:
            quest_id = reference["questID"]
            pair = evidence.legacy_quests.get((quest_id, reference["questPageSHA256"]))
            if not pair or reference["questURL"] != pair[1]["url"] or not reference["bookItemID"].isdigit():
                evidence.legacy_stats["unmatched_reference"] += 1
                continue
            full_quest, provenance = pair
            rewards = rows(full_quest.get("itemrewards")) + rows(full_quest.get("itemchoices"))
            if not any(isinstance(x, list) and x and x[0] == int(reference["bookItemID"]) for x in rewards):
                evidence.legacy_stats["book_reward_mismatch"] += 1
                continue
            if quest_id in evidence.modern_quests:
                evidence.legacy_stats["current_metadata_preserved"] += 1
                continue
            q = evidence.quest(quest_id)
            for field in ["itemrewards", "itemchoices"]:
                q.pop(field, None)
            evidence.quest(quest_id, full_quest)
            q["evidence"] = provenance
            q["legacyRecipeQuestReference"] = True
            evidence.full_quest_rewards[quest_id].update(x[0] for x in rewards if isinstance(x, list) and x and type(x[0]) is int)
            for role, bucket in [("start", "starts"), ("end", "ends")]:
                kind, actor_id = reference[role + "Kind"], reference.get(role + "ID", "")
                if kind not in ["npc", "object"] or not actor_id.isdigit() or int(actor_id) <= 0 or q[bucket]:
                    continue
                key, _ = evidence.source(kind, actor_id, reference.get(role + "Name"), provenance)
                q[bucket].append(key)
                evidence.legacy_stats["actor_roles_restored"] += 1
            if reference["startKind"] == "item" and reference.get("startID", "").isdigit():
                known_starter_destination = bool(q.get("starterZone") and q.get("starterInstructions"))
                q.setdefault("starterInstructions", "This quest begins with " + reference.get("startName", "a starting item") +
                             " (#" + reference["startID"] + "). Its acquisition destination is not established here; the turn-in NPC is not the place to begin.")
                if not known_starter_destination:
                    q["starterOriginUnresolved"] = True
                    evidence.legacy_stats["item_starts_pending_destination"] += 1
            evidence.legacy_stats["full_recipe_quests_restored"] += 1
    for quest_id, starters in evidence.quest_starters.items():
        if quest_id in evidence.quests and evidence.quests[quest_id].get("evidence"):
            q = evidence.quests[quest_id]
            q["starterItems"] = starters
            starter_ids = {item["itemID"] for item in starters}
            for item in q.get("requiredItems", []):
                if isinstance(item, dict) and item.get("itemID") in starter_ids:
                    item["startsQuest"] = True
            if not q["starts"] and not (q.get("starterZone") and q.get("starterInstructions")):
                q["starterOriginUnresolved"] = True
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
    recipe_path = REPORT / "recipes_reconciled.csv"
    recipes = {int(r["itemID"]): r for r in read_csv(recipe_path)} if recipe_path.exists() else {}
    if recipe_path.exists():
        evidence.inputs.append(dict(file=recipe_path.name, sha256=hashlib.sha256(recipe_path.read_bytes()).hexdigest()))
    dungeon_rows = {int(r["itemID"]): r for r in read_csv(REPORT / "dungeon_items_reconciled.csv")}
    known_dungeons = {r["dungeon"] for r in dungeon_rows.values() if r.get("reconciledRole") not in ["crafted-item", "crafted-pattern"] and r.get("dungeon")}
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
                currencies=evidence.currencies,
                instances={name: True for name in known_dungeons | set(evidence.instances)},
                instanceDetails=evidence.instances)
    container_routes = collections.defaultdict(list)
    for container_id, container in evidence.items.items():
        shared = container.get("containerNavigationRoutes", [])
        if not shared:
            continue
        for content in rows(container.get("contains")):
            if isinstance(content, dict) and type(content.get("id")) is int:
                container_routes[content["id"]].extend(dict(value, containerItemID=container_id)
                    for value in shared if value.get("kind") in ["quest_container", "vendor_container", "npc_container"])
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
            entry = {key: value for key, value in dict(kind=kind, **values).items() if value is not None}
            identity = {key: value for key, value in entry.items() if key not in ["instructions", "verification"]}
            for existing in plan["routes"]:
                if identity == {key: value for key, value in existing.items() if key not in ["instructions", "verification"]}:
                    if entry.get("instructions") and not existing.get("instructions"):
                        existing["instructions"] = entry["instructions"]
                    return
            plan["routes"].append(entry)
        for research_gap in meta.get("navigationResearchGaps", []):
            if isinstance(research_gap.get("gap"), str) and isinstance(research_gap.get("detail"), str):
                gap(research_gap["gap"], source=research_gap.get("sourceID", ""),
                    quest=research_gap.get("questID", ""), detail=research_gap["detail"])
        book_id = gear.get("recipePatternItemID") or books.get(item_id, {}).get("bookItemID")
        # A full teaching table identifies the learned spell and its output,
        # independently of any physical pattern book's acquisition route.
        recipe = recipes.get(item_id, {})
        if (craft and recipe.get("profession") == gear["profession"]
                and str(recipe.get("spellID", "")).isdigit()):
            spell_id = int(recipe["spellID"])
            skill_id = PROFESSION_SKILLS.get(gear["profession"])
            for npc_id, teachings in sorted(evidence.full_npc_teaching.items()):
                for teaching in teachings:
                    output = rows(teaching.get("creates"))
                    if (type(teaching.get("id")) is not int or teaching["id"] != spell_id
                            or not output or type(output[0]) is not int
                            or output[0] != item_id or teaching.get("name") != gear["name"]
                            or skill_id not in rows(teaching.get("skill"))
                            or (teaching.get("envChange") or {}).get("status") == "unconfirmed"):
                        continue
                    details = "Learn this recipe from the published trainer."
                    minimum, fee = teaching.get("learnedat"), teaching.get("trainingcost")
                    if type(minimum) is int and 0 <= minimum < 9999:
                        details += f" Published learning skill: {gear['profession']} {minimum}."
                    if type(fee) is int and fee >= 0:
                        details += f" Published training fee: {fee} copper."
                    details += (" This locates recipe learning, not finished equipment or a physical pattern book."
                                " Learning skill is not a wearer requirement. Current teaching, price and access remain unverified.")
                    for note in evidence.sources[f"npc:{npc_id}"].get("serviceAccessNotes", []):
                        details += " " + note
                    legacy = teaching.get("classicEra") == 1
                    route("trainer", source=f"npc:{npc_id}", spellID=spell_id,
                          verification="legacy-reference" if legacy else "published-reference",
                          directionsOnly=True if legacy else None, instructions=details)
                    break
        # Reviewed future trainer/special-crafting/unlock routes share the
        # existing source registry and primary NPC/object evidence pool.
        extras = list(meta.get("navigationRoutes", []))
        # A newly researched container destination applies to every exact
        # published content, including earlier and future catalogue entries.
        # It still passes the same full-source relationship guards below.
        extras.extend(container_routes.get(item_id, []))
        for extra in extras:
            if extra.get("kind") in ["vendor", "recipe_vendor"] and extra.get("requiresFullSaleJoin"):
                source_key = extra.get("source")
                actor = evidence.sources.get(source_key, {})
                target_id = book_id if craft and book_id else item_id
                product = evidence.items.get(target_id, {})
                name = product.get("identity", {}).get("name") if craft else gear["name"]
                sale = evidence.full_npc_sales.get(actor.get("sourceID"), {}).get(target_id)
                if (actor.get("kind") == "npc" and actor.get("evidence") and name and sale
                        and sale.get("name") == name
                        and any(x.get("id") == actor["sourceID"] for x in rows(product.get("sold-by")) if isinstance(x, dict))):
                    offer = {k: sale[k] for k in ["cost", "stock", "avail", "standing", "reqfaction", "reqlevel", "side"] if k in sale}
                    if extra.get("sourceSide") in [1, 2]:
                        offer["side"] = extra["sourceSide"]
                    route("recipe_vendor" if craft else "vendor", source=source_key, offer=offer,
                          sourceRequirements=[x for x in rows(extra.get("sourceRequirements")) if isinstance(x, str)],
                          instructions=extra.get("instructions"), bookItemID=book_id if craft else None,
                          verification="published-reference")
                    if not craft:
                        plan["category"] = "vendor"
                else:
                    gap("full_vendor_join_unverified", source_key or "",
                        detail="Require exact own seller and independent full vendor inventory ID/name before navigating this reviewed offer.")
                continue
            if extra.get("kind") == "npc_container":
                container_id, source_key = extra.get("containerItemID"), extra.get("source")
                container = evidence.items.get(container_id, {}) if type(container_id) is int else {}
                actor = evidence.sources.get(source_key, {})
                actor_id = actor.get("sourceID")
                drop = evidence.full_npc_drops.get(actor_id, {}).get(container_id)
                own_drop = next((x for x in rows(container.get("dropped-by"))
                                 if isinstance(x, dict) and x.get("id") == actor_id), None)
                if (actor.get("kind") == "npc" and actor.get("evidence") and drop and own_drop
                        and container.get("evidence") and not container.get("disputed")
                        and any(isinstance(x, dict) and x.get("id") == item_id for x in rows(container.get("contains")))):
                    legacy = extra.get("verification") == "legacy-reference" or drop.get("classicEra") == 1 or own_drop.get("classicEra") == 1
                    route("npc_container", source=source_key, containerItemID=container_id,
                          instructions=extra.get("instructions"), verification="legacy-reference" if legacy else "published-reference",
                          directionsOnly=True if legacy or extra.get("directionsOnly") is True else None)
                else:
                    gap("container_npc_relation_unverified", source=source_key or "",
                        detail="Require full NPC loot, container origin and exact full-wrapper contents; no direct finished-gear drop inferred.")
                continue
            if extra.get("kind") == "vendor_container":
                container_id, source_key = extra.get("containerItemID"), extra.get("source")
                container = evidence.items.get(container_id, {}) if type(container_id) is int else {}
                actor = evidence.sources.get(source_key, {})
                actor_id = actor.get("sourceID")
                sale = evidence.full_npc_sales.get(actor_id, {}).get(container_id)
                if (actor.get("kind") == "npc" and actor.get("evidence") and sale
                        and container.get("evidence") and not container.get("disputed")
                        and any(isinstance(x, dict) and x.get("id") == actor_id for x in rows(container.get("sold-by")))
                        and any(isinstance(x, dict) and x.get("id") == item_id for x in rows(container.get("contains")))):
                    offer = {k: sale[k] for k in ["cost", "stock", "avail", "standing", "reqfaction", "reqlevel", "side"] if k in sale}
                    route("vendor_container", source=source_key, containerItemID=container_id, offer=offer,
                          instructions=extra.get("instructions"), verification="published-reference")
                else:
                    gap("container_vendor_relation_unverified", source=source_key or "",
                        detail="Require full vendor inventory, container seller and exact full-container contents; no inferred equipment sale.")
                continue
            if extra.get("kind") == "quest_container":
                quest_id, container_id = extra.get("questID"), extra.get("containerItemID")
                if type(quest_id) is not int or type(container_id) is not int:
                    continue
                q = evidence.quests.get(str(quest_id), {})
                container = evidence.items.get(container_id, {})
                if (q.get("evidence") and container.get("evidence") and not container.get("disputed")
                        and container_id in evidence.full_quest_rewards.get(str(quest_id), set())
                        and any(isinstance(x, dict) and x.get("id") == item_id for x in rows(container.get("contains")))):
                    route("quest_container", questID=quest_id, containerItemID=container_id,
                          instructions=extra.get("instructions"), verification="published-reference",
                          directionsOnly=True if extra.get("directionsOnly") is True else None)
                    if not q.get("starts"):
                        gap("quest_start_missing", quest=quest_id, detail="Container reward quest has no established starting actor.")
                else:
                    gap("container_quest_relation_unverified", source="item:" + str(container_id), quest=quest_id,
                        detail="Require full quest reward and exact full-container contents evidence; no inferred destination.")
                continue
            if extra.get("kind") in ["trainer", "crafting_requirement", "object", "unlock", "named_drop"] and extra.get("source") in evidence.sources:
                actor = evidence.sources[extra["source"]]
                if not actor["evidence"]:
                    continue
                legacy = extra.get("verification") == "legacy-reference"
                if extra.get("requiresFullLootJoin") and extra["kind"] in ["object", "named_drop"]:
                    relation = "contained-in-object" if extra["kind"] == "object" else "dropped-by"
                    reverse = evidence.full_object_contents if extra["kind"] == "object" else evidence.full_npc_drops
                    expected_kind = "object" if extra["kind"] == "object" else "npc"
                    forward = next((x for x in rows(own.get(relation)) if isinstance(x, dict) and x.get("id") == actor["sourceID"]), None)
                    back = reverse.get(actor["sourceID"], {}).get(item_id)
                    if not (actor["kind"] == expected_kind and forward and back and back.get("name") == gear["name"]):
                        gap("full_loot_join_unverified", extra["source"],
                            detail="Require exact own source and independent full NPC/object contents; a header or unrelated name does not establish this loot.")
                        continue
                    legacy = legacy or forward.get("classicEra") == 1 or back.get("classicEra") == 1
                    instance = any(loc["zone"] in data["instances"] for loc in actor["locations"])
                    if instance and not craft:
                        plan["category"] = "dungeon"
                    if extra.get("entranceOnly") and not instance:
                        gap("instance_definition_unverified", extra["source"],
                            detail="Published source region retained; a verified instance definition and client entrance are still required. No floor point is substituted.")
                route(extra["kind"], source=extra["source"], instructions=extra.get("instructions"),
                      verification="legacy-reference" if legacy else "published-reference",
                      directionsOnly=True if extra.get("directionsOnly") is True or legacy else None,
                      entranceOnly=True if extra.get("entranceOnly") is True and extra.get("requiresFullLootJoin")
                          and any(loc["zone"] in data["instances"] for loc in evidence.sources[extra["source"]]["locations"]) else None,
                      bookItemID=book_id if craft else None)
        # Reward relationships are read from explicit primary reward arrays, never item-provided state.
        for quest_id, q in evidence.quests.items():
            rewards = rows(q.get("itemrewards")) + rows(q.get("itemchoices"))
            if any(isinstance(x, list) and x and x[0] == (book_id if craft and book_id else item_id) for x in rewards):
                route("quest", questID=int(quest_id), bookItemID=book_id if craft else None)
                if not craft:
                    plan["category"] = "quest"
                if q.get("relatedQuests") and not chains.get(quest_id, {}).get("prerequisitesVerified"):
                    gap("quest_chain_relationships_unverified", quest=quest_id, detail="Published travel order or related quests do not establish exact mandatory prerequisites, earlier unlocks or current availability.")
                elif q.get("legacyRecipeQuestReference") and not chains.get(quest_id, {}).get("prerequisitesVerified"):
                    gap("quest_chain_relationships_unverified", quest=quest_id, detail="Saved full quest reward/actor references do not establish earlier prerequisites or current unlock rules.")
                if not q["starts"]:
                    gap("quest_start_missing", quest=quest_id, detail="Do not present a turn-in as the starting NPC.")
                if q.get("starterOriginUnresolved"):
                    gap("quest_starter_origin_unverified", quest=quest_id, detail="Explicit item-started quest, but no safe starting-item destination; a turn-in is not the first step.")
                if q.get("sourceRequirementsUnresolved"):
                    gap("quest_source_access_unverified", quest=quest_id, detail="A published source requirement is known but its exact access threshold or current availability remains unresolved.")
        source_item = evidence.items.get(book_id if craft and book_id else item_id, {})
        if not own.get("disputed") and not source_item.get("disputed"):
            for seller in rows(source_item.get("sold-by")):
                if not seller.get("id"):
                    continue
                source_key, _ = evidence.source("npc", seller["id"], seller.get("name"))
                if any(x.get("kind") in ["vendor", "recipe_vendor"] and x.get("source") == source_key
                       and x.get("requiresFullSaleJoin") for x in extras):
                    continue
                offer = {k: seller[k] for k in ["cost", "stock", "avail", "standing", "reqfaction", "reqlevel", "side"] if k in seller}
                route("recipe_vendor" if craft else "vendor", source=source_key, bookItemID=book_id, offer=offer)
            for merchant in merchants.get(book_id if craft and book_id else item_id, []):
                if any(x.get("kind") in ["vendor", "recipe_vendor"] and x.get("source") == "npc:" + str(merchant["npcID"])
                       and x.get("requiresFullSaleJoin") for x in extras):
                    continue
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
            # A pure fishing source has useful zone directions, not an invented
            # precise spot. Broad enemy loot with incidental fishing stays generic.
            if not craft and not drops:
                for area in rows(source_item.get("fished-in")):
                    if area.get("id") and area.get("name"):
                        key, actor = evidence.source("zone", area["id"], area["name"], source_item.get("evidence"))
                        evidence.append_location(actor, evidence.location(area["name"], area["id"]))
                        route("fishing", source=key, verification="published-reference",
                              instructions="Published fishing-zone reference only. Exact spot or school, current fishing conditions, skill and event availability are unverified; no precise marker is established.")
                        plan["category"] = "fishing"
            # Random loot-table examples must never become a farm destination.
            fixed = len(drops) == 1 or (drops and len(drops) < 10 and all(x.get("classification") in [2, 3, 4] for x in drops))
            if fixed and ("named-enemy" in str(meta.get("confidence", "")) or craft and "book-drop-reference" in str(meta.get("confidence", ""))):
                for actor in drops:
                    if actor.get("id"):
                        key, _ = evidence.source("npc", actor["id"], actor.get("name"))
                        if any(x.get("kind") == "named_drop" and x.get("source") == key for x in extras):
                            continue
                        route("recipe_drop" if craft else "named_drop", source=key, bookItemID=book_id if craft else None, verification="published-reference")
            if not craft and not drops and not source_item.get("sold-by"):
                for obj in rows(source_item.get("contained-in-object")):
                    if obj.get("id"):
                        key, _ = evidence.source("object", obj["id"], obj.get("name"))
                        if any(r["kind"] == "object" and r.get("source") == key for r in plan["routes"]):
                            continue
                        back = evidence.full_object_contents.get(obj["id"], {}).get(item_id)
                        if not back or back.get("name") != gear["name"]:
                            gap("full_loot_join_unverified", key,
                                detail="An object reference needs independently read full exact contents before receiving a destination.")
                            continue
                        legacy = obj.get("classicEra") == 1 or back.get("classicEra") == 1
                        route("object", source=key, verification="legacy-reference" if legacy else "published-reference",
                              directionsOnly=True if legacy else None,
                              entranceOnly=True if any(loc["zone"] in data["instances"] for loc in evidence.sources[key]["locations"]) else None)
        if dungeon and dungeon.get("reconciledRole") not in ["crafted-item"]:
            plan["category"] = "dungeon_recipe" if craft else "dungeon"
            names = [name.strip() for name in dungeon.get("dungeon", "").split(" / ") if name.strip() in known_dungeons]
            if not names:
                gap("dungeon_identity_unverified", detail="A generic dungeon-pattern label is not an identified destination.")
            for name in names:
                route("dungeon", dungeon=name, boss=dungeon.get("enemy", ""),
                      verification=dungeon.get("confidence"), recipe=craft, bookItemID=book_id,
                      instructions=("Published possible recipe source; exact drop actor/current availability unverified. " if craft else "") + (dungeon.get("sourceSummary") or ""))
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
            q = None
            if entry["kind"] in ["quest", "quest_container"]:
                q = evidence.quests[str(entry["questID"])]
                keys = q["starts"] if q.get("starterOriginUnresolved") else q["starts"] + q["ends"]
            else:
                keys = [entry["source"]] if entry.get("source") else []
            source_locations = {}
            for key in keys:
                values = evidence.sources.get(key, {}).get("locations", [])
                zone = (q.get("actorZones") or {}).get(key) if q else None
                if zone:
                    values = [loc for loc in values if loc["zone"] == zone] or [dict(zone=zone, verification="published-reference")]
                source_locations[key] = values
            locations = [loc for values in source_locations.values() for loc in values]
            if entry.get("location"):
                locations.append(entry["location"])
            located = located or bool(locations) or entry["kind"] == "dungeon"
            if q:
                located = located or bool(q.get("starterZone") and q.get("starterInstructions")) or bool(q.get("turnInZone") and q.get("turnInInstructions"))
            exact = exact or (not entry.get("directionsOnly") and any(x["zone"] not in data["instances"] and coordinate(x.get("x")) and coordinate(x.get("y")) and x.get("verification") == "published-reference" for x in locations))
            for key in keys:
                if entry.get("directionsOnly"):
                    gap("map_target_withheld", key, entry.get("questID", ""),
                        "NPC/object target withheld; a separately resolved client instance entrance is geographic guidance, not current loot proof."
                        if entry.get("entranceOnly") else "Qualified written guidance only; do not promote this reference to a current map target.")
                if not source_locations[key]:
                    gap("source_coordinates_missing", key, entry.get("questID", ""), "Named source exists; precise location not established.")
                elif not any(coordinate(x.get("x")) and coordinate(x.get("y")) for x in source_locations[key]):
                    gap("precise_coordinate_unverified", key, entry.get("questID", ""), "Published area/roaming footprint only; no invented point or centroid.")
        expected = plan["category"] != "world_drop" or meta.get("originUnknown") is True or "named-enemy" in str(meta.get("confidence", "")) or bool(plan["routes"]) or bool(extras) or item_id in partial_hints or bool(own.get("contained-in-object") and not own.get("dropped-by"))
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
                         inGameRenderingVerified=0, gapRows=len(gaps), legacyRecipeQuestReferences=dict(evidence.legacy_stats))
    used_sources = set()
    for plan in data["items"].values():
        for entry in plan["routes"]:
            if entry.get("source"):
                used_sources.add(entry["source"])
            if entry["kind"] in ["quest", "quest_container"]:
                q = data["quests"][str(entry["questID"])]
                used_sources.update(q["starts"] + q["ends"] + q["objectives"])
                if q.get("objectiveSource") in evidence.sources:
                    used_sources.add(q["objectiveSource"])
    # Retain quest-chain actors too, without creating duplicate location records.
    for chain in chains.values():
        for quest_id in chain.get("steps", []):
            q = data["quests"].get(str(quest_id), {})
            used_sources.update(q.get("starts", []) + q.get("ends", []) + q.get("objectives", []))
            if q.get("objectiveSource") in evidence.sources:
                used_sources.add(q["objectiveSource"])
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
