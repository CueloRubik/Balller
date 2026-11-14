local C=require('src.theme')
local U=require('src.util')
local Player=require('src.player')
local Ball=require('src.ball')
local H=require('src.hazards')
local O=require('src.objects')
local FX=require('src.particles')
local Sound=require('src.audio')
local Save=require('src.save')
local Feedback=require('src.feedback')
local G={state='menu',winFlash=0,slot=nil,score=0,coins=0,time=0,spawn=0,t=0,notice='',noticeT=0,reason='',shake=0,round=1,roundLeft=0,roundDuration=0,roundHits=0,wallBounces=0,placed=0,boots=0,pulseCooldown=0,pulseVisual=0,autosaveClock=0,reward=0,previousRound=0,previousHits=0,inventory={0,0,0,0,0,0}}
local function copyArray(list)
 local result={}
 for i,entry in ipairs(list) do
  local e={}
  for k,v in pairs(entry) do
   if type(v)=='number' then e[k]=v end
  end
  result[i]=e
 end
 return result
end
local function copyNumbers(object)
 local result={}
 for k,v in pairs(object) do if type(v)=='number' then result[k]=v end end
 return result
end
function G.notify(s)
 G.notice=s
 G.noticeT=2.1
end
function G.goalKind()
 return ({'hits','walls','places'})[(G.round-1)%3+1]
end
function G.goal()
 local kind=G.goalKind()
 if kind=='walls' then return math.min(12,3+math.floor(G.round*.6)) end
 if kind=='places' then return math.min(3,1+math.floor(G.round/5)) end
 return math.min(15,5+G.round)
end
function G.progress()
 local kind=G.goalKind()
 if kind=='walls' then return G.wallBounces end
 if kind=='places' then return G.placed end
 return G.roundHits
end
function G.objectiveText()
 local kind=G.goalKind()
 if kind=='walls' then return 'Rebotes en paredes' end
 if kind=='places' then return 'Defensas colocadas' end
 return 'Golpes a la pelota'
end
function G.bonus()
 local base=12+math.min(12,math.floor((G.round-1)/3)*2)
 return G.goalKind()=='places' and base+12 or base
end
function G.upgradeCost() return G.boots>=3 and nil or 65+G.boots*55 end
function G.buyUpgrade()
 if G.state~='shop' then return false end
 local cost=G.upgradeCost()
 if not cost then G.notify('Mejora al máximo nivel') return false end
 if G.coins<cost then G.notify('Te faltan '..(cost-G.coins)..' monedas') Sound.play('warn') return false end
 G.coins=G.coins-cost
 G.boots=G.boots+1
 G.notify('¡Zapatillas nivel '..G.boots..'! +20 de velocidad')
 Sound.play('upgrade')
 G.saveRun()
 return true
end
function G.duration()
 return math.min(55,28+(G.round-1)*2)
end
function G.snapshot()
 if G.state~='shop' and G.state~='playing' and G.state~='pause' then return nil end
 if not G.player or not G.ball then return nil end
 return {
  state=G.state,round=G.round,score=G.score,coins=G.coins,
  time=G.time,roundLeft=G.roundLeft,roundDuration=G.roundDuration,
  spawn=G.spawn,roundHits=G.roundHits,wallBounces=G.wallBounces,placed=G.placed,boots=G.boots,pulseCooldown=G.pulseCooldown,reward=G.reward,
  previousRound=G.previousRound,previousHits=G.previousHits,
  player=copyNumbers(G.player),ball=copyNumbers(G.ball),
  inventory={G.inventory[1],G.inventory[2],G.inventory[3],G.inventory[4],G.inventory[5],G.inventory[6]},hazards=copyArray(H.list),objects=copyArray(O.list)
 }
end
function G.saveRun()
 if not G.slot then return false end
 local snapshot=G.snapshot()
 return snapshot~=nil and Save.storeRun(snapshot,G.slot)
end
function G.newRun(slot)
 if not slot or slot<1 or slot>3 then return false end
 G.slot=slot
 G.state='shop'
 G.score=0
 G.coins=40
 G.round=1
 G.time=0
 G.roundDuration=G.duration()
 G.roundLeft=G.roundDuration
 G.roundHits=0
 G.wallBounces=0
 G.placed=0
 G.boots=0
 G.pulseCooldown=0
 G.pulseVisual=0
 G.autosaveClock=0
 G.reward=0
 G.winFlash=0
 G.previousRound=0
 G.previousHits=0
 G.spawn=4.5
 G.shake=0
 G.player=Player.new()
 G.ball=Ball.new()
 G.inventory={1,0,1,0,0,0}
 H.clear()
 O.clear()
 FX.clear()
 Feedback.reset()
 G.notify('Elige tus defensas y empieza la ronda')
 G.saveRun()
 Sound.play('button')
 return true
