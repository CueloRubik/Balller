"""Generate cosmetic courts at the exact existing 932x440 arena size."""
from pathlib import Path
from PIL import Image, ImageDraw
import math

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/backgrounds'
OUT.mkdir(parents=True,exist_ok=True)
S=3
W,H=932,440
INK='#214a57'
def rr(d,xy,fill,r=15,outline=None,width=1):
    d.rounded_rectangle(tuple(round(v*S) for v in xy),radius=round(r*S),fill=fill,outline=outline,width=round(width*S))
def line(d,xy,fill,width=1):
    d.line([(round(x*S),round(y*S)) for x,y in xy],fill=fill,width=round(width*S),joint='curve')
def ellipse(d,xy,fill=None,outline=None,width=1):
    d.ellipse(tuple(round(v*S) for v in xy),fill=fill,outline=outline,width=round(width*S))
for name,base,rail,mark in [('patio','#a8d8b8','#eff4d6','#d9efdb'),('taller','#add1d5','#e9d7b4','#cce3e3'),('ciudad','#b9cadc','#d8d7ed','#dbe3ee')]:
    im=Image.new('RGBA',(W*S,H*S));d=ImageDraw.Draw(im)
    rr(d,(1,7,W-1,H-1),'#17495845',27)
    rr(d,(1,1,W-1,H-8),rail,25,INK,2)
    rr(d,(8,7,W-8,H-13),'#ffffff',20)
    rr(d,(18,18,W-18,H-18),base,10,INK,1)
    if name=='patio':
        for x in range(26,W-25,88):
            rr(d,(x,26,min(x+42,W-26),H-26),'#addcbd',1)
        for x,y in [(27,27),(W-27,27),(27,H-27),(W-27,H-27)]:
            line(d,[(x-7,y),(x+7,y)],'#7eac93',2)
    elif name=='taller':
        for x in range(36,W-20,64):line(d,[(x,22),(x,H-22)],'#a3c8cc',1)
        for y in range(36,H-20,64):line(d,[(22,y),(W-22,y)],'#a3c8cc',1)
        for x in range(31,W-18,40):
            line(d,[(x,10),(x+9,10)],'#c89f66',3)
            line(d,[(x,H-12),(x+9,H-12)],'#c89f66',3)
    else:
        for x in range(26,W-25,106):
            rr(d,(x,26,min(x+49,W-26),H-26),'#becfe1',1)
        for x in range(40,W-30,80):
            line(d,[(x,10),(x+22,10)],'#b1acd5',3)
            line(d,[(x,H-12),(x+22,H-12)],'#b1acd5',3)
    # Low-contrast floor marks are decorative, not collision geometry.
    rr(d,(28,28,W-28,H-28),None,6,mark,2)
    ellipse(d,(W/2-82,H/2-82,W/2+82,H/2+82),None,mark,2)
    line(d,[(W/2,29),(W/2,H-29)],mark,2)
    ellipse(d,(W/2-4,H/2-4,W/2+4,H/2+4),mark)
    for x in [12,W-12]:
        for y in [43,H/2,H-43]:
            ellipse(d,(x-3,y-3,x+3,y+3),'#83a7a6',INK,1)
    im.resize((W,H),Image.Resampling.LANCZOS).save(OUT/(name+'.png'),optimize=True)
print('Built Patio, Taller, Ciudad: cosmetic 932x440 courts; 18px physical rim preserved')
