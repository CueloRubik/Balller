local P=require('src.sprites.paint')
local k=P.colors
local g=love.graphics
local M={frames=8}
function M.draw(f)
 P.glow(30,.2,k.gold)
 P.disc(0,0,27,k.orange,k.ink,4)
 P.disc(-3,-4,22,k.gold)
 g.push()
 g.rotate((f-1)*math.pi/4)
 P.c(k.ink) g.setLineWidth(3)
 g.arc('line','open',0,0,22,-math.pi*.45,math.pi*.45)
 g.arc('line','open',0,0,22,math.pi*.55,math.pi*1.45)
 g.line(-22,0,22,0)
 g.setLineWidth(1)
 g.pop()
 P.ellipse(-11,-11,8,5,k.white,nil,0)
 P.disc(10,13,3,k.orange)
end
return M
