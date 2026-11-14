local C=require("src.theme")
local UI=require("src.ui")
local A=require("src.arena")
local M={}
local lg=love.graphics
local function col(c,a) UI.color(c,a) end
function M.background(t)
  lg.clear(C.bg)
  col({.77,.92,.96})
  for i=1,12 do
    local x=(i*139)%1010
    local y=(i*101)%695
    lg.circle("fill",x+math.sin(t+i)*9,y,4+(i%3)*2)
  end
end
function M.field()
  UI.rect(A.x,A.y+7,A.w,A.h,24,{.54,.73,.64})
  UI.rect(A.x,A.y,A.w,A.h,24,C.turf)
  lg.setScissor(A.x+9,A.y+9,A.w-18,A.h-18)
  for i=0,7 do
    if i%2==0 then
      col(C.turf2,.52)
      lg.rectangle("fill",A.x+12+i*116,A.y+11,116,A.h-22)
    end
  end
  col(C.rail,.7)
  lg.setLineWidth(3)
  lg.rectangle("line",A.x+18,A.y+18,A.w-36,A.h-36,12,12)
  lg.circle("line",A.x+A.w/2,A.y+A.h/2,72)
  lg.line(A.x+A.w/2,A.y+18,A.x+A.w/2,A.y+A.h-18)
  lg.setLineWidth(1)
  lg.setScissor()
end
function M.player(p)
  local x,y=p.x,p.y
  col(C.shadow,.28)
  lg.ellipse("fill",x+3,y+10,20,12)
  local wiggle=math.sin(p.walk)*2
  col(C.navy)
  lg.circle("fill",x-p.dy*10-p.dx*8,y+p.dx*10-p.dy*8+wiggle,8)
  lg.circle("fill",x+p.dy*10-p.dx*8,y-p.dx*10-p.dy*8-wiggle,8)
  col(C.blue)
  lg.circle("fill",x,y,p.r+3)
  col({.49,.81,1})
  lg.arc("fill",x,y,p.r,-math.pi*.94,-math.pi*.12)
  local fx,fy=x+p.dx*8,y+p.dy*8
  local sx,sy=-p.dy,p.dx
  col(C.paper)
  lg.circle("fill",fx+sx*6,fy+sy*6,4)
  lg.circle("fill",fx-sx*6,fy-sy*6,4)
  col(C.ink)
  lg.circle("fill",fx+sx*6+p.dx,fy+sy*6+p.dy,2)
  lg.circle("fill",fx-sx*6+p.dx,fy-sy*6+p.dy,2)
  if p.hit>0 then
    col(C.paper,p.hit*4)
    lg.setLineWidth(3)
    lg.circle("line",x,y,24)
    lg.setLineWidth(1)
  end
