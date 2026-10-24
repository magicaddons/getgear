local addonName, GetGear = ...
-- GetGear v0.8.0, Alliance Mage level 1-30 research preview.
-- ForeverDB client-extracted item IDs, equip levels and recipes, 1.60.1.70450.
-- Normal school-specific patterns: Mivin Shadowweave / Azeroth Commerce Authority.
-- Filigreed patterns: reported dungeon drops, tradability/boss varies by item.
-- Professions are required to craft bind-on-pickup school sets; do NOT imply
-- that the finished items can be bought on the Auction House.
GetGear:RegisterGuide("MAGE", {faction="Alliance",status="research-preview",label="Mage"})
local aca = {zone="Redridge Mountains",x=10.0,y=73.0,spot="Mivin Shadowweave, Azeroth Commerce Authority",quality="forever"}
local function Mat(id,name,amount) return {itemID=id,name=name,amount=amount} end
local function AddCraft(id,name,slot,level,skill,reagents,patternKind)
    local isDrop = patternKind=="dungeon"
    local source = isDrop and ("Pattern: "..name.." — dungeon drop / AH if tradeable")
        or ("Pattern: "..name.." — Azeroth Commerce Authority")
    local instruction = isDrop and
        ("Obtain Pattern: "..name.." from reported dungeon loot. Check the AH only if the pattern is tradeable. No specific boss drop is guaranteed. Craft yourself; the equipment binds on pickup.")
        or ("Buy Pattern: "..name.." from Mivin Shadowweave at Three Corners, Redridge Mountains (10.0, 73.0) for 30 Merchant's Favor. Craft it yourself; the equipment binds on pickup.")
    local record = {
        itemID=id,name=name,slot=slot,availableLevel=level,sourceType="Tailoring",
        source=source,zone=isDrop and "Dungeon loot / Auction House (pattern only)" or "Three Corners, Redridge Mountains",
        instructions=instruction,profession="Tailoring",professionSkillRequired=skill,
        reagents=reagents,confidence="client",acquisitionKind=isDrop and "Dungeon pattern drop" or "Vendor",
        acquisitionConfidence=isDrop and "reported" or "forever",
        sourceURL="https://foreverdb.net/item/"..id,
    }
    if not isDrop then record.acquisitionLocation=aca end
    return GetGear:RegisterItem(record)
end
local function Add(id,level,priority,spec,note)
    local r = {itemID=id,targetLevel=level,focus=spec or "All"}
    if note then r.notes=note end
    assert(GetGear:AddRecommendation("MAGE",r),"Duplicate/missing Mage item "..tostring(id))
