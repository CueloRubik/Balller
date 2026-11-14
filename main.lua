local UI=require('src.ui')
local Art=require('src.art')
local Game=require('src.game')
local Save=require('src.save')
local Sound=require('src.audio')
local Objects=require('src.objects')
local Progress=require('src.progression')
local Screens=require('src.v7screens')

local W,H=1000,680
local scale,offsetX,offsetY=1,0,0
local buttons={}
local mouseX,mouseY=0,0
local selectedDifficulty=2
local confirmSlot=1
local ciFrames=nil
local function ciSmokeRequested()
 for _,value in pairs(arg or {}) do if value=='--ci-smoke' then return true end end
 return false
end
local function resize(w,h)
 scale=math.min(w/W,h/H)
 offsetX=(w-W*scale)/2
 offsetY=(h-H*scale)/2
end
local function logical(x,y) return (x-offsetX)/scale,(y-offsetY)/scale end
local function addButton(id,x,y,w,h,label,c,icon,small,options)
 local rect=UI.button(x,y,w,h,label,c,mouseX,mouseY,icon,small,options)
 buttons[#buttons+1]={id=id,rect=rect,disabled=options and options.disabled}
end
local function hitbox(id,x,y,w,h)
 buttons[#buttons+1]={id=id,rect={x=x,y=y,w=w,h=h}}
end
Screens.bind(addButton,hitbox)
local function overlayScreen()
 buttons={}
 if Game.state=='pause' then Screens.pause() else Screens.over() end
end
function love.load()
 if ciSmokeRequested() and love.filesystem.setIdentity then love.filesystem.setIdentity('balller_ci_v7',true) end
 UI.load()
 Art.load()
 Save.load()
 Progress.load()
 Sound.load()
 Sound.enabled=Save.sound
 love.math.setRandomSeed(os.time())
 resize(love.graphics.getDimensions())
 if ciSmokeRequested() then
  ciFrames=0
  assert(Game.newRun(1,2),'No se pudo crear partida de prueba')
 end
end
function love.resize(w,h) resize(w,h) end
function love.update(dt)
 dt=math.min(dt,.04)
 Game.update(dt)
 if Progress.dirty and (Game.state=='shop' or Game.state=='menu') then Progress.save() end
 mouseX,mouseY=logical(love.mouse.getPosition())
 if ciFrames then
  ciFrames=ciFrames+1
  if ciFrames==12 then assert(Game.startRound()) end
  if ciFrames==40 then Game.togglePause() end
  if ciFrames==50 then Game.togglePause() end
  if ciFrames>=85 then love.event.quit(0) end
 end
end
function love.draw()
 love.graphics.push()
 love.graphics.translate(offsetX,offsetY)
 love.graphics.scale(scale,scale)
 buttons={}
 Art.background(Game.t)
 if Game.state=='menu' then Screens.home()
 elseif Game.state=='difficulty' then Screens.difficulties()
 elseif Game.state=='slots' then Screens.slots()
 elseif Game.state=='confirm' then Screens.slots() buttons={} Screens.confirm(confirmSlot)
 elseif Game.state=='collection' then Screens.collection()
 elseif Game.state=='achievements' then Screens.achievements()
 elseif Game.state=='settings' then Screens.settings()
 elseif Game.state=='help' then Screens.help()
 elseif Game.state=='shop' then Screens.shop()
 elseif Game.state=='tutorialDone' then Screens.tutorialDone()
 else
  Screens.game()
  if Game.state=='pause' or Game.state=='over' then overlayScreen() end
 end
 love.graphics.pop()
end
local function click(id)
 Sound.play('button')
 if id=='new' then
  Game.state='difficulty'
 elseif id=='continue' then
  Game.state='slots'
 elseif id=='collection' or id=='achievements' or id=='settings' or id=='help' then
  Game.state=id
 elseif id=='back' then
  Game.backToMenu()
 elseif id=='tutorial' then
  Game.startTutorial()
 elseif id=='toDifficulty' or id=='replay' then
  Game.tutorial=false Game.state='difficulty'
 elseif id:sub(1,10)=='difficulty' then
  selectedDifficulty=tonumber(id:sub(11)) or 2
  Game.state='slots'
 elseif id:sub(1,4)=='slot' then
  local slot=tonumber(id:sub(5))
  if Save.hasRun(slot) then
   if not Game.loadRun(slot) then Game.notify('Guardado dañado') end
  else
   Game.newRun(slot,selectedDifficulty)
  end
 elseif id:sub(1,6)=='delete' and id~='deleteConfirm' then
  confirmSlot=tonumber(id:sub(7)) or 1 Game.state='confirm'
 elseif id=='cancel' then
  Game.state='slots'
 elseif id=='deleteConfirm' then
  Save.clearRun(confirmSlot) Game.state='slots'
 elseif id=='sound' then
  Save.sound=not Save.sound Sound.enabled=Save.sound Save.store()
 elseif id:sub(1,4)=='skin' then
  local ok,message=Progress.unlock(tonumber(id:sub(5)))
  Game.notify(message)
  if ok then Sound.play('upgrade') else Sound.play('warn') end
 elseif id=='upgrade' then
  Game.buyUpgrade()
 elseif id:sub(1,3)=='buy' then
  Game.buy(tonumber(id:sub(4)))
 elseif id=='round' then
  Game.startRound()
 elseif id=='pause' or id=='resume' then
  Game.togglePause()
 elseif id=='pulse' then
  Game.pulse()
 elseif id=='previousPage' or id=='nextPage' then
  local page=Screens.page()
  Screens.setPage(page==1 and 2 or 1)
 elseif id:sub(1,4)=='item' then
  Objects.selected=tonumber(id:sub(5)) or 1
 elseif id=='save' then
  Game.saveRun()
 elseif id=='home' then
  Game.backToMenu()
 end
end
function love.mousepressed(x,y,button)
 if button~=1 then return end
 x,y=logical(x,y)
 for i=#buttons,1,-1 do
  local r=buttons[i].rect
  if x>=r.x and x<=r.x+r.w and y>=r.y and y<=r.y+r.h then
   if buttons[i].disabled then return end
   click(buttons[i].id)
   return
  end
 end
 if Game.state=='playing' then Game.place(x,y) end
end
function love.keypressed(key)
 if key=='escape' or key=='p' then
  if Game.state=='playing' or Game.state=='pause' then Game.togglePause()
  elseif Game.state=='confirm' then Game.state='slots'
  elseif Game.state~='over' then Game.backToMenu() end
 elseif key=='return' or key=='kpenter' then
  if Game.state=='menu' or Game.state=='tutorialDone' then Game.state='difficulty'
  elseif Game.state=='shop' then Game.startRound() end
 elseif Game.state=='playing' then
  if key=='space' then Game.pulse() return end
  local n=tonumber(key)
  if n and n>=1 and n<=#Objects.types then
   Objects.selected=n
   Screens.setPage(n<=4 and 1 or 2)
  end
 end
end
function love.wheelmoved(x,y)
 if Game.state~='playing' or y==0 then return end
 local n=#Objects.types
 Objects.selected=((Objects.selected-1+(y>0 and -1 or 1))%n)+1
 Screens.setPage(Objects.selected<=4 and 1 or 2)
end
function love.focus(focused)
 if not focused and Game.state=='playing' then Game.togglePause() end
end
function love.quit()
 Progress.save()
 if not Game.tutorial and (Game.state=='playing' or Game.state=='pause' or Game.state=='shop') then Game.saveRun() end
end
for _,value in pairs(arg or {}) do
 if value=='--visual-check' then require('tools.capture_ui').install() break end
end
