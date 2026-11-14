local M={}
function M.clamp(v,a,b) return math.max(a,math.min(b,v)) end
function M.length(x,y) return math.sqrt(x*x+y*y) end
function M.normal(x,y)
  local d=M.length(x,y)
  if d<0.00001 then return 1,0 end
  return x/d,y/d
end
function M.dist(x,y,a,b) return M.length(x-a,y-b) end
function M.pointRect(x,y,r) return x>=r.x and x<=r.x+r.w and y>=r.y and y<=r.y+r.h end
function M.rand(a,b) return a+(b-a)*love.math.random() end
return M
