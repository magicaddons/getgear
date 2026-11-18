-- Full catalogue/source audit. Map-ID candidates are not live-client validation.
local root=arg[1]or'.';local output=assert(arg[2],'output prefix required')
local a={};for f in io.lines(root..'/GetGear.toc')do
 if f:match('%.lua$')and f~='Core.lua'and f~='UI.lua'and f~='AltInventory.lua'then assert(loadfile(root..'/'..f))('GetGear',a)end
end
local model=a.AcquisitionNavigationData
local classes={'WARRIOR','PALADIN','HUNTER','ROGUE','PRIEST','SHAMAN','MAGE','WARLOCK','DRUID'}
local classID={WARRIOR=1,PALADIN=2,HUNTER=3,ROGUE=4,PRIEST=5,SHAMAN=7,MAGE=8,WARLOCK=9,DRUID=11}
local side,class='Alliance','WARRIOR'
UnitFactionGroup=function()return side end;UnitClass=function()return class,class,classID[class]end
UnitLevel=function()return 30 end;C_Map=nil;C_QuestLog=nil
local requests=0;C_Item={RequestLoadItemDataByID=function()requests=requests+1 end}
a.level=30;a.db={overlay={},hidden={},status={}}
local records,checks,seen={},0,{}
local function csv(v)return '"'..tostring(v or''):gsub('"','""')..'"'end
local function valid(v)return type(v)=='number'and v>=0 and v<=100 end
local function classify(t)
 if t.chainUnresolved then return 'quest_chain_unresolved' end
 if t.missingLocation then return 'source_location_missing' end
 if not t.zone then return t.kind=='dungeon'and'dungeon_exterior_missing'or'zone_missing' end
 if t.kind=='directions'or t.verification=='legacy-reference'then return 'written_reference_only' end
 local b=t.bounds
 local point=valid(t.x)and valid(t.y)and(t.x~=0 or t.y~=0)
 local area=b and valid(b.xMin)and valid(b.xMax)and valid(b.yMin)and valid(b.yMax)and b.xMin<=b.xMax and b.yMin<=b.yMax
 if not point and not area then return 'coordinates_missing' end
 if not model.maps[t.zone]and not t.uiMapID then return 'map_id_candidates_missing' end
 return t.approachOnly and 'exterior_approach_only'or point and 'point_data'or'area_data'
end
local totalTargets,usable,missingButtons,rawEvidenceChecks,rawMissingButtons=0,0,0,0,0
local counts={};local unique={};local bySlot,byKind={},{}
local function usableLocation(loc)
 if type(loc)~='table'or not loc.zone or loc.verification=='legacy-reference'or loc.coordinateScope=='continent-only'then return false end
 local b=loc.bounds
 return valid(loc.x)and valid(loc.y)and(loc.x~=0 or loc.y~=0)
  or b and valid(b.xMin)and valid(b.xMax)and valid(b.yMin)and valid(b.yMax)and b.xMin<=b.xMax and b.yMin<=b.yMax
end
local function entranceEvidence(name)
 local definition=a:GetAcquisitionInstanceDefinition(name)
 for _,loc in ipairs(definition and definition.entrances or{})do if usableLocation(loc)then return true end end
 return false
end
local function actorEvidence(key,q,route)
 if q and q.actorSides and q.actorSides[key]and q.actorSides[key]~=(side=='Alliance'and 1 or 2)then return false end
 local zone=q and q.actorZones and q.actorZones[key]or route.sourceZone
 for _,loc in ipairs((model.sources[key]or{}).locations or{})do
  if not zone or loc.zone==zone then
   if loc.dungeonApproach then if entranceEvidence(loc.dungeonApproach)then return true end
   elseif model.instances[loc.zone]then if entranceEvidence(loc.zone)then return true end
   elseif usableLocation(loc)then return true end
  end
 end
 return false
end
local function hasRawEvidence(g)
 if g.bagFromInventory then return false end
 -- Inspect accepted input routes/actor locations independently of choices.
 local routes=a:GetEligibleAcquisitionRoutes(g)
 for _,route in ipairs(routes)do
  if not route.directionsOnly and route.verification~='legacy-reference'then
   if route.kind=='dungeon'and entranceEvidence(route.dungeon)then return true
   elseif route.kind=='quest'or route.kind=='quest_container'then
    local chain=model.chains[tostring(route.questID)]or model.chains[route.questID]
    local steps=chain and chain.sideSteps and chain.sideSteps[side=='Alliance'and'1'or'2']or chain and chain.steps
    local id=steps and steps[1]or route.questID
    local q=model.quests[tostring(id)]or model.quests[id]or{}
    if not q.starterOriginUnresolved then for _,key in ipairs(q.starts or{})do if actorEvidence(key,q,route)then return true end end end
   elseif route.source and actorEvidence(route.source,nil,route)then return true
   elseif route.location and usableLocation(route.location)then return true end
  end
 end
 if not(g.acquisitionPlan or model.items[tostring(g.itemID)])and a:HasEligibleAcquisitionSource(g)then return usableLocation(g.acquisitionLocation)end
 return false
