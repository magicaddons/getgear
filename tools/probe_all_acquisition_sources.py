#!/usr/bin/env python3
import urllib.request, urllib.error, json, re, collections, html, time
urls={
"forever_cache":"https://raw.githubusercontent.com/Napalmsteak/WoW-Classic-Item-Caches/main/Forever%20Cache.json",
"classic_items":"https://www.wowforeverfriends.org/items/items.json",
"classic_npcs":"https://www.wowforeverfriends.org/library/data/npcs.json",
"everloot_edges":"https://everloot.app/api/edges?evidence=observed&limit=500",
"everloot_encounters":"https://raw.githubusercontent.com/Everloot/everloot/main/web/src/data/game-data/client-encounters.json",
"playfulls":"https://playfulls.com/database",
"playfulls_script":"https://playfulls.com/database.js?v=55a74b15ec",
"ahl_recipe":"https://api.ahledger.com/v1/crafting/forever.normal.alliance.us?all=1&limit=2000&profession=Blacksmithing",
}
for name,url in urls.items():
 try:
  req=urllib.request.Request(url,headers={"User-Agent":"GetGear-source-research/1.0 (github.com/magicaddons/getgear)","Accept":"application/json,text/html"})
  with urllib.request.urlopen(req,timeout=40) as r:
   b=r.read(28_000_000)
   print("SOURCE",name,"status",r.status,"bytes",len(b),"content_type",r.headers.get("Content-Type"))
  if name=="playfulls_script":
   text=b.decode("utf8","replace")
   for token in ("/api/","fetch(","/data/","/database","catalog","item/","sources","endpoint","JSON.parse"):
    indexes=[m.start() for m in re.finditer(re.escape(token),text)]
    print("SCRIPT_TOKEN",token,len(indexes))
    for i in indexes[:4]: print("SCRIPT_CONTEXT",text[max(0,i-110):i+210].replace("\\n"," ")[:320])
   continue
  if name=="playfulls":
   text=b.decode("utf8","replace")
   srcs=re.findall(r'<script[^>]*?src="([^"]+)"',text)
   print("SCRIPTS",len(srcs),srcs[:20])
   for token in ('itemDatabase','__NEXT_DATA__','items.json','database.json','api/items','NEXT_PUBLIC','__next_f','data-db-page','"shards"','"meta"','shards','db-config','data-db-','CFG','index-shard'):
    i=text.find(token)
    print("HTMLTOKEN",token,i,text[max(0,i-180):i+750] if i>=0 else "")
   continue
  obj=json.loads(b)
  print("ROOT",name,type(obj).__name__,len(obj),list(obj)[:14] if isinstance(obj,dict) else ("first keys "+str(list(obj[0])[:20]) if obj else "empty"))
  if name=="forever_cache":
   rows={r.get("itemId"):r for r in obj}
   for id in [1943,1951,1482,776,250489,273884,270027]:
    item=rows.get(id,{})
    print("FOREVER_ITEM",id,json.dumps({k:item.get(k) for k in ['name','sourceTypes','sourceLabels','bossNames','lastUpdatedAt']},ensure_ascii=False)[:2200])
  if name=="classic_items":
   d=obj.get("items",[]) if isinstance(obj,dict) else obj
   rows={r.get("id"):r for r in d if isinstance(r,dict)}
   for id in [1943,1951,1482,776,273884]:
    print("CLASSIC_ITEM",id,json.dumps(rows.get(id),ensure_ascii=False)[:1600])
  if name=="classic_npcs":
   d=obj.get("records",[]) if isinstance(obj,dict) else obj
   print("NPC_SAMPLE",json.dumps(d[:2],ensure_ascii=False)[:1500])
   for id in [634,644,658,657,1732,3947]:
    row=next((r for r in d if r.get('id',r.get('npcId'))==id),None)
    print("NPC",id,json.dumps(row,ensure_ascii=False)[:1000])
  if name=="everloot_edges":
   edges=obj.get("edges",[])
   print("EDGE_META",json.dumps({k:v for k,v in obj.items() if k!="edges"})[:1400])
   print("EDGE_SAMPLES",json.dumps(edges[:8],ensure_ascii=False)[:5000])
   print("EDGE_REL",collections.Counter(e.get("rel") for e in edges))
  if name=="everloot_encounters":
   print("ENCOUNTER_SAMPLE",json.dumps(list(obj.get("instances",{}).items())[:2],ensure_ascii=False)[:2800])
  if name=="ahl_recipe":
   recipes=obj.get("recipes",[])
   print("AHL_SAMPLES",json.dumps(recipes[:4],ensure_ascii=False)[:4000])
 except Exception as e: print("SOURCE_ERROR",name,str(e)[:300])
