local Save=require('src.save')
local F={mode='continue',difficulty=2,selectedSlot=nil,message='',recovery=nil}
function F.new(game)
 F.mode='new' F.selectedSlot=nil F.message='' F.recovery=nil
 game.state='difficulty'
end
function F.continue(game)
 F.mode='continue' F.selectedSlot=nil F.message='' F.recovery=nil
 game.state='slots'
end
function F.primary(game)
 for slot=1,3 do if not Save.hasRun(slot) then F.new(game) return end end
 F.continue(game)
end
function F.create(game,slot)
 if Save.hasRun(slot) then
  F.message='Esta ranura está ocupada. Elige una vacía.'
  game.state='slots'
  return false
 end
 if not game.newRun(slot,F.difficulty) then
  F.message='No se pudo guardar la nueva partida. Revisa el espacio e inténtalo de nuevo.'
  game.state='slots'
  return false
 end
 F.message='' F.selectedSlot=nil
 return true
end
function F.chooseDifficulty(game,difficulty)
 F.difficulty=difficulty
 if F.selectedSlot then
  local slot=F.selectedSlot
  F.selectedSlot=nil
  return F.create(game,slot)
 end
 F.mode='new' F.message='' game.state='slots'
 return true
end
function F.chooseSlot(game,slot)
 local state=Save.inspectRun(slot)
 F.message=''
 if F.mode=='new' then return F.create(game,slot) end
 if state.status=='empty' then
  F.mode='new' F.selectedSlot=slot game.state='difficulty'
  return true
 end
 local ok,status,detail=game.loadRun(slot)
 if not ok then
  local messages={purchase_restore_failed='No se pudo revisar la compra pendiente. Reintenta antes de continuar.',preserve_failed='No se pudo conservar el archivo dañado. La copia sigue disponible.',restore_failed='No se pudo restaurar la copia. Revisa el espacio e inténtalo de nuevo.'}
  F.message=messages[status] or 'No se pudo abrir esta partida. No hay una copia válida disponible.'
  return false
 end
 if status=='recovered' or status=='purchase_recovered' then F.recovery=detail or {slot=slot} end
 return true
end
function F.back(game)
 F.message=''
 if game.state=='slots' and F.mode=='new' then
  game.state='difficulty'
 elseif game.state=='difficulty' and F.selectedSlot then
  F.selectedSlot=nil F.mode='continue' game.state='slots'
 else game.backToMenu() end
end
return F
