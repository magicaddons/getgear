local addonName, GetGear = ...
-- Catalog-wide evidence annotations. Client existence or navigation alone
-- must never imply a verified server-side item drop, trader, or quest reward.
GetGear.DataEvidence = {classified=0, unresolvedSkill=0, inferredBinding=0}
for id,item in pairs(GetGear.ItemCatalog or {}) do
    if item.acquisitionLocation and not item.acquisitionLocationConfidence then
        item.acquisitionLocationConfidence=item.acquisitionLocation.quality or "unknown"
    end
    -- An item flagged Classic-reference cannot gain independent item-source
    -- verification merely because a dungeon entrance or quest start is mapped.
    if item.confidence=="classic-reference" and
       (item.acquisitionKind=="Dungeon entrance" or item.acquisitionKind=="Quest start") then
        item.acquisitionConfidence="classic-reference"
    end
    item.itemSourceEvidence=item.acquisitionConfidence or item.confidence or "unverified"
    if id==2277 then
        item.acquisitionKind="World drop (exact mob unverified)"
        item.acquisitionConfidence="classic-reference"
        item.itemSourceEvidence="classic-reference"
        item.source="World drop / Auction House"
        item.instructions="Forever auction listings show this item exists, but individual creature drops and chances are only Classic-reference. Check the Auction House; do not farm a claimed specific mob without Forever evidence."
        item.sourceEvidenceURL="https://foreverdb.net/item/2277"
    end
    if item.profession then
        if not item.recipeLearnMethod then
            item.recipeLearnMethod="unverified"
            GetGear.DataEvidence.classified=GetGear.DataEvidence.classified+1
        end
        -- Values of uncertain provenance may be yellow skill-up points.
        -- Retain existing number in source but don't present as a verified
        -- learning threshold until checked against pattern/vendor requirements.
        if not item.recipeLearnSkillEvidence then
            item.recipeLearnSkillEvidence="unverified"
            GetGear.DataEvidence.unresolvedSkill=GetGear.DataEvidence.unresolvedSkill+1
        end
        -- Explicitly inferred from existing guide prose, not client-certified.
        local desc=(item.instructions or "").." "..(item.notes or "")
        local lower=desc:lower()
        if lower:find("bind on pickup",1,true) or lower:find("binds on pickup",1,true)
             or lower:find("binds when picked up",1,true) then
            item.bindingStatus="bop"
            item.bindingEvidence="guide-text-inference (not independently certified)"
            GetGear.DataEvidence.inferredBinding=GetGear.DataEvidence.inferredBinding+1
        elseif lower:find("binds when equipped",1,true) or
             lower:find("bind-on-equip",1,true) then
            item.bindingStatus="boe"
            item.bindingEvidence="guide-text-inference (not independently certified)"
            GetGear.DataEvidence.inferredBinding=GetGear.DataEvidence.inferredBinding+1
        else
            item.bindingStatus="unverified"
        end
    end
end
