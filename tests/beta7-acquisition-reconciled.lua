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

-- Checkpoint 6D: all researched Leatherworking books keep vendor and
-- drop alternatives distinct from the finished crafted equipment.
local leatherBooks={
    {252428,252765,60},
    {252429,252766,60},
    {252430,252767,60},
    {252431,252768,60},
    {252432,252769,60},
    {252433,252770,60},
    {252497,252780,75},
    {252499,252782,75},
    {252440,252787,85},
    {252442,252789,85},
    {252444,252791,85},
    {252505,252799,100},
    {252447,252800,100},
    {252506,252802,100},
    {252451,252808,110},
    {252516,252820,125},
    {252517,252821,125},
    {252458,252823,125},
    {252518,252824,125},
}
for _,r in ipairs(leatherBooks) do
    local item=assert(addon.ItemCatalog[r[1]])
    local text=addon:GetAcquisitionSummary(item)
    assert(item.recipePatternItemID==r[2] and item.recipeLearnMethod=="pattern")
    assert(text:find("#"..r[2],1,true) and text:find("Leatherworking "..r[3],1,true)
        and text:find("Alliance Daniel Stitchsong",1,true)
        and text:find("Horde Pawani",1,true)
        and text:find("30 Merchant's Favor",1,true)
        and text:find("live stock/gates unverified",1,true))
    assert(describe(item,false):find("Pawani",1,true))
end
local bookDrop=assert(addon.ItemCatalog[252497]) -- Totemic Gloves
local bookDetail=describe(bookDrop,false)
assert(bookDetail:find("Published book-drop references",1,true)
    and bookDetail:find("The Deadmines: Sneed",1,true)
    and bookDetail:find("Fel Steed",1,true) and bookDetail:find("Ragefire Chasm",1,true)
    and bookDetail:find("live unverified; no drop-rate claim",1,true))
assert(bookDrop.sourceType=="Leatherworking" and bookDrop.profession=="Leatherworking")
assert(not addon:GetAcquisitionSummary(bookDrop):find("Boss:",1,true))
assert(describe(addon.ItemCatalog[252505],false):find("Player report: Lord Cobrahn",1,true))
local beltDetail=addon.ItemCatalog[252428].acquisitionResearch.details or ""
assert(not beltDetail:find("Published book-drop references",1,true)
    and not beltDetail:find("Lord Cobrahn",1,true)
    and not beltDetail:find("Sneed",1,true),
    "A published drop for a glove must not spread to the belt family")
assert(beltDetail:find("Waylaid Crate",1,true),"Shared Favor directions remain useful for belts")

-- Checkpoint 6E: item-specific costs and reputation must not leak
-- between profession families or turn a publication into live stock.
for _,r in ipairs({{249392,249482},{249393,249483},{249394,249484}}) do
    local item=assert(addon.ItemCatalog[r[1]])
    local text=addon:GetAcquisitionSummary(item)
    assert(item.recipePatternItemID==r[2] and text:find("Enchanting 140",1,true)
        and text:find("Alliance Alynsia",1,true) and text:find("Horde Beneris",1,true)
        and text:find("45 Merchant's Favor",1,true)
        and text:find("live stock/gates unverified",1,true))
    assert(not text:find("Friendly reputation",1,true),"Do not infer a gate from Engineering")
end
for _,r in ipairs({{280306,280321},{280307,280322},{280308,280323}}) do
    local item=assert(addon.ItemCatalog[r[1]])
    local text=addon:GetAcquisitionSummary(item)
    assert(item.recipePatternItemID==r[2] and text:find("Engineering 175",1,true)
        and text:find("Alliance Fritz Fizzle",1,true) and text:find("Horde Fizzlefuse",1,true)
        and text:find("180 Merchant's Favor",1,true)
        and text:find("Friendly reputation",1,true)
        and text:find("Horde: Durotar Supply and Logistics",1,true)
        and text:find("live stock/gates unverified",1,true))
    assert(describe(item,false):find("does not name its faction",1,true))
end

-- Checkpoint 6F: book quest routes retain distinct starts/turn-ins,
-- reward choices and access gates without restricting the gear catalogue.
for _,r in ipairs({{3471,3609},{6468,6476},{6709,6710},{6731,6735},
                   {7913,7978},{7914,7979},{7915,7980},{277672,277673}}) do
    local item=assert(addon.ItemCatalog[r[1]])
    local text=addon:GetAcquisitionSummary(item)
    assert(item.recipePatternItemID==r[2] and text:find("#"..r[2],1,true))
    assert(item.acquisitionResearch.confidence=="published-forever-quest-book-reference")
    assert(text:find("current availability/prerequisites unverified",1,true))
