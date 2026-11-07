#!/usr/bin/env python3
"""Stage a broad Forever equipment catalogue from a dated Wowhead-based cache.

Never overwrite hand-reviewed GetGear records. This importer only uses factual
identities, equip restrictions and broad source categories; the client tooltip
remains authoritative for live stats. Upstream is an Oct 21 beta snapshot, so
sources are expressly UNVERIFIED and must not be presented as live drop tables.

python3 tools/build_forever_catalog.py [--input /path/cache.json]
"""
import argparse
import collections
import hashlib
import html
import json
import re
import urllib.request
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
UPSTREAM = "https://raw.githubusercontent.com/Napalmsteak/WoW-Classic-Item-Caches/main/Forever%20Cache.json"
CLASSES = (
    "PRIEST", "MAGE", "WARLOCK", "DRUID", "ROGUE",
    "HUNTER", "SHAMAN", "WARRIOR", "PALADIN",
)
ALL = set(CLASSES)
ARMOR_CLASSES = {
    "Cloth": ALL,
    "Leather": ALL - {"PRIEST", "MAGE", "WARLOCK"},
    "Mail": {"HUNTER", "SHAMAN", "WARRIOR", "PALADIN"},
    "Plate": {"WARRIOR", "PALADIN"},
}
WEAPON_CLASSES = {
    "Sword": {"WARRIOR", "PALADIN", "ROGUE", "HUNTER", "MAGE", "WARLOCK"},
    "Axe": {"WARRIOR", "PALADIN", "ROGUE", "HUNTER", "SHAMAN"},
    "Mace": {"WARRIOR", "PALADIN", "ROGUE", "SHAMAN", "PRIEST", "DRUID"},
    "Dagger": {"WARRIOR", "ROGUE", "HUNTER", "PRIEST", "SHAMAN", "DRUID", "MAGE", "WARLOCK"},
    "Staff": {"WARRIOR", "HUNTER", "SHAMAN", "DRUID", "PRIEST", "MAGE", "WARLOCK"},
    "Polearm": {"WARRIOR", "PALADIN", "HUNTER", "DRUID"},
    "Fist Weapon": {"WARRIOR", "ROGUE", "HUNTER", "DRUID", "SHAMAN"},
    "Bow": {"WARRIOR", "ROGUE", "HUNTER"},
    "Gun": {"WARRIOR", "ROGUE", "HUNTER"},
    "Crossbow": {"WARRIOR", "ROGUE", "HUNTER"},
    "Thrown": {"WARRIOR", "ROGUE", "HUNTER"},
    "Wand": {"PRIEST", "MAGE", "WARLOCK"},
}
ARMOR_SLOT_WORDS = {
    "Head": "Head", "Neck": "Neck", "Shoulder": "Shoulder",
    "Chest": "Chest", "Waist": "Waist", "Legs": "Legs",
    "Feet": "Feet", "Wrist": "Wrist", "Hands": "Hands",
    "Back": "Back", "Finger": "Ring", "Trinket": "Trinket",
}
ARMOR_RE = re.compile(
    r"\b(Head|Shoulder|Chest|Waist|Legs|Feet|Wrist|Hands|Back)\s+"
    r"(Cloth|Leather|Mail|Plate)\b", re.I)
WEAPON_RE = re.compile(
    r"\b(One-Hand|Main Hand|Off Hand|Two-Hand|Ranged)\s+"
    r"(Sword|Axe|Mace|Dagger|Staff|Polearm|Fist Weapon|Bow|Gun|Crossbow|Thrown|Wand)\b", re.I)
REQ_RE = re.compile(r"\bRequires Level\s+(\d+)\b", re.I)
ILVL_RE = re.compile(r"\bItem Level\s+(\d+)\b", re.I)
QUALITY_RE = re.compile(r'<b[^>]*class=["\']q([0-7])["\']', re.I)
CLASS_RE = re.compile(r"\bClasses:\s*([A-Za-z ,]+)", re.I)
# Do not include gear that is visible only in another faction's reward tables.
HORDE_RACES = {"Orc", "Troll", "Tauren", "Undead"}
SOURCE_IDS = {"Other": 1, "Drop": 2, "Vendor": 3, "Quest": 4,
              "Crafted": 5, "Dungeon": 6, "PvP": 7}
