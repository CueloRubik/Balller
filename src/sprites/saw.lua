local P=require('src.sprites.paint')
local k=P.colors
local g=love.graphics
local M={frames=8}
function M.draw(f)
 P.disc(0,0,40,k.steel,k.ink,4)
 for i=1,12 do
  g.push() g.rotate((i-1)*math.pi/6+(f-1)*math.pi/4)
  P.path({-9,-29,0,-46,9,-29},k.cream)
  g.pop()
 end
 P.disc(0,0,26,k.blue,k.ink,4)
 P.disc(0,0,12,k.orange,k.ink,3)
end
return M
