"""Collect resumable independent lists and full entity pages; never change runtime.

Run with a runtime export and an output directory outside the checkout. Existing
receipts (including failures) are reused. No blacklisted or quarantined input is
downloaded. Discovery is partitioned independently of GetGear's equipment IDs.
"""
import argparse
import concurrent.futures
import gzip
import json
from pathlib import Path

from catalogue_verification import Archive, listview

ROOT = Path(__file__).resolve().parents[1]
BASE = 'https://www.wowhead.com/forever/'
PROFESSIONS = ('blacksmithing','leatherworking','tailoring','engineering','enchanting','alchemy','cooking','first-aid')
SLOTS = {'armor': (1,2,3,4,5,6,7,8,9,10,11,12,14,16,19,20,23,28),
         'weapons': (13,15,17,21,22,25,26)}


def collect(archive, urls):
    urls = sorted(set(urls) - archive.receipts.keys())
    with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
        count = 0
        for offset in range(0, len(urls), 6):
            batch = list(pool.map(archive.fetch, urls[offset:offset+6]))
            for row in batch:
                archive.record(row)
                count += 1
            if count % 100 < 6 or count == len(urls):
                print('Archived', count, '/', len(urls), flush=True)
            if sum('403' in row.get('error','') or '429' in row.get('error','') for row in batch) >= 3:
                print('Provider access block; collection paused with pending URLs retained by the deterministic plan.', flush=True)
                return False
    return True


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--export', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    export = json.loads(args.export.read_text())
    archive = Archive(args.output)
    inventory = [BASE+'items/'+category+'/slot:'+str(slot)+'/max-req-level:60'
                 for category, slots in SLOTS.items() for slot in slots]
    inventory += [BASE+'spells/'+('secondary-skills/' if profession in ('cooking','first-aid') else 'professions/')+profession for profession in PROFESSIONS]
    if not collect(archive, inventory): return
    partitions = []
    for url in inventory:
        row = archive.receipts[url]
        if row['status'] != 'retrieved': continue
        page = archive.read(row)
        if '_truncated: 1' in page:
            if '/items/' in url:
                base = url.rsplit('/max-req-level:',1)[0]
                partitions += [base+'/min-req-level:'+str(lo)+'/max-req-level:'+str(hi)
                               for lo, hi in ((0,30),(31,50),(51,59),(60,60))]
    if not collect(archive, partitions): return
    # A level-60 partition can still be capped. Quality subdivisions preserve
    # unknown/removed records as candidates rather than silently dropping them.
    quality_partitions = []
    for url in partitions:
        row = archive.receipts[url]
        if row['status'] == 'retrieved' and '_truncated: 1' in archive.read(row):
            quality_partitions += [url+'/quality:'+str(quality) for quality in range(8)]
    if not collect(archive, quality_partitions): return
    (args.output/'inventory-urls.json').write_text(json.dumps(inventory+partitions+quality_partitions,indent=2)+'\n')
    previous = ROOT/'docs/source-integrity-20261124'
    tooltips = [json.loads(line) for line in gzip.decompress((previous/'current-item-tooltips.jsonl.gz').read_bytes()).splitlines()]
    full = [BASE+'item='+str(row['entityIDs']['item']) for row in tooltips if row['status']!='retrieved']
    for item in export['items'].values():
        if item.get('profession') and item.get('recipeSpellID'):
            full.append(BASE+'spell='+str(item['recipeSpellID']))
    # Full source pages expose independently indexed stock, teaching, drops and
    # quest rewards. Discovery does not assume that an existing route is true.
    entities = [json.loads(line) for line in gzip.decompress((previous/'current-source-entities.jsonl.gz').read_bytes()).splitlines()]
    for receipt in entities:
        kind, identifier = next(iter(receipt['entityIDs'].items()))
        full.append(BASE+kind+'='+str(identifier))
    commerce = json.loads((previous/'commerce-published-offers.json').read_text())
    full += [BASE+'item='+identifier for identifier in commerce['offers']]
    full += [BASE+'spell=1248665', BASE+'item=249539',
             BASE+'guide/azeroth-commerce-authority-reputation-professions',
             'https://worldofwarcraft.blizzard.com/en-us/news/24315281/wow-forever-hotfixes-november-10-2026']
    collect(archive, full)
    print('Persistent evidence archive:', args.output, flush=True)


if __name__ == '__main__': main()
