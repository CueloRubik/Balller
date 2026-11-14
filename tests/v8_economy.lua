local T=require('tests.support.headless')
local G=require('src.game')
local Save=require('src.save')
local P=require('src.progression')
local O=require('src.objects')
assert(G.newRun(1,2))
local coins=G.coins
assert(not G.buy(0) and not G.buy(99) and G.coins==coins)
G.coins=0
assert(not G.buy(1) and G.inventory[1]==1 and G.coins==0)
for index,info in ipairs(O.types) do
 G.inventory={0,0,0,0,0,0,0,0}
 G.coins=info.cost
 assert(G.buy(index) and G.coins==0 and G.inventory[index]==1)
 assert(Save.loadRun(1).inventory[index]==1 and Save.loadRun(1).coins==0)
 assert(not G.buy(index) and G.coins==0 and G.inventory[index]==1)
end
G.coins=1000
G.inventory={5,0,0,0,0,0,0,0}
assert(not G.buy(1) and G.coins==1000)
G.inventory={4,4,4,0,0,0,0,0}
assert(not G.buy(4) and G.coins==1000)
assert(G.startRound())
assert(not G.buy(1) and G.coins==1000)
O.selected=1
G.ball.x,G.ball.y=770,360
G.player.x,G.player.y=220,270
local count=G.inventory[1]
assert(not G.place(0,0) and G.inventory[1]==count)
assert(G.place(460,320) and G.inventory[1]==count-1 and #O.list==1)
assert(G.saveRun() and G.loadRun(1) and G.state=='pause')
assert(G.inventory[1]==count-1 and #O.list==1)
G.togglePause()
G.endRound()
local paid,score=G.coins,G.score
assert(paid>1000 and Save.loadRun(1).coins==paid)
G.endRound()
assert(G.coins==paid and G.score==score,'Repeated endRound must not pay twice')
assert(G.loadRun(1) and G.coins==paid and G.round==2)
local original=T.fixture('profile-v7.txt')
T.files['perfil_balller_v7.txt']=original
assert(P.load())
P.rounds=100
for mode=1,4 do
 local before=P.gems
 assert(P.awardRound(P.best[mode],mode)==0 and P.gems==before)
end
T.files['perfil_balller_v7.txt']=original
assert(P.load())
for _,achievement in ipairs(P.achievements) do
 local before=P.gems
 P.track(achievement.id)
 assert(P.gems==before+2)
 P.track(achievement.id)
 assert(P.gems==before+2,'Achievement must pay once')
end
local funds=P.gems
assert(P.unlock(3) and P.gems==funds-8 and P.skin==3)
assert(P.unlock(3) and P.gems==funds-8,'Equipping owned skin must be free')
assert(not P.unlock(0) and not P.unlock(5) and P.gems==funds-8)
for skin=1,4 do assert(P.unlock(skin) and P.skinSprite()==P.skins[skin].sprite) end
assert(P.save())
local expected=P.gems
local Reloaded=T.reload('src.progression')
assert(Reloaded.load() and Reloaded.gems==expected and Reloaded.skin==4)
for i=1,4 do assert(Reloaded.owned[i]) end
local bytes=T.files['perfil_balller_v7.txt']
assert(G.startRound())
G.finish('test')
assert(not Save.hasRun(1) and T.files['perfil_balller_v7.txt']==bytes)
print('v8 baseline: buy, capacity, place, resume, round rewards, achievements and four skins OK')
