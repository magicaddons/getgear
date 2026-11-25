"""Produce catalogue-wide field coverage, reverse inventories and explicit evidence gaps.

Publication agreement is partial verification of game facts. No offline result
can create a current-client observation or certify an entire equipment record.
"""
import argparse
import collections
import csv
import gzip
import hashlib
import html
import json
import re
from pathlib import Path

from build_catalogue_verification import extracts, recipe_rows, unique_recipe, D, ROOT
from build_acquisition_navigation import PROFESSION_SKILLS
from audit_source_integrity import materials
from research_sources import require_research

FIELDS=('itemID name requiredLevel itemLevel quality equipmentSlot classification armor attributeStats resistances '
        'weaponDamage weaponSpeed equipEffects useEffects procEffects binding classRestrictions raceRestrictions '
        'factionRestrictions reputationRestrictions equipRequirements acquisitionMethods questPrerequisites '
        'recipeIdentity profession professionSkill materials recipeAcquisition specialization recipeBinding '
        'NPCIdentity zone subzone coordinates mapID dungeonEntrance factionAccessibility currencyRequirements').split()
SLOTS={1:'Head',2:'Neck',3:'Shoulder',4:'Shirt',5:'Chest',6:'Waist',7:'Legs',8:'Feet',9:'Wrist',10:'Hands',
       11:'Ring',12:'Trinket',13:'Main Hand',14:'Off Hand',15:'Ranged',16:'Back',17:'Two-Hand',19:'Tabard',
       21:'Main Hand',22:'Off Hand',23:'Off Hand',25:'Thrown',26:'Ranged',28:'Relic'}


def plain(text):return ' '.join(html.unescape(re.sub('<[^>]+>',' ',text)).split())


def tooltip_values(receipt):
    if not receipt or receipt['status']!='retrieved':return {}
    page=json.loads(receipt['body']);tip=page['tooltip'];text=plain(tip)
    result={'name':html.unescape(page['name']),'quality':page.get('quality')}
    for key,pattern in [('requiredLevel',r'Requires Level <!--rlvl-->(\d+)'),('itemLevel',r'Item Level <!--ilvl-->(\d+)'),
                        ('armor',r'<!--amr-->(\d+) Armor')]:
        found=re.search(pattern,tip)
        if found:result[key]=int(found[1])
    stats={key:int(value)for key,value in re.findall(r'<!--stat(\d+)-->([+-]\d+)',tip)}
    if stats:result['attributeStats']=stats
    resistances={school:int(value)for value,school in re.findall(r'([+-]\d+)\s+(Arcane|Fire|Nature|Frost|Shadow|Holy) Resistance',text)}
    if resistances:result['resistances']=resistances
    damage=re.search(r'<!--dmg-->(\d+)\s*-\s*(\d+)\s*([A-Za-z ]*?)Damage',tip)
    if damage:result['weaponDamage']={'minimum':int(damage[1]),'maximum':int(damage[2]),'schoolLabel':damage[3].strip()or None}
    speed=re.search(r'<!--spd-->(\d+(?:\.\d+)?)',tip)
    if speed:result['weaponSpeed']=float(speed[1])
    if 'Binds when picked up' in text:result['binding']='bop'
    elif 'Binds when equipped' in text:result['binding']='boe'
    elif 'Binds when used' in text:result['binding']='bou'
    for key,label in [('classRestrictions','Classes'),('raceRestrictions','Races')]:
        found=re.search(label+r':\s*(.*?)(?:<br|</td)',tip,re.S)
        if found:result[key]=plain(found[1])
    for key,label in [('equipEffects','Equip:'),('useEffects','Use:'),('procEffects','Chance on hit:')]:
        effects=[match[1].strip()for match in re.finditer(re.escape(label)+r'\s*(.*?)(?=Equip:|Use:|Chance on hit:|Sell Price:|$)',text)]
        if effects:result[key]=effects
    return result


