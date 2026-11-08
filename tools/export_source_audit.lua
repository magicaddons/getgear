-- Export every 1–60 catalogue record (and all class eligibility) for an
-- independent off-client source/recipe audit. Never touches SavedVariables.
-- Run with: lua5.4 tools/export_source_audit.lua . /tmp/getgear-audit.tsv
local root=(arg and arg[1]) or "."
local dest=(arg and arg[2]) or "/tmp/getgear-audit.tsv"
local addon={}
local skip={["Core.lua"]=true,["UI.lua"]=true,["AltInventory.lua"]=true}
local toc=assert(io.open(root.."/GetGear.toc","r"))
for path in toc:lines() do
  if path:match("%.lua$") and not skip[path] then
    local chunk,err=loadfile(root.."/"..path)
    assert(chunk,err)
    local ok,reason=pcall(chunk,"GetGear",addon)
    assert(ok,path..": "..tostring(reason))
  end
end
toc:close()
assert(addon.CatalogueAudit.items==7707, "Unexpected catalogue count")
local classNames={"PRIEST","MAGE","WARLOCK","DRUID","ROGUE","HUNTER","SHAMAN","WARRIOR","PALADIN"}
local byID={}
for _,class in ipairs(classNames) do
  for _,objective in ipairs(addon.EquipmentByClass[class] or {}) do
    local id=objective.itemID
    byID[id]=byID[id] or {}
    table.insert(byID[id],class..":"..tostring(objective.targetLevel))
  end
end
local keys={"id","name","level","slot","armor","role","classes","sourceType","source","zone",
  "acquisitionKind","acquisitionConfidence","itemSourceEvidence",
  "profession","recipeSpellID","recipeLearnMethod","recipePatternItemID",
  "recipeVendor","recipeAcquisitionKind","recipeDropSource","skillRequired",
  "recipeLearnSkillEvidence","bindingStatus","sourceSummary","sourceURL",
  "instructions","notes","reagents"}
local output=assert(io.open(dest,"w"))
output:write(table.concat(keys,"\t"),"\n")
local ids={}
for id in pairs(addon.ItemCatalog) do ids[#ids+1]=id end
table.sort(ids)
local function clean(value)
  if value==nil then return "" end
  return tostring(value):gsub("[\r\n\t]"," "):gsub(" +"," ")
end
for _,id in ipairs(ids) do
  local f=addon.ItemCatalog[id]
  local reagents={}
  for _,r in ipairs(f.reagents or {}) do
    if type(r.itemID)=="number" and type(r.amount)=="number" then
      reagents[#reagents+1]=tostring(r.itemID)..":"..tostring(r.amount)
    end
  end
  local obj={
    id=id,name=f.name,level=f.availableLevel,slot=f.slot,armor=f.armorType,
    role=f.statRole,classes=table.concat(byID[id] or {},","),
    sourceType=f.sourceType,source=f.source,zone=f.zone,
    acquisitionKind=f.acquisitionKind,acquisitionConfidence=f.acquisitionConfidence,
    itemSourceEvidence=f.itemSourceEvidence,
    profession=f.profession,recipeSpellID=f.recipeSpellID,
    recipeLearnMethod=f.recipeLearnMethod,recipePatternItemID=f.recipePatternItemID,
    recipeVendor=f.recipeVendor,recipeAcquisitionKind=f.recipeAcquisitionKind,
    recipeDropSource=f.recipeDropSource,skillRequired=f.professionSkillRequired,
    recipeLearnSkillEvidence=f.recipeLearnSkillEvidence,bindingStatus=f.bindingStatus,
    sourceSummary=f.sourceSummary,sourceURL=f.sourceURL,
    instructions=f.instructions,notes=f.notes,reagents=table.concat(reagents,";")
  }
  local values={}
  for _,key in ipairs(keys) do values[#values+1]=clean(obj[key]) end
  output:write(table.concat(values,"\t"),"\n")
end
output:close()
print("PASS 1–60 audit extraction: "..#ids.." catalogue items, nine class lists; "..dest)
