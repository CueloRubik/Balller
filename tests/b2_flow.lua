dofile('tests/smoke.lua')
local G=require('src.game')
local P=require('src.progression')
local Results=require('src.presentation.round_results')
local Save=require('src.save')
local function click(x,y) love.draw() love.mousepressed(x,y,1) end
G.backToMenu()
P.gems=12 P.owned={true,false,false,false} P.skin=1
click(308,620)
assert(G.state=='store')
click(400,459)
assert(P.gems==12 and not P.owned[2],'Opening confirmation must not charge')
click(700,620)
assert(G.state=='store','Modal must block navigation behind it')
love.keypressed('escape')
assert(G.state=='store' and P.gems==12)
click(400,459)
click(370,478)
assert(not P.owned[2] and P.gems==12,'Cancel must leave collection intact')
click(400,459)
click(600,478)
assert(P.owned[2] and P.skin==2 and P.gems==8)
click(600,478)
assert(P.gems==8,'Click after confirmation must not charge twice')
assert(P.load() and P.skin==2 and P.gems==8)
click(500,620)
assert(G.state=='collection')
click(155,459)
assert(P.skin==1 and P.gems==8,'Owned skin equips for free')
click(880,459)
assert(G.state=='store','Locked collection item links to the store')
click(692,620)
assert(G.state=='achievements')
click(640,126)
assert(require('src.screens.hub').challengeTab=='milestones')
for mode=1,4 do
 P.best[mode]=8
 local milestone=assert(P.nextMilestone(mode))
 assert(milestone.round==9 and milestone.gems==3 and milestone.progress==2)
end
P.best[1]=999 assert(not P.nextMilestone(1))
P.best={0,0,0,0}
assert(G.newRun(1,2) and G.startRound())
G.spawn=10000 G.roundLeft=.001
love.update(.02)
assert(G.state=='shop' and Results.visible and Results.data.round==1)
local coins,gems,round=G.coins,P.gems,G.round
assert(Save.loadRun(1).coins==coins,'Round rewards must already be saved before summary')
local snapshot=Results.data
for _=1,3 do love.draw() Results.show(G) end
assert(G.coins==coins and P.gems==gems and G.round==round and Results.data.coins==snapshot.coins)
love.keypressed('return')
assert(not Results.visible and G.state=='shop','Enter must reach workshop before starting next round')
assert(G.loadRun(1) and G.state=='shop' and G.gemsReward==0)
assert(not Results.visible and G.coins==coins and P.gems==gems)
assert(G.startRound())
G.roundLeft=.001 G.spawn=10000
love.update(.02)
assert(Results.visible)
click(325,523)
assert(G.state=='menu' and not Results.visible and Save.hasRun(1))
assert(G.newRun(2,2))
G.round=10 P.rounds=9 P.best[2]=9
G.coins=99999
assert(G.startRound())
local beforeGems=P.gems
G.spawn=10000 G.roundLeft=.001
love.update(.02)
assert(Results.visible and Results.data.coins==0 and G.coins==99999,'Summary must show actual credit at the coin cap')
assert(Results.data.gems==2 and P.gems==beforeGems+2,'Round achievement must be included in closing gems')
Results.hide()
for _,size in ipairs({{800,600},{1280,720},{1366,768},{1920,1080}}) do
 local w,h=size[1],size[2]
 local scale=math.min(w/1000,h/680)
 local ox,oy=(w-1000*scale)/2,(h-680*scale)/2
 love.resize(w,h)
 G.backToMenu() love.draw()
 love.mousepressed(ox+308*scale,oy+620*scale,1)
 assert(G.state=='store')
 love.draw()
 love.mousepressed(ox+500*scale,oy+620*scale,1)
 assert(G.state=='collection')
end
print('B2 flow: five destinations, confirmation/cancel, buy/equip, milestones and reward summary without duplicate payment OK')
