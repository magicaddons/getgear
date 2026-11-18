#!/usr/bin/env python3
"""Build a private testing ZIP only from an exact, verified GitHub development HEAD.

No release, tag or remote mutation. The output directory must be new. Runtime,
tests and packaging inputs come from a frozen export of the committed revision.
"""
import argparse
import io
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tarfile
import tempfile
import zipfile

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'tools'))
from validate_feature_acceptance import validate, validate_archive
from source_integrity import RemoteSourceError, SourceIntegrityError, clean_revision, git, recovery_bundle, verify
from test_package_metadata import add_metadata, digest, encode, manifest, payload_digest, validate_metadata


def zip_bytes(payload):
    stream = io.BytesIO()
    with zipfile.ZipFile(stream, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as z:
        for name, body in sorted(payload.items()):
            info = zipfile.ZipInfo('GetGear/' + name, (1980, 1, 1, 0, 0, 0))
            info.create_system = 3
            info.external_attr = 0o100644 << 16
            z.writestr(info, body, compress_type=zipfile.ZIP_DEFLATED, compresslevel=9)
    return stream.getvalue()


def snapshot(root, destination, revision):
    # Export committed objects, including tools/tests/fixtures, never workspace copies.
    with tarfile.open(fileobj=io.BytesIO(git(root, 'archive', '--format=tar', revision))) as tar:
        tar.extractall(destination, filter='data')


def run_regressions(source, addon, output, lua51, luac51):
    subprocess.run([sys.executable, str(source / 'tools/validate_recommendations.py'),
                    '--output', str(output), '--lua51', lua51, '--luac51', luac51,
                    '--addon-root', str(addon)], cwd=source,
                   env=dict(os.environ, PYTHONDONTWRITEBYTECODE='1'), check=True)
    return json.loads((output / 'summary.json').read_text())


def build(output, lua51, luac51, remote_branch):
    output = Path(output).resolve()
    if output.is_relative_to(ROOT):
        raise SourceIntegrityError('Keep package artifacts outside the source checkout')
    if output.exists():
        raise SourceIntegrityError('Output directory already exists; use a new directory for each build')
    try:
        proof = verify(ROOT, remote_branch)
        output.parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(prefix='getgear-validation-', dir=output.parent) as temp:
            staging = Path(temp)
            source = staging / 'source'
            snapshot(ROOT, source, proof['sourceRevision'])
            feature_proof = validate(source, source / 'FEATURE_ACCEPTANCE.json')
            toc = (source / 'GetGear.toc').read_bytes()
            version = re.search(rb'^## Version: (.+)$', toc, re.M).group(1).decode()
            if 'private' not in version or not re.fullmatch(r'[A-Za-z0-9_.-]+', version):
                raise RuntimeError('Testing packages require a distinct private TOC version')
            modules = [line.strip() for line in toc.decode().splitlines()
                       if line.strip() and not line.lstrip().startswith('#')]
            names = modules + ['GetGear.toc', 'MapPin.tga', 'README.txt']
            payload = {name: (source / name).read_bytes() for name in names}
            candidate = staging / 'candidate.zip'
            candidate.write_bytes(zip_bytes(dict(payload, **{'BUILD_INFO.txt': b'LOCAL CANDIDATE: validation pending\n'})))
            validate_archive(candidate, source)
            extracted = staging / 'extracted'
            with zipfile.ZipFile(candidate) as z:
                z.extractall(extracted)
            addon = extracted / 'GetGear'
            (addon / 'docs').symlink_to(source / 'docs', target_is_directory=True)
            delivery = staging / 'delivery'
            checks = delivery / 'validation'
            summary = run_regressions(source, addon, checks, lua51, luac51)
            # Tests must not change source, fixtures or the extracted runtime.
            source_tree = git(ROOT, 'ls-tree', '-rz', '--full-tree', proof['sourceRevision'])
            for entry in source_tree.split(b'\0'):
                if entry:
                    name = os.fsdecode(entry.split(b'\t', 1)[1])
                    if (source / name).read_bytes() != (ROOT / name).read_bytes():
                        raise SourceIntegrityError('Source/packaging input changed during validation: ' + name)
            if any((addon / name).read_bytes() != payload[name] for name in names):
                raise SourceIntegrityError('Extracted runtime changed during validation')
            stable_keys = ('checks', 'modules', 'lua51Regressions', 'lua54Regressions', 'failures',
                           'cumulativeFeaturesVerified', 'protectedAcquisitionSnapshotExact', 'actualClientTested')
            validation = {key: summary[key] for key in stable_keys}
            validation['extractedRuntimePayloadSHA256'] = payload_digest(payload)
            record = manifest(payload, proof, version, feature_proof, validation)
            final_payload = add_metadata(payload, record)
            final = delivery / ('GetGear-' + record['buildIdentifier'] + '.zip')
            final.write_bytes(zip_bytes(final_payload))
            validate_archive(final, source)
            validate_metadata(final, source, proof)
            body = final.read_bytes()
            if zip_bytes(final_payload) != body:
                raise RuntimeError('Repeat ZIP serialization is not byte-identical')
            checksum = digest(body)
            final.with_suffix('.zip.sha256').write_text(checksum + '  ' + final.name + '\n')
            (delivery / 'PACKAGE_MANIFEST.json').write_bytes(encode(dict(record, artifact=final.name,
                                                                        bytes=len(body), sha256=checksum)))
            (delivery / 'BUILD_INFO.txt').write_bytes(final_payload['BUILD_INFO.txt'])
            if clean_revision(ROOT) != {k: proof[k] for k in ('sourceRevision', 'sourceTree')}:
                raise SourceIntegrityError('HEAD changed during validation')
            if verify(ROOT, remote_branch) != proof:
                raise RemoteSourceError('Remote provenance changed during validation; rebuild')
            if output.exists():
                raise SourceIntegrityError('Output appeared during validation; refusing to overwrite it')
            # Promote the ZIP, metadata, checksums and full logs as one directory.
            delivery.rename(output)
        final = output / final.name
        print('PASS GitHub-verified cumulative testing package: ' + str(final), flush=True)
        print('SHA-256: ' + checksum, flush=True)
        print('Remote branch: ' + remote_branch + '\nSource revision: ' + proof['sourceRevision'], flush=True)
        return final
    except RemoteSourceError:
        try:
            print('Remote verification FAILED. Emergency local bundle: ' +
                  str(recovery_bundle(ROOT, output.parent / (output.name + '-recovery'))), flush=True)
        except SourceIntegrityError as error:
            print('Emergency bundle FAILED: ' + str(error), flush=True)
        raise


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--lua51', required=True)
    parser.add_argument('--luac51', required=True)
    parser.add_argument('--remote-branch', required=True, help='Exact GitHub development branch pointing to HEAD')
    args = parser.parse_args()
    build(args.output, args.lua51, args.luac51, args.remote_branch)
