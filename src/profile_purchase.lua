local Codec=require('src.profilefile')
local M={file='perfil_balller_v7.txt.purchase'}
local path='perfil_balller_v7.txt'
local function previous(raw)
 if type(raw)~='string' then return nil end
 local data=raw:match('^BALLLER_PROFILE_PURCHASE_1\n(.*)$')
 return Codec.decode(data) and data or nil
end
local function writeVerified(file,data)
 return love.filesystem.write(file,data) and love.filesystem.read(file)==data
end
function M.pending()
 if love.filesystem.getInfo then return love.filesystem.getInfo(M.file)~=nil end
 return love.filesystem.read(M.file)~=nil
end
function M.recover()
 if not M.pending() then return true end
 local raw=love.filesystem.read(M.file)
 local before=previous(raw)
 if before then
  if love.filesystem.read(path)~=before and not writeVerified(path,before) then return false end
 else
  if type(raw)~='string' then return false end
  local preserved=false
  for index=0,99 do
   local name=M.file..'.damaged'..(index==0 and '' or '.'..index)
   local existing=love.filesystem.read(name)
   if existing==raw then preserved=true break end
   if not existing then preserved=writeVerified(name,raw) break end
  end
  if not preserved then return false end
 end
 love.filesystem.remove(M.file)
 return not M.pending()
end
function M.commit(before,after)
 if not Codec.decode(before) or not Codec.decode(after) or not M.recover() then return false end
 if not writeVerified(M.file,'BALLLER_PROFILE_PURCHASE_1\n'..before) then return false end
 if not writeVerified(path..'.bak',before) then return false end
 if not writeVerified(path,after) then return false end
 love.filesystem.remove(M.file)
 return not M.pending()
end
return M
