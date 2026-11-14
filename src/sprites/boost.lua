local P=require('src.sprites.paint')
local k=P.colors
local g=love.graphics
local M={frames=8}
function M.draw(f)
 local pulse=1+math.sin((f-1)*math.pi/4)*.07
 P.glow(33,.07,k.mint)
 g.scale(pulse)
 P.disc(0,0,31,k.teal,k.ink,4)
 P.disc(0,0,24,k.mint,k.white,2)
 P.disc(0,0,17,k.teal,k.navy,2)
 P.path({-9,4,3,4,3,13,15,-2,3,-17,3,-8,-9,-8},k.white)
end
return M
