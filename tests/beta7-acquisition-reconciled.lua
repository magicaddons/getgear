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

-- Checkpoint 6P: exact vendor versions, specialisations and source-specific gates.
local highVendorBooks={{3837,6047},{7924,7995},{7947,8030},{3853,12163},{3855,12164},{12773,12819},{12775,12823},{19051,19203},{19057,19205},{19690,19776},{19691,19777},{19692,19778},{19693,19779},{19694,19780},{19695,19781},{250538,251390},{250606,251458},{250608,251460},{250616,251468},{275622,275598},{275623,275599},{275624,275600},{275625,275601},{275626,275602},{275627,275603},{5783,5789},{7386,7451},{8187,8385},{8192,8409},{4262,14635},{15077,15724},{15083,15725},{15045,15726},{15074,15729},{15061,15734},{15067,15735},{15071,15740},{15057,15741},{15048,15751},{15094,15756},{15063,15758},{15050,15759},{15080,15762},{18238,18239},{19044,19326},{19049,19327},{19052,19328},{19685,19769},{19686,19770},{19687,19771},{19688,19772},{19689,19773},{15065,20254},{252552,252877},{252599,252933},{276538,276542},{276539,276543},{276540,276544},{276541,276545},{7063,7088},{10030,10318},{13858,14469},{13863,14481},{14107,14483},{13864,14488},{18486,18487},{19047,19215},{19050,19218},{19682,19764},{19683,19765},{19684,19766},{22758,22772},{22757,22773},{22756,22774},{254123,254124},{10011,254682},{275604,275580},{275605,275581},{275606,275582},{275607,275583},{275608,275584},{275609,275585},{18634,18652},{19999,20000},{19998,20001}}
for _,r in ipairs(highVendorBooks) do
    local item=assert(addon.ItemCatalog[r[1]])
    assert(item.recipePatternItemID==r[2])
    assert(item.acquisitionResearch.details:find("current inventory/access unverified",1,true))
end
local normalGloves=addon.ItemCatalog[8187]
local otherGloves=addon.ItemCatalog[217270]
assert(normalGloves.recipePatternItemID==8385)
assert(normalGloves.acquisitionResearch.confidence=="published-forever-recipe-vendor-reference")
assert(otherGloves.recipePatternItemID==nil,"Unavailable look-alike version must not gain a required book")
assert(otherGloves.acquisitionResearch.confidence=="published-forever-availability-conflict")
assert(not otherGloves.acquisitionResearch.details:find("Rock Elemental",1,true))
assert(addon.ItemCatalog[7947].acquisitionResearch.details:find("Spectral Essence",1,true))
assert(addon.ItemCatalog[15045].acquisitionResearch.details:find("Dragonscale Leatherworking",1,true))
assert(addon.ItemCatalog[15074].acquisitionResearch.details:find("Tribal Leatherworking",1,true))
assert(addon.ItemCatalog[276538].acquisitionResearch.details:find("Friendly Advice",1,true))
assert(addon.ItemCatalog[276539].acquisitionResearch.details:find("rank unspecified",1,true))
assert(addon.ItemCatalog[276540].acquisitionResearch.details:find("Shoulders specialisation",1,true))
assert(addon.ItemCatalog[276541].acquisitionResearch.details:find("Boots specialisation",1,true))
assert(addon.ItemCatalog[250538].acquisitionResearch.details:find("do not assume it bypasses",1,true))
assert(addon.ItemCatalog[250606].acquisitionResearch.details:find("2 Massive Iron Axes",1,true))
assert(addon.ItemCatalog[10011].acquisitionResearch.details:find("1 White Bandit Mask",1,true))
assert(addon.ItemCatalog[250608].acquisitionResearch.details:find("full quest page could not be retrieved",1,true))

