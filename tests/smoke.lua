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
local Sprites=require('src.sprites')
assert(#Sprites.images.character==16)
assert(#Sprites.images.character_diagonal==16)
for _,name in ipairs({'ball','spikes','drain','shield','boost','lid','magnet','fan','clock','saw','shock','vortex'}) do
 assert(#Sprites.images[name]==8,name)
end
local Save=require('src.save')
local G=require('src.game')
local Objects=require('src.objects')
local Hazards=require('src.hazards')
local Runfile=require('src.runfile')
love.draw()
love.keypressed('return')
assert(G.state=='slots','Enter del menú debe abrir las ranuras')
love.draw()
assert(G.newRun(1))
assert(G.state=='shop' and G.coins==40 and Save.hasRun(1))
love.draw()
local startCoins=G.coins
assert(G.buy(1),'Compra de escudo')
assert(G.coins==startCoins-22)
assert(G.inventory[1]==2)
local snapshot=Save.loadRun(1)
assert(snapshot and snapshot.round==1 and snapshot.inventory[1]==2)
assert(G.startRound())
assert(G.state=='playing')
love.draw()
for i=1,120 do G.update(1/60) end
local hitsBefore=G.roundHits
G.roundHits=8
local expected=18+6*1+2*8+12
local previous=G.coins
G.roundLeft=.001
Hazards.clear()
G.spawn=100
G.ball.x,G.ball.y=800,300
G.player.x,G.player.y=190,300
G.update(.02)
assert(G.state=='shop','Debe terminar la ronda y abrir la tienda')
assert(G.round==2 and G.reward==expected and G.coins==previous+expected)
assert(Save.loadRun(1).round==2,'Autosave después de cada ronda')
assert(G.loadRun(1) and G.state=='shop')
assert(G.startRound() and G.state=='playing')
local before=G.roundLeft
G.togglePause()
assert(G.state=='pause')
G.update(2)
assert(G.roundLeft==before,'Pausa congela el tiempo de ronda')
assert(G.saveRun())
assert(G.loadRun(1) and G.state=='pause')
G.togglePause()
assert(G.state=='playing')
assert(G.newRun(2))
assert(Save.hasRun(1) and Save.hasRun(2))
assert(not Save.hasRun(3))
assert(G.newRun(3))
assert(Save.hasRun(3))
assert(G.loadRun(1) and G.state=='pause')
assert(Runfile.decode('BALLLER_RUN_2\nmalformado\nEND')==nil)
assert(not Runfile.decode('invalido'))
local art=require('src.art')
local diagonalCalls=0
local oldDraw=Sprites.draw
Sprites.draw=function(name,...)
 if name=='character_diagonal' then diagonalCalls=diagonalCalls+1 end
 return oldDraw(name,...)
end
for _,dir in ipairs({{1,1},{-1,1},{1,-1},{-1,-1}}) do
 G.player.dx,G.player.dy=dir[1],dir[2]
 art.player(G.player)
end
assert(diagonalCalls==4)
Sprites.draw=oldDraw
G.state='playing'
G.round=6
local b=G.ball
b.x,b.y=450,330
b.vx,b.vy=120,90
Hazards.list={{kind=5,x=440,y=330,r=34,warning=0,age=0,active=5,fade=.5,vx=0,vy=0,phase=0,cooldown=0}}
local vy=b.vy
assert(Hazards.update(.1,b,{})==nil and b.vy~=vy,'Remolino cambia trayectoria')
Hazards.list={{kind=3,x=450,y=330,r=30,warning=0,age=0,active=5,fade=.5,vx=0,vy=0,phase=0,cooldown=0}}
assert(Hazards.update(.02,b,{})=='sierra','Sierra debe ser peligrosa')
Hazards.list={{kind=4,x=450,y=330,r=35,warning=0,age=0,active=5,fade=.5,vx=0,vy=0,phase=0,cooldown=0}}
assert(Hazards.update(.02,b,{})=='descarga','Descarga debe ser peligrosa cuando está activa')
Hazards.clear()
love.draw()
G.finish('Prueba de pérdida')
assert(G.state=='over' and not Save.hasRun(1),'Perder borra solo la ranura actual')
assert(Save.hasRun(2) and Save.hasRun(3),'Otras ranuras no se pierden')
assert(Save.games==1)
assert(calls>400,'No se renderizó la interfaz')
print('Balller v4 smoke OK: menú, sprites, tienda, rondas, guardado, 3 ranuras, peligros y pausa')
