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
local Difficulty=require('src.difficulty')

local W,H=1000,680
local ciFrames=nil
local function ciSmokeRequested()
 for _,value in pairs(arg or {}) do if value=='--ci-smoke' then return true end end
 return false
end
local scale,ox,oy=1,0,0
local buttons={}
local mouseX,mouseY=0,0
local slotIntent='new'
local confirmSlot=1
local selectedDifficulty=2
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
   UI.pill(746,25,139,60,'bag','Mochila',tostring((function() local n=0 for _,v in ipairs(Game.inventory) do n=n+v end return n end)())..'/12',{.9,.97,1},C.blue)
  else
   UI.pill(746,25,139,60,'trophy','Récord',tostring(math.floor(Save.best)),{.9,.97,1},C.blue)
  end
  if Game.state=='playing' then addButton('pause',896,30,59,51,'',C.blue,'pause',true) end
 else
  UI.pill(720,24,230,61,'trophy','Mi récord',tostring(math.floor(Save.best)),{1,.97,.87},C.gold)
 end
end
local function menu()
 UI.rect(61,123,879,512,34,{.61,.83,.87})
 UI.rect(61,116,879,512,34,C.paper)
 UI.rect(87,145,488,448,28,{.93,.99,.98})
 UI.rect(608,142,300,361,62,{.79,.94,1})
 for i=1,11 do
  local a=i*2.4+Game.t*.14
  UI.color(i%2==0 and C.gold or C.mint,.16)
  love.graphics.circle('fill',740+math.cos(a)*112,302+math.sin(a)*140,5+i%5*2)
 end
 Art.mascot(750,323,1.16,Game.t)
 UI.rect(626,472,257,38,15,{1,.96,.81})
 Icons.draw('star',652,491,20,C.gold)
 UI.label('¡La pelota cuenta contigo!',678,479,UI.fonts.small,C.ink)
 UI.label('BALLLER',123,170,UI.fonts.big,C.navy)
 UI.rect(127,255,305,7,4,C.mint)
 UI.label('¡Protege la pelota!',125,277,UI.fonts.medium,C.ink)
 UI.label('Rondas, defensas y desafíos para todos.',126,319,UI.fonts.small,C.muted)
 addButton('new',124,372,409,67,'JUGAR',C.mint,'play')
 local saved=false
 for i=1,3 do if Save.hasRun(i) then saved=true break end end
 addButton('continue',124,454,198,52,saved and 'MIS PARTIDAS' or 'RANURAS',C.blue,'save',true)
 addButton('tutorial',335,454,198,52,'APRENDER',C.gold,'help',true)
 addButton('help',124,519,198,49,'GUÍA',C.lilac,'help',true)
 addButton('sound',335,519,198,49,Save.sound and 'SONIDO: SÍ' or 'SONIDO: NO',C.blue,Save.sound and 'sound' or 'mute',true)
 UI.label('Récord '..math.floor(Save.best)..'  ·  '..Save.games..' partidas',640,568,UI.fonts.small,C.ink)
end
local function difficultyScreen()
 UI.panel(68,113,864,535,28)
 UI.headline('ELIGE TU RETO',112,137,776,UI.fonts.title,C.navy)
 UI.label('Puedes jugar a tu ritmo. La dificultad queda guardada en tu partida.',128,194,UI.fonts.small,C.muted)
 for i,mode in ipairs(Difficulty.list) do
  local col=(i-1)%2
  local row=math.floor((i-1)/2)
  local x=100+col*407
  local y=231+row*162
  UI.rect(x,y+6,389,144,22,{.66,.77,.8})
  UI.rect(x,y,389,144,22,({{.89,.98,.92},{.89,.96,1},{1,.95,.86},{1,.90,.93}})[i])
  UI.rect(x+12,y+13,9,119,4,mode.color)
  UI.rect(x+31,y+22,66,66,21,mode.color)
  Icons.draw(({'star','flag','spark','trophy'})[i],x+64,y+55,38,C.paper)
  UI.label(mode.name,x+108,y+14,UI.fonts.medium,C.navy)
  UI.label(mode.description,x+108,y+49,UI.fonts.tiny,C.muted,'left',268)
  UI.label('Rescates por ronda: '..mode.graces,x+110,y+82,UI.fonts.small,C.ink)
  addButton('difficulty'..i,x+111,y+102,254,34,'ELEGIR',mode.color,'check',true)
 end
 addButton('back',360,572,280,51,'VOLVER',C.blue,'back',true)
