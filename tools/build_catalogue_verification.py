"""Validate additive recipe joins and preferred commerce requirements from publication extracts."""
import collections
import gzip
import html
import json
import re
from pathlib import Path

from build_acquisition_navigation import PROFESSION_SKILLS, lua
from research_sources import require_research

ROOT=Path(__file__).resolve().parents[1]
D=ROOT/'docs/catalogue-verification-20261125'


def extracts():
    rows=json.loads(gzip.decompress((D/'publication-extracts.json.gz').read_bytes()))
    for row in rows:
        require_research(row['url'],dataset=True)
        if row['status']=='retrieved':
            assert re.fullmatch('[0-9a-f]{64}',row['sha256'])
    return rows


def recipe_rows(publications):
    found=[]
    for proof in publications:
        if proof.get('kind')=='recipe-inventory' and proof.get('extractStatus')=='parsed':
            for row in proof['rows']: found.append((row,proof))
    return found


def unique_recipe(item, rows):
    """Require exact output/name/profession/material quantities; ambiguity stays open."""
    candidates={}
    materials={row['itemID']:row['amount'] for row in item.get('reagents',[])}
    for row,proof in rows:
        if ((row.get('creates')or[None])[0]==item['itemID'] and html.unescape(row.get('name',''))==item['name']
            and PROFESSION_SKILLS.get(item.get('profession')) in row.get('skill',[])
            and row.get('envChange',{}).get('status')!='unconfirmed'
            and dict(row.get('reagents',[]))==materials):
            key=json.dumps(row,sort_keys=True)
            candidates[key]=(row,proof)
    identifiers={row['id'] for row,_ in candidates.values()}
    # Multiple sources/metadata copies cannot make an ambiguous identity unique.
    if len(identifiers)!=1:return None
    signatures={json.dumps({k:row.get(k)for k in ('creates','skill','reagents','learnedat')},sort_keys=True)
                for row,_ in candidates.values()}
    return next(iter(candidates.values())) if len(signatures)==1 else None


def validate_corrections():
    rows=recipe_rows(extracts())
    records=json.loads((D/'recipe-corrections.json').read_text())
    for identifier,record in records.items():
        item=record['original']; assert str(item['itemID'])==identifier and item.get('recipeSpellID') is None
        match=unique_recipe(item,rows)
        assert match and match[0]['id']==record['recipeSpellID']
        assert match[1]['sha256']==record['evidence']['sha256']
    return records


def render_recipe_corrections():
    records=validate_corrections()
    return '''
-- Additive exact name/output/profession/reagent joins. Original ingredients,
-- eligibility, minima and acquisition alternatives are preserved.
GetGear.CatalogueRecipeCorrections='''+lua(records)+'''
for id,record in pairs(GetGear.CatalogueRecipeCorrections) do
    local gear=GetGear.ItemCatalog[tonumber(id)]
    if gear and not gear.recipeSpellID and gear.name==record.original.name
        and gear.profession==record.original.profession then
        gear.recipeSpellID=record.recipeSpellID
    end
end
'''


def commerce_preferences():
    records=json.loads((D/'commerce-skill-evidence.json').read_text())
    rows=recipe_rows(extracts())
    for book,record in records.items():
        matches=[(row,proof)for row,proof in rows if row.get('id')==record['spellID']
                 and row.get('learnedat')==record['preferredLearningSkill']
                 and PROFESSION_SKILLS[record['profession']]in row.get('skill',[])]
        assert matches and any(proof['sha256']==record['evidence']['sha256']for _,proof in matches)
        assert record['bookLearningSkill']==record['preferredLearningSkill']!=record['guideLearningSkill']
    return records
