local T=require('tests.support.headless')
local Themes=require('data.arena_themes')
local Prefs=require('src.presentation.preferences')
T.files['partida_1.txt']='existing run'
T.files['perfil_balller_v7.txt']='existing profile'
assert(not Prefs.load() and Prefs.arena=='patio' and not Prefs.reduced)
for _,theme in ipairs(Themes.list) do
 assert(Prefs.setArena(theme.id) and Prefs.arena==theme.id)
 local Reloaded=T.reload('src.presentation.preferences')
 assert(Reloaded.load() and Reloaded.arena==theme.id)
end
assert(Prefs.setReduced(true))
local bytes=T.files[Prefs.file]
assert(not Prefs.setArena('unknown') and not Prefs.setReduced('true') and T.files[Prefs.file]==bytes)
T.blocked[Prefs.file]=true
assert(not Prefs.setArena('patio') and Prefs.arena=='ciudad')
assert(not Prefs.setReduced(false) and Prefs.reduced)
assert(T.files[Prefs.file]==bytes)
T.blocked[Prefs.file]=nil
for _,bad in ipairs({'BALLLER_VISUAL_1|unknown|1','BALLLER_VISUAL_2|ciudad|1','BALLLER_VISUAL_1|taller|true','BALLLER_VISUAL_1|patio|0\n','x',''}) do
 T.files[Prefs.file]=bad
 assert(not Prefs.load() and Prefs.arena=='patio' and not Prefs.reduced)
end
assert(T.files['partida_1.txt']=='existing run' and T.files['perfil_balller_v7.txt']=='existing profile')
print('B3 preferences: three ids, restart, invalid data, failed writes and run/profile isolation OK')
