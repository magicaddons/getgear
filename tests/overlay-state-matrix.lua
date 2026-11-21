-- Compare ordered production outputs against signatures captured on exact .9.
local root=arg[1] or '.'
local record=arg[2]=='record'
local dir=arg[0]:match('^(.*[/])') or 'tests/'
local f=assert(io.open(dir..'beta4-slot-ui.lua'));local source=f:read('*a');f:close()
source=source:sub(1,assert(source:find('local addon={',1,true))-1)
local body=[=[
local root=arg[1] or '.'
local record=arg[2]=='record'
local dir=arg[0]:match('^(.*[/])') or 'tests/' 
local class,level,side='PRIEST',1,'Alliance'
UnitClass=function()return class,class end
UnitLevel=function()return level end
UnitFactionGroup=function()return side end
UnitRace=function()return side=='Alliance' and 'Human' or 'Orc',side=='Alliance' and 'Human' or 'Orc' end
SlashCmdList={}
function methods:RegisterEvent()end
local owned=0
C_Item={GetItemCount=function()return owned end}
local addon={}
for line in io.lines(root..'/GetGear.toc')do
 if line:match('%.lua$')then assert(loadfile(root..'/'..line))('GetGear',addon)end
end
local expected=not record and assert(loadfile(dir..'fixtures/overlay-state-signatures-alliance-access.lua'))()
local contexts,slotChecks=0,0
local started=os.clock()
for _,token in ipairs({'WARRIOR','PALADIN','HUNTER','ROGUE','PRIEST','SHAMAN','MAGE','WARLOCK','DRUID'})do
 for _,faction in ipairs({'Alliance','Horde'})do
  for _,at in ipairs({1,15,30,39,40,60})do
   class,side,level=token,faction,at
   addon.classToken=class;addon.level=level
   addon.db={status={},hidden={},overlay={filterObsolete=true,bagUpgrades=true,
    hideWithoutPositiveStats=true,hideGreenBoEWorldDrops=true,countArmorOnlyUpgrades=false,
    expanded={},minimized={},dependencyCollapsed={},dependencyExpanded={},materialScope='tracked'},detail={}}
   addon:SelectCurrentGuide()
   -- Drive the real UI for every class/faction/level, using the same output
   -- oracle below. Collapse/expand must reread current inventory immediately.
   addon.db.overlay.visible=true
   addon:InitializeUI();addon:ShowUI();addon:RefreshAll()
   assert(GetGear_MainWindow:IsShown() and GetGear_TrackerOverlay:IsShown())
   addon.db.overlay.materialsCollapsed=true;addon:RefreshOverlay()
   owned=owned+1
   addon.db.overlay.materialsCollapsed=false;addon:RefreshOverlay()
   assert(addon:GetMaterialCount(2589)==owned)
   GetGear_MainWindow:Hide()
   -- Exercise history decisions separately from recommendations and levels.
   if addon.Gear[1]then addon.db.status[addon.Gear[1].id]='acquired' end
   if addon.Gear[2]then addon.db.hidden[addon.Gear[2].id]=true end
   local hash=7
   local function digest(text)for i=1,#text do hash=(hash*31+text:byte(i))%1000000007 end end
   for _,mode in ipairs({'tracker','available','upcoming','earlier','hidden','completed','bags'})do
    digest(mode)
    local list=addon:GetItems(mode)
    for _,g in ipairs(list)do digest(g.id..':'..g.targetLevel..';')end
    for _,slot in ipairs(addon.EquipmentSlotFilters)do
     local filtered=addon:FilterEquipmentSlots(list,slot[1])
     digest(slot[1])
     for _,g in ipairs(filtered)do digest(g.id..';')end
     slotChecks=slotChecks+1
    end
   end
   for _,scope in ipairs({'tracked','all'})do
    digest(scope)
    for _,m in ipairs(addon:GetCombinedMaterialRows(scope))do digest(m.itemID..':'..m.amount..':'..m.name..';')end
    for _,g in ipairs(addon:GetUndocumentedCrafts(scope))do digest('unknown:'..g.id..';')end
   end
   owned=owned+1
   assert(addon:GetMaterialCount(2589)==owned,'inventory count became stale')
   local key=class..'|'..side..'|'..level
   if record then print('STATE '..key..' '..hash)else assert(expected[key]==hash,'production output changed: '..key..' '..hash..' expected '..tostring(expected[key]))end
   assert(addon.recommendationSnapshot==nil,'snapshot escaped synchronous call')
   contexts=contexts+1
  end
 end
end
print(string.format('PASS state matrix: %d class/faction/level contexts, %d slot views; %.3fs synthetic CPU',contexts,slotChecks,os.clock()-started))
]=]
assert(load(source..body,'overlay state matrix','t',_G))()
