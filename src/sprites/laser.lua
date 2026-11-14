local P=require('src.sprites.paint')
return {frames=8,draw=function(i)
 P.glow(42,.18,P.colors.red)
 P.disc(0,0,44,P.colors.navy,P.colors.ink,5)
 P.disc(0,0,31,P.colors.blueLight,P.colors.ink,4)
 P.disc(0,0,20,P.colors.red,P.colors.ink,3)
 P.disc(0,0,10,P.colors.cream)
end}
