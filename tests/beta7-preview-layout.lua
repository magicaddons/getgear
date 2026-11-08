-- Regression for Preview Guide toolbar collision fixed in Beta5.
-- Run: lua5.4 tests/beta7-preview-layout.lua .
-- Extract only the button-positioning function; execute it with frame mocks
-- so the actual UI anchors are verified without requiring WoW's frame API.
local root=(arg and arg[1]) or "."
local file=assert(io.open(root.."/UI.lua","r"))
local source=file:read("*a")
file:close()
assert(source:find('previewClassButton:SetPoint("TOPLEFT", 18, -122)',1,true),
    "Preview class selector moved: revisit toolbar geometry")
assert(source:find('previewFullButton:SetPoint("TOPLEFT", 328, -122)',1,true),
    "Preview Full 1-60 button moved: revisit toolbar geometry")
assert(source:find('local inPreview = preview.active',1,true)
    and source:find('PositionDisplaySettingsForPreview(inPreview)',1,true),
    "Preview settings repositioning must run on each RefreshUI mode switch")
local body=source:match("local function PositionDisplaySettingsForPreview%(active%)%s*(.-)\nend")
assert(body,"Preview settings layout helper missing")
local last={}
local button={
    ClearAllPoints=function(self)last.cleared=true end,
    SetPoint=function(self,...)last.args={...} end,
}
local full={}
local factory=assert(load("return function(active)\n"..body.."\nend",
    "PositionDisplaySettingsForPreview","t",{optionsButton=button,previewFullButton=full}))
local position=factory()
position(true)
assert(last.cleared,"Previous conflicting anchors weren't cleared")
assert(last.args[1]=="LEFT" and last.args[2]==full
    and last.args[3]=="RIGHT" and last.args[4]==8 and last.args[5]==0,
    "Preview Display settings must sit RIGHT of Full 1-60 with 8px gap")
-- 720px is the documented minimum detailed-window width. Class control
-- ends at x169, Full 1-60 ends at 484, and Display settings ends at 622.
local classRight=18+151
local fullRight=328+156
local settingsLeft=fullRight+last.args[4]
local settingsRight=settingsLeft+130
assert(classRight<settingsLeft and fullRight<settingsLeft and settingsRight<=720,
    "Preview controls overlap or overflow minimum window width")
last={}
position(false)
assert(last.cleared and last.args[1]=="TOPLEFT"
    and last.args[2]==18 and last.args[3]==-122,
    "Settings button must be restored to left of normal (non-preview) toolbar")
assert(source:find('optionsButton:Hide()',1,true),
    "Display settings must remain hidden in inventory subview")
print("PASS Beta7 Preview Guide: no overlap, settings next to Full 1-60, 720px fit and correct normal/inventory transitions")
