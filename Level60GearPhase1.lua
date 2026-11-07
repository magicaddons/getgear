local addonName, GetGear = ...
-- First source-checked 31–60 tranche. NOT a complete catalogue.
-- Item stats/recipe reagents: Forever client indexed pages (see item URLs).
-- Availability: a client recipe does not prove the pattern is available at launch.
-- The source field intentionally does not invent boss drop rates or vendors.
local A={"PRIEST","MAGE","WARLOCK","DRUID","ROGUE","HUNTER","SHAMAN","WARRIOR","PALADIN"}
local M={"WARRIOR","PALADIN","HUNTER","SHAMAN"}
local L={"DRUID","ROGUE","HUNTER","SHAMAN","WARRIOR","PALADIN"}
local P={"WARRIOR","PALADIN"}
local S={"WARRIOR","PALADIN","ROGUE","HUNTER","MAGE","WARLOCK"}
local D={"WARRIOR","ROGUE","HUNTER","DRUID","SHAMAN","PRIEST","MAGE","WARLOCK"}
local function Mat(id,name,amount) return {itemID=id,name=name,amount=amount} end
local mats={
  thick= function(n) return Mat(4234,"Thick Leather",n) end,
  scorpid=function(n) return Mat(8154,"Scorpid Scale",n) end,
  silken=function(n) return Mat(4291,"Silken Thread",n) end,
  heavythread=function(n) return Mat(8343,"Heavy Silken Thread",n) end,
  runeBolt=function(n) return Mat(14048,"Bolt of Runecloth",n) end,
  runeThread=function(n) return Mat(14341,"Rune Thread",n) end,
}
local function T(id,name,level,slot,armor,profession,learn,benefits,reagents,classes)
  return {id=id,name=name,level=level,slot=slot,armor=armor,profession=profession,
    learn=learn,benefits=benefits,reagents=reagents,classes=classes}
