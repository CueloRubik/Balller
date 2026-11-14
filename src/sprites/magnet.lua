local P=require('src.sprites.paint')
local g=love.graphics
local k=P.colors
local M={frames=8}
function M.draw(f)
 P.disc(0,0,38,k.pink,k.ink,5)
 g.rotate(math.sin(f*math.pi/4)*.09)
 P.disc(0,0,27,k.cream)
 P.line({-17,-17,-17,8,-9,17,9,17,17,8,17,-17},14,k.ink)
 P.line({-17,-17,-17,8,-9,17,9,17,17,8,17,-17},9,k.white)
 P.box(-24,-24,14,16,3,k.red,k.ink,2)
 P.box(10,-24,14,16,3,k.red,k.ink,2)
end
return M
