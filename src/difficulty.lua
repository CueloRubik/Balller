local D={}
D.list={
 {id=1,key='novato',name='PRIMEROS PASOS',short='NOVATO',description='Más avisos, pelota tranquila y 2 rescates por ronda.',color={.30,.76,.57},ball=.72,spawn=1.60,warning=1.65,maxHazards=3,graces=2,roundTime=.80,unlock=2,bonus=1},
 {id=2,key='normal',name='NORMAL',short='NORMAL',description='El equilibrio clásico de Balller.',color={.27,.61,.89},ball=1,spawn=1,maxHazards=6,warning=1,graces=1,roundTime=1,unlock=0,bonus=1},
 {id=3,key='dificil',name='DESAFÍO',short='DIFÍCIL',description='Peligros más rápidos y sin rescates gratuitos.',color={.96,.54,.25},ball=1.15,spawn=.79,maxHazards=7,warning=.85,graces=0,roundTime=1.12,unlock=-1,bonus=1.3},
 {id=4,key='experto',name='EXPERTO',short='EXPERTO',description='Máxima presión. Solo para quienes dominan el juego.',color={.89,.33,.52},ball=1.29,spawn=.64,maxHazards=8,warning=.72,graces=0,roundTime=1.2,unlock=-2,bonus=1.65}
}
function D.get(id) return D.list[math.floor(tonumber(id) or 2)] or D.list[2] end
return D
