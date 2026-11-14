local Runfile=require('src.runfile')
local M={best=0,total=0,games=0,sound=true}
local function safeNum(v) return math.max(0,tonumber(v) or 0) end
function M.load()
 if not love.filesystem.getInfo('save.txt') then return end
 local data=love.filesystem.read('save.txt')
 if type(data)~='string' then return end
 local a,b,c,d=data:match('^(%d+)|(%d+)|(%d+)|([01])')
 if a then
  M.best=safeNum(a)
  M.total=safeNum(b)
  M.games=safeNum(c)
  M.sound=d=='1'
 end
end
function M.store()
 local str=table.concat({math.floor(M.best),math.floor(M.total),math.floor(M.games),M.sound and 1 or 0},'|')
 return love.filesystem.write('save.txt',str)
end
function M.record(score)
 score=math.max(0,math.floor(score))
 M.best=math.max(M.best,score)
 M.total=M.total+score
 M.games=M.games+1
 M.store()
end
local function slotPath(slot)
 if type(slot)~='number' or slot%1~=0 or slot<1 or slot>3 then return nil end
 return 'partida_'..slot..'.txt'
end
function M.hasRun(slot)
 local path=slotPath(slot)
 return path~=nil and (love.filesystem.getInfo(path)~=nil or love.filesystem.getInfo(path..'.bak')~=nil)
end
function M.storeRun(data,slot)
 local path=slotPath(slot)
 local encoded=Runfile.encode(data)
 if not path or not encoded then return false end
 local previous=love.filesystem.read(path)
 if previous and Runfile.decode(previous) then
  local backed=love.filesystem.write(path..'.bak',previous)
  if not backed then return false end
 end
 return love.filesystem.write(path,encoded)
end
function M.loadRun(slot)
 local path=slotPath(slot)
 if not path or not M.hasRun(slot) then return nil end
 local data=love.filesystem.read(path)
 local parsed=Runfile.decode(data)
 if parsed then return parsed end
 local backup=love.filesystem.read(path..'.bak')
 parsed=Runfile.decode(backup)
 if parsed then love.filesystem.write(path,backup) end
 return parsed
end
function M.clearRun(slot)
 local path=slotPath(slot)
 if not path then return false end
 local result=true
 if love.filesystem.getInfo(path) then result=love.filesystem.remove(path) and result end
 if love.filesystem.getInfo(path..'.bak') then result=love.filesystem.remove(path..'.bak') and result end
 return result
end
function M.slotInfo(slot)
 return M.loadRun(slot)
end
return M
