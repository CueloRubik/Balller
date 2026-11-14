local U=require("src.util")
local A=require("src.arena")
local O={list={},selected=1}
O.types={{name="Escudo",cost=15,r=32,hits=7,duration=24},{name="Impulso",cost=25,r=24,hits=11,duration=20},{name="Tapa",cost=35,r=32,hits=1,duration=12}}
function O.clear() O.list={} O.selected=1 end
function O.place(x,y,coins,p,b,hazards)
  local kind=O.selected
  local info=O.types[kind]
  if coins<info.cost then return false,"Faltan monedas" end
  if not A.contains(x,y,info.r+20) then return false,"Fuera de la cancha" end
  if U.dist(x,y,p.x,p.y)<info.r+p.r+12 or U.dist(x,y,b.x,b.y)<info.r+b.r+12 then return false,"Espacio ocupado" end
  for _,o in ipairs(O.list) do
    if U.dist(x,y,o.x,o.y)<info.r+o.r+10 then return false,"Espacio ocupado" end
  end
  if kind==3 then
    local valid=false
    for _,h in ipairs(hazards) do
      if h.kind==2 and U.dist(x,y,h.x,h.y)<h.r*.75 then valid=true break end
    end
    if not valid then return false,"Pon la tapa sobre una alcantarilla" end
  else
    for _,h in ipairs(hazards) do
      if U.dist(x,y,h.x,h.y)<info.r+h.r+6 then return false,"Lugar peligroso" end
    end
  end
  O.list[#O.list+1]={x=x,y=y,r=info.r,kind=kind,hits=info.hits,life=info.duration}
  return true,info.cost
end
function O.update(dt)
  for i=#O.list,1,-1 do
    local o=O.list[i]
    o.life=o.life-dt
    if o.life<=0 or o.hits<=0 then table.remove(O.list,i) end
  end
end
function O.collide(b)
  local bounced=false
  for _,o in ipairs(O.list) do
    if o.kind~=3 then
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
          bounced=true
        end
      end
    end
  end
  return bounced
end
return O
