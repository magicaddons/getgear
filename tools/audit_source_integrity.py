"""Fact-level provenance inventory and bounded current-publication revalidation.

Every record is inventoried. Only specifically checked fields count as researched
or verified. Historical reference counts are never independent corroboration.
"""
import argparse
import collections
import csv
import gzip
import hashlib
import html
import json
import re
import subprocess
from build_faction_eligibility import tooltip_facts
from pathlib import Path
from research_sources import classify, validate_fact
from build_research_policy import urls, build

ROOT=Path(__file__).resolve().parents[1]
D=ROOT/'docs/source-integrity-20261124'


def load_tooltips(kind):
    return {str(r['entityIDs'][kind]):r for r in map(json.loads,gzip.decompress((D/('current-'+kind+'-tooltips.jsonl.gz')).read_bytes()).splitlines())}


def plain(value):return html.unescape(re.sub('<[^>]+>',' ',value)).replace('\xa0',' ')


def leaves(value,pointer=''):
    if isinstance(value,dict):
        for key,child in value.items():yield from leaves(child,pointer+'/'+str(key))
    elif isinstance(value,list):
        for index,child in enumerate(value):yield from leaves(child,pointer+'/'+str(index))
    else:yield pointer,value


def materials(tooltip):
    block=re.search(r'Reagents:.*?<div[^>]*>(.*?)</div>',tooltip,re.S)
    if not block:return None
    result={}
    for identifier,tail in re.findall(r'href="/forever/item=(\d+)/[^"]*"[^>]*>.*?</a>([^,<]*)',block[1]):
        amount=re.search(r'\((\d+)\)',html.unescape(tail))
        result[int(identifier)]=int(amount[1]) if amount else 1
    return result or None


