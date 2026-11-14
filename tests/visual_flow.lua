dofile('tests/smoke.lua')
local G=require('src.game')
local P=require('src.progression')
local O=require('src.objects')
for _,size in ipairs({{1000,680},{800,600},{1280,720},{1366,768},{1920,1080}}) do
 local w,h=size[1],size[2]
 local scale=math.min(w/1000,h/680)
 local ox,oy=(w-1000*scale)/2,(h-680*scale)/2
 love.resize(w,h)
 local function click(x,y) love.mousepressed(ox+x*scale,oy+y*scale,1) end
 G.backToMenu() love.draw()
 click(780,310)
 assert(G.state=='difficulty','Play hit area must survive resize')
 love.draw() click(250,293)
 assert(G.state=='slots')
 assert(G.newRun(1,2))
 G.coins=0 love.draw()
 local buy=G.buy
 local attempts=0
 G.buy=function(index) attempts=attempts+1 return buy(index) end
 click(174,304)
 assert(attempts==0,'Disabled buy must not dispatch its action')
 G.coins=22 love.draw()
 local before=G.inventory[1]
 click(174,304)
 assert(attempts==1 and G.inventory[1]==before+1 and G.coins==0)
 G.buy=buy
 P.gems=0 P.owned[3]=false
 G.state='collection' love.draw()
 local unlock=P.unlock
 P.unlock=function(index) attempts=attempts+1 return unlock(index) end
 local previous=attempts
 click(620,477)
 assert(attempts==previous,'Locked collection buy must not dispatch')
 P.unlock=unlock
end
love.resize(1000,680)
print('UI flow: five resolutions, transformed hit areas and disabled purchase actions OK')
