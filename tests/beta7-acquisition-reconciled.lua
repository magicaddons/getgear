-- Comprehensive source evidence integration regression without WoW client.
local root=(arg and arg[1]) or "."
local addon={}
local toc=assert(io.open(root.."/GetGear.toc")):read("*a")
local positions={}
local skip={["Core.lua"]=true,["UI.lua"]=true,["AltInventory.lua"]=true}
local n=0
for path in toc:gmatch("[^\r\n]+") do
    if path:match("%.lua$") then
        n=n+1;positions[path]=n
        if not skip[path] then
            local chunk,err=loadfile(root.."/"..path)
            assert(chunk,path..": "..tostring(err))
            local ok,message=pcall(chunk,"GetGear",addon)
            assert(ok,path..": "..tostring(message))
        end
    end
end
assert(positions["EquipmentCache.lua"]<positions["SourceEnrichment.lua"]
    and positions["SourceEnrichment.lua"]<positions["AcquisitionEvidenceIndex.lua"]
    and positions["AcquisitionEvidenceIndex.lua"]<positions["AcquisitionEvidence.lua"]
    and positions["AcquisitionEvidence.lua"]<positions["AcquisitionSummary.lua"]
    and positions["AcquisitionSummary.lua"]<positions["GuideEngine.lua"],
    "Evidence registry must preserve existing source precedence and class-gate generation")
assert(addon.CatalogueAudit.items==7707 and addon.CatalogueAudit.objectives==36341)
assert(addon.AcquisitionResearchAudit.indexed>=100,
    "Expected hundreds of safely attributed source references")
local classicTrash=assert(addon.ItemCatalog[1943])
assert(classicTrash.sourceSummary:find("Goblin Shipbuilder",1,true)
    and classicTrash.acquisitionConfidence=="classic-reference",
    "Original manual Classic-reference trash caveat must survive")
local defias=assert(addon.ItemCatalog[1951])
assert(defias.sourceSummary:find("Trash:",1,true)
    and defias.sourceSummary:find("Defias Pirate",1,true),
    "Original reviewed Deadmines trash label must survive")
local pattern=assert(addon.ItemCatalog[250489])
assert(pattern.recipePatternItemID==251341 and pattern.recipeAcquisitionKind=="Drop",
    "Dropped plans should not become a trainer recipe")
local named=assert(addon.ItemCatalog[1482])
local summary=addon:GetAcquisitionSummary(named)
assert(type(summary)=="string" and summary:find("Shadowfang Keep",1,true),
    "Known dungeon trash reference lost in evidence reconciliation")
assert(not summary:find("Boss:",1,true),
    "Shadowfang's generic trash loot should not be wrongly called a boss")
-- Source flags describe references; they MUST NOT certify live drop rates.
assert(named.acquisitionResearch
    and named.acquisitionResearch.confidence~="forever-observed-npc")
assert(named.acquisitionConfidence=="classic-reference",
    "New reference must not promote the imported confidence field")
local future=assert(addon.ItemCatalog[273884])
assert(future.recipePatternItemID==273952,
    "Level-60 book ID from independent Forever recipe data disappeared")
assert(future.recipeLearnMethod=="pattern",
    "A pattern book must not be misclassified as trainer teaching")
local futureSummary=addon:GetAcquisitionSummary(future)
assert(type(futureSummary)=="string" and futureSummary:find("unverified",1,true),
    "Future-recipe origin must remain explicitly unverified")
assert(not futureSummary:find("trainer",1,true),
    "A pattern book is not proof of trainer teaching")
-- A dungeon-sourced RECIPE must not claim the finished gear drops from a boss.
for _,id in ipairs({252501,252502,252503,252445,253905}) do
    local crafted=assert(addon.ItemCatalog[id],"Missing craftable fixture "..id)
    assert(crafted.profession~=nil and type(crafted.reagents)=="table",
        "Dungeon-associated crafted gear must remain craftable "..id)
    assert(not (crafted.acquisitionResearch and
        type(crafted.acquisitionResearch.sourceSummary)=="string" and
        crafted.acquisitionResearch.sourceSummary:find("Boss:",1,true)),
        "Pattern source must not become an equipment boss drop "..id)