end
assert(AddCraft(253897,"Pearly Boots","Feet",12,60,{Mat(2997,"Bolt of Woolen Cloth",8),Mat(2321,"Fine Thread",2),Mat(249409,"Cerulean Dye",2),Mat(5498,"Small Lustrous Pearl",1)},"vendor"))
Add(253897,12,"High","Arcane","Elemental damage option; requires Tailoring and a vendor pattern.")
assert(AddCraft(253909,"Filigreed Pearly Gown","Chest",15,75,{Mat(2997,"Bolt of Woolen Cloth",8),Mat(2321,"Fine Thread",4),Mat(249409,"Cerulean Dye",2),Mat(5498,"Small Lustrous Pearl",2)},"dungeon"))
Add(253909,15,"Optional","Arcane","Alternative pattern; dungeon drop, crafted item binds on pickup.")
assert(AddCraft(253921,"Pearly Gloves","Hands",15,75,{Mat(2997,"Bolt of Woolen Cloth",6),Mat(2321,"Fine Thread",4),Mat(249409,"Cerulean Dye",3),Mat(5498,"Small Lustrous Pearl",2)},"vendor"))
Add(253921,15,"High","Arcane","Elemental damage option; requires Tailoring and a vendor pattern.")
assert(AddCraft(253933,"Pearly Sash","Waist",17,85,{Mat(4305,"Bolt of Silk Cloth",8),Mat(2321,"Fine Thread",4),Mat(249409,"Cerulean Dye",3),Mat(5498,"Small Lustrous Pearl",3)},"vendor"))
Add(253933,17,"High","Arcane","Elemental damage option; requires Tailoring and a vendor pattern.")
assert(AddCraft(253957,"Pearly Circlet","Head",20,100,{Mat(4305,"Bolt of Silk Cloth",10),Mat(4291,"Silken Thread",2),Mat(249409,"Cerulean Dye",4),Mat(5498,"Small Lustrous Pearl",4),Mat(2842,"Silver Bar",1),Mat(11082,"Greater Astral Essence",2)},"vendor"))
Add(253957,20,"High","Arcane","Elemental damage option; requires Tailoring and a vendor pattern.")
assert(AddCraft(253945,"Filigreed Pearly Leggings","Legs",20,100,{Mat(4305,"Bolt of Silk Cloth",8),Mat(2321,"Fine Thread",4),Mat(249409,"Cerulean Dye",2),Mat(5498,"Small Lustrous Pearl",4)},"dungeon"))
Add(253945,20,"Optional","Arcane","Alternative pattern; dungeon drop, crafted item binds on pickup.")
assert(AddCraft(253969,"Pearly Gown","Chest",22,110,{Mat(4305,"Bolt of Silk Cloth",12),Mat(4291,"Silken Thread",2),Mat(249409,"Cerulean Dye",6),Mat(5498,"Small Lustrous Pearl",6),Mat(2842,"Silver Bar",2),Mat(11082,"Greater Astral Essence",2)},"vendor"))
Add(253969,22,"High","Arcane","Elemental damage option; requires Tailoring and a vendor pattern.")
assert(AddCraft(253983,"Filigreed Pearly Circlet","Head",25,125,{Mat(4305,"Bolt of Silk Cloth",8),Mat(2321,"Fine Thread",4),Mat(249409,"Cerulean Dye",2),Mat(5498,"Small Lustrous Pearl",6)},"dungeon"))
Add(253983,25,"Optional","Arcane","Alternative pattern; dungeon drop, crafted item binds on pickup.")
assert(AddCraft(253995,"Pearly Leggings","Legs",25,125,{Mat(4305,"Bolt of Silk Cloth",14),Mat(2321,"Fine Thread",3),Mat(249409,"Cerulean Dye",8),Mat(5498,"Small Lustrous Pearl",8),Mat(2842,"Silver Bar",2),Mat(11082,"Greater Astral Essence",3)},"vendor"))
Add(253995,25,"High","Arcane","Elemental damage option; requires Tailoring and a vendor pattern.")
assert(GetGear:RegisterItem({itemID=254009,name="Golden Slippers",slot="Feet",availableLevel=30,sourceType="Tailoring",source="Source unconfirmed: Golden Slippers",zone="Tailoring recipe source unknown / Spinning Wheel",profession="Tailoring",professionSkillRequired=140,confidence="client",acquisitionKind="Crafting (pattern source unverified)",acquisitionConfidence="client",instructions="Recipe requires Tailoring skill 140; verify where the pattern is learned before travelling. Craft using a Spinning Wheel. Bind on pickup. Bolt of Mageweave requires a separate higher Tailoring skill to produce yourself, or can be sourced from other players.",reagents={Mat(4339,"Bolt of Mageweave",8),Mat(8343,"Heavy Silken Thread",4),Mat(249430,"Magenta Dye",2),Mat(249409,"Cerulean Dye",2),Mat(13926,"Golden Pearl",2)},sourceURL="https://foreverdb.net/item/254009"}))
Add(254009,30,"High","Arcane","Level-30 school-damage craft. Higher-level intermediate Mageweave bolts may need to be obtained from another tailor.")
Add(253893,12,"High","Fire","Elemental damage option; requires Tailoring and a vendor pattern.")
Add(253905,15,"Optional","Fire","Alternative pattern; dungeon drop, crafted item binds on pickup.")
Add(253917,15,"High","Fire","Elemental damage option; requires Tailoring and a vendor pattern.")
Add(253929,17,"High","Fire","Elemental damage option; requires Tailoring and a vendor pattern.")
Add(253953,20,"High","Fire","Elemental damage option; requires Tailoring and a vendor pattern.")
Add(253941,20,"Optional","Fire","Alternative pattern; dungeon drop, crafted item binds on pickup.")
Add(253965,22,"High","Fire","Elemental damage option; requires Tailoring and a vendor pattern.")
Add(253979,25,"Optional","Fire","Alternative pattern; dungeon drop, crafted item binds on pickup.")
Add(253991,25,"High","Fire","Elemental damage option; requires Tailoring and a vendor pattern.")
Add(254005,30,"High","Fire","Level-30 school-damage craft. Higher-level intermediate Mageweave bolts may need to be obtained from another tailor.")
assert(AddCraft(253891,"Silky Boots","Feet",12,60,{Mat(2997,"Bolt of Woolen Cloth",8),Mat(2321,"Fine Thread",2),Mat(249409,"Cerulean Dye",2),Mat(3182,"Spider's Silk",1)},"vendor"))
Add(253891,12,"High","Frost","Elemental damage option; requires Tailoring and a vendor pattern.")
assert(AddCraft(253903,"Filigreed Silky Gown","Chest",15,75,{Mat(2997,"Bolt of Woolen Cloth",8),Mat(2321,"Fine Thread",4),Mat(249409,"Cerulean Dye",2),Mat(3182,"Spider's Silk",2)},"dungeon"))
Add(253903,15,"Optional","Frost","Alternative pattern; dungeon drop, crafted item binds on pickup.")
assert(AddCraft(253915,"Silky Gloves","Hands",15,75,{Mat(2997,"Bolt of Woolen Cloth",6),Mat(2321,"Fine Thread",4),Mat(249409,"Cerulean Dye",3),Mat(3182,"Spider's Silk",2)},"vendor"))
Add(253915,15,"High","Frost","Elemental damage option; requires Tailoring and a vendor pattern.")
assert(AddCraft(253927,"Silky Sash","Waist",17,85,{Mat(4305,"Bolt of Silk Cloth",8),Mat(2321,"Fine Thread",4),Mat(249409,"Cerulean Dye",3),Mat(3182,"Spider's Silk",3)},"vendor"))
Add(253927,17,"High","Frost","Elemental damage option; requires Tailoring and a vendor pattern.")
assert(AddCraft(253951,"Silky Circlet","Head",20,100,{Mat(4305,"Bolt of Silk Cloth",10),Mat(4291,"Silken Thread",2),Mat(249409,"Cerulean Dye",4),Mat(3182,"Spider's Silk",4),Mat(2842,"Silver Bar",1),Mat(11082,"Greater Astral Essence",2)},"vendor"))
Add(253951,20,"High","Frost","Elemental damage option; requires Tailoring and a vendor pattern.")
assert(AddCraft(253939,"Filigreed Silky Leggings","Legs",20,100,{Mat(4305,"Bolt of Silk Cloth",8),Mat(2321,"Fine Thread",4),Mat(249409,"Cerulean Dye",2),Mat(3182,"Spider's Silk",4)},"dungeon"))
Add(253939,20,"Optional","Frost","Alternative pattern; dungeon drop, crafted item binds on pickup.")
assert(AddCraft(253963,"Silky Gown","Chest",22,110,{Mat(4305,"Bolt of Silk Cloth",12),Mat(4291,"Silken Thread",2),Mat(249409,"Cerulean Dye",6),Mat(3182,"Spider's Silk",6),Mat(2842,"Silver Bar",2),Mat(11082,"Greater Astral Essence",2)},"vendor"))
Add(253963,22,"High","Frost","Elemental damage option; requires Tailoring and a vendor pattern.")
assert(AddCraft(253977,"Filigreed Silky Circlet","Head",25,125,{Mat(4305,"Bolt of Silk Cloth",8),Mat(2321,"Fine Thread",4),Mat(249409,"Cerulean Dye",2),Mat(3182,"Spider's Silk",6)},"dungeon"))
Add(253977,25,"Optional","Frost","Alternative pattern; dungeon drop, crafted item binds on pickup.")
assert(AddCraft(253989,"Silky Leggings","Legs",25,125,{Mat(4305,"Bolt of Silk Cloth",14),Mat(2321,"Fine Thread",3),Mat(249409,"Cerulean Dye",8),Mat(3182,"Spider's Silk",8),Mat(2842,"Silver Bar",2),Mat(11082,"Greater Astral Essence",3)},"vendor"))
Add(253989,25,"High","Frost","Elemental damage option; requires Tailoring and a vendor pattern.")
assert(GetGear:RegisterItem({itemID=254003,name="Frothing Slippers",slot="Feet",availableLevel=30,sourceType="Tailoring",source="Source unconfirmed: Frothing Slippers",zone="Tailoring recipe source unknown / Spinning Wheel",profession="Tailoring",professionSkillRequired=140,confidence="client",acquisitionKind="Crafting (pattern source unverified)",acquisitionConfidence="client",instructions="Recipe requires Tailoring skill 140; verify where the pattern is learned before travelling. Craft using a Spinning Wheel. Bind on pickup. Bolt of Mageweave requires a separate higher Tailoring skill to produce yourself, or can be sourced from other players.",reagents={Mat(4339,"Bolt of Mageweave",8),Mat(8343,"Heavy Silken Thread",4),Mat(249430,"Magenta Dye",2),Mat(249409,"Cerulean Dye",2),Mat(7079,"Globe of Water",2)},sourceURL="https://foreverdb.net/item/254003"}))
Add(254003,30,"High","Frost","Level-30 school-damage craft. Higher-level intermediate Mageweave bolts may need to be obtained from another tailor.")
assert(GetGear:RegisterItem({itemID=7053,name="Azure Silk Cloak",slot="Back",availableLevel=30,
    sourceType="Tailoring",source="Tailoring trainer / Auction House",zone="Tailoring trainer or Auction House",
    profession="Tailoring",professionSkillRequired=140,confidence="client",acquisitionKind="Trainer",
    acquisitionConfidence="forever",instructions="Learn from a qualified Tailoring trainer (skill 140) or purchase a completed Bind-on-Equip cloak from a tailor/Auction House.",
    notes="+10 Frost damage and +3 Spirit in the Forever client.",
    reagents={Mat(4305,"Bolt of Silk Cloth",3),Mat(6260,"Blue Dye",2),Mat(2321,"Fine Thread",2)},
    sourceURL="https://foreverdb.net/item/7053"}))
