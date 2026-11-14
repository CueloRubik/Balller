local P=require('src.sprites.paint')
local g=love.graphics
local k=P.colors
local M={frames=8}
function M.draw(f)
 P.disc(0,0,38,k.blueLight,k.ink,5)
 P.disc(0,0,27,k.white,k.ink,3)
 g.rotate((f-1)*math.pi/4)
 for i=1,4 do
  g.push() g.rotate(i*math.pi/2)
  P.ellipse(0,-15,10,17,k.blue,k.ink,2)
  g.pop()
 end
 P.disc(0,0,9,k.gold,k.ink,3)
end
return M
