"""Persist fact extracts from approved publication responses, without page scripts/prose."""
import argparse
import gzip
import hashlib
import json
import re
from pathlib import Path

from catalogue_verification import Archive, listview, related, spells
from build_acquisition_navigation import PROFESSION_SKILLS

PROFESSIONS = {key.lower().replace(' ','-'):value for key,value in PROFESSION_SKILLS.items()}


def compile_archive(archive):
    result = []
    for url, receipt in sorted(archive.receipts.items()):
        row = dict(receipt)
        if receipt['status'] != 'retrieved':
            result.append(row)
            continue
        page = archive.read(receipt)
        try:
            if '/items/' in url:
                rows = listview(page, 'items')
                slot = int(re.search(r'slot:(\d+)',url)[1])
                if any(item.get('slot') != slot for item in rows):
                    raise ValueError('Publisher ignored requested slot facet')
                # A filtered result may omit names/requirements on suffix rows;
                # preserve the variants, then demand consensus at field joins.
                row.update(kind='equipment-inventory', rows=rows, requestedSlot=slot,
                           truncated=bool(re.search(r'_truncated\s*:\s*1',page)))
            elif '/spells/' in url:
                profession=url.rsplit('/',1)[1]
                rows = listview(page, 'spells')
                skill = PROFESSIONS[profession]
                if any(skill not in item.get('skill',[]) for item in rows):
                    raise ValueError('Publisher ignored requested profession facet')
                row.update(kind='recipe-inventory', rows=rows, professionSkillID=skill,
                           truncated=bool(re.search(r'_truncated\s*:\s*1',page)))
            elif re.search(r'/(?:item|spell|npc|quest|object)=\d+',url):
                row.update(kind='entity-page', lists=related(page), spellDefinitions=spells(page))
            else:
                row.update(kind='publication-page', note='Response provenance retained; page prose not redistributed.')
            row['extractStatus']='parsed'
        except (ValueError, KeyError, AssertionError, IndexError) as error:
            row.update(extractStatus='rejected', parseError=str(error))
        # The raw response remains outside source control. This extract has its
        # own checksum; it is never mislabeled as the exact response bytes.
        result.append(row)
    return result


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--archive',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    result=compile_archive(Archive(args.archive))
    data=(json.dumps(result,sort_keys=True,separators=(',',':'))+'\n').encode()
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_bytes(gzip.compress(data,mtime=0))
    print('Persisted',len(result),'request outcomes; extract SHA256',hashlib.sha256(data).hexdigest())


if __name__=='__main__':main()
