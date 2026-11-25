"""Retrieve exact Forever tooltips. A retrieval is NOT whole-record verification.

Resumable bounded research only; never imported by the addon. No automatic retry
of rejected/empty pages. Raw response bytes, timestamps and failures are retained.
"""
import argparse
import concurrent.futures
import datetime
import gzip
import hashlib
import json
import subprocess
from pathlib import Path
from urllib.request import Request
from research_sources import research_open

ROOT = Path(__file__).resolve().parents[1]


def retrieve(task):
    kind, identifier = task
    url = f'https://nether.wowhead.com/forever/tooltip/{kind}/{identifier}'
    result = dict(url=url, entityIDs={kind: identifier}, retrievedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                  gameVersion='Forever 1.60.1 (published endpoint; live client build unobserved)',
                  evidenceKind='published-forever', lineage='Wowhead Forever tooltip endpoint; underlying collection/build unknown',
                  limitations=['Published tooltip does not prove live inventory, loot, prerequisites or availability.'])
    try:
        with research_open(Request(url, headers={'User-Agent': 'GetGear-SourceIntegrity/1.0'}), timeout=20) as response:
            body = response.read(500000)
            result.update(httpStatus=response.status, sha256=hashlib.sha256(body).hexdigest(), body=body.decode('utf-8'))
            parsed = json.loads(body)
            result['status'] = 'retrieved' if parsed.get('name') and parsed.get('tooltip') else 'missing-evidence'
    except Exception as error:
        result.update(status='missing-evidence', error=str(error))
    return str(identifier), result


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--workers', type=int, default=6)
    args = p.parse_args()
    assert 1 <= args.workers <= 8
    args.output.mkdir(parents=True, exist_ok=True)
    catalogue = json.loads(subprocess.check_output(['lua5.4', str(ROOT/'tools/export_navigation_inputs.lua'), str(ROOT)]))
    crafts = json.loads(subprocess.check_output(['lua5.4', str(ROOT/'tools/export_recipe_audit.lua'), str(ROOT)]))
    items = set(map(int, catalogue))
    spells = set()
    for craft in crafts.values():
        if craft.get('recipePatternItemID'): items.add(craft['recipePatternItemID'])
        if craft.get('recipeSpellID'): spells.add(craft['recipeSpellID'])
        for book in craft['normalized']['books']:
            items.add(book['itemID'])
    for kind, ids in [('item', items), ('spell', spells)]:
        path = args.output/(kind+'-tooltips.jsonl')
        done = set()
        if path.exists():
            for line in path.read_text().splitlines(): done.add(int(json.loads(line)['entityIDs'][kind]))
        pending = [(kind, id) for id in sorted(ids-done)]
        with path.open('a') as log, concurrent.futures.ThreadPoolExecutor(max_workers=args.workers) as pool:
            for count, (_, result) in enumerate(pool.map(retrieve, pending), 1):
                log.write(json.dumps(result, separators=(',', ':'))+'\n'); log.flush()
                if count % 250 == 0: print(kind, count, '/', len(pending), flush=True)
        compressed = args.output/(kind+'-tooltips.jsonl.gz')
        compressed.write_bytes(gzip.compress(path.read_bytes(), mtime=0))


if __name__ == '__main__': main()
