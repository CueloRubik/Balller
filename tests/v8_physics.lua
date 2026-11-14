require('tests.support.headless')
local G=require('src.game')
local B=require('src.ball')
local O=require('src.objects')
local H=require('src.hazards')
local A=require('src.arena')
local function speed(target,label)
 local actual=math.sqrt(G.ball.vx^2+G.ball.vy^2)
 assert(math.abs(actual-target)<.00001,label..': '..actual..' / '..target)
 assert(G.state=='playing',label..': unexpected state '..G.state)
end
local scenarios={'wall','player','shield','boost','magnet','fan','clock','vortex','pulse','portal','zero'}
for _,fps in ipairs({30,60,120}) do
 for mode=1,4 do
  for _,scenario in ipairs(scenarios) do
   assert(G.newRun(1,mode))
   G.round=10
   assert(G.startRound())
   local target=G.ballSpeed()
   G.spawn=10000
   G.player.x,G.player.y=200,180
   G.ball.x,G.ball.y=500,330
   G.ball.vx,G.ball.vy=-target,0
   local b=G.ball
   if scenario=='wall' then
    local left=A.bounds(b.r)
    b.x=left+.1
   elseif scenario=='player' then
    G.player.x,G.player.y=b.x-20,b.y
   elseif scenario=='zero' then
    b.vx,b.vy=0,0
   elseif scenario=='pulse' then
    G.player.x,G.player.y=b.x-70,b.y
    assert(G.pulse())
   elseif scenario=='vortex' then
    H.list={{kind=5,x=b.x-60,y=b.y,r=34,age=2,warning=1,active=10,fade=.5,vx=0,vy=0,phase=0,cooldown=0}}
   else
    local kinds={shield=1,boost=2,magnet=4,fan=5,clock=6,portal=8}
    local kind=assert(kinds[scenario])
    local info=O.types[kind]
    O.list={{kind=kind,x=b.x-30,y=b.y,r=info.r,hits=info.hits,life=info.duration,fullLife=info.duration,phase=0,fx=0}}
    if scenario=='magnet' or scenario=='fan' then O.list[1].y=b.y-40 end
    if scenario=='clock' then
     H.list={{kind=3,x=750,y=450,r=30,age=2,warning=1,active=10,fade=.5,vx=100,vy=0,phase=0,cooldown=0}}
    end
   end
   G.update(1/fps)
   local label=scenario..' mode '..mode..' @'..fps
   speed(target,label)
   if scenario=='wall' then assert(G.wallBounces==1)
   elseif scenario=='player' then assert(G.roundHits==1)
   elseif scenario=='shield' or scenario=='boost' then assert(O.list[1].hits==O.types[O.list[1].kind].hits-1)
   elseif scenario=='portal' then assert(b.portalCooldown>0 and b.x~=500)
   elseif scenario=='zero' then assert(b.vx==target and b.vy==0)
   elseif scenario=='magnet' then assert(b.vy<0)
   elseif scenario=='fan' then assert(b.vy>0)
   elseif scenario=='clock' then assert(math.abs(H.list[1].x-(750+100*.72/fps))<.00001)
   elseif scenario=='vortex' then assert(b.vy~=0)
   end
   for _=2,fps do G.update(1/fps) speed(target,label) end
   G.togglePause()
   local x,y,vx,vy=b.x,b.y,b.vx,b.vy
   G.update(1)
   assert(b.x==x and b.y==y and b.vx==vx and b.vy==vy)
   assert(G.loadRun(1) and G.state=='pause')
   G.togglePause()
   speed(target,label..' resumed')
  end
 end
end
for mode=1,4 do
 assert(G.newRun(1,mode))
 local previous=0
 for round=1,999 do
  G.round=round
  local target=G.ballSpeed()
  assert(target>=previous and target<=365)
  previous=target
 end
end
print('v8 baseline: 132 interaction scenarios, 30/60/120 fps, four difficulties, pause/resume and speed cap OK')
