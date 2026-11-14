from pathlib import Path
from struct import unpack
root=Path(__file__).resolve().parent.parent
expected={'character':16,'character_diagonal':16,'ball':8,'spikes':8,'drain':8,'shield':8,'boost':8,'lid':8,'magnet':8,'fan':8,'clock':8,'saw':8,'shock':8,'vortex':8}
for name,count in expected.items():
    path=root/'assets'/'sprites'/(name+'.png')
    data=path.read_bytes()
    assert data[:8]==b'\x89PNG\r\n\x1a\n',f'PNG invalido: {name}'
    assert data[12:16]==b'IHDR'
    w,h=unpack('>II',data[16:24])
    assert (w,h)==(128*count,128),(name,w,h)
    assert len(data)>1000,f'PNG vacio: {name}'
print(f'{len(expected)} hojas PNG verificadas, {sum(expected.values())} cuadros de animacion.')
