package.path='./?.lua;./?/init.lua;'..package.path
local noop=function() end
local store={}
local audio={enabled=true,load=noop,play=noop}
package.loaded['src.audio']=audio
love={
 keyboard={isDown=function() return false end},
 filesystem={
  getInfo=function(path) if store[path]~=nil then return {type='file'} end return nil end,
  read=function(path) return store[path] end,
  write=function(path,data) store[path]=data return true end,
  remove=function(path) store[path]=nil return true end
 },
 math={random=math.random,setRandomSeed=math.randomseed}
}
local Save=require('src.save')
local G=require('src.game')
local Codec=require('src.runfile')
local Objects=require('src.objects')
local Hazards=require('src.hazards')

assert(G.newRun(1))
assert(G.goalKind()=='hits' and G.goal()==6 and G.bonus()==12)
assert(G.upgradeCost()==65)
assert(not G.buyUpgrade(),'No debería poder comprar con 40 monedas')
G.coins=300
assert(G.buyUpgrade() and G.boots==1 and G.coins==235)
assert(G.buyUpgrade() and G.boots==2 and G.coins==115)
assert(not G.buyUpgrade(),'No debe permitir comprar sin dinero suficiente')
assert(G.startRound() and G.player.speed==305)
G.player.x,G.player.y=460,330
G.ball.x,G.ball.y=500,330
G.ball.vx,G.ball.vy=-100,80
assert(G.pulse(),'El rescate cercano debe activarse')
assert(G.pulseCooldown==10 and math.abs(G.ball.vx-G.ballSpeed())<.01 and math.abs(G.ball.vy)<.1)
assert(not G.pulse(),'Hay que respetar el enfriamiento')
assert(G.saveRun())
local saved=assert(Save.loadRun(1))
assert(saved.boots==2 and saved.pulseCooldown==10)
G.togglePause()
local frozen=G.pulseCooldown
G.update(3)
assert(G.pulseCooldown==frozen,'Pausa debe detener enfriamiento')
G.togglePause()
G.pulseCooldown=.02
G.spawn=1e6
Hazards.clear()
Objects.clear()
G.player.x,G.player.y=150,150
G.ball.x,G.ball.y=620,310
G.ball.vx,G.ball.vy=200,50
G.update(.03)
assert(G.pulseCooldown==0)
assert(not G.pulse(),'El pulso necesita proximidad')
assert(G.pulseCooldown==0)
G.autosaveClock=7.99
G.update(.02)
assert(G.autosaveClock==0,'El autoguardado debe reiniciar su contador')
assert(Save.loadRun(1),'Debe guardarse automáticamente')
assert(store['partida_1.txt.bak'],'Debe existir un respaldo')
local good=assert(store['partida_1.txt'])
assert(not Codec.decode(good:gsub('B|','B|999',1)),'La suma de comprobación debe detectar la corrupción')
store['partida_1.txt']='CORRUPTO'
local recovered=assert(Save.loadRun(1),'Debe restaurar desde respaldo')
assert(recovered.boots==2 and store['partida_1.txt']~='CORRUPTO')
local legacy=good:gsub('\nX|[^\n]*',''):gsub('\nK|[^\n]*','')
local old=assert(Codec.decode(legacy),'Guardados v4 deben continuar leyéndose')
assert(old.boots==0 and old.wallBounces==0 and old.pulseCooldown==0)
G.round=2
G.wallBounces=4
assert(G.goalKind()=='walls' and G.progress()==4 and G.goal()==4 and G.bonus()==12)
G.round=3
G.placed=1
assert(G.goalKind()=='places' and G.progress()==1 and G.goal()==1 and G.bonus()==24)
G.round=6
assert(G.goalKind()=='places' and G.goal()==2 and G.bonus()==26)
assert(Save.clearRun(1) and not Save.hasRun(1),'Al perder se eliminan también los respaldos')
print('Balller v5 polish OK: upgrades, pulse, autosave, backup, checksum, legacy saves, challenges')
