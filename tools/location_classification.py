"""Offline location decisions. A navigation point is not an exact-spawn claim.

Distances use map-specific world extents, never Euclidean percentage distances.
No renderer, network access, NPC exceptions or runtime dependencies live here.
"""
import copy
import math
import re
from pathlib import Path
import json
import csv
import hashlib
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / 'docs/location-review'
CLUSTER_YARDS = 15.0  # navigation tolerance, not a statistical error bound


def number(value):
    return type(value) in (int, float) and math.isfinite(value)


def coordinate(value):
    return number(value) and 0 <= value <= 100


def valid_bounds(bounds):
    return (isinstance(bounds, dict) and all(coordinate(bounds.get(k)) for k in ('xMin', 'xMax', 'yMin', 'yMax'))
            and bounds['xMin'] <= bounds['xMax'] and bounds['yMin'] <= bounds['yMax'])


class MapCatalog:
    def __init__(self, maps=None, geometry=None):
        frozen = json.loads((DATA / 'maps.json').read_text())
        self.maps = maps if maps is not None else frozen['maps']
        self.geometry = geometry if geometry is not None else frozen['geometry']
        if geometry is None:
            for name, digest in frozen['provenance']['fileHashes'].items():
                assert name in ('uimap_classic.csv', 'uimapassignment_classic.csv')
                assert hashlib.sha256((DATA/name).read_bytes()).hexdigest() == digest, 'Map evidence hash mismatch'
            with (DATA/'uimapassignment_classic.csv').open() as handle:
                rows = {int(r['UiMapID']): r for r in csv.DictReader(handle)}
            with (DATA/'uimap_classic.csv').open() as handle:
                names = {int(r['ID']): r for r in csv.DictReader(handle)}
            for map_id, entry in self.geometry.items():
                if entry.get('geometryStatus') == 'published-classic-frame-reference':
                    r = rows[int(map_id)]
                    assert names[int(map_id)]['Name_lang'] == entry['name']
                    assert entry['widthYards'] == (float(r['Region[4]'])-float(r['Region[1]']))/(float(r['UiMax[0]'])-float(r['UiMin[0]']))
                    assert entry['heightYards'] == (float(r['Region[3]'])-float(r['Region[0]']))/(float(r['UiMax[1]'])-float(r['UiMin[1]']))

    def valid(self, zone, map_id, local=True):
        ids = self.maps.get(zone, [])
        row = self.geometry.get(str(map_id), {})
        return (type(map_id) is int and map_id > 0 and map_id in ids
                and (not row.get('name') or row['name'] == zone)
                and (not local or row.get('mapType') != 'continent'))

    def size(self, zone, map_id):
        if not self.valid(zone, map_id):
            return None
        row = self.geometry.get(str(map_id), {})
        width, height = row.get('widthYards'), row.get('heightYards')
        if all(number(v) and v > 0 for v in (width, height)):
            return width, height
        return None

    def distance(self, zone, map_id, a, b):
        size = self.size(zone, map_id)
        if not size:
            return None
        return math.hypot((a[0]-b[0])*size[0]/100, (a[1]-b[1])*size[1]/100)


def clusters(points, distance, tolerance=CLUSTER_YARDS):
    """Deterministic complete-link groups; chains cannot bridge distant spawns."""
    groups = []
    for point in sorted(set(tuple(p) for p in points)):
        for group in groups:
            if all(distance(point, other) <= tolerance for other in group):
                group.append(point)
                break
        else:
            groups.append([point])
    return groups


def observation_family(record):
    # Different URLs/domains or snapshot hashes do not prove independence.
    # Only a traced collector/observation identity can create another family.
    origin = record.get('origin') or {}
    if origin.get('collector') and origin.get('observationID') and origin.get('traceable') is True:
        return 'observation:' + str(origin['collector']) + ':' + str(origin['observationID'])
    return 'unresolved-publications:' + str(record['npcID'])


