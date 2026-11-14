-- Catalogue-only presentation audit. Synthetic character APIs; no live rendering.
local root=assert(arg[1]);local output=assert(arg[2]);local overrides=arg[3];local a={}
local function path(f)
 if overrides then local h=io.open(overrides..'/'..f);if h then h:close();return overrides..'/'..f end end
 return root..'/'..f
end
for f in assert(io.open(root..'/GetGear.toc')):read('*a'):gmatch('[^\r\n]+')do
 if f:match('%.lua$')and f~='Core.lua'and f~='UI.lua'and f~='AltInventory.lua'then assert(loadfile(path(f)))('GetGear',a)end
end
local function json(v)
 local t=type(v)
 if t=='nil'then return'null'elseif t=='boolean'or t=='number'then return tostring(v)elseif t=='string'then return'"'..v:gsub('[%z\1-\31\\"]',function(c)local e={['"']='\\"',['\\']='\\\\',['\n']='\\n',['\r']='\\r',['\t']='\\t'};return e[c]or string.format('\\u%04x',c:byte())end)..'"'end
 local keys,out={},{};for k in pairs(v)do keys[#keys+1]=k end;table.sort(keys,function(x,y)return tostring(x)<tostring(y)end)
 for _,k in ipairs(keys)do out[#out+1]=json(tostring(k))..':'..json(v[k])end
 return'{'..table.concat(out,',')..'}'
end
local side,class,mode,goals='Alliance','PRIEST','unknown',{}
local gameID={PRIEST=5,MAGE=8,WARLOCK=9,DRUID=11,ROGUE=4,HUNTER=3,SHAMAN=7,WARRIOR=1,PALADIN=2}
UnitClass=function()return class,class,gameID[class]end;UnitFactionGroup=function()return side end;UnitLevel=function()return 60 end
C_Map=nil;local requests=0;C_Item={RequestLoadItemDataByID=function()requests=requests+1 end};C_CurrencyInfo=nil
local ui=assert(io.open(path('UI.lua'))):read('*a');local body=assert(ui:match('(local function DescribeOverlay.-)\nend'))..'\nend\nreturn DescribeOverlay'
local expanded=assert(load(body,'compact expanded','t',setmetatable({GetGear=a},{__index=_G})))()
local before=json({catalog=a.ItemCatalog,model=a.AcquisitionNavigationData})
local ids={};for id in pairs(a.ItemCatalog)do ids[#ids+1]=id end;table.sort(ids)
local f=assert(io.open(output,'w'));local checks,recipes,targets=0,0,0
for _,id in ipairs(ids)do
 local g=a.ItemCatalog[id];if g.profession then recipes=recipes+1 end
 local plan=a.AcquisitionNavigationData.items[tostring(id)]or{};goals={};for _,r in ipairs(plan.routes or{})do if r.questID then goals[r.questID]=true end end
 local record={itemID=id,name=g.name,profession=g.profession,sourceSummary=g.sourceSummary,source=g.source,sourceType=g.sourceType,
  method=g.recipeLearnMethod,pattern=g.recipePatternItemID,availability=g.recipeLearningAvailability,confidence=g.confidence,acquisitionConfidence=g.acquisitionConfidence,
  requirements=a.AcquisitionNavigationData.recipeRequirements[tostring(id)],routes=plan.routes,sourceNames={},summary={},expanded={},targets={}}
 for _,route in ipairs(plan.routes or {})do if route.source then record.sourceNames[route.source]=(a.AcquisitionNavigationData.sources[route.source]or{}).name end end
 for _,s in ipairs({'Alliance','Horde','Unknown'})do side=s
  for _,c in ipairs({'PRIEST','MAGE','WARLOCK','DRUID','ROGUE','HUNTER','SHAMAN','WARRIOR','PALADIN','Unknown'})do class=c
   for _,state in ipairs(next(goals)and{'unknown','active','ready','completed'}or{'unknown'})do
    mode=state;C_QuestLog=state~='unknown'and{IsOnQuest=function(q)return goals[q]and(mode=='active'or mode=='ready')or false end,IsComplete=function()return mode=='ready'end,IsQuestFlaggedCompleted=function(q)return goals[q]and mode=='completed'or false end}or nil
    local context=s..'/'..c..'/'..state;checks=checks+1
    local summary=a:GetAcquisitionSummary(g)or'';record.summary[summary]=record.summary[summary]or context
    local choices=a:GetAcquisitionNavigationChoices(g);local has=false
    for _,t in ipairs(choices)do
     targets=targets+1;local label=a:GetAcquisitionMarkerLabel(t);local key=json({label=label,kind=t.kind,source=t.source,questID=t.questID,role=t.role,zone=t.zone,entrance=t.entranceID})
     local entry=record.targets[key]or{label=label,kind=t.kind,source=t.source,questID=t.questID,role=t.role,zone=t.zone,x=t.x,y=t.y,bounds=t.bounds,verification=t.verification,requirements=t.requirements,missing=t.missingLocation,dungeon=t.dungeon,publishedEntrance=t.publishedEntrance}
     record.targets[key]=entry;if not t.missingLocation then has=true end
    end
    local detail=expanded(g,has)or''
    local text=summary
    if detail~=''then if summary~=''and not detail:find(summary,1,true)then text=summary..'\n'..detail else text=detail end end
    record.expanded[text]=record.expanded[text]or context
   end
  end
 end
 f:write(json(record),'\n')
end
assert(json({catalog=a.ItemCatalog,model=a.AcquisitionNavigationData})==before,'audit mutated acquisition data')
assert(requests==0)
f:close();local meta=assert(io.open(output..'.metadata.json','w'));meta:write(json({items=#ids,recipes=recipes,contexts=checks,labelChecks=targets,itemQueries=requests,inputModelUnchanged=true,currencies=a.AcquisitionNavigationData.currencies}));meta:close();print('PASS read-only export:items='..#ids..' recipes='..recipes..' contexts='..checks..' labelChecks='..targets..' zeroItemQueries/fullmodelunchanged')
