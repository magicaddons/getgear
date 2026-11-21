#!/usr/bin/env python3
"""Run required fresh reconciliation diagnostically; retain approved UI-test data.

No HTTP replay/fallback and no source adoption. The user requested presentation
work against the existing acquisition data. Keep complete fresh-response and
changed-output evidence outside the source tree, including on failure.
"""
import argparse
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
MANIFEST=ROOT/'docs/source-audit-1-60/reconciliation-20261109/presentation_data_snapshot.json'

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--diagnostics',type=Path)
    p.add_argument('--verify-only',action='store_true')
    a=p.parse_args();manifest=json.loads(MANIFEST.read_text());saved={}
    sha=lambda b:hashlib.sha256(b).hexdigest()
    for name,digest in manifest['files'].items():
        path=ROOT/name
        assert path.resolve().is_relative_to(ROOT) and not path.is_symlink(),name
        body=path.read_bytes();assert sha(body)==digest,('Approved presentation snapshot changed',name)
        saved[name]=body
    if a.verify_only:
        print('PASS presentation data snapshot:all17generated data/report files exact;no source adoption')
        return
    assert a.diagnostics is not None,'Diagnostics directory required'
    out=a.diagnostics.resolve();assert not out.is_relative_to(ROOT),'Keep fresh unadopted outputs outside the source tree'
    out.mkdir(parents=True,exist_ok=True);changed={};code=None
    try:
        command=[sys.executable,str(ROOT/'tools/capture_acquisition_audit.py'),'presentation', '--output-root',str(out)]
        code=subprocess.run(command,cwd=ROOT,check=False).returncode
    finally:
        for name,body in saved.items():
            path=ROOT/name;fresh=path.read_bytes() if path.exists() else None
            if fresh!=body:
                target=out/'unadopted-generated'/name;target.parent.mkdir(parents=True,exist_ok=True)
                if fresh is not None:target.write_bytes(fresh)
                changed[name]={'approvedSHA256':sha(body),'freshUnadoptedSHA256':sha(fresh) if fresh is not None else None}
                path.write_bytes(body)
        proof={'scope':manifest['scope'],'approvedBaseline':manifest['baselineRef'],'reconciliationExitCode':code,'freshChangesNotAdopted':changed,'snapshotRestoredExactly':all((ROOT/n).read_bytes()==b for n,b in saved.items()),'httpResponsesReplayed':False}
        (out/'PRESENTATION_SNAPSHOT_RECONCILIATION.json').write_text(json.dumps(proof,indent=2)+'\n')
    assert code==0,('Fresh reconciliation failed;approved data preserved',code)
    assert proof['snapshotRestoredExactly']
    print('PASS diagnostic reconciliation:original HTTP responses captured;approved presentation data restored;no new acquisition facts adopted')

if __name__=='__main__':
    main()
