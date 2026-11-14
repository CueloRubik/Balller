local P=require('src.sprites.paint')
local k=P.colors
local g=love.graphics
local M={frames=8}
function M.draw(f)
 P.glow(34,.07,k.gold)
 P.disc(0,0,37,k.gold,k.ink,4)
 P.disc(0,0,29,k.orange,k.cream,3)
 P.disc(0,0,22,k.gold,k.ink,2)
 local offset=math.sin((f-1)*math.pi/4)*2
 P.line({-18,-14+offset,18,-14+offset},4,k.cream)
 P.line({-18,0+offset,18,0+offset},4,k.cream)
 P.line({-18,14+offset,18,14+offset},4,k.cream)
 P.disc(-24,0,3,k.ink)
 P.disc(24,0,3,k.ink)
end
return M
