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
local Difficulty=require('src.difficulty')
local Progress=require('src.progression')
local Collectibles=require('src.collectibles')
local Rounds=require('src.rounds')
local Economy=require('src.economy.rules')
local Costs=Economy.config
local G={state='menu',winFlash=0,slot=nil,score=0,coins=0,time=0,spawn=0,t=0,notice='',noticeT=0,reason='',shake=0,round=1,roundLeft=0,roundDuration=0,roundHits=0,wallBounces=0,placed=0,boots=0,pulseCooldown=0,pulseVisual=0,autosaveClock=0,difficulty=2,rescues=0,rescueInvuln=0,tutorial=false,tutorialStep=0,tutorialWalk=0,roundStars=0,gemsReward=0,reward=0,previousRound=0,previousHits=0,inventory={0,0,0,0,0,0}}
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
function G.bonus() return Economy.goalBonus(G.round,G.goalKind()) end
function G.upgradeCost() return Economy.upgradeCost(G.boots) end
local function commitPurchase(before,after)
 if not Save.storePurchase(before,after,G.slot) then
  G.saveError='Compra no aplicada. El saldo y la mochila no han cambiado.'
  G.notify(G.saveError) Sound.play('warn')
  return false
 end
 G.coins=after.coins G.inventory=after.inventory G.boots=after.boots
 local profileOK=not Progress.dirty or Progress.save()
 local settingsOK=Save.store()
 if not profileOK then G.saveError='Compra guardada; falta guardar el progreso.'
 elseif not settingsOK then G.saveError='Compra guardada; faltan ajustes y récords.'
 else G.saveError=nil G.saveNoticeT=2 end
 return true
end
function G.buyUpgrade()
 if G.state~='shop' then return false end
 local cost=G.upgradeCost()
 if not cost then G.notify('Mejora al máximo nivel') return false end
 if G.coins<cost then G.notify('Te faltan '..(cost-G.coins)..' monedas') Sound.play('warn') return false end
 local before,after=G.snapshot(),G.snapshot()
 after.coins=after.coins-cost after.boots=after.boots+1
 if not commitPurchase(before,after) then return false end
 G.notify('¡Zapatillas nivel '..G.boots..'! +'..Costs.upgrades.speedStep..' de velocidad')
 Sound.play('upgrade')
 return true
end

function G.ballSpeed()
 return math.min(365,math.floor((215+math.min(G.round-1,24)*6)*Difficulty.get(G.difficulty).ball+.5))
end
function G.roundMode() return Rounds.get(G.round) end
function G.duration()
 return math.min(65,math.floor((28+(G.round-1)*2)*Difficulty.get(G.difficulty).roundTime+.5))
end
function G.snapshot()
 if G.state~='shop' and G.state~='playing' and G.state~='pause' then return nil end
 if not G.player or not G.ball then return nil end
 return {
  state=G.state,round=G.round,score=G.score,coins=G.coins,
  time=G.time,roundLeft=G.roundLeft,roundDuration=G.roundDuration,
  spawn=G.spawn,roundHits=G.roundHits,wallBounces=G.wallBounces,placed=G.placed,boots=G.boots,pulseCooldown=G.pulseCooldown,difficulty=G.difficulty,rescues=G.rescues,rescueInvuln=G.rescueInvuln,reward=G.reward,
  previousRound=G.previousRound,previousHits=G.previousHits,
  player=copyNumbers(G.player),ball=copyNumbers(G.ball),
  inventory={G.inventory[1],G.inventory[2],G.inventory[3],G.inventory[4],G.inventory[5],G.inventory[6],G.inventory[7],G.inventory[8]},hazards=copyArray(H.list),objects=copyArray(O.list)
 }
end
function G.saveRun()
 if not G.slot or G.tutorial then return false end
 local snapshot=G.snapshot()
 local ok=snapshot~=nil and Save.storeRun(snapshot,G.slot)
 if ok then
  G.saveError=nil G.saveNoticeT=2
 else
  G.saveError='No se pudo guardar la partida. Reintenta antes de salir.'
 end
 return ok
end
function G.saveSession()
 local active=G.state=='shop' or G.state=='playing' or G.state=='pause'
 local ok=true
 if active and not G.tutorial then ok=G.saveRun() end
 if Progress.dirty and not Progress.save() then
  G.saveError='No se pudo guardar el progreso. Reintenta antes de salir.'
  ok=false
 end
 if not Save.store() then
  G.saveError='No se pudieron guardar los ajustes y récords.'
  ok=false
 end
 if ok then G.saveError=nil G.saveNoticeT=2 end
 return ok
