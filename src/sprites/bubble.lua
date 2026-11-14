local P=require('src.sprites.paint')
return {frames=8,draw=function(i)
 P.glow(38,.18,P.colors.blue)
 P.disc(0,0,39,{.40,.85,1,.30},P.colors.blue,5)
 P.disc(-10,-12,8,P.colors.white)
 P.disc(12,11,5,P.colors.cream)
end}
