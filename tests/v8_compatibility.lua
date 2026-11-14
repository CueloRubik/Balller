local T=require('tests.support.headless')
local Save=require('src.save')
local Codec=require('src.runfile')
local G=require('src.game')
for version=4,7 do
 local original=T.fixture('run-v'..version..'.txt')
 local decoded=assert(Codec.decode(original),'Cannot read v'..version)
 assert(decoded.round==6 and decoded.coins==133 and decoded.score==1560)
 assert(decoded.inventory[2]==3 and decoded.inventory[6]==1)
 assert(decoded.difficulty==(version<6 and 2 or 4))
 assert(decoded.boots==(version<5 and 0 or 2))
 assert(decoded.inventory[8]==(version<6 and 0 or 2))
 assert(#decoded.hazards==1 and #decoded.objects==1)
 for slot=1,3 do
  T.files['partida_'..slot..'.txt']=original
 end
 for slot=1,3 do
  local path='partida_'..slot..'.txt'
  assert(G.loadRun(slot) and G.state=='pause' and G.slot==slot)
  assert(T.files[path]==original,'Loading must not rewrite a valid historical file')
  assert(G.difficulty==(version<6 and 2 or 4))
  assert(G.coins==133 and G.score==1560 and G.inventory[2]==3)
  G.coins=133+slot
  assert(G.saveRun())
  assert(T.files[path..'.bak']==original,'First update must preserve original bytes')
  assert(Save.loadRun(slot).coins==133+slot)
  for other=slot+1,3 do assert(T.files['partida_'..other..'.txt']==original) end
 end
 for slot=1,3 do
  local path='partida_'..slot..'.txt'
  T.files[path]='CORRUPT'
  assert(Save.loadRun(slot).coins==133,'Each slot must recover its own backup')
  assert(T.files[path]==original)
 end
 local one,three=T.files['partida_1.txt'],T.files['partida_3.txt']
 assert(Save.clearRun(2) and not Save.hasRun(2))
 assert(not T.files['partida_2.txt.bak'])
 assert(T.files['partida_1.txt']==one and T.files['partida_3.txt']==three)
 assert(G.newRun(2,1) and Save.loadRun(2).round==1)
 assert(T.files['partida_1.txt']==one and T.files['partida_3.txt']==three)
 local before=T.files['partida_2.txt']
 T.blocked['partida_2.txt.bak']=true
 assert(not G.saveRun() and T.files['partida_2.txt']==before)
 T.blocked['partida_2.txt.bak']=nil
 local snapshot=assert(G.snapshot())
 snapshot.coins=-1
 assert(not Save.storeRun(snapshot,0) and not Save.loadRun(4))
 local reloaded=T.reload('src.save')
 assert(reloaded.loadRun(1).coins==133 and reloaded.loadRun(3).coins==133)
end
local file='perfil_balller_v7.txt'
local original=T.fixture('profile-v7.txt')
T.files[file]=original
local P=T.reload('src.progression')
assert(P.load() and P.gems==24 and P.skin==4 and P.owned[2] and P.owned[4])
assert(not P.owned[3] and P.best[4]==12)
assert(T.files[file]==original)
assert(P.save() and T.files[file..'.bak']==original)
T.files[file]='CORRUPT'
P=T.reload('src.progression')
assert(P.load() and P.gems==24 and P.skin==4 and T.files[file]==original)
assert(Save.clearRun(2) and T.files[file]==original,'Deleting a run must preserve collection')
print('v8 baseline: v4-v7 fixtures, three isolated slots, restart, backup, write failure and v7 profile OK')
