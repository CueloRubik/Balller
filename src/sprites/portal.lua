local P=require('src.sprites.paint')
return {frames=8,draw=function(i)
 local a=i/8*math.pi*2
 P.glow(41,.19,P.colors.blue)
 P.disc(0,0,44,P.colors.navy,P.colors.ink,5)
 P.disc(0,0,33,P.colors.blueLight,P.colors.navy,5)
 P.disc(0,0,23,P.colors.blue,P.colors.ink,3)
 for j=0,2 do
  local phi=a+j*math.pi*2/3
  P.disc(math.cos(phi)*18,math.sin(phi)*18,6,P.colors.cream,P.colors.ink,2)
 end
 P.disc(0,0,7,P.colors.white)
end}
