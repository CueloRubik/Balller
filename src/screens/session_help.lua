local UI=require('src.ui')
local C=require('src.theme')
local Icons=require('src.icons')
local Sprites=require('src.sprites')
local Objects=require('src.objects')
local Help=require('data.object_help')
local G=require('src.game')
local Save=require('src.save')
local Exit=require('src.presentation.exit_flow')
local S={}
local b
local function text(s,x,y,font,color,align,w) UI.label(s,x,y,font or UI.fonts.body,color or C.ink,align,w) end
local function button(id,x,y,w,h,label,color,icon,options) b(id,x,y,w,h,label,color,icon,true,options) end
local function overlay() UI.color(C.navy,.6) love.graphics.rectangle('fill',0,0,1000,680) end
function S.bind(fn) b=fn end
function S.exitError()
 overlay()
 UI.panel(220,155,560,433)
 Icons.draw('warning',500,210,60,C.red)
 text('No se ha cerrado el juego',247,261,UI.fonts.title,C.ink,'center',506)
 text(Exit.error,250,324,UI.fonts.small,C.red,'center',500)
 text('Los cambios pendientes siguen en esta sesión.',250,359,UI.fonts.small,C.muted,'center',500)
 button('exitCancel',270,436,213,60,'Seguir aquí',C.blue,'back')
 button('exitRetry',517,436,213,60,'Reintentar',C.mint,'save')
 button('exitDiscard',350,517,300,50,'Salir sin guardar',C.red,'warning')
end
function S.objectInfo(index)
 local item=Objects.types[index]
 local help=Help[index]
 if not item or not help then return end
 overlay()
 UI.panel(200,101,600,493)
 text(item.name,230,122,UI.fonts.title,C.ink,'center',540)
 Sprites.draw(item.sprite,303,251,math.floor(G.t*8)%8+1,137)
 text('Precio: '..item.cost..' monedas',409,195,UI.fonts.body)
 text('Duración: '..item.duration..' s',409,232,UI.fonts.small,C.muted)
 text('En mochila: '..(G.inventory[index] or 0)..' / 5',409,267,UI.fonts.small,C.muted)
 text('Saldo: '..G.coins..' monedas',409,299,UI.fonts.small,C.muted)
 text(help.effect,247,326,UI.fonts.body,C.ink,'left',506)
 text(help.placement,247,394,UI.fonts.small,C.muted,'left',506)
 local total=0
 for _,n in ipairs(G.inventory) do total=total+n end
 if G.saveError then UI.singleLine(G.saveError,247,461,506,UI.fonts.tiny,C.red)
 else text('Mochila: '..total..' / 12',247,461,UI.fonts.tiny,C.muted) end
 button('infoClose',245,511,221,57,'Cerrar',C.blue,'back')
 button('infoBuy',501,511,254,57,'Comprar '..item.cost,C.mint,'coin',{disabled=G.coins<item.cost or G.inventory[index]>=5 or total>=12})
end
function S.pause()
 overlay()
 UI.panel(245,104,510,480)
 Icons.draw('pause',500,154,50,C.blue)
 text(G.tutorial and 'Práctica en pausa' or 'En pausa',277,197,UI.fonts.title,C.ink,'center',446)
 text(G.tutorial and ('Paso '..G.tutorialStep..' de 4') or ('Ronda '..G.round..' · Ranura '..G.slot),277,251,UI.fonts.small,C.muted,'center',446)
 local status=G.saveError or ((G.saveNoticeT or 0)>0 and 'Partida y progreso guardados.' or (G.tutorial and 'La práctica no usa ranuras ni da premios.' or 'El tiempo está detenido.'))
 UI.singleLine(status,277,291,446,UI.fonts.small,G.saveError and C.red or C.muted)
 button('resume',314,333,372,56,'Continuar',C.mint,'play')
 if G.tutorial then
  button('repeatTutorial',279,411,213,52,'Repetir',C.blue,'arrows')
  button('home',508,411,213,52,'Omitir',C.lilac,'home')
 else
  button('save',279,411,213,52,'Guardar',C.blue,'save')
  button('home',508,411,213,52,'Guardar y salir',C.lilac,'home')
 end
 button('sound',314,489,372,50,Save.sound and 'Sonido activado' or 'Sonido apagado',C.blue,Save.sound and 'sound' or 'mute')
end
function S.tutorialDone()
 UI.panel(205,104,590,482)
 Icons.draw('trophy',500,169,71,C.gold)
 text('¡Práctica completada!',230,228,UI.fonts.title,C.ink,'center',540)
 text('Ya sabes moverte, golpear, rescatar y colocar defensas.',235,292,UI.fonts.small,C.muted,'center',530)
 text(G.tutorialSaveFailed and 'Falta guardar que completaste la práctica.' or 'No se usaron ranuras ni se ganaron premios.',235,331,UI.fonts.small,G.tutorialSaveFailed and C.red or C.muted,'center',530)
 button('toDifficulty',318,383,364,63,G.tutorialSaveFailed and 'Guardar y seguir' or 'Crear partida',C.mint,'play')
 button('repeatTutorial',276,477,212,52,'Repetir',C.blue,'arrows')
 button('home',512,477,212,52,'Menú',C.lilac,'home')
end
return S