-- Checkpoint 6Q: named reputation is not acquisition proof or a family rule.
local highRep={
    {13503,13517,"Exalted with Barkskin Burrow",true},
    {16980,17017,"Honored with Thorium Brotherhood",true},
    {16979,17018,"Friendly with Thorium Brotherhood",true},
    {19156,19219,"Honored with Thorium Brotherhood",true},
    {19165,19220,"Revered with Thorium Brotherhood",true},
    {16982,17022,"Friendly with Thorium Brotherhood",true},
    {16983,17023,"Friendly with Thorium Brotherhood",true},
    {16984,17025,"Honored with Thorium Brotherhood",true},
    {19149,19330,"Honored with Thorium Brotherhood",true},
    {19157,19331,"Revered with Thorium Brotherhood",true},
    {19162,19332,"Revered with Thorium Brotherhood",true},
    {19163,19333,"Revered with Thorium Brotherhood",true},
    {275610,275586,"Friendly with Cenarion Circle",false},
    {275611,275587,"Honored with Cenarion Circle",false},
    {275612,275588,"Honored with Cenarion Circle",false},
    {275613,275589,"Friendly with Cenarion Circle",false},
    {275614,275590,"Honored with Cenarion Circle",false},
    {275615,275591,"Honored with Cenarion Circle",false},
    {275616,275592,"Friendly with Cenarion Circle",false},
    {275617,275593,"Honored with Cenarion Circle",false},
    {275618,275594,"Honored with Cenarion Circle",false},
    {275619,275595,"Friendly with Cenarion Circle",false},
    {275620,275596,"Honored with Cenarion Circle",false},
    {275621,275597,"Honored with Cenarion Circle",false},
    {12625,12698,"Revered with Argent Dawn",true},
    {16989,17049,"Honored with Thorium Brotherhood",true},
    {17014,17051,"Friendly with Thorium Brotherhood",true},
    {17013,17052,"Revered with Thorium Brotherhood",true},
    {16988,17053,"Revered with Thorium Brotherhood",true},
    {17015,17059,"Honored with Thorium Brotherhood",true},
    {17016,17060,"Honored with Thorium Brotherhood",true},
    {19148,19206,"Honored with Thorium Brotherhood",true},
    {19164,19207,"Revered with Thorium Brotherhood",true},
    {19166,19208,"Revered with Thorium Brotherhood",true},
    {19167,19209,"Revered with Thorium Brotherhood",true},
    {19170,19210,"Exalted with Thorium Brotherhood",true},
    {19168,19211,"Exalted with Thorium Brotherhood",true},
    {19169,19212,"Exalted with Thorium Brotherhood",true},
    {20039,20040,"Exalted with Thorium Brotherhood",true},
    {22198,22219,"Revered with Cenarion Circle",true},
    {22191,22221,"Exalted with Cenarion Circle",true},
    {22669,22703,"Exalted with Argent Dawn",false},
    {22670,22704,"Revered with Argent Dawn",false},
    {22671,22705,"Revered with Hydraxian Waterlords",false},
    {250617,251469,"Revered with Timbermaw Hold",false},
    {250618,251470,"Revered with Timbermaw Hold",false},
}
for _,r in ipairs(highRep) do
    local item=assert(addon.ItemCatalog[r[1]])
    assert(item.acquisitionResearch.sourceSummary:find(r[3],1,true))
    if r[4] then
        assert(item.recipePatternItemID==r[2])
        assert(item.acquisitionResearch.details:find("listed price",1,true))
    else
        assert(addon.AcquisitionEvidenceIndex[r[1]].patternID==nil,
            "Unknown book origin must not create a new required book ID")
        assert(item.acquisitionResearch.confidence=="published-forever-book-requirement-reference")
        assert(item.acquisitionResearch.details:find("no vendor, enemy, quest or trainer source",1,true))
    end
end
assert(addon.ItemCatalog[22671].acquisitionResearch.sourceSummary:find("Revered with Hydraxian Waterlords",1,true))
assert(not addon.ItemCatalog[22671].acquisitionResearch.sourceSummary:find("Argent Dawn",1,true),"Do not copy other Icebane book factions")
assert(addon.ItemCatalog[13503].acquisitionResearch.details:find("Barkskin Burrow is the exact book-tooltip faction",1,true))

-- Checkpoint 6R: book objects are not NPC drops; exact specialisations.
local remainingDungeonBooks={{11811,11813},{15047,15730},{15046,15733},{15053,15749},{15088,15768},{15051,15770},{15085,15773},{15055,15775},{15090,15776},{15096,15777},{15052,15781},{14144,14495},{14154,14512},{14152,14513},{14153,14514},{11607,11611},{11606,11614},{11605,11615},{12796,12833},{12798,12835},{12783,12839},{4393,4415},{16004,16048},{18639,18658}}
for _,r in ipairs(remainingDungeonBooks) do
    local item=assert(addon.ItemCatalog[r[1]])
    assert(item.recipePatternItemID==r[2])
    assert(item.acquisitionResearch.details:find("not drops of the finished crafted gear",1,true))
    assert(item.acquisitionResearch.sourceSummary:find("live acquisition unverified",1,true))