end
local function slotsScreen()
 UI.panel(84,118,832,525,28)
 Icons.draw('save',127,162,34,C.mintDark)
 UI.label('MIS PARTIDAS',160,138,UI.fonts.title,C.navy)
 UI.label('Continúa, elimina o empieza de nuevo cuando quieras.',129,193,UI.fonts.small,C.muted)
 for i=1,3 do
  local y=223+(i-1)*118
  UI.rect(120,y+5,762,107,18,{.65,.77,.8})
  UI.rect(120,y,762,107,18,i%2==0 and {.91,.97,1} or {.91,.99,.95})
  UI.rect(140,y+16,63,70,18,i%2==0 and C.blue or C.mint)
  Icons.draw('flag',171,y+51,36,C.paper)
  UI.label('PARTIDA '..i,220,y+12,UI.fonts.medium,C.navy)
  local info=Save.slotInfo(i)
  if info then
   local mode=Difficulty.get(info.difficulty)
   UI.label(mode.short..'  |  RONDA '..info.round..'  |  '..math.floor(info.score)..' PTS',221,y+48,UI.fonts.small,C.ink)
   UI.label(math.floor(info.coins)..' monedas guardadas',222,y+77,UI.fonts.small,C.muted)
   addButton('slot'..i,566,y+26,172,53,'SEGUIR',C.mint,'play',true)
   addButton('delete'..i,750,y+26,113,53,'BORRAR',C.red,'warning',true)
  elseif Save.hasRun(i) then
   UI.label('Este guardado no se puede leer.',221,y+55,UI.fonts.small,C.red)
   addButton('delete'..i,733,y+24,129,54,'BORRAR',C.red,'warning',true)
  else
   UI.label('Lista para una partida nueva',221,y+58,UI.fonts.small,C.muted)
   addButton('slot'..i,665,y+24,197,55,'CREAR',C.mint,'plus',true)
  end
 end
 addButton('back',367,596,266,42,'VOLVER',C.blue,'back',true)
end
local function confirmation()
 UI.color(C.navy,.42)
 love.graphics.rectangle('fill',0,0,W,H)
 UI.panel(245,190,510,302,27)
 Icons.draw('warning',500,246,53,C.gold)
 UI.headline('¿BORRAR PARTIDA?',277,286,446,UI.fonts.medium,C.navy)
 UI.label('Se eliminará la partida '..confirmSlot..' y su progreso.',271,339,UI.fonts.body,C.muted,'center',458)
 UI.label('Las demás ranuras no cambiarán.',280,373,UI.fonts.small,C.red,'center',440)
 addButton('cancel',281,426,204,50,'CANCELAR',C.blue,'back',true)
 addButton('deleteConfirm',504,426,214,50,'ELIMINAR',C.red,'check',true)
end
local function help()
 UI.panel(99,107,802,540,26)
 UI.headline('CÓMO JUGAR',151,128,697,UI.fonts.title,C.navy)
 UI.rect(139,199,724,65,16,{.9,.98,.95})
 Icons.draw('arrows',171,232,30,C.mintDark)
 UI.label('Mueve al personaje y protege la pelota.',203,205,UI.fonts.body,C.ink)
 UI.label('WASD: mover • Espacio: pulso de rescate • P: pausa.',203,232,UI.fonts.small,C.muted)
 UI.rect(139,276,724,67,16,{.92,.97,1})
 Icons.draw('flag',171,308,29,C.blue)
 UI.label('Sobrevive hasta que termine el tiempo de ronda.',203,280,UI.fonts.body,C.ink)
 UI.label('Gana monedas: supervivencia + golpes + meta variable.',203,308,UI.fonts.small,C.muted)
 UI.rect(139,355,724,62,16,{1,.97,.89})
 Icons.draw('bag',171,385,29,C.gold)
 UI.label('Compra objetos entre rondas. Úsalos dentro de la cancha.',203,363,UI.fonts.body,C.ink)
 UI.label('Guarda defensas y mejora tus zapatillas entre rondas.',203,392,UI.fonts.small,C.muted)
 UI.label('DESCUBRE PELIGROS NUEVOS SEGÚN TU DIFICULTAD',143,435,UI.fonts.small,C.muted)
 for i,name in ipairs({'spikes','drain','saw','shock','vortex','mallet','laser'}) do
  local x=161+(i-1)*113
  Sprites.draw(name,x,504,math.floor(Game.t*8)%8+1,62)
  UI.label(Hazards.names[i],x-52,540,UI.fonts.tiny,C.ink,'center',104)
 end
 addButton('tutorial',153,589,322,48,'PRACTICAR',C.gold,'play',true)
 addButton('back',518,589,328,48,'VOLVER',C.blue,'back',true)
