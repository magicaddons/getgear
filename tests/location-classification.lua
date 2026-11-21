-- Exercise generated classifications through the accepted, unchanged renderer.
local dir=arg[0]:match('^(.*[/])')or'tests/'
local function read(name)local f=assert(io.open(dir..name));local text=f:read('*a');f:close();return text end
local base=read('navigation-marker-system.lua')
local prefix=base:sub(1,assert(base:find('local canvas=frame()',1,true))-1)
local rendering=assert(read('navigation-rendering-integrity.lua'):match('local body=%[=%[(.*)%]=%]'))
local geometry=rendering:sub(1,assert(rendering:find('local cases=',1,true))-1)
local body=[=[
local fixture={itemID=999999,name='Reported-point fixture'}
a.AcquisitionNavigationData.items['999999']={routes={{kind='recipe_vendor',source='npc:256735'}}}
local source=a.AcquisitionNavigationData.sources['npc:256735']
local loc=assert(source.locations[1]);assert(loc.locationClass=='reported-point'and loc.locationConfidence=='credible-reported')
assert(loc.x==10 and loc.y==72.7 and loc.uiMapID==1433 and not loc.bounds)
assert(loc.originalBounds.yMin==72.4 and loc.originalBounds.yMax==72.8)
local evidence=loc.coordinateEvidence
assert(evidence.independentFamilyCount==1,'mirrored publications inflated evidence independence')
assert(evidence.selectedObservation.kind=='build-attributed-point'and #evidence.rejectedObservations>0)
assert(evidence.geometry.geometryStatus=='published-classic-frame-reference')
local choice=assert(a:GetAcquisitionNavigationChoices(fixture)[1])
assert(choice.locationClass=='reported-point'and choice.coordinateEvidence==evidence)
assert(choice.instructions:find('not independently verified',1,true))
assert(a:GetAcquisitionDirections(fixture):find('Reported navigation point',1,true))
assert(a:OpenAcquisitionMap(fixture,choice.id))
local target,pin=a:GetAcquisitionMarkerState()
assert(target.x==10 and target.y==72.7 and pin:IsShown()and pin.icon:IsVisible()and not pin.area:IsShown())
assert(pin.label.text=='Mivin Shadowweave'and pin.parent==canvas and pin.level>2001)
assert(math.abs(pin.point[4]*pin.scale/canvas.width-.1)<.000001)
assert(math.abs(-pin.point[5]*pin.scale/canvas.height-.727)<.000001)
for _=1,5 do assert(a:OpenAcquisitionMap(fixture,choice.id));assert(select(2,a:GetAcquisitionMarkerState())==pin)end
-- An explicitly unresolved service retains an area and separate qualification.
local uncertain={itemID=999998,name='Uncertain service fixture'}
a.AcquisitionNavigationData.items['999998']={routes={{kind='vendor',source='npc:1347'}}}
assert(a:OpenAcquisitionMap(uncertain))
target,pin=a:GetAcquisitionMarkerState()
assert(target.locationClass=='approximate-area'and not target.x and target.bounds)
assert(pin.area:IsShown()and not pin.icon:IsShown()and pin.qualifier:IsShown())
-- Documented fixed-spawn points remain separate choices through the same API.
local multiple={itemID=999997,name='Fixed-spawn fixture'}
a.AcquisitionNavigationData.sources['npc:999997']={name='Fixed-spawn fixture',kind='npc',locations={
 {zone='Redridge Mountains',uiMapID=1433,x=20,y=30,spawnID='a',verification='published-reference',locationClass='multiple-spawn-points'},
 {zone='Redridge Mountains',uiMapID=1433,x=20,y=30,spawnID='b',verification='published-reference',locationClass='multiple-spawn-points'}}}
a.AcquisitionNavigationData.items['999997']={routes={{kind='vendor',source='npc:999997'}}}
local alternatives=a:GetAcquisitionNavigationChoices(multiple)
assert(#alternatives==2 and alternatives[1].id~=alternatives[2].id)
for _,t in ipairs(alternatives)do
 assert(a:OpenAcquisitionMap(multiple,t.id))
 local placed,owned=a:GetAcquisitionMarkerState()
 assert(placed.x==t.x and placed.y==t.y and placed.spawnID==t.spawnID and placed.locationClass=='multiple-spawn-points')
 assert(owned==pin and owned.icon:IsVisible())
end
print('PASS location classification: generated Mivin reported point/provenance/uncertainty, correct Redridge target and visible named pin above map art, reusable marker and retained uncertain area; synthetic only')
]=]
assert(load(prefix..geometry..body,'location classification runtime','t',_G))()
