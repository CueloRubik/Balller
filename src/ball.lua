local U=require("src.util")
local A=require("src.arena")
local B={}
function B.enforceSpeed(b,speed)
 speed=speed or b.speed or 245
 local nx,ny=U.normal(b.vx,b.vy)
 b.speed=speed
 b.vx,b.vy=nx*speed,ny*speed
 return speed
end
function B.new() return {x=630,y=313,r=16,vx=-190,vy=145,cooldown=0,portalCooldown=0,guard=0,trail={},spin=0} end
function B.update(b,dt,onWall)
    b.cooldown=math.max(0,b.cooldown-dt)
    b.portalCooldown=math.max(0,(b.portalCooldown or 0)-dt)
    b.guard=math.max(0,(b.guard or 0)-dt)
    b.x=b.x+b.vx*dt
    b.y=b.y+b.vy*dt
    b.spin=b.spin+U.length(b.vx,b.vy)*dt/16
    local l,r,t,bot=A.bounds(b.r)
    local hit=false
    if b.x<l then b.x=l b.vx=math.abs(b.vx) hit=true end
    if b.x>r then b.x=r b.vx=-math.abs(b.vx) hit=true end
    if b.y<t then b.y=t b.vy=math.abs(b.vy) hit=true end
    if b.y>bot then b.y=bot b.vy=-math.abs(b.vy) hit=true end
    if hit and onWall then onWall(b.x,b.y) end
    B.enforceSpeed(b)
    table.insert(b.trail,1,{x=b.x,y=b.y})
    if #b.trail>8 then table.remove(b.trail) end
end
function B.hitPlayer(b,p)
    local dx,dy=b.x-p.x,b.y-p.y
    local len=U.length(dx,dy)
    if len>=b.r+p.r then return false end
    local nx,ny=U.normal(dx,dy)
    b.x=p.x+nx*(b.r+p.r+0.5)
    b.y=p.y+ny*(b.r+p.r+0.5)
    if b.cooldown>0 then return false end
    local strength=325
    b.vx=nx*strength+p.vx*.42
    b.vy=ny*strength+p.vy*.42
    B.enforceSpeed(b)
    b.cooldown=.17
    p.hit=.16
    return true
end
return B
