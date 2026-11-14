local M={}
function M.install()
 local originalLoad,originalDraw=love.load,love.draw
 local G=require('src.game')
 local Save=require('src.save')
 local P=require('src.progression')
 local Prefs=require('src.presentation.preferences')
 local Assets=require('src.presentation.assets')
 local RunFlow=require('src.presentation.run_flow')
 local sizes={{1000,680},{800,600},{1280,720},{1366,768},{1920,1080}}
 local states={'menu','difficulty','slots','shop','collection','achievements','settings','playing','pause','over','store','purchase','milestones','results','store_empty','collection_owned','arena_taller','arena_ciudad','playing_notice','playing_tutorial','playing_reduced','playing_fallback','playing_extreme','playing_edge','slots_new','slots_full','slots_backup','slots_damaged','slots_delete','slots_delete_error','slots_recovered','components'}
 local sizeIndex,stateIndex,frames,pending=1,1,0,false
 local function setup()
  local width,height=unpack(sizes[sizeIndex])
  assert(love.window.setMode(width,height,{resizable=true,vsync=0,msaa=0}))
  love.resize(width,height)
  love.keypressed('escape')
  for slot=1,3 do Save.clearRun(slot) end
  assert(G.newRun(1,2))
  P.gems=12 P.plays=0 P.rounds=0 P.best={0,0,0,0} P.owned={true,false,false,false} P.skin=1
  G.coins=160
  G.round=3
  G.previousRound=2 G.reward=30
  G.startRound()
  G.t=1.2
  G.score=230
  G.roundLeft=24
  G.coins=160
  local Results=require('src.presentation.round_results')
  local Hub=require('src.screens.hub')
  Results.hide() Hub.challengeTab='achievements' Hub.message=''
  RunFlow.mode='continue' RunFlow.message='' RunFlow.recovery=nil RunFlow.selectedSlot=nil
  local state=states[stateIndex]
  Prefs.arena='patio' Prefs.reduced=false
  require('src.screens.visual_settings').message=''
  G.state=state
  if state:match('^playing_') then G.state='playing' end
  if state=='arena_taller' then G.state='playing' Prefs.arena='taller' end
  if state=='arena_ciudad' then G.state='playing' Prefs.arena='ciudad' end
  if G.state=='playing' then
   local function hazard(kind,x,y,r,age)
    return {kind=kind,x=x,y=y,r=r,age=age,warning=2,active=6,fade=.5,vx=100,vy=0,phase=.5,cooldown=0}
   end
   require('src.hazards').list={hazard(1,460,240,29,1.2),hazard(3,740,417,30,3),hazard(5,345,407,34,3)}
   require('src.objects').list={{kind=1,x=174,y=400,r=32,hits=7,life=18,fullLife=32,phase=0,fx=.15},{kind=5,x=780,y=260,r=27,hits=99,life=18,fullLife=23,phase=0,fx=0}}
  end
  if state:match('^slots_') then
   G.state='slots'
   if state=='slots_new' then RunFlow.mode='new' RunFlow.difficulty=2 end
   if state=='slots_full' then
    assert(G.newRun(2,3) and G.newRun(3,4)) G.state='slots' RunFlow.mode='new'
   end
   if state=='slots_backup' or state=='slots_recovered' then
    local good=assert(love.filesystem.read('partida_1.txt'))
    assert(love.filesystem.write('partida_1.txt.bak',good))
    assert(love.filesystem.write('partida_1.txt','CORRUPTO'))
    if state=='slots_recovered' then assert(RunFlow.chooseSlot(G,1)) end
   end
   if state=='slots_damaged' then
    assert(love.filesystem.write('partida_1.txt','CORRUPTO'))
    love.filesystem.remove('partida_1.txt.bak')
   end
   if state=='slots_delete' or state=='slots_delete_error' then
    G.state='confirm'
    if state=='slots_delete_error' then RunFlow.message='No se pudo borrar todo. Los archivos restantes se conservan.' end
   end
  end
  if state=='store_empty' then G.state='store' P.gems=0 end
  if state=='collection_owned' then G.state='collection' P.owned[2]=true P.skin=2 end
  if state=='milestones' then G.state='achievements' Hub.challengeTab='milestones' P.best={2,5,8,12} end
  if state=='results' then
   G.state='shop' G.previousRound=3 G.round=4 G.reward=40 G.gemsReward=2
   Results.show(G)
  end
  if state=='purchase' then
   G.state='store'
   originalDraw()
   local scale=math.min(width/1000,height/680)
   love.mousepressed((width-1000*scale)/2+400*scale,(height-680*scale)/2+459*scale,1)
  end
  if G.state=='over' then G.reason='¡La pelota tocó los pinchos!' end
  G.shake=0 G.noticeT=0
  if state=='playing_notice' then G.noticeT=2 G.notice='Elige un punto dentro de la cancha. La defensa sigue en tu mochila.' end
  if state=='playing_tutorial' then
   G.startTutorial() G.tutorialStep=3 G.noticeT=0
   G.ball.x,G.ball.y=G.player.x+60,G.player.y
  end
  if state=='playing_reduced' then Prefs.reduced=true G.shake=8 G.pulseVisual=.25 G.pulseX=G.player.x G.pulseY=G.player.y end
  if state=='playing_extreme' then G.score=99999999 G.coins=99999 G.round=999 G.rescues=9 G.pulseCooldown=9.9 end
  if state=='playing_edge' then G.ball.x,G.ball.y=210,146 G.player.x,G.player.y=320,151 end
  frames=0
 end
 love.load=function()
  love.filesystem.setIdentity('balller_visual_v8',true)
  for slot=1,3 do Save.clearRun(slot) end
  love.filesystem.remove('perfil_balller_v7.txt')
  love.filesystem.remove('perfil_balller_v7.txt.bak')
  love.filesystem.remove(Prefs.file)
  originalLoad()
  for _,name in ipairs({'surfaces','icons','backdrop','home-court','meters','arena-patio','arena-taller','arena-ciudad'}) do
   assert(require('src.presentation.assets').images[name],'Missing UI texture '..name)
  end
  love.math.setRandomSeed(8001)
  P.gems=12
  love.filesystem.createDirectory('captures')
  setup()
 end
 love.update=function()
  frames=frames+1
  if pending then return end
  if frames>=4 then
   pending=true
   local filename='captures/'..states[stateIndex]..'-'..sizes[sizeIndex][1]..'x'..sizes[sizeIndex][2]..'.png'
   love.graphics.captureScreenshot(function(data)
    assert(data:encode('png',filename))
    print('CAPTURE '..love.filesystem.getSaveDirectory()..'/'..filename)
    stateIndex=stateIndex+1
    if stateIndex>#states then stateIndex=1 sizeIndex=sizeIndex+1 end
    if sizeIndex>#sizes then love.event.quit(0) return end
    setup()
    pending=false
   end)
  end
 end
 love.draw=function()
  if states[stateIndex]=='playing_fallback' then
   local image=Assets.images['arena-patio']
   Assets.images['arena-patio']=nil
   originalDraw()
   Assets.images['arena-patio']=image
   return
  end
  if states[stateIndex]~='components' then originalDraw() return end
  local UI=require('src.ui')
  local C=require('src.theme')
  local width,height=love.graphics.getDimensions()
  local scale=math.min(width/1000,height/680)
  love.graphics.push('all')
  love.graphics.translate((width-1000*scale)/2,(height-680*scale)/2)
  love.graphics.scale(scale)
  require('src.art').background(0)
  UI.label('Balller · Componentes PNG',56,28,UI.fonts.title,C.ink)
  local mouseDown=love.mouse.isDown
  for i,name in ipairs({'Normal','Pulsado','No disponible','Seleccionado'}) do
   local y=108+(i-1)*126
   UI.panel(50,y,900,112)
   UI.label(name,78,y+30,UI.fonts.medium,C.ink)
   love.mouse.isDown=function() return i==2 end
   UI.button(380,y+19,245,65,'Jugar',C.mint,400,y+30,'play',false,{disabled=i==3,selected=i==4})
   UI.button(664,y+29,235,48,'Comprar 22',C.blue,0,0,'coin',true,{disabled=i==3,selected=i==4})
  end
  love.mouse.isDown=mouseDown
  love.graphics.pop()
 end
 love.focus=function() end
 love.quit=function() end
end
return M
