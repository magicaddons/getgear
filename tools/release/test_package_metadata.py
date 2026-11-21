"""Deterministic private-package provenance, inventories and checksum validation."""
import hashlib
import json
import re
from pathlib import Path
import zipfile


def digest(body):
    return hashlib.sha256(body).hexdigest()


def encode(value):
    return (json.dumps(value, indent=2, sort_keys=True) + '\n').encode()


def runtime_modules(toc):
    return [line.strip() for line in toc.decode().splitlines()
            if line.strip() and not line.lstrip().startswith('#')]


def payload_digest(payload):
    return digest(b''.join(name.encode() + b'\0' + body + b'\0'
                           for name, body in sorted(payload.items())))


def manifest(payload, proof, version, features, validation):
    return dict(schema=1, buildIdentifier=version + '-' + proof['sourceRevision'],
                version=version, **proof, sourcePayloadSHA256=payload_digest(payload),
                runtimeModules=runtime_modules(payload['GetGear.toc']),
                featureAcceptance=features, validation=validation,
                files=[dict(path=name, bytes=len(body), sha256=digest(body))
                       for name, body in sorted(payload.items())])


def build_info(record):
    return (f"GetGear {record['version']}\nPrivate cumulative testing build.\n"
            f"Build identifier: {record['buildIdentifier']}\n"
            f"Repository: https://github.com/{record['repository']}\n"
            f"Remote branch: {record['remoteBranch']}\n"
            f"Source revision: {record['sourceRevision']}\n"
            f"Source tree: {record['sourceTree']}\n"
            f"Canonical baseline: {record['canonicalBranch']} {record['canonicalRevision']}\n"
            f"Runtime payload SHA-256: {record['sourcePayloadSHA256']}\n"
            'GitHub source verification: PASS\n'
            'Cumulative feature contract: PASS\n'
            'Extracted-package functional regressions: PASS (Lua 5.1 and 5.4)\n'
            'Full results and ordered module inventory: PACKAGE_MANIFEST.json\n'
            'Automated checks do not replace actual WoW Forever acceptance testing.\n').encode()


def add_metadata(payload, record):
    result = dict(payload)
    result['PACKAGE_MANIFEST.json'] = encode(record)
    result['BUILD_INFO.txt'] = build_info(record)
    result['SHA256SUMS'] = ''.join(digest(body) + '  ' + name + '\n'
                                     for name, body in sorted(result.items())).encode()
    return result


def require(condition, message):
    if not condition:
        raise RuntimeError('Package metadata validation failed: ' + message)


def validate_metadata(archive, source, proof):
    """Verify against independent source/provenance, not self-reported hashes."""
    source = Path(source)
    with zipfile.ZipFile(archive) as z:
        require(len(z.namelist()) == len(set(z.namelist())), 'duplicate ZIP members')
        try:
            record = json.loads(z.read('GetGear/PACKAGE_MANIFEST.json'))
            require(record['schema'] == 1, 'unsupported manifest schema')
            for key, value in proof.items():
                require(record[key] == value, 'inconsistent ' + key)
            require(record['remoteVerified'] is True, 'remote source was not verified')
            require(re.fullmatch(r'[0-9a-f]{40,64}', record['sourceRevision']), 'full source SHA required')
            toc = (source / 'GetGear.toc').read_bytes()
            version = re.search(rb'^## Version: (.+)$', toc, re.M).group(1).decode()
            require(record['version'] == version, 'TOC/version mismatch')
            require(record['buildIdentifier'] == version + '-' + proof['sourceRevision'], 'build identity mismatch')
            modules = runtime_modules(toc)
            require(record['runtimeModules'] == modules, 'module inventory mismatch')
            names = modules + ['GetGear.toc', 'MapPin.tga', 'StarOutline.tga', 'StarFilled.tga', 'README.txt']
            payload = {name: (source / name).read_bytes() for name in names}
            expected_files = [dict(path=name, bytes=len(body), sha256=digest(body))
                              for name, body in sorted(payload.items())]
            require(record['files'] == expected_files, 'source file inventory mismatch')
            require(record['sourcePayloadSHA256'] == payload_digest(payload), 'payload checksum mismatch')
            validation = record['validation']
            require(validation['failures'] == 0 and validation['checks'] > 0 and
                    validation['lua51Regressions'] > 0 and validation['lua54Regressions'] > 0 and
                    validation['modules'] == len(modules) and
                    validation['cumulativeFeaturesVerified'] is True and
                    validation['protectedAcquisitionSnapshotExact'] is True and
                    validation['extractedRuntimePayloadSHA256'] == record['sourcePayloadSHA256'],
                    'missing/inconsistent extracted-package validation')
            require(record['featureAcceptance']['modules'] == len(modules) and
                    record['featureAcceptance']['features'], 'missing feature acceptance')
            expected = add_metadata(payload, record)
            require(set(z.namelist()) == {'GetGear/' + n for n in expected}, 'missing/unexpected package members')
            for name, body in expected.items():
                require(z.read('GetGear/' + name) == body, 'inconsistent bytes: ' + name)
            require(z.testzip() is None, 'CRC failure')
            return record
        except (KeyError, ValueError, TypeError, AttributeError) as error:
            raise RuntimeError('Package metadata validation failed: missing or invalid metadata') from error
