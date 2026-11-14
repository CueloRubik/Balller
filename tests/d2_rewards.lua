local T=require('tests.support.headless')
local G=require('src.game')
local Save=require('src.save')
local P=require('src.progression')
local R=require('src.reward_transaction')
local Codec=require('src.runfile')
local Profile=require('src.profilefile')
local function setup(slot)
 T.files={} T.blocked={} R.busy=false G.pendingReward=nil
 P.gems=0 P.stars=0 P.hits=0 P.rounds=9 P.plays=0
 P.best={0,0,0,0} P.owned={true,false,false,false} P.skin=1 P.dirty=false
 assert(P.save())
 assert(G.newRun(slot or 1,2))
 G.round=3 assert(G.startRound()) G.roundHits=4 G.placed=1
 assert(G.saveSession())
end
local function verify(slot)
 local run=assert(Save.loadRun(slot or 1))
 local profile=assert(Profile.decode(T.files['perfil_balller_v7.txt']))
 assert(run.round==4 and run.previousRound==3 and run.coins==G.coins)
 assert(profile.gems==4 and profile.rounds==10 and profile.best[2]==3)
 local receipt=assert(R.readReceipt(T.files['partida_'..(slot or 1)..'.txt.reward'],slot or 1,run))
 assert(receipt.gems==4 and receipt.base==36 and receipt.skill==8 and receipt.objective==24)
 assert(not R.pending())
 return run,profile
end
for _,path in ipairs({R.file,'partida_1.txt.bak','partida_1.txt','perfil_balller_v7.txt.bak','perfil_balller_v7.txt','partida_1.txt.reward'}) do
 setup()
 T.blocked[path]=true
 G.endRound()
 assert(G.pendingReward and G.saveError and G.state=='shop')
 local balance,count,gems=G.coins,G.inventory[1],P.gems
 assert(not G.buy(1) and not G.buyUpgrade() and not G.startRound())
 assert(not P.unlock(2) and not P.save() and not Save.clearRun(1))
 G.endRound()
 assert(P.gems==gems and G.coins==balance and G.inventory[1]==count)
 T.blocked[path]=nil
 assert(G.saveSession() and not G.pendingReward)
 verify()
 assert(G.saveSession()) verify()
end
-- A persisted intent completes even if memory was lost after a partial write.
for _,path in ipairs({'partida_1.txt','perfil_balller_v7.txt','partida_1.txt.reward'}) do
 setup() T.blocked[path]=true G.endRound()
 assert(T.files[R.file])
 local expectedCoins=G.coins
 G.pendingReward=nil R.busy=false T.blocked={}
 P.gems=0 P.rounds=9
 assert(G.flushRewards() and P.gems==4 and G.coins==expectedCoins)
 verify()
 local raw=T.files['perfil_balller_v7.txt']
 assert(G.flushRewards() and T.files['perfil_balller_v7.txt']==raw)
end
setup()
local remove=love.filesystem.remove
love.filesystem.remove=function(path) if path==R.file then return false end return remove(path) end
G.endRound() assert(G.pendingReward and T.files[R.file])
local savedProfile=T.files['perfil_balller_v7.txt']
love.filesystem.remove=remove
G.pendingReward=nil R.busy=false
assert(G.flushRewards() and T.files['perfil_balller_v7.txt']==savedProfile)
verify()
-- Interrupt immediately after journal preparation and after the final disk commit.
for _,at in ipairs({'prepared','committed'}) do
 setup()
 local write=love.filesystem.write
 if at=='prepared' then
  love.filesystem.write=function(path,data)
   if path=='partida_1.txt.bak' then error('process interrupted') end
   return write(path,data)
  end
 else
  love.filesystem.remove=function(path)
   local result=remove(path)
   if path==R.file then error('process interrupted') end
   return result
  end
 end
 assert(not pcall(G.endRound))
 love.filesystem.write=write love.filesystem.remove=remove
 G.pendingReward=nil R.busy=false
 assert(G.flushRewards()) P.load() verify()
end
-- Receipt backup failures and corrupted readback are retryable without paying twice.
setup() G.endRound() verify()
assert(G.startRound())
T.blocked['partida_1.txt.reward.bak']=true G.endRound()
assert(G.pendingReward and R.pending())
T.blocked={} assert(G.saveSession())
local rounds=P.rounds assert(G.saveSession() and P.rounds==rounds)
setup()
local write=love.filesystem.write
love.filesystem.write=function(path,data)
 local result=write(path,data)
 if path=='perfil_balller_v7.txt' then T.files[path]=data..'BAD' end
 return result
end
G.endRound() assert(G.pendingReward)
love.filesystem.write=write
assert(G.saveSession()) verify()
-- Foreign slots and cosmetic profile state survive an interrupted reward.
setup(2)
P.gems=20 assert(P.unlock(2)) assert(G.saveSession())
local owned=P.export()
assert(G.newRun(1,1)) local other=T.files['partida_1.txt']
assert(G.loadRun(2)) if G.state=='pause' then G.togglePause() end
T.blocked['perfil_balller_v7.txt']=true G.endRound()
assert(G.pendingReward)
T.blocked={} assert(G.saveSession())
assert(P.owned[2] and P.skin==2 and T.files['partida_1.txt']==other)
local after=P.gems
assert(G.saveSession() and P.gems==after)
-- Complete buy/place/reward/reload circuit for thirty rounds in every difficulty.
for mode=1,4 do
 setup() assert(G.newRun(1,mode))
 for round=1,30 do
  assert(G.round==round and G.buy(1))
  assert(G.startRound())
  G.player.x,G.player.y=220,270 G.ball.x,G.ball.y=770,360
  assert(G.place(460,320))
  G.roundHits=8 G.endRound()
  assert(not G.rewardsPending())
  local coins,gems,rounds=G.coins,P.gems,P.rounds
  assert(G.backToMenu() and G.loadRun(1) and P.load())
  assert(G.round==round+1 and G.coins==coins and P.gems==gems and P.rounds==rounds)
  assert(G.rewardDetails and G.gemsReward>=0)
 end
 assert(P.best[mode]==30)
end
-- Malformed journals fail closed and preserve every byte for diagnosis.
setup() T.files[R.file]='INVALID-REWARD-INTENT'
local runBefore,profileBefore=T.files['partida_1.txt'],T.files['perfil_balller_v7.txt']
assert(not G.flushRewards() and not G.newRun(2,2) and not Save.clearRun(1) and not P.unlock(2))
assert(T.files[R.file]=='INVALID-REWARD-INTENT' and T.files['partida_1.txt']==runBefore and T.files['perfil_balller_v7.txt']==profileBefore)
print('D2 rewards: every write/backup/remove stage, interrupted restarts, idempotent recovery, profile/slot isolation and invalid journal protection OK')
