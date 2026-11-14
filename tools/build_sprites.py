from pathlib import Path
from PIL import Image
import math,io
import cairosvg

OUT=Path(__file__).resolve().parent.parent/'assets'/'sprites'
OUT.mkdir(parents=True,exist_ok=True)
SIZE=128

def svg_png(body):
    s=f'''<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
    <defs>
    <radialGradient id="shine" cx="36%" cy="25%" r="75%"><stop offset="0%" stop-color="#fff" stop-opacity=".40"/><stop offset="100%" stop-color="#fff" stop-opacity="0"/></radialGradient>
    <linearGradient id="gold" x1="0%" y1="0%" x2="100%" y2="100%"><stop stop-color="#ffef8f"/><stop offset="48%" stop-color="#ffbc39"/><stop offset="100%" stop-color="#e77a24"/></linearGradient>
    <linearGradient id="blue" x1="0%" y1="0%" x2="100%" y2="100%"><stop stop-color="#90e1ff"/><stop offset="52%" stop-color="#2c97ee"/><stop offset="100%" stop-color="#1760b0"/></linearGradient>
    <linearGradient id="mint" x1="0%" y1="0%" x2="100%" y2="100%"><stop stop-color="#b2ffce"/><stop offset="52%" stop-color="#22d2a8"/><stop offset="100%" stop-color="#0c8a75"/></linearGradient>
    <linearGradient id="red" x1="0%" y1="0%" x2="100%" y2="100%"><stop stop-color="#ffbbc1"/><stop offset="45%" stop-color="#fa5266"/><stop offset="100%" stop-color="#ad244f"/></linearGradient>
    <linearGradient id="steel" x1="0%" y1="0%" x2="100%" y2="100%"><stop stop-color="#c1e1ed"/><stop offset="50%" stop-color="#719cac"/><stop offset="100%" stop-color="#3d6681"/></linearGradient>
    </defs>{body}</svg>'''
    return Image.open(io.BytesIO(cairosvg.svg2png(bytestring=s.encode(),output_width=256,output_height=256))).convert('RGBA').resize((SIZE,SIZE),Image.Resampling.LANCZOS)

def ring(cx=64,cy=60,r=36,fill='url(#blue)',outer='#172d55'):
    return f'<circle cx="{cx}" cy="{cy}" r="{r+4}" fill="{outer}"/><circle cx="{cx}" cy="{cy}" r="{r}" fill="{fill}"/>'

def shadow():
    return '<ellipse cx="67" cy="104" rx="37" ry="10" fill="#315377" opacity=".20"/>'

def ball(i):
    angle=i*45
    return svg_png(shadow()+ring(fill='url(#gold)')+f'''<g transform="rotate({angle} 64 60)" fill="none" stroke="#9a521b" stroke-width="3.5" stroke-linecap="round">
    <path d="M30 60h68M64 26v68"/><path d="M39 34Q83 60 39 86M89 34Q45 60 89 86"/></g>
    <circle cx="53" cy="45" r="26" fill="url(#shine)"/>
    <ellipse cx="50" cy="39" rx="10" ry="5" transform="rotate(-35 50 39)" fill="white" opacity=".78"/>
    <circle cx="82" cy="84" r="4" fill="#cc762d" opacity=".6"/>''')

def spikes(i):
    grow=min(1,(i+1)/5)
    base=shadow()+ring(r=39,fill='url(#red)')
    base+='<circle cx="64" cy="60" r="31" fill="#a42b51"/>'
    for j in range(9):
        a=math.pi*2*j/9
        x,y=64+math.cos(a)*17,60+math.sin(a)*17
        ox,oy=64+math.cos(a)*(18+24*grow),60+math.sin(a)*(18+24*grow)
        sides=[(x+math.cos(a+math.pi/2)*7,y+math.sin(a+math.pi/2)*7),(ox,oy),(x+math.cos(a-math.pi/2)*7,y+math.sin(a-math.pi/2)*7)]
        pts=' '.join(f'{a:.1f},{b:.1f}' for a,b in sides)
        base+=f'<polygon points="{pts}" fill="#f3f6f7" stroke="#172d55" stroke-width="2" stroke-linejoin="round"/>'
        base+=f'<path d="M{x:.1f} {y:.1f}L{ox:.1f} {oy:.1f}" stroke="#b8d5e1" stroke-width="2"/>'
    base+=f'<circle cx="64" cy="60" r="15" fill="url(#red)" stroke="#172d55" stroke-width="4"/><circle cx="58" cy="54" r="5" fill="#fff" opacity=".35"/>'
    return svg_png(base)