end
function G.saveTutorial()
 if Save.store() then
  G.tutorialSaveFailed=false G.saveError=nil
  return true
 end
 G.tutorialSaveFailed=true
 G.saveError='No se pudo guardar que completaste la práctica.'
 return false
end

function G.newRun(slot,difficulty)
 if type(slot)~='number' or slot%1~=0 or slot<1 or slot>3 then return false end
 G.difficulty=Difficulty.get(difficulty).id
 G.tutorial=false
 G.saveError=nil G.saveNoticeT=0
 G.tutorialStep=0
 G.slot=slot
 G.state='shop'
 G.score=0
 G.coins=Costs.initialCoins
 G.rescues=Difficulty.get(G.difficulty).graces
 G.rescueInvuln=0
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
 G.gemsReward=0
 G.roundStars=0
 G.winFlash=0
 G.previousRound=0
 G.previousHits=0
 G.spawn=4.5
 G.shake=0
 G.player=Player.new()
 G.ball=Ball.new()
 Ball.enforceSpeed(G.ball,G.ballSpeed())
 Collectibles.clear()
 G.inventory={}
 for i,n in ipairs(Costs.starter) do G.inventory[i]=n end
 H.clear()
 O.clear()
 FX.clear()
 Feedback.reset()
 if not G.saveRun() then
  G.state='menu' G.slot=nil
  G.notify('No se pudo crear la partida. Inténtalo de nuevo.')
  return false
 end
 Progress.track('plays')
 Progress.save()
 G.notify('Elige tus defensas y empieza la ronda')
 Sound.play('button')
 return true
end
function G.loadRun(slot)
 local s,status,detail=Save.loadRun(slot)
 if not s then return false,status end
 G.slot=slot
 G.saveError=nil G.saveNoticeT=0
 G.tutorial=false
 G.difficulty=Difficulty.get(s.difficulty).id
 G.rescues=s.rescues or 0
 G.rescueInvuln=s.rescueInvuln or 0
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
 G.gemsReward=0
 G.winFlash=0
 G.previousRound=s.previousRound
 G.previousHits=s.previousHits
 G.inventory=s.inventory
 for i=1,#O.types do G.inventory[i]=G.inventory[i] or 0 end
 G.player=s.player
 G.player.speed=265+G.boots*Costs.upgrades.speedStep
 G.ball=s.ball
 Ball.enforceSpeed(G.ball,G.ballSpeed())
 Collectibles.clear()
 Collectibles.configure(G.roundMode().stars,G.roundMode().interval)
 G.ball.guard=G.ball.guard or 0
 G.ball.portalCooldown=G.ball.portalCooldown or 0
 G.ball.trail={}
 H.list=s.hazards
 O.list=s.objects
 O.selected=1
 G.state=s.state=='shop' and 'shop' or 'pause'
 G.shake=0
 FX.clear()
 Feedback.reset()
 G.notify(G.state=='shop' and 'Partida cargada' or 'Partida cargada. Pulsa continuar.')
 return true,status,detail
end
function G.startRound()
 if G.state~='shop' then return false end
 G.state='playing'
 G.rescues=Difficulty.get(G.difficulty).graces+G.roundMode().rescue
 G.rescueInvuln=0
 G.roundDuration=G.duration()
 G.roundLeft=G.roundDuration
 G.roundHits=0
 G.wallBounces=0
 G.placed=0
 G.pulseCooldown=0
 G.pulseVisual=0
 G.autosaveClock=0
 G.spawn=math.max(1.45,5.2-G.round*.25)*Difficulty.get(G.difficulty).spawn*G.roundMode().spawn
 G.player=Player.new()
 G.player.speed=265+G.boots*Costs.upgrades.speedStep
 G.ball=Ball.new()
 Ball.enforceSpeed(G.ball,G.ballSpeed())
 G.roundStars=0
 Collectibles.clear()
 Collectibles.configure(G.roundMode().stars,G.roundMode().interval)
 H.clear()
 O.clear()
 FX.clear()
 Feedback.resetCombo()
 G.notify('¡Ronda '..G.round..'! Cuida la pelota')
 if not G.saveSession() then G.state='pause' return false end
 Sound.play('button')
 return true
