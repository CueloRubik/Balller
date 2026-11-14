local M={}
function M.install()
 local oldLoad,oldUpdate,oldQuit=love.load,love.update,love.quit
 local G=require('src.game')
 local P=require('src.progression')
 local Save=require('src.save')
 local Results=require('src.presentation.round_results')
 local Prefs=require('src.presentation.preferences')
 local RunFlow=require('src.presentation.run_flow')
 local Exit=require('src.presentation.exit_flow')
 local Rewards=require('src.reward_transaction')
 local savedWrite,savedKeyboard,practiceRuns,practiceProfile,practiceGems=nil,nil,nil,nil,nil
 local backupBytes=nil
 local frame,paid=0,nil
 local function click(x,y) love.mousepressed(x,y,1) end
 love.load=function()
  love.filesystem.setIdentity('balller_ci_flow_v8',true)
  for slot=1,3 do Save.clearRun(slot) end
  for _,file in ipairs({'perfil_balller_v7.txt','perfil_balller_v7.txt.bak','save.txt',Prefs.file}) do love.filesystem.remove(file) end
  assert(Rewards.recover())
  oldLoad()
  P.gems=12 P.owned={true,false,false,false} P.skin=1
  assert(P.save())
  assert(G.newRun(1,2))
  G.backToMenu()
 end
 love.update=function(dt)
  if frame>=210 and frame<=236 then oldUpdate(.04) else oldUpdate(dt) end
  frame=frame+1
  if frame==5 then click(308,620)
  elseif frame==10 then assert(G.state=='store') click(400,459)
  elseif frame==15 then assert(P.gems==12 and not P.owned[2]) click(370,478)
  elseif frame==20 then assert(P.gems==12) click(400,459)
  elseif frame==25 then click(600,478)
  elseif frame==30 then
   assert(P.gems==8 and P.skin==2 and P.owned[2])
   P.gems=0 assert(P.load() and P.gems==8 and P.skin==2)
   click(500,620)
  elseif frame==35 then assert(G.state=='collection') click(155,459)
  elseif frame==40 then assert(P.skin==1 and P.gems==8) click(116,620)
  elseif frame==45 then assert(G.state=='menu') click(782,394)
  elseif frame==50 then assert(G.state=='slots')
  elseif frame==55 then click(669,204)
  elseif frame==60 then assert(G.state=='shop') click(700,620)
  elseif frame==65 then
   assert(G.state=='playing') G.spawn=10000 G.roundLeft=.001
  elseif frame==70 then
   assert(G.state=='shop' and Results.visible)
   paid=G.coins
   assert(Save.loadRun(1).coins==paid)
   click(616,523)
  elseif frame==75 then
   assert(G.state=='shop' and not Results.visible and G.coins==paid)
   click(200,620)
  elseif frame==80 then
   assert(G.state=='menu' and Save.hasRun(1))
   assert(P.load() and P.gems==8 and P.skin==1)
   click(884,620)
  elseif frame==85 then assert(G.state=='settings') click(500,458)
  elseif frame==90 then
   assert(Prefs.arena=='taller')
   Prefs.arena='patio' assert(Prefs.load() and Prefs.arena=='taller')
   click(270,539)
  elseif frame==95 then
   assert(Prefs.reduced)
   Prefs.reduced=false assert(Prefs.load() and Prefs.reduced)
   click(116,620)
  elseif frame==100 then click(782,394)
  elseif frame==105 then assert(G.state=='slots') click(669,204)
  elseif frame==110 then assert(G.state=='shop') click(700,620)
  elseif frame==115 then
   assert(G.state=='playing' and Prefs.arena=='taller' and Prefs.reduced)
   assert(math.abs(math.sqrt(G.ball.vx^2+G.ball.vy^2)-G.ballSpeed())<.001)
   G.togglePause() G.backToMenu()
   backupBytes=assert(love.filesystem.read('partida_1.txt.bak'))
   assert(love.filesystem.write('partida_1.txt','CORRUPTO-C1-NATIVE'))
  elseif frame==120 then click(782,394)
  elseif frame==125 then
   assert(G.state=='slots' and love.filesystem.read('partida_1.txt')=='CORRUPTO-C1-NATIVE')
   click(669,204)
  elseif frame==130 then
   assert(RunFlow.recovery and G.state=='pause')
   assert(love.filesystem.read(RunFlow.recovery.archive)=='CORRUPTO-C1-NATIVE')
   assert(love.filesystem.read('partida_1.txt.bak')==backupBytes)
   click(500,467)
  elseif frame==135 then assert(not RunFlow.recovery and G.state=='pause') click(500,360)
  elseif frame==140 then
   assert(G.state=='playing' and P.gems==8 and G.coins==paid)
   G.togglePause()
   savedWrite=love.filesystem.write
   love.filesystem.write=function(path,data) if path=='partida_1.txt' then return false end return savedWrite(path,data) end
   assert(oldQuit()==true and Exit.visible)
  elseif frame==145 then assert(Exit.visible and G.state=='pause') click(375,466)
  elseif frame==150 then
   love.filesystem.write=savedWrite
   click(385,438)
  elseif frame==155 then assert(not G.saveError and G.state=='pause') click(615,438)
  elseif frame==160 then assert(G.state=='menu') click(782,394)
  elseif frame==165 then assert(G.state=='slots') click(669,204)
  elseif frame==170 then assert(G.state=='pause') click(500,360)
  elseif frame==175 then assert(G.state=='playing') G.spawn=10000 G.roundLeft=.001
  elseif frame==180 then assert(Results.visible) click(616,523)
  elseif frame==185 then assert(G.state=='shop') click(248,254)
  elseif frame==190 then
   love.keypressed('return') assert(G.state=='shop')
   click(350,539)
  elseif frame==195 then click(190,620)
  elseif frame==200 then
   assert(G.state=='menu')
   practiceRuns={}
   for slot=1,3 do practiceRuns[slot]=love.filesystem.read('partida_'..slot..'.txt') end
   practiceProfile=love.filesystem.read('perfil_balller_v7.txt') practiceGems=P.gems
  elseif frame==205 then click(800,478)
  elseif frame==210 then
   assert(G.tutorial and G.tutorialStep==1)
   savedKeyboard=love.keyboard.isDown
   love.keyboard.isDown=function(...) for _,key in ipairs({...}) do if key=='d' then return true end end return false end
  elseif frame==237 then
   love.keyboard.isDown=savedKeyboard
   assert(G.tutorialStep==2 and G.player.x>300)
   G.ball.x,G.ball.y=G.player.x+20,G.player.y G.ball.cooldown=0
  elseif frame==240 then assert(G.tutorialStep==3) love.keypressed('space')
  elseif frame==245 then
   assert(G.tutorialStep==4)
   G.ball.x,G.ball.y=770,360 G.player.x,G.player.y=220,270
   love.keypressed('1') click(460,320)
  elseif frame==250 then
   assert(G.state=='tutorialDone' and Save.tutorialDone and P.gems==practiceGems)
   for slot=1,3 do assert(love.filesystem.read('partida_'..slot..'.txt')==practiceRuns[slot]) end
   assert(love.filesystem.read('perfil_balller_v7.txt')==practiceProfile)
  elseif frame==255 then click(380,503)
  elseif frame==260 then assert(G.tutorial and G.tutorialStep==1) love.keypressed('escape')
  elseif frame==264 then assert(G.state=='pause') click(615,438)
  elseif frame==268 then
   assert(G.state=='menu' and P.gems==practiceGems)
   for slot=1,3 do assert(love.filesystem.read('partida_'..slot..'.txt')==practiceRuns[slot]) end
   assert(love.filesystem.read('perfil_balller_v7.txt')==practiceProfile)
   click(782,394)
  elseif frame==273 then assert(G.state=='slots') click(669,204)
  elseif frame==278 then
   assert(G.state=='shop')
   savedWrite=love.filesystem.remove
   love.filesystem.remove=function(path) if path=='partida_1.txt.purchase' then return false end return savedWrite(path) end
   paid=G.coins
   practiceRuns=G.inventory[1]
   click(173,304)
  elseif frame==283 then
   assert(G.coins==paid and G.inventory[1]==practiceRuns and Save.inspectRun(1).pendingPurchase)
   love.filesystem.remove=savedWrite
   G.state='menu'
   love.draw()
   click(782,394)
  elseif frame==288 then assert(G.state=='slots') click(669,204)
  elseif frame==293 then
   assert(RunFlow.recovery and RunFlow.recovery.kind=='purchase')
   assert(G.coins==paid and G.inventory[1]==practiceRuns)
   click(500,467)
  elseif frame==298 then click(173,304)
  elseif frame==303 then
   assert(G.coins==paid-22 and G.inventory[1]==practiceRuns+1)
   assert(not love.filesystem.getInfo('partida_1.txt.purchase'))
   assert(G.loadRun(1) and G.coins==paid-22 and G.inventory[1]==practiceRuns+1)
   P.gems=0 P.rounds=9 P.best={0,0,0,0} assert(P.save())
   G.round=3 assert(G.startRound()) G.roundHits=4 G.placed=1
   savedWrite=love.filesystem.write
   love.filesystem.write=function(path,data) if path=='perfil_balller_v7.txt' then return false end return savedWrite(path,data) end
   G.endRound()
  elseif frame==308 then
   assert(G.pendingReward and G.state=='shop' and P.gems==4)
   paid=G.coins
   assert(not G.buy(1) and not G.startRound() and oldQuit()==true and Exit.visible)
   Exit.cancel()
  elseif frame==313 then
   love.filesystem.write=savedWrite
   love.draw() click(600,455)
  elseif frame==318 then
   assert(not G.rewardsPending() and G.coins==paid and P.gems==4 and P.rounds==10)
   assert(G.loadRun(1) and G.gemsReward==4 and G.rewardDetails.objective==24)
   assert(Results.show(G) and Results.data.gems==4)
   print('NATIVE D2 FLOW OK: C2/D1 circuit, interrupted reward recovery, no duplicate payment and persisted breakdown')
   love.event.quit(0)
  end
 end
 love.focus=function() end
 love.quit=function() end
end
return M
