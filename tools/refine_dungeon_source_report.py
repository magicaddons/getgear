#!/usr/bin/env python3
"""Offline correction of direct dungeon-name classification in an existing audit.

Reads saved output only, and the same published client encounter roster.
Does not scrape loot pages, promote live claims, or alter addon Lua.
"""
import collections,csv,importlib.util,json,pathlib,re,urllib.request
root=pathlib.Path("docs/source-audit-1-60")
spec=importlib.util.spec_from_file_location("source_audit","tools/audit_forever_sources.py")
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
url="https://raw.githubusercontent.com/Everloot/everloot/main/web/src/data/game-data/client-encounters.json"
with urllib.request.urlopen(urllib.request.Request(url,headers={"User-Agent":"GetGear-SourceAudit-Review/1.0"}),timeout=20) as r:
    observed=json.load(r)
bosses={module.norm(e.get("name")) for entries in observed["instances"].values() for e in entries if e.get("name")}
def read(filename):
    with (root/filename).open(encoding="utf-8",newline="") as f:return list(csv.DictReader(f))
def write(filename,rows,fields):
    with (root/filename).open("w",encoding="utf-8",newline="") as f:
        w=csv.DictWriter(f,fieldnames=fields);w.writeheader();w.writerows(rows)
items=read("all_items.csv")
assert len(items)==7707
changed=[]
for item in items:
    old=item["dungeonClassification"]
    # The complete item export names the property acquisitionConfidence;
    # audit rows call it sourceEvidence.
    temp={"sourceType":item["sourceType"],"source":item["source"],
          "acquisitionConfidence":item.get("sourceEvidence","")}
    new=module.dungeon_source(temp,bosses)
    # The human-readable audit CSV omits acquisitionKind; if the item was
    # only dungeon-associated through that field, retain its original label.
    if new=="not-dungeon" and old!="not-dungeon":continue
    if old==new:continue
    unresolved=("dungeon; enemy unresolved","named dungeon enemy; boss/trash unresolved")
    promoted=old in unresolved and new.startswith("named client")
    downgraded=old.startswith("named client") and new in unresolved
    assert promoted or downgraded,(old,new)
    item["dungeonClassification"]=new
    flags=set(x for x in item["issues"].split(";") if x)
    if promoted:
        flags.discard("dungeon_enemy_or_role_unresolved")
    else:
        # Some imported "boss names" are ordinary mobs. The published
        # client encounter roster cannot establish a boss identity here.
        flags.add("dungeon_enemy_or_role_unresolved")
    item["issues"]=";".join(sorted(flags))
    changed.append({"itemID":item["itemID"],"name":item["name"],"source":item["source"],
        "old":old,"new":new,
        "evidence":("Named Forever client encounter, NOT confirmed loot"
            if promoted else "Not a recognised client encounter; boss/trash remains unresolved"),
        "encounterSource":url})
write("all_items.csv",items,list(items[0]))
write("unresolved_items.csv",[x for x in items if x["issues"]],list(items[0]))
write("dungeon_sources.csv",[x for x in items if x["dungeonClassification"]!="not-dungeon"],list(items[0]))
write("dungeon_sources_unresolved.csv",[x for x in items if "dungeon_enemy_or_role_unresolved" in x["issues"]],list(items[0]))
if changed:write("dungeon_role_reconciliation.csv",changed,list(changed[0]))
allissues=collections.Counter()
allkind=collections.Counter()
for row in items:
    allkind[row["dungeonClassification"]]+=1
    for issue in set(row["issues"].split(";")):
        if issue:allissues[issue]+=1
README=root/"README.md"
doc=README.read_text(encoding="utf8")
doc=re.sub(r"(- Items with one or more outstanding flags: )\*\*[\d,]+\*\*",
           lambda m:m.group(1)+"**"+f"{sum(bool(x['issues']) for x in items):,}"+"**",doc)
start=doc.index("## Dungeon classifications")
end=doc.index("## Interpretation and limitations",start)
dungeon_lines=["## Dungeon classifications"]
for k,n in allkind.most_common():dungeon_lines.append(f"- {k}: {n:,}")
dungeon_lines.extend(["","## Outstanding issue counts"])
for k,n in allissues.most_common():dungeon_lines.append(f"- {k}: {n:,}")
dungeon_lines.append("")
doc=doc[:start]+"\n".join(dungeon_lines)+"\n"+doc[end:]
doc=doc.replace("- [Unresolved item queue](unresolved_items.csv)",
   "- [Direct-name dungeon classification corrections](dungeon_role_reconciliation.csv) (client encounters, no new drop claims)\n- [Unresolved item queue](unresolved_items.csv)")
README.write_text(doc,encoding="utf8")
focus=root/"FOCUS_QUEUES.md"
if focus.exists():
    text=focus.read_text()
    num=len([x for x in items if "dungeon_enemy_or_role_unresolved" in x["issues"]])
    text=re.sub(r"(dungeon_sources_unresolved.csv\) — \*\*)[\d,]+",lambda m:m.group(1)+f"{num:,}",text)
    focus.write_text(text)
print(f"PASS direct-named Forever encounter reconciliation: {len(changed)} corrected, "
      f"{len([x for x in items if 'dungeon_enemy_or_role_unresolved' in x['issues']])} remaining ambiguous; "
      f"{sum(bool(x['issues']) for x in items)} total flagged")
