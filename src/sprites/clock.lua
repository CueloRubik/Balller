local P=require('src.sprites.paint')
local g=love.graphics
local k=P.colors
local M={frames=8}
function M.draw(f)
 P.disc(0,0,38,k.gold,k.ink,5)
 P.disc(0,0,29,k.white,k.ink,3)
 for i=1,4 do
  local a=i*math.pi/2
  P.disc(math.cos(a)*22,math.sin(a)*22,3,k.orange)
 end
 g.rotate((f-1)*math.pi/4)
 P.line({0,0,0,-19},6,k.ink)
 P.line({0,0,12,8},4,k.orange)
 P.disc(0,0,4,k.ink)
end
return M
