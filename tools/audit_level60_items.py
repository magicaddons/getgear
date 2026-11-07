#!/usr/bin/env python3
"""Audit staged Forever equipment identity/level against AHledger's public item API.

Read-only. This audit never modifies addon data and doesn't assert that a
client item is obtainable in the live game. No account credentials required.

Usage:
    python3 tools/audit_level60_items.py
    python3 tools/audit_level60_items.py --strict
"""
import argparse
import json
import re
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "Level60GearPhase1.lua"
RECORD = re.compile(r'^\s*T\((\d+),"([^"]+)",(\d+),"([^"]+)"', re.MULTILINE)
BASE_URL = "https://api.ahledger.com/v1/items/"
CREDIT = "Prices from AHledger (ahledger.com)"


def catalog_records():
    source = SOURCE.read_text(encoding="utf-8")
    rows = [
        {"id": int(item_id), "name": name, "level": int(level), "slot": slot}
        for item_id, name, level, slot in RECORD.findall(source)
    ]
    if not rows:
        raise ValueError("No staged items found")
    ids = [row["id"] for row in rows]
    if len(ids) != len(set(ids)):
        raise ValueError("Duplicate staged item IDs")
    return rows


def fetch(item_id, attempts=2):
    url = f"{BASE_URL}{item_id}?game=forever"
    request = urllib.request.Request(
        url, headers={"User-Agent": "GetGear-1-60-data-audit/1.0"}
    )
    for attempt in range(attempts):
        try:
            with urllib.request.urlopen(request, timeout=15) as response:
                return json.load(response)
        except urllib.error.HTTPError as error:
            if error.code in (429, 503) and attempt + 1 < attempts:
                time.sleep(min(5, int(error.headers.get("Retry-After") or 2)))
                continue
            raise


def check(row, payload):
    issues = []
    if payload.get("id") != row["id"]:
        issues.append(f"ID mismatch {payload.get('id')!r}")
    actual_name = payload.get("name")
    if not actual_name or actual_name.casefold() != row["name"].casefold():
        issues.append(f"name: addon={row['name']!r}, API={actual_name!r}")
    required = payload.get("requiredLevel")
    if required is None:
        issues.append("equip requirement absent in API")
    elif isinstance(required, bool) or not isinstance(required, int):
        issues.append(f"unreadable requiredLevel={required!r}")
    elif required != row["level"]:
        issues.append(f"equip level: addon={row['level']}, API={required}")
    # Item class alone does not prove an item's weapon skill, faction or
    # acquisition. Those must be checked independently in the live game.
    return issues


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--strict", action="store_true",
                        help="fail if any item mismatches or cannot be checked")
    parser.add_argument("--delay", type=float, default=0.4)
    args = parser.parse_args()
    rows = catalog_records()
    mismatches = 0
    unavailable = 0
    print("AHledger is third-party client-indexed data, not a source of live drop guarantees.")
    print(CREDIT)
    for row in rows:
        try:
            payload = fetch(row["id"])
            issues = check(row, payload)
            status = "CHECK" if issues else "PASS"
            print(f"{status}: {row['id']} {row['name']} | " +
                  (", ".join(issues) if issues else "name and equip level agree"))
            mismatches += bool(issues)
        except (urllib.error.URLError, TimeoutError, json.JSONDecodeError,
                ValueError) as error:
            unavailable += 1
            print(f"UNAVAILABLE: {row['id']} {row['name']}: {type(error).__name__} {error}")
        time.sleep(max(0, args.delay))
    print(f"Audited {len(rows)} items: {len(rows)-mismatches-unavailable} match, "
          f"{mismatches} mismatch, {unavailable} unavailable")
    if args.strict and (mismatches or unavailable):
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
