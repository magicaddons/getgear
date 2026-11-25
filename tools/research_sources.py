"""Central research boundary. Historical bytes may be audited, never promoted by URL alone."""
import json
import hashlib
import urllib.request
from pathlib import Path
from urllib.parse import urlsplit

POLICY = json.loads((Path(__file__).resolve().parents[1] / 'docs/RESEARCH_SOURCE_POLICY.json').read_text())


def classify(url, provenance=''):
    parsed = urlsplit(str(url))
    host = (parsed.hostname or '').lower().rstrip('.')
    text = (str(url) + ' ' + str(provenance)).lower()
    if any(host == h or host.endswith('.' + h) or h in text
           for h in POLICY['blacklistedHosts']) or any(p.lower() in text for p in POLICY['blacklistedProviders']):
        return 'blacklisted'
    try: port=parsed.port
    except ValueError:return 'unapproved'
    if parsed.scheme != 'https' or parsed.username or parsed.password or port not in (None, 443):
        return 'unapproved'
    if host not in POLICY['approvedHosts']:
        return 'unapproved'
    if host.endswith('wowhead.com') and not parsed.path.startswith('/forever/'):
        return 'unapproved-version'
    if host in POLICY['platformHosts']:
        return 'platform-review-required'
    return 'approved-research'


def require_research(url, *, dataset=False, provenance=''):
    status = classify(url, provenance)
    if status not in ('approved-research', 'platform-review-required'):
        raise ValueError('Research source rejected: ' + status + ': ' + str(url))
    if dataset and any(repo.lower() in str(url).lower() for repo in POLICY['quarantinedRepositories']):
        raise ValueError('Historical dataset quarantined pending original provenance review: ' + str(url))
    return status


def validate_fact(fact):
    """Fail closed on current verification; source permission alone proves nothing."""
    required = ('url', 'retrievedAt', 'gameVersion', 'entityIDs', 'claim', 'status', 'evidenceKind', 'limitations', 'lineage')
    if any(k not in fact for k in required):
        raise ValueError('Missing fact provenance')
    if fact['evidenceKind']=='current-client' and str(fact['url']).startswith('client://'):
        if not all(fact.get(key) for key in ('api','clientBuild','observationReceipt','observedInClient')):
            raise ValueError('Native evidence requires an actual client observation receipt/build/API')
        status='current-client'
    else:
        status = require_research(fact['url'], dataset=True, provenance=fact['lineage'])
    if fact['status'] in ('independently-verified', 'corrected', 'contradicted'):
        if fact['evidenceKind'] not in ('current-client', 'published-forever') or not fact.get('sha256'):
            raise ValueError('Historical/inferred/missing evidence cannot verify a current fact')
        if status == 'platform-review-required' and not fact.get('originalAuthorReviewed'):
            raise ValueError('Platform provenance not reviewed')
        if status == 'platform-review-required':
            if not fact.get('originalSources'):
                raise ValueError('Platform facts require original-source lineage')
            for source in fact['originalSources']:require_research(source, dataset=True)
        if fact['lineage'] in ('unknown', 'unresolved', ''):
            raise ValueError('Unresolved lineage cannot verify a current fact')


def validate_receipt(receipt):
    """Current-publication caches must retain an exact approved entity response."""
    kind,identifier=next(iter(receipt['entityIDs'].items()))
    expected=f'https://nether.wowhead.com/forever/tooltip/{kind}/{identifier}'
    require_research(receipt['url'],dataset=True,provenance=receipt.get('lineage',''))
    if receipt['url']!=expected or kind not in ('item','spell','npc','object','quest'):
        raise ValueError('Entity/endpoint mismatch in research cache')
    if not receipt.get('retrievedAt') or not receipt.get('gameVersion'):
        raise ValueError('Missing cache retrieval/version provenance')
    if receipt['status']=='retrieved':
        if hashlib.sha256(receipt['body'].encode()).hexdigest()!=receipt.get('sha256'):
            raise ValueError('Research response fingerprint mismatch')


def require_evidence_tree(value):
    """Guard cached publication proofs without treating old references as live facts."""
    if isinstance(value,list):
        for child in value:require_evidence_tree(child)
    elif isinstance(value,dict):
        for key,child in value.items():
            if key.lower() in ('url','sourceurl') and isinstance(child,str):
                status=require_research(child,dataset=True,provenance=value.get('lineage',''))
                if status=='platform-review-required' and not value.get('originalAuthorReviewed'):
                    raise ValueError('Unreviewed platform cache cannot become publication evidence')
            elif isinstance(child,(dict,list)):require_evidence_tree(child)


class _Redirects(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        require_research(newurl, dataset=True)
        return super().redirect_request(req, fp, code, msg, headers, newurl)


def research_open(request, *args, **kwargs):
    url = request.full_url if isinstance(request, urllib.request.Request) else request
    require_research(url, dataset=True)
    return urllib.request.build_opener(_Redirects()).open(request, *args, **kwargs)
