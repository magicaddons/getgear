"""Extract exact ACA offers and individual guide coordinates; never relocate DSL vendors."""
import argparse
import gzip
import hashlib
import html
import json
import re
from pathlib import Path
from build_acquisition_navigation import lua
from research_sources import validate_receipt

ROOT = Path(__file__).resolve().parents[1]
D = ROOT/'docs/source-integrity-20261124'
URL = 'https://www.wowhead.com/forever/guide/azeroth-commerce-authority-reputation-professions'


def build():
    path = D/'azeroth-commerce-authority.html.gz'
    raw = gzip.decompress(path.read_bytes())
    page = raw.decode()
    markup = json.loads(re.search(r'WH\.markup\.printHtml\(("(?:[^"\\]|\\.)*")', page)[1])
    names = {int(i): name for i, name in re.findall(r'href="/forever/npc=(\d+)/[^"<]*"[^>]*>([^<]+)', page)}
    sources, offers = {}, {}
    for profession, block in re.findall(r'\[tab name=([^]]+)\](.*?)\[/tab\]', markup, re.S):
        match = re.search(r'Sold by:.*?\[npc=(\d+)\].*?/way #44 ([\d.]+), ([\d.]+)', block)
        assert match, profession
        identifier, x, y = match.groups()
        key = 'npc:'+identifier
        sources[key] = dict(name=names[int(identifier)], serviceSide=1, affiliation='Azeroth Commerce Authority',
                            profession=profession, locations=[dict(zone='Redridge Mountains', areaID=44, uiMapID=1433, x=float(x), y=float(y),
                            verification='published-reference', locationClass='reported-point',
                            locationKind='published-point', locationConfidence='published-guide-vendor',
                            instructions='Individual vendor point published in the ACA guide; not independently verified in the live client.')])
        for book, skill, cost in re.findall(r'\[tr\]\[td\]\[item=(\d+)\]\[/td\]\[td\](\d+)\[/td\]\[td\](\d+)\[/td\]\[/tr\]', block):
            assert book not in offers
            offers[book] = dict(source=key, learningSkill=int(skill), cost=int(cost), currencyID=3402,
                                reputation='unverified-per-book', profession=profession)
    assert len(sources) == 7 and len(offers) == 317
    book_proofs={str(r['entityIDs']['item']):r for r in map(json.loads,gzip.decompress((D/'current-item-tooltips.jsonl.gz').read_bytes()).splitlines())}
    for receipt in book_proofs.values():validate_receipt(receipt)
    for identifier,offer in offers.items():
        receipt=book_proofs.get(identifier)
        if not receipt or receipt['status']!='retrieved':
            offer['bookStatus']='missing-evidence';continue
        tooltip=json.loads(receipt['body'])['tooltip']
        prefix=html.unescape(re.sub('<[^>]+>',' ',tooltip.split('Use:',1)[0]))
        skill=re.search(r'Requires\s+'+re.escape(offer['profession'])+r'\s*\((\d+)\)',prefix)
        offer['bookLearningSkill']=int(skill[1]) if skill else None
        offer['learningSkillDisputed']=bool(skill and int(skill[1])!=offer['learningSkill'])
        standing=re.search(r'Requires (Friendly|Honored|Revered|Exalted) with this faction',prefix)
        offer['reputation']=standing[1] if standing else 'unverified-per-book'
        offer['taughtSpellIDs']=sorted(set(map(int,re.findall(r'Use:.*?href="/forever/spell=(\d+)',tooltip))))
        offer['outputItemIDs']=sorted(set(map(int,re.findall(r'<span class="q\d"><a href="/forever/item=(\d+)',tooltip))))
        offer['bookEvidence']={k:receipt[k] for k in ('url','sha256','retrievedAt')}
        offer['bookStatus']='published-forever-tooltip'
    proof = dict(url=URL, sha256=hashlib.sha256(raw).hexdigest(), retrievedAt='2026-11-24',
                 gameVersion='Forever 1.60.1', evidenceKind='published-forever',
                 limitations=['Published guide inventory and points; no live client observation.',
                              'Guide cost/skill does not establish individual reputation gates.',
                              'Do not replace per-book reputation requirements with a general faction rank.'])
    entities={int(r['entityIDs']['npc']):r for r in map(json.loads,gzip.decompress((D/'current-source-entities.jsonl.gz').read_bytes()).splitlines()) if 'npc' in r['entityIDs']}
    for receipt in entities.values():validate_receipt(receipt)
    opposing={}
    for identifier,receipt in entities.items():
        if receipt['status']!='retrieved':continue
        page=json.loads(receipt['body']);tooltip=page['tooltip']
        if '<td>Durotar Supply and Logistics</td>' in tooltip:
            opposing['npc:'+str(identifier)]=dict(name=page['name'],serviceSide=2,affiliation='Durotar Supply and Logistics',
                publisherMap=page.get('map'),evidence={k:receipt[k]for k in ('url','sha256','retrievedAt')})
    for key,source in sources.items():
        receipt=entities[int(key.split(':')[1])];page=json.loads(receipt['body'])
        assert html.unescape(page['name'])==source['name'] and '<td>Azeroth Commerce Authority</td>' in page['tooltip']
        source['npcEvidence']={k:receipt[k]for k in ('url','sha256','retrievedAt')}
        source['publisherMap']=page.get('map',{})
        guide=source['locations'][0];samples=[point for points in page.get('map',{}).get('coords',{}).values() for point in points]
        source['coordinateDisputed']=not(page.get('map',{}).get('zone')==44 and [guide['x'],guide['y']] in samples)
        source['guideLocations']=source['locations']
        if source['coordinateDisputed']:
            source['locations']=[dict(zone='Redridge Mountains',areaID=44,uiMapID=1433,
                verification='published-reference',locationClass='unknown',locationKind='conflicting-evidence',
                instructions='Published vendor positions disagree. Find this ACA vendor at Three Corners in Redridge; the exact current position is unverified, so no precise pin is offered.')]
    assert len(opposing)==7
    return dict(sources=sources,opposingSources=opposing,offers=offers,evidence=proof)


def render(value):
    return '-- Generated by tools/build_commerce_policy.py; published evidence, not live observations.\nlocal _, GetGear = ...\nGetGear.CommercePolicyData='+lua(value)+'\n'


def main():
    p=argparse.ArgumentParser();p.add_argument('--check',action='store_true');a=p.parse_args()
    value=build();text=render(value);path=ROOT/'CommercePolicyData.lua'
    if a.check: assert path.read_text()==text, 'Commerce policy drift'
    else:
        path.write_text(text)
        (D/'commerce-published-offers.json').write_text(json.dumps(value,indent=2)+'\n')
    print('PASS commerce guide: 7 separately located vendors, 317 exact book offers, 7 professions')


if __name__=='__main__':main()