end
assert(addon.ItemCatalog[11606].acquisitionResearch.details:find("lootable object #173232",1,true))
assert(addon.ItemCatalog[11605].acquisitionResearch.details:find("lootable object #173234",1,true))
assert(addon.ItemCatalog[11607].acquisitionResearch.details:find("Hammered Patron",1,true))
assert(addon.ItemCatalog[12796].acquisitionResearch.details:find("Master Hammersmith",1,true))
assert(addon.ItemCatalog[12798].acquisitionResearch.details:find("Master Axesmith",1,true))
assert(addon.ItemCatalog[12783].acquisitionResearch.details:find("Weaponsmith",1,true))
assert(addon.ItemCatalog[4393].acquisitionResearch.details:find("Kurzen Shadow Hunter",1,true))
assert(not addon.ItemCatalog[11606].acquisitionResearch.details:find("lootable object #173234",1,true))
assert(not addon.ItemCatalog[12783].acquisitionResearch.details:find("Master Axesmith",1,true))

-- Checkpoint 6S: only successfully researched cases enter runtime; partial source pass is explicit.
local higherGenericBooks={{3854,3868,true},{3856,3869,true},{3845,3873,true},{3846,3874,true},{3847,3875,true},{4260,4300,true},{4264,4301,true},{4328,4353,true},{4329,4356,true},{7059,7084,true},{7060,7085,true},{7061,7086,true},{7390,7452,true},{7391,7453,true},{7921,7975,true},{7934,7990,true},{7932,7991,true},{7942,7992,true},{7944,7993,true},{7946,8028,true},{7943,8029,true},{8174,8384,true},{8200,8386,true},{8201,8387,true},{8202,8389,true},{8203,8395,true},{8205,8397,true},{8204,8398,true},{8209,8399,true},{8207,8400,true},{8206,8401,true},{8208,8402,true},{10007,10300,true},{10008,10301,true},{10009,10302,true},{10018,10312,true},{10029,10315,true},{10033,10320,true},{10510,10604,true},{11608,11610,true},{11604,11612,true},{12260,12261,true},{12405,12682,true},{12406,12683,true},{12408,12684,true},{12416,12685,true},{12415,12689,true},{12409,12693,true},{12410,12694,true},{12418,12695,true},{12419,12697,true},{12417,12702,true},{12414,12704,true},{12611,12707,true},{12781,12827,true},{12792,12828,true},{12782,12830,true},{13869,14466,true},{13868,14467,true},{13857,14470,true},{14042,14471,true},{14143,14473,true},{13870,14474,true},{14043,14476,true},{14142,14477,true},{14100,14478,true},{14101,14479,true},{14141,14480,true},{14132,14485,true},{13871,14489,true},{14045,14490,true},{13865,14491,true},{14108,14492,true},{14136,14493,true},{14104,14494,true},{14111,14496,true},{14137,14497,true},{13866,14498,true},{15076,15727,true},{15084,15728,true},{15091,15731,true},{15054,15732,true},{15073,15737,true},{15078,15738,true},{15092,15739,true},{15082,15743,true},{15086,15744,true},{15093,15745,true},{15072,15746,true},{15069,15747,true},{15079,15748,true},{15060,15752,true},{15056,15753,true},{15075,15755,true},{15087,15757,true},{15066,15760,true},{15070,15761,true},{15049,15763,true},{15058,15764,true},{15995,16043,true},{16022,16054,true},{17704,17706,true},{17721,17722,true},{18638,18657,true},{250537,251389,true},{250539,251391,true},{250542,251394,true},{250548,251400,false},{250605,251457,true},{250607,251459,true},{250609,251461,true},{250611,251463,true},{252466,252845,true},{252532,252846,true},{252533,252847,true},{252565,252899,true},{254019,254020,true},{254033,254034,true},{254043,254044,false}}
for _,r in ipairs(higherGenericBooks) do
    local item=assert(addon.ItemCatalog[r[1]])
    assert(item.acquisitionResearch.sourceSummary:find("live unverified; non-exhaustive",1,true))
    assert(item.acquisitionResearch.details:find("not drops of finished crafted gear",1,true))
    if r[3] then assert(item.recipePatternItemID==r[2])
    else assert(addon.AcquisitionEvidenceIndex[r[1]].patternID==nil) end