end
local function inspect(g)
 checks=checks+1
 local key=side..':'..g.itemID
 local r=records[key]
 if not r then r={gear=g,side=side,classes={},targets={},eligible=false};records[key]=r end
 r.classes[class]=true
 if a:HasEligibleAcquisitionSource(g)then r.eligible=true end
 local choices=a:GetAcquisitionNavigationChoices(g);local button=a:GetAcquisitionMapTarget(g)
 if hasRawEvidence(g)then rawEvidenceChecks=rawEvidenceChecks+1;if not button then rawMissingButtons=rawMissingButtons+1 end end
 local good=false
 for _,t in ipairs(choices)do
  local status=classify(t)
  if status=='point_data'or status=='area_data'or status=='exterior_approach_only'then good=true end
  local route=t.acquisitionRoute and t.acquisitionRoute.kind or t.kind or'unknown'
  local id=t.id..'|'..route
  if not r.targets[id]then r.targets[id]={target=t,status=status,route=route,class=class}end
 end
 if good and not button then missingButtons=missingButtons+1 end
end
for _,faction in ipairs({'Alliance','Horde'})do side=faction
 for _,c in ipairs(classes)do class=c;a.classToken=c
  for _,g in ipairs(a.EquipmentByClass[c])do inspect(g)end
  for _,g in ipairs(a.QuestBagCatalogue)do inspect(g)end
  -- Runtime crafted/vendor bag objectives carry their accepted routes too.
  C_Container={GetContainerNumSlots=function()return 4 end,GetContainerNumFreeSlots=function()return 0,0 end}
  for _,g in ipairs(a:GetBagPlanningObjectives())do inspect(g)end
 end
end
assert(requests==0,'row/source audit must not request item cache data')
assert(missingButtons==0,'usable location evidence lost its shared navigation button')
assert(rawMissingButtons==0,'accepted route/actor location evidence was lost before button resolution')
-- Exercise every distinct usable destination against the SAME adapter with
-- synthetic map metadata. These calls establish API wiring, never live IDs.
local infos={};for zone,ids in pairs(model.maps)do for _,id in ipairs(ids)do infos[id]={name=zone,mapID=id,parentMapID=0}end end
local function frame()
 local f={shown=true,w=3000,h=2000,scale=1,hooks={}}
 function f:IsShown()return self.shown end;function f:Show()self.shown=true end
 function f:Hide()self.shown=false end;function f:HookScript(k,fn)self.hooks[k]=fn end
 function f:SetScript(k,fn)self.hooks[k]=fn end
 function f:SetParent(p)self.parent=p end;function f:ClearAllPoints()end
 function f:SetPoint(...)self.point={...}end
 function f:GetWidth()return self.w end;function f:GetHeight()return self.h end
 function f:SetSize(w,h)self.w=w;self.h=h end;function f:SetWidth(w)self.w=w end
 function f:SetScale(v)self.scale=v end;function f:GetScale()return self.scale end
 function f:EnableMouse()end;function f:SetText()end
 function f:SetAllPoints()end;function f:SetTexture()end;function f:SetColorTexture()end
 f.CreateTexture=frame;f.CreateFontString=frame
 return f
end
local canvas=frame();canvas.scale=.2
WorldMapFrame=frame();WorldMapFrame.GetCanvas=function()return canvas end
WorldMapFrame.GetCanvasScale=function()return canvas.scale end
WorldMapFrame.GetMapID=function(self)return self.mapID end
CreateFrame=frame
C_Map={GetMapInfo=function(id)return infos[id]end,OpenWorldMap=function(id)WorldMapFrame.mapID=id;WorldMapFrame:Show()end,
 SetUserWaypoint=function()error('waypoint write')end,ClearUserWaypoint=function()error('waypoint clear')end}
