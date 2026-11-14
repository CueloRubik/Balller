local T=require('tests.support.headless')
local file='perfil_balller_v7.txt'
local P=require('src.progression')
T.files[file]=T.fixture('profile-v7.txt')
assert(P.load())
local original=T.files[file]
local gems,skin=P.gems,P.skin
T.blocked[file..'.bak']=true
local ok=P.unlock(3)
assert(not ok and P.gems==gems and P.skin==skin and not P.owned[3])
assert(T.files[file]==original,'Backup failure must preserve the original profile')
T.blocked[file..'.bak']=nil
T.blocked[file]=true
ok=P.unlock(3)
assert(not ok and P.gems==gems and P.skin==skin and not P.owned[3])
assert(T.files[file]==original and T.files[file..'.bak']==original)
ok=P.unlock(2)
assert(not ok and P.skin==skin and P.gems==gems,'Failed equipment save must roll back')
T.blocked[file]=nil
assert(P.unlock(3) and P.gems==gems-8 and P.skin==3)
local new=T.reload('src.progression')
assert(new.load() and new.gems==gems-8 and new.skin==3 and new.owned[3])
assert(new.unlock(3) and new.gems==gems-8)
print('B2 persistence: purchase and equipment roll back on backup/main write errors; restart preserves paid collection OK')
