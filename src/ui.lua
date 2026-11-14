local C=require('src.theme')
local U=require('src.util')
local Icons=require('src.icons')
local Assets=require('src.presentation.assets')
local UI={fonts={}}
local g=love.graphics
local function col(c,a) g.setColor(c[1],c[2],c[3],a or c[4] or 1) end
UI.color=col
function UI.load()
 Assets.load()
 local font='assets/fonts/Nunito-ExtraBold.ttf'
 local normal='assets/fonts/Nunito-Regular.ttf'
 local bold=love.filesystem.getInfo(font) and font or nil
 local regular=love.filesystem.getInfo(normal) and normal or nil
 local function make(file,size)
  if file then
   local ok,font=pcall(g.newFont,file,size)
   if ok then return font end
  end
  return g.newFont(size)
 end
 UI.fonts.tiny=make(regular,14)
 UI.fonts.small=make(regular,17)
 UI.fonts.body=make(regular,20)
 UI.fonts.medium=make(bold,25)
 UI.fonts.title=make(bold,36)
 UI.fonts.big=make(bold,72)
 UI.fonts.number=make(bold,29)
end
function UI.rect(x,y,w,h,r,c)
 col(c)
 g.rectangle('fill',x,y,w,h,r,r)
end
function UI.outline(x,y,w,h,r,c,thickness)
 col(c)
 g.setLineWidth(thickness or 2)
 g.rectangle('line',x,y,w,h,r,r)
 g.setLineWidth(1)
end
function UI.label(s,x,y,font,c,align,w)
 g.setFont(font or UI.fonts.body)
 col(c or C.ink)
 if align then g.printf(s,x,y,w or 300,align) else g.print(s,x,y) end
end
function UI.headline(s,x,y,w,font,c)
 font=font or UI.fonts.big
 g.setFont(font)
 col(C.navy,.18)
 g.printf(s,x+2,y+4,w,'center')
 col(c or C.ink)
 g.printf(s,x,y,w,'center')
end
function UI.panel(x,y,w,h,r)
 r=r or 24
 if Assets.surface(6,0,x,y,w,h) then return end
 UI.rect(x+2,y+10,w,h,r,{.58,.72,.75})
 UI.rect(x,y+3,w,h,r,{.82,.92,.92})
 UI.rect(x,y,w,h,r,C.paper)
 UI.outline(x+1,y+1,w-2,h-2,r,{.75,.85,.87},1.7)
end
function UI.button(x,y,w,h,label,c,mouseX,mouseY,icon,compact,options)
 options=options or {}
 local hover=mouseX>=x and mouseX<=x+w and mouseY>=y and mouseY<=y+h
 local pressed=hover and not options.disabled and love.mouse and love.mouse.isDown and love.mouse.isDown(1)
 local state=options.disabled and 2 or (pressed and 1 or (options.selected and 3 or 0))
 local lift=pressed and 3 or (hover and not options.disabled and -2 or 0)
 local palette=Assets.palette(c)
 if not Assets.surface(palette,state,x,y+lift,w,h+4) then
  local r=math.min(16,h/3)
  UI.rect(x,y+6,w,h,r,C.shadow)
  UI.rect(x,y+lift,w,h,r,options.disabled and {.62,.72,.74} or c)
  UI.outline(x+1,y+lift+1,w-2,h-2,r,C.paper,1.5)
 end
 local font=compact and UI.fonts.small or UI.fonts.medium
 local iconSize=compact and 23 or 29
 local padding=icon and iconSize+8 or 0
 if font:getWidth(label)>w-28-padding then font=UI.fonts.tiny end
 local textColor=(palette==2 or palette==5) and C.ink or C.paper
 if options.disabled then textColor=C.ink end
 local tw=font:getWidth(label)
 if label=='' and icon then
  Icons.draw(icon,x+w/2,y+lift+h/2,iconSize,C.paper)
 else
  local start=x+(w-tw-padding)/2
  if icon then Icons.draw(icon,start+iconSize/2,y+lift+h/2,iconSize,C.paper) end
  UI.label(label,start+padding,y+lift+(h-font:getHeight())/2-1,font,textColor)
 end
 return {x=x,y=y,w=w,h=h}
end
function UI.pill(x,y,w,h,icon,label,value,bg,iconC)
 UI.rect(x,y+3,w,h,14,{.72,.82,.82})
 UI.rect(x,y,w,h,14,bg or C.paper)
 if icon then
  UI.rect(x+7,y+7,32,h-14,10,iconC or C.blue)
  Icons.draw(icon,x+23,y+h/2,19,C.paper)
 end
 UI.label(label,x+(icon and 47 or 12),y+7,UI.fonts.tiny,C.muted)
 UI.label(value,x+(icon and 47 or 12),y+24,UI.fonts.medium,C.ink)
end
function UI.hit(rect,x,y) return U.pointRect(x,y,rect) end
return UI
