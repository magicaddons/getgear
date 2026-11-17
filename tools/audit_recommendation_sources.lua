-- Read-only source coverage for every equipment ID, nine classes, both sides.
local root=arg[1] or '.';local output=assert(arg[2],'CSV output path required');local a={}
for f in assert(io.open(root..'/GetGear.toc')):read('*a'):gmatch('[^\r\n]+')do
    if f:match('%.lua$') and f~='Core.lua'and f~='UI.lua'and f~='AltInventory.lua'then assert(loadfile(root..'/'..f))('GetGear',a)end
end
local function csv(value)return '"'..tostring(value or ''):gsub('"','""')..'"'end
local function row(file,values)local out={};for _,v in ipairs(values)do out[#out+1]=csv(v)end;file:write(table.concat(out,','),'\n')end
local file=assert(io.open(output,'w'));row(file,{'itemID','name','routes','AllianceOnlyRoutes','HordeOnlyRoutes','ExplicitSharedQuestRoutes','FactionUnresolvedRoutes','AllianceEligibleClasses','HordeEligibleClasses','scope'})
local ids={};for id in pairs(a.ItemCatalog)do ids[#ids+1]=id end;table.sort(ids)
local counts={known=0,unknown=0,allianceRestricted=0,hordeRestricted=0,multiple=0}
for _,id in ipairs(ids)do
    local gear=a.ItemCatalog[id];local plan=a.AcquisitionNavigationData.items[tostring(id)] or {};local routes=plan.routes or {}
    local all,horde,shared,unknown=0,0,0,0
    for _,r in ipairs(routes)do
        local side=a:GetAcquisitionRouteFactionSide(gear,r)
        if side==1 then all=all+1 elseif side==2 then horde=horde+1 elseif side==3 then shared=shared+1 else unknown=unknown+1 end
    end
    local sides={}
    for _,side in ipairs({'Alliance','Horde'})do
        local allowed={}
        for _,class in ipairs({'PRIEST','MAGE','WARLOCK','DRUID','ROGUE','HUNTER','SHAMAN','WARRIOR','PALADIN'})do
            if a:CanClassEquipGear(gear,class) and a:HasEligibleAcquisitionSource(gear,{faction=side,classToken=class})then allowed[#allowed+1]=class end
        end
        sides[#sides+1]=table.concat(allowed,' ')
    end
    local scope=#routes==0 and 'No structured route: access unresolved; legacy descriptions retained' or unknown>0 and 'Contains faction-unresolved routes; no zone-based inference' or 'Explicit published source-side metadata; live access unverified'
    if (a.FactionEligibilityData.items[id]or{}).side or (a.FactionEligibilityData.items[id]or{}).acquisitionSide then scope='Published faction requirement/attribution; route alternatives and binding evaluated separately' end
    row(file,{id,gear.name,#routes,all,horde,shared,unknown,sides[1],sides[2],scope})
    counts[#routes==0 and 'unknown'or'known']=counts[#routes==0 and 'unknown'or'known']+1
    if all>0 then counts.allianceRestricted=counts.allianceRestricted+1 end
    if horde>0 then counts.hordeRestricted=counts.hordeRestricted+1 end
    if #routes>1 then counts.multiple=counts.multiple+1 end
end
file:close()
assert(#ids==7707)
print('PASS all7707 source records/nine classes/both factions;structured='..counts.known..';noStructuredRoute='..counts.unknown..';AllianceRestricted='..counts.allianceRestricted..';HordeRestricted='..counts.hordeRestricted..';multiple='..counts.multiple)
