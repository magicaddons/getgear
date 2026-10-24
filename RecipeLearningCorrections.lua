local addonName, GetGear = ...
-- Staged recipe-learning evidence corrections (23 October 2026).
-- Strictly separate recipe learning method from route verification.
-- Trainer/vendor lists in client-derived databases do not prove live NPC stock.
-- Does not alter acquisitionConfidence, notifications, saved IDs or crafting inputs.
local facts = {
  [7348] = {
    method="trainer", clearSkill=true, spellID=9145, skillEvidence="conflicting: AHledger 85 vs Wowhead Forever 125; live test required",
    source="Leatherworking trainer",
    instructions="Taught by Leatherworking trainers. Published Forever sources disagree on the minimum learning skill (85 versus 125); check the trainer UI. Finished gloves bind when equipped and may be traded.",
    url="https://foreverdiff.com/recipes/fletcher-s-gloves-5026/",
  },
  [7166] = {
    method="trainer", skill=30, provisional=true, skillEvidence="existing addon value; live trainer test pending",
    source="Blacksmithing trainer",
    instructions="Learn from a Blacksmithing trainer (skill 30 in the existing guide; live trainer check still needed). Finished dagger is tradeable.",
    url="https://foreverdiff.com/recipes/copper-dagger-4910/",
  },
  [3719] = {
    method="trainer", clearSkill=true, skillEvidence="unknown; 145 is yellow skill-up point, not learn skill",
    source="Leatherworking trainer",
    instructions="Taught by a Leatherworking trainer. The minimum learning skill remains unverified; do not mistake its 145 yellow skill-up threshold for that requirement. BoE: can be commissioned or purchased.",
    url="https://theforeverera.com/en/recipes/leatherworking/hillmans-cloak/",
  },
  [18948] = {
    method="pattern", skill=130, skillEvidence="Forever client pattern requirement",
    source="Pattern: Barbaric Bracers (Leatherworking 130)",
    instructions="Learn using Pattern: Barbaric Bracers, which requires Leatherworking 130. The specific pattern vendor/drop is not confirmed on a live Forever server. Finished bracers are BoE.",
    url="https://foreverdiff.com/recipes/barbaric-bracers-12559/",
  },
  [4311] = {
    method="pattern", skill=80, skillEvidence="Forever pattern item requirement",
    source="Pattern: Heavy Woolen Cloak (Tailoring 80)",
    instructions="Use Pattern: Heavy Woolen Cloak at Tailoring 80. Pattern is a drop; no reliable Forever-specific farming location has been verified. Check player trading or the Auction House. This is not a trainer recipe.",
    url="https://www.wowhead.com/forever/item=4346/pattern-heavy-woolen-cloak",
  },
  [252455] = {
    method="trainer", clearSkill=true, spellID=1255091,
    skillEvidence="conflicting: AHledger 90 vs other listed client thresholds 130; live test required",
    source="Leatherworking trainer",
    instructions="Leatherworking trainer recipe; skill requirement unresolved across beta listings (90 or 130). Finished Defender's Leather Helm binds on pickup and must be made by this character.",
    url="https://www.wowhead.com/forever/spell=1255091/defenders-leather-helm",
  },
  [7374] = {
    method="trainer", clearSkill=true, skillEvidence="unverified",
    source="Leatherworking trainer",
    instructions="Learn from a Leatherworking trainer. Minimum learning skill has not been independently verified in Forever; check trainer UI before collecting materials.",
    url="https://theforeverera.com/en/recipes/leatherworking/dusky-leather-armor/",
  },
  [7047] = {
    method="pattern", skill=120, skillEvidence="Forever client pattern requirement",
    source="Pattern: Hands of Darkness (Tailoring 120)",
    instructions="Learn using Pattern: Hands of Darkness, requiring Tailoring 120. The pattern's live-server seller or drop is not yet verified. Finished gloves are tradeable.",
    url="https://theforeverera.com/en/recipes/tailoring/hands-of-darkness/",
  },
}
GetGear.RecipeLearningCorrections = {updated={}, version="staged-2026-10-23"}
for id, fix in pairs(facts) do
  local item = assert(GetGear.ItemCatalog[id], "Missing recipe-learning candidate "..id)
  item.recipeLearnMethod=fix.method
  item.recipeLearnSkillProvisional=fix.provisional or false
  item.recipeLearnSkillEvidence=fix.skillEvidence
  item.recipeLearningSourceURL=fix.url
  item.source=fix.source
  item.instructions=fix.instructions
  if fix.clearSkill then item.professionSkillRequired=nil end
  if fix.spellID then item.recipeSpellID=fix.spellID end
  if fix.skill then item.professionSkillRequired=fix.skill end
  -- Distinguish client evidence from live vendor/drop evidence.
  if id==4311 or id==7374 then
    item.acquisitionKind=(id==4311 and "Pattern item (drop location unverified)" or "Profession trainer")
    item.acquisitionConfidence="client"
  end
  -- No acquisition route is asserted by these learning-method corrections.
  GetGear.RecipeLearningCorrections.updated[#GetGear.RecipeLearningCorrections.updated+1]=id
end

-- Older acquisition routing reused a verified dungeon/quest *map location*
-- as if the item drop or quest reward had been confirmed on Forever.
-- Keep the navigation coordinates, but restore the source's actual evidence tier.
for _,id in ipairs({5198,5202,6695,2042,2933}) do
    local item=assert(GetGear.ItemCatalog[id],"Missing provenance candidate "..id)
    assert(item.confidence=="classic-reference", "Expected Classic source caveat for "..id)
    item.acquisitionLocationConfidence = (item.acquisitionLocation and item.acquisitionLocation.quality)
    assert(item.acquisitionConfidence=="classic-reference", "Source evidence promoted by map route: "..id)
end
