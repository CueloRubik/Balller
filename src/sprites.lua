local M={images={},frames={},size=128}
local lg=love.graphics
local names={'character','character_diagonal','ball','ball_ocean','ball_berry','ball_violet','spikes','drain','shield','boost','lid','magnet','fan','clock','saw','shock','vortex','mallet','laser','bubble','portal'}
function M.load()
 for _,name in ipairs(names) do
  local factory=require('src.sprites.'..name)
  local frames=factory.frames
  local pages={}
  local path='assets/sprites/'..name..'.png'
  if love.filesystem.getInfo(path) then
   local sheet=lg.newImage(path)
   sheet:setFilter('linear','linear')
   local w,h=sheet:getDimensions()
   assert(w==frames*M.size and h==M.size,'Sprite mal dimensionado: '..name)
   for f=1,frames do
    pages[f]={image=sheet,quad=lg.newQuad((f-1)*M.size,0,M.size,M.size,w,h)}
   end
  else
   for f=1,frames do
    local canvas=lg.newCanvas(M.size,M.size)
    lg.push('all')
    lg.setCanvas(canvas)
    lg.clear(0,0,0,0)
    lg.origin()
    lg.translate(M.size/2,M.size/2)
    lg.setBlendMode('alpha')
    lg.setLineStyle('smooth')
    factory.draw(f)
    lg.setCanvas()
    lg.pop()
    if canvas.setFilter then canvas:setFilter('linear','linear') end
    pages[f]={image=canvas}
   end
  end
  M.images[name]=pages
  M.frames[name]=frames
 end
end
function M.draw(name,x,y,frame,w,alpha,rotation)
 local pages=M.images[name]
 if not pages then return end
 local n=#pages
 local index=(math.floor(frame or 1)-1)%n+1
 local page=pages[index]
 local scale=(w or 64)/M.size
 lg.push('all')
 lg.setColor(1,1,1,alpha or 1)
 if page.quad then
  lg.draw(page.image,page.quad,x,y,rotation or 0,scale,scale,M.size/2,M.size/2)
 else
  lg.draw(page.image,x,y,rotation or 0,scale,scale,M.size/2,M.size/2)
 end
 lg.pop()
end
return M
