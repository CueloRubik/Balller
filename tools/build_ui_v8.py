"""Deterministic Balller UI art. Pillow 13; no network or external images."""
from pathlib import Path
import math
from PIL import Image, ImageDraw, ImageFilter

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/ui'
OUT.mkdir(parents=True,exist_ok=True)
S=3
NAVY='#153f50'
COLORS=['#24b98c','#3289dc','#edaa34','#9270db','#ee6276','#f9fcf5']

def canvas(w,h):
    im=Image.new('RGBA',(w*S,h*S)); return im,ImageDraw.Draw(im)
def box(d,xy,fill,r=10,outline=None,width=1):
    d.rounded_rectangle(tuple(round(v*S) for v in xy),radius=round(r*S),fill=fill,outline=outline,width=round(width*S))
def poly(d,pts,fill,outline=None,width=2):
    pts=[(int(x*S),int(y*S)) for x,y in pts]
    d.polygon(pts,fill=fill)
    if outline:d.line(pts+[pts[0]],fill=outline,width=round(width*S),joint='curve')
def line(d,pts,fill=NAVY,width=2.6):
    pts=[(int(x*S),int(y*S)) for x,y in pts]
    d.line(pts,fill=fill,width=round(width*S),joint='curve')
    r=width*S/2
    for x,y in [pts[0],pts[-1]]:d.ellipse((x-r,y-r,x+r,y+r),fill=fill)
def ellipse(d,xy,fill,outline=None,width=2):
    d.ellipse(tuple(int(v*S) for v in xy),fill=fill,outline=outline,width=round(width*S))
def star(d,cx,cy,r=13,fill='#ffd36c'):
    pts=[]
    for i in range(10):
        a=-math.pi/2+i*math.pi/5;rr=r if i%2==0 else r*.47
        pts.append((cx+math.cos(a)*rr,cy+math.sin(a)*rr))
    poly(d,pts,fill,NAVY,1.5)
