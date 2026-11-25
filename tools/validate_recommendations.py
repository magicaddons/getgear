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
from validate_feature_acceptance import validate_navigation_coverage

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--lua51', required=True)
    parser.add_argument('--luac51', required=True)
    parser.add_argument('--addon-root', type=Path, default=ROOT,
                        help='Extracted package to exercise; test fixtures remain outside the addon')
    args = parser.parse_args()
    addon_root = args.addon_root.resolve()
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / 'checks.txt').write_text('')
    env = dict(os.environ, PYTHONPYCACHEPREFIX=str(args.output.resolve() / 'pycache'))
    lua54, luac54 = shutil.which('lua5.4'), shutil.which('luac5.4')
    assert lua54 and luac54, 'Lua5.4 and luac5.4 must be on PATH'
    modules = [line.strip() for line in (addon_root / 'GetGear.toc').read_text().splitlines() if line.strip().endswith('.lua')]
    scripts = sorted((ROOT / 'tests').glob('*.lua'))
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

    run([sys.executable, 'tools/generate_star_textures.py', '--check'])
    run([sys.executable, 'tools/validate_feature_acceptance.py', '--root', addon_root])
    run([sys.executable, '-m', 'unittest', 'discover', '-s', 'tests/build', '-v'])
    for compiler in (luac54, args.luac51):
        for module in modules:
            run([compiler, '-p', addon_root / module])
        run([compiler, '-p', 'tools/export_navigation_inputs.lua'])
        run([compiler, '-p', 'tools/audit_recommendation_sources.lua'])
        run([compiler, '-p', 'tools/audit_faction_eligibility.lua'])
        run([compiler, '-p', 'tools/audit_navigation_pipeline.lua'])
    for script in scripts:
        run([lua54, script, addon_root])
        run([args.lua51, 'tools/release/lua51-harness.lua', script, addon_root])
    for script in ('reconcile-dungeon-link-guards.py', 'worlddrop-boe-fallback.py', 'navigation-generation.py', 'navigation-review-generation.py', 'navigation-location-review.py', 'stat-school-generation.py', 'faction-evidence-generation.py', 'recipe-evidence-generation.py'):
        run([sys.executable, ROOT / 'tests' / script])
    run([lua54, 'tools/audit_acquisition_buttons.lua', addon_root, args.output / 'button-coverage.csv'])
    run([lua54, 'tools/audit_navigation_pipeline.lua', addon_root, args.output / 'navigation'])
    validate_navigation_coverage(json.loads((args.output / 'navigation-summary.json').read_text()))
    run([sys.executable, 'tools/audit_acquisition_presentation.py', '--output', args.output / 'presentation'])
    run([sys.executable, 'tools/build_recipe_evidence.py', '--check'])
    run([sys.executable, 'tools/build_commerce_policy.py', '--check'])
    integrity_export=args.output/'integrity-export.json'
    with integrity_export.open('w') as output:
        subprocess.run([lua54, 'tools/export_integrity_audit.lua', addon_root],cwd=ROOT,env=env,stdout=output,check=True)
    run([sys.executable, 'tools/build_research_policy.py', '--export', integrity_export, '--check'])
    run([sys.executable, 'tools/build_navigation_review.py', '--check'])
    run([sys.executable, 'tools/audit_recipe_integrity.py', '--addon-root', addon_root, '--output', args.output / 'recipes'])
    run([sys.executable, 'tools/build_bag_quest_catalogue.py', '--check'])
    run([sys.executable, 'tools/build_faction_eligibility.py', '--check'])
    run([sys.executable, '-m', 'unittest', 'discover', '-s', 'tests/release', '-v'])
    with tempfile.TemporaryDirectory() as folder:
        alliance_audit = Path(folder) / 'alliance.csv'
        run([lua54, 'tools/audit_alliance_acquisition.lua', addon_root, alliance_audit])
        assert alliance_audit.read_bytes() == (ROOT / 'docs/alliance-acquisition/catalogue-access.csv').read_bytes()
        source_audit = Path(folder) / 'sources.csv'
        run([lua54, 'tools/audit_recommendation_sources.lua', addon_root, source_audit])
        assert source_audit.read_bytes() == (ROOT / 'docs/recommendation-audit/equipment-source-eligibility.csv').read_bytes()
        faction_audit = Path(folder) / 'factions.csv'
        run([lua54, 'tools/audit_faction_eligibility.lua', addon_root, faction_audit])
        assert faction_audit.read_bytes() == (ROOT / 'docs/faction-audit/catalogue-eligibility.csv').read_bytes()
    protected = json.loads((ROOT / 'docs/source-audit-1-60/reconciliation-20261109/presentation_data_snapshot.json').read_text())['files']
    assert all(hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == digest for name, digest in protected.items())
    summary = dict(checks=len(results), modules=len(modules), lua54Regressions=len(scripts),
                   lua51Regressions=len(scripts), failures=0,
                   protectedAcquisitionSnapshotExact=True, actualClientTested=False,
                   addonRoot=str(addon_root), cumulativeFeaturesVerified=True,
                   statement='Offline/synthetic validation only. No addon package, tag, release or live acquisition claim.')
    (args.output / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    print('PASS integrated development gate: ' + json.dumps(summary))


if __name__ == '__main__':
    main()