SOURCE_TEXT = {
    1: "Source not documented",
    2: "World drop (route unverified)",
    3: "Vendor (availability unverified)",
    4: "Quest reward (eligibility unverified)",
    5: "Crafted gear (recipe details unverified)",
    6: "Dungeon (loot table unverified)",
    7: "PvP reward (requirements unverified)",
}


def plain_text(markup):
    # Only use text for identifying fields. Never transfer third-party HTML
    # into the addon or ask the client to execute HTML.
    x = re.sub(r"(?i)<br\s*/?>|</(?:td|tr|div|p|table)>", " ", markup)
    x = re.sub(r"<[^>]*>", " ", x)
    return re.sub(r"\s+", " ", html.unescape(x)).strip()


def classify_stat_role(text, kind, subtype):
    """Intentionally conservative: unknown/mixed stats remain eligible by default."""
    magical = bool(re.search(
        r"\b(?:intellect|spirit|spell(?:s| power| damage| hit| critical| crit)|"
        r"healing|mana(?: regeneration| per| restored)?|"
        r"shadow damage|fire damage|frost damage|nature damage|"
        r"arcane damage|holy damage)\b", text, re.I))
    physical = bool(re.search(
        r"\b(?:strength|agility|attack power|melee attack|ranged attack|"
        r"defense|parry|dodge|block(?:ing)?|armor penetration)\b", text, re.I))
    if magical and physical:
        return "mixed"
    if magical:
        return "spell"
    if physical:
        return "physical"
    # Ordinary melee weapons with no magical benefits are physical
    # leveling options, not caster upgrades. Wands are a caster exception.
    if kind == "weapon" and subtype != "Wand":
        return "physical"
    return "utility"


