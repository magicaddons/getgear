-- Regression for the opt-in craftability-only recommendation filter.
-- Run with Lua 5.4: lua5.4 tests/craftability-filter.lua .
local root=(arg and arg[1]) or "."
local toc=assert(io.open(root.."/GetGear.toc")):read("*a")
assert(toc:find("CraftingVisibility.lua",1,true))
local addon={}
local skip={["Core.lua"]=true,["UI.lua"]=true,["AltInventory.lua"]=true}
for line in toc:gmatch("[^\r\n]+") do
  if line:match("%.lua$") then
    local chunk=assert(loadfile(root.."/"..line))
    if not skip[line] then
      local ok,err=pcall(chunk,"GetGear",addon)
      assert(ok,line.." : "..tostring(err))
    end
  end
end

local know,skills={},{}
local function noop() return nil end
GetProfessions=function()return 1,2 end
GetProfessionInfo=function(index)
  if index==1 and skills.Tailoring then return "Tailoring",nil,skills.Tailoring end
  if index==2 and skills.Blacksmithing then return "Blacksmithing",nil,skills.Blacksmithing end
end
addon.GetRecipeKnowledge=function(_,gear) return know[gear.itemID] end
addon.GetBagPlanningObjectives=function()return {} end
addon.GetBagUpgradePlan=function()return nil end
addon.IsGearEquipped=function()return false end
addon.GetObsoleteGearReason=function()return nil end
addon.GetMaterialCount=noop
addon.level=6
addon.db={status={},hidden={},overlay={filterObsolete=false,hideUncraftableCrafts=false,dependencyExpanded={}}}

local robe={id="test_robe",itemID=2572,slot="Chest",targetLevel=5,sourceType="Tailoring",profession="Tailoring",professionSkillRequired=25,recipeLearnMethod="pattern",recipeLearnSkillEvidence="Forever teaching item",reagents={{itemID=2604,name="Red Dye",amount=2}}}
local vest={id="test_vest",itemID=6239,slot="Chest",targetLevel=7,sourceType="Tailoring",profession="Tailoring",professionSkillRequired=35,recipeLearnMethod="pattern",recipeLearnSkillEvidence="Forever teaching item",reagents={{itemID=2604,name="Red Dye",amount=1}}}
local bracers={id="test_bracers",itemID=4308,slot="Wrist",targetLevel=7,sourceType="Tailoring",profession="Tailoring",recipeLearnMethod="trainer",recipeLearnSkillEvidence="unverified",reagents={{itemID=2605,name="Green Dye",amount=1}}}
local smith={id="test_smith",itemID=2851,slot="Waist",targetLevel=6,sourceType="Blacksmithing",profession="Blacksmithing",recipeLearnMethod="trainer"}
local quest={id="test_quest",itemID=90001,slot="Ring",targetLevel=6,sourceType="Quest"}
local dual={id="test_dual",itemID=252512,slot="Head",targetLevel=6,sourceType="Dungeon",optionalCraft={profession="Leatherworking"}}
local bags={id="test_bag",itemID=4238,slot="Bag",targetLevel=6,bagUpgrade=true,profession="Tailoring"}
addon.Gear={robe,vest,bracers,smith,quest,dual}
local function count(list) local n=0;for _ in ipairs(list) do n=n+1 end;return n end
local function contains(list,id)for _,x in ipairs(list) do if x.itemID==id then return true end end return false end

-- The default intentionally offers crafted items even without the profession.
assert(addon:ShouldDisplayCraftedGear(robe))
local unknownCraft={itemID=999000,slot="Chest",craftOnly=true,sourceType="Crafted gear (recipe unknown)"}
assert(addon:ShouldDisplayCraftedGear(unknownCraft),
    "Default mode should show source-confirmed crafted items with unknown recipe")
assert(count(addon:GetItems("tracker"))==6)
addon.db.overlay.hideUncraftableCrafts=true
assert(not addon:ShouldDisplayCraftedGear(unknownCraft),
    "Strict opt-in filter must hide crafted items with unknown profession")
assert(not addon:ShouldDisplayCraftedGear(robe))
assert(not addon:ShouldDisplayCraftedGear(smith))
assert(addon:ShouldDisplayCraftedGear(quest) and addon:ShouldDisplayCraftedGear(dual))
assert(addon:ShouldDisplayCraftedGear(bags))
local list=addon:GetItems("tracker")
assert(count(list)==2 and contains(list,90001) and contains(list,252512))
assert(#addon:GetCombinedMaterialRows("all")==0,"Filtered materials must not count")
assert(#addon:GetUndocumentedCrafts("all")==0,"Filtered unknown materials must not count")

skills.Tailoring=30
know[2572]=true
know[6239]=true
assert(addon:ShouldDisplayCraftedGear(robe))
assert(not addon:ShouldDisplayCraftedGear(vest),"Verified required skill must be enforced")
assert(not addon:ShouldDisplayCraftedGear(bracers),"Unconfirmed trainer recipe is not confirmed craftable")
list=addon:GetItems("tracker")
assert(contains(list,2572) and not contains(list,6239))
local mats=addon:GetCombinedMaterialRows("all")
assert(contains(mats,2604),"Available craft should contribute its materials")
assert(not contains(mats,2605),"Filtered craft should not contribute materials")

know[4308]=true
assert(addon:ShouldDisplayCraftedGear(bracers))
skills.Tailoring=40
assert(addon:ShouldDisplayCraftedGear(vest))
addon.db.hidden[robe.id]=true
addon.db.status[bracers.id]="acquired"
assert(contains(addon:GetItems("hidden"),2572),"Hide filter must not remove saved history")
assert(contains(addon:GetItems("completed"),4308),"Hide filter must not remove acquired history")
assert(not contains(addon:GetItems("tracker"),2572))
-- Missing client profession API must fail open, not treat absence as proof of no skill.
GetProfessions=nil
assert(addon:ShouldDisplayCraftedGear(smith))
print("PASS craftability filter: default off, skill/learned recipe gates, other routes, history, materials")
