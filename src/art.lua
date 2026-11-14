local Assets=require('src.presentation.assets')
local C=require('src.theme')
local UI=require('src.ui')
local A=require('src.arena')
local S=require('src.sprites')
local O=require('src.objects')
local Progress=require('src.progression')
local Prefs=require('src.presentation.preferences')
local M={}
local lg=love.graphics
local function col(c,a) UI.color(c,a) end
function M.load() S.load() end
function M.background(t)
 if Assets.image('backdrop',0,0,1000,680) then return end
 lg.clear({.85,.95,1})
 for i=0,17 do
  local y=i*40
  col({.84+i*.003,.95+i*.001,1})
  lg.rectangle('fill',0,y,1000,42)
 end
 for i=1,20 do
  local x=(i*197)%1040-20
  local y=(i*137)%720-20
  local r=6+i%4*2
  col(i%3==0 and C.gold or (i%3==1 and C.mint or C.blue),.12)
  lg.circle('fill',x+math.sin(t*.3+i)*5,y+math.cos(t*.2+i)*4,r)
 end
 col(C.paper,.33)
 lg.ellipse('fill',85,630,190,85)
 lg.ellipse('fill',930,55,150,65)
end
function M.field()
 if Assets.image(Prefs.theme().image,A.x,A.y,A.w,A.h) then return end
 UI.rect(A.x,A.y+9,A.w,A.h,28,{.57,.74,.57})
 UI.rect(A.x,A.y+4,A.w,A.h,28,{.93,.99,.84})
 UI.rect(A.x,A.y,A.w,A.h,27,{.68,.88,.59})
 for i=0,9 do
  if i%2==0 then
   col({.44,.72,.45},.12)
   local width=math.min(100,A.w-24-i*100)
   if width>0 then lg.rectangle('fill',A.x+12+i*100,A.y+12,width,A.h-24) end
  end
 end
 for i=1,18 do
  local x=A.x+(i*71)%A.w
  local y=A.y+(i*139)%A.h
  col(C.paper,.07)
  lg.circle('fill',x,y,3)
 end
 col(C.paper,.68)
 lg.setLineWidth(3)
 lg.rectangle('line',A.x+20,A.y+20,A.w-40,A.h-40,19,19)
 lg.circle('line',A.x+A.w/2,A.y+A.h/2,80)
 lg.line(A.x+A.w/2,A.y+20,A.x+A.w/2,A.y+A.h-20)
 lg.setLineWidth(1)
end
function M.player(p)
 col(C.shadow,.18)
 lg.ellipse('fill',p.x+1,p.y+23,21,9)
 local diag=math.abs(p.dx)>.24 and math.abs(p.dy)>.24
 local moving=math.abs(p.vx)+math.abs(p.vy)>10
 local step=moving and math.floor(p.walk*1.25)%4 or 1
 local dir,name
 if diag then
  name='character_diagonal'
  if p.dy>0 then dir=p.dx>0 and 0 or 1
  else dir=p.dx>0 and 2 or 3 end
 else
  name='character'
  if math.abs(p.dx)>math.abs(p.dy) then dir=p.dx>0 and 1 or 3
  else dir=p.dy>=0 and 0 or 2 end
 end
 local bump=not Prefs.reduced and p.hit>0 and .06*math.sin((.16-p.hit)*40) or 0
 local bounce=not Prefs.reduced and moving and math.sin(p.walk*2)*1.4 or 0
 S.draw(name,p.x,p.y+bounce,dir*4+step+1,79*(1+bump))
 if p.hit>0 and not Prefs.reduced then
  col(C.paper,p.hit*2)
  lg.setLineWidth(3)
  lg.circle('line',p.x,p.y,25+(1-p.hit/.16)*15)
  lg.setLineWidth(1)
 end
end
function M.pulse(x,y,life)
 if not x or not y or life<=0 then return end
 if Prefs.reduced then
  col(C.blue,.65) lg.setLineWidth(2) lg.circle('line',x,y,175) lg.setLineWidth(1)
  return
 end
 local amount=1-life/.42
 col(C.blue,.35*(1-amount))
 lg.setLineWidth(5)
 lg.circle('line',x,y,24+amount*155)
 col(C.paper,.25*(1-amount))
 lg.setLineWidth(2)
 lg.circle('line',x,y,31+amount*130)
 lg.setLineWidth(1)
