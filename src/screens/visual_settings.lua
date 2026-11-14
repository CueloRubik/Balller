local UI=require('src.ui')
local C=require('src.theme')
local Assets=require('src.presentation.assets')
local Icons=require('src.icons')
local Save=require('src.save')
local Prefs=require('src.presentation.preferences')
local Themes=require('data.arena_themes')
local Hub=require('src.screens.hub')
local S={message='',ok=true}
local b
function S.bind(fn) b=fn end
function S.result(ok)
 S.ok=ok
 S.message=ok and 'Preferencia guardada' or 'No se pudo guardar la preferencia'
end
function S.draw()
 b('back',36,23,137,52,'Volver',C.blue,'back',true)
 UI.label('Ajustes',185,19,UI.fonts.title,C.ink)
 UI.label('Sonido, práctica y aspecto del juego.',187,67,UI.fonts.small,C.muted)
 UI.panel(60,108,880,88)
 b('sound',80,128,258,49,Save.sound and 'Sonido activado' or 'Sonido apagado',C.blue,Save.sound and 'sound' or 'mute',true)
 b('help',366,128,246,49,'Guía',C.mint,'help',true)
 b('tutorial',641,128,278,49,'Practicar',C.gold,'play',true)
 UI.label('Aspecto de cancha',66,214,UI.fonts.medium,C.ink)
 UI.label('Mismas reglas y límites en los tres diseños.',383,220,UI.fonts.small,C.muted)
 for i,theme in ipairs(Themes.list) do
  local x,y=60+(i-1)*300,252
  UI.panel(x,y,280,240)
  if not Assets.image(theme.image,x+14,y+14,252,119) then
   UI.rect(x+14,y+14,252,119,14,theme.color)
   Icons.draw('flag',x+140,y+72,42,C.paper)
  end
  UI.label(theme.name,x+15,y+145,UI.fonts.medium,C.ink,'center',250)
  b('arena:'..theme.id,x+23,y+187,234,40,Prefs.arena==theme.id and 'Seleccionada' or 'Usar cancha',theme.color,'check',true,{selected=Prefs.arena==theme.id})
 end
 b('reduced',62,514,425,50,Prefs.reduced and 'Estímulos reducidos' or 'Reducir estímulos',C.lilac,Prefs.reduced and 'check' or 'spark',true,{selected=Prefs.reduced})
 UI.label(S.message~='' and S.message or 'Suaviza sacudidas y efectos decorativos.',510,529,UI.fonts.small,S.ok and C.muted or C.red,'left',422)
 Hub.nav('settings')
end
return S
