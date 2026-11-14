dofile('tests/smoke.lua')
local G=require('src.game')
local Save=require('src.save')
local F=require('src.presentation.run_flow')
local E=require('src.economy.rules')
local function click(x,y) love.draw() love.mousepressed(x,y,1) end
assert(G.newRun(1,2)) G.coins=200 assert(G.saveSession())
local remove=love.filesystem.remove
love.filesystem.remove=function(path) if path=='partida_1.txt.purchase' then return false end return remove(path) end
click(248,254)
click(610,539)
assert(G.coins==200 and G.inventory[1]==1 and G.saveError)
assert(Save.inspectRun(1).pendingPurchase)
love.filesystem.remove=remove
love.keypressed('escape')
-- Simulate relaunch from a menu: it must read the journal, not the candidate.
G.state='menu'
click(780,394) click(669,204)
assert(F.recovery and F.recovery.kind=='purchase' and G.state=='shop')
assert(G.coins==200 and G.inventory[1]==1)
click(500,467)
click(173,304)
assert(G.coins==178 and G.inventory[1]==2 and not love.filesystem.getInfo('partida_1.txt.purchase'))
assert(G.loadRun(1) and G.coins==178 and G.inventory[1]==2)
for _,size in ipairs({{800,600},{1280,720},{1366,768},{1920,1080}}) do
 local w,h=size[1],size[2] local scale=math.min(w/1000,h/680)
 love.resize(w,h)
 assert(G.newRun(1,2)) G.coins=200 assert(G.saveSession()) love.draw()
 love.mousepressed((w-1000*scale)/2+173*scale,(h-680*scale)/2+304*scale,1)
 assert(G.coins==200-E.config.defenseCosts[1] and G.inventory[1]==2)
end
print('D1 flow: interrupted modal purchase, review without charge, durable retry and four scaled purchase controls OK')