def generate(export):
    current=load_tooltips('item');spells=load_tooltips('spell')
    projection,route_decisions=build(export)
    statuses=collections.Counter();fields=collections.Counter();rows=[];facts=[];contradictions=[]
    classes=export['classes'];class_by_id=collections.defaultdict(list)
    for key,ids in classes.items():
        for identifier in ids:class_by_id[str(identifier)].append(key)
    published_fields=0;name_matches=0;level_matches=0;material_matches=0;material_disagreements=[]
    for identifier,item in sorted(export['items'].items(),key=lambda pair:int(pair[0])):
        proof=current.get(identifier);success=proof and proof['status']=='retrieved'
        published=json.loads(proof['body']) if success else {}
        tooltip=published.get('tooltip','');text=plain(tooltip)
        previous_name=item.get('previousPublishedName',item['name'])
        previous_level=item.get('previousPublishedLevel',item.get('availableLevel'))
        values={}
        if success:
            # Verify the numeric endpoint marker as well as the requested ID.
            marker=re.search(r'<!--i\?(\d+):',tooltip)
            assert not marker or marker[1]==identifier, ('Wrong endpoint entity',identifier)
            values['name']=html.unescape(published['name']);values['quality']=published.get('quality')
            level=re.search(r'Requires Level <!--rlvl-->(\d+)',tooltip)
            ilvl=re.search(r'Item Level <!--ilvl-->(\d+)',tooltip)
            if level:values['requiredLevel']=int(level[1])
            if ilvl:values['itemLevel']=int(ilvl[1])
            if 'Binds when picked up' in text:values['binding']='bop'
            elif 'Binds when equipped' in text:values['binding']='boe'
            armor=re.search(r'<!--amr-->(\d+) Armor',tooltip)
            if armor:values['armor']=int(armor[1])
            values['attributeStats']={key:int(amount) for key,amount in re.findall(r'<!--stat(\d+)-->\+([\d]+)',tooltip)}
            eligibility=tooltip_facts(tooltip)
            if eligibility['races']:values['raceRestrictions']=eligibility['races']
            if eligibility['explicitSides']:values['factionRestrictions']=eligibility['explicitSides']
            name_matches+=values['name']==previous_name
            level_matches+=bool(level and values['requiredLevel']==previous_level)
        per_status=collections.Counter()
        for field,value in leaves(item):
            status='previously-sourced-currently-unverified'
            if field=='/name' and success:status='independently-verified' if values['name']==previous_name else 'corrected'
            if field=='/availableLevel' and 'requiredLevel' in values:status='independently-verified' if values['requiredLevel']==previous_level else 'corrected'
            facts.append(dict(entityType='item',entityID=int(identifier),pointer=field,value=value,status=status,
                              evidenceURL=proof['url'] if status in ('independently-verified','corrected') else None,
                              verificationScope='published-tooltip-only' if status in ('independently-verified','corrected') else 'historical-runtime-data'))
            statuses[status]+=1;per_status[status]+=1;fields[field.split('/')[1]]+=1
        for field,value in values.items():
            if value in (None,{}):continue
            claim=dict(url=proof['url'],retrievedAt=proof['retrievedAt'],gameVersion=proof['gameVersion'],entityIDs={'item':int(identifier)},
                       claim=dict(field=field,value=value),status='independently-verified',evidenceKind='published-forever',
                       limitations=proof['limitations']+['Verifies current publication only; collection build and live server agreement remain unknown.'],
                       lineage='Direct Wowhead Forever endpoint response',sha256=proof['sha256'])
            validate_fact(claim);published_fields+=1
            facts.append(dict(entityType='published-item-fact',entityID=int(identifier),**claim))
        spell=spells.get(str(item.get('recipeSpellID')))
        material_state='not-applicable'
        if item.get('profession'):
            material_state='missing-evidence'
            if spell and spell['status']=='retrieved':
                body=json.loads(spell['body']);observed=materials(body.get('tooltip',''))
                recorded={r['itemID']:r['amount'] for r in item.get('reagents',[])}
                if observed is not None:
                    # The output link must identify this exact crafted item.
                    output='href="/forever/item='+identifier+'/' in body.get('tooltip','')
                    if not output:material_state='output-join-unverified'
                    elif observed==recorded:material_state='independently-verified-published';material_matches+=1
                    else:
                        material_state='contradicted';material_disagreements.append(dict(itemID=int(identifier),spellID=item['recipeSpellID'],recorded=recorded,published=observed,url=spell['url']))
        changes=projection['itemCorrections'].get(identifier,{})
        if changes:contradictions.append(dict(itemID=int(identifier),**changes))
        row=dict(itemID=int(identifier),name=item['name'],classes=' '.join(sorted(class_by_id[identifier])),slot=item['slot'],
                 level=item.get('availableLevel'),tooltipResearched=bool(proof),tooltipRetrieved=bool(success),
                 identityMatched=bool(success and values['name']==previous_name),correctedFields=' '.join(changes.get('fields',{})),
                 publishedFieldsVerified=len(values),materialsStatus=material_state,
                 acquisitionStatus='route-level-see-route-evidence-decisions.json',wholeRecordIndependentlyVerified=False,
                 liveClientVerified=False)
        rows.append(row)
    # Inventory every remaining runtime acquisition/source/quest/chain/recipe fact.
    model_facts=collections.Counter()
    for category in ('items','sources','quests','chains','recipeRequirements','instanceEntrances','currencies','availability',
                     'maps','instanceDetails','instanceEntranceAliases','instances','npcLabels'):
        for identifier,record in export['model'].get(category,{}).items():
            citations=urls(record)
            for pointer,value in leaves(record):
                facts.append(dict(entityType=category,entityID=identifier,pointer=pointer,value=value,
                                  status='previously-sourced-currently-unverified',historicalEvidenceRecord=category+'/'+identifier,
                                  limitation='Inventoried runtime projection with an unverified default. Current commerce and exact route revalidation are recorded in their separate evidence ledgers.'))
                model_facts[category]+=1
    registry_facts=collections.Counter()
    for category in ('eligibility','effectiveEligibility','factions'):
        for identifier,record in export.get(category,{}).items():
            for pointer,value in leaves(record):
                facts.append(dict(entityType=category,entityID=identifier,pointer=pointer,value=value,
                                  status='previously-sourced-currently-unverified',
                                  limitation='Retained restriction/proficiency projection; no new native-client observation.'))
                registry_facts[category]+=1
    inventory=[];providers=collections.Counter();tainted_files=[]
    for filename in subprocess.check_output(['git','ls-files'],cwd=ROOT,text=True).splitlines():
        if filename.startswith('docs/source-integrity-20261124/'):continue
        path=ROOT/filename
        if path.suffix not in ('.json','.md','.py','.lua','.csv','.txt','.yml','.toc'):continue
        body=path.read_bytes();text=body.decode('utf-8','replace')
        links=sorted(set(re.findall(r'https?://[A-Za-z0-9._~:/?#\[\]@!$&\x27()*+,;=%-]+',text)))
        found=[]
        for url in links:
            url=url.rstrip('.,);\x27')
            try:state=classify(url)
            except ValueError:state='malformed-unapproved'
            host=url.split('/')[2].lower();providers[(host,state)]+=1
            found.append(dict(url=url,policyStatus=state))
        if any(x['policyStatus'] in ('blacklisted','unapproved','unapproved-version') for x in found):tainted_files.append(filename)
        if found:inventory.append(dict(file=filename,sha256=hashlib.sha256(body).hexdigest(),citations=found,
                                      scope='Historical local-file inspection; URLs were not fetched by this inventory.'))
    return dict(rows=rows,facts=facts,contradictions=contradictions,materialDisagreements=material_disagreements,
                sourceInventory=inventory,providerCounts=[dict(host=h,status=s,urlFileReferences=n) for (h,s),n in sorted(providers.items())],
                summary=dict(catalogueItems=len(rows),classes=len(classes),classMemberships={k:len(v) for k,v in classes.items()},
                             slots=dict(collections.Counter(r['slot'] for r in rows)),
                             itemTooltipsAttempted=sum(r['tooltipResearched'] for r in rows),
                             itemTooltipsRetrieved=sum(r['tooltipRetrieved'] for r in rows),
                             itemTooltipsMissing=sum(not r['tooltipRetrieved'] for r in rows),
                             namesMatched=name_matches,namesCorrected=sum('name' in r['correctedFields'] for r in rows),
                             levelsMatched=level_matches,levelsCorrected=sum('availableLevel' in r['correctedFields'] for r in rows),
                             currentPublishedFactsVerified=published_fields,
                             craftedRecords=sum(bool(v.get('profession')) for v in export['items'].values()),
                             craftingSpellsRetrieved=sum(r['status']=='retrieved' for r in spells.values()),
                             materialListsVerifiedAsPublished=material_matches,materialListDisagreements=len(material_disagreements),
                             factStatuses=dict(statuses),historicalModelFacts=dict(model_facts),historicalRegistryFacts=dict(registry_facts),
                             routeStatuses=dict(collections.Counter(r['status'] for r in route_decisions)),
                             wholeRecordsIndependentlyVerified=0,actualClientObservations=0,
                             historicalFilesWithUnapprovedOrBlacklistedReferences=len(tainted_files),
                             scope='Every catalogue record inventoried; current published tooltip fields and exact guide joins researched. Loot/stock/prerequisites/live build not comprehensively verified.'))


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--export',type=Path,required=True);p.add_argument('--output',type=Path,default=D);a=p.parse_args()
    result=generate(json.loads(a.export.read_text()));a.output.mkdir(parents=True,exist_ok=True)
    for key in ('summary','contradictions','materialDisagreements','sourceInventory','providerCounts'):
        payload=(json.dumps(result[key],indent=2,sort_keys=True)+'\n').encode()
        if key=='sourceInventory':(a.output/(key+'.json.gz')).write_bytes(gzip.compress(payload,mtime=0))
        else:(a.output/(key+'.json')).write_bytes(payload)
    (a.output/'fact-register.jsonl.gz').write_bytes(gzip.compress(('\n'.join(json.dumps(r,separators=(',',':'),sort_keys=True)for r in result['facts'])+'\n').encode(),mtime=0))
    with (a.output/'catalogue-revalidation.csv').open('w',newline='')as f:
        writer=csv.DictWriter(f,fieldnames=list(result['rows'][0]),lineterminator='\n');writer.writeheader();writer.writerows(result['rows'])
    print(json.dumps(result['summary'],indent=2))


if __name__=='__main__':main()
