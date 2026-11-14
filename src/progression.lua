local P={gems=0,stars=0,hits=0,rounds=0,plays=0,best={0,0,0,0},owned={true,false,false,false},skin=1,dirty=false}
P.skins={
 {name='Original',sprite='ball',desc='La pelota de siempre'},
 {name='Océano',sprite='ball_ocean',desc='Azul brillante'},
 {name='Fresa',sprite='ball_berry',desc='Rosada y divertida'},
 {name='Galaxia',sprite='ball_violet',desc='Morada y luminosa'}
}
for i,skin in ipairs(P.skins) do skin.cost=require('data.economy').skinCosts[i] end
P.achievements={
 {id='hits',name='Buen toque',hint='Golpea 50 veces la pelota',target=50,icon='star'},
 {id='stars',name='Coleccionista',hint='Atrapa 20 estrellas',target=20,icon='spark'},
 {id='rounds',name='Superviviente',hint='Supera 10 rondas',target=10,icon='flag'},
 {id='plays',name='Siempre listo',hint='Juega 5 partidas',target=5,icon='play'}
}
local file='perfil_balller_v7.txt'
local Codec=require('src.profilefile')
local Rewards=require('src.reward_transaction')
local Purchase=require('src.profile_purchase')
function P.purchasePending() return Purchase.pending() end
function P.resolvePurchase() return Purchase.recover() end
function P.export() return Codec.encode(P) end
function P.import(data)
 local decoded=Codec.decode(data)
 if not decoded then return false end
 for k,v in pairs(decoded) do P[k]=v end
 P.dirty=false
 return true
end
local read=P.import
function P.load()
 if Rewards.pending() or not Purchase.recover() then return false end
 local data=love.filesystem.read(file)
 if read(data) then return true end
 local backup=love.filesystem.read(file..'.bak')
 if read(backup) then love.filesystem.write(file,backup) return true end
 return false
end
function P.save()
 if Rewards.pending() or not Purchase.recover() then return false end
 local previous=love.filesystem.read(file)
 if Codec.decode(previous) then
  if not love.filesystem.write(file..'.bak',previous) then return false end
 end
 local encoded=P.export()
 local ok=love.filesystem.write(file,encoded) and love.filesystem.read(file)==encoded
 if ok then P.dirty=false end
 return ok
end
function P.track(kind,n)
 if kind~='hits' and kind~='stars' and kind~='rounds' and kind~='plays' then return end
 local old=P[kind]
 P[kind]=math.min(10000000,old+(n or 1))
 for _,a in ipairs(P.achievements) do
  if a.id==kind and old<a.target and P[kind]>=a.target then
   P.gems=math.min(10000000,P.gems+2)
  end
 end
 P.dirty=true
end
function P.awardRound(round,mode,defer)
 local id=math.max(1,math.min(4,math.floor(tonumber(mode) or 2)))
 local prev=P.best[id]
 local gems=0
 if round>prev then
  for n=prev+1,math.min(round,999) do
   if n%3==0 then gems=gems+(n%9==0 and 3 or 2) end
  end
  P.best[id]=round
 end
 P.gems=math.min(10000000,P.gems+gems)
 P.track('rounds',1)
 if not defer then P.save() end
 return gems
end
function P.unlock(index)
 if Rewards.pending() then return false,'Guarda primero los premios pendientes.' end
 if not Purchase.recover() then return false,'No se pudo revisar la compra pendiente.' end
 local item=P.skins[index]
 if not item then return false,'Apariencia desconocida' end
 local oldGems,oldSkin,oldOwned=P.gems,P.skin,P.owned[index]
 local before=P.export()
 if not P.owned[index] then
  if P.gems<item.cost then return false,'Te faltan '..(item.cost-P.gems)..' gemas' end
  P.gems=P.gems-item.cost
  P.owned[index]=true
 end
 P.skin=index
 if not Purchase.commit(before,P.export()) then
  P.gems,P.skin,P.owned[index]=oldGems,oldSkin,oldOwned
  return false,'No se pudo guardar. La compra no se ha aplicado.'
 end
 P.dirty=false
 return true,oldOwned and 'Equipada' or '¡Nueva pelota!'
end
function P.nextMilestone(mode)
 local best=P.best[mode]
 if not best or best>=999 then return nil end
 local round=(math.floor(best/3)+1)*3
 return {round=round,gems=round%9==0 and 3 or 2,progress=best%3}
end
function P.skinSprite() return P.skins[P.skin].sprite end
function P.progress(a)
 local n=P[a.id] or 0
 return math.min(n,a.target),a.target
end
return P
