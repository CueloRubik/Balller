local Runfile=require('src.runfile')
local M={best=0,total=0,games=0,sound=true,tutorialDone=false}
local function safeNum(v) return math.max(0,tonumber(v) or 0) end
function M.load()
 if not love.filesystem.getInfo('save.txt') then return end
 local data=love.filesystem.read('save.txt')
 if type(data)~='string' then return end
 local a,b,c,d,e=data:match('^(%d+)|(%d+)|(%d+)|([01])|?([01]?)')
 if a then
  M.best=safeNum(a)
  M.total=safeNum(b)
  M.games=safeNum(c)
  M.sound=d=='1'
  M.tutorialDone=e=='1'
 end
end
function M.store()
 local str=table.concat({math.floor(M.best),math.floor(M.total),math.floor(M.games),M.sound and 1 or 0,M.tutorialDone and 1 or 0},'|')
 if love.filesystem.read('save.txt')==str then return true end
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
 if not path or not encoded or not Runfile.decode(encoded) then return false end
 local previous=love.filesystem.read(path)
 if previous and Runfile.decode(previous) then
  local backed=love.filesystem.write(path..'.bak',previous)
  if not backed then return false end
 end
 return love.filesystem.write(path,encoded)
end
function M.inspectRun(slot)
 local path=slotPath(slot)
 if not path then return {status='invalid'} end
 local meta=love.filesystem.getInfo(path)
 local raw=love.filesystem.read(path)
 local data=Runfile.decode(raw)
 if data then return {status='ready',data=data,modified=meta and meta.modtime} end
 local backupMeta=love.filesystem.getInfo(path..'.bak')
 local backup=love.filesystem.read(path..'.bak')
 data=Runfile.decode(backup)
 if data then return {status='recoverable',data=data,modified=backupMeta and backupMeta.modtime} end
 return {status=(meta or backupMeta) and 'damaged' or 'empty'}
end
local function preserveDamaged(path,raw)
 if not love.filesystem.getInfo(path) then return true,nil end
 if type(raw)~='string' then return false end
 for index=0,99 do
  local archived=path..'.damaged'..(index==0 and '' or ('.'..index))
  if not love.filesystem.getInfo(archived) then
   if not love.filesystem.write(archived,raw) or love.filesystem.read(archived)~=raw then return false end
   return true,archived
  elseif love.filesystem.read(archived)==raw then return true,archived end
 end
 return false
end
function M.loadRun(slot)
 local path=slotPath(slot)
 if not path then return nil,'invalid' end
 local state=M.inspectRun(slot)
 if state.status=='ready' then return state.data,'ready' end
 if state.status~='recoverable' then return nil,state.status end
 local backup=love.filesystem.read(path..'.bak')
 local parsed=Runfile.decode(backup)
 if not parsed then return nil,'damaged' end
 local preserved,archived=preserveDamaged(path,love.filesystem.read(path))
 if not preserved then return nil,'preserve_failed' end
 if not love.filesystem.write(path,backup) then return nil,'restore_failed' end
 if love.filesystem.read(path)~=backup then return nil,'restore_failed' end
 return parsed,'recovered',{archive=archived,slot=slot}
end
function M.clearRun(slot)
 local path=slotPath(slot)
 if not path then return false end
 if love.filesystem.getInfo(path) and not love.filesystem.remove(path) then return false,'primary_remove_failed' end
 if love.filesystem.getInfo(path..'.bak') and not love.filesystem.remove(path..'.bak') then return false,'backup_remove_failed' end
 return true
end
function M.slotInfo(slot)
 return M.inspectRun(slot).data
end
return M