end
function G.endRound()
 if G.state~='playing' then return end
 local played=G.round
 local hits=G.roundHits
 local goal=G.progress()>=G.goal() and G.bonus() or 0
 G.reward=Economy.roundReward(played,hits,goal,Difficulty.get(G.difficulty).bonus*G.roundMode().reward,G.coins).credited
 local previousGems,previousCoins=Progress.gems,G.coins
 Progress.awardRound(played,G.difficulty)
 G.gemsReward=Progress.gems-previousGems
 G.coins=G.coins+G.reward
 G.reward=G.coins-previousCoins
 G.score=G.score+played*Costs.rewards.roundScore+goal*Costs.rewards.goalScore
 G.previousRound=played
 G.previousHits=hits
 G.round=math.min(999,played+1)
 G.roundDuration=G.duration()
 G.roundLeft=G.roundDuration
 G.spawn=math.max(1.45,5.2-G.round*.25)*Difficulty.get(G.difficulty).spawn*G.roundMode().spawn
 G.state='shop'
 G.winFlash=1.8
 G.pulseVisual=0
 G.notify('¡Ronda '..played..' superada! +'..G.reward..' monedas'..(G.gemsReward>0 and ' y +'..G.gemsReward..' gemas' or ''))
 H.clear()
 O.clear()
 Feedback.resetCombo()
 FX.burst(G.ball.x,G.ball.y,C.gold,30)
 Sound.play('round')
 G.saveSession()
end
function G.finish(reason)
 if G.state~='playing' then return end
 G.state='over'
 G.reason=reason
 G.shake=8
 FX.burst(G.ball.x,G.ball.y,C.red,28)
 Feedback.resetCombo()
 Save.record(G.score)
 if G.slot and not G.tutorial then Save.clearRun(G.slot) end
 Sound.play('lose')
end
function G.buy(index)
 if G.state~='shop' then return false end
 local ok,reason,cost=Economy.canBuy(G,index)
 if not ok then G.notify(reason) Sound.play('warn') return false end
 local before,after=G.snapshot(),G.snapshot()
 after.coins=after.coins-cost after.inventory[index]=after.inventory[index]+1
 if not commitPurchase(before,after) then return false end
 Sound.play('coin',1.05)
 G.notify(O.types[index].name..' añadido a la mochila')
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
  if G.tutorial and G.tutorialStep==4 then G.tutorialNext() end
  if G.goalKind()=='places' and G.placed==G.goal() then G.notify('¡Objetivo de la ronda cumplido!') end
  FX.burst(x,y,C.mint,11)
  Feedback.pop(x,y-28,'¡COLOCADO!',C.mintDark)
  Sound.play('place')
  return true
 end
 G.notify(value)
 return false
end
function G.startTutorial()
 G.slot=nil
 G.difficulty=1
 G.tutorial=true
 G.saveError=nil G.saveNoticeT=0 G.tutorialSaveFailed=false
 Collectibles.clear()
 G.tutorialStep=1
 G.tutorialWalk=0
 G.state='playing'
 G.round=1
 G.score=0
 G.coins=0
 G.roundHits=0
 G.wallBounces=0
 G.placed=0
 G.time=0
 G.roundLeft=180
 G.roundDuration=180
 G.pulseCooldown=0
 G.pulseVisual=0
 G.rescueInvuln=0
 G.autosaveClock=0
 G.spawn=900
 G.player=Player.new()
 G.ball=Ball.new()
 Ball.enforceSpeed(G.ball,G.ballSpeed())
 Collectibles.clear()
 G.ball.vx,G.ball.vy=65,45
 Ball.enforceSpeed(G.ball,105)
 G.inventory={1,0,1,0,0,0,0,0}
 H.clear() O.clear() FX.clear() Feedback.reset()
 G.notify('Mueve a tu personaje con WASD o las flechas')
 return true
