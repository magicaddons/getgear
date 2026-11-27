-- Production TOC/Core/UI with stateful frames; not a client-rendering claim.
local root=arg[1] or '.'
local dir=arg[0]:match('^(.*[/])') or 'tests/'
local file=assert(io.open(dir..'beta4-slot-ui.lua'));local source=file:read('*a');file:close()
local prefix=source:sub(1,assert(source:find('local addon={',1,true))-1)
local body=[=[
local originalSetText=methods.SetText
function methods:SetText(text)
 originalSetText(self,text)
 if self.kind=='EditBox' and self.scripts.OnTextChanged then self.scripts.OnTextChanged(self,false) end
end
function methods:RegisterEvent(event)self.events=self.events or {};self.events[event]=true end
function methods:SetFocus()self.focused=true end
function methods:ClearFocus()self.focused=false end
local now,queue=0,{}
C_Timer={After=function(delay,fn)queue[#queue+1]={at=now+delay,fn=fn}end}
local function advance(seconds)
 now=now+seconds
 for i=#queue,1,-1 do if queue[i].at<=now then local fn=table.remove(queue,i).fn;fn() end end
end
GetTime=function()return now end;time=function()return 1000 end
GetRealmName=function()return 'Realm'end
UnitClass=function()return 'Priest','PRIEST',5 end
UnitFactionGroup=function()return 'Alliance'end;UnitLevel=function()return 25 end
SlashCmdList={}
C_Item={GetItemCount=function()return 0 end}
local addon={}
for line in io.lines(root..'/GetGear.toc')do
 if line:match('%.lua$')then assert(loadfile(root..'/'..line))('GetGear',addon)end
end
local function event(name,...)
 for _,frame in ipairs(frames)do if frame.events and frame.events[name] and frame.scripts.OnEvent then frame.scripts.OnEvent(frame,name,...)end end
end
local sourceCalls=0;local sourceFn=addon.HasEligibleAcquisitionSource
addon.HasEligibleAcquisitionSource=function(...)sourceCalls=sourceCalls+1;return sourceFn(...)end
local db={schemaVersion=4,status={retained='skipped'},hidden={keep=true},overlay={visible=true,materialsCollapsed=true,materialScope='all'},detail={}}
GetGear_CharacterDB=db;event('ADDON_LOADED','GetGear');advance(1)
local overlay=GetGear_TrackerOverlay
local popup=GetGear_ItemSearch
local edit=GetGear_ItemSearchInput
local detail=GetGear_MainWindow
local function children(parent,predicate)
 local out={};for _,frame in ipairs(frames)do if frame.parent==parent and predicate(frame)then out[#out+1]=frame end end;return out
end
local function button(parent,label)
 return assert(children(parent,function(f)return f.kind=='Button' and f.text==label end)[1],'missing button '..label)
end
local function click(frame)assert(frame.scripts.OnClick);frame.scripts.OnClick(frame,'LeftButton')end
local function visibleRows(parent)
 return children(parent,function(f)return f.kind=='Frame' and f:IsShown() and f.points[1] and #f.children>5 end)
end
local function item(row)
 for _,child in ipairs(row.children)do if child.gearRecord then return child.gearRecord end end
end
local function findContent(parent,needle)
 for _,f in ipairs(frames)do
  if f.parent and f.parent.parent==parent and f.kind=='Frame' and f.parent.kind=='ScrollFrame' then return f end
 end
end
local objContent=findContent(overlay)
assert(objContent)
local function starButton(row)
 return assert(children(row,function(f)return f.kind=='Button' and f.starTexture~=nil end)[1])
end
addon:ShowUI()
local detailContent=findContent(detail)
assert(detailContent)
local normalIDs={};for _,r in ipairs(addon:GetItems('tracker'))do normalIDs[#normalIDs+1]=r.itemID end
local beforeMaterials=addon:GetCombinedMaterialRows('tracked')
assert(not addon.itemSearchIndex,'ordinary startup eagerly indexed names')
local searchButton=assert(children(overlay,function(f)return f.kind=='Button' and f.width==24 and f.text=='' end)[1])
click(searchButton);assert(popup:IsShown() and edit.focused)
edit:SetText('no matching equipment 0192837465')
local empty=false
for _,f in ipairs(popup.children)do if f.kind=='FontString' and f.text=='No matching equipment.' then empty=true end end
assert(empty)
click(searchButton);assert(not popup:IsShown())
-- Find a future class/faction-valid objective and exercise actual search callbacks.
local future
for _,r in ipairs(addon.Gear)do
 if r.targetLevel>=40 and not r.reagents and not addon:IsCraftMaterialsUnknown(r)
    and not addon:GetSearchRestriction(addon:GetSearchRecord(r.itemID),true) then future=r;break end
end
assert(future)
popup:Show();edit:SetText(future.name)
assert(#addon:SearchEquipment(future.name,6)>0)
edit.scripts.OnArrowPressed(edit,'DOWN');edit.scripts.OnArrowPressed(edit,'UP')
edit.scripts.OnEnterPressed(edit)
assert(addon.focusedSearchItem and addon.focusedSearchItem.itemID==future.itemID)
assert(addon.db.overlay.slotFilter=='all' and addon.db.detail.slotFilter=='all')
local focus
for _,f in ipairs(popup.children)do if f.kind=='Frame' and f:IsShown() and f.height==330 then focus=f end end
assert(focus)
click(starButton(focus));assert(addon:IsItemStarred(future.itemID))
local function contains(parent,id)
 for _,row in ipairs(visibleRows(parent))do local r=item(row);if r and r.itemID==id then return row end end
end
assert(contains(objContent,future.itemID) and contains(detailContent,future.itemID),'future star did not appear in both views')
local afterIDs={};for _,r in ipairs(addon:GetItems('tracker'))do afterIDs[#afterIDs+1]=r.itemID end
assert(table.concat(afterIDs,',')==table.concat(normalIDs,','),'starring changed underlying recommendations')
local function materialSignature(rows)
 local out={};for _,r in ipairs(rows)do out[#out+1]=r.itemID..':'..r.amount end;return table.concat(out,',')
end
assert(materialSignature(addon:GetCombinedMaterialRows('tracked'))==materialSignature(beforeMaterials),'future wishlist changed material totals')

-- Source/material comparisons from rows already rendered are reused on star clicks.
local calls={};local originals={}
for _,name in ipairs({'GetItems','GetStarredMaterialRows','GetCraftingMaterialRows','GetEligibleAcquisitionRoutes','GetGearComparison'})do
 originals[name]=addon[name];addon[name]=function(...)calls[name]=(calls[name]or 0)+1;return originals[name](...)end
end
-- Warm both arrangements once; no repeated full guide or totals rebuilds.
addon:SetItemStarred(future.itemID,false);addon:SetItemStarred(future.itemID,true)
calls={};local frameCount=#frames
for _=1,40 do assert(addon:SetItemStarred(future.itemID,false));assert(addon:SetItemStarred(future.itemID,true))end
assert(not calls.GetItems and not calls.GetStarredMaterialRows,'non-craft star click recomputed recommendations/totals')
print('TOGGLE source='..(calls.GetEligibleAcquisitionRoutes or 0)..' comparisons='..(calls.GetGearComparison or 0)..' materials='..(calls.GetCraftingMaterialRows or 0));assert((calls.GetEligibleAcquisitionRoutes or 0)<=160,'star toggles repeated source work')
assert(#frames==frameCount,'repeated star toggles grew row pools')
for name,fn in pairs(originals)do addon[name]=fn end
-- Cross-surface star controls use the same ID and update the other view immediately.
click(starButton(contains(detailContent,future.itemID)));assert(not addon:IsItemStarred(future.itemID))
addon:SetItemStarred(future.itemID,true)
click(starButton(contains(objContent,future.itemID)));assert(not addon:IsItemStarred(future.itemID))
-- Hide/restore, skip/undo and acquire/undo work on the focused future item.
click(button(focus,'Hide'));assert(addon:IsHidden(future) and not contains(objContent,future.itemID))
click(button(focus,'Restore'));assert(not addon:IsHidden(future))
click(button(focus,'Skip'));assert(addon:GetStatus(future)=='skipped')
click(button(focus,'Undo skip'));assert(addon:GetStatus(future)==nil)
click(button(focus,'Acquired'));assert(addon:GetStatus(future)=='acquired')
click(button(focus,'Undo'));assert(addon:GetStatus(future)==nil)
-- Escape clears the session focus without modifying any saved choices.
edit.scripts.OnEscapePressed(edit);assert(not popup:IsShown() and not addon.focusedSearchItem)
-- Restore a pre-fix star without silently deleting the user's selection.
-- Production composition must remove it from actionable guide/tracker lists.
db.starredItems[14147]=true
addon:RefreshAll()
assert(not addon:HasEligibleAcquisitionSource(addon.ItemCatalog[14147]))
assert(db.starredItems[14147]==true,'acquisition correction erased saved star')
for _,mode in ipairs({'available','tracker'})do
 for _,g in ipairs(addon:ComposeStarredItems(addon:GetItems(mode),mode,nil,true))do
  assert(g.itemID~=14147,'saved RFC star bypassed production acquisition checks')
 end
end
db.starredItems[14147]=nil
-- The total follows actionable stars even with the old All setting saved.
local function assertMaterials(...)
 local expected={}
 for _,gear in ipairs({...})do
  for _,mat in ipairs(gear.reagents)do expected[mat.itemID]=(expected[mat.itemID] or 0)+mat.amount end
 end
 for _,frame in ipairs(frames)do
  if frame.aggregate and frame.texture and frame:IsShown() and (frame.material.depth or 0)==0 then
   assert(expected[frame.itemID]==frame.material.amount,'unexpected starred materials for '..frame.itemID)
   expected[frame.itemID]=nil
  end
 end
 assert(not next(expected),'missing starred material rows')
end
local currentCrafts={}
for _,gear in ipairs(addon:GetItems('tracker'))do
 for _,mat in ipairs(gear.reagents or {})do currentCrafts[mat.itemID]=gear end
end
local craft, futureCraft
for _,gear in ipairs(addon.Gear)do
 if gear.targetLevel>30 and gear.reagents
    and not addon:GetSearchRestriction(addon:GetSearchRecord(gear.itemID),true) then
  for _,mat in ipairs(gear.reagents)do
   if currentCrafts[mat.itemID] then craft=currentCrafts[mat.itemID];futureCraft=gear;break end
  end
  if futureCraft then break end
 end
end
assert(futureCraft,'catalogue fixture needs current and future crafts with a shared reagent')
db.overlay.materialsCollapsed=false;addon:RefreshOverlay();assertMaterials()
assert(addon:SetItemStarred(craft.itemID,true));assertMaterials(craft)
assert(addon:SelectSearchItem(futureCraft.itemID))
click(starButton(focus));assertMaterials(craft,futureCraft)
addon:SetEquipmentSlotFilter('overlay','bags');addon:RefreshOverlayPresentation();assertMaterials(craft,futureCraft)
addon:SetHidden(craft,true);assertMaterials(futureCraft)
addon:SetHidden(craft,false);assertMaterials(craft,futureCraft)
addon:SetStatus(craft,'acquired');assertMaterials(futureCraft)
addon:SetStatus(craft,nil);assertMaterials(craft,futureCraft)
assert(addon:SetItemStarred(craft.itemID,false));assertMaterials(futureCraft)
local compileMaterials=addon.GetStarredMaterialRows
addon.GetStarredMaterialRows=function(self,stars,expanded)
 assert(not expanded,'collapsed tracker built material rows')
 return compileMaterials(self,stars,expanded)
end
db.overlay.materialsCollapsed=true;addon:RefreshOverlay()
assert(addon:SetItemStarred(futureCraft.itemID,false));assertMaterials()
addon.GetStarredMaterialRows=compileMaterials
db.overlay.materialsCollapsed=false;addon:RefreshOverlay();assertMaterials()
local undocumented={name='Undocumented craft',profession='Tailoring'}
local automaticBag={bagUpgrade=true,reagents=craft.reagents}
local rows,missing,hasMaterials=compileMaterials(addon,{[1]=undocumented,[2]=automaticBag},true)
assert(#rows==0 and missing[1]==undocumented and #missing==1 and not hasMaterials)
db.overlay.materialsCollapsed=true
addon:SetEquipmentSlotFilter('overlay','all');addon:RefreshOverlay();edit.scripts.OnEscapePressed(edit)
-- A full-class wishlist has bounded rendered rows and direct ordinary navigation.
local valid={}
for _,r in ipairs(addon.Gear)do
 if not addon:GetSearchRestriction(addon:GetSearchRecord(r.itemID),false) then
  db.starredItems[r.itemID]=true;valid[#valid+1]=r
 end
end
addon:RefreshAll();assert(#valid>1000)
local starCount=0;for _ in pairs(db.starredItems)do starCount=starCount+1 end
for _,slot in ipairs(addon.EquipmentSlotFilters)do
 addon:SetEquipmentSlotFilter('overlay',slot[1]);addon:RefreshOverlay()
 for _,row in ipairs(visibleRows(objContent))do local r=item(row);if r then assert(addon:MatchesEquipmentSlotFilter(r,slot[1]))end end
end
addon:SetEquipmentSlotFilter('overlay','all');addon:RefreshOverlay()
local afterCount=0;for _ in pairs(db.starredItems)do afterCount=afterCount+1 end
assert(afterCount==starCount,'slot navigation modified stars')
assert(#visibleRows(objContent)<=32 and #visibleRows(detailContent)<=40)
local last=valid[#valid];addon:SetEquipmentSlotFilter('overlay','all')
local nextPage=button(overlay,'>')
local pages=0
while nextPage.enabled do click(nextPage);pages=pages+1;assert(pages<200)end
assert(pages>1,'wishlist pages inaccessible')
-- Give ordinary recommendations their own reachable page even after many stars.
local ordinary=addon:GetItems('tracker')[1]
db.starredItems[ordinary.itemID]=nil;addon:RefreshOverlay()
click(button(overlay,'All v'));click(button(GetGear_OverlayGroupMenu,'Other'))
assert(contains(objContent,ordinary.itemID),'Other group did not reach normal recommendations')
-- Every restored star needs a cheap eligibility check. Expensive navigation
-- and source presentation remain bounded to visible rows, even on a full wishlist.
local choicesCalls=0;local choicesFn=addon.GetAcquisitionNavigationChoices
addon.GetAcquisitionNavigationChoices=function(...)choicesCalls=choicesCalls+1;return choicesFn(...)end
sourceCalls=0
addon:RefreshOverlay()
assert(sourceCalls<starCount+650,'wishlist repeated eligibility scans')
assert(choicesCalls<150,'off-page wishlist built navigation/source pages')
addon.GetAcquisitionNavigationChoices=choicesFn
-- Preview cannot write progress or stars, including another class.
click(button(detail,'Preview guide'))
local previewRow=visibleRows(detailContent)[1];assert(previewRow)
local control=starButton(previewRow);assert(control.enabled==false)
local id=control.record.itemID;local previous=addon:IsItemStarred(id);click(control);assert(addon:IsItemStarred(id)==previous)
assert(addon:SetItemStarred(id,not previous))
assert(control.starred==not previous,'Preview star did not reflect the character state')
assert(control.enabled==false)
addon:SetItemStarred(id,previous)
click(button(detail,'Return to character'))
-- Reload and two character DBs use existing per-character initialization.
local saved=db;event('ADDON_LOADED','GetGear');assert(addon.db==saved and next(saved.starredItems))
GetGear_CharacterDB={schemaVersion=4,overlay={visible=false},detail={}};event('ADDON_LOADED','GetGear')
assert(not next(addon.db.starredItems) and not addon:IsItemStarred(valid[1].itemID))
GetGear_CharacterDB=saved;event('ADDON_LOADED','GetGear');assert(addon:IsItemStarred(valid[1].itemID))
assert(saved.status.retained=='skipped' and saved.hidden.keep==true)
-- Normal inventory/gathering events refresh current state; close both windows first.
addon:ToggleUI();saved.overlay.visible=false;addon:RefreshOverlay()
local listCalls=0;local getItems=addon.GetItems
addon.GetItems=function(...)listCalls=listCalls+1;return getItems(...)end
for _=1,10 do event('BAG_UPDATE_DELAYED');event('CHAT_MSG_SKILL')end;advance(.2)
assert(listCalls==0,'closed windows did heavy wishlist/recommendation work')
print('PASS production search selection/focus, arrows/Enter/Escape; cross-view stars; 80 toggle pool/material budgets; large wishlist paging/source budget; Preview read-only; Core reload/character independence; inventory/gathering hidden-window budgets')
]=]
assert(load(prefix..body,'item search stars UI','t',_G))()
