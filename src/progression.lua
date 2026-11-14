local P={gems=0,stars=0,hits=0,rounds=0,plays=0,best={0,0,0,0},owned={true,false,false,false},skin=1,dirty=false}
P.skins={
 {name='Original',sprite='ball',cost=0,desc='La pelota de siempre'},
 {name='Océano',sprite='ball_ocean',cost=4,desc='Azul brillante'},
 {name='Fresa',sprite='ball_berry',cost=8,desc='Rosada y divertida'},
 {name='Galaxia',sprite='ball_violet',cost=12,desc='Morada y luminosa'}
}
P.achievements={
 {id='hits',name='Buen toque',hint='Golpea 50 veces la pelota',target=50,icon='star'},
 {id='stars',name='Coleccionista',hint='Atrapa 20 estrellas',target=20,icon='spark'},
 {id='rounds',name='Superviviente',hint='Supera 10 rondas',target=10,icon='flag'},
 {id='plays',name='Siempre listo',hint='Juega 5 partidas',target=5,icon='play'}
}
local file='perfil_balller_v7.txt'
local function checksum(s)
 local a,b=1,0
 for i=1,#s do a=(a+s:byte(i))%65521 b=(b+a)%65521 end
 return tostring(b*65536+a)
end
local function encode()
 local parts={'BALLLER_PROFILE_1',P.gems,P.stars,P.hits,P.rounds,P.plays,P.skin}
 for i=1,4 do parts[#parts+1]=P.best[i] end
 for i=1,4 do parts[#parts+1]=P.owned[i] and 1 or 0 end
 local body=table.concat(parts,'|')
 return body..'|'..checksum(body)
end
local function read(s)
 if type(s)~='string' or #s>1000 then return false end
 local parts={}
 for part in s:gmatch('[^|]+') do parts[#parts+1]=part end
 if #parts~=16 or parts[1]~='BALLLER_PROFILE_1' then return false end
 local body=table.concat(parts,'|',1,15)
 if checksum(body)~=parts[16] then return false end
 local nums={}
 for i=2,15 do
  local n=tonumber(parts[i])
  if not n or n~=n or n%1~=0 or n<0 or n>10000000 then return false end
  nums[i]=n
 end
 if nums[7]<1 or nums[7]>4 or nums[12]~=1 then return false end
 for i=13,15 do if nums[i]>1 then return false end end
 if nums[7]>1 and nums[11+nums[7]]~=1 then return false end
 P.gems,P.stars,P.hits,P.rounds,P.plays,P.skin=nums[2],nums[3],nums[4],nums[5],nums[6],nums[7]
 for i=1,4 do P.best[i]=nums[7+i] P.owned[i]=nums[11+i]==1 end
 return true
end
function P.load()
 local data=love.filesystem.read(file)
 if read(data) then return true end
 local backup=love.filesystem.read(file..'.bak')
 if read(backup) then love.filesystem.write(file,backup) return true end
 return false
end
function P.save()
 local previous=love.filesystem.read(file)
 if previous and #previous<1000 then
  local parts={}
  for p in previous:gmatch('[^|]+') do parts[#parts+1]=p end
  if #parts==16 and checksum(table.concat(parts,'|',1,15))==parts[16] then
   love.filesystem.write(file..'.bak',previous)
  end
 end
 local ok=love.filesystem.write(file,encode())
 if ok then P.dirty=false end
 return ok
end
function P.track(kind,n)
 if kind~='hits' and kind~='stars' and kind~='rounds' and kind~='plays' then return end
 local old=P[kind]
 P[kind]=math.min(10000000,old+(n or 1))
 for _,a in ipairs(P.achievements) do
  if a.id==kind and old<a.target and P[kind]>=a.target then
   P.gems=math.min(10000000,P.gems+2)
  end
 end
 P.dirty=true
end
function P.awardRound(round,mode)
 local id=math.max(1,math.min(4,math.floor(tonumber(mode) or 2)))
 local prev=P.best[id]
 local gems=0
 if round>prev then
  for n=prev+1,math.min(round,999) do
   if n%3==0 then gems=gems+(n%9==0 and 3 or 2) end
  end
  P.best[id]=round
 end
 P.gems=math.min(10000000,P.gems+gems)
 P.track('rounds',1)
 P.save()
 return gems
end
function P.unlock(index)
 local item=P.skins[index]
 if not item then return false,'Apariencia desconocida' end
 if P.owned[index] then P.skin=index P.save() return true,'Equipada' end
 if P.gems<item.cost then return false,'Te faltan '..(item.cost-P.gems)..' gemas' end
 P.gems=P.gems-item.cost P.owned[index]=true P.skin=index P.save()
 return true,'¡Nueva pelota!'
end
function P.skinSprite() return P.skins[P.skin].sprite end
function P.progress(a)
 local n=P[a.id] or 0
 return math.min(n,a.target),a.target
end
return P
