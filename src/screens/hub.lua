local UI=require('src.ui')
local C=require('src.theme')
local Icons=require('src.icons')
local Sprites=require('src.sprites')
local Assets=require('src.presentation.assets')
local P=require('src.progression')
local G=require('src.game')
local Difficulty=require('src.difficulty')
local H={message='',messageOk=true,challengeTab='achievements'}
local b
local function text(s,x,y,font,color,align,w) UI.label(s,x,y,font or UI.fonts.body,color or C.ink,align,w) end
local function panel(x,y,w,h,row)
 if not Assets.surface(6,row or 0,x,y,w,h) then UI.panel(x,y,w,h) end
end
local function button(id,x,y,w,h,label,color,icon,options) b(id,x,y,w,h,label,color,icon,true,options) end
function H.bind(fn) b=fn end
function H.nav(active)
 local destinations={{'menu','Jugar','play',C.mint},{'store','Tienda','shop',C.gold},{'collection','Colección','ball',C.blue},{'achievements','Retos','medal',C.lilac},{'settings','Ajustes','gear',C.blue}}
 for i,d in ipairs(destinations) do
  local x=26+(i-1)*192
  button(d[1],x,591,180,65,d[2],d[4],d[3],{selected=active==d[1]})
 end
end
local function header(title,subtitle)
 button('back',36,23,137,52,'Volver',C.blue,'back')
 text(title,185,19,UI.fonts.title)
 text(subtitle,187,67,UI.fonts.small,C.muted)
end
local function balance()
 panel(788,21,176,65,4)
 Icons.draw('gem',819,52,31,C.lilac)
 text('Gemas',845,26,UI.fonts.tiny,C.muted)
 text(tostring(P.gems),845,44,P.gems>99999 and UI.fonts.body or UI.fonts.medium)
end
local function skinCard(i,skin,mode)
 local x,y=45+(i-1)*239,170
 panel(x,y,222,324,i%2==0 and 2 or 3)
 UI.rect(x+22,y+17,178,142,66,i%2==0 and {.76,.89,1} or {.97,.91,.73})
 Sprites.draw(skin.sprite,x+111,y+86,math.floor(G.t*9)%8+1,132,mode=='collection' and not P.owned[i] and .4 or 1)
 text(skin.name,x+14,y+166,UI.fonts.medium,C.ink,'center',194)
 text(skin.desc,x+12,y+205,UI.fonts.small,C.muted,'center',198)
 if mode=='store' then
  text(P.owned[i] and 'Ya es tuya' or 'Compra permanente',x+16,y+239,UI.fonts.tiny,C.muted,'center',190)
  if P.owned[i] then
   button('collection',x+15,y+267,192,43,'En colección',C.blue,'check')
  else
   button('buySkin'..i,x+15,y+267,192,43,skin.cost..' gemas',C.lilac,P.gems>=skin.cost and 'gem' or 'lock',{disabled=P.gems<skin.cost})
  end
 else
  if P.owned[i] then
   text(P.skin==i and 'Lista para jugar' or 'Disponible',x+16,y+239,UI.fonts.tiny,C.muted,'center',190)
   button('equipSkin'..i,x+15,y+267,192,43,P.skin==i and 'Equipada' or 'Equipar',P.skin==i and C.mint or C.blue,'check',{selected=P.skin==i})
  else
   Icons.draw('lock',x+187,y+33,28,C.muted)
   text('Aún no está en tu colección',x+12,y+239,UI.fonts.tiny,C.muted,'center',198)
   button('store',x+15,y+267,192,43,'Ver tienda',C.lilac,'shop')
  end
 end
end
function H.store()
 header('Tienda de gemas','Apariencias permanentes para tu pelota.')
 balance()
 panel(60,107,880,48,4)
 Icons.draw('gem',89,130,25,C.lilac)
 text('El precio se paga una vez. La pelota se equipa al comprar.',116,119,UI.fonts.small)
 for i,skin in ipairs(P.skins) do skinCard(i,skin,'store') end
 panel(60,513,880,51,1)
 Icons.draw(H.message~='' and (H.messageOk and 'check' or 'warning') or 'help',91,537,27,H.messageOk and C.mint or C.red)
 text(H.message~='' and H.message or 'Las gemas se ganan con logros e hitos de ronda.',118,526,UI.fonts.small,C.ink,'left',788)
 H.nav('store')
