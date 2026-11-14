local P=require('src.sprites.paint')
local k=P.colors
local g=love.graphics
local M={frames=8}
function M.draw(f)
 local activation=math.min(1,(f-1)/3)
 local rr=15+activation*24
 P.glow(40,.12,k.red)
 P.disc(0,0,33,{.75,.35,.34},k.ink,4)
 P.disc(0,0,27,k.red,k.pink,2)
 for i=1,10 do
  local a=(i-1)*math.pi/5+(f-1)*.015
  local inside=rr*.5
  local outside=rr
  g.push() g.rotate(a)
  P.path({inside,-7,outside,0,inside,7},k.cream)
  P.path({inside+3,-3,outside-4,0,inside+3,3},k.pink)
  g.pop()
 end
 P.disc(0,0,10,k.red,k.ink,3)
 P.disc(-2,-2,4,k.pink)
end
return M
