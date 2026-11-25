"""Join fresh approved NPC/object/quest receipts without inferring live availability."""
import argparse
import collections
import gzip
import html
import json
import re
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
D=ROOT/'docs/source-integrity-20261124'


def identity(key):
    match=re.fullmatch(r'(npc|object):(\d+)',key)
    if match:return match[1],int(match[2])
    match=re.fullmatch(r'bagquest:\d+:([12]):(\d+)',key)
    if match:return ('npc' if match[1]=='1' else 'object'),int(match[2])


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--export',type=Path,required=True);a=p.parse_args()
    exported=json.loads(a.export.read_text())
    receipts=list(map(json.loads,gzip.decompress((D/'current-source-entities.jsonl.gz').read_bytes()).splitlines()))
    by_id={(next(iter(r['entityIDs'])),next(iter(r['entityIDs'].values()))):r for r in receipts}
    from build_research_policy import build
    projection,_=build(exported)
    rows=[]
    for category,records in [('source',exported['model']['sources']),('quest',exported['model']['quests'])]:
        for key,record in records.items():
            entity=('quest',int(key)) if category=='quest' else identity(key)
            receipt=by_id.get(entity,{})
            published=json.loads(receipt['body']) if receipt.get('status')=='retrieved' else {}
            match=bool(published and html.unescape(published['name'])==record.get('name'))
            row=dict(kind=category,record=key,entity=entity,recordedName=record.get('name'),publishedName=published.get('name'),
                     status='independently-verified-published-name' if match else 'publication-disagreement' if published else 'previously-sourced-currently-unverified',
                     url=receipt.get('url'),retrievedAt=receipt.get('retrievedAt'),sha256=receipt.get('sha256'),
                     publisherMap=published.get('map'),liveClientVerified=False,
                     limitations=['Current publication only; underlying collection build unknown.',
                                  'A name/map does not verify stock, teaching, loot, quest eligibility, prerequisites or full spawn extent.'])
            if category=='quest' and published:
                level=re.search(r'<b class="q0">Level (\d+)',published.get('tooltip',''))
                row['publishedDisplayedQuestLevel']=int(level[1]) if level else None
                row['minimumQuestLevelVerified']=False
                if record.get('previousPublishedName'):
                    row['status']='corrected-published-placeholder-title';row['previousName']=record['previousPublishedName']
            if category=='source' and key in projection['sourceActorAliases']:
                row['status']='withheld-duplicate-unverified-npc-alias';row['positiveObjectEvidence']=projection['sourceActorAliases'][key]
            rows.append(row)
    commerce=json.loads((D/'commerce-published-offers.json').read_text())
    original=json.loads((ROOT/'docs/source-integrity-20261124/validation-summary.json').read_text())
    summary=dict(requests=len(receipts),uniqueEntities=len(by_id),repeatRequests=len(receipts)-len(by_id),
                 retrievalCounts={kind:dict(collections.Counter(r['status']for r in by_id.values() if kind in r['entityIDs']))for kind in ['npc','object','quest']},
                 runtimeSourceRecords=len(exported['model']['sources']),questRecords=len(exported['model']['quests']),
                 nameStatuses=dict(collections.Counter(r['status']for r in rows)),
                 commerceAffiliationsVerifiedAsPublished=len(commerce['sources'])+len(commerce['opposingSources']),
                 commerceVendorCoordinateDisagreements=sum(v['coordinateDisputed']for v in commerce['sources'].values()),
                 actualClientObservations=0,wholeRecordVerification=False,
                 lastCompletedIntegratedGate=original)
    result=dict(summary=summary,records=rows,commerceSources=commerce['sources'],opposingCommerceSources=commerce['opposingSources'])
    (D/'entity-revalidation.json.gz').write_bytes(gzip.compress((json.dumps(result,indent=2)+'\n').encode(),mtime=0))
    (D/'entity-summary.json').write_text(json.dumps(summary,indent=2)+'\n')
    print(json.dumps(summary,indent=2))


if __name__=='__main__':main()
