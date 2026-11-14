local T=require('tests.support.headless')
local P=require('src.progression')
local PP=require('src.profile_purchase')
local Codec=require('src.profilefile')
local function setup()
 T.files={} T.blocked={}
 P.gems=12 P.skin=1 P.owned={true,false,false,false} P.dirty=false
 assert(P.save())
end
for _,path in ipairs({PP.file,'perfil_balller_v7.txt.bak','perfil_balller_v7.txt'}) do
 setup() T.blocked[path]=true
 assert(not P.unlock(2) and P.gems==12 and not P.owned[2] and P.skin==1)
 T.blocked={} assert(P.load())
 assert(P.gems==12 and not P.owned[2])
 assert(P.unlock(2) and P.gems==8 and P.skin==2)
 assert(P.load() and P.gems==8 and P.owned[2])
end
setup()
local remove=love.filesystem.remove
love.filesystem.remove=function(path) if path==PP.file then return false end return remove(path) end
assert(not P.unlock(2) and P.gems==12 and not P.owned[2])
assert(Codec.decode(T.files['perfil_balller_v7.txt']).gems==8)
love.filesystem.remove=remove
assert(P.load() and P.gems==12 and not P.owned[2])
setup()
love.filesystem.remove=function(path)
 local result=remove(path)
 if path==PP.file then error('interrupted after commit') end
 return result
end
assert(not pcall(P.unlock,2))
love.filesystem.remove=remove
assert(P.load() and P.gems==8 and P.skin==2)
assert(P.unlock(2) and P.gems==8,'Re-equipping is free')
T.blocked['perfil_balller_v7.txt']=true
assert(not P.unlock(1) and P.skin==2 and P.gems==8)
T.blocked={} assert(P.load() and P.skin==2 and P.gems==8)
local write=love.filesystem.write
setup()
love.filesystem.write=function(path,data)
 local result=write(path,data)
 if path=='perfil_balller_v7.txt' then T.files[path]=data..'BAD' end
 return result
end
assert(not P.unlock(2) and P.gems==12)
love.filesystem.write=write
assert(P.load() and P.gems==12 and not P.owned[2])
T.files[PP.file]='PARTIAL'
assert(P.load() and T.files[PP.file..'.damaged']=='PARTIAL')
print('D2 cosmetics: failed writes/readbacks/commit, interrupted restart, no duplicate charge and free equipment recovery OK')
