package.path='./?.lua;./?/init.lua;'..package.path
local Codec=require('src.runfile')
local p={x=280,y=330,r=19,dx=1,dy=0,vx=250,vy=0,speed=265,hit=0,walk=3}
local b={x=630,y=313,r=16,vx=-190,vy=145,cooldown=0,spin=7}
local s={state='playing',round=6,score=1560,coins=133,time=92.12,roundLeft=14.35,roundDuration=39,spawn=.15,roundHits=7,reward=50,previousRound=5,previousHits=8,player=p,ball=b,inventory={1,3,0,2,0,1},hazards={{kind=3,x=400,y=280,r=30,age=3,warning=2.1,active=5.2,fade=.5,vx=-130,vy=0,phase=1.3,cooldown=0}},objects={{x=320,y=200,r=32,kind=1,hits=5,life=13.5,fullLife=32,phase=2.3,fx=.13}}}
local encoded=assert(Codec.encode(s))
local restored=assert(Codec.decode(encoded))
assert(restored.round==6 and restored.score==1560 and restored.coins==133)
assert(restored.state=='playing' and restored.inventory[2]==3)
assert(restored.ball.vx==-190 and restored.player.walk==3)
assert(#restored.hazards==1 and restored.hazards[1].vx==-130)
assert(#restored.objects==1 and restored.objects[1].hits==5)
assert(Codec.decode(encoded:gsub('G|6.00000|','G|99999.00000|',1))==nil)
assert(Codec.decode(encoded:gsub('133.00000','-5.00000',1))==nil)
assert(Codec.decode(encoded..'\nprint("NO")')==nil)
assert(Codec.decode('garbage')==nil)
assert(Codec.decode(encoded:gsub('BALLLER_RUN_2','BALLLER_RUN_1'))==nil)
assert(Codec.encode({state='playing'})==nil)
print('Balller save codec OK')
