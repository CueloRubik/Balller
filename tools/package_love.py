from pathlib import Path
from zipfile import ZipFile, ZipInfo, ZIP_DEFLATED

root=Path(__file__).resolve().parents[1]
output=root/'dist'/'Balller-v6.love'
output.parent.mkdir(exist_ok=True)
files=[root/'main.lua',root/'conf.lua']
files.extend(p for directory in ('src','assets') for p in (root/directory).rglob('*') if p.is_file())
for path in files:
    assert path.is_file(),f'Falta: {path}'
with ZipFile(output,'w') as archive:
    for file in sorted(files,key=lambda p:p.relative_to(root).as_posix()):
        relative=file.relative_to(root).as_posix()
        info=ZipInfo(relative,date_time=(2026,1,1,0,0,0))
        info.compress_type=ZIP_DEFLATED
        info.external_attr=0o644<<16
        archive.writestr(info,file.read_bytes())
with ZipFile(output) as archive:
    assert archive.testzip() is None
    assert 'main.lua' in archive.namelist()
    assert 'conf.lua' in archive.namelist()
    assert len([name for name in archive.namelist() if name.endswith('.png')])>=14
print(f'Juego empaquetado: {output.relative_to(root)} ({output.stat().st_size} bytes)')
