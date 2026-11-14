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
local slotIntent='new'
local confirmSlot=1
local function resize(w,h)
 scale=math.min(w/W,h/H)
 ox=(w-W*scale)/2
 oy=(h-H*scale)/2
end
local function toLogical(x,y) return (x-ox)/scale,(y-oy)/scale end
local function addButton(id,x,y,w,h,label,clr,icon,small)
 local r=UI.button(x,y,w,h,label,clr,mouseX,mouseY,icon,small)
 buttons[#buttons+1]={id=id,rect=r}
end
local function inside(rect,x,y)
 return x>=rect.x and x<=rect.x+rect.w and y>=rect.y and y<=rect.y+rect.h
end
local function roundLabel()
 return 'RONDA '..Game.round
end
local function header()
 UI.panel(34,15,932,82,19)
 UI.label('BALLLER',53,25,UI.fonts.title,C.navy)
 Sprites.draw('ball',242,56,math.floor(Game.t*8)%8+1,50)
 if Game.state=='playing' or Game.state=='pause' or Game.state=='over' or Game.state=='shop' then
  UI.pill(265,25,157,60,'star','Puntos',string.format('%06d',math.floor(Game.score)),{1,.98,.9},C.gold)
  UI.pill(432,25,148,60,'coin','Monedas',tostring(math.floor(Game.coins)),{1,.97,.87},C.gold)
  UI.pill(591,25,145,60,'flag','Ronda',tostring(Game.round),{.91,.99,.96},C.mintDark)
  if Game.state=='playing' or Game.state=='pause' then
   UI.pill(746,25,139,60,'clock','Quedan',string.format('%02d:%02d',math.floor(Game.roundLeft/60),math.ceil(Game.roundLeft%60)),{.9,.97,1},C.blue)
  elseif Game.state=='shop' then
   UI.pill(746,25,139,60,'bag','Mochila',tostring(Game.inventory[1]+Game.inventory[2]+Game.inventory[3]+Game.inventory[4]+Game.inventory[5]+Game.inventory[6])..'/12',{.9,.97,1},C.blue)
  else
   UI.pill(746,25,139,60,'trophy','Récord',tostring(math.floor(Save.best)),{.9,.97,1},C.blue)
  end
  if Game.state=='playing' then addButton('pause',896,30,59,51,'',C.blue,'pause',true) end
 else
  UI.pill(720,24,230,61,'trophy','Mi récord',tostring(math.floor(Save.best)),{1,.97,.87},C.gold)
 end
end
local function menu()
 UI.panel(67,119,866,514,30)
 UI.rect(101,154,463,43,14,{.9,.97,.99})
 Icons.draw('spark',122,176,23,C.gold)
 UI.label('UNA PELOTA. MUCHAS RONDAS.',144,165,UI.fonts.small,C.navy)
 UI.label('BALLLER',119,218,UI.fonts.big,C.navy)
 UI.rect(124,300,309,6,3,C.mint)
 UI.label('¡Protégela hasta el final!',124,330,UI.fonts.medium,C.ink)
 UI.label('Compra defensas. Sobrevive. Supera tu récord.',124,370,UI.fonts.small,C.muted)
 UI.rect(625,164,260,290,60,{.91,.98,1})
 Art.mascot(749,309,1.12,Game.t)
 UI.rect(637,460,242,43,15,{1,.96,.84})
 Icons.draw('trophy',662,480,23,C.gold)
 UI.label('¡Cada ronda cuenta!',687,470,UI.fonts.small,C.ink)
 addButton('new',124,411,414,64,'NUEVA PARTIDA',C.mint,'play')
 local saved=false
 for i=1,3 do if Save.hasRun(i) then saved=true break end end
 if saved then
  addButton('continue',124,490,198,53,'CONTINUAR',C.blue,'save',true)
 else
  UI.rect(124,490,198,53,14,{.89,.93,.94})
  UI.label('SIN PARTIDAS',139,509,UI.fonts.small,C.muted)
 end
 addButton('help',333,490,205,53,'CÓMO JUGAR',C.lilac,'help',true)
 addButton('sound',124,557,198,53,Save.sound and 'SONIDO: SÍ' or 'SONIDO: NO',C.blue,Save.sound and 'sound' or 'mute',true)
 UI.label('Récord: '..math.floor(Save.best),355,565,UI.fonts.body,C.ink)
 UI.label('Partidas: '..Save.games,355,591,UI.fonts.small,C.muted)
end
local function slotsScreen()
 UI.panel(84,118,832,525,28)
 local isNew=slotIntent=='new'
 Icons.draw('save',127,161,31,C.mintDark)
 UI.label(isNew and 'NUEVA PARTIDA' or 'PARTIDAS GUARDADAS',161,137,UI.fonts.title,C.navy)
 UI.label(isNew and 'Elige dónde guardar tu aventura.' or 'Elige una partida para continuar.',129,191,UI.fonts.body,C.muted)
 for i=1,3 do
  local y=224+(i-1)*118
  UI.rect(120,y+4,762,106,18,{.68,.79,.81})
  UI.rect(120,y,762,106,18,i%2==1 and {.92,.98,.97} or {.93,.97,1})
  UI.rect(140,y+17,62,68,19,i%2==1 and C.mint or C.blue)
  Icons.draw('flag',171,y+51,36,C.paper)
  UI.label('RANURA '..i,219,y+16,UI.fonts.medium,C.navy)
  local s=Save.slotInfo(i)
  if s then
   UI.label('Ronda '..s.round..'   •   '..math.floor(s.score)..' puntos',219,y+51,UI.fonts.small,C.ink)
   UI.label(math.floor(s.coins)..' monedas',220,y+77,UI.fonts.small,C.muted)
   addButton('slot'..i,668,y+26,194,57,isNew and 'REEMPLAZAR' or 'CONTINUAR',isNew and C.gold or C.mint,isNew and 'warning' or 'play',true)
  elseif Save.hasRun(i) then
   UI.label('Guardado dañado. Puedes reemplazarlo.',219,y+58,UI.fonts.small,C.red)
   if isNew then addButton('slot'..i,668,y+26,194,57,'REEMPLAZAR',C.gold,'warning',true) end
  else
   UI.label('Ranura vacía',219,y+57,UI.fonts.body,C.muted)
   if isNew then addButton('slot'..i,668,y+26,194,57,'CREAR',C.mint,'play',true) end
  end
 end
 addButton('back',367,597,266,41,'VOLVER',C.blue,'back',true)
end
local function confirmation()
 UI.color(C.navy,.3)
 love.graphics.rectangle('fill',0,0,W,H)
 UI.panel(245,190,510,302,27)
 Icons.draw('warning',500,243,58,C.gold)
 UI.headline('¿REEMPLAZAR PARTIDA?',277,287,446,UI.fonts.medium,C.navy)
 UI.label('La partida de la ranura '..confirmSlot..' será reemplazada.',271,339,UI.fonts.body,C.muted,'center',458)
 UI.label('Este cambio no se puede deshacer.',280,372,UI.fonts.small,C.red,'center',440)
 addButton('cancel',281,424,204,50,'CANCELAR',C.blue,'back',true)
 addButton('replace',504,424,214,50,'REEMPLAZAR',C.gold,'check',true)
end
local function help()
 UI.panel(99,107,802,540,26)
 UI.headline('CÓMO JUGAR',151,128,697,UI.fonts.title,C.navy)
 UI.rect(139,199,724,65,16,{.9,.98,.95})
 Icons.draw('arrows',171,232,30,C.mintDark)
 UI.label('Mueve al personaje y golpea la pelota.',203,205,UI.fonts.body,C.ink)
 UI.label('WASD o flechas • P para pausar • clic para colocar.',203,232,UI.fonts.small,C.muted)
 UI.rect(139,276,724,67,16,{.92,.97,1})
 Icons.draw('flag',171,308,29,C.blue)
 UI.label('Sobrevive hasta que termine el tiempo de ronda.',203,280,UI.fonts.body,C.ink)
 UI.label('Gana monedas: base + golpes + objetivo cumplido.',203,308,UI.fonts.small,C.muted)
 UI.rect(139,355,724,62,16,{1,.97,.89})
 Icons.draw('bag',171,385,29,C.gold)
 UI.label('Compra objetos entre rondas. Úsalos dentro de la cancha.',203,363,UI.fonts.body,C.ink)
 UI.label('Los que no utilices se conservan para rondas futuras.',203,392,UI.fonts.small,C.muted)
 UI.label('NUEVOS PELIGROS A PARTIR DE LAS RONDAS 2, 4 Y 6',143,435,UI.fonts.small,C.muted)
 for i,name in ipairs({'spikes','drain','saw','shock','vortex'}) do
  local x=214+(i-1)*143
  Sprites.draw(name,x,504,math.floor(Game.t*8)%8+1,62)
  UI.label(Hazards.names[i],x-52,540,UI.fonts.small,C.ink,'center',104)
 end
 addButton('back',336,589,326,48,'ENTENDIDO',C.mint,'check',true)
end
local function shop()
 UI.panel(65,117,870,524,28)
 Icons.draw('bag',111,166,35,C.mintDark)
 UI.label('TIENDA',140,136,UI.fonts.title,C.navy)
 local note=Game.previousRound==0 and 'Prepara la ronda 1' or '¡Ronda '..Game.previousRound..' superada!'
 UI.label(note,390,139,UI.fonts.medium,C.mintDark)
 UI.label('MONEDAS: '..math.floor(Game.coins),740,149,UI.fonts.small,C.ink)
 if Game.winFlash>0 then
  local pulse=1+math.sin(Game.t*9)*.12
  Icons.draw('spark',655,164,27*pulse,C.gold)
  Icons.draw('star',691,137,18,C.gold)
 end
 UI.rect(95,197,810,45,14,{.9,.97,1})
 Icons.draw('star',117,219,24,C.gold)
 local rewardText=Game.previousRound==0 and 'Tienes 40 monedas y 2 defensas iniciales.' or ('Recompensa de la ronda anterior: +'..Game.reward..' monedas')
 UI.label(rewardText,140,205,UI.fonts.small,C.ink)
 UI.label('Objetivo siguiente: '..Game.goal()..' golpes = +12 monedas',140,226,UI.fonts.tiny,C.muted)
 for i,item in ipairs(Objects.types) do
  local col=(i-1)%3
  local row=math.floor((i-1)/3)
  local x=94+col*276
  local y=259+row*129
  UI.rect(x,y+5,257,119,16,{.66,.79,.8})
  UI.rect(x,y,257,119,16,((i%2)==0) and {.94,.98,1} or {.94,.99,.96})
  Sprites.draw(item.sprite,x+52,y+41,math.floor(Game.t*8)%8+1,79)
  UI.label(item.name,x+102,y+13,UI.fonts.body,C.ink)
  UI.label('Tienes '..Game.inventory[i],x+105,y+39,UI.fonts.small,C.muted)
  UI.rect(x+14,y+73,110,35,11,{1,.96,.82})
  Icons.draw('coin',x+33,y+91,17,C.gold)
  UI.label(tostring(item.cost),x+51,y+79,UI.fonts.body,C.navy)
  addButton('buy'..i,x+130,y+73,115,35,'COMPRAR',Game.coins>=item.cost and C.mint or C.blue,'plus',true)
 end
 local nextHazard=Game.round>=6 and 'Todos los peligros activos' or Game.round>=4 and 'Nueva amenaza: descarga eléctrica' or Game.round>=2 and 'Nueva amenaza: sierra móvil' or 'Pinchos y alcantarillas'
 UI.label(nextHazard,111,529,UI.fonts.small,C.muted)
 addButton('home',104,567,230,53,'GUARDAR Y SALIR',C.blue,'save',true)
 addButton('round',524,560,380,64,'JUGAR RONDA '..Game.round,C.mint,'play')
end
local function inventoryBar()
 for i,item in ipairs(Objects.types) do
  local x=35+(i-1)*155
  local y=572
  local chosen=Objects.selected==i
  local count=Game.inventory[i]
  local bg=chosen and {.97,1,.89} or C.paper
  UI.rect(x,y+5,146,66,15,chosen and C.mintDark or {.66,.8,.8})
  UI.rect(x,y,146,66,15,bg)
  if chosen then UI.outline(x+1,y+1,144,64,14,C.mintDark,3) end
  Sprites.draw(item.sprite,x+32,y+33,math.floor(Game.t*9)%8+1,58,count>0 and 1 or .45)
  UI.label(item.name,x+62,y+11,UI.fonts.small,count>0 and C.ink or C.muted)
  UI.rect(x+62,y+35,54,24,8,count>0 and {.88,.98,.91} or {.9,.93,.94})
  UI.label('x'..count,x+74,y+38,UI.fonts.small,count>0 and C.mintDark or C.muted)
  UI.rect(x+124,y+7,17,19,6,chosen and C.mintDark or C.blue)
  UI.label(tostring(i),x+128,y+8,UI.fonts.tiny,C.paper)
  buttons[#buttons+1]={id='item'..i,rect={x=x,y=y,w=146,h=66}}
 end
 local it=Objects.types[Objects.selected]
 UI.label('CLIC: colocar   •   '..it.desc,36,651,UI.fonts.small,C.ink)
 UI.label('WASD: mover   •   P: pausa',750,652,UI.fonts.small,C.muted)
end
local function inGame()
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
 inventoryBar()
 UI.rect(53,118,265,37,13,{.94,.99,.95})
 Icons.draw('flag',76,136,19,C.mintDark)
 UI.label('Objetivo: '..Game.roundHits..' / '..Game.goal()..' golpes',95,124,UI.fonts.small,C.navy)
 if Feedback.combo>1 and Feedback.comboTimer>0 and Game.state=='playing' then
  UI.panel(372,110,256,40,13)
  Icons.draw('spark',397,130,20,C.gold)
  UI.label('RACHA x'..Feedback.combo,420,118,UI.fonts.body,C.mintDark)
 end
 if Feedback.milestone>0 and Game.state=='playing' then
  UI.panel(338,162,324,49,14)
  Icons.draw('trophy',365,184,25,C.gold)
  UI.label('¡BUEN TRABAJO!',388,171,UI.fonts.medium,C.mintDark)
 end
 if Game.noticeT>0 and Game.state=='playing' then
  UI.panel(300,193,400,44,14)
  UI.label(Game.notice,310,205,UI.fonts.small,C.ink,'center',380)
 end
 if Game.state=='pause' then
  buttons={}
  UI.color(C.navy,.34)
  love.graphics.rectangle('fill',0,0,W,H)
  UI.panel(234,146,532,418,28)
  Icons.draw('pause',500,206,48,C.blue)
  UI.headline('EN PAUSA',270,248,460,UI.fonts.title,C.navy)
  UI.label('Ranura '..Game.slot..' • Ronda '..Game.round,292,302,UI.fonts.body,C.ink,'center',416)
  UI.label(Game.noticeT>0 and Game.notice or 'Puedes guardar y continuar más tarde.',292,332,UI.fonts.small,C.muted,'center',416)
  addButton('resume',314,377,372,56,'CONTINUAR',C.mint,'play')
  addButton('save',314,446,176,51,'GUARDAR',C.blue,'save',true)
  addButton('home',508,446,178,51,'SALIR AL MENÚ',C.lilac,'home',true)
 elseif Game.state=='over' then
  buttons={}
  UI.color(C.navy,.36)
  love.graphics.rectangle('fill',0,0,W,H)
  UI.panel(234,146,532,422,28)
  Icons.draw('trophy',500,206,54,C.gold)
  UI.headline('FIN DE PARTIDA',258,246,484,UI.fonts.title,C.navy)
  UI.label(Game.reason,271,302,UI.fonts.small,C.ink,'center',458)
  UI.pill(293,348,185,66,'star','Puntos',tostring(math.floor(Game.score)),{1,.98,.90},C.gold)
  UI.pill(492,348,215,66,'flag','Rondas',tostring(math.max(0,Game.round-1)),{.92,.98,1},C.blue)
  UI.label('La ranura quedó libre para una nueva partida.',277,427,UI.fonts.small,C.muted,'center',446)
  addButton('replay',301,476,194,55,'NUEVA PARTIDA',C.mint,'play',true)
  addButton('home',506,476,193,55,'MENÚ',C.blue,'home',true)
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
 if Game.state=='menu' then header() menu()
 elseif Game.state=='slots' then header() slotsScreen()
 elseif Game.state=='confirm' then header() slotsScreen() buttons={} confirmation()
 elseif Game.state=='help' then header() help()
 elseif Game.state=='shop' then header() shop()
 else inGame() end
 love.graphics.pop()
end
local function click(id)
 Sound.play('button')
 if id=='new' then slotIntent='new' Game.state='slots'
 elseif id=='continue' then slotIntent='load' Game.state='slots'
 elseif id=='back' then Game.state='menu'
 elseif id=='cancel' then Game.state='slots'
 elseif id=='replace' then Save.clearRun(confirmSlot) Game.newRun(confirmSlot)
 elseif id:sub(1,4)=='slot' then
  local slot=tonumber(id:sub(5))
  if slotIntent=='new' then
   if Save.hasRun(slot) then confirmSlot=slot Game.state='confirm'
   else Game.newRun(slot) end
  else
   if not Game.loadRun(slot) then Game.notify('No se pudo leer la partida') end
  end
 elseif id=='help' then Game.state='help'
 elseif id=='play' then slotIntent='new' Game.state='slots'
 elseif id=='round' then Game.startRound()
 elseif id=='resume' then Game.togglePause()
 elseif id=='pause' then Game.togglePause()
 elseif id=='home' then Game.backToMenu()
 elseif id=='save' then
  if Game.saveRun() then Game.notify('Partida guardada en ranura '..Game.slot)
  else Game.notify('No se pudo guardar la partida') end
 elseif id=='replay' then Game.newRun(Game.slot)
 elseif id=='sound' then Save.sound=not Save.sound Sound.enabled=Save.sound Save.store()
 elseif id:sub(1,3)=='buy' then Game.buy(tonumber(id:sub(4)))
 elseif id:sub(1,4)=='item' then Objects.selected=tonumber(id:sub(5)) or 1 end
end
function love.mousepressed(x,y,button)
 if button~=1 then return end
 x,y=toLogical(x,y)
 for i=#buttons,1,-1 do
  if inside(buttons[i].rect,x,y) then click(buttons[i].id) return end
 end
 if Game.state=='playing' then Game.place(x,y) end
end
function love.keypressed(key)
 if key=='escape' or key=='p' then
  if Game.state=='help' or Game.state=='slots' then Game.state='menu'
  elseif Game.state=='confirm' then Game.state='slots'
  elseif Game.state=='playing' or Game.state=='pause' then Game.togglePause() end
 elseif key=='return' or key=='kpenter' then
  if Game.state=='menu' then slotIntent='new' Game.state='slots'
  elseif Game.state=='shop' then Game.startRound() end
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
function love.focus(focused)
 if not focused and Game.state=='playing' then Game.togglePause() end
end
function love.quit()
 if Game.state=='playing' or Game.state=='pause' or Game.state=='shop' then Game.saveRun() end
end
