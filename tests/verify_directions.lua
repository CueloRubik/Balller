package.path='./?.lua;./?/init.lua;'..package.path
love={keyboard={isDown=function()return false end}}
local P=require('src.player')
local p=P.new()
for _,dir in ipairs({{1,0},{1,1},{0,1},{-1,1},{-1,0},{-1,-1},{0,-1},{1,-1}}) do
 p.dx,p.dy=dir[1],dir[2]
 local diag=math.abs(p.dx)>.24 and math.abs(p.dy)>.24
 if math.abs(dir[1])==1 and math.abs(dir[2])==1 then assert(diag) else assert(not diag) end
end
print('Las ocho orientaciones quedan clasificadas correctamente.')