end
function G.loadRun(slot)
 local s=Save.loadRun(slot)
 if not s then return false end
 G.slot=slot
 G.round=s.round
 G.score=s.score
 G.coins=s.coins
 G.time=s.time
 G.roundLeft=s.roundLeft
 G.roundDuration=s.roundDuration
 G.spawn=s.spawn
 G.roundHits=s.roundHits
 G.wallBounces=s.wallBounces or 0
 G.placed=s.placed or 0
 G.boots=s.boots or 0
 G.pulseCooldown=s.pulseCooldown or 0
 G.pulseVisual=0
 G.autosaveClock=0
 G.reward=s.reward
 G.winFlash=0
 G.previousRound=s.previousRound
 G.previousHits=s.previousHits
 G.inventory=s.inventory
 G.player=s.player
 G.player.speed=265+G.boots*20
 G.ball=s.ball
 G.ball.trail={}
 H.list=s.hazards
 O.list=s.objects
 O.selected=1
 G.state=s.state=='shop' and 'shop' or 'pause'
 G.shake=0
 FX.clear()
 Feedback.reset()
 G.notify(G.state=='shop' and 'Partida cargada' or 'Partida recuperada. Pulsa continuar.')
 return true
end
function G.startRound()
 if G.state~='shop' then return false end
 G.state='playing'
 G.roundDuration=G.duration()
 G.roundLeft=G.roundDuration
 G.roundHits=0
 G.wallBounces=0
 G.placed=0
 G.pulseCooldown=0
 G.pulseVisual=0
 G.autosaveClock=0
 G.spawn=math.max(1.75,5.2-G.round*.25)
 G.player=Player.new()
 G.player.speed=265+G.boots*20
 G.ball=Ball.new()
 local increase=1+math.min(.28,(G.round-1)*.045)
 G.ball.vx=G.ball.vx*increase
 G.ball.vy=G.ball.vy*increase
 H.clear()
 O.clear()
 FX.clear()
 Feedback.resetCombo()
 G.notify('¡Ronda '..G.round..'! Cuida la pelota')
 G.saveRun()
 Sound.play('button')
 return true
end
function G.endRound()
 if G.state~='playing' then return end
 local played=G.round
 local hits=G.roundHits
 local base=18+6*played
 local skill=math.min(15,hits)*2
 local goal=G.progress()>=G.goal() and G.bonus() or 0
 G.reward=base+skill+goal
 G.coins=math.min(99999,G.coins+G.reward)
 G.score=G.score+played*30+goal*5
 G.previousRound=played
 G.previousHits=hits
 G.round=math.min(999,played+1)
 G.roundDuration=G.duration()
 G.roundLeft=G.roundDuration
 G.spawn=math.max(1.75,5.2-G.round*.25)
 G.state='shop'
 G.winFlash=1.8
 G.pulseVisual=0
 G.notify('¡Ronda '..played..' superada! +'..G.reward..' monedas')
 H.clear()
 O.clear()
 Feedback.resetCombo()
 FX.burst(G.ball.x,G.ball.y,C.gold,30)
 Sound.play('round')
 G.saveRun()
end
function G.finish(reason)
 if G.state~='playing' then return end
 G.state='over'
 G.reason=reason
 G.shake=8
 FX.burst(G.ball.x,G.ball.y,C.red,28)
 Feedback.resetCombo()
 Save.record(G.score)
 if G.slot then Save.clearRun(G.slot) end
 Sound.play('lose')
end
function G.buy(index)
 if G.state~='shop' then return false end
 local info=O.types[index]
 if not info then return false end
 if G.coins<info.cost then G.notify('Te faltan '..(info.cost-G.coins)..' monedas') Sound.play('warn') return false end
 local total=0
 for _,v in ipairs(G.inventory) do total=total+v end
 if G.inventory[index]>=5 then G.notify('Máximo: 5 unidades de este objeto') return false end
 if total>=12 then G.notify('Mochila llena: máximo 12 objetos') return false end
 G.coins=G.coins-info.cost
 G.inventory[index]=G.inventory[index]+1
 Sound.play('coin',1.05)
 G.notify(info.name..' añadido a la mochila')
 G.saveRun()
 return true
end
function G.place(x,y)
 if G.state~='playing' then return false end
 local kind=O.selected
 if G.inventory[kind]<1 then G.notify('No te quedan '..O.types[kind].name..'. Compra en la tienda.') return false end
 local ok,value=O.place(x,y,G.player,G.ball,H.list)
 if ok then
  G.inventory[kind]=G.inventory[kind]-1
  G.placed=G.placed+1
  if G.goalKind()=='places' and G.placed==G.goal() then G.notify('¡Objetivo de la ronda cumplido!') end
  FX.burst(x,y,C.mint,11)
  Feedback.pop(x,y-28,'¡COLOCADO!',C.mintDark)
  Sound.play('place')
  return true
 end
 G.notify(value)
 return false
