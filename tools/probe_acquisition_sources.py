#!/usr/bin/env python3
"""Read-only schema probe for public source catalogues; prints no proprietary data."""
import json,urllib.request,urllib.error,collections
urls={
"classic_items":"https://www.wowforeverfriends.org/items/items.json",
"classic_npcs":"https://www.wowforeverfriends.org/library/data/npcs.json",
"everloot_drops":"https://everloot.app/api/rollups/drops?limit=2",
"playfulls":"https://playfulls.com/database",
"eternadex_recipes":"https://eternadex.com/en/rezepte/",
"fdb_professions":"https://foreverdb.net/api/v1/professions/blacksmithing?limit=2",
}
def summarize(value):
 if isinstance(value,dict):return dict(keys=list(value)[:18],sample={k:type(v).__name__ for k,v in list(value.items())[:10]})
 if isinstance(value,list):return dict(length=len(value),first=value[0] if value else None)
 return str(value)[:200]
for key,url in urls.items():
 try:
  req=urllib.request.Request(url,headers={"User-Agent":"GetGear-AcquisitionAudit/1.0","Accept":"application/json,text/html"})
  with urllib.request.urlopen(req,timeout=30) as resp:
   data=resp.read(35000000);ct=resp.headers.get("Content-Type","")
   print("PROBE",key,resp.status,ct,len(data))
  try:
   j=json.loads(data);print("SCHEMA",key,json.dumps(summarize(j),default=str)[:3000])
   if key=="classic_items":
    d=j.get("items",j) if isinstance(j,dict) else j
    for id in ["1943","1951","250489","251341","5192"]:
     v=d.get(id) if isinstance(d,dict) else next((x for x in d if isinstance(x,dict) and str(x.get("id"))==id),None)
     print("CLASSIC_ITEM",id,json.dumps(v,default=str)[:2600])
   if key=="classic_npcs":
    d=j.get("npcs",j) if isinstance(j,dict) else j
    for id in ["1732","634","644","630","1725"]:
     v=d.get(id) if isinstance(d,dict) else next((x for x in d if isinstance(x,dict) and str(x.get("id"))==id),None)
     print("CLASSIC_NPC",id,json.dumps(v,default=str)[:2600])
   if key=="everloot_drops":print("DROPS_EXAMPLE",json.dumps(j.get("rates",[])[:2]))
  except Exception as e:
   print("TEXT",key,data[:400].decode("utf8","replace"),"jsonerror",str(e))
 except Exception as e: print("ERROR",key,str(e)[:240])
