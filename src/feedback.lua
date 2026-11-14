local C=require('src.theme')
local UI=require('src.ui')
local M={list={},flash=0,combo=0,comboTimer=0,milestone=0}
local lg=love.graphics
function M.reset()
 M.list={}
 M.flash=0
 M.combo=0
 M.comboTimer=0
 M.milestone=0
end
function M.pop(x,y,s,c)
 M.list[#M.list+1]={x=x,y=y,txt=s,life=.85,max=.85,c=c or C.ink}
end
function M.hit(x,y,points)
 M.combo=M.comboTimer>0 and math.min(8,M.combo+1) or 1
 M.comboTimer=4.5
 M.flash=.15
 M.pop(x,y-24,'+'..points, C.ink)
 if M.combo>1 and M.combo%3==0 then
  M.pop(x,y-56,'¡RACHA '..M.combo..'!',C.mintDark)
 end
end
function M.resetCombo()
 M.combo=0
 M.comboTimer=0
end
function M.milestoneReached(n)
 M.milestone=1.5
 M.pop(500,210,'¡'..n..' PUNTOS!',C.mintDark)
end
function M.update(dt)
 M.comboTimer=math.max(0,M.comboTimer-dt)
 if M.comboTimer==0 then M.combo=0 end
 M.flash=math.max(0,M.flash-dt)
 M.milestone=math.max(0,M.milestone-dt)
 for i=#M.list,1,-1 do
  local p=M.list[i]
  p.life=p.life-dt
  p.y=p.y-43*dt
  if p.life<=0 then table.remove(M.list,i) end
 end
end
function M.draw()
 for _,p in ipairs(M.list) do
  local alpha=math.min(1,p.life*2.5)
  lg.push()
  lg.translate(p.x,p.y)
  local s=1+(.85-p.life)*.12
  lg.scale(s)
  lg.setFont(UI.fonts.body)
  local w=lg.getFont():getWidth(p.txt)
  UI.color({1,1,1},alpha*.95)
  lg.print(p.txt,-w/2+2,2)
  UI.color(p.c,alpha)
  lg.print(p.txt,-w/2,0)
  lg.pop()
 end
end
return M
