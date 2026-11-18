"""Offline, evidence-preserving location projection and whole-source audit.

No acquisition routes, equipment or frozen source files are regenerated.
Unknown motion/versions are never inferred from the size of a rectangle.
"""
import collections
import copy
import hashlib
import json
from pathlib import Path
from build_acquisition_navigation import Evidence, REPORT, coordinate

ROOT = Path(__file__).resolve().parents[1]
REVIEW = ROOT / 'docs/navigation-integrity'
CITIES = {'Stormwind City':1453, 'Ironforge':1455, 'Darnassus':1457,
          'Orgrimmar':1454, 'Thunder Bluff':1456, 'Undercity':1458}


def fingerprint(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True).encode()).hexdigest()


def geometry(location):
    return {k:location[k] for k in ['zone','areaID','uiMapID','x','y','bounds','coordinateScope','dungeonApproach'] if k in location}


def represent(location):
    loc=copy.deepcopy(location)
    if 'x' in loc and 'y' in loc:
        loc.setdefault('locationKind','published-point')
    elif 'bounds' in loc:
        loc.setdefault('locationKind','published-region')
        loc.setdefault('instructions','Approximate published region. NPC motion, spawn distribution and version agreement are not established; no corner is an exact NPC destination.')
    else:
        loc.setdefault('locationKind','map-frame-unresolved' if loc.get('coordinateScope') else 'unknown')
    loc.setdefault('locationConfidence','retained-published-reference')
    return loc


def raw_observations():
    evidence=Evidence()
    for path in sorted(REPORT.glob('checkpoint*evidence.json')):
        if 'partial' not in path.name:
            evidence.visit(json.loads(path.read_text()),path.name)
    # Some approved supplier mappers live in the reviewed recipe joins rather
    # than checkpoint responses. Keep their raw points and exact NPC proof.
    for book in json.loads((REPORT/'reviewed_recipe_sources.json').read_text()):
        for vendor in book.get('vendorEvidence',[]):
            npc=vendor.get('npcID');url=vendor.get('npcURL','');digest=vendor.get('npcPageSHA256','')
            if type(npc)is not int or url!=f'https://www.wowhead.com/forever/npc={npc}' or len(digest)!=64:continue
            _,actor=evidence.source('npc',npc,vendor.get('name'),dict(url=url,sha256=digest,file='reviewed_recipe_sources.json'))
            for area,locations in (vendor.get('mapReference')or{}).items():
                for loc in locations:
                    evidence.append_location(actor,evidence.location(loc.get('uiMapName'),area,loc))
    return evidence.sources


def validate_record(record,source):
    assert record['status']==200 and len(record['sha256'])==64
    assert record['url']==f"https://www.wowhead.com/forever/npc={record['npcID']}"
    assert record['title'].split(' - ')[0]==source['name'], 'NPC identity mismatch'


