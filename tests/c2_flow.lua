dofile('tests/smoke.lua')
local G=require('src.game')
local P=require('src.progression')
local Save=require('src.save')
local O=require('src.objects')
local Exit=require('src.presentation.exit_flow')
local Help=require('data.object_help')
local Screens=require('src.v7screens')
local function click(x,y) love.draw() love.mousepressed(x,y,1) end
assert(#Help==#O.types)
assert(G.newRun(1,2)) G.coins=300
for i=1,8 do
 local x=69+((i-1)%4)*221 local y=185+math.floor((i-1)/4)*163
 click(x+179,y+69)
 love.keypressed('return')
 assert(G.state=='shop','Enter must not start while object help is open')
 assert(Help[i].effect~='' and Help[i].placement~='')
 love.keypressed('escape')
 assert(G.state=='shop')
end
G.coins=0
click(248,254)
local stock=G.inventory[1]
click(610,539) assert(G.coins==0 and G.inventory[1]==stock)
click(350,539) G.coins=300
click(248,254)
local coins,count=G.coins,G.inventory[1]
click(610,539)
assert(G.coins==coins-O.types[1].cost and G.inventory[1]==count+1)
click(350,539)
Screens.setPage(2)
click(700,620)
assert(G.state=='playing' and Screens.page()==1,'New round must show the selected first defense')
G.togglePause()
local write=love.filesystem.write
love.filesystem.write=function(path,data) if path=='partida_1.txt' then return false end return write(path,data) end
click(615,438)
assert(G.state=='pause' and G.saveError,'Save and exit must remain in the session on failure')
assert(love.quit()==true and Exit.visible,'Failed OS close must be vetoed')
local quitCalls=0 love.event={quit=function() quitCalls=quitCalls+1 end}
click(500,540)
assert(Exit.approved and quitCalls==1 and love.quit()==false,'Only explicit discard may bypass failed saving')
Exit.cancel()
assert(love.quit()==true)
click(375,466)
assert(not Exit.visible and G.state=='pause')
love.filesystem.write=write
click(385,438)
assert(not G.saveError and G.state=='pause')
local sound=Save.sound
love.filesystem.write=function(path,data) if path=='save.txt' then return false end return write(path,data) end
click(500,514)
assert(Save.sound==sound and G.saveError,'Failed sound setting must roll back')
love.filesystem.write=write
click(500,514) assert(Save.sound~=sound and not G.saveError)
click(615,438) assert(G.state=='menu')
assert(G.startTutorial()) G.togglePause()
click(385,438) assert(G.tutorial and G.state=='playing' and G.tutorialStep==1)
G.togglePause() click(615,438)
assert(G.state=='menu' and not G.tutorial)
for _,size in ipairs({{800,600},{1280,720},{1366,768},{1920,1080}}) do
 local w,h=size[1],size[2] local scale=math.min(w/1000,h/680)
 love.resize(w,h)
 assert(G.newRun(1,2)) G.coins=200 love.draw()
 love.mousepressed((w-1000*scale)/2+248*scale,(h-680*scale)/2+254*scale,1)
 love.keypressed('return') assert(G.state=='shop')
 love.keypressed('escape')
end
print('C2 flow: eight help cards, modal purchase, save/quit failures, explicit discard, sound rollback and skip/repeat tutorial OK')
