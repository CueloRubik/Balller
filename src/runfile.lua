local M={}
local function number(v,lo,hi)
 local n=tonumber(v)
 if not n or n~=n or n==math.huge or n==-math.huge or n<lo or n>hi then return nil end
 return n
end
local function split(line)
 local parts={}
 for part in (line..'|'):gmatch('(.-)|') do parts[#parts+1]=part end
 return parts
end
local function checksum(s)
 local a,b=1,0
 for i=1,#s do
  a=(a+s:byte(i))%65521
  b=(b+a)%65521
 end
 return tostring(b*65536+a)
end
local function row(tag,data,keys)
 local out={tag}
 for _,key in ipairs(keys) do
  local val=data[key]
  if type(val)~='number' or val~=val or math.abs(val)>100000000 then return nil end
  out[#out+1]=string.format('%.5f',val)
 end
 return table.concat(out,'|')
end
local rootKeys={'round','score','coins','time','roundLeft','roundDuration','spawn','roundHits','reward','previousRound','previousHits'}
local playerKeys={'x','y','r','dx','dy','vx','vy','speed','hit','walk'}
local ballKeys={'x','y','r','vx','vy','cooldown','spin'}
local hazardKeys={'kind','x','y','r','age','warning','active','fade','vx','vy','phase','cooldown'}
local objectKeys={'x','y','r','kind','hits','life','fullLife','phase','fx'}
local function fields(parts,keys,lo,hi)
 if #parts~=#keys+1 then return nil end
 local result={}
 for j,key in ipairs(keys) do
  local v=number(parts[j+1],lo,hi)
  if not v then return nil end
  result[key]=v
 end
 return result
end
function M.encode(s)
 if not s or not s.player or not s.ball then return nil end
 if s.state~='shop' and s.state~='playing' and s.state~='pause' then return nil end
 local lines={'BALLLER_RUN_2'}
 local r=row('G',s,rootKeys)
 local p=row('P',s.player,playerKeys)
 local b=row('B',s.ball,ballKeys)
 if not r or not p or not b then return nil end
 lines[#lines+1]=r..'|'..s.state
 lines[#lines+1]=p
 lines[#lines+1]=b
 local inventory={'I'}
 if #s.inventory~=6 then return nil end
 for i=1,6 do
  local n=s.inventory[i]
  if type(n)~='number' or n<0 or n>20 or n%1~=0 then return nil end
  inventory[#inventory+1]=tostring(n)
 end
 lines[#lines+1]=table.concat(inventory,'|')
 local boots=s.boots or 0
 local walls=s.wallBounces or 0
 local placed=s.placed or 0
 local pulse=s.pulseCooldown or 0
 if boots%1~=0 or boots<0 or boots>3 or walls<0 or walls>10000 or placed<0 or placed>10000 or pulse<0 or pulse>30 then return nil end
 lines[#lines+1]=table.concat({'X',boots,walls,placed,string.format('%.5f',pulse)},'|')
 if #s.hazards>24 or #s.objects>50 then return nil end
 for _,h in ipairs(s.hazards) do
  local line=row('H',h,hazardKeys)
  if not line then return nil end
  lines[#lines+1]=line
 end
 for _,o in ipairs(s.objects) do
  local line=row('O',o,objectKeys)
  if not line then return nil end
  lines[#lines+1]=line
 end
 lines[#lines+1]='K|'..checksum(table.concat(lines,'\n'))
 lines[#lines+1]='END'
 return table.concat(lines,'\n')
end
function M.decode(text)
 if type(text)~='string' or #text>15000 then return nil end
 local lines={}
 for line in (text..'\n'):gmatch('(.-)\n') do
  line=line:gsub('\r$','')
  lines[#lines+1]=line
 end
 if lines[1]~='BALLLER_RUN_2' or lines[#lines]~='END' or #lines<6 then return nil end
 if lines[#lines-1] and lines[#lines-1]:sub(1,2)=='K|' then
  local expected=lines[#lines-1]:sub(3)
  if expected~=checksum(table.concat(lines,'\n',1,#lines-2)) then return nil end
  table.remove(lines,#lines-1)
 end
 local g=split(lines[2])
 if #g~=#rootKeys+2 then return nil end
 local state=g[#g]
 if state~='shop' and state~='playing' and state~='pause' then return nil end
 g[#g]=nil
 local s=fields(g,rootKeys,0,100000000)
 if not s then return nil end
 s.state=state
 s.player=fields(split(lines[3]),playerKeys,-100000,100000)
 s.ball=fields(split(lines[4]),ballKeys,-100000,100000)
 if not s.player or not s.ball then return nil end
 local iv=split(lines[5])
 if #iv~=7 or iv[1]~='I' then return nil end
 s.inventory={}
 for i=1,6 do
  local n=number(iv[i+1],0,10)
  if not n or n%1~=0 then return nil end
  s.inventory[i]=n
 end
 s.boots,s.wallBounces,s.placed,s.pulseCooldown=0,0,0,0
 local start=6
 if lines[6] and lines[6]:sub(1,2)=='X|' then
  local extra=split(lines[6])
  if #extra~=5 then return nil end
  local boots=number(extra[2],0,3)
  local walls=number(extra[3],0,10000)
  local placed=number(extra[4],0,10000)
  local pulse=number(extra[5],0,30)
  if not boots or boots%1~=0 or not walls or walls%1~=0 or not placed or placed%1~=0 or not pulse then return nil end
  s.boots,s.wallBounces,s.placed,s.pulseCooldown=boots,walls,placed,pulse
  start=7
 end
 s.hazards={}
 s.objects={}
 for i=start,#lines-1 do
  local parts=split(lines[i])
  if parts[1]=='H' then
   local h=fields(parts,hazardKeys,-100000,100000)
   if not h or h.kind%1~=0 or h.kind<1 or h.kind>5 then return nil end
   s.hazards[#s.hazards+1]=h
   if #s.hazards>24 then return nil end
  elseif parts[1]=='O' then
   local o=fields(parts,objectKeys,-100000,100000)
   if not o or o.kind%1~=0 or o.kind<1 or o.kind>6 then return nil end
   s.objects[#s.objects+1]=o
   if #s.objects>50 then return nil end
  else
   return nil
  end
 end
 if s.round<1 or s.round>999 or s.round%1~=0 or s.coins>99999 or s.roundLeft>120 or s.roundDuration>120 or s.roundHits>10000 or s.player.x<0 or s.player.x>1000 or s.player.y<0 or s.player.y>680 or s.ball.x<0 or s.ball.x>1000 or s.ball.y<0 or s.ball.y>680 then return nil end
 return s
end
return M
