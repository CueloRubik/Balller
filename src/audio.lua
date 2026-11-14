local M={enabled=true, sounds={}}
function M.load()
    local config={hit={440,0.11,0.25},coin={660,0.09,0.2},place={520,0.10,0.2},warn={290,0.18,0.15},lose={165,0.35,0.22},button={720,0.07,0.13},round={530,0.42,0.23}}
    for name,v in pairs(config) do
        local rate=22050
        local samples=math.floor(rate*v[2])
        local data=love.sound.newSoundData(samples,rate,16,1)
        for i=0,samples-1 do
            local t=i/rate
            local envelope=(1-i/samples)^2
            local freq=v[1]
            if name=='round' then
                if t>.28 then freq=784 elseif t>.14 then freq=659 end
            end
            local tone=math.sin(2*math.pi*freq*t)+0.18*math.sin(2*math.pi*freq*2*t)
            data:setSample(i,tone*envelope*v[3])
        end
        M.sounds[name]=love.audio.newSource(data,"static")
    end
end
function M.play(name,pitch)
    if not M.enabled then return end
    local source=M.sounds[name]
    if source then source:stop() source:setPitch(pitch or 1) source:play() end
end
return M
