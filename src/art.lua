local C=require('src.theme')
local UI=require('src.ui')
local A=require('src.arena')
local S=require('src.sprites')
local M={}
local lg=love.graphics
local function col(c,a) UI.color(c,a) end
function M.load() S.load() end
function M.background(t)
 lg.clear(C.bg)
 for i=1,12 do
  local x=(i*157)%1100-30
  local y=(i*113)%730-20
  col({1,1,1},.35)
  lg.circle('fill',x+math.sin(t*.32+i)*9,y,4+(i%3)*2)
 end
 lg.setColor(.97,.99,.94,.40)
 lg.ellipse('fill',100,628,160,60)
 lg.ellipse('fill',917,78,140,45)
end
function M.field()
 UI.rect(A.x,A.y+8,A.w,A.h,26,{.51,.74,.57})
 UI.rect(A.x,A.y,A.w,A.h,26,{.69,.88,.60})
 lg.setScissor(A.x+10,A.y+10,A.w-20,A.h-20)
 for i=0,8 do
  if i%2==0 then
   col({.52,.79,.52},.26)
   lg.rectangle('fill',A.x+12+i*110,A.y+12,110,A.h-24)
  end
 end
 col({.94,1,.89},.85)
 lg.setLineWidth(3)
 lg.rectangle('line',A.x+19,A.y+19,A.w-38,A.h-38,17,17)
 lg.circle('line',A.x+A.w/2,A.y+A.h/2,82)
 lg.line(A.x+A.w/2,A.y+19,A.x+A.w/2,A.y+A.h-19)
 lg.setLineWidth(1)
 lg.setScissor()
end
function M.player(p)
 col(C.shadow,.15)
 lg.ellipse('fill',p.x+2,p.y+22,22,10)
 local dir=0
 if math.abs(p.vx)>math.abs(p.vy) then
  dir=p.vx>=0 and 1 or 3
 elseif p.vy<0 then dir=2 end
 local walking=math.abs(p.vx)+math.abs(p.vy)>10
 local step=walking and (math.floor(p.walk*1.25)%4) or 0
 local frame=dir*4+step+1
 local bump=p.hit>0 and .08*math.sin((.16-p.hit)*40) or 0
 S.draw('character',p.x,p.y,frame,77*(1+bump))
 if p.hit>0 then
  col(C.paper,p.hit*2)
  lg.setLineWidth(3)
  lg.circle('line',p.x,p.y,25+(1-p.hit/.16)*15)
  lg.setLineWidth(1)
 end
end
function M.ball(b)
 for i=#b.trail,1,-1 do
  local p=b.trail[i]
  col(C.gold,(1-i/#b.trail)*.13)
  lg.circle('fill',p.x,p.y,13*(1-i/14))
 end
 col(C.shadow,.15)
 lg.ellipse('fill',b.x+3,b.y+17,17,8)
 local frame=math.floor(b.spin*1.273)%8+1
 S.draw('ball',b.x,b.y,frame,62)
end
function M.hazards(hazards,t)
 for _,h in ipairs(hazards) do
  local active=h.age>=h.warning and h.age<h.warning+h.active
  local warn=math.min(1,h.age/h.warning)
  local name=h.kind==1 and 'spikes' or 'drain'
  if not active then
   local c=h.kind==1 and C.red or C.gold
   col(c,.15+math.sin(t*10)^2*.14)
   lg.circle('fill',h.x,h.y,h.r+11+math.sin(t*10)*3)
   col(c,.82)
   lg.setLineWidth(4)
   lg.circle('line',h.x,h.y,h.r+7)
   lg.setLineWidth(1)
   if h.kind==2 then S.draw('drain',h.x,h.y,1,74,.75) end
   if h.kind==1 and warn>.55 then
    S.draw('spikes',h.x,h.y,1,74,(warn-.55)*1.4)
   end
  else
   local age=h.age-h.warning
   local step=math.min(8,math.floor(age*12)+1)
   if h.kind==1 then step=math.min(8,step+2) end
   local ending=h.warning+h.active-h.age
   local a=math.min(1,ending/.32)
   S.draw(name,h.x,h.y,step,80,a)
  end
 end
end
function M.objects(objects,t)
 for _,o in ipairs(objects) do
  local name=({'shield','boost','lid'})[o.kind]
  local f=(math.floor((t+o.x*.01)*9)%8)+1
  local fade=math.min(1,o.life/2)
  col(C.shadow,.15*fade)
  lg.ellipse('fill',o.x+3,o.y+20,o.r*.9,o.r*.35)
  S.draw(name,o.x,o.y,f,o.r*2.55,fade)
 end
end
function M.mascot(x,y,scale,t)
 lg.push()
 lg.translate(x,y+math.sin(t*2)*4)
 S.draw('character',-35,-7,2,160*scale)
 S.draw('ball',78,25,math.floor(t*8)%8+1,94*scale)
 lg.pop()
end
return M