end
local copperQuest=describe(addon.ItemCatalog[3471],false)
assert(copperQuest:find("Supplying the Front",1,true)
    and copperQuest:find("start Tormus Deepforge, Ironforge",1,true)
    and copperQuest:find("Thorvald Deepforge, Loch Modan",1,true)
    and copperQuest:find("generic drop route",1,true))
local deviate=addon.ItemCatalog[6468]
assert(deviate.acquisitionConfidence=="reported","Original report confidence must survive")
assert(describe(deviate,false):find("a choice: select this book",1,true))
local bootsQuest=describe(addon.ItemCatalog[277672],false)
assert(bootsQuest:find("The Quarry's Smith",1,true)
    and bootsQuest:find("This Is Spinal Axe",1,true)
    and bootsQuest:find("Frast Dokner, Dun Morogh",1,true)
    and bootsQuest:find("Ug'thok, Orgrimmar",1,true))
local shoulders=addon.ItemCatalog[7913]
assert(describe(shoulders,false):find("minimum quest level 32",1,true)
    and describe(shoulders,false):find("4 Bronze Battleaxes and 4 Bronze Warhammers",1,true))
assert(shoulders.requiredLevel~=32,"Quest access must not become the gear equip gate")
assert(not addon:GetAcquisitionSummary(shoulders):find("Vendor:",1,true))

-- Checkpoint 6G: exact non-Favor sellers, limited stock, map references,
-- reputation gates and unavailable-book conflicts stay distinct.
local otherTailoring={
    {6240,6270,35},
    {6242,6272,45},
    {6263,6274,75},
    {6264,6275,90},
    {4319,7114,120},
    {4322,14630,130},
    {277046,276982,175},
    {277047,276983,175},
    {277054,276990,175},
    {277055,276991,175},
}
for _,r in ipairs(otherTailoring) do
    local item=assert(addon.ItemCatalog[r[1]])
    assert(item.recipePatternItemID==r[2])
    local text=item.acquisitionResearch.sourceSummary
    assert(text:find("Tailoring "..r[3],1,true)
        and text:find("live stock/access unverified",1,true))
    assert(describe(item,false):find("published map",1,true))
end
local blue=describe(addon.ItemCatalog[6240],false)
assert(blue:find("Tharynn Bouden",1,true) and blue:find("Wrahk",1,true)
    and blue:find("Borya",1,true) and blue:find("limited-stock table reference",1,true))
assert(not addon:GetAcquisitionSummary(addon.ItemCatalog[6240]):find("Friendly",1,true))
for _,id in ipairs({277046,277047}) do
    assert(addon:GetAcquisitionSummary(addon.ItemCatalog[id]):find("Friendly with Earthen Ring",1,true))
end
for _,id in ipairs({277054,277055}) do
    assert(addon:GetAcquisitionSummary(addon.ItemCatalog[id]):find("Friendly with Kirin Tor",1,true))
end
for _,id in ipairs({210781,215365,215366}) do
    local item=assert(addon.ItemCatalog[id],"Keep catalogue identity pending stronger evidence")
    assert(item.acquisitionResearch.confidence=="published-forever-availability-conflict")
    assert(item.acquisitionResearch.sourceSummary:find("unavailable to players",1,true))
    assert(not item.recipePatternItemID,
        "Unavailable book warning must not become a new required learning gate")
    assert(not item.acquisitionResearch.sourceSummary:find("vendor references:",1,true))
end

-- Checkpoint 6H: all 25 non-Favor Leatherworking books preserve named
-- sellers, exact IDs, reputation and alternate-drop/location caveats.
local otherLeather={
    {5780,5786,65},
    {5781,5787,70},
    {5782,5788,145},
    {5963,5973,145},
    {6467,6475,80},
    {7284,7290,95},
    {7349,7361,110},
    {7352,7362,110},
    {4255,7613,130},
    {4455,13287,140},
    {4456,13288,140},
    {18948,18949,130},
    {20575,20576,75},
    {252424,252761,35},
    {252425,252762,35},
    {252426,252763,35},
    {252461,252830,150},
    {277042,276978,175},
    {277043,276979,175},
    {277044,276980,175},
    {277045,276981,175},
    {277050,276986,175},
    {277051,276987,175},
    {277052,276988,175},
    {277053,276989,175},
}
for _,r in ipairs(otherLeather) do
    local item=assert(addon.ItemCatalog[r[1]])
    assert(item.recipePatternItemID==r[2])
    assert(item.acquisitionResearch.sourceSummary:find("Leatherworking "..r[3],1,true))
    assert(describe(item,false):find("live stock",1,true))
