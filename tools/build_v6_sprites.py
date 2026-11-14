from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter
import math
ROOT=Path(__file__).resolve().parents[1]/'assets'/'sprites'
ROOT.mkdir(parents=True,exist_ok=True)
S=3; N=128*S
INK=(32,64,100,255)
WHITE=(255,255,255,255)
def ellipse(d,rect,fill,outline=None,width=1):
 d.ellipse(tuple(int(v*S) for v in rect),fill=fill,outline=outline,width=width*S)
def poly(d,pts,fill):d.polygon([(round(x*S),round(y*S)) for x,y in pts],fill=fill)
def line(d,pts,fill,width=1,joint='curve'):d.line([(round(x*S),round(y*S)) for x,y in pts],fill=fill,width=width*S,joint=joint)
def rounded(d,rect,rad,fill,outline=None,width=1):d.rounded_rectangle(tuple(int(v*S) for v in rect),radius=rad*S,fill=fill,outline=outline,width=width*S)
def sprite(name,kind):
 frames=[]
 for i in range(8):
  t=2*math.pi*i/8
  image=Image.new('RGBA',(N,N),(0,0,0,0));d=ImageDraw.Draw(image)
  ellipse(d,(21,98,107,113),(41,73,95,38))
  if kind=='mallet':
   d.ellipse((int(27*S),int(21*S),int(101*S),int(101*S)),fill=(253,213,110,255),outline=INK,width=5*S)
   roundoff=math.sin(t)*5
   rounded(d,(55+roundoff,45,72+roundoff,100),7,(103,164,216,255),INK,4)
   rounded(d,(29+roundoff,31,100+roundoff,65),10,(245,94,101,255),INK,5)
   rounded(d,(34+roundoff,36,94+roundoff,47),5,(255,157,146,255))
   ellipse(d,(47+roundoff,79,80+roundoff,95),(61,112,162,255),INK,3)
  if kind=='laser':
   ellipse(d,(23,24,105,107),(54,118,187,255),INK,5)
   ellipse(d,(34,34,94,94),(153,220,244,255),INK,4)
   ellipse(d,(44,44,84,84),(247,104,112,255),INK,4)
   ellipse(d,(51,51,77,77),(255,241,187,255))
   angle=t
   points=[]
   for r,a in [(42,angle),(58,angle),(58,angle+.17),(42,angle+.17)]:points.append((64+r*math.cos(a),64+r*math.sin(a)))
   poly(d,points,(255,191,109,190))
   for a in (0,math.pi/2,math.pi,math.pi*1.5):
    cx=64+35*math.cos(a);cy=64+35*math.sin(a)
    ellipse(d,(cx-4,cy-4,cx+4,cy+4),(255,255,255,255))
  if kind=='bubble':
   rr=40+math.sin(t)*3
   ellipse(d,(64-rr,64-rr,64+rr,64+rr),(105,216,253,74),(56,145,212,255),5)
   ellipse(d,(64-rr+9,64-rr+8,64+rr-7,64+rr-10),(191,246,255,81),(210,247,255,193),2)
   ellipse(d,(40,36,62,45),(255,255,255,210))
   for ang in [t,t+2.1,t+4.2]:
    x=64+43*math.cos(ang);y=64+43*math.sin(ang)
    ellipse(d,(x-4,y-4,x+4,y+4),(255,253,222,235))
   ellipse(d,(57,57,71,71),(255,246,255,225),(42,148,198,255),2)
  if kind=='portal':
   ellipse(d,(15,19,113,109),(41,75,132,255),INK,5)
   ellipse(d,(24,25,104,103),(101,106,219,255),(197,174,252,255),5)
   ellipse(d,(35,36,93,94),(75,205,228,255),INK,3)
   ellipse(d,(45,46,83,84),(39,118,206,255))
   for j in range(3):
    a=t+j*2*math.pi/3
    rad=22
    x=64+math.cos(a)*rad;y=64+math.sin(a)*rad
    ellipse(d,(x-7,y-7,x+7,y+7),(230,249,255,255),INK,2)
   ellipse(d,(59,59,69,69),(255,255,255,255))
  frames.append(image.resize((128,128),Image.Resampling.LANCZOS))
 sheet=Image.new('RGBA',(1024,128),(0,0,0,0))
 for i,f in enumerate(frames):sheet.alpha_composite(f,(i*128,0))
 sheet.save(ROOT/f'{name}.png',optimize=True)
 print(name, (ROOT/f'{name}.png').stat().st_size)
for n in ['mallet','laser','bubble','portal']:sprite(n,n)
