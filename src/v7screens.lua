local C=require('src.theme')
local UI=require('src.ui')
local Icons=require('src.icons')
local Art=require('src.art')
local Sprites=require('src.sprites')
local Game=require('src.game')
local Save=require('src.save')
local Progress=require('src.progression')
local Difficulty=require('src.difficulty')
local Objects=require('src.objects')
local Hazards=require('src.hazards')
local Collectibles=require('src.collectibles')
local FX=require('src.particles')
local Feedback=require('src.feedback')
local Assets=require('src.presentation.assets')
local Hub=require('src.screens.hub')
local Results=require('src.presentation.round_results')
local S={}
local b,hitbox
local sky={.83,.96,1}
local cream={1,.98,.89}
local ink=C.ink
local navy=C.navy
local function label(text,x,y,font,col,align,w) UI.label(text,x,y,font or UI.fonts.body,col or ink,align,w) end
local function bgCard(x,y,w,h,col,r)
 local row=0
 if col and col[2]>.94 and col[1]<.95 then row=1
 elseif col and col[3]>.98 then row=2
 elseif col and col[1]>.98 and col[3]<.94 then row=3 end
 if Assets.surface(6,row,x,y,w,h) then return end
 UI.rect(x,y+8,w,h,r or 23,{.42,.68,.67})
 UI.rect(x,y,w,h,r or 23,col or C.paper)
 UI.outline(x+2,y+2,w-4,h-4,r or 23,{1,1,1},1.8)
end
local function button(id,x,y,w,h,text,color,icon,compact,options)
 b(id,x,y,w,h,text,color,icon,compact,options)
end
local function back() button('back',36,23,137,52,'VOLVER',C.blue,'back',true) end
local function top(title,sub)
 back()
 label(title,185,19,UI.fonts.title,navy)
 if sub then label(sub,187,67,UI.fonts.small,C.muted) end
end
local function chip(x,y,w,icon,name,value,color)
 UI.rect(x,y+4,w,46,17,{.56,.76,.75})
 UI.rect(x,y,w,46,17,C.paper)
 UI.rect(x+7,y+7,32,32,11,color)
 Icons.draw(icon,x+23,y+23,20,C.paper)
 label(name,x+48,y+4,UI.fonts.tiny,C.muted)
 label(tostring(value),x+48,y+21,UI.fonts.medium,navy)
end
local function cornerCoins()
 chip(736,18,104,'gem','GEMAS',Progress.gems,C.lilac)
 chip(855,18,111,'trophy','RÉCORD',math.floor(Save.best),C.gold)
end
function S.bind(fn,register) b=fn hitbox=register Hub.bind(fn) end
S.hub=Hub
S.store=Hub.store
S.confirmPurchase=Hub.confirmPurchase
function S.home()
 label('BALLLER',56,23,UI.fonts.big,navy)
 label('Una pelota. Mil formas de salvarla.',60,105,UI.fonts.body,C.mintDark)
 cornerCoins()
 if not Assets.image('home-court',40,153,588,392) then bgCard(57,156,555,378,{.77,.93,.65},33) end
 Art.mascot(319,346,1.55,Game.t)
 Icons.draw('spark',104,230,38,C.gold)
 Icons.draw('shield',534,258,46,C.mint)
 UI.panel(145,469,342,50)
 label('Protege · Rebota · Sobrevive',164,480,UI.fonts.small,navy)
 bgCard(636,157,306,378,cream,29)
 Icons.draw('flag',788,193,34,C.mintDark)
 label('¿Otra ronda?',658,219,UI.fonts.medium,navy,'center',264)
 button('new',664,276,248,78,'JUGAR',C.mint,'play',false,{selected=true})
 button('continue',665,370,245,61,'Mis partidas',C.blue,'save',true)
 button('tutorial',664,449,245,57,'Practicar',C.gold,'help',true)
 Hub.nav('menu')
end
function S.difficulties()
 top('ELIGE TU NIVEL','Puedes cambiarlo al crear otra partida.')
 local descriptions={
  'Avisos amplios · 2 rescates',
  'Un reto equilibrado · 1 rescate',
  'Más peligros y menos avisos',
  'El desafío más rápido de Balller'
 }
 for i,mode in ipairs(Difficulty.list) do
  local x=69+((i-1)%2)*456
  local y=145+math.floor((i-1)/2)*214
  local colors={{.88,.99,.91},{.88,.96,1},{1,.95,.84},{1,.88,.93}}
  bgCard(x,y,435,182,colors[i],24)
  UI.rect(x+16,y+21,88,87,24,mode.color)
  Icons.draw(({'star','shield','spark','trophy'})[i]=='shield' and 'check' or ({'star','check','spark','trophy'})[i],x+60,y+63,45,C.paper)
  label(mode.short,x+128,y+20,UI.fonts.title,navy)
  label(descriptions[i],x+126,y+72,UI.fonts.small,C.muted,'left',275)
  label('Recompensa '..math.floor(mode.bonus*100)..'%',x+127,y+103,UI.fonts.small,C.mintDark)
  button('difficulty'..i,x+128,y+131,275,42,'ELEGIR',mode.color,'play',true)
 end
