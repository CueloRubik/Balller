from pathlib import Path
from PIL import Image
import io,math,cairosvg
ROOT=Path(__file__).resolve().parent.parent
OUT=ROOT/'assets'/'sprites'
OUT.mkdir(parents=True,exist_ok=True)
SIZE=128

def render(content):
    svg=f'''<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128"><defs>
    <linearGradient id="steel" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#f5fbff"/><stop offset=".5" stop-color="#9ed1e4"/><stop offset="1" stop-color="#4f819f"/></linearGradient>
    <linearGradient id="electric" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#fff6a5"/><stop offset=".5" stop-color="#ffc344"/><stop offset="1" stop-color="#f28c41"/></linearGradient>
    <linearGradient id="whirl" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#c9a9ff"/><stop offset=".5" stop-color="#7756d4"/><stop offset="1" stop-color="#4364cc"/></linearGradient></defs>{content}</svg>'''
    png=cairosvg.svg2png(bytestring=svg.encode(),output_width=256,output_height=256)
    return Image.open(io.BytesIO(png)).convert('RGBA').resize((128,128),Image.Resampling.LANCZOS)

def common():
    return '<ellipse cx="66" cy="109" rx="36" ry="9" fill="#274a69" opacity=".18"/>'

def saw(i):
    ang=i*45
    paths=[]
    for k in range(12):
        a=k*360/12
        paths.append(f'<path d="M-9 -32 L0 -50 L9 -32" fill="url(#steel)" stroke="#182d58" stroke-width="3" stroke-linejoin="round" transform="rotate({a} 64 60) translate(64 60)"/>')
    return render(common()+f'<g transform="rotate({ang} 64 60)">'+''.join(paths)+'''
     <circle cx="64" cy="60" r="34" fill="#162f5a"/>
     <circle cx="64" cy="60" r="29" fill="url(#steel)" stroke="#e4fcff" stroke-width="3"/>
     <circle cx="64" cy="60" r="21" fill="#497eab" stroke="#162f5a" stroke-width="4"/>
     <circle cx="64" cy="60" r="12" fill="url(#electric)" stroke="#162f5a" stroke-width="4"/>
     <circle cx="60" cy="56" r="3.5" fill="white" opacity=".85"/>
     </g>''')

def shock(i):
    pulse=1+.075*math.sin(i*math.pi/4)
    rays=''
    for k in range(6):
        a=k*60+i*5
        rays+=f'<path d="M64 22l-7 14 11-2-6 15" fill="none" stroke="#fff9c5" stroke-width="4" stroke-linejoin="round" stroke-linecap="round" transform="rotate({a} 64 60)"/>'
    return render(common()+f'<g transform="translate(64 60) scale({pulse:.3f}) translate(-64 -60)"><circle cx="64" cy="60" r="43" fill="#172f55"/><circle cx="64" cy="60" r="37" fill="url(#electric)"/><circle cx="64" cy="60" r="29" fill="#fff7d2" stroke="#e68a33" stroke-width="4"/>{rays}<path d="M68 33 50 62h13l-5 24 24-38H67z" fill="#ffae26" stroke="#162f5a" stroke-width="4" stroke-linejoin="round"/><path d="M66 37 55 58h10" fill="none" stroke="#fff7ad" stroke-width="3" stroke-linecap="round"/></g>')

def vortex(i):
    angle=i*45
    arms=''
    for j in range(3):
        a=j*120
        arms+=f'<path d="M64 60Q47 33 73 28Q100 28 95 54" fill="none" stroke="#ebddff" stroke-width="10" stroke-linecap="round" transform="rotate({a} 64 60)"/>'
        arms+=f'<path d="M64 60Q47 33 73 28Q100 28 95 54" fill="none" stroke="#7053d1" stroke-width="5" stroke-linecap="round" transform="rotate({a} 64 60)"/>'
    return render(common()+f'<circle cx="64" cy="60" r="44" fill="#172f55"/><circle cx="64" cy="60" r="39" fill="url(#whirl)"/><g transform="rotate({angle} 64 60)">{arms}</g><circle cx="64" cy="60" r="10" fill="#273a8a" stroke="#f9ecff" stroke-width="4"/><circle cx="60" cy="57" r="3" fill="white"/>')

for name,func in [('saw',saw),('shock',shock),('vortex',vortex)]:
    atlas=Image.new('RGBA',(SIZE*8,SIZE))
    for frame in range(8): atlas.alpha_composite(func(frame),(frame*SIZE,0))
    atlas.save(OUT/(name+'.png'),optimize=True)
    print(name,atlas.size)
