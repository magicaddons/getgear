#!/usr/bin/env python3
"""Identical production-path workloads; synthetic CPU/heap, never client FPS."""
import argparse
import json
from pathlib import Path
import platform
import re
import statistics
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
BASELINE = 'b08945d44fd454c13446a322bedbb58b1acc77fa'


def run(lua, root, baseline, output):
    test = ROOT / 'tests/overlay-performance.lua'
    # The existing 5.1 harness supplies load(..., environment) compatibility.
    # Use a tiny external launcher to pass the benchmark-only mode unchanged.
    with tempfile.TemporaryDirectory() as folder:
        launcher = Path(folder) / 'launch.lua'
        launcher.write_text('arg[0]=' + json.dumps(str(test)) + '\narg[2]=' +
                            ('"baseline"' if baseline else 'nil') + '\nassert(loadfile(arg[0]))()\n')
        command = [lua, str(ROOT / 'tools/release/lua51-harness.lua'), str(launcher), str(root)] if '5.1' in Path(lua).name else [lua, str(test), str(root)] + (['baseline'] if baseline else [])
        result = subprocess.run(command, cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    output.write_text('$ ' + ' '.join(command) + '\n' + result.stdout)
    if result.returncode:
        raise RuntimeError(str(output) + ': ' + result.stdout[-2000:])
    rows = {}
    signatures = {}
    for line in result.stdout.splitlines():
        match = re.fullmatch(r'MEASURE (.*): ([\d.]+)ms; net heap (-?[\d.]+)KiB; (.*)', line)
        if match:
            counts = {key: int(value) for key, value in re.findall(r'(\w+)=(\d+)', match[4])}
            rows[match[1]] = dict(milliseconds=float(match[2]), netHeapKB=float(match[3]), counts=counts)
        if line.startswith('SIGNATURE '):
            label, value = line[len('SIGNATURE '):].rsplit(' ', 1)
            signatures[label] = int(value)
    heap = float(re.search(r'HEAP one refresh with GC paused: ([\d.]+)KiB', result.stdout)[1])
    shared = [int(x) for x in re.search(r'SHARED separate routes=(\d+) sources=(\d+); shared routes=(\d+) sources=(\d+)', result.stdout).groups()]
    return dict(scenarios=rows, signatures=signatures, gcPausedHeapGrowthKB=heap,
                separateRoutes=shared[0], separateSources=shared[1], sharedRoutes=shared[2], sharedSources=shared[3])


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--baseline-root', type=Path, required=True)
    p.add_argument('--addon-root', type=Path, default=ROOT)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--lua51', required=True)
    p.add_argument('--lua54', required=True)
    p.add_argument('--repeats', type=int, default=3)
    a = p.parse_args()
    assert a.repeats >= 1
    a.output.mkdir(parents=True, exist_ok=False)
    # Verify the unmodified baseline payload against Git objects, not its label.
    for name in ['GetGear.toc', 'MapPin.tga'] + [line.strip() for line in (ROOT / 'GetGear.toc').read_text().splitlines() if line.strip().endswith('.lua')]:
        assert (a.baseline_root / name).read_bytes() == subprocess.check_output(['git', 'show', BASELINE + ':' + name], cwd=ROOT), name
    report = dict(baselineCommit=BASELINE, implementationRevision=subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
                  implementationHasUncommittedChanges=bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT)),
                  platform=platform.platform(), repeats=a.repeats, actualClientTested=False,
                  qualification='Sequential identical workloads; median synthetic CPU times. Inclusive profile times overlap. Net heap is GC-sensitive; GC-paused Lua growth is a proxy, not a client allocation counter.', interpreters={})
    for version, lua in [('5.1', a.lua51), ('5.4', a.lua54)]:
        samples = {label: [] for label in ('baseline', 'implementation')}
        for repeat in range(a.repeats):
            for label, root in [('baseline', a.baseline_root), ('implementation', a.addon_root)]:
                samples[label].append(run(lua, root.resolve(), label == 'baseline', a.output / f'lua{version}-{label}-{repeat + 1}.txt'))
        assert all(s['signatures'] == samples['baseline'][0]['signatures'] for group in samples.values() for s in group)
        comparisons = {}
        for label in samples['baseline'][0]['scenarios']:
            values = {}
            for cohort, group in samples.items():
                counts = [s['scenarios'][label]['counts'] for s in group]
                assert all(c == counts[0] for c in counts), (cohort, label, counts)
                values[cohort] = dict(medianMilliseconds=statistics.median(s['scenarios'][label]['milliseconds'] for s in group), counts=counts[0])
            old, new = values['baseline']['medianMilliseconds'], values['implementation']['medianMilliseconds']
            values['timeChangePercent'] = round((new / old - 1) * 100, 2) if old else None
            comparisons[label] = values
        report['interpreters'][version] = dict(executable=lua, scenarios=comparisons, samples=samples)
    (a.output / 'comparison.json').write_text(json.dumps(report, indent=2) + '\n')
    print('PASS identical baseline/implementation outputs and stable operation counts: ' + str(a.output / 'comparison.json'))


if __name__ == '__main__':
    main()