end
local gear={
  T(8203,"Tough Scorpid Breastplate",39,"Chest","Mail","Leatherworking",195,
    "+15 Agility, +7 Intellect; 245 armor",
    {mats.thick(12),mats.scorpid(12),mats.silken(4)},M),
  T(8204,"Tough Scorpid Gloves",40,"Hands","Mail","Leatherworking",200,
    "+10 Agility, +9 Intellect; 155 armor",
    {mats.thick(6),mats.scorpid(8),mats.silken(2)},M),
  T(8205,"Tough Scorpid Bracers",39,"Wrist","Mail","Leatherworking",195,
    "+7 Agility, +6 Intellect; 107 armor",
    {mats.thick(10),mats.scorpid(4),mats.silken(2)},M),
  T(8206,"Tough Scorpid Leggings",44,"Legs","Mail","Leatherworking",220,
    "+17 Agility, +10 Intellect; 235 armor",
    {mats.thick(14),mats.scorpid(8),mats.heavythread(2)},M),
  T(8207,"Tough Scorpid Shoulders",43,"Shoulder","Mail","Leatherworking",215,
    "+10 Agility, +10 Intellect; 197 armor",
    {mats.thick(12),mats.scorpid(16),mats.heavythread(2)},M),
  T(8208,"Tough Scorpid Helm",45,"Head","Mail","Leatherworking",225,
    "+14 Agility, +14 Intellect; 222 armor",
    {mats.thick(10),mats.scorpid(20),mats.heavythread(2)},M),
  T(8209,"Tough Scorpid Boots",42,"Feet","Mail","Leatherworking",210,
    "+12 Agility, +7 Intellect; 178 armor",
    {mats.thick(12),mats.scorpid(12),mats.silken(6)},M),
  T(8347,"Dragonscale Gauntlets",40,"Hands","Mail","Leatherworking",nil,
    "+6 Agility, +7 Stamina, +1% Critical Strike; 171 armor",
    {mats.thick(24),Mat(8165,"Worn Dragonscale",12),mats.heavythread(4),
      Mat(8172,"Cured Thick Hide",2)},M),
  T(8367,"Dragonscale Breastplate",46,"Chest","Mail","Leatherworking",nil,
    "+10 Stamina, five resistances, 600 magical absorption on use; 306 armor",
    {mats.thick(40),Mat(8165,"Worn Dragonscale",30),mats.heavythread(4),
      Mat(8172,"Cured Thick Hide",4)},M),
  T(10020,"Stormcloth Vest",40,"Chest","Cloth","Tailoring",225,
    "+8 Stamina, +8 Spirit, +58 Healing, +10 Spell Power; 59 armor",
    {Mat(4339,"Bolt of Mageweave",5),Mat(7079,"Globe of Water",3),
      mats.heavythread(2)},A),
  T(13858,"Runecloth Robe",47,"Chest","Cloth","Tailoring",215,
    "+17 Intellect, +11 Spell Power; 68 armor",
    {mats.runeBolt(5),Mat(14227,"Ironweb Spider Silk",1),mats.runeThread(1)},A),
  T(14136,"Robe of Winter Night",52,"Chest","Cloth","Tailoring",245,
    "+12 Intellect, +40 Shadow Damage, +40 Frost Damage; 81 armor",
    {mats.runeBolt(10),Mat(14256,"Felcloth",12),Mat(12808,"Essence of Undeath",4),
      Mat(7080,"Essence of Water",4),mats.runeThread(1)},A),
  T(14138,"Mooncloth Vest",55,"Chest","Cloth","Tailoring",270,
    "+20 Intellect, +19 Spirit, +26 Healing, +9 Spell Power; 85 armor",
    {mats.runeBolt(6),Mat(14342,"Mooncloth",4),mats.runeThread(1)},A),
  T(14106,"Felcloth Robe",56,"Chest","Cloth","Tailoring",260,
    "+7 Stamina, +36 Shadow Damage; 79 armor",
    {mats.runeBolt(8),Mat(14256,"Felcloth",8),Mat(12662,"Demonic Rune",4),
      mats.runeThread(2)},A),
  T(15096,"Runic Leather Shoulders",57,"Shoulder","Leather","Leatherworking",285,
    "+15 Intellect, +10 Spell Power; 119 armor",
    {Mat(8170,"Rugged Leather",16),Mat(12810,"Enchanted Leather",4),
      Mat(14047,"Runecloth",18),Mat(15407,"Cured Rugged Hide",1),
      mats.runeThread(2)},L),
  T(12420,"Radiant Leggings",56,"Legs","Mail","Blacksmithing",280,
    "+12 Stamina, +18 Frost Resistance, +18 Shadow Resistance; 286 armor",
    {Mat(12359,"Thorium Bar",20),Mat(7077,"Heart of Fire",4)},M),
  T(12612,"Runic Plate Helm",56,"Head","Plate","Blacksmithing",280,
    "+19 Stamina, +14 Fire Resistance, +14 Nature Resistance; 621 armor",
    {Mat(12359,"Thorium Bar",30),Mat(12360,"Arcanite Bar",2),
      Mat(6037,"Truesilver Bar",2),Mat(12364,"Huge Emerald",1)},P),
  T(7943,"Wicked Mithril Blade",40,"Main Hand","Sword","Blacksmithing",200,
    "26.6 weapon DPS, +6 Strength, +4 Agility; one-hand sword",
    {Mat(3860,"Mithril Bar",14),Mat(6037,"Truesilver Bar",4),
      Mat(7966,"Solid Grinding Stone",1),mats.thick(2)},S),
  T(7944,"Dazzling Mithril Rapier",43,"Main Hand","One-Hand Sword","Blacksmithing",215,
    "28.5 weapon DPS, +8 Agility; one-hand sword",
    {Mat(3860,"Mithril Bar",14),Mat(7909,"Aquamarine",1),
      Mat(1705,"Lesser Moonstone",2),Mat(1206,"Moss Agate",2),
      Mat(7966,"Solid Grinding Stone",1),Mat(4338,"Mageweave Cloth",2)},S),
  T(7961,"Phantom Blade",44,"Main Hand","One-Hand Sword","Blacksmithing",nil,
    "32.5 weapon DPS; chance on hit: -100 enemy armor and prevents stealth",
    {Mat(3860,"Mithril Bar",28),Mat(7081,"Breath of Wind",6),
      Mat(6037,"Truesilver Bar",8),Mat(3823,"Lesser Invisibility Potion",2),
      Mat(7909,"Aquamarine",6),Mat(7966,"Solid Grinding Stone",4),
      Mat(4234,"Thick Leather",2)},S),
  T(7947,"Ebon Shiv",46,"Main Hand","Dagger","Blacksmithing",230,
    "30.3 weapon DPS, +9 Agility; one-hand dagger",
    {Mat(3860,"Mithril Bar",12),Mat(6037,"Truesilver Bar",6),
      Mat(7910,"Star Ruby",2),Mat(7966,"Solid Grinding Stone",1),
      Mat(4234,"Thick Leather",2)},D),
  T(14153,"Robe of the Void",57,"Chest","Cloth","Tailoring",295,
    "Warlock only, bind on pickup; +10 Stamina, +9 Intellect, +46 Spell Power; pet heal",
    {mats.runeBolt(12),Mat(12662,"Demonic Rune",20),Mat(14256,"Felcloth",40),
      Mat(7078,"Essence of Fire",8),Mat(12808,"Essence of Undeath",8),
      mats.runeThread(2),Mat(249431,"Viridian Dye",10)},{"WARLOCK"}),
  T(14154,"Truefaith Vestments",57,"Chest","Cloth","Tailoring",295,
    "Priest only, bind on pickup; +14 Stamina, +16 Spirit, +73 Healing, +25 Spell Power; Fade",
    {mats.runeBolt(12),Mat(14342,"Mooncloth",8),Mat(12811,"Righteous Orb",2),
      Mat(13926,"Golden Pearl",2),Mat(9210,"Ghost Dye",8),
      mats.runeThread(2),Mat(249431,"Viridian Dye",10)},{"PRIEST"}),
}
local audit={itemsAdded=0,recommendationsAdded=0,alreadyPresent=0,byClass={}}
for _,e in ipairs(gear) do
    local sourceURL="https://theforeverera.com/en/items/"..e.id.."/"
    if not GetGear.ItemCatalog[e.id] then
        local pattern=e.learn~=nil
        local item={
            itemID=e.id,name=e.name,slot=e.slot,availableLevel=e.level,
            sourceType=e.profession,source="Crafted "..e.profession.." (Forever client recipe)",
            zone=e.profession.." / player trading",
            confidence="client",acquisitionKind="Crafting",acquisitionConfidence="client",
            sourceURL=sourceURL,profession=e.profession,
            professionSkillRequired=e.learn,recipeLearnMethod=pattern and "pattern" or "unknown",
            recipeLearnSkillEvidence=pattern and "Forever recipe teaching item" or "unverified",
            recipeLearningAvailability="Client recipe verified; live pattern/specialization availability unverified",
            notes=e.benefits,reagents=e.reagents,
            instructions="The item and recipe exist in the Forever game client. Obtain the recipe/pattern and craft, or buy the finished Bind on Equip item from players. Client data alone does not confirm the live pattern seller or drop location.",
        }
        if e.id==8347 or e.id==8367 then
            item.instructions="Specialist Dragonscale Leatherworking recipe; confirm specialization, known recipe, and pattern access in the live game before crafting or commissioning."
        end
        if e.id==14153 or e.id==14154 then
            item.instructions="Bind on pickup: your character must have Tailoring and the learned pattern. Verify the live recipe source. The finished robe cannot be bought or commissioned."
        end
        assert(GetGear:RegisterItem(item),"duplicate 1-60 item: "..e.id)
        audit.itemsAdded=audit.itemsAdded+1
    else
        audit.alreadyPresent=audit.alreadyPresent+1
    end
    for _,class in ipairs(e.classes) do
        -- Hunters and Shamans receive Mail proficiency at level 40.
        local targetLevel=e.level
        if e.armor=="Mail" and (class=="HUNTER" or class=="SHAMAN") then
            targetLevel=math.max(40,targetLevel)
        end
        local recID="item_"..e.id
        local found=GetGear.RecommendationIndex and GetGear.RecommendationIndex[class]
            and GetGear.RecommendationIndex[class].ids[recID]
        if not found then
            local rec={itemID=e.id,targetLevel=targetLevel,focus="All",
                notes="Source-checked level 31-60 option. "..e.benefits}
            assert(GetGear:AddRecommendation(class,rec),
                "could not add 31-60 item "..e.id.." for "..class)
            audit.recommendationsAdded=audit.recommendationsAdded+1
            audit.byClass[class]=(audit.byClass[class] or 0)+1
        end
    end
end
GetGear.Level60GearPhase1=audit
