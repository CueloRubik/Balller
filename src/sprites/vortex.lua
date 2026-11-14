local P=require('src.sprites.paint')
local g=love.graphics
local M={frames=8}
function M.draw(f)
 P.disc(0,0,42,{.5,.39,.85},P.colors.ink,4)
 g.push() g.rotate((f-1)*math.pi/4)
 for i=1,3 do
  g.push() g.rotate((i-1)*math.pi*2/3)
  P.line({0,0,-15,-22,5,-33,28,-20},9,{.91,.83,1})
  g.pop()
 end
 g.pop()
 P.disc(0,0,10,P.colors.navy,P.colors.white,3)
end
return M
