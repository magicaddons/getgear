"""Project identified historical dependencies without changing frozen evidence."""
import argparse
import csv
import gzip
import html
import json
import re
import subprocess
from pathlib import Path
from build_acquisition_navigation import lua
from research_sources import classify, require_research, validate_receipt

ROOT=Path(__file__).resolve().parents[1]
D=ROOT/'docs/source-integrity-20261124'


def urls(value):
    result=[]
    if isinstance(value,dict):
        for key,child in value.items():
            if key in ('url','sourceURL','sourceUrl') and isinstance(child,str) and child.startswith('http'): result.append(child)
            elif isinstance(child,(dict,list)):result.extend(urls(child))
    elif isinstance(value,list):
        for child in value:result.extend(urls(child))
    elif isinstance(value,str) and value.startswith(('https://','http://')):
        result.append(value)
    return sorted(set(result))


def build(export):
    model=export['model'];states={};items={};decisions=[]
    dungeon_current={}
    dungeon_alias={'thedeadmines':'deadmines','stormwindstockade':'stockade','thestockade':'stockade',
                   'thetempleofatalhakkar':'thetempleofatalhakkar','zulfarrak':'zulfarrak'}
    norm=lambda s: re.sub('[^a-z0-9]','',s.lower())
    guide_dir=D/'dungeon-guides'
    for proof in json.loads((guide_dir/'manifest.json').read_text()):
        require_research(proof['url'],dataset=True)
        if not proof.get('bytes'):continue
        page=gzip.decompress((guide_dir/proof['file']).read_bytes()).decode()
        match=re.search(r'WH\.markup\.printHtml\(("(?:[^"\\]|\\.)*")',page)
        if not match:continue
        markup=json.loads(match[1]);slug=proof['url'].rsplit('/',1)[1].removesuffix('-dungeon-overview-location-rewards')
        offers=[]
        for label,block in re.findall(r'\[tab name="?([^]"\n]+)"?\](.*?)\[/tab\]',markup,re.S):
            for identifier in re.findall(r'\[item=(\d+)',block):
                offers.append((identifier,html.unescape(label)))
        dungeon_current[norm(slug)]=(proof,offers)
    dungeon={r['itemID']:r for r in csv.DictReader((ROOT/'docs/source-audit-1-60/reconciliation-20261109/dungeon_equipment_drops.csv').open())}
    for identifier,item in export['items'].items():
        own=urls(item)
        if own and all(classify(u) not in ('approved-research',) for u in own): items[identifier]='previously-sourced-currently-unverified'
        for i,route in enumerate(model['items'].get(identifier,{}).get('routes',[]),1):
            citations=urls(route)
            current=None
            if route['kind']=='dungeon':
                key=norm(route.get('dungeon',''));key=dungeon_alias.get(key,key)
                proof,offers=dungeon_current.get(key,({},[]))
                target=str(item.get('recipePatternItemID')) if route.get('recipe') else identifier
                enemy=norm(route.get('enemyName') or route.get('boss') or '')
                matched=[label for output,label in offers if output==target and norm(label)==enemy and enemy]
                if matched:
                    citations=[proof['url']]
                    current=dict(url=proof['url'],sha256=proof['sha256'],retrievedAt=proof['retrievedAt'],
                                 claim='Exact item/book listed under the recorded named enemy in current published Forever guide',
                                 verificationScope='published-guide-loot-list',liveClientVerified=False)
            if route['kind'] in ('quest','quest_container'):
                citations+=urls(model['quests'].get(str(route.get('questID')),{}).get('evidence',{}))
            if not citations and route['kind']=='dungeon' and identifier in dungeon:
                citations=[dungeon[identifier]['sourceURL']]
            dispositions=[classify(u) for u in citations]
            approved=any(s=='approved-research' for s in dispositions)
            blocked=bool(citations) and not approved
            state='independently-verified-published-guide' if current else 'withheld-unapproved-evidence' if blocked else 'retained-published-unverified' if approved else 'missing-evidence'
            if blocked: states.setdefault(identifier,{})[str(i)]=state
            decisions.append(dict(itemID=int(identifier),routeIndex=i,kind=route['kind'],source=route.get('source'),
                                  status=state,urls=sorted(set(citations)),sourceDecisions=dispositions,
                                  currentEvidence=current,
                                  limitation='Retained approved publication is historical, not new independent/current-client verification.'))
    corrections={}
    for line in gzip.decompress((D/'current-item-tooltips.jsonl.gz').read_bytes()).splitlines():
        proof=json.loads(line);validate_receipt(proof);identifier=str(proof['entityIDs']['item']);item=export['items'].get(identifier)
        if not item or proof['status']!='retrieved':continue
        page=json.loads(proof['body']);fields={}
        old_name=item.get('previousPublishedName',item['name'])
        old_level=item.get('previousPublishedLevel',item.get('availableLevel'))
        name=html.unescape(page['name'])
        if name!=old_name:fields['name']=dict(previous=old_name,value=name)
        level=re.search(r'Requires Level <!--rlvl-->(\d+)',page['tooltip'])
        if level and int(level[1])!=old_level:fields['availableLevel']=dict(previous=old_level,value=int(level[1]))
        if fields:corrections[identifier]=dict(fields=fields,url=proof['url'],sha256=proof['sha256'],retrievedAt=proof['retrievedAt'])
    commerce=json.loads((D/'commerce-published-offers.json').read_text())
    location_holds={}
    for key,actor in model['sources'].items():
        if key in commerce['sources']:continue
        for index,location in enumerate(actor.get('locations',[]),1):
            selected=location.get('coordinateEvidence',{}).get('selectedObservation',{}).get('url')
            if selected and classify(selected)!='approved-research':location_holds.setdefault(key,[]).append(index)
    entities={int(r['entityIDs']['npc']):json.loads(r['body']) for r in map(json.loads,gzip.decompress((D/'current-source-entities.jsonl.gz').read_bytes()).splitlines()) if 'npc' in r['entityIDs'] and r['status']=='retrieved'}
    areas={}
    for actor in model['sources'].values():
        for loc in actor.get('previousResearchLocations',actor.get('locations',[])):
            if loc.get('areaID'):areas.setdefault(loc['zone'],set()).add(loc['areaID'])
    conflicts=[]
    for key,actor in model['sources'].items():
        if key in commerce['sources']:continue
        match=re.fullmatch(r'npc:(\d+)',key) or re.fullmatch(r'bagquest:\d+:1:(\d+)',key)
        if not match:continue
        mapper=entities.get(int(match[1]),{}).get('map',{})
        samples=[point for points in mapper.get('coords',{}).values() for point in points]
        for index,loc in enumerate(actor.get('previousResearchLocations',actor.get('locations',[])),1):
            frame=loc.get('areaID') or (next(iter(areas.get(loc.get('zone'),[]))) if len(areas.get(loc.get('zone'),[]))==1 else None)
            if 'x' not in loc or 'y' not in loc or not frame or frame!=mapper.get('zone') or not samples:continue
            if [loc['x'],loc['y']] not in samples:
                holds=location_holds.setdefault(key,[])
                if index not in holds:holds.append(index)
                conflicts.append(dict(source=key,index=index,retainedPoint=[loc['x'],loc['y']],currentPublishedSamples=samples,areaID=frame,
                                      url='https://nether.wowhead.com/forever/tooltip/npc/'+match[1],
                                      status='published-coordinate-disagreement',limitation='Different samples do not establish removal, movement or a transform. Precision withheld pending native observation.'))
    entrance_holds={}
    for name,definition in model['instanceEntrances'].items():
        for index,entrance in enumerate(definition.get('previousResearchEntrances',definition.get('entrances',[])),1):
            references=urls(entrance)
            if references and all(classify(u)!='approved-research' for u in references):entrance_holds.setdefault(name,[]).append(index)
    receipts={(next(iter(r['entityIDs'])),next(iter(r['entityIDs'].values()))):r for r in map(json.loads,gzip.decompress((D/'current-source-entities.jsonl.gz').read_bytes()).splitlines())}
    for receipt in receipts.values():validate_receipt(receipt)
    quest_names={};actor_aliases={}
    for identifier,quest in model['quests'].items():
        old=quest.get('previousPublishedName',quest.get('name',''))
        receipt=receipts.get(('quest',int(identifier)),{})
        if old.startswith('Quest #') and receipt.get('status')=='retrieved':
            name=html.unescape(json.loads(receipt['body'])['name'])
            quest_names[identifier]=dict(previous=old,value=name,evidence={k:receipt[k]for k in ('url','sha256','retrievedAt')})
    for key,actor in model['sources'].items():
        match=re.fullmatch(r'npc:(\d+)',key)
        if not match:continue
        npc=receipts.get(('npc',int(match[1])),{});obj=receipts.get(('object',int(match[1])),{})
        canonical='object:'+match[1]
        if npc.get('status')=='missing-evidence' and obj.get('status')=='retrieved' and canonical in model['sources']:
            name=html.unescape(json.loads(obj['body'])['name'])
            if actor['name']==name==model['sources'][canonical]['name']:
                actor_aliases[key]=dict(canonical=canonical,evidence={k:obj[k]for k in ('url','sha256','retrievedAt')},
                                       status='withheld-duplicate-unverified-npc-alias')
    return dict(routes=states,items=items,itemCorrections=corrections,questNameCorrections=quest_names,sourceActorAliases=actor_aliases,
                sourceLocationHolds=location_holds,coordinateConflicts=conflicts,entranceHolds=entrance_holds),decisions


def main():
    p=argparse.ArgumentParser();p.add_argument('--export',type=Path,required=True);p.add_argument('--check',action='store_true');a=p.parse_args()
    projection,decisions=build(json.loads(a.export.read_text()))
    text='-- Generated historical dependency holds; no live verification implied.\nlocal _, GetGear = ...\nGetGear.ResearchPolicyData='+lua(projection)+'\n'
    path=ROOT/'ResearchPolicyData.lua'
    if a.check:assert path.read_text()==text
    else:
        path.write_text(text)
        (D/'route-evidence-decisions.json').write_text(json.dumps(decisions,indent=2)+'\n')
    print('Research policy: withheld routes',sum(map(len,projection['routes'].values())),'unapproved legacy items',len(projection['items']))


if __name__=='__main__':main()