end
assert(addon.ItemCatalog[12781].acquisitionResearch.details:find("object #176325",1,true))
assert(addon.ItemCatalog[12782].acquisitionResearch.details:find("object #176327",1,true))
assert(addon.ItemCatalog[17704].acquisitionResearch.details:find("current event availability/dates",1,true))
assert(addon.ItemCatalog[17721].acquisitionResearch.details:find("Smokywood Pastures Special Gift",1,true))
assert(addon.ItemCatalog[250548].acquisitionResearch.details:find("no named trainer/vendor/drop/quest source",1,true))
assert(addon.ItemCatalog[254043].acquisitionResearch.details:find("Book existence does not establish",1,true))
assert(addon.ItemCatalog[15078].acquisitionResearch.details:find("Blackrock Soldier",1,true))
assert(not addon.ItemCatalog[12781].acquisitionResearch.details:find("object #176327",1,true))
assert(addon.ItemCatalog[7934].acquisitionResearch.details:find("200 NPC rows and may be truncated",1,true))

-- Checkpoint 6T: four exact drop routes, one unavailable version and 146 honest origin gaps.
local noAltOriginGaps={254013,250535,254015,254017,249144,10010,250540,250541,250546,250549,250550,250610,252465,252531,252562,252563,252564,254037,254039,254041,254047,10020,249234,250612,10032,250544,250545,10038,10039,252574,252575,250586,250587,252544,252467,254073,254075,254077,252545,252546,252580,252581,249232,250588,254093,250551,250552,250553,250554,250555,252547,252548,252549,252550,252551,252582,252583,252584,252585,252586,252587,254095,254097,254099,254101,254103,254105,252478,252592,252593,252594,252595,252596,250589,250590,250615,252479,252553,252554,252597,252598,254119,252555,254125,250591,250592,252556,252557,252481,252600,254121,254127,249237,250593,252558,252559,254129,254131,260819,260820,260828,260829,250594,250598,250599,250600,250601,252560,252482,252561,252483,252484,252485,252486,252601,252602,252603,252604,252605,252606,254135,254137,260821,279246,279247,279248,279249,279250,279251,279252,279253,279254,279255,279256,279257,279259,279260,279261,279262,279263,279264,279265,279266,279267,279268,279273}
for _,id in ipairs(noAltOriginGaps) do
    local item=assert(addon.ItemCatalog[id])
    assert(addon.AcquisitionEvidenceIndex[id].patternID==nil)
    assert(item.acquisitionResearch.confidence=="published-forever-book-origin-unresolved")
    assert(item.acquisitionResearch.details:find("not current teaching proof",1,true)
        and item.acquisitionResearch.details:find("not proof a trainer cannot teach",1,true))
end
for _,r in ipairs({{250536,251388,"Kurzen Jungle Fighter"},{250547,251399,"Ragglesnout"},
                   {254021,254022,"Saltscale Oracle"},{254045,254046,"Amnennar the Coldbringer"}}) do
    local item=assert(addon.ItemCatalog[r[1]])
    assert(item.recipePatternItemID==r[2] and item.acquisitionResearch.details:find(r[3],1,true))
    assert(item.acquisitionResearch.details:find("not drops of the finished crafted gear",1,true))
end
assert(addon.ItemCatalog[217273].recipePatternItemID==nil)
assert(addon.ItemCatalog[217273].acquisitionResearch.confidence=="published-forever-availability-conflict")
assert(addon.ItemCatalog[9366].recipePatternItemID==9367
    and addon.ItemCatalog[9366].acquisitionResearch.confidence=="published-forever-quest-book-reference")
assert(not addon.ItemCatalog[217273].acquisitionResearch.sourceSummary:find("Hank the Hammer",1,true))

