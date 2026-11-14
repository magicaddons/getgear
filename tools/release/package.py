"""TOC-based deterministic packaging; never infer historical ZIP byte identity."""
import hashlib
import json
import re
import stat
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
BETA9 = json.loads((HERE / 'beta9-manifest.json').read_text())


def require(ok, message):
    if not ok:
        raise RuntimeError(message)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def identity(tag, commit, checksum):
    require(re.fullmatch(r'v\d+\.\d+\.\d+-beta\d+', tag), 'Expected a beta release tag')
    require(re.fullmatch(r'[0-9a-f]{40}', commit), 'Expected full source commit SHA')
    require(re.fullmatch(r'[0-9a-f]{64}', checksum), 'Expected approved ZIP SHA-256')
    if tag == BETA9['tag']:
        require(commit == BETA9['sourceCommit'] and checksum == BETA9['sha256'],
                'Beta 9 source/checksum is immutable')


def members(source, tag):
    toc = (source / 'GetGear.toc').read_text()
    require(f'## Version: {tag[1:]}' in toc.splitlines(), 'TOC version differs from tag')
    modules = [line.strip() for line in toc.splitlines()
               if line.strip() and not line.startswith('#')]
    require(modules and len(modules) == len(set(modules)), 'Empty/duplicate TOC entries')
    require(all(re.fullmatch(r'[A-Za-z0-9_-]+\.lua', x) for x in modules),
            'Only flat Lua TOC entries supported; review packaging for a new layout')
    names = modules + ['GetGear.toc', 'MapPin.tga', 'README.txt']
    # Preserve the current documentation convention for future releases.
    if (source / 'DATA_MODEL.md').exists():
        names.append('DATA_MODEL.md')
    for name in names:
        require((source / name).is_file() and not (source / name).is_symlink(), name)
    return names, modules


def validate(archive, source, tag, commit):
    names, modules = members(source, tag)
    if tag == BETA9['tag']:
        expected = {x['path']: x for x in BETA9['files']}
    else:
        expected = {'GetGear/' + name: None for name in names + ['BUILD_INFO.txt']}
    with zipfile.ZipFile(archive) as z:
        require(z.testzip() is None, 'Archive CRC failure')
        require(len(z.infolist()) == len(expected) and set(z.namelist()) == set(expected),
                'Unexpected, duplicate or missing archive entries')
        for info in z.infolist():
            require(stat.S_IFMT(info.external_attr >> 16) in (0, stat.S_IFREG), 'Unsafe file type')
            data = z.read(info)
            if tag == BETA9['tag']:
                record = expected[info.filename]
                require(len(data) == record['bytes'] and digest(data) == record['sha256'],
                        'Historical member differs: ' + info.filename)
            name = info.filename.removeprefix('GetGear/')
            if name != 'BUILD_INFO.txt':
                require(data == (source / name).read_bytes(), 'Source differs: ' + name)
            else:
                require(commit.encode() in data, 'Missing source attribution')
        with tempfile.TemporaryDirectory() as tmp:
            z.extractall(tmp)  # membership above allows only the explicit safe paths
            root = Path(tmp) / 'GetGear'
            # Evidence fixtures are test-only; gameplay modules always come from the ZIP.
            if (source / 'docs').is_dir():
                (root / 'docs').symlink_to(source / 'docs', target_is_directory=True)
            for runtime in ('5.1', '5.4'):
                for module in modules:
                    subprocess.run(['luac' + runtime, '-p', str(root / module)], check=True)
            tests = sorted((source / 'tests').glob('*.lua'))
            require(tests, 'No regression tests found')
            for test in tests:
                subprocess.run(['lua5.4', str(test.resolve()), str(root)], check=True)
                subprocess.run(['lua5.1', str(HERE / 'lua51-harness.lua'),
                                str(test.resolve()), str(root)], check=True)


def build(source, out, tag, commit, checksum, original=None):
    identity(tag, commit, checksum)
    require(subprocess.check_output(['git', '-C', str(source), 'rev-parse', 'HEAD'],
                                    text=True).strip() == commit, 'Wrong source checkout')
    require(not subprocess.check_output(['git', '-C', str(source), 'status', '--porcelain',
                                        '--untracked-files=no']), 'Dirty source checkout')
    names, _ = members(source, tag)
    out.mkdir(parents=True, exist_ok=True)
    archive = out / f'GetGear-{tag}.zip'
    if tag == BETA9['tag']:
        require(original and original.is_file(),
                'STOP: original Beta 9 ZIP missing. Restore approved bytes to '
                'release-packages/GetGear-v0.14.0-beta9.zip; do not substitute a rebuild.')
        data = original.read_bytes()
        require(digest(data) == BETA9['sha256'], 'STOP: original Beta 9 ZIP hash differs')
        archive.write_bytes(data)
    else:
        payload = {name: (source / name).read_bytes() for name in names}
        payload['BUILD_INFO.txt'] = (
            f'GetGear {tag}\nSource commit: {commit}\n'
            'Repository: https://github.com/magicaddons/getgear\n').encode()
        with zipfile.ZipFile(archive, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as z:
            for name, data in sorted(payload.items()):
                info = zipfile.ZipInfo('GetGear/' + name, (1980, 1, 1, 0, 0, 0))
                info.create_system = 3
                info.external_attr = 0o100644 << 16
                z.writestr(info, data, compress_type=zipfile.ZIP_DEFLATED, compresslevel=9)
    actual = digest(archive.read_bytes())
    print(f'ZIP SHA-256: {actual}', flush=True)
    # In a dry run the operator may use a provisional checksum to discover the build hash.
    require(actual == checksum, 'STOP: ZIP differs from approved SHA-256; publication blocked')
    validate(archive, source, tag, commit)
    (out / (archive.name + '.sha256')).write_text(f'{actual}  {archive.name}\n')


if __name__ == '__main__':
    source, out, tag, commit, checksum, original = sys.argv[1:]
    build(Path(source).resolve(), Path(out), tag, commit, checksum, Path(original))
