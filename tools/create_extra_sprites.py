from pathlib import Path
from PIL import Image
import cairosvg,io,math
ROOT=Path(__file__).resolve().parent.parent
OUT=ROOT/'assets'/'sprites'
OUT.mkdir(exist_ok=True,parents=True)
SIZE=128
src=ROOT/'assets'/'source'/'character_diagonal_4x4.png'
if src.exists():
    im=Image.open(src).convert('RGBA')
    frames=[]
    for row in range(4):
        for col in range(4):
            box=(round(im.width*col/4), round(im.height*row/4),round(im.width*(col+1)/4),round(im.height*(row+1)/4))
            cell=im.crop(box)
            bb=cell.getchannel('A').getbbox()
            if not bb: raise ValueError(f'Empty diagonal cell {row} {col}')
            crop=cell.crop((max(0,bb[0]-4),max(0,bb[1]-4),min(cell.width,bb[2]+4),min(cell.height,bb[3]+4)))
            scale=min(109/crop.width,113/crop.height)
            crop=crop.resize((round(crop.width*scale),round(crop.height*scale)),Image.Resampling.LANCZOS)
            canvas=Image.new('RGBA',(SIZE,SIZE))
            canvas.alpha_composite(crop,((128-crop.width)//2,120-crop.height))
            frames.append(canvas)
    atlas=Image.new('RGBA',(SIZE*len(frames),SIZE))
    for i,f in enumerate(frames):atlas.alpha_composite(f,(SIZE*i,0))
    atlas.save(OUT/'character_diagonal.png',optimize=True)
    print('Diagonal sprites:',atlas.size)

def svg_to_img(body):
    s=f'''<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
      <defs><linearGradient id="cyan" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#91f4ff"/><stop offset="1" stop-color="#2299e8"/></linearGradient><linearGradient id="pink" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#ffb5eb"/><stop offset="1" stop-color="#ea559b"/></linearGradient><linearGradient id="orange" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#ffe28b"/><stop offset="1" stop-color="#ffa442"/></linearGradient></defs>{body}</svg>'''
    return Image.open(io.BytesIO(cairosvg.svg2png(bytestring=s.encode(),output_width=256,output_height=256))).convert('RGBA').resize((128,128),Image.Resampling.LANCZOS)

def base(tint='cyan'):
    return f'<ellipse cx="66" cy="108" rx="35" ry="10" fill="#35677c" opacity=".17"/><circle cx="64" cy="60" r="43" fill="#172f55"/><circle cx="64" cy="60" r="38" fill="url(#{tint})"/><circle cx="51" cy="43" r="12" fill="#ffffff" opacity=".24"/>'

def magnet(i):
    wobble=math.sin(i*math.pi/4)*5
    return svg_to_img(base('pink')+f'<g transform="rotate({wobble:.2f} 64 60)"><path d="M42 44v23c0 31 44 31 44 0V44" fill="none" stroke="#172f55" stroke-width="22" stroke-linecap="round"/><path d="M42 44v23c0 31 44 31 44 0V44" fill="none" stroke="#f8fdff" stroke-width="15" stroke-linecap="round"/><rect x="32" y="39" width="20" height="19" rx="4" fill="#ef5d7b"/><rect x="76" y="39" width="20" height="19" rx="4" fill="#ef5d7b"/><rect x="35" y="39" width="14" height="6" rx="2" fill="#ffd2dd"/><rect x="79" y="39" width="14" height="6" rx="2" fill="#ffd2dd"/></g>')

def fan(i):
    a=i*45
    return svg_to_img(base('cyan')+f'<circle cx="64" cy="60" r="30" fill="#e4fbff" stroke="#172f55" stroke-width="4"/><g transform="rotate({a} 64 60)">'+''.join(f'<path d="M64 60 Q{49+j*0} 34 66 29Q88 32 64 60" fill="#2c96e4" stroke="#172f55" stroke-width="3" transform="rotate({j*90} 64 60)"/>' for j in range(4))+'</g><circle cx="64" cy="60" r="10" fill="#ffda70" stroke="#172f55" stroke-width="3"/><circle cx="60" cy="57" r="3" fill="white"/>')

def clock(i):
    a=-90+i*45
    return svg_to_img(base('orange')+f'<circle cx="64" cy="60" r="31" fill="#fff8e5" stroke="#172f55" stroke-width="5"/><circle cx="64" cy="60" r="4" fill="#172f55"/><path d="M64 60V39" stroke="#172f55" stroke-width="6" stroke-linecap="round" transform="rotate({a+90} 64 60)"/><path d="M64 60v14" stroke="#ee8556" stroke-width="5" stroke-linecap="round" transform="rotate({(a+90)*.45:.2f} 64 60)"/><circle cx="64" cy="32" r="3" fill="#f6a74d"/><circle cx="92" cy="60" r="3" fill="#f6a74d"/><circle cx="64" cy="88" r="3" fill="#f6a74d"/><circle cx="36" cy="60" r="3" fill="#f6a74d"/>')

for name,fn in [('magnet',magnet),('fan',fan),('clock',clock)]:
    atlas=Image.new('RGBA',(128*8,128))
    for i in range(8):atlas.alpha_composite(fn(i),(128*i,0))
    atlas.save(OUT/(name+'.png'),optimize=True)
    print(name,atlas.size)