def review_locations(export, research=None, decisions=None, originals=None):
    research=research if research is not None else json.loads((REVIEW/'research/city-locations.json').read_text())
    decisions=decisions if decisions is not None else json.loads((REVIEW/'location-decisions.json').read_text())
    originals=originals if originals is not None else raw_observations()
    fresh={f"npc:{r['npcID']}":r for r in research if r.get('status')==200}
    updates,rows,counts={},[],collections.Counter()
    for key,source in sorted(export['sources'].items()):
        before=source.get('locations',[])
        after=[represent(loc) for loc in before]
        record=fresh.get(key)
        proofs=[]
        if record:
            validate_record(record,source)
            proofs=[{k:record[k] for k in ['url','sha256','retrieved','bytes']}]
            for i,loc in enumerate(before):
                # No name-only/map-frame conversions and no adoption of a new
                # region merely because another version lists the same NPC.
                zone=loc.get('zone');map_id=CITIES.get(zone)
                if not map_id or loc.get('uiMapID') not in [None,map_id]:continue
                candidates=[]
                for area_id,areas in record.get('mapper',{}).items():
                    for area in areas:
                        if area.get('uiMapName')==zone and area.get('uiMapId')==map_id:
                            location=Evidence().location(zone,int(area_id),area)
                            if location and 'bounds' in location:candidates.append(location)
                if not candidates:continue
                # Reviewed capital records have one map-bound footprint. Never
                # combine separate footprints or choose one by list ordering.
                assert len(candidates)==1, 'Separate spawn/area decision required: '+key
                accepted=represent(candidates[0])
                decision=decisions.get(key,{})
                if decision.get('point'):
                    point=decision['point']
                    assert all(coordinate(v) for v in point) and len(point)==2
                    assert point in accepted['coordinateObservations'], 'Accepted point absent from primary evidence'
                    assert decision.get('corroboration') and decision.get('reason')
                    accepted.pop('bounds',None);accepted.update(x=point[0],y=point[1],locationKind='stationary')
                    accepted.pop('instructions',None)
                elif decision.get('locationKind'):
                    assert decision['locationKind'] in ['stationary','roaming','multiple-spawns','conflicting-evidence','published-region']
                    accepted['locationKind']=decision['locationKind']
                accepted['locationConfidence']='reviewed-primary-reference'
                accepted['instructions']=(decision.get('reason') or 'Current exact Forever NPC/map reference; earlier incompatible observations retained in the location audit. Published geometry does not establish motion or current presence.')
                if accepted.get('bounds') and 'x' not in accepted:
                    accepted['instructions']+=' Approximate published area; no precise NPC point is asserted.'
                after[i]=accepted
        if after!=before:updates[key]=after
        kinds=sorted({loc['locationKind'] for loc in after})
        original=originals.get(key,{})
        conflict=[]
        if any(geometry(a)!=geometry(b)for a,b in zip(before,after)):
            conflict.append('Earlier frozen geometry differs from current exact NPC/map reference; retained below, not averaged.')
            counts['geometryCorrectedSources']+=1
        if any('bounds'in loc and 'x'not in loc for loc in before):counts['originalAreaSources']+=1
        raw=original.get('locations',[])
        frames=collections.defaultdict(set)
        for loc in raw:
            frames[loc.get('zone')].add(loc.get('uiMapID'))
        analysis=dict(distinctUnmergedGeometries=len({fingerprint(geometry(l))for l in raw}),
                      multipleMapFrames=sorted(zone for zone,ids in frames.items()if len(ids-{None})>1),
                      motionEstablished=False,
                      interpretation='Mapper observations alone do not distinguish patrols, spawns, stale versions or extraction errors.')
        if analysis['multipleMapFrames']:conflict.append('Multiple explicit UI map frames retained separately; no coordinate conversion inferred.')
        unresolved=not after or any(loc['locationKind'] in ['published-region','conflicting-evidence','unknown','map-frame-unresolved'] or ('bounds'in loc and 'x'not in loc)for loc in after)
        if unresolved:counts['unresolvedSources']+=1
        for kind in kinds:counts['kind:'+kind]+=1
        rows.append(dict(source=key,name=source.get('name'),kind=source.get('kind','bag-quest-actor'),
            categories=sorted(source.get('categories',{})),oldLocations=before,acceptedLocations=after,
            originalEvidence=source.get('evidence',[]),unmergedObservations=original.get('locations',[]),
            evidenceAnalysis=analysis,
            observationEvidence=original.get('evidence',[]),reviewedEvidence=proofs,
            decision=decisions.get(key),confidence=sorted({loc['locationConfidence']for loc in after}),
            conflicts=conflict,unresolved=unresolved,
            nextAction='Compare exact NPC identity and UI map with versioned client position; preserve separate routes/spawns and resolve conflicting observations.' if unresolved else 'Owner actual-client confirmation still required.'))
    counts.update(sourceRecords=len(rows),locationRecords=sum(len(s.get('locations',[])) for s in export['sources'].values()),
                  originalNonzeroBounds=sum(1 for s in export['sources'].values() for loc in s.get('locations',[]) if 'bounds'in loc and (loc['bounds']['xMin']!=loc['bounds']['xMax'] or loc['bounds']['yMin']!=loc['bounds']['yMax'])),
                  reviewedPrimarySources=len(fresh),projectedSources=len(updates))
    return updates,dict(schema=1,counts=dict(counts),actualClientVerified=False,
                        baselineFingerprint=fingerprint(export['sources']),sources=rows)
