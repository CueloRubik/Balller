local P=require('src.sprites.paint')
local k=P.colors
local g=love.graphics
local M={frames=16}
function M.draw(frame)
 local face=math.floor((frame-1)/4)
 local phase=(frame-1)%4
 local stride=({0,5,0,-5})[phase+1]
 g.rotate(face*math.pi/2)
 P.ellipse(0,26,19,12,k.navy,k.ink,4)
 P.ellipse(-12,22+stride,9,12,k.navy,k.ink,3)
 P.ellipse(12,22-stride,9,12,k.navy,k.ink,3)
 P.ellipse(-12,25+stride,6,5,k.white)
 P.ellipse(12,25-stride,6,5,k.white)
 P.ellipse(-27,-1-stride*.5,9,16,k.cream,k.ink,3)
 P.ellipse(27,-1+stride*.5,9,16,k.cream,k.ink,3)
 P.box(-34,5-stride*.5,14,8,4,k.blue,k.ink,2)
 P.box(20,5+stride*.5,14,8,4,k.blue,k.ink,2)
 P.ellipse(0,3,29,30,k.teal,k.ink,4)
 P.ellipse(0,11,25,17,k.mint)
 P.box(-23,11,46,7,3,k.white)
 P.ellipse(0,-15,31,30,k.cream,k.ink,4)
 P.path({-30,-21,-26,-39,-13,-34,-3,-47,13,-36,25,-38,31,-23,24,-17,12,-19,4,-14,-6,-21,-18,-15},k.navy)
 P.box(-29,-13,58,7,3,k.blue,k.ink,2)
 P.box(-25,-12,50,3,1,k.white)
 P.ellipse(-11,0,4.1,5.5,k.ink)
 P.ellipse(11,0,4.1,5.5,k.ink)
 P.ellipse(-12,-2,1.2,2,k.white)
 P.ellipse(10,-2,1.2,2,k.white)
 P.line({-4,11,0,13,4,11},2,k.ink)
end
return M
