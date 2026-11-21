#!/usr/bin/env python3
"""Catalogue-wide independent recipe property and additive-source audit, offline."""
import argparse
import collections
import csv
import json
from pathlib import Path
import subprocess

ROOT=Path(__file__).resolve().parents[1]


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--addon-root',type=Path,default=ROOT);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    a.output.mkdir(parents=True,exist_ok=True)
    baseline=json.loads((ROOT/'docs/recipe-audit/baseline.json').read_text())
    current=json.loads(subprocess.check_output(['lua5.4',str(ROOT/'tools/export_recipe_audit.lua'),str(a.addon_root)],text=True))
    assert set(current)==set(baseline) and len(current)==1254
    rows=[];improved=0;preserved=0;methods=collections.Counter();professions=collections.Counter()
    for key,item in current.items():
        old=baseline[key];assert all(item[k]==old[k] for k in ['itemID','name','profession'])
        if old.get('minimum') is not None:
            assert item.get('minimum')==old['minimum'],('Existing minimum changed',key)
            preserved+=1
        elif item.get('minimum') is not None:improved+=1
        routes=(item.get('plan')or{}).get('routes',[])
        for route in (old.get('plan')or{}).get('routes',[]):assert route in routes,('Lost original source',key,route)
        n=item['normalized'];professions[item['profession']]+=1
        for source in n['sources']:methods[source['kind']]+=1
        rows.append(dict(itemID=item['itemID'],name=item['name'],profession=item['profession'],
                         craftingSkill=n.get('craftingSkill'),learningSkill=n.get('learningSkill'),
                         effectiveMinimum=item.get('minimum'),skillConfidence=n['skillConfidence'],
                         sourceConfidence=n['sourceConfidence'],sourceAlternatives=len(routes),
                         documentedDropEnemies=len(n['documentedDrops']),summary=item['summary']))
    assert improved==104 and preserved==1135
    rows.sort(key=lambda x:x['itemID'])
    with (a.output/'catalogue.csv').open('w',newline='')as f:
        w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
    result=dict(crafts=len(current),professions=dict(professions),sourceCategories=dict(methods),
                preservedKnownMinima=preserved,correctedMissingMinima=improved,
                knownMinima=preserved+improved,unresolvedMinima=[r for r in rows if r['effectiveMinimum'] is None],
                originalAcquisitionAlternativesPreserved=True,actualClientVerified=False)
    (a.output/'summary.json').write_text(json.dumps(result,indent=2)+'\n')
    print('PASS recipe catalogue:1254 crafts/six professions,1135 existing minima and every original route preserved,104 corrected minima,15 explicitly unresolved')

if __name__=='__main__':main()
