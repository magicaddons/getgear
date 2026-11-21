-- Real catalogue plus table-driven independent profession/source evidence.
local root=arg[1]or'.';local a={}
for f in io.lines(root..'/GetGear.toc')do if f:match('%.lua$')and f~='Core.lua'and f~='UI.lua'and f~='AltInventory.lua'then assert(loadfile(root..'/'..f))('GetGear',a)end end
local count,known,supplement=0,0,0;local professions={}
for id,g in pairs(a.ItemCatalog)do if g.profession then
 count=count+1;professions[g.profession]=true
 local n=a:GetNormalizedRecipeData(g)
 assert(n.profession==g.profession)
 if a:GetRecipeSkillRequirement(g)then known=known+1;assert(n.skillConfidence=='documented')end
 local extra=a.RecipeEvidence[id]
 if extra then
  supplement=supplement+1;assert(a:GetRecipeSkillRequirement(g)==extra.craftingSkill)
  assert(n.craftingSkill==extra.craftingSkill and n.learningSkill==extra.learningSkill)
  for _,r in ipairs(extra.acquisitions)do
   local found=false
   for _,route in ipairs(n.acquisitions)do if route==r then found=true end end
   assert(found,'lost alternate source')
  end
 end
end end
assert(count==1254 and known==1239 and supplement==104)
for _,p in ipairs({'Blacksmithing','Leatherworking','Tailoring','Enchanting','Engineering','Alchemy'})do assert(professions[p])end
local helm=assert(a.ItemCatalog[250498]);local n=a:GetNormalizedRecipeData(helm)
assert(helm.recipePatternItemID==251350 and n.craftingSkill==125 and n.learningSkill==125)
assert(#n.documentedDrops==29 and n.sourceConfidence=='documented')
local summary=a:GetAcquisitionSummary(helm);local guide=a:GetAcquisitionDirections(helm)
assert(summary:find('Dungeon drop (multiple sources)',1,true)and summary:find('125',1,true))
assert(not summary:find('skill unverified',1,true)and not summary:find('trash',1,true))
local dungeons={}
for _,drop in ipairs(n.documentedDrops)do
 assert(guide:find(drop.name,1,true))
 for _,name in ipairs(drop.dungeons)do dungeons[name]=true end
end
local nc=0;for _ in pairs(dungeons)do nc=nc+1 end;assert(nc==5)
assert(#a:GetAcquisitionNavigationChoices(helm)>=5,'documented dungeons need shared entrance navigation')
-- Execute the real detailed description, not only the navigation formatter.
local ui=assert(io.open(root..'/UI.lua')):read('*a')
local body=assert(ui:match('local function Describe%(gear, previewMode%)\n(.-)\nend'))
local describe=assert(load('return function(gear,previewMode)\n'..body..'\nend','real detailed recipe description','t',setmetatable({GetGear=a},{__index=_G})))()
local description=describe(helm,false)
assert(description:find('Dungeon drop (multiple sources)',1,true)and description:find('125',1,true))
assert(not description:find('learning source unverified',1,true),'detailed guide retained a superseded unknown label')
-- Both secondary profession display and opt-in craftability use the same fact.
a.db={overlay={hideUncraftableCrafts=true}}
GetProfessions=function()return 1 end;GetProfessionInfo=function()return 'Blacksmithing',nil,124 end
local skill=124;a.GetProfessionSkill=function()return skill end
a.GetRecipeKnowledge=function()return true end
assert(not a:ShouldDisplayCraftedGear(helm),'known recipe still requires the documented craft minimum')
assert(a:GetProfessionDisplay(helm)=='Blacksmithing  124/125')
skill=125;assert(a:ShouldDisplayCraftedGear(helm))
-- Independent properties across every supported profession and source class.
local original=a.AcquisitionNavigationData
local model={items={},sources={},quests={},chains={},recipeRequirements={}}
a.AcquisitionNavigationData=model;a.RecipeEvidence={}
local classes={
 {'trainer','trainer'}, {'recipe_vendor','vendor'}, {'quest','quest'},
 {'dungeon','dungeon_boss','boss'}, {'dungeon','dungeon_trash','trash'},
 {'dungeon','dungeon_drop'}, {'world_drop','world_drop'}, {'reputation','reputation'}, {'legacy','unknown'},
}
local checks=0
for _,profession in ipairs({'Blacksmithing','Leatherworking','Tailoring','Enchanting','Engineering','Alchemy','Cooking','First Aid'})do
 for _,case in ipairs(classes)do
  local id=900000+checks;checks=checks+1
  local g={itemID=id,profession=profession,recipeLearnSkillEvidence='unverified',recipeLearnMethod='multiple'}
  model.recipeRequirements[tostring(id)]={recipeMinimumSkill=125,bookLearningSkill=100}
  local route={kind=case[1],sourceRole=case[3],verification='published-reference'}
  model.items[tostring(id)]={routes={route,route}}
  local norm=a:GetNormalizedRecipeData(g)
  assert(norm.craftingSkill==125 and norm.learningSkill==100 and norm.sources[1].kind==case[2])
  assert(norm.sourceConfidence=='documented'and a:GetRecipeSkillRequirement(g)==125)
  skill=124;assert(not a:ShouldDisplayCraftedGear(g));skill=125;assert(a:ShouldDisplayCraftedGear(g))
  if case[1]=='world_drop'then assert(a:GetAcquisitionSummary(g):find('World drop',1,true))end
  route.verification='unverified'
  norm=a:GetNormalizedRecipeData(g)
  assert(norm.sourceConfidence=='unverified'and norm.craftingSkill==125,'unknown source erased known requirement')
  model.recipeRequirements[tostring(id)]={skillUpThresholds={125,150,175,200}}
  route.verification='published-reference';norm=a:GetNormalizedRecipeData(g)
  assert(norm.sourceConfidence=='documented'and norm.skillConfidence=='unverified'and not a:GetRecipeSkillRequirement(g),'source/color fabricated skill')
 end
end
print('PASS recipe integrity: all1254 crafts/six catalogue professions;104 reconciled minima/1239 known/15 unresolved;29 Helm enemies/five dungeons; '..checks..' independent source/profession matrices; no boss/trash or difficulty inference')
