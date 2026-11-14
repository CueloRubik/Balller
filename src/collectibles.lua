local A=require('src.arena')
local U=require('src.util')
local S={list={},timer=5,spawned=0,limit=5,interval=7}
function S.clear()
 S.list={}
 S.timer=5
 S.spawned=0
end
function S.configure(limit,interval)
 S.limit=limit or 5
 S.interval=interval or 7
 S.timer=math.min(S.timer,S.interval)
end
function S.update(dt,ball,hazards,callback)
 S.timer=S.timer-dt
 for i=#S.list,1,-1 do
  local p=S.list[i]
  p.life=p.life-dt
  p.t=p.t+dt
  if U.dist(p.x,p.y,ball.x,ball.y)<ball.r+17 then
   table.remove(S.list,i)
   callback(p.x,p.y)
  elseif p.life<=0 then table.remove(S.list,i) end
 end
 if S.timer>0 or S.spawned>=S.limit or #S.list>=2 then return end
 S.timer=S.interval
 for tries=1,30 do
  local x=love.math.random(A.x+70,A.x+A.w-70)
  local y=love.math.random(A.y+70,A.y+A.h-70)
  local safe=U.dist(x,y,ball.x,ball.y)>110
  for _,h in ipairs(hazards) do if U.dist(x,y,h.x,h.y)<h.r+65 then safe=false break end end
  if safe then
   S.list[#S.list+1]={x=x,y=y,t=0,life=10}
   S.spawned=S.spawned+1
   return
  end
 end
end
function S.draw(t)
 local g=love.graphics
 for _,p in ipairs(S.list) do
  local alpha=math.min(1,p.life*2)
  local bounce=math.sin(p.t*5)*4
  local x,y=p.x,p.y+bounce
  g.setColor(.27,.57,.4,.15*alpha)
  g.circle('fill',x+2,y+14,16)
  g.setColor(1,.92,.5,.22*alpha)
  g.circle('fill',x,y,24+math.sin(t*4)*2)
  g.setColor(1,.76,.2,alpha)
  local coords={}
  for k=0,9 do
   local ang=-math.pi/2+k*math.pi/5
   local r=k%2==0 and 17 or 8
   coords[#coords+1]=x+math.cos(ang)*r
   coords[#coords+1]=y+math.sin(ang)*r
  end
  g.polygon('fill',coords)
  g.setColor(1,1,.8,.8*alpha)
  g.circle('fill',x-4,y-4,3)
 end
end
return S
