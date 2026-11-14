package.path="./?.lua;./?/init.lua;"..package.path
local calls=0
local function noop() calls=calls+1 end
local graphics={}
for _,name in ipairs({"clear","setColor","rectangle","circle","line","arc","polygon","ellipse","setLineWidth","setScissor","push","pop","translate","scale","print","printf","setFont","draw"}) do
  graphics[name]=noop
end
graphics.newFont=function(size) return {} end
graphics.getDimensions=function() return 1000,680 end
graphics.newImage=function() return {setFilter=noop} end
graphics.newQuad=function() return {} end
local keyboard={isDown=function() return false end}
local data={setSample=noop}
local filesystem={getInfo=function() return nil end,read=function() return nil end,write=function() return true end}
local source={play=noop,stop=noop}
love={
  graphics=graphics,
  keyboard=keyboard,
  filesystem=filesystem,
  sound={newSoundData=function() return data end},
  audio={newSource=function() return source end},
  math={random=math.random,setRandomSeed=math.randomseed},
  mouse={getPosition=function() return 500,300 end}
}
dofile("main.lua")
love.load()
love.draw()
love.keypressed("return")
for i=1,360 do
  love.update(1/60)
  love.draw()
end
love.keypressed("1")
love.mousepressed(420,320,1)
love.keypressed("p")
love.draw()
love.keypressed("p")
love.draw()
assert(calls>100,"Draw calls were not triggered")
print("Balller smoke test OK")
