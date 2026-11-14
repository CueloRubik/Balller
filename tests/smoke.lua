package.path='./?.lua;./?/init.lua;'..package.path
local count=0
local function noop() count=count+1 end
local g={}
for _,k in ipairs({'clear','setColor','rectangle','circle','line','arc','polygon','ellipse','setLineWidth','setScissor','push','pop','translate','scale','rotate','print','printf','setFont','draw','setCanvas','origin','setBlendMode','setLineStyle'}) do g[k]=noop end
local font={getWidth=function(_,s) return #tostring(s)*12 end}
g.newFont=function() return font end
g.getFont=function() return font end
g.newCanvas=function() return {getDimensions=function() return 128,128 end,setFilter=noop} end
g.newImage=function(path) return {getDimensions=function() return path:find('character') and 2048 or 1024,128 end,setFilter=noop} end
g.newQuad=function() return {} end
g.getDimensions=function() return 1000,680 end
local fallback=arg and arg[1]=='fallback'
local files={getInfo=function(path) if not fallback and path:match('^assets/sprites/.*%.png$') then return {type='file'} end end,read=function() return nil end,write=function() return true end}
local audio={play=noop,stop=noop,setPitch=noop}
love={graphics=g,keyboard={isDown=function() return false end},filesystem=files,math={random=math.random,setRandomSeed=math.randomseed},mouse={getPosition=function() return 500,300 end},sound={newSoundData=function() return {setSample=noop} end},audio={newSource=function() return audio end}}
dofile('main.lua')
love.load()
local S=require('src.sprites')
assert(#S.images.character==16)
for _,key in ipairs({'ball','spikes','drain','shield','boost','lid'}) do assert(#S.images[key]==8,key) end
love.draw()
love.keypressed('return')
local G=require('src.game')
assert(G.state=='playing')
for i=1,280 do love.update(1/60) love.draw() end
love.keypressed('1')
love.mousepressed(420,320,1)
love.keypressed('p')
assert(G.state=='pause')
love.draw()
love.keypressed('p')
assert(G.state=='playing')
local F=require('src.feedback')
F.hit(300,300,10)
assert(F.combo==1)
F.hit(300,300,10)
assert(F.combo==2)
F.update(5)
assert(F.combo==0)
assert(count>300,'Faltaron llamadas al sistema grafico')
print('Balller smoke OK; sprites, menus, partida, pausa y rachas.')
