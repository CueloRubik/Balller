from pathlib import Path
from struct import unpack
import zlib
import hashlib

root=Path(__file__).resolve().parents[1]
paths={root/'assets/ui/surfaces.png':(1024,640),root/'assets/ui/icons.png':(512,256),root/'assets/ui/backdrop.png':(1000,680),root/'assets/ui/home-court.png':(600,400),root/'assets/ui/meters.png':(512,128)}
icons=sorted((root/'assets/ui/icons').glob('*.png'))
assert len(icons)==32
assert len({hashlib.sha256(p.read_bytes()).hexdigest() for p in icons})==32
paths.update({p:(64,64) for p in icons})
for path,dimensions in paths.items():
    data=path.read_bytes()
    assert data[:8]==b'\x89PNG\r\n\x1a\n',path
    offset=8
    chunks=[]
    while offset<len(data):
        length=unpack('>I',data[offset:offset+4])[0]
        tag=data[offset+4:offset+8]
        payload=data[offset+8:offset+8+length]
        crc=unpack('>I',data[offset+8+length:offset+12+length])[0]
        assert zlib.crc32(tag+payload)&0xffffffff==crc,path
        if tag==b'IHDR':
            w,h,depth,color,*_=unpack('>IIBBBBB',payload)
            assert (w,h)==dimensions and depth==8 and color==6,path
        if tag==b'IDAT':chunks.append(payload)
        offset+=length+12
        if tag==b'IEND':break
    assert offset==len(data) and len(zlib.decompress(b''.join(chunks)))==h*(1+w*4),path
for filename in ['Nunito-Regular.ttf','Nunito-ExtraBold.ttf']:
    font=root/'assets/fonts'/filename
    assert font.read_bytes()[:4]==b'\x00\x01\x00\x00' and font.stat().st_size>10000
license=(root/'assets/fonts/OFL-Nunito.txt').read_text()
assert 'SIL OPEN FONT LICENSE Version 1.1' in license and 'Nunito Project Authors' in license
print('37 valid UI PNGs, 32 unique icons, two TrueType fonts and bundled OFL verified')