def parse_equipment(record):
    item_id = record.get("itemId")
    markup = record.get("tooltipHtml") or ""
    if not isinstance(item_id, int) or item_id < 1 or not markup:
        return None, "invalid-record"
    if record.get("itemExpansion") != "Forever":
        return None, "wrong-expansion"
    name = str(record.get("name") or "")
    if (item_id == 24358 or 281685 <= item_id <= 281729 or
        re.match(r"^(?:QATest|QA\s+Test|GM\s+Test)(?:\b|\W)", name, re.I)):
        return None, "internal-test-or-placeholder"
    diff = record.get("changeFromClassic") or {}
    if diff.get("status") == "unconfirmed":
        return None, "unconfirmed-forever-facts"
    quality = QUALITY_RE.search(markup)
    if not quality or int(quality.group(1)) < 2:
        return None, "not-green-or-better"
    text = plain_text(markup)
    # The item itself precedes durability, effects, set descriptions and source
    # annotations. Restrict slot detection to the equipment header.
    equip_header = re.split(
        r"\b(?:Durability|Requires Level|Equip:|Use:|Sell Price:|Item Set)\b",
        text, maxsplit=1)[0][:480]
    kind = None
    slot = None
    classes = None
    subtype = None
    armor = ARMOR_RE.search(equip_header)
    weapon = WEAPON_RE.search(equip_header)
    if armor:
        slot = ARMOR_SLOT_WORDS[armor.group(1).title()]
        subtype = armor.group(2).title()
        classes = set(ARMOR_CLASSES[subtype])
        kind = "armor"
    elif weapon:
        hand, subtype = weapon.group(1).lower(), weapon.group(2).title()
        classes = set(WEAPON_CLASSES.get(subtype, ()))
        if hand == "two-hand":
            slot = "Two-Hand Staff" if subtype == "Staff" else (
                "Two-Hand Polearm" if subtype == "Polearm"
                else "Two-Hand " + subtype)
            # Rogues only have one-handed axes, never two-handed axes.
            if subtype == "Axe":
                classes.discard("ROGUE")
            if subtype == "Mace":
                classes.discard("ROGUE")
            if subtype == "Sword":
                classes -= {"ROGUE", "MAGE", "WARLOCK"}
            if subtype == "Dagger":
                return None, "unsupported-two-hand-dagger"
        elif hand == "ranged":
            slot = "Wand" if subtype == "Wand" else "Ranged"
        elif hand == "off hand":
            slot = "Off Hand"
        else:
            slot = "Main Hand"
        kind = "weapon"
    elif re.search(r"\bOff Hand\s+Shield\b", equip_header, re.I):
        slot = "Off Hand"
        subtype = "Shield"
        classes = {"WARRIOR", "PALADIN", "SHAMAN"}
        kind = "armor"
    elif re.search(r"\bHeld In Off-hand\b", equip_header, re.I):
        slot = "Off Hand"
        subtype = "Held In Off-hand"
        classes = {"PRIEST", "MAGE", "WARLOCK", "DRUID", "SHAMAN", "PALADIN"}
        kind = "armor"
    elif re.search(r"\bRanged\s+Wand\b", equip_header, re.I):
        slot, subtype, classes, kind = "Wand", "Wand", set(WEAPON_CLASSES["Wand"]), "weapon"
    elif re.search(r"\bRanged\s+(?:Bow|Gun|Crossbow)\b", equip_header, re.I):
        subtype = re.search(r"\bRanged\s+(Bow|Gun|Crossbow)\b", equip_header, re.I).group(1).title()
        slot, classes, kind = "Ranged", set(WEAPON_CLASSES[subtype]), "weapon"
    elif re.search(r"\bThrown\b", equip_header, re.I) and re.search(r"\bRanged\b", equip_header, re.I):
        slot, subtype, classes, kind = "Thrown", "Thrown", set(WEAPON_CLASSES["Thrown"]), "weapon"
    elif re.search(r"\bIdol\b", equip_header):
        slot, subtype, classes, kind = "Relic", "Idol", {"DRUID"}, "armor"
    elif re.search(r"\bLibram\b", equip_header):
        slot, subtype, classes, kind = "Relic", "Libram", {"PALADIN"}, "armor"
    elif re.search(r"\bTotem\b", equip_header):
        slot, subtype, classes, kind = "Relic", "Totem", {"SHAMAN"}, "armor"
    elif re.search(r"\b(Neck|Finger|Trinket)\b", equip_header, re.I):
        x = re.search(r"\b(Neck|Finger|Trinket)\b", equip_header, re.I).group(1).title()
        slot, subtype, classes, kind = ARMOR_SLOT_WORDS[x], "Jewelry", set(ALL), "armor"
    else:
        return None, "unsupported-or-unknown-slot"
    if not classes:
        return None, "no-class-proficiency"
    match = REQ_RE.search(text)
    if match:
        required_level = int(match.group(1))
    else:
        # A missing level on a high item is not proof it can be used at 1.
        ilvl = ILVL_RE.search(text)
        if not ilvl or int(ilvl.group(1)) > 10:
            return None, "no-proven-equip-level"
        required_level = 1
    if not 1 <= required_level <= 60:
        return None, "outside-level-range"
    if re.search(r"\b(?:Horde Only|Requires Horde)\b", text, re.I):
        return None, "horde-only"
    # Class-restricted items (including BoP epics and some PvP gear) may be
    # worn only by the listed class(es), even if another class could equip
    # the armor type. Keep only explicit matches.
    classmatch = CLASS_RE.search(text)
    if classmatch:
        stated = {token for token in CLASSES
                  if re.search(r"\b" + token + r"\b", classmatch.group(1), re.I)}
        if stated:
            classes &= stated
    races = re.search(r"\bRaces:\s*([A-Za-z ,]+)", text, re.I)
    if races:
        allowed = {race for race in (
            "Human", "Dwarf", "Night Elf", "Gnome",
            "Orc", "Troll", "Tauren", "Undead") if race.lower() in races.group(1).lower()}
        if allowed and not (allowed - HORDE_RACES):
            return None, "horde-race-only"
        # Race-filtered items need a separate live-client check; don't
        # accidentally recommend them to a race that cannot equip them.
        if allowed:
            return None, "race-restricted-needs-review"
    if not classes:
        return None, "class-restriction"
    source_kinds = [x for x in record.get("sourceTypes", []) if x in SOURCE_IDS]
    source_code = SOURCE_IDS[source_kinds[0]] if source_kinds else SOURCE_IDS["Other"]
    labels = record.get("sourceLabels") or []
    label = ", ".join(dict.fromkeys(str(x) for x in labels if x and x != "Unknown source"))[:85]
    mask = sum(2 ** i for i, class_token in enumerate(CLASSES) if class_token in classes)
    phase = max((int(x) for x in record.get("sourcePhases", [])
                 if isinstance(x, int)), default=1)
    return {
        "id": item_id, "name": str(record.get("name") or ""), "level": required_level,
        "slot": slot, "subtype": subtype, "kind": kind, "source": source_code,
        "statRole": classify_stat_role(text, kind, subtype),
        "sourceLabel": label, "mask": mask, "phase": phase,
        "craftOnly": "Crafted" in source_kinds and
                     not any(x in source_kinds for x in ("Dungeon", "Quest", "Vendor", "Drop", "PvP")),
    }, None