end
assert(describe(addon.ItemCatalog[5780],false):find("Defias Squallshaper",1,true))
assert(describe(addon.ItemCatalog[20575],false):find("Black Dragon Whelp",1,true))
assert(describe(addon.ItemCatalog[252424],false):find("Granny Finespindle",1,true))
assert(not describe(addon.ItemCatalog[252424],false):find("Defias Squallshaper",1,true),
    "Do not copy a Murloc Scale Belt drop onto new Slippers")
local kalldan=describe(addon.ItemCatalog[6467],false)
assert(kalldan:find("Wailing Caverns area",1,true)
    and kalldan:find("continent-level Kalimdor",1,true)
    and kalldan:find("exact position remains unverified",1,true))
for _,id in ipairs({277042,277043,277044,277045}) do
    assert(addon.ItemCatalog[id].acquisitionResearch.sourceSummary:find("Friendly with Earthen Ring",1,true))
end
for _,id in ipairs({277050,277051,277052,277053}) do
    assert(addon.ItemCatalog[id].acquisitionResearch.sourceSummary:find("Friendly with Kirin Tor",1,true))
end

-- Checkpoint 6I: remaining low-level vendor books, per-seller locations,
-- and an in-guide quest-supply reference remain informational.
for _,r in ipairs({{3851,10858,130},{3849,12162,135},{277040,276976,175},
                   {277041,276977,175},{277048,276984,175},{277049,276985,175},
                   {4372,13309,120}}) do
    local item=assert(addon.ItemCatalog[r[1]])
    assert(item.recipePatternItemID==r[2])
    assert(item.acquisitionResearch.sourceSummary:find(tostring(r[3]),1,true))
    assert(describe(item,false):find("listed price",1,true)
        and describe(item,false):find("live stock",1,true))
end
local maul=describe(addon.ItemCatalog[3851],false)
assert(maul:find("Jannos Ironwill",1,true) and maul:find("Muuran",1,true)
    and maul:find("Jazzrik",1,true) and maul:find("Badlands",1,true))
assert(describe(addon.ItemCatalog[4372],false):find("Fradd Swiftgear",1,true)
    and describe(addon.ItemCatalog[4372],false):find("Jinky Twizzlefixxit",1,true))
assert(describe(addon.ItemCatalog[7915],false):find("Related quest supply: Solid Iron Maul plans",1,true))
for _,id in ipairs({277040,277041}) do
    assert(addon.ItemCatalog[id].acquisitionResearch.sourceSummary:find("Friendly with Earthen Ring",1,true))
end
for _,id in ipairs({277048,277049}) do
    assert(addon.ItemCatalog[id].acquisitionResearch.sourceSummary:find("Friendly with Kirin Tor",1,true))
end

-- Checkpoint 6J: exact dungeon book loot references must not become
-- finished-item boss loot or spread between superficially similar patterns.
local dungeonBooks={
    {253901,253902,75},
    {253903,253904,75},
    {253905,253906,75},
    {253907,253908,75},
    {253909,253910,75},
    {253911,253912,75},
    {253937,253938,100},
    {253939,253940,100},
    {253941,253942,100},
    {253943,253944,100},
    {253947,253948,100},
    {253975,253976,125},
    {253977,253978,125},
    {253979,253980,125},
    {253981,253982,125},
    {253983,253984,125},
    {253985,253986,125},
}
for _,r in ipairs(dungeonBooks) do
    local item=assert(addon.ItemCatalog[r[1]])
    assert(item.recipePatternItemID==r[2])
    assert(item.acquisitionResearch.confidence=="published-forever-book-drop-reference")
    local detail=item.acquisitionResearch.details
    assert(detail:find("no drop-rate claim",1,true)
        and detail:find("not drops of the finished crafted equipment",1,true))
    assert(not item.acquisitionResearch.sourceSummary:find("Boss:",1,true))
    assert(item.profession=="Tailoring" and type(item.reagents)=="table")
    assert(describe(item,false):find("Published recipe-book drop references",1,true))
