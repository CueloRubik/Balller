from pathlib import Path
from PIL import Image
import colorsys
root=Path(__file__).resolve().parent.parent
src=Image.open(root/'assets/sprites/ball.png').convert('RGBA')
for name,hue in [('ball_ocean',.54),('ball_berry',.96),('ball_violet',.74)]:
 out=src.copy()
 pixel=out.load()
 for y in range(out.height):
  for x in range(out.width):
   r,g,b,a=pixel[x,y]
   if a<8: continue
   h,s,v=colorsys.rgb_to_hsv(r/255,g/255,b/255)
   if .065<h<.16 and s>.28:
    hh=hue+(h-.105)*.33
    rr,gg,bb=colorsys.hsv_to_rgb(hh,min(.88,s*.89),v)
    pixel[x,y]=(int(rr*255),int(gg*255),int(bb*255),a)
 path=root/'assets/sprites'/f'{name}.png'
 out.save(path,optimize=True)
 print(name,path.stat().st_size)
