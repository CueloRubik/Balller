local P=require('src.sprites.paint')
local k=P.colors
local g=love.graphics
local M={frames=8}
function M.draw(f)
 local pulse=1+math.sin((f-1)*math.pi/4)*.06
 g.scale(pulse)
 P.disc(0,0,41,k.gold,k.ink,4)
 P.disc(0,0,31,k.cream,k.orange,3)
 P.path({5,-26,-16,5,0,5,-8,26,21,-11,5,-11},k.orange)
end
return M