end
local pristineGown=addon.ItemCatalog[253901].acquisitionResearch.details
local silkyGown=addon.ItemCatalog[253903].acquisitionResearch.details
local flameGown=addon.ItemCatalog[253905].acquisitionResearch.details
assert(pristineGown:find("Kresh",1,true) and not pristineGown:find("Lady Anacondra",1,true))
assert(silkyGown:find("Lady Anacondra",1,true) and not silkyGown:find("Kresh",1,true))
assert(not flameGown:find("Wailing Caverns",1,true),"Do not infer every gown drops in WC")
assert(addon.ItemCatalog[253977].acquisitionResearch.details:find("Dark Iron Ambassador",1,true))
assert(not addon.ItemCatalog[253979].acquisitionResearch.details:find("Dark Iron Ambassador",1,true))

-- Checkpoint 6K: exact reputation books, contested current access, no inferred gear gates.
local nightclawBooks={
    {276992,276928,60,"Honored"},
    {276993,276929,50,"Friendly"},
    {276994,276930,55,"Friendly"},
    {276995,276931,50,"Friendly"},
    {276996,276932,60,"Honored"},
    {276997,276933,55,"Friendly"},
    {277016,276952,60,"Honored"},
    {277017,276953,50,"Friendly"},
    {277018,276954,55,"Friendly"},
    {277019,276955,50,"Friendly"},
    {277020,276956,60,"Honored"},
    {277021,276957,55,"Friendly"},
    {276998,276934,60,"Honored"},
    {276999,276935,50,"Friendly"},
    {277000,276936,55,"Friendly"},
    {277001,276937,50,"Friendly"},
    {277002,276938,60,"Honored"},
    {277003,276939,55,"Friendly"},
    {277004,276940,60,"Honored"},
    {277005,276941,50,"Friendly"},
    {277006,276942,55,"Friendly"},
    {277007,276943,50,"Friendly"},
    {277008,276944,60,"Honored"},
    {277009,276945,55,"Friendly"},
    {277022,276958,60,"Honored"},
    {277023,276959,50,"Friendly"},
    {277024,276960,55,"Friendly"},
    {277025,276961,50,"Friendly"},
    {277026,276962,60,"Honored"},
    {277027,276963,55,"Friendly"},
    {277028,276964,60,"Honored"},
    {277029,276965,50,"Friendly"},
    {277030,276966,55,"Friendly"},
    {277031,276967,50,"Friendly"},
    {277032,276968,60,"Honored"},
    {277033,276969,55,"Friendly"},
    {277010,276946,60,"Honored"},
    {277011,276947,50,"Friendly"},
    {277012,276948,55,"Friendly"},
    {277013,276949,50,"Friendly"},
    {277014,276950,60,"Honored"},
    {277015,276951,55,"Friendly"},
    {277034,276970,60,"Honored"},
    {277035,276971,50,"Friendly"},
    {277036,276972,55,"Friendly"},
    {277037,276973,50,"Friendly"},
    {277038,276974,60,"Honored"},
    {277039,276975,55,"Friendly"},
}
for _,r in ipairs(nightclawBooks) do
    local item=assert(addon.ItemCatalog[r[1]])
    assert(item.recipePatternItemID==r[2])
    local research=assert(item.acquisitionResearch)
    assert(research.confidence=="published-forever-recipe-vendor-reference")
    assert(research.sourceSummary:find(r[4].." with Nightclaw Druids",1,true))
    assert(research.sourceSummary:find("shop access disputed; live unverified",1,true))
    local text=describe(item,false)
    assert(text:find("Nightclaw Cavern",1,true) and text:find("63.8, 36.0",1,true))
    assert(text:find("Unnerving Silence (#94484)",1,true)
        and text:find("do not assume every race",1,true))
    assert(text:find("No new race, class or equip restriction",1,true))
end
assert(addon.ItemCatalog[276992].acquisitionResearch.sourceSummary:find("Honored",1,true))
assert(not addon.ItemCatalog[276993].acquisitionResearch.sourceSummary:find("Honored",1,true),
    "Do not copy chest/leg reputation gates onto wrist books")

