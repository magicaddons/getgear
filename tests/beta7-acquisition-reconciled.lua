-- Comprehensive source evidence integration regression without WoW client.
local root=(arg and arg[1]) or "."
local addon={}
local toc=assert(io.open(root.."/GetGear.toc")):read("*a")
local positions={}
local skip={["Core.lua"]=true,["UI.lua"]=true,["AltInventory.lua"]=true}
local n=0
-- Evidence overlays must preserve every pre-existing field except their
-- explicitly additive summary/book metadata. Deep copies detect nested
-- ingredient, stat and eligibility mutations, not just item counts.
local function copy(value)
    if type(value)~="table" then return value end
    local out={}; for k,v in pairs(value) do out[k]=copy(v) end; return out
end
local function same(a,b)
    if type(a)~=type(b) then return false end
    if type(a)~="table" then return a==b end
    for k,v in pairs(a) do if not same(v,b[k]) then return false end end
    for k in pairs(b) do if a[k]==nil then return false end end
    return true
end
local additive={sourceSummary=true,acquisitionResearch=true,
    recipePatternItemID=true,recipeLearnMethod=true,recipeMethodEvidence=true}
for path in toc:gmatch("[^\r\n]+") do
    if path:match("%.lua$") then
        n=n+1;positions[path]=n
        if not skip[path] then
            local chunk,err=loadfile(root.."/"..path)
            assert(chunk,path..": "..tostring(err))
            local before=path=="AcquisitionEvidence.lua" and copy(addon.ItemCatalog)
            local ok,message=pcall(chunk,"GetGear",addon)
            assert(ok,path..": "..tostring(message))
            if before then
                for id,facts in pairs(before) do
                    local after=assert(addon.ItemCatalog[id],"Removed item "..id)
                    for key,value in pairs(facts) do
                        if not additive[key] then
                            assert(same(value,after[key]),"Evidence mutated "..id.."/"..key)
                        end
                    end
                end
                for id in pairs(addon.ItemCatalog) do assert(before[id],"Added item "..id) end
            end
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

-- Nine former "boss/trash unknown" Scarlet Monastery entries are
-- explicitly documented in Forever's Dungeon Journal as rare-boss loot.
local rareBosses={
    {actor="Ironspine", ids={7686,7687,7688},slug="ironspine-rare"},
    {actor="Fallen Champion", ids={7689,7690,7691},slug="fallen-champion-rare"},
    {actor="Azshir the Sleepless", ids={7708,7709,7731},slug="azshir-the-sleepless-rare"},
}
for _,group in ipairs(rareBosses) do
    for _,id in ipairs(group.ids) do
        local gear=assert(addon.ItemCatalog[id],"Missing journal gear "..id)
        local research=assert(gear.acquisitionResearch,"Missing journal source "..id)
        assert(research.confidence=="published-forever-dungeon-journal")
        assert(research.sourceURL:find(group.slug,1,true),"Wrong rare-boss journal link "..id)
        assert(gear.sourceSummary
            and gear.sourceSummary:find("Rare boss: "..group.actor,1,true),
            "Missing precise rare-boss display source "..id)
        assert(not gear.sourceSummary:find("boss/trash unverified",1,true))
        assert(not followUpCSV:find("\n"..id..",",1,true),
            "Journal-documented boss still queued as unresolved "..id)
        assert(dungeonDropCSV:find("\n"..id..",",1,true),
            "Dungeon equipment removed incorrectly "..id)
    end
end
assert(addon.ItemCatalog[7709].acquisitionConfidence=="observed",
    "Do not erase the existing Blighted Leggings observation")
assert(addon.ItemCatalog[7709].source=="Azshir the Sleepless",
    "Do not overwrite Blighted Leggings original source")
assert(addon.ItemCatalog[7709].instructions:find("observed in Forever",1,true),
    "Do not erase prior live-recorded drop context")

-- Two explicitly attributed named trash drops, retained as published
-- references rather than promoted to observed Forever drop chances.
for _,entry in ipairs({
    {id=3569,name="Death's Head Priest",urlPart="razorfen-kraul"},
    {id=5943,name="Arugal's Voidwalker",urlPart="rift-bracers"},
}) do
    local item=assert(addon.ItemCatalog[entry.id],"Missing dungeon trash "..entry.id)
    local source=assert(item.acquisitionResearch,"Missing trash evidence "..entry.id)
    assert(source.confidence=="published-forever-trash-reference")
    assert(source.sourceURL:find(entry.urlPart,1,true),
        "Missing precise Forever loot reference "..entry.id)
    assert(item.sourceSummary
        and item.sourceSummary:find("Trash: "..entry.name,1,true),
        "Specific dungeon trash identity not shown "..entry.id)
    assert(item.sourceSummary:find("live drop unverified",1,true),
        "Do not imply verified live drop rates for dungeon trash")
    assert(not followUpCSV:find("\n"..entry.id..",",1,true),
        "Item with named trash identity still queued "..entry.id)
    assert(dungeonDropCSV:find("\n"..entry.id..",",1,true),
        "Named trash gear must remain counted as dungeon equipment")
