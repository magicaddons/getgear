#!/usr/bin/env python3
"""Generate a conservative offline index of uncommon Bind-on-Equip world drops.

The inclusion test requires ALL of:
  - GetGear says world drop, not dungeon/quest/craft/vendor;
  - Classic's published item metadata says Uncommon + Binds when equipped;
  - a separate Forever item catalogue independently says quality UNCOMMON;
  - exact name agreement between Classic and GetGear (normalised punctuation).
This is a fallback when Forever's own GetItemInfo isn't cached. Live client
quality/bind always take priority and can override it. No server loot claims.
"""
import csv,json,urllib.request,re,hashlib,collections,pathlib,sys
root=pathlib.Path(".")
source=root/"docs/source-audit-1-60/all_items.csv"
assert source.exists(), "Run 1-60 evidence audit before generating world-drop BoE index"
def pull(url):
    req=urllib.request.Request(url,headers={"User-Agent":"GetGear-DataQualityIndex/1.0","Accept":"application/json"})
    with urllib.request.urlopen(req,timeout=40) as resp:data=resp.read(30000000)
    return json.loads(data),hashlib.sha256(data).hexdigest()
classicUrl="https://www.wowforeverfriends.org/items/items.json"
classic,classic_sha=pull(classicUrl)
byClassic={int(row["id"]):row for row in classic["items"]
           if isinstance(row,dict) and isinstance(row.get("id"),int)}
foreverQual={}
sources=[]
for cat in ("armor","weapon","recipe","trade-goods"):
    url="https://ahledger.com/api/catalog?class="+cat
    data,hashValue=pull(url)
    sources.append((url,hashValue))
    for row in data.get("rows",[]):
        if isinstance(row,list) and len(row)>2 and isinstance(row[0],int):
            foreverQual[row[0]]=str(row[2]).upper()
def canon(value):
    return re.sub(r"[^a-z0-9]","",str(value or "").casefold())
with source.open(encoding="utf8",newline="") as f:records=list(csv.DictReader(f))
assert len(records)==7707,len(records)
chosen=[]
rejects=collections.Counter()
for row in records:
    st=str(row.get("sourceType","")).lower()
    acq=str(row.get("source","")).lower()
    if "world drop" not in st:continue
    # A reviewed alternative acquisition route protects an otherwise
    # imported generic source label from unintended hiding.
    if any(key in st or key in acq for key in
           ("dungeon","quest","vendor","crafted","reputation")):
        rejects["targetable"]+=1;continue
    if row.get("profession"):rejects["crafted"]+=1;continue
    iid=int(row["itemID"])
    other=byClassic.get(iid)
    if not other:rejects["no-classic-record"]+=1;continue
    if canon(other.get("name"))!=canon(row["name"]):
        rejects["name-mismatch"]+=1;continue
    if other.get("quality")!="Uncommon" or other.get("binding")!="Binds when equipped":
        rejects["not-green-boe"]+=1;continue
    if foreverQual.get(iid)!="UNCOMMON":
        rejects["forever-quality-not-confirmed"]+=1;continue
    chosen.append(iid)
chosen.sort()
assert len(chosen)>100, f"Not enough cross-validated green BoEs: {len(chosen)}; {rejects}"
path=root/"WorldDropBoEIndex.lua"
with path.open("w",encoding="utf8") as f:
    f.write("local addonName, GetGear = ...\n")
    f.write("-- Conservative Classic BoE metadata cross-checked with a Forever quality index.\n")
    f.write("-- Fallback only; live client GetItemInfo always overrides this classification.\n")
    f.write("-- This is NOT a drop/source evidence index. Do not use for actual loot rates.\n")
    f.write("GetGear.WorldDropGreenBoEIndex = {\n")
    for i in range(0,len(chosen),10):
        f.write("    "+", ".join("["+str(x)+"]=true" for x in chosen[i:i+10])+",\n")
    f.write("}\n")
audit=root/"docs/source-audit-1-60/BOE_FILTER_INDEX.md"
audit.write_text("# Conservative green BoE world-drop filter index\n\n"+
    f"- Total items: **{len(chosen)}**\n"+
    "- These are only GENERIC WORLD DROPS; crafting, quest, dungeon and vendor items were excluded.\n"+
    "- Default overlay rule uses GetItemInfo when loaded; this index is only the offline fallback.\n"+
    "- The full guide and user Hidden/Acquired statuses are unchanged.\n"+
    "- Classic binding metadata is a provisional reference, not verified live Forever binding.\n\n"+
    "## Data provenance\n"+
    f"- [Classic item reference]({classicUrl}), SHA256 "+classic_sha+"\n"+
    "".join(f"- [Forever quality catalogue]({url}), SHA256 {sha}\n" for url,sha in sources)+
    "\n## Rejected source candidates\n"+
    "".join(f"- {k}: {v}\n" for k,v in sorted(rejects.items())),encoding="utf8")
print("PASS green BoE index",len(chosen),"from",len(records),"items; rejects",dict(rejects))