-- Checkpoint 6L: generic-drop book references are not exclusive live farms.
local genericBooks={
    {3481,2882},
    {3490,2883},
    {3492,3608},
    {3484,3611},
    {3485,3612},
    {3850,3866},
    {3852,3867},
    {3840,3870},
    {3841,3871},
    {3843,3872},
    {5541,5543},
    {2869,5578},
    {10423,10424},
    {250483,251335},
    {250484,251336},
    {250485,251337},
    {250486,251338},
    {250487,251339},
    {250533,251385},
    {250534,251386},
    {250602,251454},
    {250603,251455},
    {250604,251456},
    {2307,2406},
    {2312,2408},
    {2317,2409},
    {4250,4294},
    {4252,4296},
    {4254,4297},
    {4258,4298},
    {4256,4299},
    {5958,5972},
    {7280,7288},
    {4248,7360},
    {7358,7363},
    {7359,7364},
    {7373,7449},
    {7375,7450},
    {252449,252804},
    {2572,2598},
    {2585,2601},
    {4313,4345},
    {4317,4349},
    {4321,4350},
    {4323,4351},
    {4325,4352},
    {5770,5773},
    {6239,6271},
    {7065,7090},
    {7049,7091},
    {7047,7092},
    {10048,10316},
    {253945,253946},
    {4383,4412},
}
for _,r in ipairs(genericBooks) do
    local item=assert(addon.ItemCatalog[r[1]])
    assert(item.recipePatternItemID==r[2])
    local research=assert(item.acquisitionResearch)
    assert(research.confidence=="published-forever-book-drop-reference")
    assert(research.sourceSummary:find("live unverified; non-exhaustive",1,true))
    local detail=research.details
    assert(detail:find("not finished crafted gear",1,true)
        and detail:find("No confirmed live drop",1,true))
    assert(not detail:find("Drop Chance:",1,true) and not detail:find("%%"))
end
local arcana=addon.ItemCatalog[5770].acquisitionResearch
assert(arcana.sourceSummary:find("Defias Enchanter",1,true)
    and arcana.sourceSummary:find("Dark Strand Voidcaller",1,true))
assert(arcana.details:find("not a single waypoint",1,true))
local linen=addon.ItemCatalog[2572].acquisitionResearch.details
assert(linen:find("200 NPC rows and may be truncated",1,true))
assert(not linen:find("Defias Enchanter",1,true),"Do not copy Arcana's targeted source onto Linen")
local pearly=addon.ItemCatalog[253945].acquisitionResearch.details
assert(pearly:find("Shadow Charger",1,true) and pearly:find("Lady Sarevess",1,true))
assert(not pearly:find("Kresh",1,true),"Do not spread another Filigreed book's NPCs")

-- Checkpoint 6M: trainer alternatives must not acquire a fabricated required book ID.
local trainerAlternatives={250620,250621,250482,250556,250557,250558,250559,250560,253885,253887,254001,254003,254005,254007,254009,254011}
for _,id in ipairs(trainerAlternatives) do
    local item=assert(addon.ItemCatalog[id])
    assert(item.recipePatternItemID==nil,"Unknown physical book origin must not add a required book ID")
    assert(item.acquisitionResearch.confidence=="published-forever-trainer-spell-reference")
    assert(item.acquisitionResearch.sourceSummary:find("not established required",1,true))
    local detail=item.acquisitionResearch.details
    assert(detail:find("Book existence does not establish",1,true)
        and detail:find("live trainer inventory",1,true))
end
local newlyLocatedBooks={{250500,251352},{250501,251353},{250502,251354},{252501,252793},{252445,252794},{252503,252797},{253999,254000}}
for _,r in ipairs(newlyLocatedBooks) do
    local item=assert(addon.ItemCatalog[r[1]])
    assert(item.recipePatternItemID==r[2])
    assert(item.acquisitionResearch.details:find("not drops of the finished crafted gear",1,true))
end
local protector=addon.ItemCatalog[250500].acquisitionResearch.details
local acolyte=addon.ItemCatalog[250501].acquisitionResearch.details
assert(protector:find("Dextren Ward",1,true) and not acolyte:find("Dextren Ward",1,true))
assert(acolyte:find("Bazil Thredd",1,true) and not protector:find("Bazil Thredd",1,true))
assert(addon.ItemCatalog[253999].acquisitionResearch.details:find("Gravelsnout Surveyor",1,true))

