local I={}
local g=love.graphics
local pi=math.pi
local function path(...) g.polygon('fill',...) end
function I.draw(name,x,y,size,c)
 size=size or 24
 g.push('all')
 g.translate(x,y)
 g.scale(size/24)
 g.setColor((c or {1,1,1})[1],(c or {1,1,1})[2],(c or {1,1,1})[3],(c or {1,1,1})[4] or 1)
 g.setLineWidth(2.8)
 if name=='play' then
  path(-6,-9,9,0,-6,9)
 elseif name=='pause' then
  g.rectangle('fill',-8,-9,6,18,2,2)
  g.rectangle('fill',2,-9,6,18,2,2)
 elseif name=='home' then
  path(-11,-1,0,-11,11,-1,8,1,8,10,-7,10,-7,1)
  g.setColor(.15,.35,.47,1)
  g.rectangle('fill',-2,3,4,7,1,1)
 elseif name=='help' then
  g.circle('line',0,0,10)
  g.arc('line',0,-3,4,-pi*.9,pi*.3)
  g.line(2,0,0,4)
  g.circle('fill',0,8,1.8)
 elseif name=='sound' or name=='mute' then
  path(-10,-4,-5,-4,1,-10,1,10,-5,4,-10,4)
  if name=='sound' then
   g.arc('line','open',3,0,7,-pi/3,pi/3)
   g.arc('line','open',3,0,11,-pi/3,pi/3)
  else
   g.line(6,-6,13,6)
   g.line(13,-6,6,6)
  end
 elseif name=='coin' then
  g.circle('fill',0,0,11)
  g.setColor(.78,.43,.13,1)
  g.circle('line',0,0,8)
  g.line(-3,0,3,0)
  g.circle('line',0,0,4)
 elseif name=='trophy' then
  g.rectangle('fill',-6,-9,12,11,3,3)
  g.arc('line','open',-6,-4,5,pi/2,pi*1.5)
  g.arc('line','open',6,-4,5,-pi/2,pi/2)
  g.rectangle('fill',-2,2,4,7)
  g.rectangle('fill',-7,8,14,3,2,2)
 elseif name=='clock' then
  g.circle('line',0,0,10)
  g.line(0,-6,0,0,5,3)
 elseif name=='star' then
  local pts={}
  for i=0,9 do local a=-pi/2+i*pi/5 local r=(i%2==0) and 11 or 5
   pts[#pts+1]=math.cos(a)*r pts[#pts+1]=math.sin(a)*r end
  g.polygon('fill',pts)
 elseif name=='check' then
  g.setLineWidth(3.8) g.line(-9,0,-2,7,10,-8)
 elseif name=='arrows' then
  g.line(-8,-4,-8,-9,8,-9,8,4)
  path(3,4,13,4,8,10)
  g.line(8,9,8,11,-8,11,-8,-2)
  path(-13,-2,-3,-2,-8,-8)
 elseif name=='warning' then
  path(0,-11,11,9,-11,9)
  g.setColor(.55,.25,.09)
  g.rectangle('fill',-1.5,-5,3,8,1,1)
  g.circle('fill',0,6,1.6)
 elseif name=='spark' then
  path(0,-11,3,-3,11,0,3,3,0,11,-3,3,-11,0,-3,-3)
 elseif name=='back' then
  g.setLineWidth(3.8) g.line(-2,-9,-10,0,-2,9)
  g.line(-10,0,10,0)
 end
 g.pop()
end
return I
