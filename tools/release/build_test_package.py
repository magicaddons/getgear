#!/usr/bin/env python3
"""Build a cumulative private testing ZIP, validate its extracted runtime, then expose it.

No GitHub mutation, release/tag creation or branch change. Never overwrite an
existing final build. Run from a clean, reviewed integration revision.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[2]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / 'tools'))
from validate_feature_acceptance import validate, validate_archive


def digest(body):
    return hashlib.sha256(body).hexdigest()


def build(output, lua51, luac51):
    feature_proof = validate(ROOT)
    revision = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
    if subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT):
        raise RuntimeError('Commit the reviewed cumulative source before packaging; dirty source is not a revision identifier')
    toc = (ROOT / 'GetGear.toc').read_text()
    version = re.search(r'^## Version: (.+)$', toc, re.M).group(1)
    if 'private' not in version or not re.fullmatch(r'[A-Za-z0-9_.-]+', version):
        raise RuntimeError('Testing packages require a distinct private TOC version')
    output = Path(output).resolve()
    if output.is_relative_to(ROOT):
        raise RuntimeError('Keep package artifacts outside the source checkout')
    output.mkdir(parents=True, exist_ok=True)
    final = output / ('GetGear-' + version + '.zip')
    if final.exists():
        raise RuntimeError('This test build already exists; choose a new source build identity')
    modules = [line.strip() for line in toc.splitlines() if line.strip().endswith('.lua')]
    names = modules + ['GetGear.toc', 'MapPin.tga', 'README.txt']
    payload = {name: (ROOT / name).read_bytes() for name in names}
    source_hash = hashlib.sha256()
    for name, body in sorted(payload.items()):
        source_hash.update(name.encode() + b'\0' + body + b'\0')
    source_digest = source_hash.hexdigest()
    payload['BUILD_INFO.txt'] = (
        f'GetGear {version}\nPrivate cumulative in-game test; not a public release.\n'
        f'Source revision: {revision}\nRuntime payload SHA-256: {source_digest}\n'
        'Baseline: settings-ui-refinement 3e590ae438b2064bea756d40356ee5bc5c1205d4\n'
        'Includes completed settings, stat priorities, faction/talent/source rules, bags, materials and slot filtering.\n'
        'Paused navigation development is preserved separately and is not included.\n'
        'Automated checks do not replace actual WoW Forever acceptance testing.\n').encode()
    staging = Path(tempfile.mkdtemp(prefix='validation-', dir=output))
    candidate = staging / 'candidate.zip'
    with zipfile.ZipFile(candidate, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as z:
        for name, body in sorted(payload.items()):
            info = zipfile.ZipInfo('GetGear/' + name, (2026, 11, 18, 0, 0, 0))
            info.create_system = 3
            info.external_attr = 0o100644 << 16
            z.writestr(info, body, compress_type=zipfile.ZIP_DEFLATED, compresslevel=9)
    validate_archive(candidate, ROOT)
    extracted = staging / 'extracted'
    with zipfile.ZipFile(candidate) as z:
        z.extractall(extracted)
    addon = extracted / 'GetGear'
    # External test fixtures are available for report-bound assertions, never
    # distributed in the installable archive. Every runtime Lua file is from ZIP.
    (addon / 'docs').symlink_to(ROOT / 'docs', target_is_directory=True)
    env = dict(os.environ, PYTHONDONTWRITEBYTECODE='1')
    subprocess.run([sys.executable, str(ROOT / 'tools/validate_recommendations.py'),
                    '--output', str(staging / 'checks'), '--lua51', lua51, '--luac51', luac51,
                    '--addon-root', str(addon)], cwd=ROOT, env=env, check=True)
    # No source drift between creation, test execution and final handoff.
    for name in names:
        if payload[name] != (ROOT / name).read_bytes():
            raise RuntimeError('Source changed during validation: ' + name)
    if subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT):
        raise RuntimeError('Validation changed the source tree; review before creating final package')
    validate_archive(candidate, ROOT)
    body = candidate.read_bytes()
    with final.open('xb') as f:
        f.write(body)
    checksum = digest(body)
    if digest(final.read_bytes()) != checksum:
        raise RuntimeError('Final ZIP readback checksum differs')
    final.with_suffix('.zip.sha256').write_text(checksum + '  ' + final.name + '\n')
    manifest = {'artifact': final.name, 'bytes': len(body), 'sha256': checksum,
                'sourceRevision': revision, 'sourcePayloadSHA256': source_digest,
                'features': feature_proof, 'tests': str(staging / 'checks/summary.json'),
                'files': [{'path': 'GetGear/' + n, 'bytes': len(b), 'sha256': digest(b)}
                          for n, b in sorted(payload.items())]}
    (output / 'PACKAGE_MANIFEST.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print('PASS complete cumulative test package: ' + str(final), flush=True)
    print('SHA-256: ' + checksum, flush=True)
    print('Source revision: ' + revision, flush=True)
    return final


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--lua51', required=True)
    parser.add_argument('--luac51', required=True)
    args = parser.parse_args()
    build(args.output, args.lua51, args.luac51)
