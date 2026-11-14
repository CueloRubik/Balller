dofile('tests/smoke.lua')
local G=require('src.game')
local P=require('src.progression')
local R=require('src.reward_transaction')
local Results=require('src.presentation.round_results')
local Exit=require('src.presentation.exit_flow')
local function click(x,y) love.draw() love.mousepressed(x,y,1) end
assert(G.newRun(1,2))
P.gems=0 P.rounds=9 P.best={0,0,0,0} assert(P.save())
G.round=3 assert(G.startRound()) G.roundHits=4 G.placed=1
local write=love.filesystem.write
love.filesystem.write=function(path,data) if path=='perfil_balller_v7.txt' then return false end return write(path,data) end
G.roundLeft=.001 G.spawn=10000 love.update(.01)
assert(G.pendingReward and Results.visible and G.state=='shop')
local balance,gems=G.coins,P.gems
click(616,523) love.keypressed('escape') love.keypressed('return')
assert(G.pendingReward and G.state=='shop' and G.coins==balance and P.gems==gems)
assert(love.quit()==true and Exit.visible)
click(375,466) assert(not Exit.visible)
love.filesystem.write=write
click(600,455)
assert(not G.rewardsPending() and G.coins==balance and P.gems==4 and P.rounds==10)
Results.hide()
assert(G.loadRun(1) and G.gemsReward==4 and G.rewardDetails.objective==24)
click(820,138)
assert(Results.visible and Results.data.gems==4 and Results.data.detail.skill==8)
love.draw() click(616,523)
assert(not Results.visible and G.coins==balance)
for _,size in ipairs({{800,600},{1000,680},{1280,720},{1366,768},{1920,1080}}) do
 local w,h=size[1],size[2] love.resize(w,h)
 local scale=math.min(w/1000,h/680)
 assert(G.startRound())
 love.filesystem.write=function(path,data) if path==R.file then return false end return write(path,data) end
 G.endRound() love.draw() assert(G.rewardsPending())
 love.filesystem.write=write
 love.mousepressed((w-1000*scale)/2+600*scale,(h-680*scale)/2+455*scale,1)
 assert(not G.rewardsPending())
end
-- Restart the app with a prepared journal and a profile write still failing.
assert(G.startRound())
love.filesystem.write=function(path,data) if path=='perfil_balller_v7.txt' then return false end return write(path,data) end
G.endRound() assert(R.pending())
G.pendingReward=nil R.busy=false G.state='menu'
love.load() love.draw() assert(G.rewardsPending())
local prior=P.gems
click(780,394) assert(G.state=='menu')
love.filesystem.write=write
love.keypressed('return')
assert(not G.rewardsPending() and P.gems==prior)
assert(G.loadRun(1) and G.state=='shop')
-- Cosmetic commit failure uses the same blocking retry surface.
G.state='store' P.gems=12 P.owned[2]=false P.skin=1 assert(P.save())
local remove=love.filesystem.remove
love.filesystem.remove=function(path) if path=='perfil_balller_v7.txt.purchase' then return false end return remove(path) end
assert(not P.unlock(2) and P.gems==12 and not P.owned[2])
love.draw() assert(G.rewardsPending())
love.filesystem.remove=remove
love.resize(1000,680) click(600,455)
assert(not G.rewardsPending() and P.gems==12 and not P.owned[2])
print('D2 flow: pending reward modal, blocked purchases/navigation, close retry, durable receipt and five scaled retry controls OK')