end
function M.ball(b)
  for i=#b.trail,1,-1 do
    local p=b.trail[i]
    col(C.gold,(1-i/#b.trail)*.20)
    lg.circle("fill",p.x,p.y,11)
  end
  col(C.shadow,.25)
  lg.ellipse("fill",b.x+3,b.y+7,17,12)
  col({.86,.47,.17})
  lg.circle("fill",b.x,b.y,b.r+2)
  col(C.gold)
  lg.circle("fill",b.x,b.y,b.r)
  col({1,.91,.63})
  lg.circle("fill",b.x-5,b.y-5,5)
  col({.72,.42,.12},.75)
  lg.setLineWidth(2)
  lg.arc("line",b.x,b.y,b.r-4,b.spin,b.spin+math.pi)
  lg.setLineWidth(1)
end
function M.hazards(hazards,t)
  for _,h in ipairs(hazards) do
    local active=h.age>=h.warning and h.age<h.warning+h.active
    if not active then
      col(h.kind==1 and C.red or C.gold,.17+.1*math.sin(t*11)^2)
      lg.circle("fill",h.x,h.y,h.r+9)
      col(h.kind==1 and C.red or C.gold)
      lg.setLineWidth(3)
      lg.circle("line",h.x,h.y,h.r+3)
      lg.setLineWidth(1)
    elseif h.kind==1 then
      col(C.shadow,.3)
      lg.circle("fill",h.x+3,h.y+5,h.r+5)
      col(C.red)
      for i=0,11 do
        local a=i*math.pi/6
        lg.polygon("fill",
          h.x+math.cos(a-.18)*(h.r-5),
          h.y+math.sin(a-.18)*(h.r-5),
          h.x+math.cos(a)*(h.r+8),
          h.y+math.sin(a)*(h.r+8),
          h.x+math.cos(a+.18)*(h.r-5),
          h.y+math.sin(a+.18)*(h.r-5)
        )
      end
      col(C.redDark)
      lg.circle("fill",h.x,h.y,h.r-9)
      col({1,.68,.68})
      lg.circle("line",h.x,h.y,h.r-14)
    else
      col(C.shadow,.3)
      lg.circle("fill",h.x+2,h.y+4,h.r+6)
      col({.20,.33,.37})
      lg.circle("fill",h.x,h.y,h.r+4)
      col({.07,.16,.19})
      lg.circle("fill",h.x,h.y,h.r-3)
      col({.38,.57,.60})
      for i=-2,2 do
        local offset=i*10
        local half=math.sqrt(math.max(0,(h.r-8)^2-offset^2))
        lg.rectangle("fill",h.x-half,h.y+offset-2,half*2,4,2,2)
      end
    end
  end
end
function M.objects(objects)
  for _,o in ipairs(objects) do
    col(C.shadow,.23)
    lg.circle("fill",o.x+3,o.y+5,o.r+4)
    if o.kind==1 then
      col(C.blue)
      lg.circle("fill",o.x,o.y,o.r)
      col(C.navy)
      lg.circle("fill",o.x,o.y,o.r-7)
      col({.67,.87,1})
      lg.setLineWidth(3)
      lg.circle("line",o.x,o.y,o.r-12)
      lg.setLineWidth(1)
      col(C.blue)
      lg.circle("fill",o.x,o.y,6)
    elseif o.kind==2 then
      col(C.mint)
      lg.circle("fill",o.x,o.y,o.r)
      col(C.mintDark)
      lg.circle("fill",o.x,o.y,o.r-8)
      col({.76,1,.75})
      lg.circle("fill",o.x,o.y,9)
    else
      col(C.gold)
      lg.circle("fill",o.x,o.y,o.r)
      col({.84,.52,.17})
      lg.setLineWidth(4)
      lg.circle("line",o.x,o.y,o.r-6)
      lg.line(o.x-13,o.y,o.x+13,o.y)
      lg.line(o.x,o.y-13,o.x,o.y+13)
      lg.setLineWidth(1)
    end
  end
end
function M.mascot(x,y,scale,t)
  lg.push()
  lg.translate(x,y+math.sin(t*2.3)*3)
  lg.scale(scale)
  col(C.shadow,.2)
  lg.ellipse("fill",2,40,51,12)
  col(C.navy)
  lg.circle("fill",-21,31,12)
  lg.circle("fill",21,31,12)
  col(C.blue)
  lg.circle("fill",0,1,42)
  col({.48,.82,1})
  lg.arc("fill",0,1,42,-2.45,-.65)
  col(C.paper)
  lg.circle("fill",-13,-7,11)
  lg.circle("fill",13,-7,11)
  col(C.ink)
  lg.circle("fill",-10,-6,5)
  lg.circle("fill",16,-6,5)
  col(C.navy)
  lg.arc("line",3,8,11,.13,2.65)
  lg.pop()
end

local atlas
local quads={}
function M.load()
  atlas=lg.newImage("assets/sprites.png")
  atlas:setFilter("linear","linear")
  for i=1,8 do
    local col=(i-1)%4
    local row=math.floor((i-1)/4)
    quads[i]=lg.newQuad(col*48,row*48,48,48,192,96)
  end
end
local function sprite(id,x,y,sz,rotation)
  if not atlas then return end
  col(C.paper)
  lg.draw(atlas,quads[id],x,y,rotation or 0,sz/48,sz/48,24,24)
end
local oldPlayer=M.player
function M.player(p)
  if not atlas then return oldPlayer(p) end
  col(C.shadow,.19)
  lg.ellipse("fill",p.x+3,p.y+9,19,11)
  local angle=math.atan2 and math.atan2(p.dx,-p.dy) or math.atan(p.dx,-p.dy)
  sprite(1,p.x,p.y,57,angle)
  if p.hit>0 then
    col(C.paper,math.min(1,p.hit*4))
    lg.setLineWidth(3)
    lg.circle("line",p.x,p.y,28)
    lg.setLineWidth(1)
  end
end
local oldBall=M.ball
function M.ball(b)
  if not atlas then return oldBall(b) end
  for i=#b.trail,1,-1 do
    local p=b.trail[i]
    col(C.gold,(1-i/#b.trail)*.18)
    lg.circle("fill",p.x,p.y,10)
  end
  col(C.shadow,.2)
  lg.ellipse("fill",b.x+3,b.y+5,17,11)
  sprite(2,b.x,b.y,43,b.spin)
end
local oldHazards=M.hazards
function M.hazards(hazards,t)
  if not atlas then return oldHazards(hazards,t) end
  for _,h in ipairs(hazards) do
    local active=h.age>=h.warning and h.age<h.warning+h.active
    if active then
      col(C.shadow,.22)
      lg.ellipse("fill",h.x+3,h.y+6,h.r+3,h.r*.76)
      sprite(h.kind==1 and 3 or 4,h.x,h.y,h.r*2+20)
    else
      oldHazards({h},t)
    end
  end
end
local oldObjects=M.objects
function M.objects(objects)
  if not atlas then return oldObjects(objects) end
  for _,o in ipairs(objects) do
    col(C.shadow,.2)
    lg.ellipse("fill",o.x+3,o.y+5,o.r+2,o.r*.7)
    sprite(4+o.kind,o.x,o.y,o.r*2+16)
  end
end
local oldMascot=M.mascot
function M.mascot(x,y,scale,t)
  if not atlas then return oldMascot(x,y,scale,t) end
  sprite(1,x,y+math.sin(t*2.5)*3,154*scale)
end

return M
