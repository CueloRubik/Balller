local E={visible=false,error='',approved=false}
function E.attempt(game,profile,save)
 if game.state=='playing' then game.state='pause' end
 local active=game.state=='pause' or game.state=='shop'
 local runOK=not active or game.tutorial or game.saveRun()
 local profileOK=profile.save()
 local settingsOK=save.store()
 if runOK and profileOK and settingsOK then
  game.saveError=nil game.tutorialSaveFailed=false
  E.visible=false E.error=''
  return true
 end
 E.visible=true
 E.error=not runOK and 'No se pudo guardar la partida.' or (not profileOK and 'No se pudo guardar el progreso y la colección.' or 'No se pudieron guardar los ajustes y récords.')
 return false
end
function E.cancel() E.visible=false E.error='' E.approved=false end
return E