def verified(record):
    origin = record.get('origin') or {}
    npc = record['npcID']
    guid = str(origin.get('targetGUID', ''))
    fields = guid.split('-')
    return (record.get('kind') == 'npc-position' and origin.get('subject') == 'npc'
            and origin.get('traceable') is True and origin.get('clientBuild')
            and origin.get('collector') and origin.get('observationID')
            and len(fields) == 7 and fields[0] in ('Creature', 'Vehicle')
            and fields[5] == str(npc) and record.get('physicalPositionVerified') is True)


def fixed_spawn_witnesses(records, distance):
    """Explicit spawn identities take precedence over geometric closeness."""
    by_id = {}
    for r in records:
        if r.get('kind') == 'documented-spawn' and r.get('spawnID') and r.get('motion') == 'fixed':
            by_id.setdefault(str(r['spawnID']), []).append(r)
    if len(by_id) < 2:
        return None, None
    def near(a, b):
        if a == b:return True
        d = distance(a, b)
        return d is not None and d <= CLUSTER_YARDS
    if not all(all(near((a['x'],a['y']),(b['x'],b['y'])) for a in rows for b in rows)for rows in by_id.values()):
        return None, 'One documented spawn identity has unresolved separated positions.'
    witnesses = [min(rows,key=lambda r:(r['x'],r['y']))for _,rows in sorted(by_id.items())]
    if not all(any(near((r['x'],r['y']),(w['x'],w['y']))for w in witnesses)for r in records):
        return None, 'Documented spawn points do not account for all retained observations.'
    return witnesses, None


