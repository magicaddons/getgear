local addonName, GetGear = ...

-- Normal inventory bags only (the four equipped bag slots, bag indexes 1-4).
-- Reagent, profession, soul, ammo, quiver and bank containers are excluded.
-- Source: Forever 1.60.1.70450 recipe tables; the tier skill values are
-- INTERNAL planning thresholds, not verified trainer learning requirements.
local BAG_TIERS = {
    {itemID=4238, recipeSpellID=3755, name="Linen Bag", slots=6, level=1, skill=1,
     inputs={{2996,3},{2320,3}}, source="Tailoring trainer", sourceURL="https://www.wowhead.com/forever/item=4238", 
     notes="6-slot ordinary bag. Trainer-taught; confirm the learning threshold in game."},
    {itemID=4240, recipeSpellID=3757, name="Woolen Bag", slots=8, level=15, skill=75,
     inputs={{2997,3},{2321,1}}, source="Tailoring trainer", sourceURL="https://www.wowhead.com/forever/item=4240",
     notes="8-slot ordinary bag. Trainer-taught; the minimum skill varies across current published sources."},
    {itemID=4245, recipeSpellID=3813, name="Small Silk Pack", slots=10, level=25, skill=145,
     inputs={{4305,3},{4234,2},{2321,3}}, source="Tailoring trainer", sourceURL="https://www.wowhead.com/forever/item=4245",
     notes="10-slot ordinary bag. Trainer-taught; verify minimum learning skill with a trainer."},
    {itemID=10050, recipeSpellID=12065, name="Mageweave Bag", slots=12, level=30, skill=205,
     inputs={{4339,4},{4291,2}}, source="Tailoring trainer", sourceURL="https://www.wowhead.com/forever/item=10050",
     notes="12-slot ordinary bag. Trainer-taught; verify minimum learning skill with a trainer."},
}
GetGear.BagTiers = BAG_TIERS

local function GetBagSlots(index)
    if C_Container and type(C_Container.GetContainerNumSlots)=="function" then
        local ok,slots=pcall(C_Container.GetContainerNumSlots,index)
        if ok and type(slots)=="number" then return slots end
    elseif type(GetContainerNumSlots)=="function" then
        local ok,slots=pcall(GetContainerNumSlots,index)
        if ok and type(slots)=="number" then return slots end
    end
    return nil
end

-- The bag-family API is important: a specialty bag with only six slots must
-- not be mistaken for a disposable six-slot general-purpose inventory bag.
local function BagFamily(index)
    if C_Container and type(C_Container.GetContainerNumFreeSlots)=="function" then
        local ok,_,family=pcall(C_Container.GetContainerNumFreeSlots,index)
        if ok and type(family)=="number" then return family end
    elseif type(GetContainerNumFreeSlots)=="function" then
        local ok,_,family=pcall(GetContainerNumFreeSlots,index)
        if ok and type(family)=="number" then return family end
    end
    return nil
end

