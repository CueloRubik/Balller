local C=require('src.theme')
local UI=require('src.ui')
local Icons=require('src.icons')
local Art=require('src.art')
local Game=require('src.game')
local Save=require('src.save')
local Sound=require('src.audio')
local FX=require('src.particles')
local Feedback=require('src.feedback')
local Sprites=require('src.sprites')
local Hazards=require('src.hazards')
local Objects=require('src.objects')

local W,H=1000,680
local scale,ox,oy=1,0,0
local buttons={}
local mouseX,mouseY=0,0

local function resize(w,h)
 scale=math.min(w/W,h/H)
 ox=(w-W*scale)/2
 oy=(h-H*scale)/2
end
local function toLogical(x,y) return (x-ox)/scale,(y-oy)/scale end
local function addButton(id,x,y,w,h,label,color,icon,small)
 local r=UI.button(x,y,w,h,label,color,mouseX,mouseY,icon,small)
 buttons[#buttons+1]={id=id,rect=r}
end
local function header()
 UI.panel(34,14,932,83,19)
 UI.label('BALLLER',55,24,UI.fonts.title,C.navy)
 Sprites.draw('ball',246,53,math.floor(Game.t*8)%8+1,51)
 if Game.state=='playing' or Game.state=='pause' or Game.state=='over' then
  UI.pill(300,24,164,61,'star','Puntos',string.format('%06d',math.floor(Game.score)),{.99,.98,.91},C.gold)
  UI.pill(477,24,146,61,'coin','Monedas',tostring(Game.coins),{1,.97,.88},C.gold)
  UI.pill(636,24,153,61,'clock','Tiempo',string.format('%02d:%02d',math.floor(Game.time/60),math.floor(Game.time%60)),{.90,.97,1},C.blue)
  if Game.state=='playing' then
   addButton('pause',814,30,132,49,'PAUSA',C.blue,'pause',true)
  end
 else
  UI.pill(704,24,242,61,'trophy','Mi récord',tostring(math.floor(Save.best)),{1,.97,.87},C.gold)
 end
end
local function store()
 local m=Objects.selected
 for i,item in ipairs(Objects.types) do
  local x=34+(i-1)*155
  local y=568
  local hover=mouseX>=x and mouseX<=x+146 and mouseY>=y and mouseY<=y+75
  local active=m==i
  local bg=active and {.99,1,.93} or C.paper
  UI.rect(x,y+5,146,74,15,active and C.mintDark or {.67,.79,.83})
  UI.rect(x,y,146,74,15,bg)
  if hover then
   UI.rect(x+3,y+3,140,68,13,{.91,.97,1})
  end
  if active then UI.outline(x+1,y+1,144,72,14,C.mintDark,3) end
  Sprites.draw(item.sprite,x+31,y+36,(math.floor(Game.t*8)%8)+1,58)
  UI.label(item.name,x+60,y+12,UI.fonts.small,C.ink)
  UI.label(tostring(item.cost)..' $',x+60,y+42,UI.fonts.body,Game.coins<item.cost and C.red or C.mintDark)
  UI.rect(x+125,y+5,16,18,5,active and C.mintDark or C.blue)
  UI.label(tostring(i),x+129,y+5,UI.fonts.tiny,C.paper)
  if Game.coins<item.cost then
   UI.rect(x+6,y+5,4,64,2,C.red)
  end
  buttons[#buttons+1]={id='item'..i,rect={x=x,y=y,w=146,h=74}}
 end
 local item=Objects.types[m]
 UI.label(item.name..': '..item.desc,43,653,UI.fonts.small,C.ink)
 UI.label('WASD: mover  |  Clic: colocar  |  1-6: elegir',644,653,UI.fonts.small,C.muted)
end
local function menu()
 UI.panel(67,120,866,506,30)
 UI.rect(99,155,474,43,14,{.90,.97,.99})
 Icons.draw('spark',122,176,21,C.gold)
 UI.label('UN RETO DE REFLEJOS',146,163,UI.fonts.small,C.navy)
 UI.label('BALLLER',120,214,UI.fonts.big,C.navy)
 UI.rect(125,297,296,6,3,C.mint)
 UI.label('¡Que no se pierda la pelota!',125,323,UI.fonts.medium,C.ink)
 UI.label('Muévete, rebota y crea tu defensa.',125,365,UI.fonts.body,C.muted)
 UI.rect(618,170,273,296,58,{.91,.98,1})
 Art.mascot(744,312,1.12,Game.t)
 UI.rect(638,453,230,40,13,{.99,.94,.81})
 Icons.draw('star',663,473,21,C.gold)
 UI.label('¡Consigue un nuevo récord!',680,461,UI.fonts.small,C.ink)
 addButton('play',126,416,402,65,'JUGAR',C.mint,'play')
 addButton('help',126,506,196,55,'CÓMO JUGAR',C.blue,'help',true)
 addButton('sound',334,506,194,55,Save.sound and 'SONIDO: SÍ' or 'SONIDO: NO',C.lilac,Save.sound and 'sound' or 'mute',true)
 Icons.draw('trophy',138,596,21,C.gold)
 UI.label('Récord: '..math.floor(Save.best),155,583,UI.fonts.body,C.ink)
 UI.label('Partidas: '..Save.games,348,585,UI.fonts.small,C.muted)
end
local function help()
 UI.panel(102,109,796,526,26)
 UI.headline('CÓMO JUGAR',165,139,670,UI.fonts.title,C.navy)
 UI.rect(150,211,702,70,18,{.91,.98,.94})
 Icons.draw('arrows',185,246,34,C.mintDark)
 UI.label('Muévete con WASD o las flechas.',218,227,UI.fonts.body,C.ink)
 UI.label('Toca la pelota para hacerla rebotar.',218,252,UI.fonts.small,C.muted)
 UI.rect(150,292,702,60,18,{.91,.96,1})
 Icons.draw('warning',185,322,33,C.red)
 UI.label('¡Cuidado con los pinchos y alcantarillas!',218,306,UI.fonts.body,C.ink)
 UI.label('Aparecen con una señal de aviso.',218,329,UI.fonts.small,C.muted)
 UI.label('PREPARA TUS DEFENSAS',157,368,UI.fonts.small,C.muted)
 for i,item in ipairs(Objects.types) do
  local x=157+(i-1)*115
  Sprites.draw(item.sprite,x+30,416,(math.floor(Game.t*9)%8)+1,63)
  UI.label(item.name,x-13,457,UI.fonts.small,C.ink,'center',85)
 end
 UI.label('Golpea la pelota para ganar monedas y comprar objetos.',168,490,UI.fonts.small,C.muted)
 addButton('back',329,546,342,57,'ENTENDIDO',C.mint,'check')
end
local function overlay(title,subtitle,mode)
 UI.color(C.navy,.28)
 love.graphics.rectangle('fill',0,0,W,H)
 UI.panel(234,165,532,367,28)
 if mode=='over' then
  UI.rect(454,187,92,76,25,{1,.96,.82})
  Icons.draw('trophy',500,226,53,C.gold)
 else
  UI.rect(454,185,92,76,25,{.90,.97,1})
  Icons.draw('pause',500,223,48,C.blue)
 end
 UI.headline(title,257,274,486,UI.fonts.title,C.navy)
 UI.label(subtitle,286,328,UI.fonts.body,C.muted,'center',428)
 if mode=='over' then
  UI.pill(291,361,184,65,'star','Puntos',tostring(math.floor(Game.score)),{.99,.98,.90},C.gold)
  UI.pill(486,361,218,65,'trophy','Mi récord',tostring(math.floor(Save.best)),{.92,.98,1},C.blue)
  addButton('replay',318,450,172,55,'OTRA VEZ',C.mint,'play',true)
  addButton('home',510,450,172,55,'MENÚ',C.blue,'home',true)
 else
  addButton('resume',318,389,364,56,'CONTINUAR',C.mint,'play')
  addButton('home',318,462,364,46,'MENÚ PRINCIPAL',C.blue,'home',true)
 end
end
function love.load()
 UI.load()
 Art.load()
 Save.load()
 Sound.load()
 Sound.enabled=Save.sound
 love.math.setRandomSeed(os.time())
 resize(love.graphics.getDimensions())
end
function love.resize(w,h) resize(w,h) end
function love.update(dt)
 dt=math.min(dt,.04)
 Game.update(dt)
 mouseX,mouseY=toLogical(love.mouse.getPosition())
end
function love.draw()
 love.graphics.push()
 love.graphics.translate(ox,oy)
 love.graphics.scale(scale,scale)
 buttons={}
 Art.background(Game.t)
 if Game.state=='menu' then
  header()
  menu()
 elseif Game.state=='help' then
  header()
  help()
 else
  Art.field()
  love.graphics.push()
  if Game.shake>0 then
   love.graphics.translate((love.math.random()-.5)*Game.shake,(love.math.random()-.5)*Game.shake)
  end
  Art.hazards(Hazards.list,Game.t)
  Art.objects(Objects.list,Game.t)
  FX.draw()
  Feedback.draw()
  Art.ball(Game.ball)
  Art.player(Game.player)
  love.graphics.pop()
  header()
  store()
  if Feedback.combo>1 and Feedback.comboTimer>0 and Game.state=='playing' then
   UI.panel(373,105,254,38,12)
   Icons.draw('spark',396,124,20,C.gold)
   UI.label('RACHA  x'..Feedback.combo,417,112,UI.fonts.body,C.mintDark)
  end
  if Feedback.milestone>0 and Game.state=='playing' then
   UI.panel(338,162,324,49,14)
   Icons.draw('trophy',365,184,25,C.gold)
   UI.label('¡BUEN TRABAJO!',388,171,UI.fonts.medium,C.mintDark)
  end
  if Game.noticeT>0 and Game.state=='playing' then
   UI.panel(320,216,360,45,14)
   UI.label(Game.notice,332,228,UI.fonts.body,C.ink,'center',336)
  end
  if Game.state=='pause' then overlay('EN PAUSA','¿Listo para continuar?','pause') end
  if Game.state=='over' then overlay('FIN DE PARTIDA',Game.reason,'over') end
 end
 love.graphics.pop()
end
local function click(id)
 Sound.play('button')
 if id=='play' or id=='replay' then Game.start()
 elseif id=='help' then Game.state='help'
 elseif id=='back' or id=='home' then Game.state='menu'
 elseif id=='pause' or id=='resume' then Game.togglePause()
 elseif id=='sound' then
  Save.sound=not Save.sound
  Sound.enabled=Save.sound
  Save.store()
 elseif id:sub(1,4)=='item' then
  Objects.selected=tonumber(id:sub(5)) or 1
 end
end
function love.mousepressed(x,y,button)
 if button~=1 then return end
 x,y=toLogical(x,y)
 for i=#buttons,1,-1 do
  if UI.hit(buttons[i].rect,x,y) then
   click(buttons[i].id)
   return
  end
 end
 if Game.state=='playing' then Game.place(x,y) end
end
function love.keypressed(key)
 if key=='escape' or key=='p' then
  if Game.state=='help' then Game.state='menu'
  elseif Game.state=='playing' or Game.state=='pause' then Game.togglePause() end
 elseif key=='return' or key=='kpenter' then
  if Game.state=='menu' or Game.state=='over' then Game.start() end
 elseif Game.state=='playing' then
  local n=tonumber(key)
  if n and n>=1 and n<=#Objects.types then Objects.selected=n end
 end
end
function love.wheelmoved(x,y)
 if Game.state~='playing' or y==0 then return end
 local total=#Objects.types
 Objects.selected=((Objects.selected-1+(y>0 and -1 or 1))%total)+1
end