end
assert(addon.ItemCatalog[3569].acquisitionConfidence~="published-forever-trash-reference"
    and addon.ItemCatalog[5943].acquisitionConfidence~="published-forever-trash-reference",
    "Additive published reference must remain separate from original item confidence")

-- Checkpoint 4: researched roles are reference-only, never live loot claims.
for _,r in ipairs({
    {id=9457,actor="Dark Iron Ambassador",confidence="published-forever-dungeon-journal"},
    {id=10804,actor="Ogom the Wretched",confidence="forever-encounter-historic-loot-reference"},
    {id=11633,actor="Hedrum the Creeper",confidence="published-forever-dungeon-guide"},
    {id=11726,actor="Gorosh the Dervish",confidence="published-forever-dungeon-guide"},
    {id=11728,actor="Ok'thor the Breaker",confidence="published-forever-dungeon-guide"},
    {id=11729,actor="Hedrum the Creeper",confidence="published-forever-dungeon-guide"},
    {id=11730,actor="Eviscerator",confidence="published-forever-dungeon-guide"},
    {id=11731,actor="Anub'shiah",confidence="published-forever-dungeon-guide"},
    {id=12952,actor="Gyth",confidence="published-forever-dungeon-guide"},
    {id=16669,actor="Gyth",confidence="published-forever-dungeon-guide"},
    {id=16695,actor="Solakar Flamewreath",confidence="published-forever-dungeon-guide"},
    {id=18760,actor="Death Knight Darkreaver",confidence="forever-item-historic-loot-reference"},
    {id=22242,actor="Verek",confidence="published-forever-dungeon-guide"},
    {id=23169,actor="Scorn",confidence="published-forever-beta-class-guide"},
}) do
    local item=assert(addon.ItemCatalog[r.id],"Missing role item "..r.id)
    local ev=assert(item.acquisitionResearch,"No role evidence "..r.id)
    assert(ev.confidence==r.confidence,"Confidence mismatch "..r.id)
    assert(type(ev.sourceURL)=="string" and ev.sourceURL~="",
        "Evidence must retain source URL "..r.id)
    assert(ev.sourceSummary:find(r.actor,1,true)
        and ev.sourceSummary:find("live drop unverified",1,true),
        "Reference must retain named role and loot caveat "..r.id)
    assert(not followUpCSV:find("\n"..r.id..",",1,true),
        "Role-reviewed item remains in identity queue "..r.id)
    assert(dungeonDropCSV:find("\n"..r.id..",",1,true),
        "Role-reviewed item disappeared from dungeon scope "..r.id)
end
for _,r in ipairs({
    {id=11945},
    {id=11946},
}) do
    local item=assert(addon.ItemCatalog[r.id])
    local ev=assert(item.acquisitionResearch)
    assert(ev.confidence=="historic-container-reference")
    assert(ev.sourceSummary:find("Container lead:",1,true)
        and ev.sourceSummary:find("Forever coffer loot unverified",1,true))
    assert(not ev.sourceSummary:find("Boss:",1,true)
        and not ev.sourceSummary:find("Enemy:",1,true))
    assert(followUpCSV:find("\n"..r.id..",",1,true),
        "Unverified coffer contents must stay queued "..r.id)
end
for _,id in ipairs({10801,14525,23173,273044}) do
    assert(addon.ItemCatalog[id],"Unresolved item missing "..id)
    assert(followUpCSV:find("\n"..id..",",1,true),
        "Do not promote historic NPC item mapping to Forever drop "..id)
end
local vendorCSV=assert(io.open(root.."/docs/source-audit-1-60/reconciliation-20261109/recipe_vendor_book_checks.csv")):read("*a")
assert(vendorCSV:find("Aisarra Nightmeadow",1,true),
    "Named vendor reference must be preserved with live-stock caveat")
local recipeReconciliation=assert(io.open(root.."/docs/source-audit-1-60/reconciliation-20261109/README.md")):read("*a")
assert(recipeReconciliation:find("**954**",1,true),
    "All 68 vendor books and 886 trainer-labelled books need verification")
assert(recipeReconciliation:find("**552**",1,true)
    and recipeReconciliation:find("**24**",1,true)
    and recipeReconciliation:find("**6**",1,true)
    and recipeReconciliation:find("rare-boss: 12",1,true)
    and recipeReconciliation:find("container-lead: 2",1,true)
    and recipeReconciliation:find("trash: 137",1,true),
    "Crafted-pattern records must not masquerade as equipment drops")