-- Returns nil if bag-slot data are missing rather than claiming there are
-- four empty slots. Count bags worn in indexes 1-4 only; the backpack cannot
-- be replaced and the reagent container is a different type of equipment.
function GetGear:GetEquippedBagSnapshot()
    local snapshot = {}
    for index=1,4 do
        local slots=GetBagSlots(index)
        if slots==nil then return nil end
        local bagID=nil
        if type(GetInventoryItemID)=="function" then
            local ok,id=pcall(GetInventoryItemID,"player",19+index)
            if ok then bagID=id end
        end
        if slots>0 then
            -- Some Forever clients report a valid worn-bag capacity and bag
            -- family but GetInventoryItemID("player",19+index) returns nil.
            -- Item ID isn't needed to judge an ordinary bag's capacity.
            -- Only family == 0 can be safely replaced; nil or specialty
            -- families remain protected even if an item ID is available.
            local family=BagFamily(index)
            snapshot[#snapshot+1]={index=index,slots=slots,itemID=bagID,
                replaceable=(family==0),
                reason=family==nil and "bag family unknown" or
                    (family~=0 and "specialty bag" or nil)}
        elseif not bagID then
            -- A reliably reported zero-capacity slot with no worn bag is
            -- empty. It can be filled without trying to guess an item ID.
            snapshot[#snapshot+1]={index=index,slots=0,replaceable=true}
        else
            -- A cached bag item with an unreadable capacity: don't infer it
            -- is an empty slot and recommend replacing a possible specialty.
            snapshot[#snapshot+1]={index=index,slots=0,itemID=bagID,
                replaceable=false,reason="bag capacity unavailable"}
        end
    end
    return snapshot
end

-- A planning recommendation, not an automatic equipment upgrade operation.
-- Character level sets the normally useful bag tier. A skilled tailor may
-- see a larger tier sooner, but no player is told that a skill milestone
-- guarantees a trainer has the recipe. Buying and commissioning are alternatives.
function GetGear:GetBagUpgradePlan()
    if not self.db or (self.db.overlay and self.db.overlay.bagUpgrades==false) then return nil end
    local equipped=self:GetEquippedBagSnapshot()
    if not equipped then return nil end
    local level=self.level or 1
    local skill=self.GetProfessionSkill and self:GetProfessionSkill("Tailoring") or nil
    local chosen=BAG_TIERS[1]
    for _,tier in ipairs(BAG_TIERS) do
        if level>=tier.level or (skill and skill>=tier.skill) then chosen=tier end
    end
    local replacing,from={},{}
    for _,bag in ipairs(equipped) do
        if bag.replaceable and bag.slots<chosen.slots then
            replacing[#replacing+1]=bag.index
            from[#from+1]=bag.slots
        end
    end
    local count=#replacing
    if count==0 then return nil end
    -- Already-made, unequipped replacement bags need no new reagents.
    -- GetMaterialCount uses includeBank=false and includeEquipped=false.
    local spare=self.GetMaterialCount and self:GetMaterialCount(chosen.itemID) or nil
    if type(spare)~="number" then spare=0 end
    spare=math.max(0,math.min(count,spare))
    local toCraft=count-spare
    local materials={}
    if skill and toCraft>0 then
        for _,entry in ipairs(chosen.inputs) do
            materials[#materials+1]={itemID=entry[1],name=self:MaterialName(entry[1]),amount=entry[2]*toCraft}
        end
    end
    local route
    if skill then
        route="Tailoring "..skill.." detected. Upgrade "..count.." bag slot(s). "
          ..(spare>0 and (spare.." suitable spare bag(s) already in inventory; ") or "")
          .."Craft or commission "..toCraft.." more if needed. "
          .."If the recipe is not yet learned, check a Tailoring trainer; "
          .."skill colour breakpoints do not establish the learning requirement. "
          .."Materials shown cover "..toCraft.." new craft(s), not bags already owned."
    else
        route="Tailoring not detected. Upgrade "..count.." bag slot(s). "
          ..(spare>0 and (spare.." suitable spare bag(s) already in inventory. ") or "")
          .."Buy or commission "..toCraft.." more from the Auction House or another tailor. "
          .."Crafting ingredients are not added to your personal materials tracker."
    end
    return {
        id="auto_bag_"..chosen.itemID, itemID=chosen.itemID,
        name=chosen.name, slot="Bag", bagUpgrade=true, quantity=count,
        bagSlots=chosen.slots, replacing=replacing, oldSlots=from,
        spareBags=spare, craftQuantity=toCraft,
        targetLevel=math.min(chosen.level,level), availableLevel=1,
        sourceType=skill and "Tailoring" or "Trade / Tailoring",
        source=chosen.source, zone="Any Tailoring trainer / Auction House",
        instructions=route, notes=chosen.notes,
        profession="Tailoring", -- displayed for EVERY class, even non-tailors
        professionLearnSource="Trainer",
        recipeSpellID=chosen.recipeSpellID,
        -- Keep the colour/planning skill out of the user-facing craft threshold.
        -- Current beta sources disagree on the Woolen Bag learning minimum.
        professionSkillRequired=(chosen.itemID==4238 and 1 or nil),
        reagents=materials,
        confidence="client", acquisitionConfidence="client", sourceURL=chosen.sourceURL,
        focus="All",
    }
end

-- Source alternatives are separate, independently hideable objectives.
-- Each alternative is only shown when it adds ordinary inventory capacity.
-- We do not combine their material requirements: crafting and purchasing the
-- same capacity are competing routes, not things the player must do both of.
local function CanStillDoQuest(questID)
    if C_QuestLog and type(C_QuestLog.IsQuestFlaggedCompleted)=="function" then
        local ok,done=pcall(C_QuestLog.IsQuestFlaggedCompleted,questID)
        if ok then return not done end
    end
    return true -- no quest API available; explain the uncertainty in the text
end

function GetGear:GetBagPlanningObjectives()
    local plan=self:GetBagUpgradePlan()
    if not plan then return {} end
    local results={plan}
    local equipped=self:GetEquippedBagSnapshot()
    if not equipped then return results end
    local level=self.level or 1
    local faction=type(UnitFactionGroup)=="function" and UnitFactionGroup("player") or "Alliance"
    local race=type(UnitRace)=="function" and select(2,UnitRace("player")) or nil
    local function CountUnder(cap)
        local n=0
        for _,bag in ipairs(equipped) do
            if bag.replaceable and bag.slots<cap then n=n+1 end
        end
        return n
    end
    local function Alternative(id,name,slots,target,count,source,notes,sourceType,place)
        if count<=0 then return end
        local spare=self.GetMaterialCount and self:GetMaterialCount(id) or 0
        if type(spare)~="number" then spare=0 end
        local missing=math.max(0,count-math.min(spare,count))
        results[#results+1]={id="auto_bag_"..id,itemID=id,name=name,
            bagUpgrade=true,bagAlternative=true,quantity=count,bagSlots=slots,
            craftQuantity=0,spareBags=math.min(spare,count),
            slot="Bag",targetLevel=math.min(target,level),availableLevel=1,
            sourceType=sourceType,source=source,
            zone=place and place.zone or "Auction House / Quest",
            instructions=notes.." "..count.." bag slot(s) could gain capacity; "
                ..missing.." copy/copies still needed after bags in inventory.",
            notes="Alternative to crafted bag recommendations; do not buy and craft both sets.",
            acquisitionLocation=place,
            acquisitionConfidence=place and place.quality or "client",
            confidence="client",reagents={},focus="All"}
    end
    -- Real beta vendor scans verified this 8-slot bag on both factions.
    if level>=15 then
        local vendor
        if faction=="Horde" then
            vendor={zone="Orgrimmar",x=58.9,y=52.9,
                spot="Gotri, bag vendor (Brown Leather Satchel)",quality="forever"}
        elseif race == "Human" then
            vendor={zone="Elwynn Forest",x=43.9,y=66.0,
                spot="Brog Hamfist, general supplies (Brown Leather Satchel)",quality="forever"}
        elseif race == "NightElf" then
            vendor={zone="Darnassus",x=64.5,y=53.1,
                spot="Ellandrieth, general goods (Brown Leather Satchel)",quality="forever"}
        else
            vendor={zone="Dun Morogh",x=47.2,y=52.4,
                spot="Kreg Bilmn, general supplies (Brown Leather Satchel)",quality="forever"}
        end
        Alternative(4498,"Brown Leather Satchel",8,15,CountUnder(8),
            "General supplies vendor",
            "Vendor purchase (25 silver each, verify current price) or Auction House."
                .." Other local general-goods vendors may also carry it.",
            "Vendor",vendor)
    end
    -- New, confirmed Forever Alliance starting-zone quest bag. Unlike
    -- craftable bags this quest yields exactly ONE copy, and doesn't
    -- justify upgrading already-equipped six-slot bags.
    if faction=="Alliance" and (race=="Gnome" or race=="Dwarf")
        and level>=4 and CanStillDoQuest( 97277) then
        local empty=0
        for _,bag in ipairs(equipped) do
            if bag.replaceable and bag.slots<6 then empty=empty+1 end
        end
        Alternative( 277977,"Canvas Latchbag",6,4,math.min(empty,1),
            "Quest: Grund and Gozwin",
            "Reward from Grund and Gozwin near Anvilmar in Coldridge Valley."
              .." Find the Mechanic's Log and defeat Snow Leopard Prowler."
              .." The quest is one-time; no exact coordinates independently verified.",
            "Quest",{zone="Dun Morogh",spot="Grund and Gozwin: Coldridge Valley near Anvilmar",quality="zone-only"})
    end
    return results
end
