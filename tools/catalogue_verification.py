"""Persistent publication audit helpers. Parse data literals; never execute source JavaScript.

Research permission is delegated to research_sources, including redirect checks.
Neither a publication nor a matching checksum establishes live-game behaviour.
"""
import datetime
import gzip
import hashlib
import json
import re
from pathlib import Path
from urllib.request import Request

from research_sources import research_open


def literal(text, start):
    """Read a JSON-compatible JS object/array with bare keys and trailing commas.

    Wowhead appends bare-key publication metadata to otherwise JSON rows. Only
    literal keys are normalized outside strings. Expressions/functions fail JSON
    decoding. Quoted text is never rewritten or evaluated.
    """
    assert text[start] in '[{'
    depth = 0
    quoted = False
    escape = False
    end = None
    for index in range(start, len(text)):
        char = text[index]
        if quoted:
            if escape: escape = False
            elif char == '\\': escape = True
            elif char == '"': quoted = False
        elif char == '"': quoted = True
        elif char in '[{': depth += 1
        elif char in ']}':
            depth -= 1
            if depth == 0:
                end = index + 1
                break
    if end is None: raise ValueError('Unterminated publication literal')
    raw = text[start:end]
    # Split strings first: regexes must never touch data inside a string.
    tokens = re.split(r'("(?:[^"\\]|\\.)*")', raw)
    for index in range(0, len(tokens), 2):
        tokens[index] = re.sub(r'([,{]\s*)([A-Za-z_$][\w$]*)(\s*:)', r'\1"\2"\3', tokens[index])
        tokens[index] = re.sub(r',\s*(?=[}\]])', '', tokens[index])
    return json.loads(''.join(tokens)), end


def listview(page, name):
    match = re.search(r'\bvar\s+listview' + re.escape(name) + r'\s*=\s*', page)
    if not match: raise ValueError('Missing listview' + name)
    return literal(page, match.end())[0]


def related(page):
    result = {}
    for block in re.split(r'\bnew Listview\(', page)[1:]:
        identity = re.search(r"\bid:\s*['\"]([^'\"]+)['\"]", block)
        data = re.search(r'\bdata:\s*(?=\[)', block)
        if identity and data:
            result[identity[1]] = literal(block, data.end())[0]
    return result


def spells(page):
    result = []
    for match in re.finditer(r'\$\.extend\(g_spells\[(\d+)\],\s*(?=\{)', page):
        value, _ = literal(page, match.end())
        if value.get('id') == int(match[1]): result.append(value)
    return result


class Archive:
    """Append-only request receipts and checksummed compressed responses."""
    def __init__(self, root):
        self.root = Path(root)
        self.root.mkdir(parents=True, exist_ok=True)
        self.log = self.root / 'requests.jsonl'
        self.receipts = {}
        if self.log.exists():
            for line in self.log.read_text().splitlines():
                row = json.loads(line)
                self.receipts[row['url']] = row

    def fetch(self, url):
        if url in self.receipts: return self.receipts[url]
        key = hashlib.sha256(url.encode()).hexdigest()
        row = dict(url=url, retrievedAt=datetime.datetime.now(datetime.timezone.utc).isoformat(),
                   evidenceFamily='Wowhead' if 'wowhead.com/' in url else 'Blizzard',
                   scope='publication-only', liveClientVerified=False)
        try:
            with research_open(Request(url, headers={'User-Agent':'GetGear-CatalogueVerification/1.0'}), timeout=35) as response:
                raw = response.read(8_000_001)
                if len(raw) > 8_000_000: raise ValueError('Response exceeds archive limit')
                row.update(httpStatus=response.status, sha256=hashlib.sha256(raw).hexdigest(),
                           bytes=len(raw), file=key+'.gz', status='retrieved')
                (self.root / row['file']).write_bytes(gzip.compress(raw, mtime=0))
        except Exception as error:
            row.update(status='missing-evidence', error=str(error))
        # Callers append in the collecting thread, so concurrent reads never
        # interleave JSONL writes. A persisted failure is never silently retried.
        return row

    def record(self, row):
        with self.log.open('a') as stream: stream.write(json.dumps(row, sort_keys=True)+'\n')
        self.receipts[row['url']] = row

    def read(self, row):
        raw = gzip.decompress((self.root / row['file']).read_bytes())
        if hashlib.sha256(raw).hexdigest() != row['sha256']: raise ValueError('Publication archive drift')
        return raw.decode()