end
local reportCSV=assert(io.open(root.."/docs/source-audit-1-60/reconciliation-20261109/dungeon_items_reconciled.csv")):read("*a")
assert(reportCSV:find("crafted-pattern",1,true),
    "The audit should explicitly separate dungeon recipe plans from equipment loot")
-- The historical Atal'Hakkar association for Idol of the Dream is false:
-- the finished relic is an Enchanting craft, with a separately sold formula.
local idol=assert(addon.ItemCatalog[220606])
assert(idol.sourceType=="Enchanting" and idol.recipeSpellID==1249128
    and idol.recipePatternItemID==249529 and idol.recipeLearnMethod=="pattern")
assert(idol.profession=="Enchanting" and idol.professionSkillRequired==300
    and idol.recipeVendor=="Alynsia")
local dungeonDropCSV=assert(io.open(root.."/docs/source-audit-1-60/reconciliation-20261109/dungeon_equipment_drops.csv")):read("*a")
assert(not dungeonDropCSV:find("\n220606,",1,true),
    "Crafted idol incorrectly counted as dungeon equipment loot")
local followUpCSV=assert(io.open(root.."/docs/source-audit-1-60/reconciliation-20261109/dungeon_source_followups.csv")):read("*a")
assert(not followUpCSV:find("\n220606,",1,true),
    "Known craft must not remain on dungeon-enemy verification list")
assert(reportCSV:find("220606,Idol of the Dream",1,true)
    and reportCSV:find("crafted-item",1,true),
    "Preserve historical misclassification transparently in the audit")

local vendorCSV=assert(io.open(root.."/docs/source-audit-1-60/reconciliation-20261109/recipe_vendor_book_checks.csv")):read("*a")
assert(vendorCSV:find("Aisarra Nightmeadow",1,true),
    "Named vendor reference must be preserved with live-stock caveat")
local recipeReconciliation=assert(io.open(root.."/docs/source-audit-1-60/reconciliation-20261109/README.md")):read("*a")
assert(recipeReconciliation:find("**954**",1,true),
    "All 68 vendor books and 886 trainer-labelled books need verification")
assert(recipeReconciliation:find("**552**",1,true)
    and recipeReconciliation:find("**24**",1,true)
    and recipeReconciliation:find("**31**",1,true),
    "Crafted-pattern records must not masquerade as equipment drops")
local index=assert(io.open(root.."/AcquisitionEvidenceIndex.lua")):read("*a")
assert(index:find("reputation/quest/slot gates may apply",1,true),
    "Preserve prospective Hyjal reputation and specialization requirements")
-- The catalogue and crafting lists remain identical and class-wide.
local checks={"PRIEST","MAGE","WARLOCK","DRUID","ROGUE","HUNTER","SHAMAN","WARRIOR","PALADIN"}
for _,cls in ipairs(checks) do
    assert(#(addon.EquipmentByClass[cls] or {})>=1000,"Class objectives missing "..cls)
end
local total,crafting=0,0
for id,facts in pairs(addon.ItemCatalog) do
    assert(addon.EquipmentEligibility[id],"Class eligibility lost "..id)
    total=total+1
    if facts.profession and type(facts.reagents)=="table" and #facts.reagents>0 then
        crafting=crafting+1
        for _,reagent in ipairs(facts.reagents) do
            assert(type(reagent.itemID)=="number" and type(reagent.amount)=="number"
                and reagent.amount>0 and type(reagent.name)=="string" and reagent.name~="",
                "Invalid reagent after source research for item "..id)
        end
    end
end
assert(total==7707 and crafting>=1252)
local report=assert(io.open(root.."/docs/source-audit-1-60/reconciliation-20261109/README.md")):read("*a")
assert(report:find("7,707") and report:find("1,252") and report:find("577"),
    "Reconciliation report is missing complete scope")
print("PASS full acquisition reconciliation: "..addon.AcquisitionResearchAudit.indexed..
      " item-ID sources; "..addon.AcquisitionResearchAudit.displayEnriched..
      " new displayed references; "..addon.AcquisitionResearchAudit.bookIdsAdded..
      " new recipe book IDs, 577 dungeon routes, 1252 crafts and nine classes")
