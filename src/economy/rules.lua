local C=require('data.economy')
local E={config=C}
local function integer(n,lo,hi) return type(n)=='number' and n==n and n%1==0 and n>=lo and n<=hi end
function E.validate()
 if not integer(C.coinCap,1,99999) or not integer(C.initialCoins,0,C.coinCap) then return false,'Coin limits exceed the legacy save format' end
 if not integer(C.perItem,1,10) or not integer(C.bagCapacity,1,80) then return false,'Invalid inventory limits' end
 if #C.defenseCosts~=8 or #C.skinCosts~=4 or #C.starter~=8 or #C.upgrades.costs~=3 then return false,'Keep the legacy item/skin/upgrade counts' end
 local total=0
 for i,cost in ipairs(C.defenseCosts) do
  if not integer(cost,1,C.coinCap) or not integer(C.starter[i],0,C.perItem) then return false,'Invalid defense price or starter inventory' end
  total=total+C.starter[i]
 end
 if total>C.bagCapacity or C.skinCosts[1]~=0 then return false,'Invalid starter capacity or original skin price' end
 for _,cost in ipairs(C.skinCosts) do if not integer(cost,0,10000000) then return false,'Invalid skin price' end end
 for _,cost in ipairs(C.upgrades.costs) do if not integer(cost,1,C.coinCap) then return false,'Invalid upgrade price' end end
 if not integer(C.upgrades.speedStep,1,100) then return false,'Invalid upgrade speed' end
 for _,n in pairs(C.rewards) do if not integer(n,0,100000) then return false,'Invalid reward value' end end
 if C.rewards.goalEvery<1 then return false,'Invalid goal interval' end
 return true
end
function E.total(inventory)
 local total=0 for _,n in ipairs(inventory) do total=total+n end return total
end
function E.canBuy(game,index)
 local cost=C.defenseCosts[index]
 if not cost then return false,'Objeto desconocido' end
 if game.state~='shop' then return false,'Se compra entre rondas' end
 if game.coins<cost then return false,'Te faltan '..(cost-game.coins)..' monedas' end
 if (game.inventory[index] or 0)>=C.perItem then return false,'Máximo: '..C.perItem..' unidades de este objeto' end
 if E.total(game.inventory)>=C.bagCapacity then return false,'Mochila llena: máximo '..C.bagCapacity..' objetos' end
 return true,nil,cost
end
function E.upgradeCost(level) return C.upgrades.costs[level+1] end
function E.goalBonus(round,kind)
 local r=C.rewards
 return r.goalBase+math.min(r.goalExtraCap,math.floor((round-1)/r.goalEvery)*r.goalStep)+(kind=='places' and r.placementExtra or 0)
end
function E.roundReward(round,hits,objective,multiplier,balance)
 local r=C.rewards
 local base=r.base+r.perRound*round
 local skill=math.min(r.hitCap,hits)*r.perHit
 local requested=math.floor((base+skill+objective)*multiplier+.5)
 local credited=math.max(0,math.min(C.coinCap-balance,requested))
 return {base=base,skill=skill,objective=objective,requested=requested,credited=credited}
end
assert(E.validate())
return E
