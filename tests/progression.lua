package.path='./?.lua;./?/init.lua;'..package.path
local files={}
love={filesystem={remove=function(path) files[path]=nil return true end,read=function(path) return files[path] end,write=function(path,s) files[path]=s return true end},math={random=math.random}}
local P=require('src.progression')
assert(P.gems==0 and P.skin==1)
assert(P.awardRound(1,1)==0)
assert(P.awardRound(3,1)==2)
assert(P.awardRound(3,1)==0,'Repetir una ronda no puede regalar gemas')
assert(P.awardRound(6,1)==2)
assert(P.gems==4)
assert(P.unlock(2) and P.skin==2 and P.gems==0)
for i=1,50 do P.track('hits') end
assert(P.gems==2,'Logro de 50 golpes suma 2 gemas')
assert(P.unlock(3)==false,'No se pueden comprar skins sin gemas')
P.save()
assert(files['perfil_balller_v7.txt'])
local oldGems=P.gems
P.gems=999
assert(P.load() and P.gems==oldGems and P.owned[2] and P.skin==2)
P.gems=P.gems+3 P.save()
files['perfil_balller_v7.txt']='CORRUPTO'
assert(P.load() and P.gems==oldGems,'Recupera perfil desde copia de respaldo')
assert(P.awardRound(9,1)==3)
assert(P.awardRound(9,1)==0)
print('Balller v7: gemas, logros, compras, guardado y respaldo OK')