-- Checkpoint 6B: specific book research is actionable inside both views,
-- without claiming stock, trainer teaching, or a finished-item dungeon drop.
local reviewedBooks={
    {250515,251367,45},{250516,251368,45},{250517,251369,45},
    {250510,251362,80},{250512,251364,80},{250507,251359,85},
    {250529,251381,95},{250532,251384,95},{250522,251374,110},
    {250527,251379,125},
}
for _,r in ipairs(reviewedBooks) do
    local item=assert(addon.ItemCatalog[r[1]])
    local ev=assert(item.acquisitionResearch)
    assert(ev.recipeReference and ev.confidence=="published-forever-recipe-vendor-reference")
    assert(item.recipePatternItemID==r[2] and item.recipeLearnMethod=="pattern")
    local text=addon:GetAcquisitionSummary(item)
    assert(text:find("Plans #"..r[2],1,true)
        and text:find("Blacksmithing "..r[3],1,true)
        and text:find("Alliance Stondry Darkhammer",1,true)
        and text:find("Horde Gor'mak",1,true)
        and text:find("Three Corners",1,true)
        and text:find("Crossroads",1,true)
        and text:find("30 Merchant's Favor",1,true)
        and text:find("live stock/gates unverified",1,true))
    assert(item.acquisitionConfidence=="published-client-recipe",
        "Publication must not promote original item confidence")
    assert(item.professionSkillRequired==nil,
        "Book tooltip learning requirement must not mutate crafting/equip gates")
    assert(not text:find("Boss:",1,true),"Finished craft must not become boss loot")
end
assert(addon.ItemCatalog[250510].sourceSummary:find("Player report:",1,true))
assert(addon.ItemCatalog[250512].sourceSummary:find("enemy unspecified",1,true))
assert(addon.ItemCatalog[250529].sourceSummary:find("Verdan the Everliving",1,true))
-- Exercise the real detailed-guide formatter with the researched source.
local ui=assert(io.open(root.."/UI.lua")):read("*a")
local describeBody=assert(ui:match("local function Describe%(gear, previewMode%)%s*(.-)\nend"))
local describe=assert(load("return function(gear,previewMode)\n"..describeBody.."\nend",
    "Describe", "t", {type=type,tostring=tostring,table=table}))()
local detailed=describe(addon.ItemCatalog[250515],false)
assert(detailed:find("Stondry Darkhammer",1,true)
    and detailed:find("Gor'mak",1,true) and detailed:find("unverified",1,true))
-- An existing observed/manual description retains display precedence.
local fixture={ItemCatalog={[250515]={sourceSummary="Original observation",
    acquisitionConfidence="observed",reagents={{itemID=2840,amount=12}},classMask=1}},
    AcquisitionEvidenceIndex=addon.AcquisitionEvidenceIndex}
assert(loadfile(root.."/AcquisitionEvidence.lua"))("GetGear",fixture)
assert(fixture.ItemCatalog[250515].sourceSummary=="Original observation")
assert(fixture.ItemCatalog[250515].acquisitionConfidence=="observed"
    and fixture.ItemCatalog[250515].classMask==1
    and fixture.ItemCatalog[250515].reagents[1].amount==12)

-- Checkpoint 6C: all six early Tailoring slots retain exact book IDs,
-- item-specific skill and usable directions for both factions.
local tailoringBooks={
    {253889,253890,60},
    {253891,253892,60},
    {253893,253894,60},
    {253895,253896,60},
    {253897,253898,60},
    {253899,253900,60},
    {253913,253914,75},
    {253915,253916,75},
    {253917,253918,75},
    {253919,253920,75},
    {253921,253922,75},
    {253923,253924,75},
    {253925,253926,85},
    {253927,253928,85},
    {253929,253930,85},
    {253931,253932,85},
    {253933,253934,85},
    {253935,253936,85},
    {253949,253950,100},
    {253951,253952,100},
    {253953,253954,100},
    {253955,253956,100},
    {253957,253958,100},
    {253959,253960,100},
    {253961,253962,110},
    {253963,253964,110},
    {253965,253966,110},
    {253967,253968,110},
    {253969,253970,110},
    {253971,253972,110},
    {253987,253988,125},
    {253989,253990,125},
    {253991,253992,125},
    {253993,253994,125},
    {253995,253996,125},
    {253997,253998,125},
}
for _,r in ipairs(tailoringBooks) do
    local item=assert(addon.ItemCatalog[r[1]])
    local text=addon:GetAcquisitionSummary(item)
    assert(item.recipePatternItemID==r[2] and item.recipeLearnMethod=="pattern")
    assert(text:find("Pattern:",1,true) and text:find("#"..r[2],1,true)
        and text:find("Tailoring "..r[3],1,true)
        and text:find("Alliance Mivin Shadowweave",1,true)
        and text:find("Horde Jim'bek",1,true)
        and text:find("30 Merchant's Favor",1,true)
        and text:find("live stock/gates unverified",1,true))
    assert(item.acquisitionResearch.confidence=="published-forever-recipe-vendor-reference")
    assert(not text:find("Boss:",1,true))
    assert(describe(item,false):find("Jim'bek",1,true),"Guide lost Horde source")
end

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