def review(location, npc_id, observations, catalog, hold=None):
    """Return a decision and audit; never manufacture a point from bounds."""
    if type(npc_id) is not int or npc_id <= 0:
        raise ValueError('Expected a positive NPC identity')
    result = copy.deepcopy(location)
    zone, map_id = result.get('zone'), result.get('uiMapID')
    accepted, rejected = [], []
    for record in observations:
        reason = None
        if type(record.get('npcID')) is not int or record['npcID'] != npc_id:
            reason = 'wrong-npc-identity'
        elif type(record.get('uiMapID')) is not int or record.get('zone') != zone or record.get('uiMapID') != map_id or not catalog.valid(zone, map_id):
            reason = 'wrong-or-unvalidated-map'
        elif not (coordinate(record.get('x')) and coordinate(record.get('y'))):
            reason = 'invalid-coordinate'
        elif urlparse(str(record.get('url',''))).scheme not in ('http','https') or not urlparse(str(record.get('url',''))).netloc or not re.fullmatch(r'[0-9a-f]{64}', str(record.get('sha256', ''))):
            reason = 'missing-provenance'
        elif any(int(value)!=npc_id for value in re.findall(r'(?:npc=|/npcs?/)(\d+)',str(record.get('url','')))):
            reason = 'source-url-npc-mismatch'
        elif record.get('excludedReason'):
            reason = record['excludedReason']
        if reason:
            rejected.append(dict(record=record, reason=reason))
        else:
            accepted.append(copy.deepcopy(record))
    accepted.sort(key=lambda r: json.dumps(r, sort_keys=True))
    rejected.sort(key=lambda r: json.dumps(r, sort_keys=True))
    families = sorted({observation_family(r) for r in accepted})
    audit = dict(acceptedObservations=accepted, rejectedObservations=rejected,
                 independentEvidenceFamilies=families, independentFamilyCount=len(families),
                 toleranceYards=CLUSTER_YARDS, geometry=catalog.geometry.get(str(map_id)),
                 classification='unknown', reason='No usable map-bound position evidence.')
    if not catalog.valid(zone, map_id) or result.get('coordinateScope'):
        audit['reason'] = 'Unknown, continent-only or unvalidated coordinate frame; no local point asserted.'
    elif hold:
        audit.update(classification='approximate-area', reason=hold)
    elif accepted:
        points = sorted({(r['x'], r['y']) for r in accepted})
        size = catalog.size(zone, map_id)
        witnesses, spawn_error = fixed_spawn_witnesses(accepted,lambda a,b:catalog.distance(zone,map_id,a,b))
        if witnesses:
            audit.update(classification='multiple-spawn-points',reason='Explicitly documented distinct fixed spawn identities; closeness does not merge them.',selectedSpawnObservations=witnesses)
            spawned=[]
            for witness in witnesses:
                loc=copy.deepcopy(location);loc.pop('bounds',None)
                if 'bounds'in location:loc['originalBounds']=copy.deepcopy(location['bounds'])
                loc.update(x=witness['x'],y=witness['y'],spawnID=str(witness['spawnID']),locationKind='multiple-spawn-points',
                    locationClass='multiple-spawn-points',locationConfidence='reported-fixed-spawns',
                    instructions='Documented distinct fixed spawn point; current presence is not independently verified.',coordinateEvidence=copy.deepcopy(audit))
                spawned.append(loc)
            return spawned,audit
        # A single explicitly published position needs no distance calculation.
        # Several positions with missing geometry must not acquire a guessed scale.
        if spawn_error:
            audit.update(classification='approximate-area',reason=spawn_error)
        elif len(points) > 1 and not size:
            audit.update(classification='approximate-area', reason='Map dimensions unavailable; clustering withheld.')
        else:
            distance = lambda a, b: catalog.distance(zone, map_id, a, b) or 0.0
            groups = clusters(points, distance)
            audit['clusters'] = [list(map(list, g)) for g in groups]
            if len(groups) == 1:
                # Prefer explicit build-attributed point reports over mapper
                # samples. Select an actual observation, never a box midpoint.
                def rank(r):
                    priority = 3 if verified(r) else {'build-attributed-point': 2, 'primary-mapper': 1}.get(r.get('kind'), 0)
                    p = (r['x'], r['y'])
                    return (-priority, max(distance(p, q) for q in points), sum(distance(p, q) for q in points), p)
                chosen = min(accepted, key=rank)
                is_verified = verified(chosen)
                classification = 'verified-npc-point' if is_verified else 'reported-point'
                result.pop('bounds', None)
                result.update(x=chosen['x'], y=chosen['y'], locationKind=classification,
                              verification='published-reference', locationConfidence='npc-position-verified' if is_verified else 'credible-reported')
                if 'bounds' in location:
                    result['originalBounds'] = copy.deepcopy(location['bounds'])
                spread = max(distance(points[i], points[j]) for i in range(len(points)) for j in range(len(points)))
                audit.update(classification=classification, selectedObservation=chosen,
                             observedSpreadReferenceYards=round(spread, 3),
                             reason='Tightly clustered map-bound observations support a navigation point; publications are deduplicated by lineage.')
                result['instructions'] = ('Verified NPC-position observation; current presence still needs checking.' if is_verified else
                    'Reported navigation point. Exact physical spawn is not independently verified. '
                    + ('Observed spread %.1f map-reference yards; this is not a measured error bound.' % spread if size else 'Single published position; map distance is unmeasured.'))
            else:
                # Separated samples alone do not establish multiple fixed spawns.
                audit.update(classification='approximate-area', reason='Separated observations without documented fixed spawn identities; region retained.')
    elif valid_bounds(result.get('bounds')):
        audit.update(classification='approximate-area', reason='Only footprint evidence available; no observed point selected.')
    if audit['classification'] == 'unknown':
        for key in ('x', 'y', 'bounds'):
            if key in result:
                result.setdefault('withheldGeometry', {})[key] = result.pop(key)
    result['locationClass'] = audit['classification']
    result['coordinateEvidence'] = copy.deepcopy(audit)
    return [result], audit