-- Checkpoint 6U: recovered canonical book and exact spell identities, preserving uncertainty.
local recoveredGenericBooks={{12610,12706},{12633,12711},{14128,14500},{14138,14501},{15095,15765},{15059,15771},{15062,15772},{22385,22388},{12420,12713},{12612,12714},{12640,12717},{13867,14504},{14130,14505},{14106,14506},{14139,14507},{15081,15774},{16007,16056},{12613,12718},{12614,12719},{12794,12837},{14112,14508},{14140,14509},{14146,14511},{15068,15779},{18405,18414},{18407,18415},{18408,18416},{18409,18417},{18504,18514},{18506,18515},{18508,18516},{21278,21548},{12790,12834},{12797,12836},{12784,12838},{20538,20546},{20537,20547},{20539,20548},{20549,20553},{20550,20554},{20551,20555},{22384,22390},{22383,22389},{18263,18265},{18168,18291},{18282,18292},{22194,22220},{22196,22222}}
for _,r in ipairs(recoveredGenericBooks) do
    local item=assert(addon.ItemCatalog[r[1]])
    assert(item.acquisitionResearch.sourceSummary:find("live unverified; non-exhaustive",1,true))
    assert(item.acquisitionResearch.details:find("not drops of finished crafted gear",1,true))
    assert(item.recipePatternItemID==r[2])
end
for _,id in ipairs({18405,18407,18408,18409,18504,18506,18508}) do
    local d=addon.ItemCatalog[id].acquisitionResearch.details
    assert(d:find("object #179501",1,true) and d:find("Free Knot!",1,true)
        and d:find("Gordok Shackle Key #18250",1,true))
    assert(not d:find("Hermit Ortell",1,true))
end
for _,id in ipairs({20538,20537,20539,20549,20550,20551}) do
    local d=assert(addon.ItemCatalog[id]).acquisitionResearch.details
    assert(d:find("Hermit Ortell",1,true) and d:find("10 Encrypted Twilight Texts",1,true)
        and d:find("Current delivery timing",1,true))
    assert(not d:find("Free Knot!",1,true))
end
assert(addon.ItemCatalog[14112].acquisitionResearch.details:find("Winterspring",1,true)
    and addon.ItemCatalog[14112].acquisitionResearch.details:find("fishing-table",1,true))
assert(addon.ItemCatalog[12790].acquisitionResearch.details:find("Master Swordsmith",1,true))
assert(addon.ItemCatalog[12784].acquisitionResearch.details:find("Master Axesmith",1,true))
assert(not addon.ItemCatalog[12784].acquisitionResearch.details:find("Master Swordsmith",1,true))
assert(addon.ItemCatalog[15095].acquisitionResearch.details:find("200 NPC rows and may be truncated",1,true))