-- Checkpoint 6N: cost is not a reputation rule; exact rank/name/ID exceptions.
local highFavor={
    {250561,251413,90,"Honored"},
    {250562,251414,90,"Honored"},
    {250563,251415,90,"Honored"},
    {250564,251416,90,"Honored"},
    {250565,251417,90,"Honored"},
    {250566,251418,60,"Friendly"},
    {250567,251419,60,"Friendly"},
    {250568,251420,60,"Friendly"},
    {250569,251421,60,"Friendly"},
    {250570,251422,60,"Friendly"},
    {250571,251423,90,"Honored"},
    {250572,251424,90,"Honored"},
    {250573,251425,90,"Honored"},
    {250575,251427,90,"Honored"},
    {250576,251428,60,"Friendly"},
    {250577,251429,60,"Friendly"},
    {250578,251430,60,"Friendly"},
    {250579,251431,60,"Friendly"},
    {250580,251432,60,"Friendly"},
    {250581,251433,90,"Honored"},
    {250582,251434,90,"Honored"},
    {250583,251435,90,"Honored"},
    {250584,251436,90,"Honored"},
    {250585,251437,90,"Honored"},
    {250595,251447,120,"Honored"},
    {250596,251448,120,"Honored"},
    {250597,251449,120,"Honored"},
    {250613,251465,90,"Honored"},
    {250614,251466,90,"Honored"},
    {250619,251471,120,"Honored"},
    {252524,252836,60,"Friendly"},
    {252525,252837,60,"Friendly"},
    {252526,252838,60,"Friendly"},
    {252527,252839,60,"Friendly"},
    {252528,252840,60,"Friendly"},
    {252529,252841,60,"Friendly"},
    {252530,252842,60,"Friendly"},
    {252534,252848,60,"Friendly"},
    {252535,252849,60,"Friendly"},
    {252536,252850,60,"Friendly"},
    {252537,252851,60,"Friendly"},
    {252538,252852,60,"Friendly"},
    {252539,252853,90,"Honored"},
    {252540,252854,90,"Honored"},
    {252541,252855,90,"Honored"},
    {252542,252856,90,"Honored"},
    {252543,252857,90,"Honored"},
    {252468,252860,90,"Honored"},
    {252469,252861,90,"Honored"},
    {252470,252862,90,"Honored"},
    {252471,252863,90,"Honored"},
    {252472,252864,90,"Honored"},
    {252473,252872,90,"Honored"},
    {252474,252873,90,"Honored"},
    {252475,252874,90,"Honored"},
    {252476,252875,90,"Honored"},
    {252477,252876,90,"Honored"},
    {252566,252900,60,"Friendly"},
    {252567,252901,60,"Friendly"},
    {252568,252902,60,"Friendly"},
    {252569,252903,60,"Friendly"},
    {252570,252904,90,"Honored"},
    {252571,252905,90,"Honored"},
    {252572,252906,90,"Honored"},
    {252573,252907,90,"Honored"},
    {252576,252910,90,"Honored"},
    {252577,252911,90,"Honored"},
    {252578,252912,90,"Honored"},
    {252579,252913,90,"Honored"},
    {252588,252922,90,"Honored"},
    {252589,252923,90,"Honored"},
    {252590,252924,90,"Honored"},
    {252591,252925,90,"Honored"},
    {254023,254024,60,"Friendly"},
    {254025,254026,60,"Friendly"},
    {254027,254028,60,"Friendly"},
    {254029,254030,60,"Friendly"},
    {254031,254032,60,"Friendly"},
    {254049,254050,60,"Friendly"},
    {254051,254052,60,"Friendly"},
    {254053,254054,60,"Friendly"},
    {254055,254056,60,"Friendly"},
    {254057,254058,60,"Friendly"},
    {254059,254060,60,"Friendly"},
    {254061,254062,60,"Friendly"},
    {254063,254064,60,"Friendly"},
    {254065,254066,60,"Friendly"},
    {254067,254068,60,"Friendly"},
    {254069,254070,60,"Friendly"},
    {254071,254072,60,"Friendly"},
    {254081,254082,60,"Friendly"},
    {254083,254084,60,"Friendly"},
    {254085,254086,60,"Friendly"},
    {254087,254088,60,"Friendly"},
    {254089,254090,60,"Friendly"},
    {254091,254092,60,"Friendly"},
    {254107,254108,90,"Honored"},
    {254109,254110,90,"Honored"},
    {254111,254112,90,"Honored"},
    {254113,254114,90,"Honored"},
    {254115,254116,90,"Honored"},
    {254117,254118,90,"Honored"},
    {249441,249493,120,"Friendly"},
    {249442,249494,120,"Friendly"},
    {249443,249495,120,"Friendly"},
    {249453,249506,120,"Friendly"},
    {249454,249507,120,"Friendly"},
    {249455,249508,120,"Friendly"},
    {249456,249509,120,"Friendly"},
    {228175,249530,240,"Honored"},
    {228176,249532,240,"Honored"},
    {249385,249537,180,"Honored"},
    {260824,264234,360,"Honored"},
    {280310,280325,180,"Friendly"},
    {280311,280326,180,"Friendly"},
    {280312,280327,180,"Friendly"},
    {280313,280328,180,"Friendly"},
}
for _,r in ipairs(highFavor) do
    local item=assert(addon.ItemCatalog[r[1]])
    assert(item.recipePatternItemID==r[2])
    local text=item.acquisitionResearch.sourceSummary
    assert(text:find(r[3].." Merchant's Favor",1,true))
    assert(text:find("Tooltip: "..r[4],1,true))
    assert(text:find("live stock/gates unverified",1,true))
    assert(item.acquisitionResearch.details:find("No gate is inferred from cost",1,true))
