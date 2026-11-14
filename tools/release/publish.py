"""Fail-closed draft release transaction, using only the job's GITHUB_TOKEN via gh."""
import json
import os
import subprocess
import sys
from pathlib import Path
from urllib.parse import quote

from package import BETA9, digest, identity, require


class GitHub:
    def __init__(self, repository, allow_writes=False):
        require(repository == 'magicaddons/getgear', 'Wrong repository')
        self.base = f'repos/{repository}'
        self.allow_writes = allow_writes

    def api(self, path, method='GET', body=None):
        require(self.allow_writes or (method == 'GET' and body is None),
                'Release mutations disabled for dry run')
        cmd = ['gh', 'api', self.base + '/' + path, '--method', method]
        if body is not None:
            cmd += ['--input', '-']
        result = subprocess.run(cmd, input=json.dumps(body) if body is not None else None,
                                text=True, capture_output=True, check=True)
        return json.loads(result.stdout)

    def releases(self):
        result = []
        page = 1
        while True:
            batch = self.api(f'releases?per_page=100&page={page}')
            result.extend(batch)
            if len(batch) < 100:
                return result
            page += 1

    def commit(self, tag):
        obj = self.api('git/ref/tags/' + quote(tag, safe=''))['object']
        for _ in range(10):
            if obj['type'] == 'commit':
                return obj['sha']
            require(obj['type'] == 'tag', 'Tag does not resolve to a commit')
            obj = self.api('git/tags/' + obj['sha'])['object']
        raise RuntimeError('Excessive annotated tag nesting')

    def upload(self, release_id, path):
        require(self.allow_writes, 'Release mutations disabled for dry run')
        # Fixed host/repository/id: never follow an untrusted upload_url or use clobber.
        url = ('https://uploads.github.com/' + self.base + f'/releases/{release_id}/assets?name='
               + quote(path.name, safe=''))
        subprocess.run(['gh', 'api', url, '--method', 'POST', '-H',
                        'Content-Type: application/octet-stream', '--input', str(path)],
                       check=True, stdout=subprocess.DEVNULL)

    def download(self, asset):
        return subprocess.check_output(['gh', 'api', self.base + '/releases/assets/' + str(asset['id']),
                                        '-H', 'Accept: application/octet-stream'])


def verify_tag(api, tag, commit):
    # Safe with contents: read; unlike draft inspection this needs no push access.
    require(api.commit(tag) == commit, 'Tag moved or wrong expected source commit')


def select(api, tag, commit):
    verify_tag(api, tag, commit)
    matches = [r for r in api.releases() if r['tag_name'] == tag]
    require(len(matches) == 1, 'Exactly one existing draft is required; never create releases here')
    release = matches[0]
    require(release['draft'], 'Release already published; refusing any mutation')
    # Require drafts to explicitly name the source SHA, avoiding branch-name ambiguity.
    require(release['target_commitish'] == commit, 'Draft source differs from expected commit')
    if tag == BETA9['tag']:
        require(release['id'] == 445097507, 'Wrong Beta 9 draft ID')
    return release


def assets(api, release, expected):
    actual = api.api(f"releases/{release['id']}/assets?per_page=100")
    require(len(actual) <= len(expected), 'Unexpected assets')
    names = [x['name'] for x in actual]
    require(len(names) == len(set(names)) and set(names) <= set(expected), 'Unexpected/duplicate assets')
    for asset in actual:
        data = expected[asset['name']]
        require(asset['state'] == 'uploaded' and asset['size'] == len(data), 'Incomplete asset')
        require(api.download(asset) == data, 'Existing/downloaded asset bytes differ')
    return set(names)


def run(api, directory, tag, commit, checksum, publish=False):
    identity(tag, commit, checksum)
    name = f'GetGear-{tag}.zip'
    expected = {name: (directory / name).read_bytes(),
                name + '.sha256': (directory / (name + '.sha256')).read_bytes()}
    require(digest(expected[name]) == checksum, 'ZIP checksum mismatch before API writes')
    require(expected[name + '.sha256'] == f'{checksum}  {name}\n'.encode(), 'Checksum file differs')
    release = select(api, tag, commit)
    present = assets(api, release, expected)
    if not publish:
        print('Dry run passed. Draft and assets unchanged; publication disabled.')
        return
    # Recheck identity/state before every upload, including safe resume after partial failure.
    for filename, data in expected.items():
        current = select(api, tag, commit)
        require(current['id'] == release['id'], 'Draft identity changed')
        present = assets(api, current, expected)
        if filename not in present:
            api.upload(release['id'], directory / filename)
    current = select(api, tag, commit)
    require(current['id'] == release['id'], 'Draft identity changed')
    require(assets(api, current, expected) == set(expected), 'Not all assets verified')
    require(api.commit(tag) == commit, 'Tag moved during asset verification')
    # The sole publication operation; failures before this leave the draft unpublished.
    result = api.api(f"releases/{release['id']}", 'PATCH',
                     {'draft': False, 'prerelease': True, 'make_latest': 'false'})
    require(not result['draft'] and result['prerelease'] and result['tag_name'] == tag,
            'Unexpected publication response; inspect release manually')
    print('Published pre-release: ' + result['html_url'])
    summary = os.environ.get('GITHUB_STEP_SUMMARY')
    if summary:
        with open(summary, 'a') as f:
            f.write(f"Published [{tag}]({result['html_url']})\n")


if __name__ == '__main__':
    directory, tag, commit, checksum, enabled = sys.argv[1:]
    publish = enabled == 'true'
    run(GitHub(os.environ['GITHUB_REPOSITORY'], allow_writes=publish),
        Path(directory), tag, commit, checksum, publish=publish)
