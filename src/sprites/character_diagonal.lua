local original=require('src.sprites.character')
local M={frames=16}
function M.draw(frame)
 local row=math.floor((frame-1)/4)
 local phase=(frame-1)%4+1
 local base= row<=1 and (row==0 and 5 or 13) or (row==2 and 5 or 13)
 love.graphics.push()
 love.graphics.rotate((row==0 or row==2) and -.12 or .12)
 original.draw(base+phase-1)
 love.graphics.pop()
end
return M
