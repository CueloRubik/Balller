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
local VisualSettings=require('src.screens.visual_settings')
local Prefs=require('src.presentation.preferences')
local HUD=require('src.presentation.hud_layout')
local Flow=require('src.presentation.run_flow')
local SlotScreens=require('src.screens.run_slots')
local SessionHelp=require('src.screens.session_help')
local Economy=require('src.economy.rules')
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
function S.bind(fn,register) b=fn hitbox=register Hub.bind(fn) VisualSettings.bind(fn) SlotScreens.bind(fn) SessionHelp.bind(fn) end
S.hub=Hub
S.store=Hub.store
S.confirmPurchase=Hub.confirmPurchase
S.objectInfo=SessionHelp.objectInfo
S.exitError=SessionHelp.exitError
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
 local occupied=0
 for slot=1,3 do if Save.hasRun(slot) then occupied=occupied+1 end end
 button(occupied<3 and 'new' or 'continue',664,276,248,78,occupied<3 and 'Nueva partida' or 'Ver partidas',C.mint,'play',false,{selected=true})
 button('continue',665,370,245,61,'Continuar',C.blue,'save',true,{disabled=occupied==0})
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
function S.slots() SlotScreens.draw() end
function S.confirm(slot) SlotScreens.confirm(slot) end
function S.recovery(data) SlotScreens.recovery(data) end

function S.collection() Hub.collection() end
function S.achievements() Hub.challenges() end

