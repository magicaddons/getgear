#!/usr/bin/env python3
"""Reject incomplete future GetGear sources/packages against the cumulative feature contract.

Checks source dependencies and capability signatures. Functional Lua regressions
are mandatory in the build gate; the signatures alone do not establish behavior.
The contract comes from this tool's reviewed checkout, never from inside a ZIP.
"""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import stat
import tempfile
import zipfile

RUNTIME_ASSETS = ['MapPin.tga', 'StarOutline.tga', 'StarFilled.tga']

ROOT = Path(__file__).resolve().parents[1]
CONTRACT = ROOT / 'FEATURE_ACCEPTANCE.json'


class FeatureValidationError(RuntimeError):
    pass


def require(ok, message):
    if not ok:
        raise FeatureValidationError(message)


def validate_navigation_coverage(report, contract=CONTRACT):
    """A silent resolver drop must fail even if the remaining targets work."""
    baseline = json.loads(Path(contract).read_text())['navigationCoverageBaseline']
    for key, minimum in baseline['minimum'].items():
        require(report.get(key, -1) >= minimum, 'Navigation coverage fell below reviewed baseline: ' + key)
    for key in baseline['zero']:
        require(report.get(key) == 0, 'Navigation lost usable source evidence: ' + key)
    return True


def validate(root, contract=CONTRACT):
    root = Path(root)
    spec = json.loads(Path(contract).read_text())
    require(spec['schema'] == 1, 'Unsupported feature contract schema')
    require((root / 'GetGear.toc').is_file(), 'GetGear.toc is missing')
    modules = [s.strip() for s in (root / 'GetGear.toc').read_text().splitlines()
               if s.strip() and not s.lstrip().startswith('#')]
    require(all(re.fullmatch(r'[A-Za-z0-9_-]+\.lua', n) for n in modules), 'Unsafe/unsupported TOC path')
    require(len(modules) == len(set(modules)), 'Duplicate TOC modules')
    missing = set(spec['requiredModules']) - set(modules)
    require(not missing, 'Cumulative runtime modules missing: ' + ', '.join(sorted(missing)))
    for module in modules:
        require((root / module).is_file() and not (root / module).is_symlink(), 'Missing/unsafe runtime module: ' + module)
    for chain in spec['loadOrder']:
        require(all(modules.index(a) < modules.index(b) for a, b in zip(chain, chain[1:])), 'Invalid load order: ' + ' < '.join(chain))
    contents = {}
    features = []
    for feature in spec['features']:
        for name, signatures in feature['requires'].items():
            if name not in contents:
                require((root / name).is_file(), 'Missing feature file: ' + name)
                contents[name] = (root / name).read_text()
            for signature in signatures:
                require(signature in contents[name], feature['id'] + ': missing capability in ' + name + ': ' + signature)
        for script in feature['regressions']:
            require((ROOT / 'tests' / script).is_file(), 'Required functional regression missing: ' + script)
        features.append(feature['id'])
    for asset in RUNTIME_ASSETS:
        require((root / asset).is_file(), 'Required runtime asset missing: ' + asset)
    for name, expected in spec.get('acceptedNavigationFiles', {}).items():
        require(hashlib.sha256((root / name).read_bytes()).hexdigest() == expected,
                'Unreviewed navigation changes in ' + name)
    for section in spec.get('acceptedSections', []):
        text = (root / section['file']).read_text()
        start = text.index(section['start'])
        end = text.index(section['end'], start)
        require(hashlib.sha256(text[start:end].encode()).hexdigest() == section['sha256'],
                'Unreviewed navigation UI changes')
    return {'modules': len(modules), 'features': features, 'functionalTestsRequired': True,
            'acceptedNavigationExact': True}


def validate_archive(archive, source=None):
    with tempfile.TemporaryDirectory(prefix='getgear-feature-package-') as folder:
        with zipfile.ZipFile(archive) as z:
            names = z.namelist()
            require(len(names) == len(set(names)), 'Duplicate ZIP members')
            require(z.testzip() is None, 'ZIP CRC failure')
            require('GetGear/GetGear.toc' in names, 'ZIP must contain GetGear/GetGear.toc')
            toc = z.read('GetGear/GetGear.toc').decode()
            modules = [s.strip() for s in toc.splitlines() if s.strip() and not s.lstrip().startswith('#')]
            require(all(re.fullmatch(r'[A-Za-z0-9_-]+\.lua', n) for n in modules), 'Unsafe TOC module')
            allowed = {'GetGear/' + name for name in modules + RUNTIME_ASSETS + ['GetGear.toc', 'README.txt', 'BUILD_INFO.txt']}
            optional = {'GetGear/', 'GetGear/DATA_MODEL.md', 'GetGear/PACKAGE_MANIFEST.json', 'GetGear/SHA256SUMS'}
            require(allowed <= set(names) and set(names) <= allowed | optional, 'ZIP has missing dependencies or development/unexpected files')
            for info in z.infolist():
                p = PurePosixPath(info.filename)
                require(not p.is_absolute() and '..' not in p.parts and p.parts[0] == 'GetGear', 'Unsafe ZIP member')
                if info.is_dir():
                    require(info.filename == 'GetGear/', 'Unexpected ZIP directory')
                    continue
                require(len(p.parts) == 2 and stat.S_IFMT(info.external_attr >> 16) in (0, stat.S_IFREG), 'Unsafe ZIP member type/path')
                if source and p.name not in ('BUILD_INFO.txt', 'PACKAGE_MANIFEST.json', 'SHA256SUMS'):
                    require(z.read(info.filename) == (Path(source) / p.name).read_bytes(), 'Package differs from tested source: ' + p.name)
            z.extractall(folder)
        return validate(Path(folder) / 'GetGear')


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--root', type=Path, default=ROOT)
    p.add_argument('--archive', type=Path)
    p.add_argument('--expected-source', type=Path)
    a = p.parse_args()
    result = validate_archive(a.archive, a.expected_source) if a.archive else validate(a.root)
    print('PASS cumulative feature acceptance: ' + json.dumps(result))


if __name__ == '__main__':
    main()