def drain(i):
    t=min(1,i/5)
    base=shadow()+ring(r=39,fill='url(#steel)')
    base+='<circle cx="64" cy="60" r="29" fill="#112b45" stroke="#f0ffff" stroke-width="3"/>'
    base+=f'<g transform="translate({-32*t:.2f} 0)" stroke="#172d55" stroke-width="3" stroke-linecap="round">'
    for j in range(-2,3):
        y=60+j*10
        half=math.sqrt(max(0,26**2-(j*10)**2))
        base+=f'<line x1="{64-half:.1f}" x2="{64+half:.1f}" y1="{y}" y2="{y}" stroke="#bcdfe5" stroke-width="6"/>'
    base+='</g><circle cx="34" cy="60" r="3" fill="#fff"/><circle cx="94" cy="60" r="3" fill="#fff"/>'
    return svg_png(base)

def shield(i):
    pulse=1+math.sin(i*math.pi/4)*.045
    base=shadow()+f'<g transform="translate(64 60) scale({pulse:.3f}) translate(-64 -60)">'
    base+=ring(r=38,fill='url(#blue)')+'<circle cx="64" cy="60" r="29" fill="#a0ebff" stroke="#fff" stroke-width="4"/>'
    base+='<circle cx="64" cy="60" r="22" fill="#278bd6" stroke="#172d55" stroke-width="3"/>'
    base+='<path d="M59 36l-10 25h13l-5 24 23-32H67l7-17z" fill="#fff" stroke="#d8fcff" stroke-width="2"/>'
    return svg_png(base+'</g>')

def boost(i):
    pulse=1+math.sin(i*math.pi/4)*.07
    base=shadow()+f'<g transform="translate(64 60) scale({pulse:.3f}) translate(-64 -60)">'
    base+=ring(r=36,fill='url(#mint)')+'<circle cx="64" cy="60" r="27" fill="#a1ffd1" stroke="#fff" stroke-width="3"/>'
    base+='<circle cx="64" cy="60" r="21" fill="#16ac94" stroke="#116278" stroke-width="3"/>'
    base+='<path d="M64 33l20 28H72v23H56V61H44z" fill="#fff" stroke="#dcffea" stroke-width="2" stroke-linejoin="round"/>'
    return svg_png(base+'</g>')

def lid(i):
    y=math.sin(i*math.pi/4)*2
    base=shadow()+ring(r=40,fill='url(#gold)')
    base+='<circle cx="64" cy="60" r="31" fill="#e99031" stroke="#fff3bf" stroke-width="4"/><circle cx="64" cy="60" r="26" fill="#ffd568" stroke="#7f511e" stroke-width="3"/>'
    for j in [-1,0,1]:
        base+=f'<rect x="44" y="{58+j*13+y:.2f}" width="40" height="5" rx="2.5" fill="#fff1ac" stroke="#b8732b" stroke-width="1.5"/>'
    base+='<circle cx="39" cy="60" r="3" fill="#17334e"/><circle cx="89" cy="60" r="3" fill="#17334e"/>'
    return svg_png(base)

def save(name,frames):
    sheet=Image.new('RGBA',(SIZE*len(frames),SIZE),(0,0,0,0))
    for i,frame in enumerate(frames): sheet.alpha_composite(frame,(SIZE*i,0))
    target=OUT/(name+'.png')
    sheet.save(target,format='PNG',optimize=True)
    return target

for name,fn in [('ball',ball),('spikes',spikes),('drain',drain),('shield',shield),('boost',boost),('lid',lid)]:
    save(name,[fn(i) for i in range(8)])

source=Path(__file__).resolve().parent/'character_source.png'
if source.exists():
    im=Image.open(source).convert('RGBA')
    framecols=[]
    cw,ch=im.width/3,im.height/3
    for row in range(3):
        sequence=[]
        for col in range(3):
            cell=im.crop((round(cw*col),round(ch*row),round(cw*(col+1)),round(ch*(row+1))))
            bbox=cell.getchannel('A').getbbox()
            if not bbox: raise ValueError('Se esperaba un personaje en cada cuadro')
            x0,y0,x1,y1=bbox
            crop=cell.crop((max(0,x0-5),max(0,y0-5),min(cell.width,x1+5),min(cell.height,y1+5)))
            scale=min(106/crop.width,114/crop.height)
            crop=crop.resize((round(crop.width*scale),round(crop.height*scale)),Image.Resampling.LANCZOS)
            canvas=Image.new('RGBA',(SIZE,SIZE),(0,0,0,0))
            canvas.alpha_composite(crop,((SIZE-crop.width)//2,119-crop.height))
            sequence.append(canvas)
        framecols.append([sequence[0],sequence[1],sequence[2],sequence[1]])
    down,right,up=framecols
    left=[f.transpose(Image.Transpose.FLIP_LEFT_RIGHT) for f in right]
    save('character',down+right+up+left)

print('\n'.join(f'{p.name}: {p.stat().st_size} bytes' for p in sorted(OUT.glob('*.png'))))
