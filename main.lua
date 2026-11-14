local C=require("src.theme")
local U=require("src.util")
local UI=require("src.ui")
local Art=require("src.art")
local Game=require("src.game")
local Save=require("src.save")
local Sound=require("src.audio")
local FX=require("src.particles")
local Hazards=require("src.hazards")
local Objects=require("src.objects")

local width,height=1000,680
local sx,sy,ox,oy=1,1,0,0
local buttons={}
local mouseX,mouseY=0,0

local function resize(w,h)
  local scale=math.min(w/width,h/height)
  sx,sy=scale,scale
  ox=(w-width*scale)/2
  oy=(h-height*scale)/2
end
local function toLogical(x,y)
  return (x-ox)/sx,(y-oy)/sy
end
local function addButton(id,x,y,w,h,label,color)
  buttons[#buttons+1]={id=id,rect=UI.button(x,y,w,h,label,color,mouseX,mouseY)}
end
local function header()
  UI.panel(34,20,932,75)
  UI.label("BALLLER",57,35,UI.fonts.title,C.mintDark)
  if Game.state=="playing" or Game.state=="pause" or Game.state=="over" then
    UI.label("PUNTOS",310,33,UI.fonts.small,C.muted)
    UI.label(string.format("%06d",math.floor(Game.score)),310,52,UI.fonts.body,C.ink)
    UI.label("MONEDAS",505,33,UI.fonts.small,C.muted)
    UI.label(tostring(Game.coins),505,52,UI.fonts.body,C.ink)
    UI.label("TIEMPO",660,33,UI.fonts.small,C.muted)
    UI.label(string.format("%02d:%02d",math.floor(Game.time/60),math.floor(Game.time%60)),660,52,UI.fonts.body,C.ink)
    addButton("pause",827,34,118,44,"PAUSA",C.blue)
  else
    UI.label("Protege la pelota",310,50,UI.fonts.body,C.muted)
    UI.label("RECORD  "..math.floor(Save.best),747,48,UI.fonts.body,C.ink)
  end
end
local function store()
  UI.label("OBJETOS",38,564,UI.fonts.small,C.muted)
  for i,item in ipairs(Objects.types) do
    local x=34+(i-1)*206
    local y=588
    local active=Objects.selected==i
    UI.rect(x,y+3,196,66,14,active and C.mintDark or {.67,.79,.78})
    UI.rect(x,y,196,64,14,active and C.paper or {.98,.99,.96})
    UI.color(active and C.mint or C.blue)
    love.graphics.circle("fill",x+28,y+29,15)
    UI.label(i.."  "..item.name,x+52,y+9,UI.fonts.body,C.ink)
    UI.label(item.cost.." monedas",x+52,y+36,UI.fonts.small,C.muted)
    buttons[#buttons+1]={id="item"..i,rect={x=x,y=y,w=196,h=66}}
  end
  UI.label("WASD O FLECHAS",667,594,UI.fonts.small,C.muted)
  UI.label("Mover personaje",667,614,UI.fonts.small,C.ink)
  UI.label("CLIC: COLOCAR",828,594,UI.fonts.small,C.muted)
  UI.label("P: PAUSA",828,615,UI.fonts.small,C.ink)
end
local function menu()
  UI.panel(232,112,536,504)
  Art.mascot(500,229,1.1,Game.t)
  UI.label("BALLLER",279,294,UI.fonts.big,C.ink,"center",442)
  UI.label("¡Que no se pierda la pelota!",297,369,UI.fonts.body,C.muted,"center",406)
  addButton("play",344,424,312,59,"JUGAR",C.mint)
  addButton("help",344,501,150,52,"COMO JUGAR",C.blue)
  addButton("sound",506,501,150,52,Save.sound and "SONIDO: SI" or "SONIDO: NO",C.lilac)
  UI.label("RECORD: "..math.floor(Save.best),350,575,UI.fonts.small,C.muted,"center",300)
end
local function help()
  UI.panel(200,122,600,464)
  UI.label("COMO JUGAR",236,155,UI.fonts.title,C.ink)
  local lines={
    "Muevete con WASD o con las flechas.",
    "Toca la pelota para enviarla lejos del peligro.",
    "Esquiva pinchos y alcantarillas abiertas.",
    "Gana monedas y coloca defensas con un clic.",
    "1: Escudo    2: Impulso    3: Tapa",
    "La tapa protege las alcantarillas.",
    "Consigue la mayor puntuacion posible."
  }
  for i,line in ipairs(lines) do
    UI.label(line,239,224+(i-1)*37,UI.fonts.body,C.ink)
  end
  addButton("back",347,515,306,50,"VOLVER",C.blue)
end
local function overlay(title,subtitle,mode)
  UI.color(C.ink,.34)
  love.graphics.rectangle("fill",0,0,width,height)
  UI.panel(234,170,532,347)
  UI.label(title,263,215,UI.fonts.title,C.ink,"center",474)
  UI.label(subtitle,263,295,UI.fonts.body,C.muted,"center",474)
  if mode=="pause" then
    addButton("resume",354,367,292,55,"CONTINUAR",C.mint)
    addButton("home",354,438,292,49,"MENU PRINCIPAL",C.blue)
  else
    UI.label("PUNTOS: "..math.floor(Game.score),351,344,UI.fonts.body,C.ink,"center",298)
    addButton("replay",354,393,292,53,"OTRA PARTIDA",C.mint)
    addButton("home",354,458,292,43,"MENU PRINCIPAL",C.blue)
  end
end

function love.load()
  UI.load()
  Save.load()
  Sound.load()
  Sound.enabled=Save.sound
  resize(love.graphics.getDimensions())
  love.math.setRandomSeed(os.time())
end
function love.resize(w,h)
  resize(w,h)
end
function love.update(dt)
  dt=math.min(dt,.04)
  Game.update(dt)
  mouseX,mouseY=toLogical(love.mouse.getPosition())
end
function love.draw()
  love.graphics.push()
  love.graphics.translate(ox,oy)
  love.graphics.scale(sx,sy)
  buttons={}
  Art.background(Game.t)
  if Game.state=="menu" then
    header()
    menu()
  elseif Game.state=="help" then
    header()
    help()
  else
    Art.field()
    love.graphics.push()
    if Game.shake>0 then
      love.graphics.translate((love.math.random()-.5)*Game.shake,(love.math.random()-.5)*Game.shake)
    end
    Art.hazards(Hazards.list,Game.t)
    Art.objects(Objects.list)
    FX.draw()
    Art.ball(Game.ball)
    Art.player(Game.player)
    love.graphics.pop()
    header()
    store()
    if Game.noticeT>0 and Game.state=="playing" then
      UI.rect(317,130,366,39,12,C.paper)
      UI.label(Game.notice,330,139,UI.fonts.body,C.ink,"center",340)
    end
    if Game.state=="pause" then overlay("EN PAUSA","Tu pelota esta a salvo por ahora.","pause") end
    if Game.state=="over" then overlay("FIN DE PARTIDA",Game.reason,"over") end
  end
  love.graphics.pop()
end
local function click(id)
  Sound.play("button")
  if id=="play" or id=="replay" then Game.start()
  elseif id=="help" then Game.state="help"
  elseif id=="back" or id=="home" then Game.state="menu"
  elseif id=="pause" or id=="resume" then Game.togglePause()
  elseif id=="sound" then
    Save.sound=not Save.sound
    Sound.enabled=Save.sound
    Save.store()
  elseif id:sub(1,4)=="item" then
    Objects.selected=tonumber(id:sub(5)) or 1
  end
end
function love.mousepressed(x,y,button)
  if button~=1 then return end
  x,y=toLogical(x,y)
  for i=#buttons,1,-1 do
    if UI.hit(buttons[i].rect,x,y) then
      click(buttons[i].id)
      return
    end
  end
  if Game.state=="playing" then Game.place(x,y) end
end
function love.keypressed(key)
  if key=="escape" or key=="p" then
    if Game.state=="help" then Game.state="menu"
    elseif Game.state=="playing" or Game.state=="pause" then Game.togglePause() end
  elseif key=="return" or key=="kpenter" then
    if Game.state=="menu" or Game.state=="over" then Game.start() end
  elseif Game.state=="playing" then
    local n=tonumber(key)
    if n and n>=1 and n<=3 then Objects.selected=n end
  end
end
