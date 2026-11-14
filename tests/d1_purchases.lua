local T=require('tests.support.headless')
local G=require('src.game')
local Save=require('src.save')
local P=require('src.progression')
local Codec=require('src.runfile')
local journal='partida_1.txt.purchase'
local function reset()
 T.blocked={}
 assert(Save.clearRun(1))
 assert(G.newRun(1,2)) G.coins=1000
 assert(G.saveSession())
end
for _,path in ipairs({journal,'partida_1.txt.bak','partida_1.txt'}) do
 reset()
 local before=G.coins local count=G.inventory[1]
 T.blocked[path]=true
 assert(not G.buy(1) and G.coins==before and G.inventory[1]==count)
 T.blocked[path]=nil
 local fresh=T.reload('src.save')
 local restored=assert(fresh.loadRun(1))
 assert(restored.coins==before and restored.inventory[1]==count)
 assert(not T.files[journal])
end
reset()
local remove=love.filesystem.remove
love.filesystem.remove=function(path) if path==journal then return false end return remove(path) end
assert(not G.buy(1) and G.coins==1000 and G.inventory[1]==1)
assert(Codec.decode(T.files['partida_1.txt']).coins==978,'Candidate was written, but is not committed while journal exists')
local inspected=Save.inspectRun(1)
assert(inspected.pendingPurchase and inspected.data.coins==1000 and T.files[journal])
love.filesystem.remove=remove
local fresh=T.reload('src.save')
local old,status=fresh.loadRun(1)
assert(old.coins==1000 and old.inventory[1]==1 and status=='purchase_recovered')
reset()
love.filesystem.remove=function(path) if path==journal then error('simulated interruption before commit') end return remove(path) end
assert(not pcall(G.buy,1) and G.coins==1000)
love.filesystem.remove=remove
assert(T.reload('src.save').loadRun(1).coins==1000,'Interruption before commit must undo')
reset()
local purchase=Save.storePurchase
Save.storePurchase=function(...)
 assert(purchase(...))
 error('simulated interruption after durable commit')
end
assert(not pcall(G.buy,1) and G.coins==1000)
Save.storePurchase=purchase
local committed=assert(T.reload('src.save').loadRun(1))
assert(committed.coins==978 and committed.inventory[1]==2 and not T.files[journal],'Committed purchase survives even before screen update')
reset()
local write=love.filesystem.write
love.filesystem.write=function(path,data)
 if path==journal then T.files[path]=data:sub(1,20) return false end
 return write(path,data)
end
assert(not G.buy(1) and G.coins==1000)
love.filesystem.write=write
assert(T.reload('src.save').loadRun(1).coins==1000)
assert(T.files[journal..'.damaged'],'Incomplete journal is preserved for diagnosis')
reset()
love.filesystem.write=function(path,data)
 if path=='partida_1.txt' then T.files[path]=data..'BAD' return true end
 return write(path,data)
end
assert(not G.buy(1) and G.coins==1000 and T.files[journal])
love.filesystem.write=write
assert(T.reload('src.save').loadRun(1).coins==1000,'Read-back mismatch must undo')
reset()
P.track('hits') T.blocked['perfil_balller_v7.txt']=true
assert(G.buy(1) and G.coins==978 and G.inventory[1]==2 and G.saveError)
assert(Save.loadRun(1).coins==978,'Unrelated profile error must not misreport a committed purchase as cancelled')
T.blocked['perfil_balller_v7.txt']=nil
assert(G.saveSession() and G.coins==978 and G.inventory[1]==2)
reset()
assert(G.buyUpgrade() and G.buyUpgrade() and G.buyUpgrade())
assert(G.boots==3 and G.coins==640 and not G.upgradeCost())
assert(not G.buyUpgrade() and G.boots==3 and G.coins==640)
assert(G.loadRun(1) and G.boots==3 and G.coins==640)
assert(G.newRun(2,4)) G.coins=777 assert(G.saveSession())
local before2,after2=G.snapshot(),G.snapshot() after2.coins=755 after2.inventory[1]=2
T.blocked['partida_2.txt']=true
assert(not Save.storePurchase(before2,after2,2))
T.blocked['partida_2.txt']=nil
T.files[journal]=T.files['partida_2.txt.purchase']
local firstCoins=assert(Codec.decode(T.files['partida_1.txt'])).coins
assert(Save.loadRun(1).coins==firstCoins,'Foreign slot journal must not restore its payload into this slot')
assert(Save.loadRun(2).coins==777)
print('D1 purchases: failure at every write/commit stage, interruptions, restart, invalid/foreign journals and max upgrades OK')
