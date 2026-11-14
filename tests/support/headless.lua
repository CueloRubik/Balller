local M={files={},blocked={}}
local noop=function() end
package.loaded['src.audio']={enabled=false,play=noop,load=noop}
love={
 keyboard={isDown=function() return false end},
 math={random=math.random,setRandomSeed=math.randomseed},
 filesystem={
  getInfo=function(path) return M.files[path] and {type='file'} or nil end,
  read=function(path) return M.files[path] end,
  write=function(path,data)
   if M.blocked[path] then return false,'simulated write failure' end
   M.files[path]=data
   return true
  end,
  remove=function(path) M.files[path]=nil return true end
 }
}
math.randomseed(8001)
function M.fixture(name)
 local f=assert(io.open('tests/fixtures/'..name,'rb'))
 local data=f:read('*a')
 f:close()
 return data
end
function M.reload(name)
 package.loaded[name]=nil
 return require(name)
end
return M