end
function H.collection()
 header('Colección','Equipa las pelotas que ya conseguiste.')
 balance()
 for i,skin in ipairs(P.skins) do skinCard(i,skin,'collection') end
 panel(60,513,880,51,1)
 Icons.draw(H.message~='' and (H.messageOk and 'check' or 'warning') or 'ball',91,537,28,H.messageOk and C.mint or C.red)
 text(H.message~='' and H.message or 'Equipar es gratis. Las apariencias mantienen la misma física.',118,526,UI.fonts.small)
 H.nav('collection')
end
function H.confirmPurchase(index)
 local skin=P.skins[index]
 if not skin then return end
 UI.color(C.navy,.62) love.graphics.rectangle('fill',0,0,1000,680)
 panel(246,141,508,399,4)
 text('Confirmar compra',277,167,UI.fonts.title,C.ink,'center',446)
 Sprites.draw(skin.sprite,360,291,math.floor(G.t*9)%8+1,138)
 text(skin.name,459,239,UI.fonts.medium)
 text('Precio: '..skin.cost..' gemas',459,286,UI.fonts.body)
 text('Saldo: '..P.gems..' gemas',459,320,UI.fonts.small,C.muted)
 text('Es permanente y se equipará al confirmar.',279,379,UI.fonts.small,C.ink,'center',442)
 button('cancelPurchase',284,451,196,57,'Cancelar',C.blue,'back')
 button('confirmPurchase',512,451,196,57,'Comprar',C.lilac,'gem',{disabled=P.owned[index] or P.gems<skin.cost})
end
function H.challenges()
 header('Retos','Objetivos permanentes. Avanza a tu ritmo.')
 balance()
 button('challengeAchievements',220,103,270,46,'Logros',C.blue,'medal',{selected=H.challengeTab=='achievements'})
 button('challengeMilestones',508,103,270,46,'Hitos de ronda',C.lilac,'flag',{selected=H.challengeTab=='milestones'})
 if H.challengeTab=='achievements' then
  for i,a in ipairs(P.achievements) do
   local x,y=60+((i-1)%2)*454,173+math.floor((i-1)/2)*183
   local n,target=P.progress(a)
   panel(x,y,426,168,i%2==0 and 2 or 3)
   Icons.draw(n>=target and 'check' or a.icon,x+43,y+44,43,C.gold)
   text(a.name,x+83,y+18,UI.fonts.medium)
   text(a.hint,x+83,y+57,UI.fonts.small,C.muted)
   UI.progress(x+22,y+102,382,16,n/target,n>=target and 2 or 0)
   text(n..' / '..target,x+23,y+127,UI.fonts.small)
   text(n>=target and 'Completado · premio recibido' or 'Premio automático: 2 gemas',x+122,y+128,UI.fonts.tiny,C.muted)
  end
 else
  for i,mode in ipairs(Difficulty.list) do
   local x,y=60+((i-1)%2)*454,173+math.floor((i-1)/2)*183
   local m=P.nextMilestone(i)
   panel(x,y,426,168,i%2==0 and 2 or 3)
   Icons.draw('flag',x+43,y+44,40,mode.color)
   text(mode.short,x+83,y+17,UI.fonts.medium)
   text('Mejor ronda: '..P.best[i],x+83,y+55,UI.fonts.small,C.muted)
   local ratio=m and m.progress/3 or 1
   UI.progress(x+22,y+99,382,17,ratio,3)
   text(m and ('Ronda '..m.round..': '..m.gems..' gemas') or 'Todos los hitos completados',x+23,y+129,UI.fonts.small)
  end
 end
 text('Los premios se añaden al cumplir el objetivo; no hay que reclamarlos.',100,550,UI.fonts.small,C.muted,'center',800)
 H.nav('achievements')
end
return H
