local M={visible=false,data=nil}
function M.show(game)
 if game.state~='shop' or (game.previousRound or 0)<1 then return false end
 M.data={round=game.previousRound,hits=game.previousHits or 0,coins=game.reward or 0,gems=game.gemsReward or 0,score=math.floor(game.score),nextRound=game.round}
 M.visible=true
 return true
end
function M.hide() M.visible=false M.data=nil end
return M