end
function S.slots()
 top('TUS PARTIDAS','Guarda, continúa o empieza una aventura nueva.')
 for i=1,3 do
  local y=140+(i-1)*156
  bgCard(78,y,843,139,i%2==0 and {.89,.96,1} or {.9,.98,.9},23)
  UI.rect(95,y+20,87,92,25,i%2==0 and C.blue or C.mint)
  Icons.draw('flag',139,y+65,45,C.paper)
  label('PARTIDA '..i,204,y+14,UI.fonts.medium,navy)
  local info=Save.slotInfo(i)
  if info then
   label('Ronda '..info.round..'    '..Difficulty.get(info.difficulty).short,206,y+49,UI.fonts.body,ink)
   label(math.floor(info.score)..' puntos · '..math.floor(info.coins)..' monedas',206,y+86,UI.fonts.small,C.muted)
   button('slot'..i,588,y+39,168,57,'SEGUIR',C.mint,'play',true)
   button('delete'..i,767,y+39,130,57,'BORRAR',C.red,'delete',true)
  elseif Save.hasRun(i) then
   label('El guardado está dañado',205,y+72,UI.fonts.body,C.red)
   button('delete'..i,755,y+39,141,57,'BORRAR',C.red,'delete',true)
  else
   label('Espacio disponible',205,y+69,UI.fonts.body,C.muted)
   button('slot'..i,673,y+39,222,60,'CREAR',C.mint,'plus',true)
  end
 end
end
function S.confirm(slot)
 UI.color(C.navy,.45) love.graphics.rectangle('fill',0,0,1000,680)
 bgCard(251,184,498,310,cream,29)
 Icons.draw('warning',500,238,58,C.red)
 UI.headline('¿BORRAR PARTIDA?',280,280,440,UI.fonts.title,navy)
 label('Se perderá el progreso de la ranura '..slot,291,353,UI.fonts.body,C.muted,'center',418)
 button('cancel',296,412,194,57,'CANCELAR',C.blue,'back',true)
 button('deleteConfirm',509,412,192,57,'BORRAR',C.red,'delete',true)
end
function S.collection() Hub.collection() end
function S.achievements() Hub.challenges() end

function S.settings()
 top('AJUSTES','Opciones sencillas para jugar a tu manera.')
 bgCard(205,155,592,400,cream,28)
 UI.rect(242,197,516,91,20,{.88,.96,1})
 Icons.draw(Save.sound and 'sound' or 'mute',287,241,39,C.blue)
 label('Sonido',326,223,UI.fonts.medium,navy)
 button('sound',545,218,190,53,Save.sound and 'ACTIVADOS' or 'APAGADOS',C.blue,Save.sound and 'sound' or 'mute',true)
 UI.rect(242,311,516,91,20,{.91,.99,.92})
 Icons.draw('help',286,357,37,C.mintDark)
 label('Guía de juego',324,341,UI.fonts.medium,navy)
 button('help',557,333,178,52,'GUÍA',C.mint,'help',true)
 UI.rect(242,428,516,94,20,{1,.95,.84})
 Icons.draw('star',286,473,38,C.gold)
 label('Práctica',324,459,UI.fonts.medium,navy)
 button('tutorial',556,451,179,52,'PRACTICAR',C.gold,'play',true)
 Hub.nav('settings')
end
function S.help()
 top('CÓMO JUGAR','Cuatro reglas y listo.')
 local rows={
  {'arrows','MUEVE','WASD o flechas. Toca la pelota para desviarla.',C.mint},
  {'clock','SOBREVIVE','Aguanta hasta que termine el cronómetro.',C.blue},
  {'bag','PREPÁRATE','Compra defensas antes de cada ronda.',C.gold},
  {'spark','RESCATA','Espacio activa el pulso. Requiere recarga.',C.lilac}
 }
 for i,r in ipairs(rows) do
  local y=139+(i-1)*114
  bgCard(127,y,745,96,i%2==0 and {.9,.97,1} or cream,20)
  UI.rect(143,y+15,64,65,18,r[4])
  Icons.draw(r[1],175,y+47,36,C.paper)
  label(r[2],227,y+10,UI.fonts.medium,navy)
  label(r[3],228,y+48,UI.fonts.small,C.muted)
 end
