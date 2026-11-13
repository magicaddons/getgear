-- Tests use Lua 5.2+'s string/environment form of load to compile fixture
-- snippets. Adapt only that test-runner API; addon source is unmodified.
local nativeLoad=load
load=function(chunk,name,mode,environment)
  local fn,err
  if type(chunk)=="string" then fn,err=loadstring(chunk,name)
  else fn,err=nativeLoad(chunk,name) end
  if fn and environment then setfenv(fn,environment) end
  return fn,err
end
local test=assert(arg[1]);local root=assert(arg[2]);arg={[0]=test,[1]=root}
assert(loadfile(test))()
