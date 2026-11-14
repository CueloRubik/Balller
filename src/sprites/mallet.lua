local P=require('src.sprites.paint')
return {frames=8,draw=function(i)
 local p=(i-1)/8*math.pi*2
 P.glow(37,.14,P.colors.orange)
 P.disc(0,0,42,P.colors.gold,P.colors.ink,5)
 P.box(-11,-7,22,44,8,P.colors.steel,P.colors.ink,4)
 P.box(-31+math.sin(p)*5,-29,62,25,9,P.colors.red,P.colors.ink,5)
 P.box(-25+math.sin(p)*5,-24,50,7,3,P.colors.pink)
end}
