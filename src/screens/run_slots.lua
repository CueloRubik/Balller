local UI=require('src.ui')
local C=require('src.theme')
local Icons=require('src.icons')
local Sprites=require('src.sprites')
local Progress=require('src.progression')
local Save=require('src.save')
local Difficulty=require('src.difficulty')
local Flow=require('src.presentation.run_flow')
local S={}
local b
local function label(text,x,y,font,color,align,width) UI.label(text,x,y,font or UI.fonts.body,color or C.ink,align,width) end
function S.bind(fn) b=fn end
local function button(id,x,y,w,h,text,color,icon,options) b(id,x,y,w,h,text,color,icon,true,options) end
function S.draw()
 button('back',36,23,137,52,'Volver',C.blue,'back')
 label(Flow.mode=='new' and 'Nueva partida' or 'Tus partidas',185,19,UI.fonts.title)
 label(Flow.mode=='new' and ('Elige una ranura vacía · '..Difficulty.get(Flow.difficulty).short) or 'Continúa, recupera una copia o administra tus ranuras.',187,67,UI.fonts.small,C.muted)
 for slot=1,3 do
  local y=140+(slot-1)*156
  UI.panel(78,y,843,139)
  Sprites.draw(Progress.skinSprite(),137,y+66,1,87)
  label('Partida '..slot,204,y+12,UI.fonts.medium)
  local state=Save.inspectRun(slot)
  local data=state.data
  if data then
   label('Ronda '..data.round..' · '..Difficulty.get(data.difficulty).short,206,y+46,UI.fonts.small)
   UI.singleLine(math.floor(data.score)..' puntos · '..math.floor(data.coins)..' monedas',206,y+73,350,UI.fonts.small,C.muted)
   local saved='Fecha no disponible'
   if type(state.modified)=='number' then saved=os.date('%d/%m/%Y %H:%M',math.floor(state.modified)) end
   UI.singleLine(state.pendingPurchase and 'Compra pendiente de revisar' or (state.status=='recoverable' and ('Copia disponible: '..saved) or ('Guardado: '..saved)),206,y+102,350,UI.fonts.tiny,state.status=='recoverable' and C.mintDark or C.muted)
   if Flow.mode=='new' then
    button('slot'..slot,650,y+39,245,57,'Ocupada',C.blue,'lock',{disabled=true})
   else
    button('slot'..slot,588,y+39,168,57,state.pendingPurchase and 'Revisar' or (state.status=='recoverable' and 'Recuperar' or 'Continuar'),C.mint,state.status=='recoverable' and 'save' or 'play')
    button('delete'..slot,767,y+39,130,57,'Borrar',C.red,'delete')
   end
  elseif state.status=='empty' then
   label('Espacio disponible',206,y+58,UI.fonts.body,C.muted)
   button('slot'..slot,673,y+39,222,60,Flow.mode=='new' and 'Crear' or 'Nueva',C.mint,'plus')
  else
   label('El archivo está dañado',206,y+50,UI.fonts.body,C.red)
   label('No hay una copia válida.',206,y+89,UI.fonts.small,C.muted)
   if Flow.mode=='new' then
    button('slot'..slot,650,y+39,245,57,'Ocupada',C.blue,'lock',{disabled=true})
   else button('delete'..slot,755,y+39,141,57,'Borrar',C.red,'delete') end
  end
 end
 UI.singleLine(Flow.message~='' and Flow.message or (Flow.mode=='new' and 'Las partidas ocupadas se conservan.' or 'Las gemas y la colección se comparten entre tus partidas.'),82,628,574,UI.fonts.small,Flow.message~='' and C.red or C.muted)
 local full=true
 for slot=1,3 do if not Save.hasRun(slot) then full=false break end end
 button(Flow.mode=='new' and 'manageRuns' or 'new',688,612,230,52,Flow.mode=='new' and 'Gestionar' or (full and 'Sin ranuras libres' or 'Nueva partida'),C.blue,Flow.mode=='new' and 'save' or 'plus',{disabled=Flow.mode~='new' and full})
end
function S.confirm(slot)
 UI.color(C.navy,.6) love.graphics.rectangle('fill',0,0,1000,680)
 UI.panel(246,155,508,374)
 Icons.draw('delete',500,211,56,C.red)
 label('¿Borrar partida '..slot..'?',277,257,UI.fonts.title,C.ink,'center',446)
 label('Se borran la partida y su respaldo.',277,319,UI.fonts.small,C.muted,'center',446)
 label('Las gemas y la colección se conservan.',277,350,UI.fonts.small,C.muted,'center',446)
 UI.singleLine(Flow.message,279,391,442,UI.fonts.tiny,C.red)
 button('cancel',284,440,196,57,'Cancelar',C.blue,'back')
 button('deleteConfirm',512,440,196,57,'Borrar',C.red,'delete')
end
function S.recovery(data)
 UI.color(C.navy,.6) love.graphics.rectangle('fill',0,0,1000,680)
 UI.panel(226,153,548,371)
 Icons.draw('save',500,209,59,C.mint)
 label(data.kind=='purchase' and 'Compra revisada' or 'Partida recuperada',247,265,UI.fonts.title,C.ink,'center',506)
 label(data.kind=='purchase' and 'Se revisó una compra que quedó interrumpida.' or ('Se restauró la copia de la partida '..data.slot..'.'),250,328,UI.fonts.small,C.muted,'center',500)
 label(data.kind=='purchase' and 'Comprueba tu saldo y mochila antes de continuar.' or (data.archive and 'El archivo dañado se conservó por seguridad.' or 'Se recuperó el archivo principal que faltaba.'),250,360,UI.fonts.small,C.muted,'center',500)
 button('recoveryOK',340,437,320,60,'Abrir partida',C.mint,'play')
end
return S
