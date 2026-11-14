local P={}
local g=love.graphics
P.colors={ink={.14,.25,.34},navy={.13,.28,.51},cream={1,.97,.84},white={1,1,1},blue={.24,.61,.94},blueLight={.59,.86,1},teal={.15,.72,.62},mint={.53,.95,.73},orange={1,.68,.20},gold={1,.86,.42},red={.94,.31,.34},pink={1,.66,.58},steel={.40,.56,.65}}
function P.c(v,a) g.setColor(v[1],v[2],v[3],a or 1) end
function P.disc(x,y,r,fill,stroke,sw)
 if stroke then P.c(stroke) g.circle('fill',x,y,r+(sw or 3)) end
 P.c(fill) g.circle('fill',x,y,r)
end
function P.ellipse(x,y,rx,ry,fill,stroke,sw)
 if stroke then P.c(stroke) g.ellipse('fill',x,y,rx+(sw or 3),ry+(sw or 3)) end
 P.c(fill) g.ellipse('fill',x,y,rx,ry)
end
function P.box(x,y,w,h,r,fill,stroke,sw)
 if stroke then P.c(stroke) g.rectangle('fill',x-(sw or 3),y-(sw or 3),w+2*(sw or 3),h+2*(sw or 3),r+(sw or 3)) end
 P.c(fill) g.rectangle('fill',x,y,w,h,r)
end
function P.path(points,fill)
 P.c(fill) g.polygon('fill',points)
end
function P.line(points,width,color)
 P.c(color) g.setLineWidth(width) g.line(points) g.setLineWidth(1)
end
function P.glow(r,a,c)
 c=c or P.colors.white
 for i=4,1,-1 do P.c(c,a*(5-i)/24) g.circle('fill',0,0,r+i*4) end
end
return P
