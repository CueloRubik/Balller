local Themes=require('data.arena_themes')
local P={arena='patio',reduced=false}
P.file='balller_visual_v8.txt'
function P.load()
 P.arena='patio' P.reduced=false
 local data=love.filesystem.read(P.file)
 if type(data)~='string' or #data>100 then return false end
 local arena,reduced=data:match('^BALLLER_VISUAL_1|([a-z]+)|([01])$')
 if not Themes.byId[arena] then return false end
 P.arena=arena P.reduced=reduced=='1'
 return true
end
local function store(arena,reduced)
 local ok=love.filesystem.write(P.file,'BALLLER_VISUAL_1|'..arena..'|'..(reduced and '1' or '0'))
 if not ok then return false end
 P.arena=arena P.reduced=reduced
 return true
end
function P.setArena(id)
 if not Themes.byId[id] then return false end
 return store(id,P.reduced)
end
function P.setReduced(value)
 if type(value)~='boolean' then return false end
 return store(P.arena,value)
end
function P.theme() return Themes.byId[P.arena] or Themes.list[1] end
return P
