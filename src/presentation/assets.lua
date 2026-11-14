local M={images={},quads={},loaded=false}
local names={'play','pause','home','help','sound','mute','coin','trophy','clock','star','check','arrows','warning','spark','flag','bag','save','plus','gem','ball','medal','gear','next','back','shop','delete','lock','music','chapter','shield','upgrade','objective'}
local iconIndex={}
for i,name in ipairs(names) do iconIndex[name]=i-1 end
function M.load()
 M.images={} M.quads={}
 for _,name in ipairs({'surfaces','icons','backdrop','home-court'}) do
  local path='assets/ui/'..name..'.png'
  if love.filesystem.getInfo(path) then
   local ok,image=pcall(love.graphics.newImage,path)
   if ok then
    image:setFilter('linear','linear')
    M.images[name]=image
   else print('[Balller UI] Cannot load '..path..': '..tostring(image)) end
  end
 end
 M.loaded=true
end
local function quad(key,x,y,w,h,image)
 if not M.quads[key] then
  local iw,ih=image:getDimensions()
  M.quads[key]=love.graphics.newQuad(x,y,w,h,iw,ih)
 end
 return M.quads[key]
end
function M.image(name,x,y,w,h)
 local image=M.images[name]
 if not image then return false end
 local iw,ih=image:getDimensions()
 love.graphics.push('all')
 love.graphics.setColor(1,1,1,1)
 love.graphics.draw(image,x,y,0,w/iw,h/ih)
 love.graphics.pop()
 return true
end
function M.icon(name,x,y,size)
 local image=M.images.icons
 local index=iconIndex[name]
 if not image or not index then return false end
 local q=quad('icon-'..name,(index%8)*64,math.floor(index/8)*64,64,64,image)
 love.graphics.push('all')
 love.graphics.setColor(1,1,1,1)
 love.graphics.draw(image,q,x-size/2,y-size/2,0,size/64,size/64)
 love.graphics.pop()
 return true
end
function M.surface(column,row,x,y,w,h)
 local image=M.images.surfaces
 if not image then return false end
 local g=love.graphics
 local edgeX,edgeY=math.min(24,w/2),math.min(24,h/2)
 local source={0,24,104,128}
 local dx,dy={x,x+edgeX,x+w-edgeX,x+w},{y,y+edgeY,y+h-edgeY,y+h}
 g.push('all')
 g.setColor(1,1,1,1)
 for j=1,3 do for i=1,3 do
  local sw,sh=source[i+1]-source[i],source[j+1]-source[j]
  local dw,dh=dx[i+1]-dx[i],dy[j+1]-dy[j]
  if dw>0 and dh>0 then
   local key=table.concat({column,row,i,j},'-')
   local q=quad(key,column*128+source[i],row*128+source[j],sw,sh,image)
   g.draw(image,q,dx[i],dy[j],0,dw/sw,dh/sh)
  end
 end end
 g.pop()
 return true
end
function M.palette(color)
 local palettes={{.14,.73,.55},{.20,.54,.86},{.93,.67,.20},{.57,.44,.86},{.93,.38,.46},{.98,.99,.96}}
 local chosen,best=1,math.huge
 for i,c in ipairs(palettes) do
  local distance=(c[1]-color[1])^2+(c[2]-color[2])^2+(c[3]-color[3])^2
  if distance<best then chosen,best=i,distance end
 end
 return chosen-1
end
return M
