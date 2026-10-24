local addonName, GetGear = ...
-- v0.12.9 evidence follow-up: never derive learning minima from
-- yellow/green/grey skill-ups. Indexed Forever pattern and output item tooltips
-- are dated client evidence, NOT live trainer/vendor verification.
local facts={
  [2300]={url="https://theforeverera.com/en/items/2300/", proof="forever-client-item-tooltip", binding="boe"}, -- Embossed Leather Vest
  [2303]={url="https://theforeverera.com/en/recipes/leatherworking/handstitched-leather-pants/", proof="forever-client-item-tooltip", binding="boe"}, -- Handstitched Leather Pants
  [2849]={url="https://theforeverera.com/en/recipes/blacksmithing/bronze-axe/", proof="forever-indexed-trainer-learning-minimum", skill=85, binding="boe"}, -- Bronze Axe
  [2850]={url="https://theforeverera.com/en/recipes/blacksmithing/bronze-shortsword/", proof="forever-indexed-trainer-learning-minimum", skill=95, binding="boe"}, -- Bronze Shortsword
  [2852]={url="https://theforeverera.com/en/items/2852/", proof="forever-client-item-tooltip", binding="boe"}, -- Copper Chain Pants
  [2853]={url="https://foreverdb.net/item/2853", proof="forever-client-initial-profession", skill=1}, -- Copper Bracers
  [2854]={url="https://theforeverera.com/en/recipes/blacksmithing/runed-copper-bracers/", proof="forever-client-item-tooltip", binding="boe"}, -- Runed Copper Bracers
  [2857]={url="https://theforeverera.com/en/recipes/blacksmithing/runed-copper-belt/", proof="forever-indexed-trainer-learning-minimum", skill=80, binding="boe"}, -- Runed Copper Belt
  [2866]={url="https://theforeverera.com/en/recipes/blacksmithing/rough-bronze-cuirass/", proof="forever-indexed-trainer-learning-minimum", skill=105, binding="boe"}, -- Rough Bronze Cuirass
  [2870]={url="https://theforeverera.com/en/recipes/blacksmithing/shining-silver-breastplate/", proof="forever-indexed-trainer-learning-minimum", skill=135, binding="boe"}, -- Shining Silver Breastplate
  [3469]={url="https://www.wowhead.com/forever/item=3469/copper-chain-boots", proof="forever-client-item-tooltip", binding="boe"}, -- Copper Chain Boots
  [3471]={url="https://theforeverera.com/en/recipes/blacksmithing/copper-chain-vest/", proof="explicit-forever-plans-item", skill=30, binding="boe"}, -- Copper Chain Vest
  [3480]={url="https://theforeverera.com/en/recipes/blacksmithing/rough-bronze-shoulders/", proof="forever-client-item-tooltip", binding="boe"}, -- Rough Bronze Shoulders
  [3482]={url="https://theforeverera.com/en/recipes/blacksmithing/silvered-bronze-boots/", proof="forever-client-item-tooltip", binding="boe"}, -- Silvered Bronze Boots
  [3488]={url="https://theforeverera.com/en/recipes/blacksmithing/copper-battle-axe/", proof="forever-client-item-tooltip", binding="boe"}, -- Copper Battle Axe
  [3490]={url="https://www.wowhead.com/forever/item=2883/plans-deadly-bronze-poniard", proof="explicit-forever-plans-item", skill=100, binding="boe"}, -- Deadly Bronze Poniard
  [3491]={url="https://theforeverera.com/en/recipes/blacksmithing/heavy-bronze-mace/", proof="forever-client-item-tooltip", binding="boe"}, -- Heavy Bronze Mace
  [3719]={url="https://theforeverera.com/en/recipes/leatherworking/hillmans-cloak/", proof="forever-client-item-tooltip", binding="boe"}, -- Hillman's Cloak
  [3842]={url="https://theforeverera.com/en/recipes/blacksmithing/green-iron-leggings/", proof="forever-client-item-tooltip", binding="boe"}, -- Green Iron Leggings
  [3849]={url="https://theforeverera.com/en/recipes/blacksmithing/hardened-iron-shortsword/", proof="explicit-forever-plans-item", skill=135, binding="boe"}, -- Hardened Iron Shortsword
  [3850]={url="https://theforeverera.com/en/recipes/blacksmithing/jade-serpentblade/", proof="explicit-forever-plans-item", skill=150, binding="boe"}, -- Jade Serpentblade
  [4242]={url="https://theforeverera.com/en/items/4242/", proof="forever-client-item-tooltip", binding="boe"}, -- Embossed Leather Pants
  [4244]={url="https://theforeverera.com/en/recipes/leatherworking/hillmans-leather-vest/", proof="explicit-forever-pattern-item", skill=75, binding="boe"}, -- Hillman's Leather Vest
  [4311]={url="https://theforeverera.com/en/recipes/tailoring/heavy-woolen-cloak/", proof="explicit-forever-pattern-item", skill=80, binding="boe"}, -- Heavy Woolen Cloak
  [4318]={url="https://theforeverera.com/en/recipes/tailoring/gloves-of-meditation/", proof="forever-client-item-tooltip", binding="boe"}, -- Gloves of Meditation
  [4320]={url="https://theforeverera.com/en/recipes/tailoring/spidersilk-boots/", proof="forever-client-item-tooltip", binding="boe"}, -- Spidersilk Boots
  [5540]={url="https://theforeverera.com/en/recipes/blacksmithing/pearl-handled-dagger/", proof="forever-client-item-tooltip", binding="boe"}, -- Pearl-handled Dagger
  [5541]={url="https://theforeverera.com/en/recipes/blacksmithing/iridescent-hammer/", proof="explicit-forever-plans-item", skill=115, binding="boe"}, -- Iridescent Hammer
  [5542]={url="https://theforeverera.com/en/items/5542/", proof="forever-client-item-tooltip", binding="boe"}, -- Pearl-clasped Cloak
  [5957]={url="https://theforeverera.com/en/items/5957/", proof="forever-client-item-tooltip", binding="boe"}, -- Handstitched Leather Vest
  [6214]={url="https://theforeverera.com/en/recipes/blacksmithing/heavy-copper-maul/", proof="forever-client-item-tooltip", binding="boe"}, -- Heavy Copper Maul
  [6468]={url="https://theforeverera.com/en/recipes/leatherworking/deviate-scale-belt/", proof="explicit-forever-pattern-item", skill=90, binding="boe"}, -- Deviate Scale Belt
  [6730]={url="https://theforeverera.com/en/recipes/blacksmithing/ironforge-chain/", proof="explicit-forever-plans-item", skill=70, binding="boe"}, -- Ironforge Chain
  [7047]={url="https://theforeverera.com/en/recipes/tailoring/hands-of-darkness/", proof="explicit-forever-pattern-item", skill=120, binding="boe"}, -- Hands of Darkness
  [7049]={url="https://theforeverera.com/en/recipes/tailoring/truefaith-gloves/", proof="explicit-forever-pattern-item", skill=125, binding="boe"}, -- Truefaith Gloves
  [7053]={url="https://theforeverera.com/en/recipes/tailoring/azure-silk-cloak/", proof="explicit-forever-pattern-item", skill=140, binding="boe"}, -- Azure Silk Cloak
  [7166]={url="https://theforeverera.com/en/recipes/blacksmithing/copper-dagger/", proof="forever-client-item-tooltip", binding="boe"}, -- Copper Dagger
  [7348]={url="https://theforeverera.com/en/recipes/leatherworking/fletchers-gloves/", proof="forever-client-item-tooltip", binding="boe"}, -- Fletcher's Gloves
  [7352]={url="https://theforeverera.com/en/recipes/leatherworking/earthen-leather-shoulders/", proof="explicit-forever-pattern-item", skill=110, binding="boe"}, -- Earthen Leather Shoulders
  [7374]={url="https://theforeverera.com/en/recipes/leatherworking/dusky-leather-armor/", proof="forever-client-item-tooltip", binding="boe"}, -- Dusky Leather Armor
  [7955]={url="https://theforeverera.com/en/recipes/blacksmithing/copper-claymore/", proof="forever-client-item-tooltip", binding="boe"}, -- Copper Claymore
  [7956]={url="https://theforeverera.com/en/recipes/blacksmithing/bronze-warhammer/", proof="forever-client-item-tooltip", binding="boe"}, -- Bronze Warhammer
  [10421]={url="https://foreverdb.net/item/10421", proof="forever-client-item-tooltip", skill=1, binding="boe"}, -- Rough Copper Vest
  [11287]={url="https://theforeverera.com/en/recipes/enchanting/lesser-magic-wand/", proof="forever-client-item-tooltip", binding="boe"}, -- Lesser Magic Wand
  [11288]={url="https://theforeverera.com/en/recipes/enchanting/greater-magic-wand/", proof="forever-client-item-tooltip", binding="boe"}, -- Greater Magic Wand
  [18948]={url="https://theforeverera.com/en/recipes/leatherworking/barbaric-bracers/", proof="explicit-forever-pattern-item", skill=130, binding="boe"}, -- Barbaric Bracers
  [20575]={url="https://theforeverera.com/en/recipes/leatherworking/black-whelp-tunic/", proof="explicit-forever-pattern-item", skill=75, binding="boe"}, -- Black Whelp Tunic
  [247789]={url="https://theforeverera.com/en/recipes/enchanting/novices-practice-wand/", proof="forever-client-initial-profession", skill=1, binding="boe"}, -- Novice's Practice Wand
  [249395]={url="https://theforeverera.com/en/recipes/enchanting/orb-of-souls/", proof="explicit-forever-formula-item", skill=140, binding="bop"}, -- Orb of Souls
  [250556]={url="https://theforeverera.com/en/recipes/blacksmithing/officers-belt/", proof="explicit-forever-plans-item", skill=150, binding="bop"}, -- Officer's Belt
  [250557]={url="https://theforeverera.com/en/recipes/blacksmithing/sentinels-belt/", proof="explicit-forever-plans-item", skill=150, binding="bop"}, -- Sentinel's Belt
  [250558]={url="https://theforeverera.com/en/recipes/blacksmithing/warders-belt/", proof="explicit-forever-plans-item", skill=150, binding="bop"}, -- Warder's Belt
  [250559]={url="https://theforeverera.com/en/recipes/blacksmithing/prefects-belt/", proof="explicit-forever-plans-item", skill=150, binding="bop"}, -- Prefect's Belt
  [250603]={url="https://theforeverera.com/en/recipes/blacksmithing/bronze-dory/", proof="explicit-forever-plans-item", skill=95, binding="boe"}, -- Bronze Dory
  [252445]={url="https://theforeverera.com/en/recipes/leatherworking/defenders-leather-pants/", proof="forever-client-item-tooltip", binding="bop"}, -- Defender's Leather Pants
  [252455]={url="https://theforeverera.com/en/recipes/leatherworking/defenders-leather-helm/", proof="forever-client-item-tooltip", binding="bop"}, -- Defender's Leather Helm
  [252456]={url="https://theforeverera.com/en/recipes/leatherworking/totemic-leather-helm/", proof="forever-client-item-tooltip", binding="bop"}, -- Totemic Leather Helm
  [252501]={url="https://theforeverera.com/en/recipes/leatherworking/trappers-leather-pants/", proof="forever-client-item-tooltip", binding="bop"}, -- Trapper's Leather Pants
  [252502]={url="https://theforeverera.com/en/recipes/leatherworking/stormriders-leather-pants/", proof="forever-client-item-tooltip", binding="bop"}, -- Stormrider's Leather Pants
  [252503]={url="https://theforeverera.com/en/recipes/leatherworking/wisdoms-leather-pants/", proof="forever-client-item-tooltip", binding="bop"}, -- Wisdom's Leather Pants
  [252512]={url="https://theforeverera.com/en/recipes/leatherworking/brawlers-leather-helm/", proof="forever-client-item-tooltip", binding="bop"}, -- Brawler's Leather Helm
  [252515]={url="https://theforeverera.com/en/recipes/leatherworking/wisdoms-leather-helm/", proof="forever-client-item-tooltip", binding="bop"}, -- Wisdom's Leather Helm
  [253885]={url="https://theforeverera.com/en/recipes/tailoring/novice-arcanists-sash/", proof="explicit-forever-pattern-item", skill=50, binding="bop"}, -- Novice Arcanist's Sash
  [253887]={url="https://theforeverera.com/en/recipes/tailoring/novice-ardents-sash/", proof="explicit-forever-pattern-item", skill=50, binding="bop"}, -- Novice Ardent's Sash
  [253889]={url="https://theforeverera.com/en/recipes/tailoring/pristine-boots/", proof="explicit-forever-pattern-item", skill=60, binding="bop"}, -- Pristine Boots
  [253891]={url="https://theforeverera.com/en/recipes/tailoring/silky-boots/", proof="explicit-forever-pattern-item", skill=60, binding="bop"}, -- Silky Boots
  [253893]={url="https://theforeverera.com/en/recipes/tailoring/flame-boots/", proof="explicit-forever-pattern-item", skill=60, binding="bop"}, -- Flame Boots
  [253895]={url="https://theforeverera.com/en/recipes/tailoring/shadow-boots/", proof="explicit-forever-pattern-item", skill=60, binding="bop"}, -- Shadow Boots
  [253897]={url="https://theforeverera.com/en/recipes/tailoring/pearly-boots/", proof="explicit-forever-pattern-item", skill=60, binding="bop"}, -- Pearly Boots
  [253901]={url="https://theforeverera.com/en/recipes/tailoring/filigreed-pristine-gown/", proof="explicit-forever-pattern-item", skill=75, binding="bop"}, -- Filigreed Pristine Gown
  [253903]={url="https://theforeverera.com/en/recipes/tailoring/filigreed-silky-gown/", proof="explicit-forever-pattern-item", skill=75, binding="bop"}, -- Filigreed Silky Gown
  [253905]={url="https://theforeverera.com/en/recipes/tailoring/filigreed-flame-gown/", proof="explicit-forever-pattern-item", skill=75, binding="bop"}, -- Filigreed Flame Gown
  [253907]={url="https://theforeverera.com/en/recipes/tailoring/filigreed-shadow-gown/", proof="explicit-forever-pattern-item", skill=75, binding="bop"}, -- Filigreed Shadow Gown
  [253909]={url="https://theforeverera.com/en/recipes/tailoring/filigreed-pearly-gown/", proof="explicit-forever-pattern-item", skill=75, binding="bop"}, -- Filigreed Pearly Gown
  [253913]={url="https://theforeverera.com/en/recipes/tailoring/pristine-gloves/", proof="explicit-forever-pattern-item", skill=75, binding="bop"}, -- Pristine Gloves
  [253915]={url="https://theforeverera.com/en/recipes/tailoring/silky-gloves/", proof="explicit-forever-pattern-item", skill=75, binding="bop"}, -- Silky Gloves
  [253917]={url="https://theforeverera.com/en/recipes/tailoring/flame-gloves/", proof="explicit-forever-pattern-item", skill=75, binding="bop"}, -- Flame Gloves
  [253919]={url="https://theforeverera.com/en/recipes/tailoring/shadow-gloves/", proof="explicit-forever-pattern-item", skill=75, binding="bop"}, -- Shadow Gloves
  [253921]={url="https://theforeverera.com/en/recipes/tailoring/pearly-gloves/", proof="explicit-forever-pattern-item", skill=75, binding="bop"}, -- Pearly Gloves
  [253925]={url="https://theforeverera.com/en/recipes/tailoring/pristine-sash/", proof="explicit-forever-pattern-item", skill=85, binding="bop"}, -- Pristine Sash
  [253927]={url="https://theforeverera.com/en/recipes/tailoring/silky-sash/", proof="explicit-forever-pattern-item", skill=85, binding="bop"}, -- Silky Sash
  [253929]={url="https://theforeverera.com/en/recipes/tailoring/flame-sash/", proof="explicit-forever-pattern-item", skill=85, binding="bop"}, -- Flame Sash
  [253931]={url="https://theforeverera.com/en/recipes/tailoring/shadow-sash/", proof="explicit-forever-pattern-item", skill=85, binding="bop"}, -- Shadow Sash
  [253933]={url="https://theforeverera.com/en/recipes/tailoring/pearly-sash/", proof="explicit-forever-pattern-item", skill=85, binding="bop"}, -- Pearly Sash
  [253939]={url="https://theforeverera.com/en/recipes/tailoring/filigreed-silky-leggings/", proof="explicit-forever-pattern-item", skill=100, binding="bop"}, -- Filigreed Silky Leggings
  [253941]={url="https://theforeverera.com/en/recipes/tailoring/filigreed-flame-leggings/", proof="explicit-forever-pattern-item", skill=100, binding="bop"}, -- Filigreed Flame Leggings
  [253943]={url="https://theforeverera.com/en/recipes/tailoring/filigreed-shadow-leggings/", proof="explicit-forever-pattern-item", skill=100, binding="bop"}, -- Filigreed Shadow Leggings
  [253945]={url="https://theforeverera.com/en/recipes/tailoring/filigreed-pearly-leggings/", proof="explicit-forever-pattern-item", skill=100, binding="bop"}, -- Filigreed Pearly Leggings
  [253951]={url="https://theforeverera.com/en/recipes/tailoring/silky-circlet/", proof="explicit-forever-pattern-item", skill=100, binding="bop"}, -- Silky Circlet
  [253953]={url="https://theforeverera.com/en/recipes/tailoring/flame-circlet/", proof="explicit-forever-pattern-item", skill=100, binding="bop"}, -- Flame Circlet
  [253955]={url="https://theforeverera.com/en/recipes/tailoring/shadow-circlet/", proof="explicit-forever-pattern-item", skill=100, binding="bop"}, -- Shadow Circlet
  [253957]={url="https://theforeverera.com/en/recipes/tailoring/pearly-circlet/", proof="explicit-forever-pattern-item", skill=100, binding="bop"}, -- Pearly Circlet
  [253961]={url="https://theforeverera.com/en/recipes/tailoring/pristine-gown/", proof="explicit-forever-pattern-item", skill=110, binding="bop"}, -- Pristine Gown
  [253963]={url="https://theforeverera.com/en/recipes/tailoring/silky-gown/", proof="explicit-forever-pattern-item", skill=110, binding="bop"}, -- Silky Gown
  [253965]={url="https://theforeverera.com/en/recipes/tailoring/flame-gown/", proof="explicit-forever-pattern-item", skill=110, binding="bop"}, -- Flame Gown
  [253967]={url="https://theforeverera.com/en/recipes/tailoring/shadow-gown/", proof="explicit-forever-pattern-item", skill=110, binding="bop"}, -- Shadow Gown
  [253969]={url="https://theforeverera.com/en/recipes/tailoring/pearly-gown/", proof="explicit-forever-pattern-item", skill=110, binding="bop"}, -- Pearly Gown
  [253977]={url="https://theforeverera.com/en/recipes/tailoring/filigreed-silky-circlet/", proof="explicit-forever-pattern-item", skill=125, binding="bop"}, -- Filigreed Silky Circlet
  [253979]={url="https://theforeverera.com/en/recipes/tailoring/filigreed-flame-circlet/", proof="explicit-forever-pattern-item", skill=125, binding="bop"}, -- Filigreed Flame Circlet
  [253981]={url="https://theforeverera.com/en/recipes/tailoring/filigreed-shadow-circlet/", proof="explicit-forever-pattern-item", skill=125, binding="bop"}, -- Filigreed Shadow Circlet
  [253983]={url="https://theforeverera.com/en/recipes/tailoring/filigreed-pearly-circlet/", proof="explicit-forever-pattern-item", skill=125, binding="bop"}, -- Filigreed Pearly Circlet
  [253987]={url="https://theforeverera.com/en/recipes/tailoring/pristine-leggings/", proof="explicit-forever-pattern-item", skill=125, binding="bop"}, -- Pristine Leggings
  [253989]={url="https://theforeverera.com/en/recipes/tailoring/silky-leggings/", proof="explicit-forever-pattern-item", skill=125, binding="bop"}, -- Silky Leggings
  [253991]={url="https://theforeverera.com/en/recipes/tailoring/flame-leggings/", proof="explicit-forever-pattern-item", skill=125, binding="bop"}, -- Flame Leggings
  [253993]={url="https://theforeverera.com/en/recipes/tailoring/shadow-leggings/", proof="explicit-forever-pattern-item", skill=125, binding="bop"}, -- Shadow Leggings
  [253995]={url="https://theforeverera.com/en/recipes/tailoring/pearly-leggings/", proof="explicit-forever-pattern-item", skill=125, binding="bop"}, -- Pearly Leggings
  [254001]={url="https://theforeverera.com/en/recipes/tailoring/gilded-slippers/", proof="explicit-forever-pattern-item", skill=140, binding="bop"}, -- Gilded Slippers
  [254003]={url="https://theforeverera.com/en/recipes/tailoring/frothing-slippers/", proof="explicit-forever-pattern-item", skill=140, binding="bop"}, -- Frothing Slippers
  [254005]={url="https://theforeverera.com/en/recipes/tailoring/fiery-slippers/", proof="explicit-forever-pattern-item", skill=140, binding="bop"}, -- Fiery Slippers
  [254007]={url="https://theforeverera.com/en/recipes/tailoring/black-slippers/", proof="explicit-forever-pattern-item", skill=140, binding="bop"}, -- Black Slippers
  [254009]={url="https://theforeverera.com/en/recipes/tailoring/golden-slippers/", proof="explicit-forever-pattern-item", skill=140, binding="bop"}, -- Golden Slippers
}
GetGear.EvidenceReconciliation130={verifiedLearning={},verifiedBindings={},conflicts={}}
for id,f in pairs(facts) do
    local item=assert(GetGear.ItemCatalog[id], "Evidence item absent: "..id)
    assert(item.profession and item.reagents, "Not a crafted item: "..id)
    if f.skill then
        local current=item.professionSkillRequired
        if current and current~=f.skill then
            item.recipeRequirementConflict="Existing "..current.." versus Forever indexed "..f.skill
            GetGear.EvidenceReconciliation130.conflicts[#GetGear.EvidenceReconciliation130.conflicts+1]=id
        else
            item.professionSkillRequired=f.skill
            item.recipeLearnSkillEvidence=f.proof
            item.recipeRequirementEvidenceURL=f.url
            item.recipeLearnSkillProvisional=nil
            GetGear.EvidenceReconciliation130.verifiedLearning[#GetGear.EvidenceReconciliation130.verifiedLearning+1]=id
        end
    end
    if f.binding then
        item.bindingStatus=f.binding
        item.bindingEvidence="forever-client-item-tooltip"
        item.bindingEvidenceURL=f.url
        GetGear.EvidenceReconciliation130.verifiedBindings[#GetGear.EvidenceReconciliation130.verifiedBindings+1]=id
    end
end
-- A runtime client can override indexed metadata when the exact item has loaded.
-- This is an optional read-only accessor, not a claim of offline live verification.
function GetGear:GetVerifiedBinding(itemID)
    local item=self.ItemCatalog and self.ItemCatalog[itemID]
    if not item then return nil,"uncatalogued" end
    local getter = (C_Item and C_Item.GetItemInfo) or GetItemInfo
    if type(getter)=="function" then
        local ok,value = pcall(function() return select(14,getter(itemID)) end)
        if ok and type(value)=="number" then
            if value==1 then return "bop","live-client" end
            if value==2 then return "boe","live-client" end
            if value==3 then return "bou","live-client" end
            if value==4 then return "quest","live-client" end
            if value==0 then return "none","live-client" end
        end
    end
    if item.bindingEvidence=="forever-client-item-tooltip" then
        return item.bindingStatus,"forever-client-index"
    end
    return nil,"not-independently-verified"
end
-- Independent bind flags obtained from finished-item tooltips, not recipe scrolls.
local directFinishedItemBindings={
  [249396]="https://www.60.tools/items/249396-mystic-mushroom",
  [249397]="https://www.wowhead.com/forever/spell=1248754/tenets-of-the-silver-hand",
  [249398]="https://www.wowhead.com/forever/item=249398/polished-driftwood-icon",
  [250500]="https://senseos.gg/wiki/wow-forever/items/250500/protectors-chain-helm/",
  [250501]="https://www.wowhead.com/forever/spell=1252250/acolytes-chain-helm",
  [250502]="https://metaforge.app/wow-forever/database/armor/crusaders-chain-helm",
  [250503]="https://foreverdiff.com/recipes/veteran-s-boots-54715/",
  [250504]="https://foreverdiff.com/recipes/guard-s-boots-54716/",
  [250505]="https://foreverdiff.com/recipes/protector-s-boots-54717/",
  [250506]="https://www.wowhead.com/forever/item=250506/acolytes-boots",
  [250508]="https://foreverdiff.com/recipes/veteran-s-gloves-54720/",
  [250509]="https://foreverdiff.com/recipes/guard-s-gloves-54721/",
  [250511]="https://www.wowhead.com/forever/item=250511/acolytes-gloves",
  [250514]="https://theforeverera.com/en/recipes/blacksmithing/guards-chain-belt/",
  [250518]="https://www.wowhead.com/forever/item=250518/veterans-silvered-chain-shirt",
  [250519]="https://theforeverera.com/en/recipes/blacksmithing/guards-silvered-chain-shirt/",
  [250520]="https://theforeverera.com/en/recipes/blacksmithing/protectors-silvered-chain-shirt/",
  [250521]="https://www.wowhead.com/forever/item=250521/acolytes-silvered-chain-shirt",
  [250523]="https://www.wowhead.com/forever/spell=1252272/veterans-silvered-chain-leggings",
  [250524]="https://wowforever.gameslantern.com/items/guards-silvered-chain-leggings",
  [250525]="https://www.wowhead.com/forever/item=250525/protectors-silvered-chain-leggings",
  [250526]="https://wowforever.ninja/items/250526-acolytes-silvered-chain-leggings/",
  [250528]="https://www.wowhead.com/forever/spell=1252277/veterans-silvered-chain-helm",
  [250530]="https://www.wowhead.com/forever/spell=1252279/protectors-silvered-chain-helm",
  [250531]="https://www.wowhead.com/forever/item=250531/acolytes-silvered-chain-helm",
  [252427]="https://foreverdiff.com/recipes/moonglow-boots-55204/",
  [252439]="https://www.wowhead.com/forever/item=252439/brawlers-leather-boots",
  [252441]="https://theforeverera.com/en/recipes/leatherworking/defenders-leather-boots/",
  [252443]="https://www.wowhead.com/forever/item=252443/stormriders-leather-boots",
  [252448]="https://foreverdiff.com/recipes/totemic-leather-hood-55167/",
  [252450]="https://foreverdiff.com/recipes/defender-s-leather-tunic-55161/",
  [252457]="https://www.wowhead.com/forever/spell=1255085/defenders-leather-kilt",
  [252459]="https://www.wowhead.com/forever/item=252459/prowlers-leather-belt",
  [252460]="https://foreverdiff.com/recipes/warden-s-leather-belt-55139/",
  [252494]="https://foreverdiff.com/recipes/brawler-s-leather-gloves-55191/",
  [252495]="https://foreverdiff.com/recipes/trapper-s-leather-gloves-55190/",
  [252496]="https://theforeverera.com/en/recipes/leatherworking/defenders-leather-gloves/",
  [252498]="https://www.wowhead.com/forever/item=252498/stormriders-leather-gloves",
  [252504]="https://theforeverera.com/en/recipes/leatherworking/brawlers-leather-hood/",
  [252507]="https://foreverdiff.com/recipes/wisdom-s-leather-hood-55165/",
  [252508]="https://endgametools.com/en/wow-forever/items/252508",
  [252509]="https://www.wowhead.com/forever/spell=1255101/trappers-leather-tunic",
  [252510]="https://www.wowhead.com/forever/spell=1255098/stormriders-leather-tunic",
  [252511]="https://www.wowhead.com/forever/spell=1255097/wisdoms-leather-tunic",
  [252519]="https://theforeverera.com/en/recipes/leatherworking/wisdoms-leather-leggings/",
  [252520]="https://www.wowhead.com/forever/item=252520/skulkers-leather-belt",
  [252521]="https://www.wowhead.com/forever/spell=1255079/stalkers-leather-belt",
  [252522]="https://theforeverera.com/en/recipes/leatherworking/skycallers-leather-belt/",
  [252523]="https://theforeverera.com/en/recipes/leatherworking/menders-leather-belt/",
}
for itemID,url in pairs(directFinishedItemBindings) do
    local item=assert(GetGear.ItemCatalog[itemID],"Unknown BoP finished item: "..itemID)
    assert(item.bindingStatus=="bop", "BoP evidence conflicts: "..itemID)
    item.bindingEvidence="forever-client-item-tooltip"
    item.bindingEvidenceURL=url
end
