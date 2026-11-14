local T={list={
 {id='patio',name='Patio',image='arena-patio',color={.23,.75,.53}},
 {id='taller',name='Taller',image='arena-taller',color={.27,.61,.89}},
 {id='ciudad',name='Ciudad',image='arena-ciudad',color={.59,.48,.86}}
}}
T.byId={}
for _,theme in ipairs(T.list) do T.byId[theme.id]=theme end
return T
