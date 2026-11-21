#!/usr/bin/env python3
"""Compare identical production UI workloads against the verified .10 runtime."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import statistics
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline', type=Path, required=True)
    parser.add_argument('--lua51', required=True)
    parser.add_argument('--lua54', required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    baseline = args.baseline.resolve()
    revision = 'd608838d049802e191e763ab32078116bc09a797'
    # Independently verify the baseline runtime against committed .10 Git objects.
    names = [line for line in (baseline / 'GetGear.toc').read_text().splitlines() if line.endswith('.lua')]
    for name in names + ['GetGear.toc', 'MapPin.tga']:
        body = subprocess.check_output(['git', 'show', revision + ':' + name], cwd=ROOT)
        assert body == (baseline / name).read_bytes(), name
    feature = args.output / 'feature-runtime'
    feature.mkdir(exist_ok=True)
    feature_hashes = {}
    for name in names + ['GetGear.toc', 'MapPin.tga']:
        shutil.copyfile(ROOT / name, feature / name)
        feature_hashes[name] = hashlib.sha256((feature / name).read_bytes()).hexdigest()
    rows = {}
    pattern = re.compile(r'^MEASURE (.*?): ([0-9.]+)ms; net heap ([0-9.-]+)KiB; (.*)$', re.M)
    for version, interpreter in [('5.1', args.lua51), ('5.4', args.lua54)]:
        samples = {'baseline': [], 'feature': []}
        for repeat in range(3):
            for label, runtime in [('baseline', baseline), ('feature', feature)]:
                command = [interpreter]
                if version == '5.1':
                    command += [str(ROOT / 'tools/release/lua51-harness.lua')]
                command += [str(ROOT / 'tests/overlay-performance.lua'), str(runtime)]
                result = subprocess.run(command, cwd=ROOT, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
                (args.output / f'lua{version}-{label}-{repeat+1}.txt').write_text(result.stdout)
                assert result.returncode == 0, result.stdout
                data = {}
                for name, cpu, heap, counters in pattern.findall(result.stdout):
                    data[name] = dict(cpuMS=float(cpu), netHeapKiB=float(heap),
                                      counts={k: int(v) for k, v in re.findall(r'(\w+)=(\d+)', counters)})
                assert len(data) == 14
                samples[label].append(data)
                print(f'PASS Lua {version} {label} repeat {repeat+1}', flush=True)
        comparisons = {}
        for name in samples['baseline'][0]:
            base = [sample[name] for sample in samples['baseline']]
            new = [sample[name] for sample in samples['feature']]
            for before, after in zip(base, new):
                for count in ('records', 'sourceChecks', 'routes', 'comparisons', 'obsolete', 'professions', 'aggregate', 'undocumented'):
                    assert before['counts'][count] == after['counts'][count], (name, count, before, after)
                expected_new_controls = 40 if name == 'detail + overlay' else 0
                assert after['counts']['newFrames'] == before['counts']['newFrames'] + expected_new_controls, (name, 'unexpected frame growth')
            old_ms = statistics.median(row['cpuMS'] for row in base)
            new_ms = statistics.median(row['cpuMS'] for row in new)
            comparisons[name] = dict(baselineMedianMS=old_ms, featureMedianMS=new_ms,
                                     changePercent=round((new_ms / old_ms - 1) * 100, 2) if old_ms else None,
                                     baseline=base, feature=new)
        rows[version] = comparisons
    for name, expected in feature_hashes.items():
        assert hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == expected, 'Feature source changed during comparison: ' + name
    report = dict(featureRuntimeSHA256=feature_hashes, baselineRevision=revision, baselineRuntimeExact=True, repeats=3,
                  workloadSHA256=hashlib.sha256((ROOT / 'tests/overlay-performance.lua').read_bytes()).hexdigest(),
                  interpreters=rows, actualClientTested=False,
                  statement='Synthetic Lua CPU only. Operation counts and recommendation/material signatures are exact; text writes include star controls.')
    (args.output / 'comparison.json').write_text(json.dumps(report, indent=2) + '\n')
    print('PASS identical .10 calculation counts and output fingerprints on both interpreters')


if __name__ == '__main__':
    main()
