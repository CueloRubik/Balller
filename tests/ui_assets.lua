local calls,quads={},{}
local missing,corrupt=false,false
love={filesystem={getInfo=function() return not missing and {} or nil end},graphics={
 newImage=function(path)
  if corrupt then error('simulated PNG corruption') end
  return {setFilter=function() end,getDimensions=function() if path:find('surfaces') then return 1024,640 else return 512,256 end end}
 end,
 newQuad=function(x,y,w,h,iw,ih)
  assert(x>=0 and y>=0 and w>0 and h>0 and x+w<=iw and y+h<=ih)
  local q={x=x,y=y,w=w,h=h};quads[#quads+1]=q;return q
 end,
 setColor=function() end,push=function() end,pop=function() end,
 draw=function(image,q,x,y,r,sx,sy)
  assert(sx>0 and sy>0)
  calls[#calls+1]={q=q,x=x,y=y,sx=sx,sy=sy}
 end
}}
local A=require('src.presentation.assets')
A.load()
for column=0,5 do for state=0,3 do
 local first=#calls
 assert(A.surface(column,state,10,20,181,39))
 assert(#calls-first==6)
 for i=first+1,#calls do
  local c=calls[i]
  assert(c.x>=10 and c.y>=20 and c.x+c.q.w*c.sx<=191.0001 and c.y+c.q.h*c.sy<=59.0001)
 end
end end
for row=0,4 do assert(A.surface(6,row,0,0,1000,680)) end
assert(A.surface(0,0,0,0,20,18))
local count=#quads
for _=1,20 do A.surface(0,0,0,0,181,39) end
assert(#quads==count,'Repeated drawing must reuse cached quads')
for _,name in ipairs({'play','gear','delete','shop','chapter','objective'}) do assert(A.icon(name,32,32,40)) end
assert(not A.icon('unknown',0,0,24))
missing=true A.load()
assert(not A.surface(0,0,0,0,100,40) and not A.icon('play',0,0,24))
missing=false corrupt=true A.load()
assert(not A.surface(0,0,0,0,100,40) and not A.image('backdrop',0,0,1000,680))
print('UI atlas: 24 button states, five panels, nine-slice bounds, cache and missing/corrupt fallback OK')
