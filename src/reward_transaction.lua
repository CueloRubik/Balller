local Run=require('src.runfile')
local Profile=require('src.profilefile')
local M={file='premios_balller_v8.pending',busy=false}
local function checksum(s)
 local a,b=1,0
 for i=1,#s do a=(a+s:byte(i))%65521 b=(b+a)%65521 end
 return tostring(b*65536+a)
end
local function pack(body) return checksum(body)..'\n'..body end
local function unpackData(raw)
 if type(raw)~='string' or #raw>18000 then return nil end
 local sum,body=raw:match('^(%d+)\n(.*)$')
 if not body or checksum(body)~=sum then return nil end
 return body
end
function M.receipt(slot,run,gems,detail)
 return pack(table.concat({'BALLLER_REWARD_RECEIPT_1',slot,run.previousRound,run.reward,gems,detail.base,detail.skill,detail.objective,detail.multiplier},'|'))
end
function M.readReceipt(raw,slot,run)
 local body=unpackData(raw)
 if not body then return nil end
 local p={} for value in body:gmatch('[^|]+') do p[#p+1]=value end
 if #p~=9 or p[1]~='BALLLER_REWARD_RECEIPT_1' then return nil end
 for i=2,9 do p[i]=tonumber(p[i]) if not p[i] or p[i]~=p[i] or p[i]<0 or p[i]>10000000 then return nil end end
 if p[2]~=slot or (run and (p[3]~=run.previousRound or p[4]~=run.reward)) then return nil end
 return {gems=p[5],base=p[6],skill=p[7],objective=p[8],multiplier=p[9]}
end
local function decode(raw)
 local body=unpackData(raw)
 if not body then return nil end
 local slot,profile,receipt,run=body:match('^BALLLER_REWARD_1|([123])\n([^\n]+)\n([^\n]+)\n(.*)$')
 slot=tonumber(slot)
 if not slot or not Profile.decode(profile) then return nil end
 local parsed=Run.decode(run)
 receipt=receipt and receipt:gsub('~','\n',1)
 if not parsed or not M.readReceipt(receipt,slot,parsed) then return nil end
 return {slot=slot,profile=profile,run=run,receipt=receipt}
end
function M.pending()
 if M.busy then return true end
 if love.filesystem.getInfo then return love.filesystem.getInfo(M.file)~=nil end
 return love.filesystem.read(M.file)~=nil
end
function M.inspect()
 local data=decode(love.filesystem.read(M.file))
 return data and data.slot
end
local function writeVerified(path,bytes)
 return love.filesystem.write(path,bytes) and love.filesystem.read(path)==bytes
end
function M.recover()
 if not love.filesystem.getInfo(M.file) then return not M.busy end
 local data=decode(love.filesystem.read(M.file))
 if not data then return false,'invalid' end
 local path='partida_'..data.slot..'.txt'
 for _,entry in ipairs({{path,data.run,Run.decode},{'perfil_balller_v7.txt',data.profile,Profile.decode},{path..'.reward',data.receipt,function(raw) return M.readReceipt(raw,data.slot) end}}) do
  local current=love.filesystem.read(entry[1])
  if current~=entry[2] then
   if entry[3](current) and not writeVerified(entry[1]..'.bak',current) then return false,'backup' end
   if not writeVerified(entry[1],entry[2]) then return false,'write' end
  end
 end
 love.filesystem.remove(M.file)
 if love.filesystem.getInfo(M.file) then return false,'remove' end
 M.busy=false
 return true
end
function M.commit(slot,run,profile,receipt)
 local encoded=Run.encode(run)
 if not encoded or not Run.decode(encoded) or not Profile.decode(profile) or not M.readReceipt(receipt,slot,run) then return false end
 if type(slot)~='number' or slot%1~=0 or slot<1 or slot>3 then return false end
 local body=table.concat({'BALLLER_REWARD_1|'..slot,profile,receipt:gsub('\n','~',1),encoded},'\n')
 local raw=pack(body)
 local existing=love.filesystem.read(M.file)
 if decode(existing) and existing~=raw then return false end
 M.busy=true
 if existing~=raw and not writeVerified(M.file,raw) then return false end
 return M.recover()
end
return M
