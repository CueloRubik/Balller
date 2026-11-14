package.path='./?.lua;./?/init.lua;'..package.path
local calls=0
local function noop() calls=calls+1 end
local graphics={}
for _,k in ipairs({'clear','setColor','rectangle','circle','line','arc','polygon','ellipse','setLineWidth','setScissor','push','pop','translate','scale','rotate','print','printf','setFont','draw','setCanvas','origin','setBlendMode','setLineStyle'}) do graphics[k]=noop end
local font={getWidth=function(_,s) return #tostring(s)*12 end,getHeight=function() return 20 end}
graphics.newFont=function() return font end
graphics.getFont=function() return font end
graphics.newCanvas=function() return {getDimensions=function() return 128,128 end,setFilter=noop} end
graphics.newImage=function(path) return {getDimensions=function() return path:find('character') and 2048 or 1024,128 end,setFilter=noop} end
graphics.newQuad=function() return {} end
graphics.getDimensions=function() return 1000,680 end
local fallback=arg and arg[1]=='fallback'
local store={}
local fs={
 getInfo=function(path) if not fallback and path:match('^assets/sprites/.*%.png$') then return {type='file'} end if store[path] then return {type='file'} end return nil end,
 read=function(path) return store[path] end,
 write=function(path,data) store[path]=data return true end,
 remove=function(path) store[path]=nil return true end
}
local source={play=noop,stop=noop,setPitch=noop}
local mouse={getPosition=function() return 500,300 end}
love={graphics=graphics,keyboard={isDown=function() return false end},filesystem=fs,math={random=math.random,setRandomSeed=math.randomseed},mouse=mouse,sound={newSoundData=function() return {setSample=noop} end},audio={newSource=function() return source end}}
dofile('main.lua')
love.load()
local G=require('src.game')
local B=require('src.ball')
local P=require('src.progression')
local S=require('src.sprites')
local R=require('src.rounds')
local Save=require('src.save')
local Screens=require('src.v7screens')
local O=require('src.objects')
local H=require('src.hazards')
for _,name in ipairs({'ball','ball_ocean','ball_berry','ball_violet','character','character_diagonal','spikes','portal'}) do
 assert(S.images[name], 'Falta sprite '..name)
end
for _,state in ipairs({'menu','difficulty','slots','collection','achievements','settings','help','shop','tutorialDone'}) do
 if state=='shop' then G.newRun(1,2) else G.state=state end
 love.draw()
end
G.newRun(1,2)
G.startRound()
assert(G.state=='playing')
assert(G.ballSpeed()>200 and G.ballSpeed()<320)
local target=G.ballSpeed()
local function verifySpeed()
 local speed=math.sqrt(G.ball.vx^2+G.ball.vy^2)
 assert(math.abs(speed-target)<.01, 'Velocidad no constante: '..speed..' vs '..target)
end
G.ball.vx,G.ball.vy=700,240
G.update(1/60)
verifySpeed()
G.pulseCooldown=0
G.ball.x,G.ball.y=G.player.x+50,G.player.y
assert(G.pulse())
verifySpeed()
G.spawn=1000
H.clear()
O.clear()
for i=1,120 do G.update(1/60) end
verifySpeed()
love.draw()
Screens.setPage(2)
love.draw()
G.togglePause()
love.draw()
G.togglePause()
assert(G.state=='playing')
G.round=3
G.roundLeft=0
G.spawn=1000
H.clear()
G.endRound()
assert(G.state=='shop')
assert(P.gems>=1 and P.best[2]>=3)
assert(Save.loadRun(1)~=nil)
love.draw()
P.gems=10
local old=P.gems
assert(P.unlock(2))
assert(P.skin==2 and P.gems==old-4)
love.draw()
G.backToMenu()
love.draw()
local function show(state)
 G.state=state
 love.draw()
end
show('collection')
show('achievements')
show('settings')
assert(calls>200)
print('Balller v7 smoke OK')
