local U=require('src.util')
local A=require('src.arena')
local H={list={}}
H.names={'Pinchos','Alcantarilla','Sierra','Descarga','Remolino','Martillo','Láser'}
function H.clear() H.list={} end
function H.spawn(p,b,round,mode)
 round=math.max(1,math.floor(round or 1))
 mode=mode or {unlock=0,warning=1}
 local kinds=math.min(7,2+math.floor(math.max(0,round-(mode.unlock or 0))/2))
 for attempt=1,45 do
  local x=love.math.random(A.x+82,A.x+A.w-82)
  local y=love.math.random(A.y+82,A.y+A.h-82)
  local kind=love.math.random(1,kinds)
  local r=({29,33,30,35,34,31,30})[kind]
  local valid=U.dist(x,y,p.x,p.y)>r+p.r+75 and U.dist(x,y,b.x,b.y)>r+b.r+75
  for _,h in ipairs(H.list) do
   if U.dist(x,y,h.x,h.y)<r+h.r+62 then valid=false break end
  end
  if valid then
   local diagonal=(love.math.random(1,2)==1)
   local speed=95+math.min(round*9,75)
   H.list[#H.list+1]={
    x=x,y=y,r=r,kind=kind,age=0,
    warning=(kind==3 and 2.1 or 1.8)*(mode.warning or 1),
    active=kind==5 and 6.8 or 5.2,fade=.5,
    vx=(kind==3 or kind==6) and (diagonal and speed or 0) or 0,
    vy=(kind==3 or kind==6) and (not diagonal and speed or 0) or 0,
    phase=love.math.random()*6.28,cooldown=0
   }
   return true
  end
 end
 return false
end
local function covered(h,objects)
 for _,o in ipairs(objects) do
  if o.kind==3 and U.dist(o.x,o.y,h.x,h.y)<h.r+10 then return true end
 end
 return false
end
function H.update(dt,b,objects)
 for i=#H.list,1,-1 do
  local h=H.list[i]
  h.age=h.age+dt
  h.cooldown=math.max(0,(h.cooldown or 0)-dt)
  local endAt=h.warning+h.active
  if h.age>endAt+h.fade then
   table.remove(H.list,i)
  elseif h.age>=h.warning and h.age<endAt then
   if h.kind==3 or h.kind==6 then
    local moving=h.kind==3 or ((h.age-h.warning+h.phase)%2.7)<1.35
    if moving then
     h.x=h.x+h.vx*dt
     h.y=h.y+h.vy*dt
    end
    local l,r,t,bot=A.bounds(h.r+18)
    if h.x<l then h.x=l h.vx=math.abs(h.vx) end
    if h.x>r then h.x=r h.vx=-math.abs(h.vx) end
    if h.y<t then h.y=t h.vy=math.abs(h.vy) end
    if h.y>bot then h.y=bot h.vy=-math.abs(h.vy) end
   end
   local dist=U.dist(b.x,b.y,h.x,h.y)
   if h.kind==5 and dist<145 and dist>2 then
    local dx,dy=(b.x-h.x)/dist,(b.y-h.y)/dist
    local force=430*(1-dist/145)*dt
    b.vx=b.vx-dy*force
    b.vy=b.vy+dx*force
   elseif h.kind==4 then
    local charged=((h.age-h.warning+h.phase)%2.3)<1.3
    if charged and dist<h.r+b.r-8 then return 'descarga' end
   elseif h.kind==2 then
    if dist<h.r+b.r-8 and not covered(h,objects) then return 'alcantarilla' end
   elseif h.kind==1 and dist<h.r+b.r-7 then
    return 'pinchos'
   elseif h.kind==3 and dist<h.r+b.r-8 then
    return 'sierra'
   elseif h.kind==6 and dist<h.r+b.r-8 then
    return 'martillo'
   elseif h.kind==7 then
    local ang=(h.age-h.warning)*1.35+h.phase
    local vx,vy=math.cos(ang),math.sin(ang)
    local dx,dy=b.x-h.x,b.y-h.y
    local along=math.max(-120,math.min(120,dx*vx+dy*vy))
    local px,py=h.x+vx*along,h.y+vy*along
    if U.dist(px,py,b.x,b.y)<b.r+9 then return 'laser' end
   end
  end
 end
end
return H
