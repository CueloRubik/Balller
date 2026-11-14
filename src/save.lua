local M={best=0,total=0,games=0,sound=true}
local function safeNum(v) return math.max(0,tonumber(v) or 0) end
function M.load()
  if not love.filesystem.getInfo("save.txt") then return end
  local data=love.filesystem.read("save.txt")
  if type(data)~="string" then return end
  local a,b,c,d=data:match("^(%d+)|(%d+)|(%d+)|([01])")
  if a then
    M.best=safeNum(a)
    M.total=safeNum(b)
    M.games=safeNum(c)
    M.sound=d=="1"
  end
end
function M.store()
  local value=table.concat({math.floor(M.best),math.floor(M.total),math.floor(M.games),M.sound and 1 or 0},"|")
  return love.filesystem.write("save.txt",value)
end
function M.record(score)
  score=math.max(0,math.floor(score))
  M.best=math.max(M.best,score)
  M.total=M.total+score
  M.games=M.games+1
  M.store()
end
return M
