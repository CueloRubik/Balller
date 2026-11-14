local U=require("src.util")
local A=require("src.arena")
local P={}
function P.new()
  return {x=280,y=330,r=19,dx=1,dy=0,vx=0,vy=0,speed=265,hit=0,walk=0}
end
function P.update(p,dt)
  local x,y=0,0
  if love.keyboard.isDown("a","left") then x=x-1 end
  if love.keyboard.isDown("d","right") then x=x+1 end
  if love.keyboard.isDown("w","up") then y=y-1 end
  if love.keyboard.isDown("s","down") then y=y+1 end
  if x~=0 or y~=0 then
    x,y=U.normal(x,y)
    p.dx,p.dy=x,y
    p.walk=p.walk+dt*13
  end
  p.vx,p.vy=x*p.speed,y*p.speed
  local l,r,t,b=A.bounds(p.r)
  p.x=U.clamp(p.x+p.vx*dt,l,r)
  p.y=U.clamp(p.y+p.vy*dt,t,b)
  p.hit=math.max(0,p.hit-dt)
end
return P
