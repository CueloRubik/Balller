local U=require("src.util")
local A=require("src.arena")
local H={list={}}
function H.clear() H.list={} end
function H.spawn(p,b)
  for attempt=1,35 do
    local x=love.math.random(A.x+75,A.x+A.w-75)
    local y=love.math.random(A.y+75,A.y+A.h-75)
    local kind=love.math.random(1,2)
    local r=kind==1 and 29 or 33
    local valid=U.dist(x,y,p.x,p.y)>r+p.r+65 and U.dist(x,y,b.x,b.y)>r+b.r+65
    for _,h in ipairs(H.list) do
      if U.dist(x,y,h.x,h.y)<r+h.r+45 then valid=false break end
    end
    if valid then
      H.list[#H.list+1]={x=x,y=y,r=r,kind=kind,age=0,warning=1.7,active=kind==1 and 4.5 or 5.5,fade=.45}
      return true
    end
  end
  return false
end
function H.update(dt,b,objects)
  for i=#H.list,1,-1 do
    local h=H.list[i]
    h.age=h.age+dt
    local endAt=h.warning+h.active
    if h.age>endAt+h.fade then
      table.remove(H.list,i)
    elseif h.age>=h.warning and h.age<endAt then
      if U.dist(b.x,b.y,h.x,h.y)<h.r+b.r-6 then
        if h.kind==1 then return "pinchos" end
        local safe=false
        for _,o in ipairs(objects) do
          if o.kind==3 and U.dist(o.x,o.y,h.x,h.y)<h.r+12 then safe=true break end
        end
        if not safe then return "alcantarilla" end
      end
    end
  end
end
return H
