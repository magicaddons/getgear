#!/usr/bin/env python3
import urllib.request,urllib.parse, json, re,collections,hashlib,html
base="https://playfulls.com"
def get(path,limit=25000000):
 u=path if path.startswith("https:") else base+path
 req=urllib.request.Request(u,headers={"User-Agent":"GetGear-public-data-research/1.0","Accept":"application/json,text/html"})
 with urllib.request.urlopen(req,timeout=50) as r:
  body=r.read(limit);ct=r.headers.get("Content-Type","")
 return body,ct
b,_=get("/database")
m=re.search(r'<script[^>]*id="db-data"[^>]*>(.*?)</script>',b.decode("utf-8","replace"),re.S)
assert m,"No db-data"
cfg=json.loads(html.unescape(m.group(1)))
print("CONFIG",json.dumps({k:cfg.get(k) for k in ("meta","shards","n","rows")}))
for path in [cfg["meta"]]+cfg["shards"]:
 raw,ct=get(path)
 obj=json.loads(raw)
 print("DATA",path,len(raw),hashlib.sha256(raw).hexdigest()[:12],type(obj).__name__,len(obj),list(obj)[:25] if isinstance(obj,dict) else "list")
 if isinstance(obj,dict):
  for k,v in list(obj.items())[:11]:
   print("FIELD",k,"type",type(v).__name__,"length",len(v) if hasattr(v,"__len__") else "na","sample",str(v[:1] if isinstance(v,list) else v)[:1400])
  d=obj.get("rows",obj.get("items",[]))
 else:d=obj
 if isinstance(d,list) and d:
  print("ROW_SAMPLES",json.dumps(d[:2])[:2400])
  if isinstance(obj,dict) and "so" in obj:
   print("SOURCE_KINDS",json.dumps(obj.get("sk"),ensure_ascii=False)[:3500])
   print("SOURCE_NAMES",json.dumps(obj.get("src")[:6],ensure_ascii=False)[:3000])
   print("SELECTED_SOURCE_RECORDS",json.dumps({k:obj["so"][k] for k in [41,421,1079,1279,1285,1907,6675,7004] if k<len(obj["so"])},ensure_ascii=False)[:9000])

  for id in [1943,1951,250489,250492,273884,273951,1482,776,270027]:
   row=next((r for r in d if (isinstance(r,list) and str(r[0])==str(id)) or (isinstance(r,dict) and str(r.get("id",r.get("itemId"))) ==str(id))),None)
   if row is not None:print("MATCH",id,json.dumps(row,ensure_ascii=False)[:3000])
