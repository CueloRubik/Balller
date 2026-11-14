local Runfile=require('src.runfile')
local Rewards=require('src.reward_transaction')
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
local function purchaseData(text,slot)
 if type(text)~='string' then return nil end
 local id,encoded=text:match('^BALLLER_PURCHASE_1|([123])\r?\n(.*)$')
 if tonumber(id)~=slot then return nil end
 return Runfile.decode(encoded),encoded
end
function M.hasRun(slot)
 local path=slotPath(slot)
 return path~=nil and (love.filesystem.getInfo(path)~=nil or love.filesystem.getInfo(path..'.bak')~=nil or love.filesystem.getInfo(path..'.purchase')~=nil)
end
function M.storeRun(data,slot)
 if Rewards.pending() then return false end
 local path=slotPath(slot)
 local encoded=Runfile.encode(data)
 if not path or not encoded or not Runfile.decode(encoded) then return false end
 if love.filesystem.getInfo(path..'.purchase') and not M.resolvePurchase(slot) then return false end
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
 local pending=love.filesystem.getInfo(path..'.purchase')
 if pending then
  local before=purchaseData(love.filesystem.read(path..'.purchase'),slot)
  if before then return {status='ready',data=before,pendingPurchase=true,modified=pending.modtime} end
 end
 local meta=love.filesystem.getInfo(path)
 local raw=love.filesystem.read(path)
 local data=Runfile.decode(raw)
 if data then return {status='ready',data=data,pendingPurchase=pending~=nil,modified=meta and meta.modtime} end
 local backupMeta=love.filesystem.getInfo(path..'.bak')
 local backup=love.filesystem.read(path..'.bak')
 data=Runfile.decode(backup)
 if data then return {status='recoverable',data=data,modified=backupMeta and backupMeta.modtime} end
 return {status=(meta or backupMeta or pending) and 'damaged' or 'empty'}
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
function M.resolvePurchase(slot)
 local path=slotPath(slot)
 if not path then return false end
 local journal=path..'.purchase'
 if not love.filesystem.getInfo(journal) then return true end
 local raw=love.filesystem.read(journal)
 local before,encoded=purchaseData(raw,slot)
 local diagnostic
 if before then
  if not love.filesystem.write(path,encoded) or love.filesystem.read(path)~=encoded then return false end
 else
  local ok
  ok,diagnostic=preserveDamaged(journal,raw)
  if not ok then return false end
 end
 love.filesystem.remove(journal)
 if love.filesystem.getInfo(journal) then return false end
 return true,{slot=slot,kind='purchase',diagnostic=diagnostic}
end
function M.storePurchase(before,after,slot)
 if Rewards.pending() then return false end
 local path=slotPath(slot)
 if not path then return false end
 local old,new=Runfile.encode(before),Runfile.encode(after)
 if not old or not new or not Runfile.decode(old) or not Runfile.decode(new) then return false end
 if not M.resolvePurchase(slot) then return false end
 local journal=path..'.purchase'
 local prepared='BALLLER_PURCHASE_1|'..slot..'\n'..old
 if not love.filesystem.write(journal,prepared) or love.filesystem.read(journal)~=prepared then return false end
 if not love.filesystem.write(path..'.bak',old) or love.filesystem.read(path..'.bak')~=old then return false end
 if not love.filesystem.write(path,new) or love.filesystem.read(path)~=new then return false end
 love.filesystem.remove(journal)
 if love.filesystem.getInfo(journal) then return false end
 return true
end
function M.loadRun(slot)
 if Rewards.pending() then return nil,'reward_pending' end
 local path=slotPath(slot)
 if not path then return nil,'invalid' end
 local purchase
 if love.filesystem.getInfo(path..'.purchase') then
  local ok,detail=M.resolvePurchase(slot)
  if not ok then return nil,'purchase_restore_failed' end
  purchase=detail
 end
 local state=M.inspectRun(slot)
 if state.status=='ready' then return state.data,purchase and 'purchase_recovered' or 'ready',purchase end
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
 if Rewards.pending() then return false,'reward_pending' end
 local path=slotPath(slot)
 if not path then return false end
 for _,suffix in ipairs({'.reward','.reward.bak'}) do
  if love.filesystem.getInfo(path..suffix) and not love.filesystem.remove(path..suffix) then return false,'receipt_remove_failed' end
 end
 if love.filesystem.getInfo(path) and not love.filesystem.remove(path) then return false,'primary_remove_failed' end
 if love.filesystem.getInfo(path..'.bak') and not love.filesystem.remove(path..'.bak') then return false,'backup_remove_failed' end
 if love.filesystem.getInfo(path..'.purchase') and not love.filesystem.remove(path..'.purchase') then return false,'purchase_remove_failed' end
 return true
end
function M.slotInfo(slot)
 return M.inspectRun(slot).data
end
return M
