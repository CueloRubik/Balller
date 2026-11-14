local M={x=34,y=112,w=932,h=440}
function M.bounds(r)
  return M.x+18+r,M.x+M.w-18-r,M.y+18+r,M.y+M.h-18-r
end
function M.contains(x,y,pad)
  pad=pad or 0
  return x>=M.x+pad and x<=M.x+M.w-pad and y>=M.y+pad and y<=M.y+M.h-pad
end
return M