def save(im,path):im.resize((im.width//S,im.height//S),Image.Resampling.LANCZOS).save(path,optimize=True)

# 6 palettes x 4 states; empty centers and fixed-width borders for nine-slice.
atlas=Image.new('RGBA',(1024,640))
for palette,color in enumerate(COLORS):
    for state in range(4):
        im,d=canvas(128,128)
        fill='#b1c6c9' if state==2 else color
        edge='#607e89' if state==2 else NAVY
        top=9 if state==1 else 3
        box(d,(5,10,123,125),'#174958',23)
        box(d,(5,top,123,116+top),fill,23,edge,2)
        box(d,(10,top+5,118,109+top),None,18,'#ffffff85',2)
        line(d,[(24,top+9),(103,top+9)],'#ffffff65',2)
        if state==3:
            box(d,(1,0,127,127),None,25,'#ffce60',3)
        atlas.alpha_composite(im.resize((128,128),Image.Resampling.LANCZOS),(palette*128,state*128))
for i,color in enumerate(['#fffdf5','#e3f6f0','#eaf3ff','#fff1d3','#efe9fc']):
    im,d=canvas(128,128)
    box(d,(5,11,123,126),'#17495835',21)
    box(d,(4,3,124,118),color,21,NAVY,1.5)
    box(d,(9,8,119,113),None,17,'#ffffffcf',2)
    atlas.alpha_composite(im.resize((128,128),Image.Resampling.LANCZOS),(768,i*128))
atlas.save(OUT/'surfaces.png',optimize=True)

# Illustrated progress tracks and fills: four palettes, two 256x32 tiles per row.
meters=Image.new('RGBA',(512,128))
for row,color in enumerate(['#24b98c','#3289dc','#edaa34','#9270db']):
    for column,fill in enumerate(['#bdcfd3',color]):
        im,d=canvas(256,32)
        box(d,(1,3,255,31),'#174958',11)
        box(d,(1,1,255,28),fill,11,NAVY,1)
        line(d,[(14,6),(241,6)],'#ffffff85',2)
        meters.alpha_composite(im.resize((256,32),Image.Resampling.LANCZOS),(column*256,row*32))
meters.save(OUT/'meters.png',optimize=True)

# Icons share outlines, highlights and silhouettes with the illustrated sprites.
names=['play','pause','home','help','sound','mute','coin','trophy','clock','star','check','arrows','warning','spark','flag','bag','save','plus','gem','ball','medal','gear','next','back','shop','delete','lock','music','chapter','shield','upgrade','objective']
icons=Image.new('RGBA',(8*64,4*64))
folder=OUT/'icons';folder.mkdir(exist_ok=True)
for idx,name in enumerate(names):
    im,d=canvas(64,64)
    if name=='play':poly(d,[(22,12),(53,32),(22,52)],'#64e6b7',NAVY,3);line(d,[(27,20),(27,39)],'#e7fff4',2)
    elif name=='pause':
        for x in [17,38]:box(d,(x,12,x+11,52),'#c1e3ff',3,NAVY,2)
    elif name=='home':
        poly(d,[(12,28),(32,10),(53,28),(49,29),(49,53),(16,53),(16,28)],'#5fb5ee',NAVY,2)
        box(d,(27,35,38,53),'#fff2c8',2,NAVY,2)
    elif name=='help':
        ellipse(d,(9,9,55,55),'#7cc6ff',NAVY,2)
        d.arc((24*S,17*S,40*S,33*S),190,490,fill=NAVY,width=3*S)
        line(d,[(34,32),(32,37)],NAVY,3);ellipse(d,(30,43,34,47),NAVY,None)
    elif name in ('sound','mute'):
        poly(d,[(10,25),(20,25),(32,15),(32,49),(20,39),(10,39)],'#b5e0ff',NAVY,2)
        if name=='sound':
            for r in [10,17]:d.arc(((31-r)*S,(32-r)*S,(31+r)*S,(32+r)*S),300,420,fill=NAVY,width=3*S)
        else:line(d,[(40,24),(54,40)],'#e9566e',3);line(d,[(54,24),(40,40)],'#e9566e',3)
    elif name in ('coin','ball'):
        ellipse(d,(9,11,55,57),'#d88b28',NAVY,2)
        ellipse(d,(9,7,55,53),'#ffd165' if name=='coin' else '#f3a856',NAVY,2)
        ellipse(d,(15,13,49,47),None,'#b77727',2)
        if name=='coin':
            line(d,[(35,19),(26,19),(25,29),(37,31),(36,41),(26,41)],'#a96a22',3)
            line(d,[(32,16),(32,44)],'#a96a22',2)
        else:
            line(d,[(10,31),(54,29)],NAVY,2);d.arc((17*S,8*S,45*S,53*S),80,280,fill=NAVY,width=2*S)
        line(d,[(19,17),(26,14)],'#fff7c3',3)
    elif name=='gem':
        poly(d,[(10,24),(21,11),(43,11),(55,24),(32,55)],'#ac8afa',NAVY,2)
        poly(d,[(10,24),(25,24),(32,55)],'#7958cc')
        poly(d,[(25,24),(39,24),(32,55)],'#e3d4ff')
        line(d,[(11,24),(54,24)],NAVY,1.5);line(d,[(21,11),(25,24),(32,11),(39,24),(43,11)],NAVY,1.2)
    elif name=='trophy':
        d.arc((7*S,12*S,29*S,38*S),80,280,fill=NAVY,width=3*S)
        d.arc((35*S,12*S,57*S,38*S),260,460,fill=NAVY,width=3*S)
        box(d,(28,33,36,48),'#e4a139',2,NAVY,2);box(d,(19,47,45,54),'#ffd36c',3,NAVY,2)
        box(d,(18,9,46,37),'#ffce62',7,NAVY,2);star(d,32,22,7,'#fff1ac')
    elif name=='clock':
        box(d,(27,7,37,14),'#78b9ed',2,NAVY,2);ellipse(d,(10,13,54,57),'#b5e3fa',NAVY,2)
        ellipse(d,(15,18,49,52),'#fffdf3',None);line(d,[(32,23),(32,35),(42,40)],NAVY,3)
    elif name=='star':star(d,32,31,24)
    elif name=='check':
        ellipse(d,(9,9,55,55),'#6de0b4',NAVY,2);line(d,[(20,32),(29,41),(45,23)],'#ffffff',5)
    elif name=='arrows':
        line(d,[(17,40),(17,17),(43,17),(43,32)],NAVY,4)
        poly(d,[(35,30),(51,30),(43,42)],'#6bc6ff',NAVY,2)
        line(d,[(46,48),(23,48)],NAVY,4);poly(d,[(26,40),(13,48),(26,56)],'#79dfbd',NAVY,2)
    elif name=='warning':
        poly(d,[(32,8),(57,54),(7,54)],'#ffbc72',NAVY,2);line(d,[(32,23),(32,36)],NAVY,4);ellipse(d,(30,43,34,47),NAVY,None)
    elif name=='spark':poly(d,[(36,6),(14,35),(29,35),(25,58),(51,26),(35,26)],'#ffe28b',NAVY,2)
    elif name=='flag':
        line(d,[(17,56),(17,9)],NAVY,4);poly(d,[(19,11),(51,14),(42,25),(50,36),(19,33)],'#78dfb7',NAVY,2)
    elif name=='bag':
        box(d,(12,19,52,56),'#5eb7ed',9,NAVY,2);d.arc((22*S,7*S,42*S,29*S),180,360,fill=NAVY,width=3*S)
        box(d,(20,35,44,49),'#b5e7fa',5,NAVY,2);line(d,[(27,41),(37,41)],NAVY,2)
    elif name=='save':
        poly(d,[(11,10),(47,10),(54,17),(54,55),(11,55)],'#69b8f0',NAVY,2)
        box(d,(20,10,43,27),'#e9f7ff',2,NAVY,2);box(d,(18,35,46,55),'#edf9fa',2,NAVY,2);box(d,(34,12,39,23),NAVY,1)
    elif name=='plus':
        ellipse(d,(9,9,55,55),'#63d8b0',NAVY,2);line(d,[(21,32),(43,32)],'#ffffff',5);line(d,[(32,21),(32,43)],'#ffffff',5)
    elif name=='medal':
        poly(d,[(13,9),(25,9),(34,32),(23,36)],'#6ebcff',NAVY,2);poly(d,[(39,9),(51,9),(41,36),(30,32)],'#ef8092',NAVY,2)
        ellipse(d,(15,24,49,58),'#ffcf68',NAVY,2);star(d,32,41,10,'#fff1a6')
    elif name=='gear':
        for i in range(8):
            a=i*math.pi/4;cx=32+19*math.cos(a);cy=32+19*math.sin(a);box(d,(cx-5,cy-5,cx+5,cy+5),'#8abcf4',2,NAVY,1)
        ellipse(d,(13,13,51,51),'#8abcf4',NAVY,2);ellipse(d,(24,24,40,40),'#f7fcf4',NAVY,2)
    elif name in ('back','next'):
        if name=='back':line(d,[(28,15),(11,32),(28,49)],'#c1e3ff',7);line(d,[(13,32),(53,32)],'#c1e3ff',7)
        else:line(d,[(25,14),(43,32),(25,50)],'#c1e3ff',7)
    elif name=='shop':
        box(d,(13,24,51,54),'#fff2d2',3,NAVY,2);box(d,(36,34,46,54),'#7cd8c3',2,NAVY,2)
        poly(d,[(9,25),(16,11),(48,11),(55,25)],'#f2a95d',NAVY,2)
        for x in [17,33]:box(d,(x,12,x+7,28),'#fff0cf',1)
        line(d,[(9,27),(55,27)],NAVY,2)
    elif name=='delete':
        box(d,(20,19,45,55),'#f68a97',5,NAVY,2);box(d,(15,15,49,21),'#ffb2bd',3,NAVY,2);box(d,(26,8,38,15),'#fff0df',2,NAVY,2)
        for x in [27,37]:line(d,[(x,28),(x,45)],NAVY,2)
    elif name=='lock':
        d.arc((20*S,7*S,44*S,38*S),180,360,fill=NAVY,width=5*S);box(d,(13,26,51,55),'#becbdb',6,NAVY,2);ellipse(d,(28,35,36,43),NAVY,None);line(d,[(32,41),(32,47)],NAVY,3)
    elif name=='music':
        line(d,[(27,43),(27,15),(49,10),(49,38)],NAVY,4);line(d,[(28,22),(48,17)],'#b995ed',5)
        ellipse(d,(12,37,28,49),'#b995ed',NAVY,2);ellipse(d,(34,32,50,44),'#b995ed',NAVY,2)
    elif name=='chapter':
        poly(d,[(9,13),(29,9),(34,14),(55,10),(55,51),(35,56),(29,51),(9,55)],'#fff1bf',NAVY,2)
        line(d,[(31,15),(31,48)],NAVY,2);line(d,[(18,23),(23,26),(19,38),(26,43),(43,28)],'#57bca8',3);star(d,44,25,7)
    elif name=='shield':
        poly(d,[(12,14),(32,8),(52,14),(49,36),(43,46),(32,56),(21,46),(15,36)],'#74d8c3',NAVY,2);line(d,[(23,30),(30,37),(42,23)],'#fff9d8',4)
    elif name=='upgrade':
        poly(d,[(10,32),(32,9),(54,32),(42,32),(42,54),(22,54),(22,32)],'#7ddbad',NAVY,2);line(d,[(32,20),(32,42)],'#e7ffe7',3)
    elif name=='objective':
        for r,fill in [(23,'#f9ad8a'),(16,'#fff4d0'),(9,'#ee7184')]:ellipse(d,(32-r,32-r,32+r,32+r),fill,NAVY,1.5)
        line(d,[(32,32),(52,12)],NAVY,3);poly(d,[(48,9),(58,6),(55,17)],'#76dcbc',NAVY,1)
    save(im,folder/(name+'.png'))
    icons.alpha_composite(im.resize((64,64),Image.Resampling.LANCZOS),((idx%8)*64,(idx//8)*64))
icons.save(OUT/'icons.png',optimize=True)

# Backgrounds contain no text, so all labels remain sharp and localizable.
back,d=canvas(1000,680)
for y in range(680):
    t=y/680;color=tuple(int(a+(b-a)*t) for a,b in zip((239,250,240),(218,239,241)))
    d.rectangle((0,y*S,1000*S,(y+1)*S),fill=color)
base=back.copy()
back,d=canvas(1000,680)
for x,y,r in [(55,75,155),(960,615,195),(990,40,110)]:ellipse(d,(x-r,y-r,x+r,y+r),'#ffffff7c')
for y in range(18,680,28):
    for x in range(14,1000,28):ellipse(d,(x,y,x+2,y+2),'#1646550b')
for x,y,r in [(570,120,10),(42,537,8),(953,151,9)]:star(d,x,y,r,'#ffe5a5')
back=Image.alpha_composite(base,back)
save(back,OUT/'backdrop.png')

stage,d=canvas(600,400)
box(d,(7,15,593,395),'#184c5830',35)
box(d,(7,5,593,381),'#b8e8d1',35,NAVY,2)
# Upper sunlit sky, distant trees, raised court and planted corners.
box(d,(14,12,586,373),'#d9f6e5',29)
ellipse(d,(424,22,548,146),'#fff5ba')
for x,y,r in [(30,94,65),(88,83,48),(561,102,65),(508,111,35)]:
    ellipse(d,(x-r,y-r,x+r,y+r),'#9ed6bb')
box(d,(35,111,565,352),'#329a95',26,NAVY,2)
box(d,(45,119,555,339),'#65c6af',19,'#b6efd5',3)
for x in range(65,555,76):box(d,(x,126,x+35,331),'#6bceb6',1)
box(d,(58,134,542,324),None,11,'#d9fbe1',2)
ellipse(d,(232,159,367,294),None,'#d9fbe1',2)
line(d,[(300,135),(300,323)],'#d9fbe1',2)
for x,y in [(75,90),(526,326),(53,328)]:
    poly(d,[(x-16,y+11),(x+14,y+11),(x+4,y-17)],'#f6a974',NAVY,2)
    line(d,[(x-7,y),(x+7,y)],'#fff4d2',3)
for x,y in [(557,358),(33,360),(554,59)]:
    for angle in [-1,-.3,.4]:
        dx=math.cos(angle)*25;dy=math.sin(angle)*25
        poly(d,[(x,y),(x+dx-10,y+dy-17),(x+dx,y+dy-23),(x+dx+6,y+dy-11)],'#3b9b84',NAVY,1)
    ellipse(d,(x-17,y-3,x+17,y+13),'#e5f5d4',NAVY,1)
for x,y in [(96,167),(504,190),(440,74)]:star(d,x,y,10,'#ffdc82')
save(stage,OUT/'home-court.png')
print(f'Built surfaces, 32 icons + atlas, backdrop and court in {OUT.relative_to(ROOT)}')
