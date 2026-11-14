local U=require("src.util")
local C=require("src.theme")
local A=require("src.arena")
local Player=require("src.player")
local Ball=require("src.ball")
local H=require("src.hazards")
local O=require("src.objects")
local FX=require("src.particles")
local Sound=require("src.audio")
local Save=require("src.save")
local Feedback=require("src.feedback")
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
    Feedback.reset()
    G.notify("Cuida la pelota")
    Sound.play("button")
end
function G.finish(reason)
    if G.state~="playing" then return end
    G.state="over"
    G.reason=reason
    G.shake=9
    FX.burst(G.ball.x,G.ball.y,C.red,32)
    Feedback.resetCombo()
    Save.record(G.score)
    Sound.play("lose")
end
function G.place(x,y)
    if G.state~="playing" then return end
    local ok,value=O.place(x,y,G.coins,G.player,G.ball,H.list)
    if ok then
        G.coins=G.coins-value
        FX.burst(x,y,C.mint,13)
        Feedback.pop(x,y-28,"¡LISTO!",C.mintDark)
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
    Feedback.update(dt)
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
    local oldScore=G.score
    if Ball.hitPlayer(G.ball,G.player) then
        local nextCombo=Feedback.comboTimer>0 and Feedback.combo+1 or 1
        local multiplier=math.min(3,1+math.floor((nextCombo-1)/3))
        local gain=10*multiplier
        G.score=G.score+gain
        G.coins=G.coins+2
        G.shake=math.min(3,1+nextCombo*.25)
        FX.burst(G.ball.x,G.ball.y,C.gold,8+multiplier*3)
        Feedback.hit(G.ball.x,G.ball.y,gain)
        Sound.play("hit",1+math.min(.3,Feedback.combo*.035))
    end
    if O.collide(G.ball) then
        G.score=G.score+5
        FX.burst(G.ball.x,G.ball.y,C.mint,7)
        Feedback.pop(G.ball.x,G.ball.y-24,"+5",C.mintDark)
        Sound.play("hit",1.1)
    end
    if math.floor(G.score/150)>math.floor(oldScore/150) then
        Feedback.milestoneReached(math.floor(G.score/150)*150)
        FX.burst(G.ball.x,G.ball.y,C.gold,18)
        Sound.play("coin",1.12)
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
