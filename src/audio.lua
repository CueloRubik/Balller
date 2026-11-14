local M={enabled=true,sounds={}}
function M.load()
  local config={hit={440,.11,.25},coin={660,.09,.2},place={520,.10,.2},warn={290,.18,.15},lose={165,.35,.22},button={720,.07,.13}}
  for name,v in pairs(config) do
    local rate=22050
    local samples=math.floor(rate*v[2])
    local data=love.sound.newSoundData(samples,rate,16,1)
    for i=0,samples-1 do
      local t=i/rate
      local env=(1-i/samples)^2
      local tone=math.sin(2*math.pi*v[1]*t)+.18*math.sin(4*math.pi*v[1]*t)
      data:setSample(i,tone*env*v[3])
    end
    M.sounds[name]=love.audio.newSource(data,"static")
  end
end
function M.play(name)
  if not M.enabled then return end
  local src=M.sounds[name]
  if src then src:stop() src:play() end
end
return M