end
function G.pulse()
 if G.state~='playing' then return false end
 if G.pulseCooldown>0 then return false end
 local dx,dy=G.ball.x-G.player.x,G.ball.y-G.player.y
 local dist=U.length(dx,dy)
 if dist>175 then
  G.notify('Acércate a la pelota para usar el pulso')
  Sound.play('warn')
  return false
 end
 local nx,ny=U.normal(dx,dy)
 G.ball.vx,G.ball.vy=nx*460,ny*460
 G.ball.cooldown=.22
 G.pulseCooldown=10
 G.pulseVisual=.42
 G.pulseX,G.pulseY=G.player.x,G.player.y
 G.shake=3
 G.player.hit=.16
 FX.burst(G.ball.x,G.ball.y,C.blue,18)
 Feedback.pop(G.ball.x,G.ball.y-22,'¡RESCATE!',C.blue)
 Sound.play('pulse')
 return true
end
function G.update(dt)
 G.t=G.t+dt
 G.winFlash=math.max(0,(G.winFlash or 0)-dt)
 G.noticeT=math.max(0,G.noticeT-dt)
 G.shake=math.max(0,G.shake-25*dt)
 FX.update(dt)
 Feedback.update(dt)
 if G.state~='playing' then return end
 G.pulseCooldown=math.max(0,G.pulseCooldown-dt)
 G.pulseVisual=math.max(0,G.pulseVisual-dt)
 G.autosaveClock=G.autosaveClock+dt
 if G.autosaveClock>=8 then
  G.autosaveClock=0
  G.saveRun()
 end
 G.time=G.time+dt
 G.roundLeft=math.max(0,G.roundLeft-dt)
 G.score=G.score+dt*2
 G.spawn=G.spawn-dt
 local maxHazards=math.min(7,2+math.floor(G.round/2))
 if G.spawn<=0 then
  if #H.list<maxHazards and H.spawn(G.player,G.ball,G.round) then Sound.play('warn') end
  G.spawn=math.max(1.8,5.15-G.round*.27)
 end
 Player.update(G.player,dt)
 Ball.update(G.ball,dt,function(x,y)
  G.wallBounces=G.wallBounces+1
  if G.goalKind()=='walls' and G.wallBounces==G.goal() then G.notify('¡Objetivo de la ronda cumplido!') end
  FX.burst(x,y,C.paper,3)
 end)
 local scoreBefore=G.score
 if Ball.hitPlayer(G.ball,G.player) then
  G.roundHits=G.roundHits+1
  if G.goalKind()=='hits' and G.roundHits==G.goal() then G.notify('¡Objetivo de la ronda cumplido!') end
  local nextCombo=Feedback.comboTimer>0 and Feedback.combo+1 or 1
  local multiplier=math.min(3,1+math.floor((nextCombo-1)/3))
  local gain=10*multiplier
  G.score=G.score+gain
  G.shake=math.min(3,1+nextCombo*.25)
  FX.burst(G.ball.x,G.ball.y,C.gold,7+multiplier*3)
  Feedback.hit(G.ball.x,G.ball.y,gain)
  Sound.play('hit',1+math.min(.3,Feedback.combo*.035))
 end
 if O.collide(G.ball) then
  G.score=G.score+5
  FX.burst(G.ball.x,G.ball.y,C.mint,7)
  Feedback.pop(G.ball.x,G.ball.y-24,'+5',C.mintDark)
  Sound.play('hit',1.1)
 end
 if math.floor(G.score/150)>math.floor(scoreBefore/150) then
  Feedback.milestoneReached(math.floor(G.score/150)*150)
  FX.burst(G.ball.x,G.ball.y,C.gold,16)
  Sound.play('coin',1.12)
 end
 O.update(dt,G.ball)
 local fatal=H.update(dt,G.ball,O.list)
 if fatal then
  local reasons={pinchos='¡La pelota tocó los pinchos!',alcantarilla='¡La pelota cayó a la alcantarilla!',sierra='¡La sierra alcanzó la pelota!',descarga='¡La descarga eléctrica alcanzó la pelota!'}
  G.finish(reasons[fatal] or 'Se acabó la partida')
 elseif G.roundLeft<=0 then
  G.endRound()
 end
end
function G.togglePause()
 if G.state=='playing' then G.state='pause' G.saveRun()
 elseif G.state=='pause' then G.state='playing' G.autosaveClock=0 end
end
function G.backToMenu()
 if G.state=='playing' or G.state=='pause' or G.state=='shop' then G.saveRun() end
 G.state='menu'
end
return G
