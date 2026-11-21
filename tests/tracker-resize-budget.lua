-- Extend the existing real UI fixture and drag benchmark with idle geometry
-- budgets, repeated release and scroll-clamping checks. No renderer claim.
local dir=arg[0]:match('^(.*[/])')or'tests/'
local f=assert(io.open(dir..'beta4-slot-ui.lua'));local source=f:read('*a');f:close()
local extra=[=[
splitter:Show();down=true;cursor=400
splitter.scripts.OnMouseDown(splitter,'LeftButton')
local changes=0
for _,method in ipairs({'SetHeight','SetPoint','ClearAllPoints'})do
 local old=methods[method]
 methods[method]=function(...)changes=changes+1;return old(...)end
end
local before=#frames;local started=os.clock()
for _=1,5000 do splitter.scripts.OnUpdate(splitter,1/120)end
assert(changes==0 and #frames==before and heavy==0,'stationary cursor repeated layout or content work')
-- Huge scroll positions are clamped by geometry without reconstructing rows.
objScroll:SetVerticalScroll(100000);cursor=cursor-20
splitter.scripts.OnUpdate(splitter,1/120)
assert(objScroll:GetVerticalScroll()<100000 and changes>0 and heavy==0 and #frames==before)
splitter.scripts.OnMouseUp(splitter,'LeftButton')
local saved=addon.db.overlay.materialShare
splitter.scripts.OnMouseUp(splitter,'LeftButton');splitter:Hide()
assert(addon.db.overlay.materialShare==saved and not splitter.scripts.OnUpdate)
print(string.format('PASS resize budget: 5000 stationary ticks, zero geometry writes/frames/heavy work; movement clamps scroll, repeated release persists once; %.6fs synthetic CPU',os.clock()-started))
]=]
assert(load(source..extra,'resize budget','t',_G))()
