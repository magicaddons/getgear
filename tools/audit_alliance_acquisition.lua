-- Audit current Alliance access without modifying source data or SavedVariables.
local root=arg[1] or '.'
local output=assert(arg[2],'CSV output required')
local a={}
for line in io.lines(root..'/GetGear.toc')do
 if line:match('%.lua$')and line~='Core.lua'and line~='UI.lua'and line~='AltInventory.lua'then assert(loadfile(root..'/'..line))('GetGear',a)end
end
local classes={'PRIEST','MAGE','WARLOCK','DRUID','ROGUE','HUNTER','SHAMAN','WARRIOR','PALADIN'}
local context={faction='Alliance'}
local m=a.AcquisitionNavigationData
local file=assert(io.open(output,'w'))
local function row(values)
 local out={};for _,v in ipairs(values)do out[#out+1]='"'..tostring(v):gsub('"','""')..'"'end
 file:write(table.concat(out,','),'\n')
end
row({'itemID','name','recordedRoutes','capitalOrReputationRoutesBlocked','otherRoutes','AllianceEligibleClasses','independentAccess','noStructuredRoute','reasons'})
local ids={};for id in pairs(a.ItemCatalog)do ids[#ids+1]=id end;table.sort(ids)
local counts={affected=0,blocked=0,retained=0,rfc=0,unknown=0,routeBlocks=0}
for _,id in ipairs(ids)do
 local gear=a.ItemCatalog[id]
 local plan=m.items[id]or m.items[tostring(id)]or{}
 local routes=plan.routes or{}
 local blocked,reasons,rfc=0,{},false
 for _,r in ipairs(routes)do
  local allowed,reason=a:IsAcquisitionRouteAccessible(gear,r,context)
  if not allowed then blocked=blocked+1;reasons[reason]=true end
  if r.dungeon=='Ragefire Chasm'then rfc=true end
 end
 local eligible={}
 for _,class in ipairs(classes)do
  context.classToken=class
  if a:CanClassEquipGear(gear,class)and a:HasEligibleAcquisitionSource(gear,context)then eligible[#eligible+1]=class end
 end
 local labels={};for reason in pairs(reasons)do labels[#labels+1]=reason end;table.sort(labels)
 row({id,gear.name,#routes,blocked,#routes-blocked,table.concat(eligible,' '),a:GetIndependentAcquisitionAccess(gear,context)or'',#routes==0,table.concat(labels,'; ')})
 if blocked>0 then
  counts.affected=counts.affected+1;counts.routeBlocks=counts.routeBlocks+blocked
  if #eligible>0 then counts.retained=counts.retained+1 else counts.blocked=counts.blocked+1 end
 end
 if rfc then counts.rfc=counts.rfc+1 end
 if #routes==0 then counts.unknown=counts.unknown+1 end
end
file:close()
print('PASS Alliance audit: items='..#ids..'; affected='..counts.affected..'; blockedRoutes='..counts.routeBlocks..'; itemsWithoutEligibleClass='..counts.blocked..'; retainedWithAlternative='..counts.retained..'; RFC='..counts.rfc..'; noStructuredRoute='..counts.unknown)