-- Checkpoint 7A: exact original Hyjal book gates supersede only a generic generated hint.
local hyjalVendorBooks={{273884,273952,"Friendly Advice",8},{273885,273953,"Gloves",6},{273886,273954,"Shoulders",6},{273887,273955,"Boots",6},{273888,273956,"Friendly Advice",8},{273889,273957,"Gloves",6},{273890,273958,"Shoulders",6},{273891,273959,"Boots",6},{273892,273960,"Friendly Advice",8},{273893,273961,"Gloves",6},{273894,273962,"Shoulders",6},{273895,273963,"Boots",6},{273896,273964,"Friendly Advice",8},{273897,273965,"Gloves",6},{273898,273966,"Shoulders",6},{273899,273967,"Boots",6},{273900,273968,"Friendly Advice",8},{273901,273969,"Gloves",6},{273902,273970,"Shoulders",6},{273903,273971,"Boots",6},{273904,273972,"Friendly Advice",8},{273905,273973,"Gloves",6},{273906,273974,"Shoulders",6},{273907,273975,"Boots",6},{273908,273976,"Friendly Advice",8},{273909,273977,"Gloves",6},{273910,273978,"Shoulders",6},{273911,273979,"Boots",6},{273912,273980,"Friendly Advice",8},{273913,273981,"Gloves",6},{273914,273982,"Shoulders",6},{273915,273983,"Boots",6},{273916,273984,"Friendly Advice",8},{273917,273985,"Gloves",6},{273918,273986,"Shoulders",6},{273919,273987,"Boots",6},{273920,273988,"Friendly Advice",8},{273921,273989,"Gloves",6},{273922,273990,"Shoulders",6},{273923,273991,"Boots",6},{273924,273992,"Friendly Advice",8},{273925,273993,"Gloves",6},{273926,273994,"Shoulders",6},{273927,273995,"Boots",6},{273928,273996,"Friendly Advice",8},{273929,273997,"Gloves",6},{273930,273998,"Shoulders",6},{273931,273999,"Boots",6},{273932,274000,"Friendly Advice",8},{273933,274001,"Gloves",6},{273934,274002,"Shoulders",6},{273935,274003,"Boots",6},{273936,274004,"Friendly Advice",8},{273937,274005,"Gloves",6},{273938,274006,"Shoulders",6},{273939,274007,"Boots",6},{273940,274008,"Friendly Advice",8},{273941,274009,"Gloves",6},{273942,274010,"Shoulders",6},{273943,274011,"Boots",6},{273944,274012,"Friendly Advice",8},{273945,274013,"Gloves",6},{273946,274014,"Shoulders",6},{273947,274015,"Boots",6},{273948,274016,"Friendly Advice",8},{273949,274017,"Gloves",6},{273950,274018,"Shoulders",6},{273951,274019,"Boots",6}}
for _,r in ipairs(hyjalVendorBooks) do
    local item=assert(addon.ItemCatalog[r[1]])
    local a=assert(item.acquisitionResearch)
    assert(item.recipePatternItemID==r[2] and a.recipeReference==true)
    assert(a.confidence=="published-forever-recipe-vendor-reference")
    assert(a.details:find("not sale of the finished crafted gear",1,true))
    assert(a.details:find("Purchase cost and quest/slot gates are separate",1,true))
    assert(a.details:find("disenchanting items from Hyjal Summit or Barrow Deeps",1,true))
    assert(a.details:find("exact item yields",1,true) and a.sourceSummary:find("live stock/access unverified",1,true))
    assert(a.details:find(r[4].." x Malleable Essence of Nature #274030",1,true))
    if r[3]=="Friendly Advice" then
        assert(a.details:find("exact quest ID",1,true) and not a.details:find("rank is unspecified",1,true))
    else
        assert(a.details:find(r[3].." specialisation",1,true) and a.details:find("rank is unspecified",1,true))
        for _,slot in ipairs({"Gloves","Shoulders","Boots"}) do
            if slot~=r[3] then assert(not a.details:find(slot.." specialisation",1,true)) end
        end
    end
end
-- Published new currency information does not change prior Spiritcaller slot conditions.
for _,id in ipairs({276538,276539,276540,276541}) do
    local a=assert(addon.ItemCatalog[id]).acquisitionResearch
    assert(a.details:find("disenchanting items from Hyjal Summit or Barrow Deeps",1,true))
end

-- Checkpoint 7B: detailed equipment quest routes are additive and distinct from recipe research.
local reviewedQuestGear={5596,7001,16606,16607,217314,217315,263305,270027,281267,281269,281270,281271,281272,281273}
for _,id in ipairs(reviewedQuestGear) do
    local item=assert(addon.ItemCatalog[id])
    local a=assert(item.acquisitionResearch)
    assert(a.equipmentReference==true and not a.recipeReference)
    assert(a.confidence=="published-forever-quest-equipment-reference")
    assert(a.sourceSummary:find("unverified",1,true) and a.details:find("no current live acquisition confirmation",1,true))
    assert(addon.AcquisitionEvidenceIndex[id].patternID==nil)
end
for _,id in ipairs({281269,281270,281271,281272,281273}) do
    local d=addon.ItemCatalog[id].acquisitionResearch.details
    assert(d:find("Choose one of five",1,true) and d:find("#661446/#661448/#661449",1,true))
    assert(d:find("ground objects, not enemies or vendors",1,true))
    assert(not d:find("Scramble",1,true))
end
for _,id in ipairs({217314,217315}) do
    local d=addon.ItemCatalog[id].acquisitionResearch.details
    assert(d:find("Scramble",1,true) and d:find("Alliance starts",1,true) and d:find("Horde starts",1,true))
    assert(d:find("interactive objects, not NPCs",1,true))
    assert(not d:find("Choose one of five",1,true))
