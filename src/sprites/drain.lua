local P=require('src.sprites.paint')
local k=P.colors
local g=love.graphics
local M={frames=8}
function M.draw(f)
 local opened=math.min(1,(f-1)/5)
 P.glow(35,.07,k.blue)
 P.disc(0,0,37,k.steel,k.ink,4)
 P.disc(0,0,29,k.navy,k.white,2)
 P.disc(0,0,25,{.07,.16,.26})
 g.push()
 g.translate(-opened*25,0)
 P.c(k.steel)
 g.setLineWidth(6)
 for i=-2,2 do
  g.line(-21,i*9,21,i*9)
 end
 g.setLineWidth(1)
 P.c(k.white,.55)
 g.arc('line','open',0,0,22,math.pi,math.pi*1.6)
 g.pop()
end
return M
