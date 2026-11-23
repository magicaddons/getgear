-- Execute the real UI and its callbacks against measured, stateful frame mocks.
-- These checks are UI evidence, not a replacement for the Forever renderer.
local root=(arg and arg[1]) or "."
local frames={}
local methods={}
local function new(kind,name,parent)
    local frame=setmetatable({kind=kind,name=name,parent=parent,children={},points={},scripts={},shown=true,width=300,height=250,text="",level=1}, {__index=methods})
    if parent then parent.children[#parent.children+1]=frame end
    frames[#frames+1]=frame
    if name then _G[name]=frame end
    return frame
end
function methods:SetSize(w,h) self.width=w;self.height=h end
function methods:SetWidth(w) self.width=w end
function methods:SetHeight(h) self.height=h end
function methods:GetWidth() return self.width end
function methods:GetHeight() return self.height end
function methods:SetPoint(...) self.points[#self.points+1]={...} end
function methods:ClearAllPoints() self.points={} end
function methods:SetText(text) self.text=tostring(text) end
function methods:GetText() return self.text end
function methods:GetStringWidth() return #self.text*6 end
function methods:GetStringHeight()
    return math.max(1,math.ceil(#self.text*6/math.max(1,self.width)))*12
end
function methods:SetScript(event,fn) self.scripts[event]=fn end
function methods:HookScript(event,fn)
    local prev=self.scripts[event]
    self.scripts[event]=function(...) if prev then prev(...) end;fn(...) end
end
function methods:Show() self.shown=true end
function methods:Hide()
    local was=self.shown;self.shown=false
    if was and self.scripts.OnHide then self.scripts.OnHide(self) end
end
function methods:IsShown() return self.shown and (not self.parent or self.parent:IsShown()) end
function methods:CreateTexture(name) return new("Texture",name,self) end
function methods:CreateFontString(name) return new("FontString",name,self) end
function methods:GetFrameLevel() return self.level end
function methods:SetFrameLevel(n) self.level=n end
function methods:GetEffectiveScale() return 1 end
function methods:GetLeft() return 0 end
function methods:GetTop() return 800 end
function methods:SetScrollChild(child) self.child=child end
function methods:SetVerticalScroll(value) self.offset=value end
function methods:GetVerticalScroll() return self.offset or 0 end
function methods:SetEnabled(value) self.enabled=value end
function methods:SetChecked(value) self.checked=value end
function methods:GetChecked() return self.checked end
local noop=function() end
for _,method in ipairs({"SetAllPoints","SetFrameStrata","SetClampedToScreen","EnableMouse","SetColorTexture",
    "SetJustifyH","SetJustifyV","SetMovable","SetToplevel","RegisterForDrag","SetNormalTexture",
    "SetHighlightTexture","SetPushedTexture","SetAutoFocus","SetNumeric","SetMaxLetters","SetTextColor",
    "SetResizable","SetResizeBounds","SetTexture","SetVertexColor","SetDesaturated","SetMinMaxValues",
    "SetValueStep","SetObeyStepOnDrag","SetValue","SetScale","ClearFocus","Raise","StartMoving",
    "StopMovingOrSizing","StartSizing","EnableMouseWheel","RegisterForClicks",
    "SetTextInsets","SetTextColor","SetAlpha","SetBackdrop","SetBackdropColor","SetBackdropBorderColor",
    "SetDisabledTexture","SetNormalFontObject","SetHighlightFontObject","SetDisabledFontObject"}) do methods[method]=noop end
function methods:SetShown(value) if value then self:Show() else self:Hide() end end
function methods:GetEffectiveScale() return 1 end
function methods:GetScript(event) return self.scripts[event] end
CreateFrame=function(kind,name,parent,template)
    local f=new(kind,name,parent)
    if template=="UICheckButtonTemplate" then f.Text=new("FontString",nil,f) end
    return f
end
UIParent=new("Frame","UIParent");Minimap=new("Frame","Minimap")
UISpecialFrames={}
UnitName=function() return "Test" end
UnitClass=function() return "Warrior","WARRIOR" end
UnitRace=function() return "Human","Human" end
local addon={level=30,classToken="WARRIOR",className="Warrior",activeTab="available"}
assert(loadfile(root.."/GuideState.lua"))("GetGear",addon)
assert(loadfile(root.."/StatPriorities.lua"))("GetGear",addon)
local all={}
for i=1,140 do
    local slot=i<=70 and "Chest" or (i<=120 and "Main Hand" or "Ring")
    all[i]={id="test_"..i,itemID=i,name=(slot=="Chest" and string.rep("Long wrapped chest name ",5) or slot)..i,
        slot=slot,targetLevel=30,sourceType="Quest",source="Test source",zone="Test zone",
        instructions=string.rep("A long source description to exercise wrapping. ",6)}
end
addon.Gear=all
addon.db={status={},hidden={},overlay={visible=true,slotFilter="all",height=700,expanded={},minimized={},
    dependencyExpanded={},dependencyCollapsed={}},detail={slotFilter="all"}}
addon.IsGearEquipped=function() return false end
addon.GetObsoleteGearReason=function() return nil end
addon.GetCraftingMaterialRows=function(self,gear)
    local key="fixture:"..gear.id
    local expanded=self.db.overlay.dependencyExpanded[key]
    local rows={{itemID=2996,name="Bolt of Linen Cloth",amount=2,hasChildren=true,collapseKey=key,collapsed=not expanded}}
    if expanded then rows[#rows+1]={itemID=2589,name="Linen Cloth",amount=4,depth=1} end
    return rows
end
local mapped
addon.GetAcquisitionMapTarget=function() return {zone="Test zone",spot="Test source",quality="forever"} end
addon.OpenAcquisitionMap=function(_,gear) mapped=gear end
local materialCalls=0
addon.GetCombinedMaterialRows=function() materialCalls=materialCalls+1;return {} end
addon.GetUndocumentedCrafts=function() return {} end
addon.ComparisonInline=function() return string.rep("+10 Strength +20 Stamina ",9),true end
local previewedClass
addon.GetPreviewRecommendations=function(_,class) previewedClass=class;return all end
addon.GuideDefinitions={WARRIOR={}}
addon.GetGuideEmptyMessage=function() return "Original empty view message" end
C_Item={GetItemInventoryTypeByID=function(id) return id%2==0 and 13 or 21 end}
assert(loadfile(root.."/UI.lua"))("GetGear",addon)
addon:InitializeUI();addon:ShowUI()
local overlay=GetGear_TrackerOverlay
local detail=GetGear_MainWindow
local overlayMenu=GetGear_OverlaySlotMenu
local detailMenu=GetGear_DetailSlotMenu
-- Find frames through actual parent/child relations, without extracting source.
local function find(parent,fn)
    for _,f in ipairs(frames) do if f.parent==parent and fn(f) then return f end end
    error("frame not found under "..tostring(parent.name))
end
local function text(parent,pattern)
    return find(parent,function(f) return f.kind=="FontString" and f.text:find(pattern,1,true) end)
end
local function button(parent,label)
    return find(parent,function(f) return f.kind=="Button" and f.text==label end)
end
local function click(b)
    assert(b.scripts.OnClick,"button missing callback")
    b.scripts.OnClick(b,"LeftButton")
end
local function selectSlot(menu,label)
    click(menu.parent)
    assert(menu:IsShown(),"dropdown didn't open")
    click(button(menu,label))
    assert(not menu:IsShown(),"dropdown didn't close")
end
local objScroll=find(overlay,function(f) return f.kind=="ScrollFrame" and f.points[1][5]==-93 end)
local detailScroll=find(detail,function(f) return f.kind=="ScrollFrame" and f.points[1][3]==-214 end)
local objContent=objScroll.child
local detailContent=detailScroll.child
local function visibleRows(parent)
    local rows={}
    for _,f in ipairs(parent.children) do if f.kind=="Frame" and f:IsShown() then rows[#rows+1]=f end end
    table.sort(rows,function(a,b)return -a.points[1][5]<-b.points[1][5] end)
    return rows
end
local function rowItem(row)
    return find(row,function(f) return f.itemID~=nil and f.gearRecord~=nil end).gearRecord
end
local function checkRows(parent,slot,limit)
    local rows=visibleRows(parent)
    assert(#rows<=limit,"lost bounded row allocation")
    local lastY=0
    for i,row in ipairs(rows) do
        assert(rowItem(row).slot==slot,"wrong slot rendered")
        local y=-row.points[1][5]
        assert(y>=lastY,"rows overlap")
        lastY=y+row:GetHeight()
    end
    return rows
end
assert(#visibleRows(objContent)==32 and #visibleRows(detailContent)==40)
local heading=find(overlay,function(f) return f.kind=="Button" and f.children[1] and f.children[1].text:find("Showing",1,true) end)
assert(heading.children[1].text=="-  Showing 32 of 140 (140 slot matches)  |  1/5")
assert(text(detail,"Showing 40 of 140 (140 slot matches)"))
selectSlot(overlayMenu,"Chest")
assert(addon.db.overlay.slotFilter=="chest" and addon.db.detail.slotFilter=="all")
objScroll:SetVerticalScroll(25)
selectSlot(overlayMenu,"Rings")
assert(objScroll:GetVerticalScroll()==25,"unnecessary overlay scroll reset")
checkRows(objContent,"Ring",32)
assert(heading.children[1].text=="-  Showing 20 of 140 recommendations")
selectSlot(detailMenu,"Weapons")
checkRows(detailContent,"Main Hand",40)
assert(addon.db.overlay.slotFilter=="rings" and addon.db.detail.slotFilter=="weapons")
assert(text(detail,"Showing 40 of 140 (50 slot matches)"))
click(button(detail,"Next >"))
assert(#visibleRows(detailContent)==10)
assert(text(detail,"Showing 10 of 140 (50 slot matches)"))
selectSlot(detailMenu,"Rings") -- clamps page from 2 to 1
assert(#visibleRows(detailContent)==20)
assert(text(detail,"Showing 20 of 140 recommendations"))
selectSlot(detailMenu,"Head")
assert(text(detail,"Showing 0 of 140 recommendations"))
assert(text(visibleRows(detailContent)[1],"No recommendations for this slot."))
selectSlot(overlayMenu,"Head")
assert(text(objContent,"No recommendations for this slot."):IsShown())
assert(#visibleRows(objContent)==0)
-- Hide/Unhide actions bound to filtered records, including reuse after empty state.
selectSlot(overlayMenu,"Rings")
local row=visibleRows(objContent)[1]
local hidden=rowItem(row)
click(button(row,"X"))
assert(addon:IsHidden(hidden))
assert(heading.children[1].text=="-  Showing 19 of 139 recommendations")
click(button(detail,"Hidden"))
selectSlot(detailMenu,"Rings")
row=visibleRows(detailContent)[1]
assert(rowItem(row)==hidden)
click(button(row,"Restore"))
assert(not addon:IsHidden(hidden))
-- Completed/Skipped and undo remain usable while filtered.
click(button(detail,"Available Now"))
row=visibleRows(detailContent)[1]
local skipped=rowItem(row)
click(button(row,"Skip"))
click(button(detail,"Completed / Skipped"))
row=visibleRows(detailContent)[1]
assert(rowItem(row)==skipped and addon:GetStatus(skipped)=="skipped")
click(button(row,"Undo skip"))
assert(addon:GetStatus(skipped)==nil)
-- Preview shares the detail preference but never uses live hidden/progress.
selectSlot(detailMenu,"Weapons")
local overlayBefore=addon.db.overlay.slotFilter
click(button(detail,"Preview guide"))
assert(previewedClass=="WARRIOR")
click(button(detail,"Class: Warrior"))
assert(previewedClass=="ROGUE","preview filtering didn't use the browsed class")
checkRows(detailContent,"Main Hand",40)
assert(addon.db.overlay.slotFilter==overlayBefore)
selectSlot(detailMenu,"Chest")
local previewRows=checkRows(detailContent,"Chest",40)
for _,r in ipairs(previewRows) do
    assert(not button(r,"Acquired"):IsShown() and not button(r,"Hide"):IsShown())
end
click(button(detail,"Return to character"))
assert(addon.db.detail.slotFilter=="chest")
assert(next(addon.db.status)==nil and next(addon.db.hidden)==nil,"preview changed live progress")
click(button(detail,"Bags"))
assert(not detailMenu.parent:IsShown(),"dedicated Bags view should bypass selector")
click(button(detail,"Available Now"))
assert(detailMenu.parent:IsShown() and addon.db.detail.slotFilter=="chest")
-- Inventory browser remains independent of slots.
addon.AltInventory={BrowserCharacters=function() return {} end,BrowseItems=function()
    return {},{missingBanks=0,missingBags=0,partialBanks=0,characters={}}
end}
click(button(detail,"Alt inventory"))
assert(not detailMenu.parent:IsShown())
assert(text(detail,"Account inventory"))
local inventoryView=find(detail,function(f) return f.kind=="Frame" and pcall(button,f,"Return to guide") end)
click(button(inventoryView,"Return to guide"))
assert(detailMenu.parent:IsShown())
-- Reopen restores labels; repeated changes retain row bounds and measured height.
local beforeSlotMaterials=materialCalls
for n=1,3 do
    for _,entry in ipairs(addon.EquipmentSlotFilters) do
        selectSlot(overlayMenu,entry[2]);selectSlot(detailMenu,entry[2])
    end
end
assert(materialCalls==beforeSlotMaterials,'presentation-only slot switching rebuilt total materials')
selectSlot(overlayMenu,"Chest");selectSlot(detailMenu,"Chest")
addon:ToggleOverlay();addon:ToggleOverlay();addon:ToggleUI();addon:ToggleUI()
assert(overlayMenu.parent.text=="Slot: Chest" and detailMenu.parent.text=="Slot: Chest")
local chest=checkRows(objContent,"Chest",32)[1]
click(button(chest,"-"));assert(addon.db.overlay.minimized[rowItem(chest).id])
selectSlot(overlayMenu,"Rings");selectSlot(overlayMenu,"Chest")
assert(addon.db.overlay.minimized[rowItem(chest).id])
click(button(chest,"+"))
assert(chest:GetHeight()>47,"wrapped comparison height lost")
local expand=find(chest,function(f) return f.kind=="Button" and f.scripts.OnClick and f.text=="" and f.width>100 end)
click(expand)
assert(chest:GetHeight()>100,"expanded wrapped source height lost")
local material=find(chest,function(f) return f.kind=="Frame" and f.children[1] and f.children[1].text=="?/2" end)
local arrow=find(material,function(f) return f.arrowGlyph~=nil end)
local previousHeight=chest:GetHeight()
click(arrow)
assert(chest:GetHeight()==previousHeight+28,"expanded ingredients lost row height")
click(arrow)
assert(chest:GetHeight()==previousHeight,"collapsed ingredients lost row height")
local pin=find(chest,function(f) return f.pinTexture~=nil end)
click(pin)
assert(mapped==rowItem(chest),"filtered map button points at wrong item")
click(heading);assert(not objScroll:IsShown())
selectSlot(overlayMenu,"Rings");click(heading)
assert(objScroll:IsShown() and #visibleRows(objContent)==20)
local beforeFullMaterials=materialCalls
addon:RefreshOverlay()
assert(materialCalls==beforeFullMaterials+1,"full refresh must still update total materials")
detail:Hide();addon:ShowUI()
addon:ToggleOverlay();addon:ToggleOverlay()
assert(detailMenu.parent:GetText()=="Slot: Chest" and overlayMenu.parent:GetText()=="Slot: Rings")
assert(overlayMenu.parent.points[1][3]==-37 and heading.points[1][3]==-65)
-- Existing overlay-only policies precede the slot filter and its totals.
-- Each excludes a different slot; the guide must retain its own visibility.
addon.ShouldShowOverlayStatChanges=function(_,gear) return gear.itemID~=1 end
addon.ShouldShowOverlayWorldBoEDrops=function(_,gear) return gear.itemID~=71 end
addon.ShouldShowOverlayAcquisition=function(_,gear) return gear.itemID~=121 end
addon:RefreshOverlay() -- settings/gameplay changes invalidate presentation models
selectSlot(overlayMenu,"All Slots")
assert(heading.children[1].text=="-  Showing 32 of 137 (137 slot matches)  |  1/5")
selectSlot(overlayMenu,"Chest")
assert(heading.children[1].text=="-  Showing 32 of 137 (69 slot matches)  |  1/3")
selectSlot(overlayMenu,"Rings")
assert(heading.children[1].text=="-  Showing 19 of 137 recommendations")
selectSlot(detailMenu,"Rings")
assert(text(detail,"Showing 20 of 140 recommendations"))
print("PASS slot UI: real dropdown/render callbacks, counts before caps/pages, empty states, Hide/Restore/Skip/Undo, preview, Bags/inventory isolation, reopen, scroll retention, wrapped rows, collapse/minimize and repeated switching")

-- Profile the real splitter callbacks with existing wrapped rows and a large
-- material viewport. Dragging must never enter recommendation/row processing.
selectSlot(overlayMenu,"Chest")
addon.GetCombinedMaterialRows=function() materialCalls=materialCalls+1;local t={};for i=1,200 do t[i]={itemID=2996,name="Bolt of Linen Cloth",amount=i} end;return t end
addon:RefreshOverlay()
local splitter=GetGear_OverlaySectionSplitter
assert(splitter:IsShown())
local beforeFrames=#frames
local heavy=0
for _,name in ipairs({"GetItems","ComparisonInline","GetCombinedMaterialRows","GetUndocumentedCrafts","FilterEquipmentSlots"})do
 local original=addon[name]
 addon[name]=function(...) heavy=heavy+1;return original(...) end
end
local saved=addon.db.overlay.materialShare
local cursor=400
GetCursorPosition=function() return 0,cursor end
local down=true;IsMouseButtonDown=function() return down end
local start=os.clock()
splitter.scripts.OnMouseDown(splitter,"LeftButton")
for i=1,1200 do
 cursor=250+(i%300)
 splitter.scripts.OnUpdate(splitter,1/120)
 assert(addon.db.overlay.materialShare==saved,"drag wrote SavedVariables before release")
end
assert(heavy==0 and #frames==beforeFrames,"section drag rebuilt recommendations, materials, rows or frames")
local ratio=splitter.pendingShare
local point=splitter.points[1]
assert(math.abs(-point[5]-(800-cursor))<=1,"splitter failed to follow physical cursor")
down=false;splitter.scripts.OnUpdate(splitter,1/120)
assert(not splitter.dragging and not splitter.scripts.OnUpdate)
assert(addon.db.overlay.materialShare==ratio,"outside release did not persist the final split")
for i=1,20 do
 down=true;splitter.scripts.OnMouseDown(splitter,"LeftButton")
 cursor=cursor+1;splitter.scripts.OnMouseUp(splitter,"LeftButton")
 assert(not splitter.scripts.OnUpdate)
end
-- Hiding during dragging is also a terminating release, without new frames.
down=true;splitter.scripts.OnMouseDown(splitter,"LeftButton");splitter:Hide()
assert(not splitter.dragging and not splitter.scripts.OnUpdate and heavy==0 and #frames==beforeFrames)
assert(addon.db.overlay.slotFilter=="chest" and addon.db.detail.slotFilter=="rings")
print(string.format("PASS resize profile: 1200 movement ticks + repeated/outside/hidden releases; 0 heavy calls, 0 new frames; %.6fs synthetic Lua CPU (not in-game FPS)",os.clock()-start))
