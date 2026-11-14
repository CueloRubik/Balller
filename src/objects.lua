local U=require('src.util')
local A=require('src.arena')
local O={list={},selected=1}
O.types={
 {name='Escudo',sprite='shield',cost=22,r=32,hits=7,duration=32,desc='Rebota la pelota. 7 golpes.'},
 {name='Impulso',sprite='boost',cost=30,r=24,hits=11,duration=26,desc='Lanza la pelota lejos.'},
 {name='Tapa',sprite='lid',cost=20,r=32,hits=1,duration=16,desc='Cubre una alcantarilla.'},
 {name='Imán',sprite='magnet',cost=38,r=27,hits=99,duration=23,desc='Atrae la pelota.'},
 {name='Ventilador',sprite='fan',cost=35,r=27,hits=99,duration=23,desc='Empuja la pelota.'},
 {name='Reloj',sprite='clock',cost=34,r=27,hits=99,duration=20,desc='Ralentiza la pelota.'}
}
function O.clear() O.list={} O.selected=1 end
function O.place(x,y,p,b,hazards)
 local kind=O.selected
 local info=O.types[kind]
 if not info then return false,'Objeto desconocido' end
 if not A.contains(x,y,info.r+20) then return false,'Elige un punto dentro de la cancha' end
 if U.dist(x,y,p.x,p.y)<info.r+p.r+12 or U.dist(x,y,b.x,b.y)<info.r+b.r+12 then return false,'Ese lugar está ocupado' end
 for _,o in ipairs(O.list) do
  if U.dist(x,y,o.x,o.y)<info.r+o.r+10 then return false,'Está muy cerca de otra defensa' end
 end
 if kind==3 then
  local valid=false
  for _,h in ipairs(hazards) do
   if h.kind==2 and U.dist(x,y,h.x,h.y)<h.r*.75 then valid=true break end
  end
  if not valid then return false,'Pon la tapa sobre una alcantarilla' end
 else
  for _,h in ipairs(hazards) do
   if h.kind~=5 and U.dist(x,y,h.x,h.y)<info.r+h.r+6 then return false,'Ese lugar es peligroso' end
  end
 end
 O.list[#O.list+1]={x=x,y=y,r=info.r,kind=kind,hits=info.hits,life=info.duration,fullLife=info.duration,phase=love.math.random()*6.28,fx=0}
 return true
end
function O.update(dt,b)
 for i=#O.list,1,-1 do
  local o=O.list[i]
  o.life=o.life-dt
  o.fx=math.max(0,(o.fx or 0)-dt)
  if b and o.kind>=4 then
   local dx,dy=b.x-o.x,b.y-o.y
   local dist=U.length(dx,dy)
   local range=o.kind==6 and 125 or 175
   if dist<range and dist>2 then
    local nx,ny=dx/dist,dy/dist
    local factor=1-dist/range
    if o.kind==4 then
     b.vx=b.vx-nx*730*factor*dt
     b.vy=b.vy-ny*730*factor*dt
    elseif o.kind==5 then
     b.vx=b.vx+nx*850*factor*dt
     b.vy=b.vy+ny*850*factor*dt
    else
     local damp=(.955)^(dt*60*factor)
     b.vx,b.vy=b.vx*damp,b.vy*damp
    end
    o.fx=.16
   end
  end
  if o.life<=0 or o.hits<=0 then table.remove(O.list,i) end
 end
end
function O.collide(b)
 local bounced=false
 for _,o in ipairs(O.list) do
  if o.kind==1 or o.kind==2 then
   local dx,dy=b.x-o.x,b.y-o.y
   local len=U.length(dx,dy)
   if len<b.r+o.r then
    local nx,ny=U.normal(dx,dy)
    b.x=o.x+nx*(b.r+o.r+1)
    b.y=o.y+ny*(b.r+o.r+1)
    local dot=b.vx*nx+b.vy*ny
    if dot<0 then
     b.vx=b.vx-2*dot*nx
     b.vy=b.vy-2*dot*ny
     if o.kind==2 then b.vx=nx*455 b.vy=ny*455 end
     o.hits=o.hits-1
     o.fx=.25
     bounced=true
    end
   end
  end
 end
 return bounced
end
return O