end
function S.shop()
 top('Taller de partida','Prepara tu mochila para la ronda '..Game.round)
 chip(769,25,188,'coin','MONEDAS',math.floor(Game.coins),C.gold)
 UI.rect(70,110,862,57,19,{.86,.96,.86})
 Icons.draw('flag',104,138,29,C.mintDark)
 label(Game.roundMode().name,132,123,UI.fonts.medium,navy)
 if Game.previousRound>0 then
  label('+'..Game.reward..' monedas'..(Game.gemsReward>0 and ' · +'..Game.gemsReward..' gemas' or ''),404,129,UI.fonts.small,C.mintDark)
 else
  label(Game.roundMode().desc,415,128,UI.fonts.small,C.muted)
 end
 for i,item in ipairs(Objects.types) do
  local x=69+((i-1)%4)*221
  local y=185+math.floor((i-1)/4)*163
  local bg=(i%2==0) and {.9,.96,1} or cream
  bgCard(x,y,209,147,bg,19)
  Sprites.draw(item.sprite,x+58,y+52,math.floor(Game.t*8)%8+1,91)
  label(item.name,x+100,y+15,UI.fonts.small,navy)
  label('x'..(Game.inventory[i] or 0),x+110,y+43,UI.fonts.medium,C.mintDark)
  local total=0
  for _,n in ipairs(Game.inventory) do total=total+n end
  local disabled=Game.coins<item.cost or (Game.inventory[i] or 0)>=5 or total>=12
  button('buy'..i,x+14,y+99,181,39,'Comprar '..item.cost,C.mint,'coin',true,{disabled=disabled})
 end
 local cost=Game.upgradeCost()
 UI.rect(87,524,826,41,15,{.86,.95,1})
 Icons.draw('arrows',112,545,26,C.blue)
 label('ZAPATILLAS  '..Game.boots..'/3',143,532,UI.fonts.small,navy)
 label('+'..(Game.boots*20)..' velocidad',345,532,UI.fonts.small,C.muted)
 button('upgrade',697,524,199,37,cost and ('SUBIR  '..cost) or 'COMPLETO',C.blue,'upgrade',true,{disabled=not cost or Game.coins<cost})
 button('home',80,587,230,65,'GUARDAR',C.blue,'save',true)
 button('round',533,584,390,69,'JUGAR RONDA '..Game.round,C.mint,'play')
end
local itemPage=1
function S.setPage(page) itemPage=math.max(1,math.min(2,page)) end
function S.page() return itemPage end
function S.game()
 Art.field()
 love.graphics.push()
 if Game.shake>0 then love.graphics.translate((love.math.random()-.5)*Game.shake,(love.math.random()-.5)*Game.shake) end
 Art.hazards(Hazards.list,Game.t)
 Collectibles.draw(Game.t)
 Art.objects(Objects.list,Game.t)
 FX.draw() Feedback.draw()
 Art.ball(Game.ball)
 Art.pulse(Game.pulseX,Game.pulseY,Game.pulseVisual)
 Art.player(Game.player)
 love.graphics.pop()
 UI.rect(30,12,940,82,24,cream)
 label('BALLLER',51,22,UI.fonts.medium,navy)
 chip(205,27,154,'star','PUNTOS',math.floor(Game.score),C.gold)
 chip(369,27,128,'flag','RONDA',Game.round,C.mint)
 chip(506,27,142,'clock','TIEMPO',math.ceil(Game.roundLeft)..' s',C.blue)
 chip(656,27,136,'coin','MONEDAS',math.floor(Game.coins),C.gold)
 button('pause',871,26,83,49,'',C.blue,'pause',true)
 UI.rect(48,114,312,44,14,cream)
 Icons.draw('flag',72,136,20,C.mintDark)
 label((Game.tutorial and 'PRÁCTICA '..Game.tutorialStep..'/4') or (Game.objectiveText()..' '..Game.progress()..'/'..Game.goal()),91,126,UI.fonts.small,navy)
 UI.progress(91,151,252,6,Game.progress()/Game.goal(),0)
 UI.rect(729,114,219,44,14,{.91,.96,1})
 Icons.draw('star',750,134,20,C.gold)
 label('RESCATES: '..Game.rescues,767,125,UI.fonts.small,navy)
 for offset=1,4 do
  local i=(itemPage-1)*4+offset
  local item=Objects.types[i]
  local x=91+(offset-1)*152
  local chosen=Objects.selected==i
  local c=chosen and {.92,1,.82} or cream
  bgCard(x,563,141,88,c,17)
  if chosen then UI.outline(x+2,565,137,83,15,C.mintDark,3) end
  Sprites.draw(item.sprite,x+44,594,math.floor(Game.t*9)%8+1,65,(Game.inventory[i] or 0)>0 and 1 or .45)
  label('x'..(Game.inventory[i] or 0),x+83,577,UI.fonts.medium,navy)
  label(item.name,x+13,617,UI.fonts.tiny,ink,'center',117)
  hitbox('item'..i,x,565,141,85)
 end
 button('previousPage',41,586,44,51,'',C.blue,'back',true)
 button('nextPage',702,586,44,51,'',C.blue,'next',true)
 label(itemPage..'/2',754,652,UI.fonts.small,navy)
 local ready=Game.pulseCooldown<=0
 button('pulse',773,571,179,71,ready and 'PULSO' or math.ceil(Game.pulseCooldown)..' s',ready and C.mint or C.lilac,'spark',true,{disabled=not ready})
 UI.progress(782,647,160,8,1-Game.pulseCooldown/10,1)
 if Game.noticeT>0 then
  bgCard(305,175,390,47,cream,14)
  label(Game.notice,312,189,UI.fonts.small,navy,'center',376)
 end
 if Game.tutorial then
  local steps={'','Muévete con WASD o flechas','Toca la pelota','Espacio para usar el pulso','Pulsa 1 y coloca una defensa'}
  bgCard(274,236,452,65,{.93,1,.83},18)
  label(steps[Game.tutorialStep] or '',289,258,UI.fonts.small,navy,'center',424)
 end
