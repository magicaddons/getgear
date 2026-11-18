"""Fail-closed GitHub provenance checks shared by private testing builds.

No remote mutations. A local tracking ref is never proof of a GitHub branch.
"""
import argparse
import base64
import hashlib
import json
import os
from pathlib import Path
import subprocess


class SourceIntegrityError(RuntimeError):
    pass


class RemoteSourceError(SourceIntegrityError):
    pass


def git(root, *args, remote=False):
    env = dict(os.environ, GIT_TERMINAL_PROMPT='0', GCM_INTERACTIVE='never')
    token = env.get('GH_TOKEN') or env.get('GITHUB_TOKEN')
    if remote and token:
        # Credentials exist only in this child's environment, never argv/files/logs.
        index = int(env.get('GIT_CONFIG_COUNT', '0'))
        env['GIT_CONFIG_COUNT'] = str(index + 1)
        env[f'GIT_CONFIG_KEY_{index}'] = 'http.https://github.com/.extraheader'
        auth = base64.b64encode(('x-access-token:' + token).encode()).decode()
        env[f'GIT_CONFIG_VALUE_{index}'] = 'AUTHORIZATION: basic ' + auth
    try:
        return subprocess.run(['git', *args], cwd=root, env=env, check=True,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                              timeout=60).stdout
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired, OSError) as error:
        # Do not echo credential helpers, headers or server-controlled diagnostics.
        kind = RemoteSourceError if remote else SourceIntegrityError
        raise kind('GitHub remote verification failed; check network/authentication and push the '
                   'intended branch. No approved package may be delivered.' if remote else
                   'Git source verification failed: ' + args[0]) from error


def clean_revision(root):
    root = Path(root).resolve()
    if Path(git(root, 'rev-parse', '--show-toplevel').decode().strip()).resolve() != root:
        raise SourceIntegrityError('Expected the source repository root')
    revision = git(root, 'rev-parse', '--verify', 'HEAD^{commit}').decode().strip()
    if git(root, 'status', '--porcelain', '--untracked-files=all'):
        raise SourceIntegrityError('Dirty source tree: commit all intended changes before building')
    # status alone misses assume-unchanged/skip-worktree files. Compare every
    # tracked input, including packaging tools, tests, contracts and fixtures.
    tree = git(root, 'ls-tree', '-rz', '--full-tree', revision)
    object_format = git(root, 'rev-parse', '--show-object-format').decode().strip()
    for entry in tree.split(b'\0'):
        if not entry:
            continue
        header, raw_name = entry.split(b'\t', 1)
        mode, kind, expected = header.decode().split()
        name = os.fsdecode(raw_name)
        path = root / name
        if kind != 'blob' or mode not in ('100644', '100755') or path.is_symlink() or not path.is_file():
            raise SourceIntegrityError('Missing/unsupported committed input: ' + name)
        body = path.read_bytes()
        actual = hashlib.new(object_format, b'blob ' + str(len(body)).encode() + b'\0' + body).hexdigest()
        if actual != expected:
            raise SourceIntegrityError('Source input differs from committed revision: ' + name)
    return {'sourceRevision': revision,
            'sourceTree': git(root, 'rev-parse', revision + '^{tree}').decode().strip()}


def remote_tip(root, branch):
    if not branch or branch == 'main' or branch.startswith('-'):
        raise RemoteSourceError('Designate an isolated development branch, never main')
    git(root, 'check-ref-format', 'refs/heads/' + branch)
    ref = 'refs/heads/' + branch
    records = git(root, 'ls-remote', '--exit-code', '--refs', 'origin', ref, remote=True).decode().splitlines()
    if len(records) != 1 or records[0].split()[1:] != [ref]:
        raise RemoteSourceError('GitHub did not return the designated branch: ' + branch)
    return records[0].split()[0]


def verify(root, branch):
    root = Path(root).resolve()
    proof = clean_revision(root)
    policy = json.loads((root / 'CUMULATIVE_BASELINE.json').read_text())
    repository = policy['repository']
    if repository != 'magicaddons/getgear' or policy['canonicalBranch'] != 'integration/cumulative':
        raise SourceIntegrityError('Unexpected canonical cumulative repository/branch')
    url = git(root, 'remote', 'get-url', 'origin').decode().strip()
    if url not in (f'https://github.com/{repository}', f'https://github.com/{repository}.git',
                   f'git@github.com:{repository}.git', f'ssh://git@github.com/{repository}.git'):
        raise RemoteSourceError('origin must identify the authoritative GitHub repository ' + repository)
    tip = remote_tip(root, branch)
    if tip != proof['sourceRevision']:
        raise RemoteSourceError('GitHub branch ' + branch + ' points to ' + tip +
                                ', not HEAD ' + proof['sourceRevision'] + '; push and verify before building')
    canonical = policy['canonicalBranch']
    baseline = remote_tip(root, canonical)
    # Obtain the *current* canonical objects, without moving any local branch.
    git(root, 'fetch', '--no-tags', '--no-write-fetch-head', 'origin', 'refs/heads/' + canonical, remote=True)
    pins = [policy['originalCumulativeCommit'], *policy['subsequentCommits'], policy['recoveredHead']]
    try:
        for pin in pins:
            git(root, 'merge-base', '--is-ancestor', pin, baseline)
        git(root, 'merge-base', '--is-ancestor', baseline, proof['sourceRevision'])
    except SourceIntegrityError as error:
        raise RemoteSourceError('HEAD/current canonical baseline must preserve the complete recovered '
                                'cumulative history; fetch and integrate reviewed work first') from error
    if remote_tip(root, canonical) != baseline or remote_tip(root, branch) != tip:
        raise RemoteSourceError('GitHub branch moved during verification; retry against the current baseline')
    return dict(proof, repository=repository, remoteBranch=branch,
                canonicalBranch=canonical, canonicalRevision=baseline, remoteVerified=True)


def recovery_bundle(root, output):
    """Preserve HEAD after a remote failure; never alter or force a branch."""
    root, output = Path(root), Path(output).resolve()
    if output.is_relative_to(root.resolve()):
        raise SourceIntegrityError('Keep recovery bundles outside the checkout')
    revision = git(root, 'rev-parse', '--verify', 'HEAD^{commit}').decode().strip()
    output.mkdir(parents=True, exist_ok=True)
    bundle = output / ('GetGear-recovery-' + revision + '.bundle')
    # git bundle refuses to replace this reserved name if it already exists.
    if bundle.exists():
        git(root, 'bundle', 'verify', str(bundle))
        heads = git(root, 'bundle', 'list-heads', str(bundle)).decode()
        if revision + ' HEAD' not in heads.splitlines():
            raise SourceIntegrityError('Existing recovery bundle has a different HEAD')
    else:
        git(root, 'bundle', 'create', str(bundle), 'HEAD')
        git(root, 'bundle', 'verify', str(bundle))
    checksum = hashlib.sha256(bundle.read_bytes()).hexdigest()
    bundle.with_suffix('.bundle.sha256').write_text(checksum + '  ' + bundle.name + '\n')
    return bundle


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument('--remote-branch', required=True)
    parser.add_argument('--recovery-output', type=Path, required=True)
    args = parser.parse_args()
    try:
        print(json.dumps(verify(args.root, args.remote_branch), indent=2))
    except RemoteSourceError:
        try:
            print('Remote verification FAILED. Emergency local bundle: ' +
                  str(recovery_bundle(args.root, args.recovery_output)))
        except SourceIntegrityError as error:
            print('Emergency bundle FAILED: ' + str(error))
        raise


if __name__ == '__main__':
    main()
