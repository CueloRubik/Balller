local T=require('tests.support.headless')
local G=require('src.game')
local Save=require('src.save')
local P=require('src.progression')
local Exit=require('src.presentation.exit_flow')
assert(G.newRun(1,2) and G.startRound())
G.togglePause()
local before=T.files['partida_1.txt']
G.coins=99
T.blocked['partida_1.txt']=true
assert(not G.saveSession() and G.saveError and G.state=='pause')
assert(not G.backToMenu() and G.state=='pause' and G.coins==99)
assert(T.files['partida_1.txt']==before)
assert(not Exit.attempt(G,P,Save) and Exit.visible and G.state=='pause')
Exit.cancel() assert(not Exit.visible and G.state=='pause')
T.blocked['partida_1.txt']=nil
assert(G.saveSession() and not G.saveError and Save.loadRun(1).coins==99)
P.track('hits')
T.blocked['perfil_balller_v7.txt']=true
assert(not G.backToMenu() and G.state=='pause' and P.dirty and G.saveError)
T.blocked['perfil_balller_v7.txt']=nil
assert(G.backToMenu() and G.state=='menu' and not P.dirty)
assert(G.loadRun(1) and G.state=='pause')
local sound=Save.sound
Save.sound=not sound T.blocked['save.txt']=true
assert(not G.backToMenu() and G.state=='pause' and G.saveError)
T.blocked['save.txt']=nil Save.sound=sound
assert(G.saveSession())
G.togglePause()
T.blocked['partida_1.txt']=true
G.autosaveClock=7.99 G.spawn=10000
local x,y,left=G.ball.x,G.ball.y,G.roundLeft
G.update(.02)
assert(G.state=='pause' and G.saveError and G.ball.x==x and G.ball.y==y and G.roundLeft==left)
T.blocked['partida_1.txt']=nil
assert(G.saveSession())
assert(G.startTutorial())
local files={}
for slot=1,3 do files[slot]=T.files['partida_'..slot..'.txt'] end
local stats={P.gems,P.hits,P.stars,P.rounds,P.plays}
love.keyboard.isDown=function(...) for _,key in ipairs({...}) do if key=='d' then return true end end return false end
for _=1,28 do G.update(.04) end
love.keyboard.isDown=function() return false end
assert(G.tutorialStep==2 and G.player.x>300)
G.ball.x,G.ball.y=G.player.x+20,G.player.y G.ball.cooldown=0
G.update(.02) assert(G.tutorialStep==3)
assert(G.pulse() and G.tutorialStep==4)
assert(math.abs(math.sqrt(G.ball.vx^2+G.ball.vy^2)-105)<.001)
G.ball.x,G.ball.y=770,360 G.player.x,G.player.y=220,270
T.blocked['save.txt']=true
assert(G.place(460,320) and G.state=='tutorialDone' and G.tutorialSaveFailed)
assert(not G.backToMenu() and G.state=='tutorialDone')
T.blocked['save.txt']=nil
assert(G.saveTutorial() and not G.tutorialSaveFailed and Save.tutorialDone)
assert(G.backToMenu())
for slot=1,3 do assert(T.files['partida_'..slot..'.txt']==files[slot]) end
assert(P.gems==stats[1] and P.hits==stats[2] and P.stars==stats[3] and P.rounds==stats[4] and P.plays==stats[5])
print('C2 saving: manual/exit failures retain session, profile retry, failed autosave pauses and full tutorial has no rewards/run writes OK')