end
assert(addon.ItemCatalog[280310].acquisitionResearch.sourceSummary:find("Tooltip: Friendly",1,true))
assert(addon.ItemCatalog[249385].acquisitionResearch.sourceSummary:find("Tooltip: Honored",1,true))
for _,id in ipairs({280306,280307,280308}) do
    local text=addon.ItemCatalog[id].acquisitionResearch.details
    assert(text:find("Friendly Durotar Supply and Logistics",1,true))
    assert(text:find("not live purchase verification",1,true))
end

-- Checkpoint 6O: item starts, objective costs and alternate faction quests.
local higherQuestBooks={{7916,7981},{7917,7982},{7926,7983},{7927,7984},{7928,7985},{8210,8403},{8211,8404},{8214,8405},{8213,8406},{8212,8407},{9366,9367},{10025,10463},{12428,12687},{12424,12688},{12425,12690},{12628,12696},{12631,12699},{12426,12700},{12427,12701},{12422,12705},{12429,12715},{12620,12725},{12619,12726},{12618,12727},{12774,12821},{12776,12824},{12777,12825},{17193,18592},{252480,252883}}
for _,r in ipairs(higherQuestBooks) do
    local item=assert(addon.ItemCatalog[r[1]])
    assert(item.recipePatternItemID==r[2])
    assert(item.acquisitionResearch.confidence=="published-forever-quest-book-reference")
    assert(item.acquisitionResearch.details:find("These references track recipe books",1,true))
    assert(item.acquisitionResearch.details:find("prerequisites",1,true))
end
assert(addon.ItemCatalog[8210].acquisitionResearch.details:find("Pratt McGrubben",1,true))
assert(addon.ItemCatalog[8210].acquisitionResearch.details:find("Jangdor Swiftstrider",1,true))
assert(addon.ItemCatalog[252480].acquisitionResearch.details:find("select this exact book",1,true))
assert(addon.ItemCatalog[252480].acquisitionResearch.details:find("Friendly Gelkis Clan Centaur",1,true))
assert(addon.ItemCatalog[252480].acquisitionResearch.details:find("Do not invent a map pin",1,true))
assert(addon.ItemCatalog[12620].acquisitionResearch.details:find("item #18771",1,true))
assert(addon.ItemCatalog[12620].acquisitionResearch.details:find("Blacksmithing 300",1,true))
assert(addon.ItemCatalog[12620].acquisitionResearch.details:find("Black Guard Swordsmith",1,true))
assert(addon.ItemCatalog[12620].acquisitionResearch.details:find("Urok Doomhowl",1,true))
assert(addon.ItemCatalog[17193].acquisitionResearch.details:find("item #18628",1,true))
assert(addon.ItemCatalog[17193].acquisitionResearch.details:find("Sulfuron Ingot",1,true))
assert(addon.ItemCatalog[12428].acquisitionResearch.details:lower():find("20 x thorium bar",1,true))
assert(addon.ItemCatalog[12422].acquisitionResearch.details:lower():find("60 x thorium bar",1,true))

assert(addon.ItemCatalog[12631].acquisitionResearch.details:find("BOTH plans #12699 and finished Fiery Plate Gauntlets #12631",1,true))
assert(addon.ItemCatalog[12631].sourceType=="Blacksmithing", "Preserve crafted facts alongside direct quest alternative")

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