end
local function shop()
 UI.panel(62,111,876,538,28)
 Icons.draw('bag',112,155,35,C.mintDark)
 UI.label('TIENDA',142,128,UI.fonts.title,C.navy)
 UI.label(Difficulty.get(Game.difficulty).short..'  ·  RONDA '..Game.round,380,139,UI.fonts.body,C.navy)
 UI.rect(734,132,174,41,13,{1,.95,.80})
 Icons.draw('coin',757,152,25,C.gold)
 UI.label(tostring(math.floor(Game.coins)),779,142,UI.fonts.medium,C.ink)
 local rewardText=Game.previousRound==0 and 'Elige las defensas para empezar.' or ('¡Ronda superada!  +'..Game.reward..' monedas')
 UI.rect(91,192,817,45,14,{.90,.98,.94})
 Icons.draw('trophy',120,215,26,C.gold)
 UI.label(rewardText,143,199,UI.fonts.small,C.ink)
 UI.label('Objetivo: '..Game.objectiveText()..' ('..Game.goal()..')',525,201,UI.fonts.small,C.muted)
 for i,item in ipairs(Objects.types) do
  local col=(i-1)%4
  local row=math.floor((i-1)/4)
  local x=94+col*205
  local y=253+row*127
  UI.rect(x,y+5,193,119,17,{.66,.78,.79})
  UI.rect(x,y,193,119,17,col%2==0 and {.93,.99,.96} or {.93,.97,1})
  Sprites.draw(item.sprite,x+47,y+39,math.floor(Game.t*9)%8+1,77)
  UI.label(item.name,x+83,y+17,UI.fonts.small,C.ink)
  UI.label('Tienes '..(Game.inventory[i] or 0),x+83,y+41,UI.fonts.tiny,C.muted)
  UI.rect(x+11,y+78,66,31,10,{1,.96,.82})
  Icons.draw('coin',x+27,y+94,17,C.gold)
  UI.label(tostring(item.cost),x+41,y+84,UI.fonts.small,C.navy)
  addButton('buy'..i,x+83,y+78,101,31,'COMPRAR',Game.coins>=item.cost and C.mint or C.blue,'plus',true)
 end
 local cost=Game.upgradeCost()
 UI.rect(106,516,788,37,12,{.89,.96,1})
 Icons.draw('arrows',125,534,22,C.blue)
 UI.label('Zapatillas '..Game.boots..'/3  ·  +20 de velocidad por nivel',151,523,UI.fonts.small,C.ink)
 addButton('upgrade',695,517,190,32,cost and ('MEJORAR $'..cost) or 'MÁXIMO',cost and C.blue or C.mint,'plus',true)
 addButton('home',105,566,231,55,'GUARDAR Y SALIR',C.blue,'save',true)
 addButton('round',526,561,378,63,'JUGAR RONDA '..Game.round,C.mint,'play')