function S.settings() VisualSettings.draw() end

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
 Icons.draw(Game.saveError and 'warning' or 'flag',104,138,29,Game.saveError and C.red or C.mintDark)
 if not Game.saveError then label(Game.roundMode().name,132,123,UI.fonts.medium,navy) end
 if Game.saveError then
  UI.singleLine(Game.saveError,132,129,775,UI.fonts.small,C.red)
 elseif Game.previousRound>0 then
  label('+'..Game.reward..' monedas'..(Game.gemsReward>0 and ' · +'..Game.gemsReward..' gemas' or ''),404,129,UI.fonts.small,C.mintDark)
  button('lastReward',742,118,178,40,'Ver premio',C.gold,'trophy',true)
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
  button('info'..i,x+162,y+52,34,34,'',C.blue,'help',true)
  local disabled=not Economy.canBuy(Game,i)
  button('buy'..i,x+14,y+99,181,39,'Comprar '..item.cost,C.mint,'coin',true,{disabled=disabled})
 end
 local cost=Game.upgradeCost()
 UI.rect(87,524,826,41,15,{.86,.95,1})
 Icons.draw('arrows',112,545,26,C.blue)
 label('ZAPATILLAS  '..Game.boots..'/'..#Economy.config.upgrades.costs,143,532,UI.fonts.small,navy)
 label('+'..(Game.boots*Economy.config.upgrades.speedStep)..' velocidad',345,532,UI.fonts.small,C.muted)
 button('upgrade',697,524,199,37,cost and ('SUBIR  '..cost) or 'COMPLETO',C.blue,'upgrade',true,{disabled=not cost or Game.coins<cost})
 button('home',80,587,230,65,'Guardar y salir',C.blue,'save',true)
 button('round',533,584,390,69,'JUGAR RONDA '..Game.round,C.mint,'play')
end
local itemPage=1
function S.setPage(page) itemPage=math.max(1,math.min(2,page)) end
function S.page() return itemPage end
local function hudStat(x,w,icon,name,value)
 Icons.draw(icon,x+23,38,27,C.paper)
 label(name,x+46,17,UI.fonts.tiny,C.muted)
 local text=tostring(value)
 local font=UI.fonts.medium
 if font:getWidth(text)>w-58 then font=UI.fonts.small end
 UI.singleLine(text,x+46,35,w-57,font,navy)
end
function S.game()
 Art.field()
 love.graphics.push()
 if Game.shake>0 and not Prefs.reduced then love.graphics.translate(math.sin(Game.t*79)*Game.shake*.5,math.cos(Game.t*91)*Game.shake*.5) end
 Art.hazards(Hazards.list,Game.t)
 Collectibles.draw(Game.t)
 Art.objects(Objects.list,Game.t)
 if not Prefs.reduced then FX.draw() Feedback.draw() end
 Art.ball(Game.ball)
 Art.pulse(Game.pulseX,Game.pulseY,Game.pulseVisual)
 Art.player(Game.player)
 love.graphics.pop()
 local header=HUD.header
 UI.panel(header.x,header.y,header.w,header.h)
 label('BALLLER',49,15,UI.fonts.medium,navy)
 label(Prefs.theme().name,50,46,UI.fonts.tiny,C.muted)
 hudStat(205,154,'star','Puntos',math.floor(Game.score))
 hudStat(369,128,'flag',Game.tutorial and 'Paso' or 'Ronda',Game.tutorial and (Game.tutorialStep..'/4') or Game.round)
 hudStat(506,142,'clock','Tiempo',Game.tutorial and '--' or (math.ceil(Game.roundLeft)..' s'))
 hudStat(656,136,'coin','Monedas',math.floor(Game.coins))
 button('pause',871,16,83,46,'',C.blue,'pause',true)
 local objective=HUD.objective
 Icons.draw(Game.tutorial and 'help' or 'objective',objective.x+14,objective.y+15,22,C.mintDark)
 local objectiveText=Game.tutorial and HUD.tutorialSteps[Game.tutorialStep] or (Game.objectiveText()..' '..Game.progress()..'/'..Game.goal())
 UI.singleLine(objectiveText or '',objective.x+34,objective.y+2,objective.w-40,UI.fonts.small,navy)
 UI.progress(objective.x+34,objective.y+27,objective.w-42,5,Game.tutorial and Game.tutorialStep/4 or Game.progress()/Game.goal(),0)
 local rescue=HUD.rescues
 Icons.draw('shield',rescue.x+13,80,23,C.gold)
 label(Game.tutorial and 'Práctica sin peligro' or ('Rescates: '..Game.rescues),rescue.x+35,71,UI.fonts.small,navy)
 for offset=1,4 do
  local i=(itemPage-1)*4+offset
  local item=Objects.types[i]
  local x=91+(offset-1)*152
  local chosen=Objects.selected==i
  if not Assets.surface(5,chosen and 3 or 0,x,563,141,88) then
   bgCard(x,563,141,88,cream,17)
   if chosen then UI.outline(x+2,565,137,83,15,C.mintDark,3) end
  end
  Sprites.draw(item.sprite,x+44,594,math.floor(Game.t*9)%8+1,65,(Game.inventory[i] or 0)>0 and 1 or .45)
  label('x'..(Game.inventory[i] or 0),x+83,577,UI.fonts.medium,navy)
  label(item.name,x+13,617,UI.fonts.tiny,ink,'center',117)
  label(tostring(i),x+11,570,UI.fonts.tiny,C.muted)
  hitbox('item'..i,x,565,141,85)
 end
 button('previousPage',41,586,44,51,'',C.blue,'back',true)
 button('nextPage',702,586,44,51,'',C.blue,'next',true)
 label(itemPage..'/2',709,647,UI.fonts.tiny,navy)
 local ready=Game.pulseCooldown<=0
 local pulse=HUD.pulse
 button('pulse',pulse.x,pulse.y,pulse.w,pulse.h,ready and 'PULSO' or math.ceil(Game.pulseCooldown)..' s',ready and C.mint or C.lilac,'spark',true,{disabled=not ready})
 UI.progress(782,647,160,8,1-Game.pulseCooldown/10,1)
 label('Espacio',799,659,UI.fonts.tiny,C.muted,'center',128)
 local status=HUD.status
 UI.singleLine(Game.saveError or (Game.noticeT>0 and Game.notice or '1-8: defensa · Clic: colocar'),status.x,status.y,status.w,UI.fonts.tiny,Game.saveError and C.red or (Game.noticeT>0 and navy or C.muted))
end

function S.rewardPending()
 UI.color(C.navy,.65) love.graphics.rectangle('fill',0,0,1000,680)
 bgCard(183,150,634,372,cream,29)
 Icons.draw('save',500,199,52,C.blue)
 UI.headline(Game.rewardRecoveryError=='invalid' and 'Registro dañado' or (Progress.purchasePending() and 'Compra pendiente' or 'Premios pendientes'),216,243,568,UI.fonts.title,navy)
 label(Game.rewardRecoveryError=='invalid' and 'Los archivos se conservan para revisar su recuperación.' or (Progress.purchasePending() and 'La compra no se aplicó. Se revisará su registro.' or 'Se conservará el registro para completar el guardado.'),223,304,UI.fonts.small,C.muted,'center',554)
 label('Reintenta antes de comprar o empezar otra ronda.',223,340,UI.fonts.small,C.muted,'center',554)
 button('rewardClose',222,426,190,58,'Cerrar',C.blue,'back',true)
 button('rewardRetry',440,426,337,58,'Reintentar guardado',C.mint,'save',true)
end
function S.roundResults()
 local d=Results.data
 if not d then S.shop() return end
 bgCard(177,98,646,478,cream,29)
 Icons.draw('trophy',500,154,68,C.gold)
 UI.headline('¡Ronda '..d.round..' superada!',218,203,564,UI.fonts.title,navy)
 label(Game.saveError and 'Premios pendientes de guardar' or 'Premios ya añadidos a tus saldos',238,259,UI.fonts.small,Game.saveError and C.red or C.muted,'center',524)
 chip(238,305,240,'coin','MONEDAS GANADAS','+'..d.coins,C.gold)
 chip(518,305,240,'gem','GEMAS AL CERRAR','+'..d.gems,C.lilac)
 if d.detail then
  local r=d.detail
  label('Base '..r.base..' + golpes '..r.skill..' + objetivo '..r.objective,224,385,UI.fonts.small,navy,'center',552)
  label('Multiplicador ×'..string.format('%.2f',r.multiplier)..' · '..d.score..' puntos',224,410,UI.fonts.small,C.muted,'center',552)
 else label(d.hits..' golpes · '..d.score..' puntos',250,387,UI.fonts.body,navy,'center',500) end
 label(d.detail and d.coins<math.floor((d.detail.base+d.detail.skill+d.detail.objective)*d.detail.multiplier+.5) and 'Se aplicó el límite de monedas del saldo.' or ('Prepara tus defensas para la ronda '..d.nextRound),240,447,UI.fonts.small,C.muted,'center',520)
 button('resultsHome',224,496,208,56,'Guardar y salir',C.blue,'save',true)
 button('resultsContinue',463,493,309,62,'Ir al taller',C.mint,'bag')
end
function S.pause() SessionHelp.pause() end

function S.over()
 UI.color(C.navy,.47) love.graphics.rectangle('fill',0,0,1000,680)
 bgCard(221,141,558,442,cream,29)
 Icons.draw('trophy',500,205,63,C.gold)
 UI.headline('FIN DE PARTIDA',258,254,485,UI.fonts.title,navy)
 label(Game.reason,266,311,UI.fonts.small,C.muted,'center',468)
 chip(300,356,179,'star','PUNTOS',math.floor(Game.score),C.gold)
 chip(510,356,185,'flag','RONDAS',math.max(0,Game.round-1),C.blue)
 if Game.saveError then UI.singleLine(Game.saveError,266,420,468,UI.fonts.tiny,C.red) end
 button('replay',294,457,195,63,'OTRA PARTIDA',C.mint,'play',true)
 button('home',504,457,191,63,'MENÚ',C.blue,'home',true)
end
function S.tutorialDone() SessionHelp.tutorialDone() end
return S
