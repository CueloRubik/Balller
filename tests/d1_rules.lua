require('tests.support.headless')
local E=require('src.economy.rules')
local C=E.config
local G=require('src.game')
local O=require('src.objects')
local P=require('src.progression')
local D=require('src.difficulty')
local R=require('src.rounds')
assert(E.validate() and C.initialCoins==40 and C.perItem==5 and C.bagCapacity==12)
for i,item in ipairs(O.types) do assert(item.cost==C.defenseCosts[i]) end
for i,skin in ipairs(P.skins) do assert(skin.cost==C.skinCosts[i]) end
assert(not E.upgradeCost(3))
local oldCap=C.coinCap C.coinCap=100000 assert(not E.validate()) C.coinCap=oldCap
local every=C.rewards.goalEvery C.rewards.goalEvery=0 assert(not E.validate()) C.rewards.goalEvery=every
assert(G.newRun(1,2)) G.coins=1000
C.perItem=2
assert(G.buy(1) and G.inventory[1]==2 and not G.buy(1))
C.perItem=5 C.bagCapacity=3
assert(not G.buy(4),'Capacity applies to the combined inventory')
C.bagCapacity=12
C.coinCap=500 G.coins=600
assert(G.startRound()) G.endRound()
assert(G.coins==600 and G.reward==0,'Lower configured cap must not confiscate existing balances')
C.coinCap=oldCap
for mode=1,4 do
 local coins=C.initialCoins
 for round=1,10 do
  coins=coins-C.defenseCosts[1]
  assert(coins>=0,'One shield per round must remain accessible in the reference simulation')
  local multiplier=D.get(mode).bonus*R.get(round).reward
  local reward=E.roundReward(round,0,0,multiplier,coins)
  local reference=math.floor((18+6*round)*multiplier+.5)
  assert(reward.requested==reference)
  coins=coins+reward.credited
 end
 print('Reference economy: mode '..mode..', 10 rounds, one shield each, final coins '..coins)
end
for mode=1,4 do for round=1,100 do for hits=0,20 do for _,complete in ipairs({false,true}) do
 local kind=({'hits','walls','places'})[(round-1)%3+1]
 local goal=complete and (12+math.min(12,math.floor((round-1)/3)*2)+(kind=='places' and 12 or 0)) or 0
 local reference=math.floor((18+6*round+math.min(15,hits)*2+goal)*D.get(mode).bonus*R.get(round).reward+.5)
 assert(E.roundReward(round,hits,goal,D.get(mode).bonus*R.get(round).reward,0).requested==reference)
end end end end
assert(E.validate())
print('D1 rules: defaults/metadata, configurable limits, legacy-safe caps and four deterministic economy simulations OK')
