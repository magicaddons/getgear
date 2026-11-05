-- GetGear early-crafting regression: run from repository root with Lua 5.4.
local root=(arg and arg[1]) or "."
local addon={}; local files=0; local skip={["Core.lua"]=true,["UI.lua"]=true,["AltInventory.lua"]=true}
local toc=assert(io.open(root.."/GetGear.toc")):read("*a")
assert(toc:find("EarlyCraftedProgression132.lua",1,true),"early crafting module missing from TOC")
for line in toc:gmatch("[^\r\n]+") do
  if line:match("%.lua$") then
    local chunk,err=loadfile(root.."/"..line)
    assert(chunk,line..": "..tostring(err))
    files=files+1
    if not skip[line] then
      local ok,res=pcall(chunk,"GetGear",addon)
      assert(ok,line..": "..tostring(res))
    end
  end
end
assert(files>=33,"expected v0.12.11 modules plus early craft module")
local audit=assert(addon.EarlyCraftedProgression132,"missing early craft audit")
assert(audit.itemsAdded==8 and audit.recommendationsAdded==21,
  "unexpected early craft counts: "..audit.itemsAdded.." / "..audit.recommendationsAdded)
local catalog=0;for _ in pairs(addon.ItemCatalog) do catalog=catalog+1 end
assert(catalog==233,"catalogue count "..catalog)
local recTotal=0
for class,recs in pairs(addon.Recommendations) do
  local ids={}
  for _,r in ipairs(recs) do
    assert(addon.ItemCatalog[r.itemID],class.." missing item "..r.itemID)
    assert(not ids[r.id],class.." duplicate progress ID "..tostring(r.id))
    ids[r.id]=true;recTotal=recTotal+1
  end
end
assert(recTotal==425,"recommendations "..recTotal)
local coarseCount=0
for _,id in ipairs({2572,6239,6240,4308,4239,2309,2312}) do
 for _,mat in ipairs(addon.ItemCatalog[id].reagents or {}) do
  assert(not (mat.name=="Coarse Thread" and mat.itemID~=2320),
    "Coarse Thread ID mismatch on "..id)
  if mat.name=="Coarse Thread" then coarseCount=coarseCount+1 end
 end
end
assert(coarseCount==7,"expected seven Coarse Thread recipes, got "..coarseCount)
local needed={
 PRIEST={2572,6239,6240,4308},MAGE={2572,6239,4308},WARLOCK={2572,6239,4308},
 HUNTER={5957,2303,2300,4239},ROGUE={5957,2303,2300,4239},
 DRUID={5957,2303,2300,4239,2309,2312},
 SHAMAN={5957,2303,2300,4239,2309,2312},
 WARRIOR={2852,3469,3471,2851},PALADIN={2852,3469,3471,2851},
}
for class,items in pairs(needed) do
 local present={}
 for _,r in ipairs(addon.Recommendations[class]) do present[r.itemID]=true end
 for _,id in ipairs(items) do assert(present[id],class.." lacks "..id) end
end
for _,class in ipairs({"ROGUE","HUNTER"}) do
 for _,r in ipairs(addon.Recommendations[class]) do
  assert(r.itemID~=2309 and r.itemID~=2312 and r.itemID~=273034,
    "caster gear recommended for "..class.." "..r.itemID)
 end
end
for _,id in ipairs({2572,6239,6240,2312}) do
 local i=addon.ItemCatalog[id]
 assert(i.recipeLearnMethod=="pattern" and i.professionSkillRequired,"missing pattern evidence "..id)
end
for _,id in ipairs({4308,4239,2309,2851}) do
 local i=addon.ItemCatalog[id]
 assert(i.recipeLearnMethod=="trainer" and not i.professionSkillRequired and
        i.recipeLearnSkillEvidence=="unverified","invented trainer minimum "..id)
end
addon.db={specialization="All",status={},hidden={},overlay={filterObsolete=false}}
addon.IsGearEquipped=function()return false end
addon.GetObsoleteGearReason=function()return nil end
UnitClass=function()return "Priest","PRIEST" end
UnitFactionGroup=function()return "Alliance" end
UnitRace=function()return "Gnome","Gnome" end
addon.level=6; assert(addon:SelectCurrentGuide()>0)
local seen={}
for _,i in ipairs(addon:GetItems("tracker")) do seen[i.itemID]=true end
for _,id in ipairs({2572,6239,6240,4308}) do
 assert(seen[id],"level-6 Priest misses "..id)
end
local previews=0
for class,specs in pairs(addon.Specializations) do
 for _,spec in ipairs(specs) do
  assert(#addon:GetPreviewRecommendations(class,spec)>0,class.."/"..spec.." empty")
  previews=previews+1
 end
end
assert(previews==37,"spec views: "..previews)
assert(not toc:find("SLASH_GETGEAR2",1,true),"unexpected alias")
print("PASS early crafting: "..files.." Lua files, "..catalog.." items, "..recTotal.." recommendations, "..previews.." previews, Priest level 6")
