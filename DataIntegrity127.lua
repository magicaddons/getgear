local addonName, GetGear = ...
-- v0.12.7: Research-backed classification; a client recipe teaching record
-- is not proof of the current server-side NPC inventory or pattern drop.
-- Yellow/green/grey skill-up thresholds are NEVER used as learning minima.
local candidates = {
    [2300] = {method='trainer', url='https://wowforever.wclbox.com/en/zhuanye/leatherworking', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution=''},
    [2303] = {method='trainer', url='https://wowforever.wclbox.com/en/zhuanye/leatherworking', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution=''},
    [2844] = {method='trainer', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [2845] = {method='trainer', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [2849] = {method='trainer', url='https://wowforever.wclbox.com/en/zhuanye/blacksmithing', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='recipe learnt-at values 85 and 105, respectively, appear in independent client record; source threshold values vary by catalogue'},
    [2850] = {method='trainer', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [2852] = {method='trainer', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [2853] = {method='initial', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [2854] = {method='trainer', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [2857] = {method='trainer', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [2866] = {method='trainer', url='https://wowforever.wclbox.com/en/zhuanye/blacksmithing', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='recipe learnt-at values 85 and 105, respectively, appear in independent client record; source threshold values vary by catalogue'},
    [2870] = {method='trainer', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [3469] = {method='trainer', url='https://wowforever.wclbox.com/en/zhuanye/blacksmithing', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution=''},
    [3471] = {method='pattern', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution='Plans: Copper Chain Vest in Forever recipe catalogue. Do not assume trainer-taught.'},
    [3480] = {method='trainer', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [3482] = {method='trainer', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [3488] = {method='trainer', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [3490] = {method='pattern', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution='Plans: Deadly Bronze Poniard; ForeverDiff identifies plan requirement Blacksmithing 100 (not recipe craft tier 125).'},
    [3491] = {method='trainer', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [3842] = {method='trainer', url='https://wowforever.wclbox.com/en/zhuanye/blacksmithing', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='minimum trainer skill unknown; displayed number may be yellow skill-up threshold, not learning requirement'},
    [3849] = {method='pattern', url='https://wowforever.wclbox.com/en/zhuanye/blacksmithing', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution=''},
    [3850] = {method='pattern', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution='Plans: Jade Serpentblade in Forever recipe catalogue.'},
    [4242] = {method='trainer', url='https://wowforever.wclbox.com/en/zhuanye/leatherworking', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution=''},
    [4244] = {method='pattern', url='https://questing.wiki/wow-forever/professions/leatherworking/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution='Pattern: Hillman\'s Leather Vest; world drop listings are not live proof.'},
    [4318] = {method='trainer', url='https://theforeverera.com/en/recipes/tailoring/gloves-of-meditation/', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='minimum trainer skill unknown; displayed number may be yellow skill-up threshold, not learning requirement'},
    [4320] = {method='trainer', url='https://theforeverera.com/en/recipes/tailoring/spidersilk-boots/', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='minimum trainer skill unknown; displayed number may be yellow skill-up threshold, not learning requirement'},
    [5540] = {method='trainer', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [5541] = {method='pattern', url='https://wowforever.wclbox.com/en/zhuanye/blacksmithing', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution=''},
    [5542] = {method='trainer', url='https://theforeverera.com/en/recipes/tailoring/pearl-clasped-cloak/', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='minimum trainer skill unknown; displayed number may be yellow skill-up threshold, not learning requirement'},
    [5957] = {method='multiple', url='https://wowforever.wclbox.com/en/zhuanye/leatherworking', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='trainer vs automatically learned wording conflict; check freshly learned Leatherworking spellbook'},
    [6214] = {method='trainer', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [6468] = {method='pattern', url='https://questing.wiki/wow-forever/professions/leatherworking/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution='Pattern: Deviate Scale Belt; Forever client/quest listing links Deviate Eradication.'},
    [6730] = {method='pattern', url='https://wowforever.wclbox.com/en/zhuanye/blacksmithing', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution=''},
    [7049] = {method='pattern', url='https://questing.wiki/wow-forever/professions/tailoring/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [7053] = {method='pattern', url='https://questing.wiki/wow-forever/professions/tailoring/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [7352] = {method='pattern', url='https://questing.wiki/wow-forever/professions/leatherworking/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution='Pattern: Earthen Leather Shoulders; Zixil listing needs live verification.'},
    [7955] = {method='trainer', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [7956] = {method='trainer', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [10421] = {method='initial', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [11287] = {method='trainer', url='https://questing.wiki/wow-forever/professions/enchanting/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution='Trainer taught; source lists 22 trainer NPCs.'},
    [11288] = {method='trainer', url='https://questing.wiki/wow-forever/professions/enchanting/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [20575] = {method='pattern', url='https://questing.wiki/wow-forever/professions/leatherworking/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution='Pattern: Black Whelp Tunic; Amy Davenport listed as possible vendor, stock not proven live.'},
    [247789] = {method='initial', url='https://questing.wiki/wow-forever/professions/enchanting/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution='Automatically learned with Enchanting; 10 is yellow tier in cited catalogue, not necessarily learning minimum.'},
    [250500] = {method='trainer', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [250501] = {method='trainer', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [250502] = {method='trainer', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [250556] = {method='pattern', url='https://wowforever.wclbox.com/en/zhuanye/blacksmithing', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='prior round found trainer-vs-plans conflicting listings; plans existence alone not proof of exclusive pattern teaching'},
    [250557] = {method='pattern', url='https://wowforever.wclbox.com/en/zhuanye/blacksmithing', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution=''},
    [250558] = {method='pattern', url='https://wowforever.wclbox.com/en/zhuanye/blacksmithing', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='prior round found trainer-vs-plans conflicting listings; plans existence alone not proof of exclusive pattern teaching'},
    [250559] = {method='pattern', url='https://wowforever.wclbox.com/en/zhuanye/blacksmithing', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution=''},
    [250603] = {method='pattern', url='https://questing.wiki/wow-forever/professions/blacksmithing/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution='Plans: Bronze Dory; ForeverDiff gives plan requirement Blacksmithing 95.'},
    [252445] = {method='trainer', url='https://wowforever.wclbox.com/en/zhuanye/leatherworking', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution=''},
    [252456] = {method='trainer', url='https://wowforever.wclbox.com/en/zhuanye/leatherworking', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='Totemic Leather Helm marked Trainer in client catalogue, but prior in-game report indicated not trainable; needs direct current beta trainer test'},
    [252459] = {method='pattern', url='https://questing.wiki/wow-forever/professions/leatherworking/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [252501] = {method='trainer', url='https://wowforever.wclbox.com/en/zhuanye/leatherworking', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution=''},
    [252502] = {method='trainer', url='https://wowforever.wclbox.com/en/zhuanye/leatherworking', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution=''},
    [252503] = {method='trainer', url='https://wowforever.wclbox.com/en/zhuanye/leatherworking', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution=''},
    [252512] = {method='trainer', url='https://wowforever.wclbox.com/en/zhuanye/leatherworking', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution=''},
    [252515] = {method='trainer', url='https://wowforever.wclbox.com/en/zhuanye/leatherworking', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution=''},
    [252520] = {method='pattern', url='https://questing.wiki/wow-forever/professions/leatherworking/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [252521] = {method='pattern', url='https://questing.wiki/wow-forever/professions/leatherworking/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [253885] = {method='pattern', url='https://questing.wiki/wow-forever/professions/tailoring/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [253887] = {method='pattern', url='https://questing.wiki/wow-forever/professions/tailoring/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [253889] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253891] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253893] = {method='pattern', url='https://questing.wiki/wow-forever/professions/tailoring/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [253895] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253897] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253901] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already pattern/drop in addon prose; do not promote exact boss drop to live confirmed'},
    [253903] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already pattern/drop in addon prose; do not promote exact boss drop to live confirmed'},
    [253905] = {method='pattern', url='https://questing.wiki/wow-forever/professions/tailoring/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution='Pattern: Filigreed Flame Gown. Specific dungeon drop remains unverified.'},
    [253907] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already pattern/drop in addon prose; do not promote exact boss drop to live confirmed'},
    [253909] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already pattern/drop in addon prose; do not promote exact boss drop to live confirmed'},
    [253913] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253915] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253917] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253919] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253921] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253925] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253927] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253929] = {method='pattern', url='https://questing.wiki/wow-forever/professions/tailoring/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [253931] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253933] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253939] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already pattern/drop in addon prose; do not promote exact boss drop to live confirmed'},
    [253941] = {method='pattern', url='https://questing.wiki/wow-forever/professions/tailoring/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution='Pattern: Filigreed Flame Leggings. Boss/zone reports need confirmation.'},
    [253943] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already pattern/drop in addon prose; do not promote exact boss drop to live confirmed'},
    [253945] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already pattern/drop in addon prose; do not promote exact boss drop to live confirmed'},
    [253951] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253953] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253955] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253957] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253961] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253963] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253965] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253967] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253969] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253977] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already pattern/drop in addon prose; do not promote exact boss drop to live confirmed'},
    [253979] = {method='pattern', url='https://questing.wiki/wow-forever/professions/tailoring/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [253981] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already pattern/drop in addon prose; do not promote exact boss drop to live confirmed'},
    [253983] = {method='pattern', url='https://questing.wiki/wow-forever/professions/tailoring/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [253987] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253989] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253991] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253993] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [253995] = {method='pattern', url='https://www.wowhead.com/forever/guide/professions/tailoring-overview-trainer-locations-recipes', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='already listed as pattern/vendor in addon prose; structured learning method incorrectly unverified'},
    [254001] = {method='multiple', url='https://foreverdiff.com/recipes/gilded-slippers-55481/', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='beta first-hand observation claims Tepa/Rhiannon trainer-taught (build 70205); pattern also exists in client (build 70450) | requires Spinning Wheel workstation; not interchangeable with trainer/source'},
    [254003] = {method='pattern', url='https://questing.wiki/wow-forever/professions/tailoring/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [254005] = {method='pattern', url='https://questing.wiki/wow-forever/professions/tailoring/', basis='Forever-indexed profession listing (not live trainer/vendor stock)', caution=''},
    [254007] = {method='multiple', url='https://wowfdb.com/professions/tailoring/recipes/', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='pattern documented but addon describes trainer; cannot exclude both methods | also requires Spinning Wheel per recipe source, distinct from learning source'},
    [254009] = {method='pattern', url='https://foreverdiff.com/recipes/golden-slippers-55485/', basis='Forever-indexed recipe catalogue (not live trainer/vendor stock)', caution='requires Spinning Wheel workstation; not interchangeable with trainer/source'},
}
local function CleanUnsupportedClaim(text)
    if type(text)~="string" then return text end
    -- These substitutions remove only supposed learning-skill requirements,
    -- never item stats, equipment levels, vendor prices, reagent counts, etc.
    text=text:gsub("[Ll]earn and craft with ([A-Za-z]+) skill %d+", "Learn/craft with %1 (minimum learning skill unverified)")
    text=text:gsub("[Cc]raft through ([A-Za-z]+) %(skill %d+%)", "Craft through %1 (minimum learning skill unverified)")
    text=text:gsub("[Cc]raft with ([A-Za-z]+) %(skill %d+%)", "Craft with %1 (minimum learning skill unverified)")
    text=text:gsub("[Ff]orge with ([A-Za-z]+) %(skill %d+%)", "Forge with %1 (minimum learning skill unverified)")
    text=text:gsub("[Ll]earn it at ([A-Za-z]+) skill %d+", "Learning skill for %1 not independently established")
    text=text:gsub("[Rr]ecipe requires ([A-Za-z]+) skill %d+", "Recipe learning requirement for %1 is not independently established")
    text=text:gsub("[Tt]he belt requires ([A-Za-z]+) skill %d+ to learn", "The belt's %1 learning requirement is not independently established")
    text=text:gsub("[Ss]kill %d+ is required", "Minimum learning skill has not been verified")
    text=text:gsub("([A-Za-z]+) skill %d+", "%1 learning skill (unverified)")
    text=text:gsub("([A-Za-z]+) %d+ recipe", "%1 recipe (learning skill unverified)")
    for _,prof in ipairs({"Tailoring","Leatherworking","Blacksmithing","Enchanting"}) do
        text=text:gsub("at "..prof.." %d+", "at "..prof.." (minimum learning skill unverified)")
    end
    text=text:gsub("([A-Za-z]+) %d+: automatically learned", "%1 initial recipe (minimum skill unverified): automatically learned")
    text=text:gsub("[Ss]kill %d+", "learning skill unverified")
    return text
end
GetGear.IntegratedLearningAudit = {candidateCount=0, unknownMinimums=0, methods={}}
for id,item in pairs(GetGear.ItemCatalog or {}) do
    if item.profession then
        local f=candidates[id]
        if f then
            assert(item.recipeLearnMethod=="unverified", "Unexpected preclassified source for "..id)
            item.recipeLearnMethod=f.method
            item.recipeMethodEvidence="forever-client-index; live acquisition not certified"
            item.recipeMethodEvidenceURL=f.url
            item.recipeMethodCaution=f.caution
            GetGear.IntegratedLearningAudit.candidateCount=GetGear.IntegratedLearningAudit.candidateCount+1
            GetGear.IntegratedLearningAudit.methods[f.method]=(GetGear.IntegratedLearningAudit.methods[f.method] or 0)+1
            if (item.acquisitionKind=="Crafting" or item.acquisitionKind=="Crafting (pattern source unverified)") and not item.recipeVendor then
                item.acquisitionKind=(f.method=="trainer" and "Profession trainer (client-listed)")
                    or (f.method=="pattern" and "Pattern/plans required (learning item location not certified)")
                    or (f.method=="initial" and "Initial profession recipe (client-listed)")
                    or "Trainer / pattern conflict (client listings)"
            end
            if item.source and (item.source:find("learning source",1,true) or item.source:find("recipe source unknown",1,true)) then
                item.source = (f.method=="trainer" and item.profession.." trainer (client-listed)")
                    or (f.method=="pattern" and "Pattern/plans documented (exact learning item source unconfirmed)")
                    or (f.method=="initial" and "Initial "..item.profession.." recipe (client-listed)")
                    or "Recipe learning method disputed across Forever listings"
            end
            -- Rewrite the old generic warning without claiming the indexed
            -- teaching method has already been demonstrated on the server.
            local methodText = (f.method=="trainer" and "Forever client listings mark this as trainer-taught; check the current trainer UI for availability.")
                or (f.method=="pattern" and "Forever client listings identify a teaching pattern or plans; the exact acquisition method may still need confirmation.")
                or (f.method=="initial" and "Forever listings suggest this is included when learning the profession; check the profession recipe list.")
                or "Forever references disagree about trainer versus pattern or initial learning; check the current profession UI."
            if type(item.instructions)=="string" then
                local old="The recipe exists in the Forever client, but its actual learning source has not been confirmed. Check in game before spending materials."
                local old2="This Forever-client recipe is confirmed, but the exact trainer, vendor or drop that teaches it has not been independently verified. Check your recipe list before travelling."
                item.instructions=item.instructions:gsub(old:gsub("([^%w])","%%%1"), methodText)
                item.instructions=item.instructions:gsub(old2:gsub("([^%w])","%%%1"), methodText)
            end
            if f.method=="multiple" then
                item.recipeLearningAvailability="disputed"
                if not f.caution or f.caution=="" then
                    item.recipeMethodCaution="Multiple learning sources are listed in different Forever snapshots; current server method not established."
                end
            end
        end
        -- Skill-up colour thresholds are not proof of learning skill. The
        -- prior addon hid the badge, yet still leaked guesses into text.
        if not (item.recipeLearnSkillEvidence=="published-beta-vendor-pattern"
              or item.recipeLearnSkillEvidence=="Forever client pattern requirement"
              or item.recipeLearnSkillEvidence=="Forever pattern item requirement") then
            item.professionSkillRequired=nil
            item.professionSkillEstimate=nil
            item.recipeLearnSkillEvidence="unverified"
            item.source=CleanUnsupportedClaim(item.source)
            item.instructions=CleanUnsupportedClaim(item.instructions)
            item.notes=CleanUnsupportedClaim(item.notes)
            GetGear.IntegratedLearningAudit.unknownMinimums=GetGear.IntegratedLearningAudit.unknownMinimums+1
        end
        if f and not item.recipeVendor and f.method=="trainer" then
            -- Do not claim *which* trainer currently offers it.
            item.recipeTrainerListProvenance="Forever client listing; live stock unknown"
        end
    end
end
local helm=GetGear.ItemCatalog[252456]
if helm then
    helm.recipeLearningAvailability="disputed"
    helm.recipeMethodCaution="Client lists a trainer; user reported not trainable in the beta. Do not recommend travel solely on the client listing."
end
-- No item stat is replaced from an older snapshot or lower-number guess.
-- Live client item info remains the comparison authority; these exceptions
-- explicitly require build chronology before editing static item notes.
for id,why in pairs({
    [11304]="Divergent static bow damage values (14-26 vs 23-44)",
    [1484]="Divergent static staff damage values (40-61 vs 55-83)",
    [271215]="Published spell power/resistance properties differ",
    [273643]="Published mana-per-five values differ (1 vs 2)",
}) do
    local item=GetGear.ItemCatalog[id]
    if item then
        item.statEvidenceConflict=why
        item.statResolution="Use current WoW Forever client tooltip; compare database values only after matching extract build/date"
    end
end
