local M={}
function M.install()
 local originalLoad,originalDraw=love.load,love.draw
 local G=require('src.game')
 local Save=require('src.save')
 local P=require('src.progression')
 local sizes={{1000,680},{800,600},{1280,720},{1366,768},{1920,1080}}
 local states={'menu','difficulty','slots','shop','collection','achievements','settings','playing','pause','over','components'}
 local sizeIndex,stateIndex,frames,pending=1,1,0,false
 local function setup()
  local width,height=unpack(sizes[sizeIndex])
  assert(love.window.setMode(width,height,{resizable=true,vsync=0,msaa=0}))
  love.resize(width,height)
  assert(G.newRun(1,2))
  P.gems=12 P.plays=0 P.rounds=0
  G.coins=160
  G.round=3
  G.previousRound=2 G.reward=30
  G.startRound()
  G.t=1.2
  G.score=230
  G.roundLeft=24
  G.coins=160
  G.state=states[stateIndex]
  if G.state=='over' then G.reason='¡La pelota tocó los pinchos!' end
  G.shake=0 G.noticeT=0
  frames=0
 end
 love.load=function()
  love.filesystem.setIdentity('balller_visual_v8',true)
  for slot=1,3 do Save.clearRun(slot) end
  love.filesystem.remove('perfil_balller_v7.txt')
  love.filesystem.remove('perfil_balller_v7.txt.bak')
  originalLoad()
  for _,name in ipairs({'surfaces','icons','backdrop','home-court'}) do
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
