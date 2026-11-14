local C=require("src.theme")
local U=require("src.util")
local UI={}
local lg=love.graphics
UI.fonts={}
function UI.load()
  UI.fonts.small=lg.newFont(14)
  UI.fonts.body=lg.newFont(19)
  UI.fonts.title=lg.newFont(43)
  UI.fonts.big=lg.newFont(63)
end
function UI.color(c,a) lg.setColor(c[1],c[2],c[3],a or 1) end
function UI.rect(x,y,w,h,r,c)
  UI.color(c)
  lg.rectangle("fill",x,y,w,h,r,r)
end
function UI.label(s,x,y,font,c,align,w)
  lg.setFont(font or UI.fonts.body)
  UI.color(c or C.ink)
  if align then lg.printf(s,x,y,w or 300,align) else lg.print(s,x,y) end
end
function UI.button(x,y,w,h,label,c,mx,my)
  local hover=mx>=x and mx<=x+w and my>=y and my<=y+h
  UI.rect(x,y+5,w,h,15,C.shadow)
  UI.rect(x,y,w,h,15,c)
  if hover then
    UI.color(C.paper,.19)
    lg.rectangle("fill",x,y,w,h,15,15)
  end
  UI.label(label,x,y+h/2-12,UI.fonts.body,C.paper,"center",w)
  return {x=x,y=y,w=w,h=h}
end
function UI.panel(x,y,w,h)
  UI.rect(x,y+7,w,h,22,{.64,.81,.82})
  UI.rect(x,y,w,h,22,C.paper)
end
function UI.hit(button,x,y) return U.pointRect(x,y,button) end
return UI