def dump(name,value):
    data=(json.dumps(value,sort_keys=True,indent=2)+'\n').encode()
    if name.endswith('.gz'):data=gzip.compress(data,mtime=0)
    (D/name).write_bytes(data)


def run(export,minima):
    publications=extracts();recipes=recipe_rows(publications)
    web_joins={}
    for row in json.loads((D/'web-crafting-joins.json').read_text()):
        require_research(row['url'],dataset=True);require_research(row['outputURL'],dataset=True)
        assert '/spell='+str(row['spellID'])+'/' in row['url']
        assert '/item='+str(row['outputItemID'])+'/' in row['outputURL'] and row['effect']=='Create Item'
        row['extractSHA256']=hashlib.sha256(json.dumps(row,sort_keys=True).encode()).hexdigest()
        web_joins[str(row['outputItemID'])]=row
    old=ROOT/'docs/source-integrity-20261124'
    tooltips={str(row['entityIDs']['item']):row for row in map(json.loads,gzip.decompress((old/'current-item-tooltips.jsonl.gz').read_bytes()).splitlines())}
    spell_proofs={str(row['entityIDs']['spell']):row for row in map(json.loads,gzip.decompress((old/'current-spell-tooltips.jsonl.gz').read_bytes()).splitlines())}
    inventory={}
    for proof in publications:
        if proof.get('kind')=='equipment-inventory':
            for row in proof['rows']:inventory.setdefault(str(row['id']),[]).append((row,proof))
    acquisition_inventory={}
    for identifier,variants in inventory.items():
        for row,proof in variants:
            for source in row.get('sourcemore',[]):
                if not isinstance(source,dict) or not source.get('ti'):continue
                key=(int(identifier),source.get('t'),source['ti'])
                # Retain the publisher's method/type codes. A source reference
                # does not by itself establish a quest reward, live loot or stock.
                acquisition_inventory.setdefault(key,dict(itemID=int(identifier),publishedEntityTypeCode=source.get('t'),
                    sourceID=source['ti'],sourceName=source.get('n'),publishedSourceCodes=row.get('source',[]),
                    status='publication-source-reference; acquisition semantics/live availability unverified',
                    evidence={k:proof[k]for k in ('url','sha256','retrievedAt')}))
    for proof in publications:
        match=re.search(r'/item=(\d+)',proof['url'])
        if proof.get('kind')=='entity-page' and match:
            for vendor in proof.get('lists',{}).get('sold-by',[]):
                key=(int(match[1]),1,vendor['id'])
                acquisition_inventory.setdefault(key,dict(itemID=int(match[1]),publishedEntityTypeCode=1,
                    sourceID=vendor['id'],sourceName=vendor.get('name'),publishedOffer=vendor,
                    status='published-sold-by-row; may concern recipe book rather than finished equipment; live stock unverified',
                    evidence={k:proof[k]for k in ('url','sha256','retrievedAt')}))
    route_comparison=[];runtime_pairs=set()
    for identifier,plan in export['model']['items'].items():
        gear=export['items'].get(identifier,{})
        for index,route in enumerate(plan.get('routes',[]),1):
            source=re.fullmatch(r'(npc|object):(\d+)',route.get('source',''))
            identity=(5,route['questID'])if route.get('questID')else ((1 if source[1]=='npc'else 2),int(source[2]))if source else None
            target=route.get('bookItemID')or (gear.get('recipePatternItemID')if route.get('recipe')else None)or int(identifier)
            key=(target,*identity)if identity else None
            if key:runtime_pairs.add(key)
            route_comparison.append(dict(itemID=int(identifier),routeIndex=index,
                status='matched-published-source-reference'if key in acquisition_inventory else'not-listed-by-independent-evidence'if key else'identity-insufficient-for-exact-source-join',
                limitation='Absence is not removal; source-list relation is not current live acquisition proof.'))
    for key,record in acquisition_inventory.items():
        record['runtimeExactIDAlternative']=key in runtime_pairs
        record['comparisonStatus']='exact-ID-alternative-present'if key in runtime_pairs else'candidate-alternative-or-unmodeled-relation; semantics need review'
    dump('independent-acquisition-inventory.json.gz',list(acquisition_inventory.values()))
    dump('acquisition-bidirectional-reconciliation.json.gz',route_comparison)
    source_register=[]
    for index,proof in enumerate(publications,1):
        source_register.append(dict(sourceID=index,url=proof['url'],retrievedAt=proof['retrievedAt'],status=proof['status'],
            evidenceFamily=proof['evidenceFamily'],rawResponseSHA256=proof.get('sha256'),error=proof.get('error'),
            extraction=proof.get('extractStatus'),parseError=proof.get('parseError'),truncated=proof.get('truncated'),
            purpose=proof.get('kind','attempted full entity research'),trustBasis='Direct approved Forever publication endpoint; no intermediary imported dataset.',
            limitation='Same publisher family throughout. Collection build/live applicability unknown. A failed request or absent listing does not prove absence.',
            rawArchive='/workspace/artifacts/catalogue-audit-20261125/raw/'+proof.get('file',''),
            factualExtract='publication-extracts.json.gz'))
    for filename in ('current-item-tooltips.jsonl.gz','current-spell-tooltips.jsonl.gz','current-source-entities.jsonl.gz'):
        for line in gzip.decompress((old/filename).read_bytes()).splitlines():
            proof=json.loads(line)
            source_register.append(dict(sourceID='retained:'+filename+':'+str(proof['entityIDs']),
                url=proof['url'],retrievedAt=proof['retrievedAt'],status=proof['status'],evidenceFamily='Wowhead',
                rawResponseSHA256=proof.get('sha256'),error=proof.get('error'),
                purpose='Reused completed exact tooltip/entity research; no redundant retrieval.',
                trustBasis='Approved direct Forever publication response, retained with fingerprint.',
                limitation='Publication only; collection build/live applicability unknown; not an independent witness.',
                retainedReceipt='docs/source-integrity-20261124/'+filename))
    for row in web_joins.values():
        source_register.append(dict(sourceID='web-create-item:'+str(row['spellID']),url=row['url'],outputURL=row['outputURL'],
            retrievedAt=row['retrievedAt'],status='retrieved-web-extract',evidenceFamily='Wowhead',
            rawResponseSHA256=None,extractSHA256=row['extractSHA256'],factualExtract='web-crafting-joins.json',
            purpose='Exact Create Item output ID via clicked effect link; retained raw spell tooltip supplies material IDs and quantities.',
            trustBasis='Approved Forever spell page and exact numeric output item link.',limitations=row['limitations']))
    dump('source-register.json.gz',source_register)
    facts=[];records=[];issues=[];changes=[];craft_rows=[];external=[]
    inherited_routes=json.loads((old/'route-evidence-decisions.json').read_text())
    class_by_id=collections.defaultdict(list)
    for name,ids in export['classes'].items():
        for identifier in ids:class_by_id[str(identifier)].append(name)
    def issue(identifier,category,reason,attempted,needed,**extra):
        issues.append(dict(issueID=category+':'+str(identifier),entityID=identifier,category=category,status='unresolved',
                           reason=reason,attempted=attempted,evidenceNeeded=needed,liveGameInvestigationRequired=True,**extra))
    for identifier,item in sorted(export['items'].items(),key=lambda pair:int(pair[0])):
        receipt=tooltips.get(identifier);values=tooltip_values(receipt);evidence={key:receipt[key]for key in ('url','sha256','retrievedAt')if key in (receipt or {})}
        field_evidence={field:evidence for field in values}
        for field,external_key in [('equipmentSlot','slot'),('classification','subclass')]:
            candidates={json.dumps(row.get(external_key),sort_keys=True)for row,_ in inventory.get(identifier,[]) if external_key in row}
            if len(candidates)==1:
                value=json.loads(next(iter(candidates)));values[field]=SLOTS.get(value,value) if field=='equipmentSlot'else value
                field_evidence[field]={key:inventory[identifier][0][1][key]for key in ('url','sha256','retrievedAt')}
        if inventory.get(identifier):
            values['itemID']=int(identifier)
            field_evidence['itemID']={key:inventory[identifier][0][1][key]for key in ('url','sha256','retrievedAt')}
        recipe=unique_recipe(item,recipes)if item.get('profession')else None
        material_state='not-applicable'
        if item.get('profession'):
            material_state='missing-evidence'
            if recipe:
                row,proof=recipe;material_state='publication-matched';values['materials']={str(i):n for i,n in row['reagents']}
                values['recipeIdentity']=row['id'];values['profession']=item['profession']
                for field in ('materials','recipeIdentity','profession'):field_evidence[field]={key:proof[key]for key in ('url','sha256','retrievedAt')}
            else:
                # A successful full page can expose a creates link missing from
                # the small tooltip endpoint. It must identify this exact output.
                for proof in publications:
                    if proof.get('kind')!='entity-page':continue
                    for row in proof.get('spellDefinitions',[]):
                        if (row.get('creates')or[None])[0]==int(identifier) and row.get('id')==item.get('recipeSpellID') and row.get('name')==item['name'] and PROFESSION_SKILLS[item['profession']]in row.get('skill',[]) and dict(row.get('reagents',[]))=={r['itemID']:r['amount']for r in item['reagents']}:
                            material_state='publication-matched';values['materials']={str(i):n for i,n in row['reagents']};values['recipeIdentity']=row['id']
                            for field in ('materials','recipeIdentity'):field_evidence[field]={key:proof[key]for key in ('url','sha256','retrievedAt')}
                if material_state!='publication-matched':
                    proof=spell_proofs.get(str(item.get('recipeSpellID')))
                    if proof and proof['status']=='retrieved':
                        body=json.loads(proof['body'])['tooltip'];observed=materials(body)
                        if observed=={r['itemID']:r['amount']for r in item['reagents']} and 'href="/forever/item='+identifier+'/' in body:
                            material_state='publication-matched';values['materials']={str(k):v for k,v in observed.items()}
                            field_evidence['materials']={key:proof[key]for key in ('url','sha256','retrievedAt')}
                        join=web_joins.get(identifier)
                        if material_state!='publication-matched' and join and join['spellID']==item.get('recipeSpellID') and observed=={r['itemID']:r['amount']for r in item['reagents']}:
                            material_state='publication-matched';values['materials']={str(k):v for k,v in observed.items()}
                            values['recipeIdentity']=join['spellID']
                            field_evidence['materials']={key:proof[key]for key in ('url','sha256','retrievedAt')}
                            field_evidence['recipeIdentity']=dict(url=join['url'],outputURL=join['outputURL'],sha256=join['extractSHA256'],
                                retrievedAt=join['retrievedAt'],fingerprintScope='structured web-tool fact extract, not the original response bytes',
                                factExtract='web-crafting-joins.json')
                            if join['notInGame']:
                                issue(identifier,'recipe-availability-flag','Exact spell publication flags this recipe unavailable. Existing runtime qualification preserved; material/output agreement does not establish live craftability.',
                                      ['Full exact Forever spell page','Clicked exact Create Item output ID','Retained published pattern availability qualification'],
                                      'Current-client learned recipe/craftability receipt or an applicable official availability correction.',spellID=join['spellID'],evidenceURL=join['url'])
            if material_state!='publication-matched':
                issue(identifier,'crafting-output-join','No exact current output/profession/material join established.',
                      ['Retained spell tooltip','Six independent profession inventories','Full spell-page collection (access blocked)'],
                      'Current profession UI recipe/output/reagents receipt, or an accessible exact Forever spell/output publication.',spellID=item.get('recipeSpellID'))
            craft_rows.append(dict(itemID=int(identifier),profession=item['profession'],spellID=item.get('recipeSpellID'),materialStatus=material_state))
            if recipe and type(recipe[0].get('learnedat'))is int:
                observed=recipe[0]['learnedat'];previous=minima[identifier].get('minimum')
                if previous!=observed:
                    issue(identifier,'recipe-skill-semantics','Spell-list learnedat differs from existing effective minimum. Learning and crafting requirements must remain distinct.',
                          ['All six equipment profession inventories','Prior independently sourced recipe minima/book requirements'],
                          'Current client learning and crafting requirements measured separately.',recordedMinimum=previous,publishedLearnedAt=observed,evidence={k:recipe[1][k]for k in ('url','sha256','retrievedAt')})
        if not values:
            issue(identifier,'equipment-response','Prior tooltip request failed; independent valid slot lists contain no matching ID.',
                  ['Retained exact tooltip outcome','Independent all-slot inventory','New full item page attempt'],
                  'Current client item link with ID/build/tooltip; or an accessible exact Forever item publication.',previousError=(receipt or {}).get('error'))
        statuses=collections.Counter()
        for field in FIELDS:
            runtime={'itemID':item['itemID'],'name':item['name'],'requiredLevel':item.get('availableLevel'),
                     'equipmentSlot':item.get('slot'),'binding':item.get('bindingStatus'),'profession':item.get('profession'),
                     'recipeIdentity':item.get('recipeSpellID'),'materials':{str(r['itemID']):r['amount']for r in item.get('reagents',[])}or None,
                     'acquisitionMethods':(export['model']['items'].get(identifier)or{}).get('routes'),
                     'zone':item.get('zone')}.get(field)
            published=values.get(field)
            applicable=field not in ('recipeIdentity','profession','professionSkill','materials','recipeAcquisition','specialization','recipeBinding') or bool(item.get('profession'))
            state='partially-verified' if published is not None else 'legacy-or-unverified' if runtime is not None else 'missing-information'
            # Availability level and subtype-derived hand labels are not always
            # the same field as printed wearer level or an inventory slot enum.
            if field=='name' and published is not None and runtime!=published:state='contradictory'
            if not applicable:state='not-applicable'
            facts.append(dict(entityType='equipment',entityID=int(identifier),field=field,runtimeValue=runtime if field!='acquisitionMethods'else None,
                runtimeReference='AcquisitionNavigationData.items/'+identifier if field=='acquisitionMethods'else None,
                publishedValue=published,status=state,applicable=applicable,evidence=field_evidence.get(field) if published is not None else None,
                evidenceScope='publication-only; field presence and exact joins, no current-client observation',
                limitation='No inference of zero, no restriction, removal, availability or exact position from omitted data.'))
            statuses[state]+=1
        records.append(dict(itemID=int(identifier),name=item['name'],slot=item['slot'],level=item.get('availableLevel'),classes=class_by_id[identifier],
                            status='partially-verified'if values else'legacy-or-unverified',fieldStatuses=dict(statuses),
                            currentClientVerified=False,comprehensivelyVerified=False,materialsStatus=material_state))
    # Compare the independent equipment inventory in the reverse direction too.
    historical=list(csv.DictReader((ROOT/'docs/source-audit-1-60/reconciliation-20261109/additional_catalogue_research_queue.csv').open()))
    holds={row['itemID']:row['status']for row in historical}
    for identifier,variants in sorted(inventory.items(),key=lambda pair:int(pair[0])):
        values={field:sorted({json.dumps(row.get(field),sort_keys=True)for row,_ in variants})for field in ('name','quality','reqlevel','slot','side')}
        representative=variants[0][0];quality=representative.get('quality',0)
        state='present'if identifier in export['items']else'candidate-needs-record-verification'if quality>=2 else'outside-current-quality-policy'
        external.append(dict(itemID=int(identifier),name=representative.get('name'),status=state,variantRows=len(variants),
            fieldVariants={key:[json.loads(v)for v in vals]for key,vals in values.items()},
            historicalHold=holds.get(identifier),liveClientVerified=False,
            evidenceURLs=sorted({proof['url']for _,proof in variants}),
            limitation='Independent list discovery; not an automatic Alliance-accessible equipment addition. Variant disagreements and all prior holds retained.'))
        if state=='candidate-needs-record-verification':
            issue(identifier,'equipment-completeness-candidate','Published equipment reference is outside the active catalogue; current version, full wearer facts and practical Alliance sources need review.',
                  ['Independent all-slot inventory','Two-way exact-ID reconciliation','Historical candidate hold comparison'],
                  'Complete applicable item and restriction evidence, qualified acquisition alternatives and runtime eligibility review before adoption.',
                  historicalHold=holds.get(identifier),inventoryReference='independent-equipment-inventory.json.gz')
    for row in inherited_routes:
        issue(str(row['itemID'])+':'+str(row['routeIndex']),'acquisition-availability',
              'Current live loot, stock, teaching or quest access is not established; retained route disposition: '+row['status'],
              ['Prior route-level provenance review','Retained exact guide joins where available','New full source-page collection (access blocked)'],
              'Applicable original evidence for this exact item/source alternative, with live build or official availability context.',
              itemID=row['itemID'],routeIndex=row['routeIndex'],kind=row['kind'],previousDisposition=row['status'])
    commerce=json.loads((D/'commerce-skill-evidence.json').read_text())
    for book,row in commerce.items():
        issue(book,'commerce-guide-skill','Guide table contradicts matching book/spell requirements. Preferred publication value chosen; current-client requirement unknown.',
              ['Exact book tooltip','Exact teaching-spell ID and profession list requirement','Commerce guide table'],
              'Current client recipe-book learning requirement and profession window receipt.',preferredPublishedValue=row['preferredLearningSkill'],guideValue=row['guideLearningSkill'],publicationPreferenceResolved=True)
    issue(249539,'enchantment-effect','Formula teaching text says +6 defense; nested enchantment/spell publication says +9. One publisher cannot independently resolve live effect.',
          ['Retained complete formula tooltip','Current full formula teaches-spell list','Current spell-list identity and indexed spell page'],
          'Actual enchanted-item tooltip/stat change plus client build and enchantment ID; or explicit applicable official correction.',spellID=1248665)
    policy=json.loads((old/'commerce-published-offers.json').read_text())
    for identifier,source in policy['sources'].items():
        if source.get('coordinateDisputed'):
            issue(identifier,'commerce-coordinates','Guide point disagrees with the NPC mapper samples; precision remains withheld.',
                  ['Retained individual guide point','Exact NPC map samples','Full NPC page attempt (403)'],
                  'NPC-position observation with matching GUID, UI map, build and physical-position measurement.',guide=source['guideLocations'],mapper=source['publisherMap'])
    # Preserve every pre-existing non-commerce geometry conflict explicitly.
    entity=json.loads(gzip.decompress((old/'entity-revalidation.json.gz').read_bytes()))
    source_facts=[]
    entity_records={(row['kind'],str(row['record'])):row for row in entity['records']}
    for category,model_key,field_names in [('source','sources',('name','entityIdentity','zone','subzone','coordinates','mapID','factionAccessibility','stock','teaching','loot')),
                                          ('quest','quests',('name','level','minimumLevel','rewards','starts','ends','objectives','prerequisites','factionAccessibility'))]:
        for identifier,record in export['model'][model_key].items():
            prior=entity_records.get((category,str(identifier)),{})
            for field in field_names:
                published=prior.get('publishedName')if field=='name'else (prior.get('publisherMap')or None)if field=='coordinates'else None
                runtime=record.get(field)
                if category=='source' and field in ('coordinates','zone','subzone','mapID'):
                    runtime=record.get('locations')or None
                source_facts.append(dict(entityType=category,entityID=identifier,field=field,runtimeValue=runtime,publishedValue=published,
                    status='partially-verified'if published is not None else'legacy-or-unverified'if runtime is not None else'missing-information',
                    evidence={key:prior[key]for key in ('url','sha256','retrievedAt')if key in prior},
                    evidenceScope='publication-only; a mapper sample is not a verified NPC position or spawn extent'))
    from build_research_policy import build as research_projection
    projection,_=research_projection(export)
    for conflict in projection['coordinateConflicts']:
        issue(conflict['source'],'source-coordinates','Published point and NPC mapper samples disagree; precise marker remains withheld.',
              ['Preserved reviewed point and coordinate classification','Exact retained NPC mapper','Full NPC page attempt (403)'],
              'Build-attributed physical NPC position, matching GUID, UI map, and map frame.',conflict=conflict)
    dump('inherited-entity-audit-reference.json',dict(file='docs/source-integrity-20261124/entity-revalidation.json.gz',sha256=hashlib.sha256((old/'entity-revalidation.json.gz').read_bytes()).hexdigest(),note='All original entity outcomes/coordinate conflicts retained verbatim; no coordinate promoted.'))
    for identifier,record in json.loads((D/'recipe-corrections.json').read_text()).items():
        changes.append(dict(entityID=int(identifier),field='recipeSpellID',original=None,corrected=record['recipeSpellID'],
                            evidence=record['evidence'],reason=record['reason'],status='partially-verified',liveClientVerified=False))
    for book,record in commerce.items():
        changes.append(dict(entityID=int(book),field='preferredCommerceLearningRequirement',original='disputed guide/book values',
                            corrected=record['preferredLearningSkill'],evidence=[record['bookEvidence'],record['evidence']],
                            reason='Exact book/spell agreement; conflicting guide retained',status='partially-verified',liveClientVerified=False))
    old_crafts={row['itemID']:row for row in csv.DictReader((old/'catalogue-revalidation.csv').open())}
    for row in craft_rows:
        identifier=str(row['itemID']);previous=old_crafts[identifier]['materialsStatus']
        if row['materialStatus']=='publication-matched' and previous not in ('independently-verified-published','not-applicable'):
            changes.append(dict(entityID=row['itemID'],field='verification.materialOutputJoin',original=previous,
                corrected='publication-matched',evidenceReference='verification-ledger.jsonl.gz: equipment/'+identifier+'/materials and recipeIdentity',
                reason='Exact published output link or missing-spell inventory join; all reagent IDs/quantities agree.',
                status='partially-verified',liveClientVerified=False,runtimeMaterialChange=False))
    with gzip.open(D/'verification-ledger.jsonl.gz','wt')as out:
        for fact in facts:out.write(json.dumps(fact,separators=(',',':'),sort_keys=True)+'\n')
    with gzip.open(D/'source-quest-field-ledger.jsonl.gz','wt')as out:
        for fact in source_facts:out.write(json.dumps(fact,separators=(',',':'),sort_keys=True)+'\n')
    bag_evidence={str(row['itemID']):row for row in json.loads((old/'bag-revalidation.json').read_text())}
    with gzip.open(D/'bag-field-ledger.jsonl.gz','wt')as out:
        for identifier,bag in export['bags'].items():
            prior=bag_evidence.get(identifier,{})
            for field in FIELDS+['capacity']:
                published=prior.get('publishedName')if field=='name'else prior.get('publishedCapacity')if field=='capacity'else None
                out.write(json.dumps(dict(entityType='bag',entityID=int(identifier),field=field,runtimeValue=bag.get(field),
                    publishedValue=published,status='partially-verified'if published is not None else'legacy-or-unverified'if bag.get(field)is not None else'missing-information',
                    evidence={key:prior[key]for key in ('url','sha256','retrievedAt')if key in prior},currentClientVerified=False,
                    evidenceScope='Reused exact published bag identity/capacity; stock and prerequisites unknown'),sort_keys=True)+'\n')
    dump('record-ledger.json.gz',records);dump('independent-equipment-inventory.json.gz',external)
    dump('independent-recipe-inventory.json.gz',[dict(row=row,evidence={k:proof[k]for k in ('url','sha256','retrievedAt')})for row,proof in recipes])
    dump('unresolved-issues.json.gz',issues);dump('change-register.json',changes);dump('crafting-reconciliation.json',craft_rows)
    def groups(key):
        result={}
        for record in records:
            keys=record[key]if isinstance(record[key],list)else[record[key]]
            for value in keys:
                entry=result.setdefault(str(value),dict(records=0,partiallyVerified=0,unverified=0,fullyVerified=0))
                entry['records']+=1;entry['partiallyVerified'if record['status']=='partially-verified'else'unverified']+=1
        return result
    summary=dict(equipmentRecords=len(records),recipeRecords=len(craft_rows),bags=len(export['bags']),
        totalDistinctItemRecords=len(set(export['items'])|set(export['bags'])),
        acquisitionRoutes=sum(len(plan.get('routes',[]))for plan in export['model']['items'].values()),
        acquisitionSourceEntities=len(export['model']['sources']),quests=len(export['model']['quests']),
        sourceQuestFieldsInventoried=len(source_facts),
        fieldsInventoried=len(facts),applicableFields=sum(f['applicable']for f in facts),fieldStatuses=dict(collections.Counter(f['status']for f in facts)),
        recordStatuses=dict(collections.Counter(r['status']for r in records)),fullyVerifiedRecords=0,actualClientObservations=0,
        independentEquipmentIDs=len(external),independentEquipmentVariantRows=sum(r['variantRows']for r in external),
        independentAcquisitionReferences=len(acquisition_inventory),
        externalCandidateIDs=sum(r['status']=='candidate-needs-record-verification'for r in external),
        canonicalIDsWithoutIndependentListMatch=sum(identifier not in inventory for identifier in export['items']),
        materialListsMatchedAsPublished=sum(r['materialStatus']=='publication-matched'for r in craft_rows),
        unresolvedCraftingJoins=sum(r['materialStatus']!='publication-matched'for r in craft_rows),
        recipeSpellIDsRestored=len(json.loads((D/'recipe-corrections.json').read_text())),
        commercePublicationPreferences=len(commerce),definitivelyResolvedCommerceConflicts=0,
        unresolvedCategories=dict(collections.Counter(i['category']for i in issues)),
        requestOutcomes=dict(collections.Counter(r['status']for r in publications)),
        extractionOutcomes=dict(collections.Counter(r.get('extractStatus','request-failed')for r in publications)),
        duplicateCatalogueIDs=0,newEquipmentAdded=0,duplicateRecordsRemoved=0,acquisitionRoutesRestored=0,geographicConflictsResolved=0,
        bySlot=groups('slot'),byLevel=groups('level'),byClass=groups('classes'),
        priorRouteStatuses=dict(collections.Counter(row['status']for row in inherited_routes)),
        limitations=['Publication fields are partial game verification, never whole-record/live confirmation.',
                    'Independent inventory discovery is independent of GetGear IDs but has one publisher lineage.',
                    'Some publisher facets were ignored or truncated; rejected extracts never establish completeness.',
                    'Broad 403 access failure prevented full source/quest/recipe-page research. No missing entity inferred.',
                    'All 900 historical publication-pass candidate holds remain outside the active catalogue.'])
    dump('coverage.json',summary)
    print(json.dumps({key:summary[key]for key in ('equipmentRecords','fieldsInventoried','independentEquipmentIDs','externalCandidateIDs','materialListsMatchedAsPublished','unresolvedCraftingJoins','recipeSpellIDsRestored')},indent=2))
    return summary


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--export',type=Path,required=True);parser.add_argument('--baseline-recipes',type=Path,required=True)
    args=parser.parse_args();run(json.loads(args.export.read_text()),json.loads(args.baseline_recipes.read_text()))
