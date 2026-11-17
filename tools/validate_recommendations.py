#!/usr/bin/env python3
"""Run the integrated offline gate without packaging or publishing an addon."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import time

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--lua51', required=True)
    parser.add_argument('--luac51', required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / 'checks.txt').write_text('')
    env = dict(os.environ, PYTHONPYCACHEPREFIX=str(args.output.resolve() / 'pycache'))
    lua54, luac54 = shutil.which('lua5.4'), shutil.which('luac5.4')
    assert lua54 and luac54, 'Lua5.4 and luac5.4 must be on PATH'
    modules = [line.strip() for line in (ROOT / 'GetGear.toc').read_text().splitlines() if line.strip().endswith('.lua')]
    results = []

    def run(command):
        start = time.monotonic()
        process = subprocess.run(list(map(str, command)), cwd=ROOT, env=env, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        result = dict(command=list(map(str, command)), exitCode=process.returncode, seconds=round(time.monotonic() - start, 3))
        results.append(result)
        with (args.output / 'checks.txt').open('a') as log:
            log.write('$ ' + ' '.join(result['command']) + '\n' + process.stdout + '\n')
        print(('PASS ' if process.returncode == 0 else 'FAIL ') + ' '.join(result['command']), flush=True)
        (args.output / 'checks.json').write_text(json.dumps(results, indent=2) + '\n')
        assert process.returncode == 0, process.stdout

    for compiler in (luac54, args.luac51):
        for module in modules:
            run([compiler, '-p', module])
        run([compiler, '-p', 'tools/export_navigation_inputs.lua'])
        run([compiler, '-p', 'tools/audit_recommendation_sources.lua'])
        run([compiler, '-p', 'tools/audit_faction_eligibility.lua'])
    for script in sorted((ROOT / 'tests').glob('*.lua')):
        run([lua54, script, '.'])
        run([args.lua51, 'tools/release/lua51-harness.lua', script, '.'])
    for script in ('reconcile-dungeon-link-guards.py', 'worlddrop-boe-fallback.py', 'navigation-generation.py', 'stat-school-generation.py', 'faction-evidence-generation.py'):
        run([sys.executable, ROOT / 'tests' / script])
    run([lua54, 'tools/audit_acquisition_buttons.lua', '.'])
    run([sys.executable, 'tools/audit_acquisition_presentation.py', '--output', args.output / 'presentation'])
    run([sys.executable, 'tools/build_bag_quest_catalogue.py', '--check'])
    run([sys.executable, 'tools/build_faction_eligibility.py', '--check'])
    run([sys.executable, '-m', 'unittest', 'discover', '-s', 'tests/release', '-v'])
    with tempfile.TemporaryDirectory() as folder:
        source_audit = Path(folder) / 'sources.csv'
        run([lua54, 'tools/audit_recommendation_sources.lua', '.', source_audit])
        assert source_audit.read_bytes() == (ROOT / 'docs/recommendation-audit/equipment-source-eligibility.csv').read_bytes()
        faction_audit = Path(folder) / 'factions.csv'
        run([lua54, 'tools/audit_faction_eligibility.lua', '.', faction_audit])
        assert faction_audit.read_bytes() == (ROOT / 'docs/faction-audit/catalogue-eligibility.csv').read_bytes()
    protected = json.loads((ROOT / 'docs/source-audit-1-60/reconciliation-20261109/presentation_data_snapshot.json').read_text())['files']
    assert all(hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == digest for name, digest in protected.items())
    summary = dict(checks=len(results), modules=len(modules), lua54Regressions=len(list((ROOT / 'tests').glob('*.lua'))),
                   lua51Regressions=len(list((ROOT / 'tests').glob('*.lua'))), failures=0,
                   protectedAcquisitionSnapshotExact=True, actualClientTested=False,
                   statement='Offline/synthetic validation only. No addon package, tag, release or live acquisition claim.')
    (args.output / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    print('PASS integrated development gate: ' + json.dumps(summary))


if __name__ == '__main__':
    main()
