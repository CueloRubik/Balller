local R={}
function R.get(round)
 round=math.max(1,math.floor(round or 1))
 if round%7==0 then
  return {name='RONDA RESCATE',desc='Un rescate extra para practicar.',color={.25,.72,.85},stars=4,interval=6.5,spawn=1.08,rescue=1,reward=1}
 elseif round%5==0 then
  return {name='RONDA TORMENTA',desc='Más peligros. ¡Mantente atento!',color={.94,.46,.38},stars=5,interval=6.2,spawn=.78,rescue=0,reward=1.2}
 elseif round%3==0 then
  return {name='FIEBRE ESTELAR',desc='Aparecen más estrellas por atrapar.',color={1,.72,.25},stars=9,interval=3.5,spawn=1.08,rescue=0,reward=1}
 end
 return {name='RONDA CLÁSICA',desc='Protege la pelota hasta el final.',color={.29,.76,.53},stars=5,interval=6.5,spawn=1,rescue=0,reward=1}
end
return R