end
function M.ball(b)
 for i=Prefs.reduced and 0 or #b.trail,1,-1 do
  local p=b.trail[i]
  col(C.gold,(1-i/#b.trail)*.13)
  lg.circle('fill',p.x,p.y,13*(1-i/14))
 end
 col(C.shadow,.14)
 lg.ellipse('fill',b.x+3,b.y+18,17,8)
 local frame=math.floor(b.spin*1.273)%8+1
 S.draw(Progress.skinSprite(),b.x,b.y,frame,62)
 if (b.guard or 0)>0 then
  col(C.blue,.23) lg.circle('fill',b.x,b.y,37+(Prefs.reduced and 0 or math.sin(b.guard*7)*2))
  col(C.paper,.88) lg.setLineWidth(3) lg.circle('line',b.x,b.y,37) lg.setLineWidth(1)
 end
end
function M.hazards(hazards,t)
 local names={'spikes','drain','saw','shock','vortex','mallet','laser'}
 for _,h in ipairs(hazards) do
  local active=h.age>=h.warning and h.age<h.warning+h.active
  local name=names[h.kind] or 'spikes'
  local tint=(h.kind==1 or h.kind==3) and C.red or (h.kind==2 and C.gold or (h.kind==4 and {1,.67,.22} or (h.kind==6 and C.gold or C.lilac)))
  if not active then
   local pulse=Prefs.reduced and .5 or math.sin(t*10)^2
   col(tint,.10+pulse*.14)
   lg.circle('fill',h.x,h.y,h.r+17+(Prefs.reduced and 0 or math.sin(t*8)*2))
   col(tint,.86)
   lg.setLineWidth(4)
   lg.circle('line',h.x,h.y,h.r+8)
   lg.setLineWidth(1)
   S.draw(name,h.x,h.y,1,80,.30+.17*pulse)
   if h.kind==7 then
    local ang=h.phase
    col(C.red,.23)
    lg.setLineWidth(11)
    lg.line(h.x-math.cos(ang)*120,h.y-math.sin(ang)*120,h.x+math.cos(ang)*120,h.y+math.sin(ang)*120)
    lg.setLineWidth(1)
   end
   col(C.paper,.97)
   local progress=math.min(1,h.age/h.warning)
   lg.setLineWidth(4)
   lg.arc('line','open',h.x,h.y,h.r+17,-math.pi/2,-math.pi/2+progress*math.pi*2)
   lg.setLineWidth(1)
  else
   local age=h.age-h.warning
   local frame=h.kind<=2 and math.min(8,math.floor(age*12)+1) or (math.floor(t*10)%8+1)
   if h.kind==1 then frame=math.min(8,frame+2) end
   local alpha=math.min(1,(h.warning+h.active-h.age)/.35)
   if h.kind==4 then
    local charged=((age+h.phase)%2.3)<1.3
    if not charged then alpha=alpha*.47 end
    col(charged and C.red or C.blue,charged and .12 or .08)
    lg.circle('fill',h.x,h.y,h.r+13)
   elseif h.kind==5 then
    col(C.lilac,Prefs.reduced and .11 or (.09+.05*math.sin(t*5)^2))
    lg.circle('fill',h.x,h.y,145)
    col(C.lilac,.28)
    lg.setLineWidth(2)
    lg.circle('line',h.x,h.y,145)
    lg.setLineWidth(1)
   elseif h.kind==3 or h.kind==6 then
    col(C.red,.11)
    lg.circle('fill',h.x,h.y,h.r+13)
   elseif h.kind==7 then
    local ang=age*1.35+h.phase
    col(C.red,.13) lg.setLineWidth(27)
    lg.line(h.x-math.cos(ang)*120,h.y-math.sin(ang)*120,h.x+math.cos(ang)*120,h.y+math.sin(ang)*120)
    col(C.paper,.5) lg.setLineWidth(7)
    lg.line(h.x-math.cos(ang)*120,h.y-math.sin(ang)*120,h.x+math.cos(ang)*120,h.y+math.sin(ang)*120)
    lg.setLineWidth(1)
   end
   S.draw(name,h.x,h.y,frame,80,alpha)
  end
 end
end
function M.objects(objects,t)
 for _,o in ipairs(objects) do
  local info=O.types[o.kind]
  local name=info and info.sprite or 'shield'
  local frame=(math.floor((t+o.x*.01)*9)%8)+1
  local fade=math.min(1,o.life/1.2)
  col(C.shadow,.14*fade)
  lg.ellipse('fill',o.x+3,o.y+21,o.r*.9,o.r*.35)
  if o.kind>=4 and o.kind<=6 then
   local r=o.kind==6 and 125 or 175
   col(o.kind==4 and C.lilac or (o.kind==5 and C.blue or C.gold),o.fx>0 and .17 or .055)
   lg.circle('fill',o.x,o.y,r)
   col(C.paper,.22)
   lg.setLineWidth(2)
   lg.circle('line',o.x,o.y,r)
   lg.setLineWidth(1)
  end
  local pulse=Prefs.reduced and 1 or 1+(o.fx>0 and .10*math.sin(t*25) or .018*math.sin(t*5))
  S.draw(name,o.x,o.y,frame,o.r*2.55*pulse,fade)
  if o.life<4 then
   col(C.paper,.85*fade)
   lg.setLineWidth(3)
   lg.arc('line','open',o.x,o.y,o.r+9,-math.pi/2,-math.pi/2+math.pi*2*o.life/4)
   lg.setLineWidth(1)
  end
 end
end
function M.mascot(x,y,scale,t)
 if Prefs.reduced then t=0 end
 lg.push()
 lg.translate(x,y+math.sin(t*2.7)*4)
 col(C.gold,.2)
 lg.circle('fill',0,-40,112*scale)
 col(C.paper,.53)
 lg.circle('fill',0,-40,89*scale)
 S.draw('character_diagonal',-27,-22,(math.floor(t*5)%4)+1,156*scale)
 S.draw('ball',74,23,math.floor(t*9)%8+1,86*scale)
 lg.pop()
end
return M