local rendered,renderSeen=0,{}
for _,r in pairs(records)do for _,v in pairs(r.targets)do
 if v.status=='point_data'or v.status=='area_data'or v.status=='exterior_approach_only'then
  local key=v.target.id
  if not renderSeen[key]then
   side=r.side;class=v.class;a.classToken=class
   local ok,mode=a:OpenAcquisitionMap(r.gear,key)
   assert(ok and mode=='map','synthetic adapter failed for usable destination: '..tostring(r.gear.itemID)..' '..key..' '..tostring(mode))
   local t,pin=a:GetAcquisitionMarkerState();assert(pin and pin:IsShown()and t.uiMapID==WorldMapFrame.mapID)
   local x,y=t.x,t.y;if not x then x,y=t.bounds.xMin,t.bounds.yMin end
   assert(math.abs(pin.point[4]*pin.scale/canvas.w-x/100)<.000001)
   assert(math.abs(-pin.point[5]*pin.scale/canvas.h-y/100)<.000001)
   renderSeen[key]=true;rendered=rendered+1
  end
 end
end end
a:ClearAcquisitionMapMarker()
local rows=assert(io.open(output..'-targets.csv','w'))
local gaps=assert(io.open(output..'-gaps.csv','w'))
local mapGaps=assert(io.open(output..'-map-gaps.csv','w'))
local header='faction,itemID,name,slot,route,status,source,questID,zone,x,y,hasArea,mapIDCandidates,reason\n'
rows:write(header);gaps:write(header)
mapGaps:write(header)
local keys={};for k in pairs(records)do keys[#keys+1]=k end;table.sort(keys)
local items=0
for _,key in ipairs(keys)do
 local r=records[key];local g=r.gear;local p=g.acquisitionPlan or model.items[tostring(g.itemID)]or{}
 local ids={};for id in pairs(r.targets)do ids[#ids+1]=id end;table.sort(ids)
 if #ids==0 then
  local status=not r.eligible and'character_restricted'or #(p.routes or{})==0 and'no_fixed_route'or'no_actionable_destination'
  r.targets['']={status=status,route=p.category or'unknown',target={}};ids={''}
 end
 unique[g.itemID]=true
 for _,id in ipairs(ids)do
  local v=r.targets[id];local t=v.target;local status=v.status
  local mapped=status=='point_data'or status=='area_data'or status=='exterior_approach_only'
  counts[status]=(counts[status]or 0)+1;totalTargets=totalTargets+1;if mapped then usable=usable+1 end
  bySlot[g.slot or(g.slots and'Bag')or'Bag']=(bySlot[g.slot or(g.slots and'Bag')or'Bag']or 0)+1
  byKind[v.route]=(byKind[v.route]or 0)+1
  local reason=mapped and(t.approachOnly and'Exact actor coordinates unresolved; reviewed exterior approach retained'or'Client map-ID/name and actual rendering require in-game validation')
   or status=='character_restricted'and'No eligible route in this character context'
   or status=='no_fixed_route'and'No fixed mapped route is recorded; may be random loot or an unresolved source'
   or status=='no_actionable_destination'and'Known route has no resolved starter/source destination'
   or t.instructions or status
  local line=table.concat({csv(r.side),g.itemID,csv(g.name),csv(g.slot or'Bag'),csv(v.route),csv(status),csv(t.source),csv(t.questID),csv(t.zone),csv(t.x),csv(t.y),csv(t.bounds~=nil),csv(table.concat(model.maps[t.zone]or{},'|')),csv(reason)},',')..'\n'
  rows:write(line)
  if not mapped or t.approachOnly then gaps:write(line)end
  if t.zone and not model.maps[t.zone]and not t.uiMapID then mapGaps:write(line)end
 end
end
rows:close();gaps:close();mapGaps:close();for _ in pairs(unique)do items=items+1 end
local function object(t)local out={};for k,v in pairs(t)do out[#out+1]=string.format('%q:%d',k,v)end;table.sort(out);return'{'..table.concat(out,',')..'}'end
local out=assert(io.open(output..'-summary.json','w'))
out:write('{"catalogueItems":7707,"auditedItemIDs":'..items..',"classFactionChecks":'..checks..',"targetRows":'..totalTargets..',"usableLocationRows":'..usable..',"simulatedDistinctMarkerDestinations":'..rendered..',"usableLocationsWithoutButton":'..missingButtons..',"rawSourceEvidenceChecks":'..rawEvidenceChecks..',"sourceEvidenceWithoutButton":'..rawMissingButtons..',"itemCacheRequests":0,"actualClientTested":false,"mapIDsLiveValidated":false,"statuses":'..object(counts)..',"slots":'..object(bySlot)..',"routes":'..object(byKind)..'}\n');out:close()
print('PASS navigation pipeline audit: '..items..' equipment/bag IDs, '..checks..' class/faction records, '..totalTargets..' destinations/status rows; zero usable locations without buttons; live map IDs/rendering unverified')
