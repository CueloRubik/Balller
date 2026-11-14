local U=require("src.util")
local M={list={}}
function M.clear() M.list={} end
function M.burst(x,y,c,n)
  for i=1,n do
    local a=U.rand(0,math.pi*2)
    local s=U.rand(55,190)
    M.list[#M.list+1]={x=x,y=y,vx=math.cos(a)*s,vy=math.sin(a)*s,life=U.rand(.24,.6),max=.6,r=U.rand(2,5),c=c}
  end
end
function M.update(dt)
  for i=#M.list,1,-1 do
    local p=M.list[i]
    p.life=p.life-dt
    p.x=p.x+p.vx*dt
    p.y=p.y+p.vy*dt
    p.vx=p.vx*(1-3*dt)
    p.vy=p.vy*(1-3*dt)
    if p.life<=0 then table.remove(M.list,i) end
  end
end
function M.draw()
  local lg=love.graphics
  for _,p in ipairs(M.list) do
    lg.setColor(p.c[1],p.c[2],p.c[3],math.max(0,p.life/p.max))
    lg.circle("fill",p.x,p.y,p.r)
  end
end
return M
