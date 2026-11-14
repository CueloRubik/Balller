dofile('tests/smoke.lua')
local A=require('src.arena')
local L=require('src.presentation.hud_layout')
local Prefs=require('src.presentation.preferences')
local Themes=require('data.arena_themes')
local G=require('src.game')
local Codec=require('src.runfile')
local UI=require('src.ui')
local function intersects(a,b)
 return a.x<b.x+b.w and b.x<a.x+a.w and a.y<b.y+b.h and b.y<a.y+a.h
end
for _,name in ipairs({'header','objective','rescues','inventory','pulse','status'}) do
 local r=L[name]
 assert(not intersects(r,A),name..' must not cover playable court')
 assert(r.x>=0 and r.y>=0 and r.x+r.w<=1000 and r.y+r.h<=680)
end
assert(#L.tutorialSteps==4 and L.tutorialSteps[1]:find('WASD') and L.tutorialSteps[3]:find('Espacio'))
assert(G.startTutorial())
G.tutorialNext() assert(G.notice=='Toca la pelota')
G.tutorialNext() assert(G.notice:find('ESPACIO'))
G.tutorialNext() assert(G.notice:find('cancha'))
G.backToMenu()
for _,theme in ipairs(Themes.list) do
 Prefs.arena=theme.id
 assert(G.newRun(1,2) and G.startRound())
 G.notice='Notificación muy larga con acentos: acción, dirección, protección y más información repetida para comprobar el ancho.'
 G.noticeT=2
 G.score=99999999 G.coins=99999 G.round=999
 love.draw()
 for step=1,4 do G.tutorial=true G.tutorialStep=step love.draw() end
 G.tutorial=false
end
local clipped=UI.singleLine('Árbol, imán, protección: '..string.rep('á',40),0,0,90,UI.fonts.small)
assert(utf8.len(clipped) and UI.fonts.small:getWidth(clipped)<=90 and clipped:sub(-3)=='...')
local function simulate(reduced)
 Prefs.arena='patio' Prefs.reduced=reduced
 love.math.setRandomSeed(312)
 assert(G.newRun(1,2) and G.startRound())
 G.t=0 G.shake=8
 for _=1,300 do G.update(.02) love.draw() end
 return assert(Codec.encode(assert(G.snapshot())))
end
local normal=simulate(false)
assert(normal==simulate(true),'Reduced effects must not change movement, hazards or gameplay RNG')
for _,size in ipairs({{1000,680},{800,600},{1280,720},{1366,768},{1920,1080}}) do
 local w,h=size[1],size[2]
 local scale=math.min(w/1000,h/680)
 local ox,oy=(w-1000*scale)/2,(h-680*scale)/2
 love.resize(w,h)
 local function click(x,y) love.draw() love.mousepressed(ox+x*scale,oy+y*scale,1) end
 G.backToMenu() click(884,620)
 assert(G.state=='settings')
 Prefs.arena='patio' Prefs.reduced=false
 local write=love.filesystem.write
 love.filesystem.write=function(path,data) if path==Prefs.file then return false end return write(path,data) end
 click(800,458)
 assert(Prefs.arena=='patio' and not require('src.screens.visual_settings').ok)
 love.filesystem.write=write
 click(500,458)
 assert(Prefs.arena=='taller')
 click(270,539)
 assert(Prefs.reduced)
 Prefs.arena='patio' Prefs.reduced=false
 assert(Prefs.load() and Prefs.arena=='taller' and Prefs.reduced)
end
print('B3 HUD: no arena overlap, three themes, four tutorial steps, UTF-8 truncation and cosmetic-only reduced effects OK')
