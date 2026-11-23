#!/usr/bin/env python3
"""Compare unchanged event/presentation workloads against the pinned production head.

Run outside the gate for before/after timing receipts; the Lua regression itself
runs in every integrated gate. Timing has no pass threshold.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import statistics
import subprocess

ROOT = Path(__file__).resolve().parents[1]
BASELINE = 'de1037a8a20593430d1c27e123685980d6da909b'
LINE = re.compile(r'IDLE_GROUPS (\w+) level=(\d+) (.*?) cpu=([\d.]+)ms heapGrowth=([\d.]+)KiB refresh=(\d+) items=(\d+) compose=(\d+) totals=(\d+) comparisons=(\d+)')


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--baseline-root', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--lua51', required=True)
    p.add_argument('--lua54', required=True)
    p.add_argument('--repeats', type=int, default=3)
    a = p.parse_args()
    assert a.repeats > 0
    a.output.mkdir(parents=True, exist_ok=False)
    for name in ['GetGear.toc'] + [line.strip() for line in (ROOT / 'GetGear.toc').read_text().splitlines() if line.endswith('.lua')]:
        expected = subprocess.check_output(['git', 'show', BASELINE + ':' + name], cwd=ROOT)
        assert (a.baseline_root / name).read_bytes() == expected, name
    report = dict(baseline=BASELINE, actualClientTested=False, repeats=a.repeats,
                  fixtureSHA256=hashlib.sha256((ROOT / 'tests/overlay-idle-groups.lua').read_bytes()).hexdigest(),
                  qualification='Synthetic CPU medians; inclusive counts; GC-paused Lua heap growth is a proxy, not client allocations. Frame-loop CPU includes walking mocked frames and cannot measure native render cost.', interpreters={})
    for version, lua in [('5.1', a.lua51), ('5.4', a.lua54)]:
        samples = {'baseline': {}, 'implementation': {}}
        for repeat in range(a.repeats):
            order = ['baseline', 'implementation'] if repeat % 2 == 0 else ['implementation', 'baseline']
            for cohort in order:
                command = [lua]
                if version == '5.1':
                    command += ['tools/release/lua51-harness.lua']
                command += ['tests/overlay-idle-groups.lua', str(a.baseline_root.resolve() if cohort == 'baseline' else ROOT)]
                if cohort == 'baseline':
                    command += ['baseline']
                result = subprocess.run(command, cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                    env=dict(os.environ, GETGEAR_OVERLAY_BASELINE='1' if cohort == 'baseline' else '0'))
                (a.output / f'lua{version}-{cohort}-{repeat+1}.txt').write_text(result.stdout)
                assert result.returncode == 0, result.stdout
                matches = list(LINE.finditer(result.stdout))
                assert len(matches) == 36
                for m in matches:
                    key = f'{m[1]} level {m[2]}: {m[3]}'
                    samples[cohort].setdefault(key, []).append(dict(cpuMS=float(m[4]), heapGrowthKB=float(m[5]),
                        counts=dict(zip(['refresh', 'items', 'compose', 'totals', 'comparisons'], map(int, m.groups()[5:])))))
                print(f'PASS Lua {version} {cohort} repetition {repeat+1}', flush=True)
        comparisons = {}
        for key in samples['baseline']:
            row = {}
            for cohort in samples:
                group = samples[cohort][key]
                assert all(v['counts'] == group[0]['counts'] for v in group)
                row[cohort] = dict(cpuMedianMS=statistics.median(v['cpuMS'] for v in group),
                    heapGrowthMedianKB=statistics.median(v['heapGrowthKB'] for v in group), counts=group[0]['counts'])
            comparisons[key] = row
        report['interpreters'][version] = comparisons
    (a.output / 'comparison.json').write_text(json.dumps(report, indent=2) + '\n')
    print('PASS ' + str(a.output / 'comparison.json'))


if __name__ == '__main__':
    main()