end
local function inventoryBar()
 for i,item in ipairs(Objects.types) do
  local x=35+(i-1)*117
  local y=573
  local chosen=Objects.selected==i
  local count=Game.inventory[i] or 0
  UI.rect(x,y+5,109,67,14,chosen and C.mintDark or {.67,.78,.80})
  UI.rect(x,y,109,67,14,chosen and {.96,1,.87} or C.paper)
  if chosen then UI.outline(x+1,y+1,107,65,13,C.mintDark,2.5) end
  Sprites.draw(item.sprite,x+46,y+27,math.floor(Game.t*9)%8+1,55,count>0 and 1 or .42)
  UI.label(item.name,x+2,y+48,UI.fonts.tiny,count>0 and C.ink or C.muted,'center',105)
  UI.rect(x+78,y+5,25,22,7,count>0 and C.mint or {.69,.75,.76})
  UI.label(tostring(count),x+80,y+7,UI.fonts.small,C.paper,'center',21)
  UI.rect(x+6,y+5,17,19,6,chosen and C.mintDark or C.blue)
  UI.label(tostring(i),x+7,y+7,UI.fonts.tiny,C.paper,'center',15)
  buttons[#buttons+1]={id='item'..i,rect={x=x,y=y,w=109,h=67}}
 end
 local it=Objects.types[Objects.selected]
 UI.label('CLIC: '..it.desc,38,651,UI.fonts.small,C.ink)
 UI.label('ESPACIO: pulso  •  P: pausa',754,651,UI.fonts.small,C.muted)
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
 Art.pulse(Game.pulseX,Game.pulseY,Game.pulseVisual)
 Art.player(Game.player)
 love.graphics.pop()
 header()
 inventoryBar()
 UI.rect(53,118,265,37,13,{.94,.99,.95})
 Icons.draw('flag',76,136,19,C.mintDark)
 UI.label(Game.tutorial and ('PRÁCTICA '..Game.tutorialStep..'/4') or (Game.objectiveText()..': '..Game.progress()..'/'..Game.goal()),95,124,UI.fonts.small,C.navy)
 if Game.state=='playing' and not Game.tutorial then
  local tag=(Game.ball.guard or 0)>0 and 'BURBUJA '..math.ceil(Game.ball.guard)..'s' or ('RESCATES: '..Game.rescues)
  UI.rect(448,117,249,35,11,{.94,.99,.92})
  Icons.draw('star',470,135,18,C.gold)
  UI.label(tag,490,124,UI.fonts.small,C.navy)
 end
 if Game.state=='playing' then
  UI.rect(715,117,224,35,11,{.92,.97,1})
  Icons.draw('spark',737,134,18,C.blue)
  UI.label(Game.pulseCooldown<=0 and 'ESPACIO: PULSO LISTO' or ('PULSO: '..math.ceil(Game.pulseCooldown)..' s'),754,123,UI.fonts.small,C.navy)
 end
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
 if Game.tutorial and Game.state=='playing' then
  UI.panel(278,164,444,65,18)
  local steps={'','Muévete con WASD o flechas','Acércate y golpea la pelota','Usa ESPACIO cerca de la pelota','Pulsa 1 y haz clic para colocar el escudo'}
  UI.label(steps[Game.tutorialStep] or '',292,180,UI.fonts.small,C.navy,'center',414)
 end
 if Game.state=='pause' then
  buttons={}
  UI.color(C.navy,.34)
  love.graphics.rectangle('fill',0,0,W,H)
  UI.panel(234,146,532,418,28)
  Icons.draw('pause',500,206,48,C.blue)
  UI.headline('EN PAUSA',270,248,460,UI.fonts.title,C.navy)
  UI.label((Game.tutorial and 'Tutorial sin peligro' or ('Ranura '..Game.slot..' • Ronda '..Game.round)),292,302,UI.fonts.body,C.ink,'center',416)
  UI.label(Game.tutorial and 'Aprende sin perder vidas.' or 'Se guarda automáticamente cada 8 segundos.',292,332,UI.fonts.small,C.muted,'center',416)
  addButton('resume',314,377,372,56,'CONTINUAR',C.mint,'play')
  if not Game.tutorial then addButton('save',314,446,176,51,'GUARDAR',C.blue,'save',true) end
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
 if ciSmokeRequested() and love.filesystem.setIdentity then love.filesystem.setIdentity('balller_ci',true) end
 UI.load()
 Art.load()
 Save.load()
 Sound.load()
 Sound.enabled=Save.sound
 love.math.setRandomSeed(os.time())
 resize(love.graphics.getDimensions())
 if ciSmokeRequested() then
  ciFrames=0
  assert(Game.newRun(1),'No se pudo crear una partida de prueba')
 end
end
function love.resize(w,h) resize(w,h) end
function love.update(dt)
 dt=math.min(dt,.04)
 Game.update(dt)
 if ciFrames then
  ciFrames=ciFrames+1
  if ciFrames==12 then assert(Game.startRound(),'No inicia la ronda de prueba') end
  if ciFrames==40 then Game.togglePause() end
  if ciFrames==50 then Game.togglePause() end
  if ciFrames>=85 then love.event.quit(0) end
 end
 mouseX,mouseY=toLogical(love.mouse.getPosition())
end
function love.draw()
 love.graphics.push()
 love.graphics.translate(ox,oy)
 love.graphics.scale(scale,scale)
 buttons={}
 Art.background(Game.t)
 if Game.state=='menu' then header() menu()
 elseif Game.state=='difficulty' then header() difficultyScreen()
 elseif Game.state=='slots' then header() slotsScreen()
 elseif Game.state=='confirm' then header() slotsScreen() buttons={} confirmation()
 elseif Game.state=='help' then header() help()
 elseif Game.state=='tutorialDone' then
  header() UI.panel(205,162,590,372,26)
  Icons.draw('trophy',500,237,76,C.gold)
  UI.headline('¡YA SABES JUGAR!',248,279,505,UI.fonts.title,C.navy)
  UI.label('Aprendiste a moverte, golpear, rescatar y colocar defensas.',235,348,UI.fonts.small,C.ink,'center',530)
  addButton('toDifficulty',319,427,363,61,'ELEGIR DIFICULTAD',C.mint,'play')
 elseif Game.state=='shop' then header() shop()
 else inGame() end
 love.graphics.pop()
end
local function click(id)
 Sound.play('button')
 if id=='new' then slotIntent='new' Game.state='difficulty'
 elseif id=='continue' then slotIntent='load' Game.state='slots'
 elseif id=='toDifficulty' then Game.tutorial=false slotIntent='new' Game.state='difficulty'
 elseif id=='tutorial' then Game.startTutorial()
 elseif id=='back' then Game.state='menu'
 elseif id=='cancel' then Game.state='slots'
 elseif id=='deleteConfirm' then
  if Save.clearRun(confirmSlot) then Game.state='slots' else Game.state='slots' Game.notify('No se pudo borrar la partida') end
 elseif id:sub(1,6)=='delete' then
  confirmSlot=tonumber(id:sub(7)) or 1 Game.state='confirm'
 elseif id:sub(1,10)=='difficulty' then
  selectedDifficulty=tonumber(id:sub(11)) or 2 slotIntent='new' Game.state='slots'
 elseif id:sub(1,4)=='slot' then
  local slot=tonumber(id:sub(5))
  if Save.hasRun(slot) then
   if not Game.loadRun(slot) then Game.notify('No se pudo leer la partida') end
  else
   Game.newRun(slot,selectedDifficulty)
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
 elseif id=='replay' then slotIntent='new' Game.state='difficulty'
 elseif id=='sound' then Save.sound=not Save.sound Sound.enabled=Save.sound Save.store()
 elseif id=='upgrade' then Game.buyUpgrade()
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
  if Game.state=='help' or Game.state=='slots' or Game.state=='difficulty' or Game.state=='tutorialDone' then Game.backToMenu()
  elseif Game.state=='confirm' then Game.state='slots'
  elseif Game.state=='playing' or Game.state=='pause' then Game.togglePause() end
 elseif key=='return' or key=='kpenter' then
  if Game.state=='menu' then slotIntent='new' Game.state='difficulty'
  elseif Game.state=='shop' then Game.startRound()
  elseif Game.state=='tutorialDone' then slotIntent='new' Game.state='difficulty' end
 elseif Game.state=='playing' then
  if key=='space' then Game.pulse() return end
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
 if not Game.tutorial and (Game.state=='playing' or Game.state=='pause' or Game.state=='shop') then Game.saveRun() end
end