def lua_quote(value):
    # ensure_ascii=False avoids JSON \\u sequences, which Lua 5.4 does not
    # understand. All source values are JSON strings with escaped quotes.
    return json.dumps(value, ensure_ascii=False)


def write_lua(records, path, digest):
    out = [
        "local addonName, GetGear = ...",
        "-- Generated from Napalmsteak/WoW-Classic-Item-Caches, Forever Cache.json.",
        "-- Upstream beta item facts last refreshed 2026-10-21; not live-source evidence.",
        "-- Raw cache sha256: " + digest,
        "-- DO NOT use Classic-era source labels as confirmed Forever drop locations.",
        "local CLASSES = {" + ",".join(lua_quote(x) for x in CLASSES) + "}",
        "local SOURCES = {" + ",".join(lua_quote(SOURCE_TEXT[i]) for i in sorted(SOURCE_TEXT)) + "}",
        "local DEFAULT_NOTE = 'Forever client item. Where/how to obtain it is not verified on the live server.'",
        "-- Rows: itemID, name, equip-level, slot, subtype, sourceCode, classMask, sourceLabel, phase, craftOnly, statRole.",
        "local rows = {",
    ]
    for x in records:
        vals = (
            str(x["id"]), lua_quote(x["name"]), str(x["level"]),
            lua_quote(x["slot"]), lua_quote(x["subtype"]), str(x["source"]),
            str(x["mask"]), lua_quote(x["sourceLabel"]), str(x["phase"]),
            "true" if x["craftOnly"] else "false", lua_quote(x["statRole"]),
        )
        out.append("    {" + ",".join(vals) + "},")
    out += [
        "}",
        "local audit={newItems=0,newObjectives=0,existingItems=0,byClass={}}",
        "for _,r in ipairs(rows) do",
        "    local id,name,level,slot,subtype,sourceCode,mask,sourceLabel,phase,craftOnly,role =",
        "        r[1],r[2],r[3],r[4],r[5],r[6],r[7],r[8],r[9],r[10],r[11]",
        "    if not GetGear.ItemCatalog[id] then",
        "        local description=SOURCES[sourceCode] or SOURCES[1]",
        "        local zone=(sourceLabel~='' and sourceLabel or 'Source not yet confirmed')",
        "        if phase>1 then zone=zone..' (future phase possible)' end",
        "        assert(GetGear:RegisterItem({",
        "            itemID=id,name=name,availableLevel=level,slot=slot,",
        "            sourceType=description,source=description,zone=zone,",
        "            sourceURL='https://www.wowhead.com/forever/item='..id,",
        "            confidence='client',acquisitionConfidence='classic-reference',",
        "            acquisitionKind=description,craftOnly=craftOnly,",
        "            fromGeneratedCache=true,armorType=subtype,statRole=role,",
        "            notes=DEFAULT_NOTE,",
        "            instructions='Client-indexed equipment; specific drop, quest, vendor,'",
        "                ..' or recipe access is unverified in live WoW Forever.',",
        "        }), 'generated catalogue item collision '..id)",
        "        audit.newItems=audit.newItems+1",
        "    else",
        "        audit.existingItems=audit.existingItems+1",
        "    end",
        "    for i,classToken in ipairs(CLASSES) do",
        "        if math.floor(mask / (2 ^ (i-1))) % 2 >= 1 then",
        "            local goal = level",
        "            if subtype=='Mail' and (classToken=='HUNTER' or classToken=='SHAMAN') then",
        "                goal=math.max(40,goal)",
        "            elseif subtype=='Plate' then",
        "                goal=math.max(40,goal)",
        "            end",
        "            local progressID='item_'..id",
        "            local idx=GetGear.RecommendationIndex and GetGear.RecommendationIndex[classToken]",
        "            local exists=idx and idx.ids[progressID]",
        "            if not idx then",
        "                for _,old in ipairs(GetGear.Recommendations[classToken] or {}) do",
        "                    if old.itemID==id then exists=true;break end",
        "                end",
        "            end",
        "            if not exists then",
        "                assert(GetGear:AddRecommendation(classToken,{",
        "                    itemID=id,targetLevel=goal,focus='All',",
        "                }), 'generated recommendation failed '..id..' '..classToken)",
        "                audit.newObjectives=audit.newObjectives+1",
        "                audit.byClass[classToken]=(audit.byClass[classToken] or 0)+1",
        "            end",
        "        end",
        "    end",
        "end",
        "GetGear.GeneratedForeverGear=audit",
        "",
    ]
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(out), encoding="utf-8")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, help="Use a previously downloaded cache")
    parser.add_argument("--output", type=Path, default=REPO / "GeneratedForeverGear.lua")
    parser.add_argument("--report", type=Path, default=REPO / "docs" / "generated-forever-audit.json")
    args = parser.parse_args()
    if args.input:
        data_bytes = args.input.read_bytes()
    else:
        req = urllib.request.Request(UPSTREAM, headers={"User-Agent": "GetGear data audit"})
        with urllib.request.urlopen(req, timeout=75) as response:
            data_bytes = response.read(30_000_000)
    digest = hashlib.sha256(data_bytes).hexdigest()
    source = json.loads(data_bytes)
    if not isinstance(source, list) or len(source) < 10000:
        raise ValueError("The Forever cache is unexpectedly small or invalid")
    rejected = collections.Counter()
    found = {}
    for record in source:
        result, reason = parse_equipment(record)
        if reason:
            rejected[reason] += 1
        else:
            if result["id"] in found:
                raise ValueError("Duplicate upstream item ID: " + str(result["id"]))
            found[result["id"]] = result
    rows = [found[k] for k in sorted(found)]
    for item_id, slot, level in ((3473, "Legs", 8), (3489, "Main Hand", 12), (14154, "Chest", 57)):
        item = found.get(item_id)
        if not item or item["slot"] != slot or item["level"] != level:
            raise ValueError("Sentinel item missing/misclassified: " + str(item_id) + " " + str(item))
    if found[14154]["mask"] != (1 << CLASSES.index("PRIEST")):
        raise ValueError("Truefaith Vestments must be Priest-only")
    for test_id in (24358, 281685, 281701):
        if test_id in found:
            raise ValueError("QA/restoration placeholder incorrectly included: "+str(test_id))
    write_lua(rows, args.output, digest)
    counts = collections.Counter()
    bands = collections.Counter()
    for r in rows:
        for i, cls in enumerate(CLASSES):
            if (r["mask"] // 2**i) % 2:
                counts[cls] += 1
        bands["1-15" if r["level"] <= 15 else "16-30" if r["level"] <= 30
              else "31-45" if r["level"] <= 45 else "46-60"] += 1
    report = {
        "upstream": UPSTREAM, "sha256": digest,
        "sourceLastRefresh": max(str(r.get("lastUpdatedAt", "")) for r in source),
        "upstreamItems": len(source), "importableItems": len(rows),
        "eligibleClassCount": dict(sorted(counts.items())),
        "levelBandCount": dict(sorted(bands.items())),
        "rejectReasons": dict(sorted(rejected.items())),
        "statRoleCounts": dict(sorted(collections.Counter(x["statRole"] for x in rows).items())),
        "warning": "Client/beta existence is not a live drop or quest guarantee; original GetGear records override generated facts",
    }
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
