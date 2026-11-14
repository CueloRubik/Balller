local C=require("src.theme")
local Player=require("src.player")
local Ball=require("src.ball")
local H=require("src.hazards")
local O=require("src.objects")
local FX=require("src.particles")
local Sound=require("src.audio")
local Save=require("src.save")
local G={state="menu",score=0,coins=0,time=0,spawn=0,t=0,notice="",noticeT=0,reason="",shake=0}
function G.notify(s)
  G.notice=s
  G.noticeT=1.8
end
function G.start()
  G.state="playing"
  G.score=0
  G.coins=35
  G.time=0
  G.spawn=3.8
  G.shake=0
  G.player=Player.new()
  G.ball=Ball.new()
  H.clear()
  O.clear()
  FX.clear()
  G.notify("Cuida la pelota")
  Sound.play("button")
end
function G.finish(reason)
  if G.state~="playing" then return end
  G.state="over"
  G.reason=reason
  G.shake=9
  FX.burst(G.ball.x,G.ball.y,C.red,32)
  Save.record(G.score)
  Sound.play("lose")
end
function G.place(x,y)
  if G.state~="playing" then return end
  local ok,value=O.place(x,y,G.coins,G.player,G.ball,H.list)
  if ok then
    G.coins=G.coins-value
    FX.burst(x,y,C.mint,13)
    Sound.play("place")
  else
    G.notify(value)
  end
end
function G.update(dt)
  G.t=G.t+dt
  G.noticeT=math.max(0,G.noticeT-dt)
  G.shake=math.max(0,G.shake-25*dt)
  FX.update(dt)
  if G.state~="playing" then return end
  G.time=G.time+dt
  G.score=G.score+dt*3
  G.spawn=G.spawn-dt
  if G.spawn<=0 then
    if H.spawn(G.player,G.ball) then Sound.play("warn") end
    G.spawn=math.max(1.9,5.1-G.time*.015)
  end
  Player.update(G.player,dt)
  Ball.update(G.ball,dt,function(x,y) FX.burst(x,y,C.paper,3) end)
  if Ball.hitPlayer(G.ball,G.player) then
    G.score=G.score+10
    G.coins=G.coins+2
    G.shake=2
    FX.burst(G.ball.x,G.ball.y,C.gold,9)
    Sound.play("hit")
  end
  if O.collide(G.ball) then
    G.score=G.score+5
    FX.burst(G.ball.x,G.ball.y,C.mint,7)
    Sound.play("hit")
  end
  O.update(dt)
  local fatal=H.update(dt,G.ball,O.list)
  if fatal then
    G.finish(fatal=="pinchos" and "La pelota se poncho" or "Cayo en una alcantarilla")
  end
end
function G.togglePause()
  if G.state=="playing" then G.state="pause" elseif G.state=="pause" then G.state="playing" end
end
return G
