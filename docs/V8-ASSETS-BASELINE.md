# Inventario de referencia v7 para v8

Referencia: `9df16188acba59641626cd0c8bd1de29acacb47d` (14-11-2026).
21 PNG, 184 cuadros; todos de 128×128 por cuadro. SHA-256 permite comprobar que la migración no cambia arte existente por accidente. Los originales continúan en su ruta actual.

| Archivo | Dimensiones | Cuadros | SHA-256 |
|---|---|---:|---|
| `assets/sprites/ball.png` | 1024×128 | 8 | 62393a666ab4f9cbbd291174d794f18fd0c8988bc457d94715cd2c4129c57e6c |
| `assets/sprites/ball_berry.png` | 1024×128 | 8 | dc8b442338176e30edc79724a55be68474c2d298f61302e46c0b27bc01e605b8 |
| `assets/sprites/ball_ocean.png` | 1024×128 | 8 | af90eecbd5a4751f53e985ca28b3496f726e7450d7e532e1753bf86dafea0609 |
| `assets/sprites/ball_violet.png` | 1024×128 | 8 | 6c9772399414cc41e3edfff71eecf782b0b7c7061b7dd8cd20b750eae1e9078d |
| `assets/sprites/boost.png` | 1024×128 | 8 | 6d283c4401c5e5bdff5fee81bdea72dbbd957b364b911cacf7b3363c894927c1 |
| `assets/sprites/bubble.png` | 1024×128 | 8 | 94c5a357adbf8c3ba991261a0dab694399be1e0432e0dd5a8c77580695bd8afe |
| `assets/sprites/character.png` | 2048×128 | 16 | a21f0dc7ee74b66a9701d2e1697aac82a7b5e7a829c188cad1e23cd51e224d59 |
| `assets/sprites/character_diagonal.png` | 2048×128 | 16 | a4ca8597f309c3222633c036d1fbe693cafc7fc887e9d62a7a9e712c873b5d42 |
| `assets/sprites/clock.png` | 1024×128 | 8 | a3390846ba06f601ad14deaeb16ecef9d8e1e8843757272d4495c7bc8d9ecbf0 |
| `assets/sprites/drain.png` | 1024×128 | 8 | 9b924935e4cb55e4000789a2f39a0a882ca6783955d22e546539937b6d6a2969 |
| `assets/sprites/fan.png` | 1024×128 | 8 | 8bca56d992afb73c7b52a6a7b80e5c5840802d08f575c0687a33804a41449d7c |
| `assets/sprites/laser.png` | 1024×128 | 8 | 5543aa2792eb7dc4afd1f747b0611aeae8b966432b45e5b7ca15900a1e80a1e4 |
| `assets/sprites/lid.png` | 1024×128 | 8 | 2f42e514a1afd5c0aa3ac9540b5682c03ad86c8277383d06128a59cf31841368 |
| `assets/sprites/magnet.png` | 1024×128 | 8 | cf7880a90ff40a0fdd563f76fbe5f6834e592dfd8fc1fa2bf557da799a4408fc |
| `assets/sprites/mallet.png` | 1024×128 | 8 | f213b1c4ab5a3305e9ab4df3f82bdd728de7cc5a190e9d76595098cc9a010bbf |
| `assets/sprites/portal.png` | 1024×128 | 8 | 9ae3d31de3399f9e31ed48c725b56afd8595ab348c210f0c66f45288b4e3ef89 |
| `assets/sprites/saw.png` | 1024×128 | 8 | e0642f36a716c5a1a3e46ce46729f9030b527d69272f77f035d4921ca3490fcf |
| `assets/sprites/shield.png` | 1024×128 | 8 | 148afef49ceafb915f4f0e654fb02929cbccfbe9368716ac8ee0e545b3a5cde2 |
| `assets/sprites/shock.png` | 1024×128 | 8 | 99e1f3b1c29919f6f6788e4c964b840f728436bb3926babdd85e9dadd070c70a |
| `assets/sprites/spikes.png` | 1024×128 | 8 | 784b9c529b96b37226c49a6e84deab6af84e7c00b48d486128b10a36a261655a |
| `assets/sprites/vortex.png` | 1024×128 | 8 | 747c982022f8aabcdf8a5096a0b431f56bb206db7163e28ae52539f37dc54139 |

## Procedencia y licencias observadas

| Grupo | Evidencia actual | Estado para publicación |
|---|---|---|
| Código Lua/Python | Historial del repositorio; no hay LICENSE | Pendiente: el creador debe decidir licencia; esta fase no concede derechos nuevos |
| PNG existentes | Scripts de generación en tools y dibujos alternativos en src/sprites | Sin licencia explícita ni manifiesto de autoría por archivo; no inferir CC0 ni autoría solo por existir generadores |
| Sonidos | src/audio.lua sintetiza nueve tonos en memoria | No hay archivos externos de audio; licencia del código pendiente |
| Fuente | src/ui.lua busca Rubik Regular/Bold y usa fallback de LÖVE | No hay TTF/OTF en assets; no se distribuye Rubik ni se le atribuye licencia sin verificar |
| UI | src/ui.lua, src/icons.lua y src/v7screens.lua dibujan con LÖVE | Sin atlas PNG de UI; producción pendiente en fase B |

No se descargó ni añadió arte/audio externo. Tampoco se añadió una licencia general sin decisión del creador. Las licencias de recursos futuros deben registrarse al incorporarlos; la ausencia de una licencia explícita aquí no autoriza redistribución ajena.
