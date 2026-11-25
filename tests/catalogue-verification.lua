local root=arg[1]or'.'
UnitFactionGroup=function()return 'Alliance' end
local a={}
for file in io.lines(root..'/GetGear.toc')do
 if file:match('%.lua$')and file~='Core.lua'and file~='UI.lua'and file~='AltInventory.lua'then assert(loadfile(root..'/'..file))('GetGear',a)end
end
local count=0
for identifier,record in pairs(a.CatalogueRecipeCorrections)do
 local gear=assert(a.ItemCatalog[tonumber(identifier)])
 assert(gear.recipeSpellID==record.recipeSpellID)
 assert(gear.name==record.original.name and gear.profession==record.original.profession)
 local expected={};for _,r in ipairs(record.original.reagents)do expected[r.itemID]=r.amount end
 for _,r in ipairs(gear.reagents)do assert(expected[r.itemID]==r.amount);expected[r.itemID]=nil end
 assert(next(expected)==nil,'recipe repair changed materials');count=count+1
end
assert(count==8)
local preferred=0
for book,offer in pairs(a.CommercePolicyData.offers)do
 if offer.preferredLearningSkill then
  assert(offer.learningSkillDisputed and offer.preferredLearningSkill==offer.bookLearningSkill)
  assert(offer.preferredLearningSkill~=offer.learningSkill and offer.skillEvidence.sha256)
  local requirements=table.concat(a:GetCommerceLearningRequirements({recipePatternItemID=tonumber(book)}),' ')
  assert(requirements:find('Learn '..offer.preferredLearningSkill,1,true))
  assert(requirements:find('guide '..offer.learningSkill,1,true))
  preferred=preferred+1
 end
end
assert(preferred==54)
-- Current source conflicts and publication preferences never create a precise
-- pin or a cross-faction exception. Existing shared policy remains authoritative.
for _,source in pairs(a.CommercePolicyData.sources)do
 if source.coordinateDisputed then for _,loc in ipairs(source.locations)do assert(not loc.x and not loc.y)end end
end
print('PASS catalogue verification: 8 exact spell joins/material preservation; 54 qualified book/spell preferences; geometry holds preserved')
