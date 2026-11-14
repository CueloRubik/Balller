package.path='./?.lua;./?/init.lua;'..package.path
dofile('tests/smoke.lua')
local G=require('src.game')
local Save=require('src.save')
local H=require('src.hazards')
local O=require('src.objects')
local Runfile=require('src.runfile')
local Difficulty=require('src.difficulty')
assert(#Difficulty.list==4)
for i=1,4 do
 assert(G.newRun(1,i))
 assert(G.difficulty==i)
 assert(G.rescues==Difficulty.get(i).graces)
 assert(G.startRound())
 assert(G.state=='playing')
 assert(math.abs(G.roundDuration-(28*Difficulty.get(i).roundTime))<1)
 assert(G.saveRun())
 local saved=assert(Save.loadRun(1))
 assert(saved.difficulty==i and saved.rescues==Difficulty.get(i).graces)
 assert(G.loadRun(1) and G.difficulty==i and G.state=='pause')
end
assert(G.newRun(1,1) and G.startRound())
G.spawn=100
H.list={{kind=1,x=G.ball.x,y=G.ball.y,r=29,age=4,warning=1.8,active=5,fade=.5,vx=0,vy=0,phase=0,cooldown=0}}
G.update(.02)
assert(G.state=='playing' and G.rescues==1 and G.rescueInvuln>0)
G.update(.02)
assert(G.state=='playing' and G.rescues==1,'No perder otro rescate inmediatamente')
local snap=assert(G.snapshot())
assert(snap.difficulty==1 and snap.rescueInvuln>0)
assert(Runfile.decode(assert(Runfile.encode(snap))).difficulty==1)
assert(G.saveRun())
assert(G.loadRun(1) and G.rescueInvuln>0)
assert(G.newRun(2,2))
G.coins=900
assert(G.buy(7) and G.buy(8))
assert(G.inventory[7]==1 and G.inventory[8]==1)
assert(G.saveRun())
assert(Save.loadRun(2).inventory[8]==1)
assert(G.startRound())
O.clear()
local b=G.ball
local bubble={x=b.x,y=b.y,r=29,hits=1,life=20,fullLife=20,kind=7,phase=0,fx=0}
O.list={bubble}
assert(O.collide(b) and b.guard>0 and bubble.hits==0)
O.clear()
b.guard=0
b.portalCooldown=0
local portal={x=b.x,y=b.y,r=28,hits=2,life=20,fullLife=20,kind=8,phase=0,fx=0}
O.list={portal}
local oldx=b.x
assert(O.collide(b) and b.portalCooldown>0 and b.x~=oldx)
assert(portal.hits==1)
local function hazard(kind,x,y)
 return {kind=kind,x=x,y=y,r=30,age=3,warning=1,active=5,fade=.5,vx=0,vy=0,phase=0,cooldown=0}
end
b.x,b.y=480,330
H.list={hazard(6,480,330)}
assert(H.update(.02,b,{})=='martillo')
H.list={hazard(7,480,330)}
assert(H.update(.02,b,{})=='laser')
assert(G.newRun(3,1))
local oldSlot=assert(Save.loadRun(3))
assert(Save.clearRun(3))
assert(not Save.hasRun(3) and Save.hasRun(1) and Save.hasRun(2))
assert(G.newRun(3,4) and Save.loadRun(3).difficulty==4)
assert(G.startTutorial() and G.slot==nil and G.tutorialStep==1)
love.keyboard.isDown=function() return true end
for i=1,70 do G.update(.02) end
love.keyboard.isDown=function() return false end
assert(G.tutorialStep==2)
G.ball.x,G.ball.y=G.player.x+20,G.player.y
G.ball.cooldown=0
G.update(.02)
assert(G.tutorialStep==3)
G.ball.x,G.ball.y=G.player.x+60,G.player.y
assert(G.pulse() and G.tutorialStep==4)
O.selected=1
G.ball.x,G.ball.y=770,360
G.player.x,G.player.y=220,270
assert(G.place(460,320))
assert(G.tutorialStep==5 and G.state=='tutorialDone' and Save.tutorialDone)
assert(G.slot==nil)
G.backToMenu()
assert(Save.hasRun(1) and Save.hasRun(2) and Save.hasRun(3))
print('Balller v6: 4 difficulties, tutorial, save compatibility, new objects, hazards, rescues and slots OK')
