local T=require('tests.support.headless')
local Save=require('src.save')
local G=require('src.game')
local P=require('src.progression')
local good=T.fixture('run-v7.txt')
T.files['partida_1.txt']='CORRUPTO'
T.files['partida_1.txt.bak']=good
for _=1,5 do
 local info=Save.inspectRun(1)
 assert(info.status=='recoverable' and info.data.coins==133)
 assert(Save.slotInfo(1).round==6)
end
assert(T.files['partida_1.txt']=='CORRUPTO' and not T.files['partida_1.txt.damaged'],'Inspection must not write')
T.blocked['partida_1.txt.damaged']=true
local data,status=Save.loadRun(1)
assert(not data and status=='preserve_failed' and T.files['partida_1.txt']=='CORRUPTO')
T.blocked['partida_1.txt.damaged']=nil
T.blocked['partida_1.txt']=true
data,status=Save.loadRun(1)
assert(not data and status=='restore_failed')
assert(T.files['partida_1.txt.damaged']=='CORRUPTO' and T.files['partida_1.txt.bak']==good)
T.blocked['partida_1.txt']=nil
local read=love.filesystem.read
love.filesystem.read=function(path) if path=='partida_1.txt' then return nil end return read(path) end
data,status=Save.loadRun(1)
assert(not data and status=='preserve_failed' and T.files['partida_1.txt']=='CORRUPTO')
love.filesystem.read=read
local detail
data,status,detail=Save.loadRun(1)
assert(data and status=='recovered' and detail.archive=='partida_1.txt.damaged')
assert(T.files['partida_1.txt']==good)
T.files['partida_1.txt']='OTRO DAÑO'
assert(Save.loadRun(1))
assert(T.files['partida_1.txt.damaged']=='CORRUPTO' and T.files['partida_1.txt.damaged.1']=='OTRO DAÑO')
T.files['partida_2.txt.bak']=good
assert(Save.inspectRun(2).status=='recoverable' and Save.loadRun(2))
T.files['partida_3.txt']='CORRUPTO'
assert(Save.inspectRun(3).status=='damaged' and not Save.loadRun(3))
local before=T.files['partida_1.txt']
local snapshot=assert(Save.loadRun(1)) snapshot.coins=-1
assert(not Save.storeRun(snapshot,1) and T.files['partida_1.txt']==before,'Invalid encoded data must not replace a valid run')
local remove=love.filesystem.remove
love.filesystem.remove=function(path) if path=='partida_1.txt' then return false end return remove(path) end
assert(not Save.clearRun(1) and T.files['partida_1.txt']==before and T.files['partida_1.txt.bak']==good)
love.filesystem.remove=function(path) if path=='partida_1.txt.bak' then return false end return remove(path) end
assert(not Save.clearRun(1) and T.files['partida_1.txt.bak']==good)
love.filesystem.remove=remove
assert(Save.clearRun(1) and not Save.hasRun(1))
assert(T.files['partida_1.txt.damaged']=='CORRUPTO','Diagnostic archive is not a playable backup')
assert(Save.clearRun(3))
local plays=P.plays
T.blocked['partida_3.txt']=true
assert(not G.newRun(3,2) and not Save.hasRun(3) and P.plays==plays)
T.blocked['partida_3.txt']=nil
assert(G.newRun(3,2) and P.plays==plays+1 and Save.hasRun(3))
assert(not G.newRun(1.5,2))
print('C1 persistence: read-only inspection, archived corruption, recovery errors, safe deletion and failed creation OK')
