-- Exhaustive offline faction audit. No source refresh, status write or client IO.
local root=arg[1]or'.';local output=assert(arg[2],'CSV output required');local a={}
for file in assert(io.open(root..'/GetGear.toc')):read('*a'):gmatch('[^\r\n]+')do
 if file:match('%.lua$')and file~='Core.lua'and file~='UI.lua'and file~='AltInventory.lua'then assert(loadfile(root..'/'..file))('GetGear',a)end
end
local classes={'PRIEST','MAGE','WARLOCK','DRUID','ROGUE','HUNTER','SHAMAN','WARRIOR','PALADIN'}
local function csv(x)return '"'..tostring(x or''):gsub('"','""')..'"'end
local function row(f,values)local r={};for _,v in ipairs(values)do r[#r+1]=csv(v)end;f:write(table.concat(r,','),'\n')end
local out=assert(io.open(output,'w'))
row(out,{'itemID','name','category','itemUseSide','itemAcquisitionSide','binding','knownRoutes','AllianceEligibleRoutes','HordeEligibleRoutes','AllianceEligibleClasses','HordeEligibleClasses','AllianceIndependentAccess','HordeIndependentAccess','auditStatus'})
local ids={};for id in pairs(a.ItemCatalog)do ids[#ids+1]=id end;table.sort(ids)
local counts={restricted=0,characterOrSource=0,unknown=0,sharedOrAlternative=0,tradeable=0}
for _,id in ipairs(ids)do
 local g=a.ItemCatalog[id];local p=a.AcquisitionNavigationData.items[tostring(id)]or{};local fact=a.FactionEligibilityData.items[id]or{}
 local lists,routes,independent={},{},{}
 for _,side in ipairs({'Alliance','Horde'})do
  local allowed={};local bestRoutes=0
  for _,class in ipairs(classes)do
   if not(class=='PALADIN'and side=='Horde'or class=='SHAMAN'and side=='Alliance')then
    local context={faction=side,classToken=class}
    local paths=a:GetEligibleAcquisitionRoutes(g,context);bestRoutes=math.max(bestRoutes,#paths)
    if a:CanClassEquipGear(g,class)and a:HasEligibleAcquisitionSource(g,context)then allowed[#allowed+1]=class end
   end
  end
  lists[#lists+1]=table.concat(allowed,' ');routes[#routes+1]=bestRoutes
  independent[#independent+1]=a:GetIndependentAcquisitionAccess(g,{faction=side})or''
 end
 local status
 if fact.side or fact.acquisitionSide or fact.races then status='published-item-requirement';counts.restricted=counts.restricted+1
 elseif lists[1]==''or lists[2]==''then status='character-or-source-restricted';counts.characterOrSource=counts.characterOrSource+1
 elseif not p.routes or #p.routes==0 then status='no-structured-route-uncertain';counts.unknown=counts.unknown+1
 else status='eligible-shared-alternative-or-unresolved';counts.sharedOrAlternative=counts.sharedOrAlternative+1 end
 if fact.binding=='boe'then counts.tradeable=counts.tradeable+1 end
 row(out,{id,g.name,p.category or g.sourceType,fact.side or'',fact.acquisitionSide or'',a:GetGearBindingStatus(g)or'unknown',#(p.routes or{}),routes[1],routes[2],lists[1],lists[2],independent[1],independent[2],status})
end
out:close()
assert(#ids==a:GetCatalogSize())
print('PASS exhaustive faction audit: '..#ids..' items/16 faction-valid class combinations; itemRequirements='..counts.restricted..';characterOrSource='..counts.characterOrSource..';noStructuredRoute='..counts.unknown..';other='..counts.sharedOrAlternative..';verifiedBoE='..counts.tradeable)
