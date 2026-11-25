-- Read the accepted runtime, including its additive evidence projections.
local root=arg[1]or'.';local a={}
for f in io.lines(root..'/GetGear.toc')do
 if f:match('%.lua$')and f~='Core.lua'and f~='UI.lua'and f~='AltInventory.lua'then
  if f=='AcquisitionPolicy.lua' and arg[2]=='baseline' then
   -- The historical geometry classifier must reproduce its frozen input,
   -- before current source holds and commerce points are projected separately.
  elseif f=='AcquisitionNavigation.lua' and arg[2]=='baseline' then
   local handle=assert(io.open(root..'/'..f));local body=handle:read('*a');handle:close()
   body=body:gsub('%-%- BEGIN GENERATED NAVIGATION REVIEW\n.-%-%- END GENERATED NAVIGATION REVIEW\n','')
   assert((loadstring or load)(body,'@'..f))('GetGear',a)
  else assert(loadfile(root..'/'..f))('GetGear',a)end
 end
end
local function json(v)
 local t=type(v)
 if t=='nil'then return'null'end
 if t=='boolean'or t=='number'then return tostring(v)end
 if t=='string'then return'"'..v:gsub('[%z\1-\31\\"]',function(c)return string.format('\\u%04x',c:byte())end)..'"'end
 local keys,out={},{};for k in pairs(v)do keys[#keys+1]=k end
 table.sort(keys,function(x,y)return tostring(x)<tostring(y)end)
 if #v>0 then for _,x in ipairs(v)do out[#out+1]=json(x)end
 else for _,k in ipairs(keys)do out[#out+1]=json(tostring(k))..':'..json(v[k])end end
 return(#v>0 and'['or'{')..table.concat(out,',')..(#v>0 and']'or'}')
end
local m=a.AcquisitionNavigationData;local sources,labels,providers={}, {},{}
local routeCount,questCount,sourceCount,itemCount=0,0,0,0
local function proof(p,kind)
 local url=type(p)=='table'and p.url or p
 if type(url)~='string'then return end
 local host=url:match('^https?://([^/]+)')or'unspecified'
 local file=type(p)=='table'and(p.file or'unspecified')or'bag-quest-evidence.json'
 local key=host..'|'..file;local row=providers[key]or{host=host,file=file,kinds={},references=0}
 row.kinds[kind or'unknown']=true;row.references=row.references+1;providers[key]=row
end
for key,s in pairs(m.sources)do
 sourceCount=sourceCount+1
 sources[key]={name=s.name,kind=s.kind,sourceID=s.sourceID,locations=s.locations,evidence=s.evidence,categories={}}
 for _,p in ipairs(s.evidence or{})do proof(p,s.kind)end
end
for id,q in pairs(m.quests)do questCount=questCount+1
 local e=q.evidence or{};if e.url then proof(e,'quest')else for _,p in ipairs(e)do proof(p,'quest')end end
end
for id,p in pairs(m.items)do itemCount=itemCount+1
 for i,r in ipairs(p.routes or{})do routeCount=routeCount+1
  if r.source and sources[r.source] then sources[r.source].categories[r.kind or 'unknown']=true end
  if r.location then labels[#labels+1]={itemID=id,route=i,label=r.label or r.location.spot,zone=r.location.zone}end
 end
end
for _,q in pairs(m.quests) do
 for _,role in ipairs({'starts','ends','objectives'}) do
  for _,key in ipairs(q[role] or {}) do if sources[key] then sources[key].categories['quest-'..role]=true end end
 end
end
for id,g in pairs(a.ItemCatalog)do
 local l=g.acquisitionLocation
 if l then labels[#labels+1]={itemID=id,label=l.spot,zone=l.zone}end
end
io.write(json({sources=sources,labels=labels,providers=providers,maps=m.maps,
 counts={sourceRecords=sourceCount,questRecords=questCount,routes=routeCount,items=itemCount}}),'\n')
