local addonName, GetGear = ...
-- Integrate independent acquisition evidence conservatively. Source research
-- never changes equipment identities, quality, class masks, item statistics,
-- recipe material lists, or SavedVariables. Manual item source descriptions
-- and genuinely observed notes retain priority over generated references.
local records=GetGear.AcquisitionEvidenceIndex or {}
local added=0
local teaching=0
for id,reference in pairs(records) do
    local facts=GetGear.ItemCatalog and GetGear.ItemCatalog[id]
    if facts and type(reference)=="table" then
        local current=facts.sourceSummary
        local manualCurrent=type(current)=="string" and current~=""
        facts.acquisitionResearch={
            confidence=reference.confidence,
            sourceURL=reference.url,
            sourceSummary=reference.summary,
            referenceDate="2026-11-09",
            recipeReference=reference.recipeReference,
            details=reference.details,
        }
        if not manualCurrent
            and type(reference.summary)=="string" and reference.summary~="" then
            facts.sourceSummary=reference.summary
            added=added+1
        end
        -- Associate a researched book route when one is supplied. Book
        -- existence alone does not establish the only learning path;
        -- trainer alternatives with unknown book origin omit patternID.
        if type(reference.patternID)=="number" and not facts.recipePatternItemID then
            facts.recipePatternItemID=reference.patternID
            if not facts.recipeLearnMethod then
                facts.recipeLearnMethod="pattern"
            end
            if not facts.recipeMethodEvidence then
                facts.recipeMethodEvidence="forever-client-book; source unverified"
            end
            teaching=teaching+1
        end
    end
end
GetGear.AcquisitionResearchAudit={indexed=0,displayEnriched=added,bookIdsAdded=teaching}
for _ in pairs(records) do
    GetGear.AcquisitionResearchAudit.indexed=GetGear.AcquisitionResearchAudit.indexed+1
end
