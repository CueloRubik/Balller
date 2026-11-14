local M={}
function M.install()
 local oldLoad,oldUpdate=love.load,love.update
 local G=require('src.game')
 local P=require('src.progression')
 local Save=require('src.save')
 local Results=require('src.presentation.round_results')
 local frame,paid=0,nil
 local function click(x,y) love.mousepressed(x,y,1) end
 love.load=function()
  love.filesystem.setIdentity('balller_ci_flow_v8',true)
  for slot=1,3 do Save.clearRun(slot) end
  for _,file in ipairs({'perfil_balller_v7.txt','perfil_balller_v7.txt.bak','save.txt'}) do love.filesystem.remove(file) end
  oldLoad()
  P.gems=12 P.owned={true,false,false,false} P.skin=1
  assert(P.save())
  assert(G.newRun(1,2))
  G.backToMenu()
 end
 love.update=function(dt)
  oldUpdate(dt)
  frame=frame+1
  if frame==5 then click(308,620)
  elseif frame==10 then assert(G.state=='store') click(400,459)
  elseif frame==15 then assert(P.gems==12 and not P.owned[2]) click(370,478)
  elseif frame==20 then assert(P.gems==12) click(400,459)
  elseif frame==25 then click(600,478)
  elseif frame==30 then
   assert(P.gems==8 and P.skin==2 and P.owned[2])
   P.gems=0 assert(P.load() and P.gems==8 and P.skin==2)
   click(500,620)
  elseif frame==35 then assert(G.state=='collection') click(155,459)
  elseif frame==40 then assert(P.skin==1 and P.gems==8) click(116,620)
  elseif frame==45 then assert(G.state=='menu') click(780,310)
  elseif frame==50 then assert(G.state=='difficulty') click(250,293)
  elseif frame==55 then assert(G.state=='slots') click(669,204)
  elseif frame==60 then assert(G.state=='shop') click(700,620)
  elseif frame==65 then
   assert(G.state=='playing') G.spawn=10000 G.roundLeft=.001
  elseif frame==70 then
   assert(G.state=='shop' and Results.visible)
   paid=G.coins
   assert(Save.loadRun(1).coins==paid)
   click(616,523)
  elseif frame==75 then
   assert(G.state=='shop' and not Results.visible and G.coins==paid)
   click(200,620)
  elseif frame==80 then
   assert(G.state=='menu' and Save.hasRun(1))
   assert(P.load() and P.gems==8 and P.skin==1)
   print('NATIVE B2 FLOW OK: cancel, buy, persisted profile, equip, saved round and one-time summary')
   love.event.quit(0)
  end
 end
 love.focus=function() end
 love.quit=function() end
end
return M
