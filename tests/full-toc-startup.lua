-- Synthetic Blizzard frame API: load order/dependency smoke, not rendering.
local root=assert(arg[1]);local addon={};local methods={}
local mt={__index=methods}
local function frame(name)
 local f=setmetatable({scripts={},shown=false,width=800,height=600,text=""},mt)
 if name then _G[name]=f end
 return f
end
for _,m in ipairs({"SetResizable","SetResizeBounds","SetTextColor","SetPoint","ClearAllPoints","SetFrameStrata","SetFrameLevel","SetClampedToScreen","SetMovable","EnableMouse","RegisterForDrag","RegisterForClicks","SetBackdrop","SetBackdropColor","SetBackdropBorderColor","SetNormalTexture","SetHighlightTexture","SetPushedTexture","SetDisabledTexture","SetTexture","SetColorTexture","SetVertexColor","SetAllPoints","SetTexCoord","SetAlpha","SetFont","SetJustifyH","SetJustifyV","SetWordWrap","SetNonSpaceWrap","SetMaxLines","SetSpacing","SetScript","HookScript","RegisterEvent","SetScrollChild","EnableMouseWheel","SetVerticalScroll","SetHorizontalScroll","SetAutoFocus","SetMultiLine","SetNumeric","SetMaxLetters","SetTextInsets","SetHitRectInsets","SetMinMaxValues","SetValueStep","SetObeyStepOnDrag","SetOrientation","SetThumbTexture","SetParent","SetEnabled","Enable","Disable","SetChecked","SetValue","SetNormalFontObject","SetHighlightFontObject","SetDisabledFontObject"}) do methods[m]=function() end end
methods.SetScript=function(self,k,v)self.scripts[k]=v end
methods.GetScript=function(self,k)return self.scripts[k]end
methods.SetText=function(self,v)self.text=v or ""end
methods.GetText=function(self)return self.text end
methods.SetWidth=function(self,v)self.width=v end
methods.SetHeight=function(self,v)self.height=v end
methods.SetSize=function(self,w,h)self.width=w;self.height=h end
methods.GetWidth=function(self)return self.width end
methods.GetHeight=function(self)return self.height end
methods.GetStringWidth=function(self)return #tostring(self.text)*6 end
methods.GetStringHeight=function()return 14 end
methods.GetFont=function()return "Fonts/FRIZQT__.TTF",12,""end
methods.GetFontString=function()return frame()end
methods.CreateTexture=function()return frame()end
methods.CreateFontString=function()return frame()end
methods.Show=function(self)self.shown=true end
methods.Hide=function(self)self.shown=false end
methods.IsShown=function(self)return self.shown end
methods.GetFrameLevel=function()return 1 end
methods.GetVerticalScroll=function()return 0 end
methods.GetEffectiveScale=function()return 1 end
methods.GetValue=function()return 1 end
methods.GetChecked=function()return false end
UIParent=frame();UISpecialFrames={};SlashCmdList={}
CreateFrame=function(kind,name,parent,template)return frame(name)end
UnitClass=function()return "Warrior","WARRIOR",1 end
UnitLevel=function()return 30 end
UnitRace=function()return "Human","Human"end
UnitFactionGroup=function()return "Alliance"end
local n=0
for line in assert(io.open(root.."/GetGear.toc")):read("*a"):gmatch("[^\r\n]+") do
 if line:match("%.lua$")then assert(loadfile(root.."/"..line))("GetGear",addon);n=n+1 end
end
assert(n==26 and addon.CatalogueAudit.items==7707 and addon.CatalogueAudit.objectives==36255)
assert(type(addon.OpenAcquisitionMap)=="function"and type(addon.GetAcquisitionMapTarget)=="function"and type(addon.ShowAcquisitionChoices)=="function"and type(addon.ShowAcquisitionDirections)=="function")
assert(type(SlashCmdList.GETGEAR)=="function")
print("PASS full TOC smoke:26modules including Core/UI/AltInventory;shared navigation helpers/slash command;no external addon library;synthetic frames only")