def service_review(key, source, locations, original, primary, decision, catalog):
    """Audit every service footprint; use retained observations, not box corners."""
    npc_id = int(key.split(':')[1])
    extra = json.loads((DATA / 'reported-points.json').read_text())['observations']
    supplementary = []
    for record in extra:
        assert hashlib.sha256(json.dumps(record['extract'], sort_keys=True).encode()).hexdigest() == record['sha256'], 'Reported extract hash changed'
        assert all(record.get(k) == record['extract'].get(k) for k in ('npcID', 'name', 'zone', 'uiMapID', 'x', 'y', 'url', 'kind', 'origin', 'excludedReason')), 'Extract/coordinate identity mismatch'
        if record['npcID'] == npc_id:
            assert record['name'] == source['name'], 'Reported NPC name mismatch'
            supplementary.append(record)
    after, audits = [], []
    for loc in locations:
        if 'bounds' not in loc or 'x' in loc:
            after.append(loc)
            continue
        observations = []
        if primary and loc.get('coordinateObservations'):
            rows = [loc]
            proof = primary
        else:
            rows = [r for r in original.get('locations', []) if r.get('zone') == loc.get('zone')
                    and r.get('uiMapID') in (None, loc.get('uiMapID'))]
            proofs = [p for p in original.get('evidence', []) if re.fullmatch(
                r'https://www\.wowhead\.com/forever/npc=' + str(npc_id) + r'(?:/[^?]*)?', p.get('url', ''))]
            proof = proofs[0] if proofs else {}
        for row in rows:
            for point in row.get('coordinateObservations', []):
                pooled = dict(point=point, candidates=proofs) if not (primary and loc.get('coordinateObservations')) else None
                digest = hashlib.sha256(json.dumps(pooled,sort_keys=True).encode()).hexdigest() if pooled and proofs else proof.get('sha256')
                observations.append(dict(npcID=npc_id, zone=loc.get('zone'), uiMapID=loc.get('uiMapID'),
                    x=point[0], y=point[1], kind='primary-mapper', url=proof.get('url'), sha256=digest,
                    hashKind='retained-source-observation-pool' if pooled else 'primary-response',
                    pooledExtract=pooled,
                    provenanceCandidates=pooled['candidates'] if pooled else [dict(url=primary['url'],sha256=primary['sha256'])],
                    provenancePrecision='pooled-retained-observations' if pooled else 'primary-response-mapper',
                    origin=dict(traceable=False, lineage='unresolved-publications'),
                    note='Retained Forever NPC mapper observation; sampling method and physical spawn precision unverified.'))
        observations.extend(supplementary)
        hold = None
        if decision and decision.get('locationKind') in ('conflicting-evidence', 'roaming'):
            hold = decision['reason']
        frames = {r.get('uiMapID') for r in original.get('locations', []) if r.get('zone') == loc.get('zone') and r.get('uiMapID')}
        if len(frames)>1 and any(r.get('uiMapID') is None for r in rows):
            hold = 'Unresolved original coordinate frames.'
        if loc.get('locationKind') == 'roaming':
            hold = 'Explicitly documented movement; retain its area.'
        footprint_wide=False
        if valid_bounds(loc.get('bounds')):
            b = loc['bounds']
            diagonal = catalog.distance(loc.get('zone'), loc.get('uiMapID'), (b['xMin'], b['yMin']), (b['xMax'], b['yMax']))
            footprint_wide=diagonal is not None and diagonal > CLUSTER_YARDS
        classified, audit = review(loc, npc_id, observations, catalog, hold)
        if footprint_wide and audit['classification']in ('reported-point','verified-npc-point'):
            classified,audit=review(loc,npc_id,observations,catalog,
                'Retained footprint spans more than the navigation tolerance; no supported replacement by one point.')
        audits.append(dict(zone=loc.get('zone'), uiMapID=loc.get('uiMapID'), before=loc, after=classified, decision=audit))
        after.extend(classified)
    return after, audits