end
assert(addon.ItemCatalog[16606].acquisitionResearch.details:find("Troll, Priest",1,true))
assert(addon.ItemCatalog[16607].acquisitionResearch.details:find("Undead, Priest",1,true))
assert(not addon.ItemCatalog[16606].acquisitionResearch.details:find("Undead, Priest",1,true))
assert(addon.ItemCatalog[7001].acquisitionResearch.details:find("Alliance #1200",1,true)
    and addon.ItemCatalog[7001].acquisitionResearch.details:find("Horde #6561",1,true))
assert(addon.ItemCatalog[270027].acquisitionConfidence=="reported"
    and addon.ItemCatalog[270027].source:find("seen by one player",1,true))
assert(addon.ItemCatalog[5596].acquisitionResearch.details:find("not proof the complete chain is achievable at level 1",1,true))
assert(addon.ItemCatalog[263305].acquisitionResearch.details:find("scripted confrontation",1,true))
-- Fresh community listings cannot erase the existing multi-encounter source
-- or promote a published item/NPC table into observed live equipment loot.
local claw=assert(addon.ItemCatalog[12243])
for _,name in ipairs({"Dreamscythe","Weaver","Hazzas","Morphaz"}) do
    assert(claw.source:find(name,1,true))
end
assert(claw.acquisitionResearch.sourceSummary:find("live unverified",1,true)
    and claw.acquisitionResearch.confidence~="forever-observed-npc")

-- Checkpoint 7C: exact vendor references, version-specific warnings and honest source gaps.
local reviewedVendorGear={2506,3026,3027,4765,4781,4789,4794,4795,4796,4800,4816,4829,4832,11303,11304,15200,18834,18845,18846,18849,18850,18851,18852,18853,19513,19521,19537,19545,19553,19561,19569,20152,20157,20162,20164,20169,20172,20178,20182,20188,20191,20197,20201,20207,20210,20425,20426,20429,20430,20437,20441,20442,21120,206386,209611,209612,209613,209614,209615,209616,209617,209618,209619,209620,209621,209622,209623,209624,209625,209626,211500,211856,211857,212580,212581,212582,212583,212584,212585,212586,212587,272067,272071,272075,272082,272086,272090,272094,274741,274742,274743,274744,276273}
local crossVersionGear={206386,209611,209612,209613,209614,209615,209616,209617,209618,209619,209620,209621,209622,209623,209624,209625,209626,212582,212586}
for _,id in ipairs(reviewedVendorGear) do
    local a=assert(addon.ItemCatalog[id]).acquisitionResearch
    assert(a.equipmentReference and not a.recipeReference)
    assert(a.sourceSummary:find("unverified",1,true) and a.details:find("unchanged",1,true))
    assert(addon.AcquisitionEvidenceIndex[id].patternID==nil)
end
for _,id in ipairs(crossVersionGear) do
    local a=addon.ItemCatalog[id].acquisitionResearch
    assert(a.confidence=="published-cross-version-availability-warning")
    assert(a.details:find("not an instruction that this item can currently be bought",1,true))
end
for _,id in ipairs({20178,20182}) do
    local a=addon.ItemCatalog[id].acquisitionResearch
    assert(a.confidence=="published-forever-equipment-origin-unresolved")
    assert(a.details:find("No guessed seller, price or farm",1,true))
end
assert(addon.ItemCatalog[18834].acquisitionResearch.confidence=="published-forever-equipment-vendor-reference")
assert(not addon.ItemCatalog[18834].acquisitionResearch.details:find("added in Season of Discovery",1,true))
assert(addon.ItemCatalog[209611].acquisitionResearch.details:find("class access: Hunter",1,true))
assert(addon.ItemCatalog[18834].acquisitionResearch.details:find("class access: Warrior",1,true))
assert(addon.ItemCatalog[20425].acquisitionResearch.details:find("Warsong Outriders - Revered",1,true))
assert(addon.ItemCatalog[20426].acquisitionResearch.details:find("Warsong Outriders - Honored",1,true))
assert(addon.ItemCatalog[20425].acquisitionResearch.details:find("Standing 0 is not proof of Neutral access",1,true))
assert(addon.ItemCatalog[276273].acquisitionResearch.details:find("one Extravagant Extravaganza Coin #274026",1,true)
    and addon.ItemCatalog[276273].acquisitionResearch.details:find("Current event schedule",1,true))