end
function G.tutorialNext()
 G.tutorialStep=G.tutorialStep+1
 if G.tutorialStep>=5 then
  G.state='tutorialDone'
  Save.tutorialDone=true G.saveTutorial()
  Sound.play('round')
 else
  local notes={[2]='Toca la pelota',[3]='Acércate y usa ESPACIO',[4]='Pulsa 1 y haz clic en la cancha'}
  G.notify(notes[G.tutorialStep] or '')
 end
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
 Ball.enforceSpeed(G.ball,G.tutorial and 105 or G.ballSpeed())
 G.ball.cooldown=.22
 G.pulseCooldown=10
 if G.tutorial and G.tutorialStep==3 then G.tutorialNext() end
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
 G.saveNoticeT=math.max(0,(G.saveNoticeT or 0)-dt)
 G.t=G.t+dt
 G.winFlash=math.max(0,(G.winFlash or 0)-dt)
 G.noticeT=math.max(0,G.noticeT-dt)
 G.shake=math.max(0,G.shake-25*dt)
 FX.update(dt)
 Feedback.update(dt)
 if G.state~='playing' then return end
 if G.tutorial then
  G.pulseCooldown=math.max(0,G.pulseCooldown-dt)
  G.pulseVisual=math.max(0,G.pulseVisual-dt)
  if G.tutorialStep==1 then
   if love.keyboard.isDown('w','a','s','d','up','down','left','right') then G.tutorialWalk=G.tutorialWalk+dt end
   if G.tutorialWalk>=1 then G.tutorialNext() end
  end
  Player.update(G.player,dt)
  Ball.update(G.ball,dt)
  if Ball.hitPlayer(G.ball,G.player) then
   G.score=G.score+10
   if G.tutorialStep==2 then G.tutorialNext() end
   FX.burst(G.ball.x,G.ball.y,C.gold,7)
  end
  O.collide(G.ball) O.update(dt,G.ball)
  Ball.enforceSpeed(G.ball,105)
  return
 end
 G.pulseCooldown=math.max(0,G.pulseCooldown-dt)
 G.pulseVisual=math.max(0,G.pulseVisual-dt)
 G.rescueInvuln=math.max(0,(G.rescueInvuln or 0)-dt)
 G.autosaveClock=G.autosaveClock+dt
 if G.autosaveClock>=8 then
  G.autosaveClock=0
  if not G.saveSession() then G.state='pause' return end
 end
 G.time=G.time+dt
 G.roundLeft=math.max(0,G.roundLeft-dt)
 G.score=G.score+dt*2
 G.spawn=G.spawn-dt
 local mode=Difficulty.get(G.difficulty)
 local maxHazards=math.min(mode.maxHazards,2+math.floor(G.round/2))
 if G.spawn<=0 then
  if #H.list<maxHazards and H.spawn(G.player,G.ball,G.round,mode) then Sound.play('warn') end
  G.spawn=math.max(1.6,5.15-G.round*.27)*mode.spawn*G.roundMode().spawn
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
  Progress.track('hits')
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
 local hazardDt=dt
 for _,o in ipairs(O.list) do
  if o.kind==6 then hazardDt=dt*.72 break end
 end
 local fatal=H.update(hazardDt,G.ball,O.list)
 Collectibles.update(dt,G.ball,H.list,function(x,y)
  G.roundStars=G.roundStars+1
  G.score=G.score+25
  Progress.track('stars')
  FX.burst(x,y,C.gold,12)
  Feedback.pop(x,y-24,'+25',C.gold)
  Sound.play('coin')
 end)
 Ball.enforceSpeed(G.ball,G.ballSpeed())
 if fatal then
  if G.rescueInvuln>0 then return end
  if (G.ball.guard or 0)>0 or G.rescues>0 then
   if (G.ball.guard or 0)>0 then G.ball.guard=0 else G.rescues=G.rescues-1 end
   G.ball.x,G.ball.y=630,313
   G.ball.vx,G.ball.vy=180,-150
   Ball.enforceSpeed(G.ball,G.ballSpeed())
   G.ball.cooldown=.4
   G.ball.portalCooldown=1
   G.rescueInvuln=1.5
   G.shake=3
   FX.burst(630,313,C.blue,18)
   G.notify('¡Salvada! Protecciones: '..G.rescues)
   Sound.play('pulse')
   return
  end
  local reasons={pinchos='¡La pelota tocó los pinchos!',alcantarilla='¡La pelota cayó a la alcantarilla!',sierra='¡La sierra alcanzó la pelota!',descarga='¡La descarga eléctrica alcanzó la pelota!',martillo='¡El martillo golpeó la pelota!',laser='¡El láser alcanzó la pelota!'}
  G.finish(reasons[fatal] or 'Se acabó la partida')
 elseif G.roundLeft<=0 then
  G.endRound()
 end
end
function G.togglePause()
 if G.state=='playing' then
  G.state='pause'
  if not G.tutorial then return G.saveSession() end
  return true
 elseif G.state=='pause' then
  G.state='playing' G.autosaveClock=0
  return true
 end
 return false
end
function G.backToMenu()
 if G.tutorialSaveFailed and not G.saveTutorial() then return false end
 if not G.saveSession() then
  if G.state=='playing' then G.state='pause' end
  return false
 end
 G.tutorial=false
 G.state='menu'
 return true
end
return G