Add(7053,30,"High","Frost")
Add(247789,1,"High","All","Starter wand / Enchanting.")
Add(11287,5,"High","All","Early wand. Check enchanting skill and reagents.")
Add(253885,10,"High","All","Universal spell power Tailoring sash; bind on pickup.")
Add(11288,13,"High","All","Strong early wand; available through Enchanting.")
Add(5542,14,"Medium","All","Bind-on-equip spell-power cloak; buy finished on AH if desired.")
Add(279898,15,"Optional","All","Alliance Ironforge off-hand; quest availability should be confirmed.")
Add(4311,16,"Optional","All","BoE cloak craft or AH; recipe source unverified.")
Add(2042,18,"Optional","All","Deadmines quest staff, reward choice still Classic-reference.")
Add(5198,18,"Optional","All","Deadmines wand; boss source still Classic-reference.")
Add(4320,20,"Medium","All","Tailoring boots with general Spell Power, can be difficult to craft.")
Add(6903,23,"Medium","All","Gaze Dreamer Pants; Blackfathom Deeps drop.")
Add(8071,22,"Optional","All","Alliance Wailing Caverns quest reward; Forever route unverified.")
Add(6908,24,"Medium","All","Ghamoo-ra's Bind; dungeon drop route uses Classic reference.")
Add(7001,27,"Medium","All","Alliance Blackfathom Villainy quest reward; quest prerequisites apply.")
Add(7684,30,"High","All","Scarlet Monastery shoulder drop; confirm dungeon access.")
Add(23169,30,"Optional","All","Scarlet Monastery neck alternative; verify actual stats against your gear.")
Add(19525,28,"Optional","All","PvP/reputation ring; faction standing and source should be verified.")
Add(20099,28,"Optional","All","League of Arathor gear; confirm honor/reputation requirements.")
-- "All" is the union of class-specific alternatives, NOT a requirement to
-- craft Arcane, Fire and Frost gear simultaneously. Choose a profile or hide
-- unwanted alternatives to keep the Total Materials list meaningful.