assert(addon.ItemCatalog[206386].acquisitionResearch.details:find("not proof the relic, rune mechanic or Rune Broker exists",1,true))

-- Checkpoint 7D: complete bounded source-undocumented triage; no invented sources or version spread.
local sourceUndocumentedGear={3334,4196,4763,5000,6360,6589,6698,6707,6708,6711,6724,6728,7426,7427,7467,8350,9602,18611,205218,206376,206383,206384,206385,206389,206390,206391,231877,241089,241090,251960,263005,263007,263431,263432,263434,263435,263436,264501,271911,271916,271920,271927,271931,271935,271939,274444,274445,274978,277213,280304,281730,281731,281732,281733,281926,281927,282636,282642,282653,282654,282655,282717,282721,283361,284177,284386,284399,284400,284401,284403,284459,284573,284574,284667,284668,284697,284699,284700,284702,284704,284717,285191,285192,285212,285236,285253,285268,285326,285331,285344,285351,286537,286540,286982,286983,286984,286985,286986,286987,286988,286989,286990,286991,286992,286993,286995,286996}
local unavailableGear={6698,6707,6708,6711,6724,6728,274978,285326}
local unresolvedGear={4196,4763,5000,6589,7426,7427,7467,9602,231877,251960,263431,263432,263434,263435,263436,271911,271916,271920,271927,271931,271935,271939,274444,274445,280304,281730,281731,281732,281733,282642,282655,282717,284403,284459,284573,284574,284667,284697,284699,284700,284717,285191,285192,286982,286983,286984,286993,286995}
for _,id in ipairs(sourceUndocumentedGear) do
    local a=assert(addon.ItemCatalog[id]).acquisitionResearch
    assert(a.equipmentReference and not a.recipeReference)
    assert(a.sourceSummary:find("unverified",1,true) and addon.AcquisitionEvidenceIndex[id].patternID==nil)
end
for _,id in ipairs(unavailableGear) do
    local a=addon.ItemCatalog[id].acquisitionResearch
    assert(a.confidence=="published-item-availability-warning"
        and a.details:find("not a claim a player can obtain it",1,true))
end
for _,id in ipairs(unresolvedGear) do
    local a=addon.ItemCatalog[id].acquisitionResearch
    assert(a.confidence=="published-forever-equipment-origin-unresolved")
    assert(a.details:find("No guessed source",1,true))
end
local shovel=addon.ItemCatalog[3334].acquisitionResearch.details
assert(shovel:find("Farmer Solliden",1,true) and shovel:find("Tirisfal Farmer",1,true)
    and shovel:find("Stepping Stones #79192",1,true)
    and shovel:find("quest minimum 14 is not the gear equip level 5",1,true))
assert(addon.ItemCatalog[6360].acquisitionResearch.details:find("fishing catches, not NPC drops",1,true))
assert(addon.ItemCatalog[8350].acquisitionResearch.details:find("gear equip level is not a fishing skill requirement",1,true))
assert(addon.ItemCatalog[264501].acquisitionResearch.details:find("interactive object, not a boss NPC",1,true))
assert(addon.ItemCatalog[271911].acquisitionResearch.details:find("omits this exact ID",1,true)
    and addon.ItemCatalog[271911].acquisitionResearch.details:find("Honored",1,true))
assert(addon.ItemCatalog[274444].acquisitionResearch.details:find("Corporal/Grunt (Rank 2)",1,true))
assert(not addon.ItemCatalog[274444].acquisitionResearch.details:find("this exact item page explicitly flags unavailable",1,true))
assert(addon.ItemCatalog[284573].acquisitionResearch.confidence=="published-forever-equipment-origin-unresolved")
assert(addon.ItemCatalog[205218].acquisitionResearch.confidence=="published-cross-version-availability-warning")

local index=assert(io.open(root.."/AcquisitionEvidenceIndex.lua")):read("*a")
assert(index:find("Friendly Guardians of Hyjal + completion of Friendly Advice",1,true)
    and index:find("Boots specialisation (exact rank unspecified)",1,true),
    "Preserve individually evidenced Hyjal gates and unspecified-rank limits")
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