end
function S.roundResults()
 local d=Results.data
 if not d then S.shop() return end
 bgCard(177,98,646,478,cream,29)
 Icons.draw('trophy',500,154,68,C.gold)
 UI.headline('¡Ronda '..d.round..' superada!',218,203,564,UI.fonts.title,navy)
 label('Premios ya añadidos a tus saldos',238,259,UI.fonts.small,C.muted,'center',524)
 chip(238,305,240,'coin','MONEDAS GANADAS','+'..d.coins,C.gold)
 chip(518,305,240,'gem','GEMAS AL CERRAR','+'..d.gems,C.lilac)
 label(d.hits..' golpes · '..d.score..' puntos',250,387,UI.fonts.body,navy,'center',500)
 label('Prepara tus defensas para la ronda '..d.nextRound,240,428,UI.fonts.small,C.muted,'center',520)
 button('resultsHome',224,496,208,56,'Guardar y salir',C.blue,'save',true)
 button('resultsContinue',463,493,309,62,'Ir al taller',C.mint,'bag')
end
function S.pause()
 UI.color(C.navy,.43) love.graphics.rectangle('fill',0,0,1000,680)
 bgCard(245,147,510,404,cream,29)
 Icons.draw('pause',500,203,56,C.blue)
 UI.headline('EN PAUSA',283,252,438,UI.fonts.title,navy)
 label(Game.tutorial and 'Práctica sin peligro' or ('Ronda '..Game.round..' · Ranura '..Game.slot),275,324,UI.fonts.body,C.muted,'center',450)
 button('resume',314,373,372,59,'CONTINUAR',C.mint,'play')
 if not Game.tutorial then button('save',294,451,193,55,'GUARDAR',C.blue,'save',true) end
 button('home',Game.tutorial and 314 or 511,451,Game.tutorial and 372 or 193,55,'SALIR',C.lilac,'home',true)
end
function S.over()
 UI.color(C.navy,.47) love.graphics.rectangle('fill',0,0,1000,680)
 bgCard(221,141,558,442,cream,29)
 Icons.draw('trophy',500,205,63,C.gold)
 UI.headline('FIN DE PARTIDA',258,254,485,UI.fonts.title,navy)
 label(Game.reason,266,311,UI.fonts.small,C.muted,'center',468)
 chip(300,356,179,'star','PUNTOS',math.floor(Game.score),C.gold)
 chip(510,356,185,'flag','RONDAS',math.max(0,Game.round-1),C.blue)
 button('replay',294,457,195,63,'OTRA PARTIDA',C.mint,'play',true)
 button('home',504,457,191,63,'MENÚ',C.blue,'home',true)
end
function S.tutorialDone()
 bgCard(217,159,566,387,cream,25)
 Icons.draw('trophy',500,219,76,C.gold)
 UI.headline('¡LISTO PARA JUGAR!',239,277,522,UI.fonts.title,navy)
 label('Ya sabes golpear, rescatar y colocar defensas.',235,357,UI.fonts.small,C.muted,'center',530)
 button('toDifficulty',318,429,364,70,'¡VAMOS!',C.mint,'play')
end
return S
