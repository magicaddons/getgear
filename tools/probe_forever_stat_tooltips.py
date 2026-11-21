#!/usr/bin/env python3
import urllib.request,json,re,html
url="https://raw.githubusercontent.com/Napalmsteak/WoW-Classic-Item-Caches/main/Forever%20Cache.json"
req=urllib.request.Request(url,headers={"User-Agent":"GetGear-StatAudit/1.0"})
with urllib.request.urlopen(req,timeout=45) as resp:
    payload=resp.read(28000000)
j=json.loads(payload)
print("SCHEMA_ROOT",type(j).__name__,len(j),list(j[0].keys()))
by={x.get("itemId"):x for x in j}
for id in (250492,250522,250490,250520,250488,250519,250501,250502,3313,252509,250491,250517,250527,1951,250525,2851):
    row=by.get(id)
    print("ITEM",id,row.get("name") if row else None,
          "tooltipLength",len(row.get("tooltipHtml","")) if row else None,
          "tooltip",row.get("tooltipHtml","")[:2400] if row else None)
