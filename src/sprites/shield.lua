local P=require('src.sprites.paint')
local k=P.colors
local g=love.graphics
local M={frames=8}
function M.draw(f)
 local pulse=.5+.5*math.sin((f-1)*math.pi/4)
 P.glow(36,.06+pulse*.06,k.blue)
 P.disc(0,0,34,k.blue,k.ink,4)
 P.disc(0,0,26,k.blueLight,k.white,3)
 P.disc(0,0,18,k.blue,k.navy,3)
 P.path({-5,-18,11,-18,2,-2,13,-2,-10,20,-3,5,-14,5},k.white)
end
return M
