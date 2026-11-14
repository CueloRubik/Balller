# Canchas visuales B3

`patio.png`, `taller.png` y `ciudad.png` se generan con `tools/build_courts.py` (Pillow 13). No contienen material descargado de terceros. Se incorporan al proyecto siguiendo el estilo de contornos y paleta de los sprites anteriores; no se asigna una licencia global nueva al repositorio.

Cada PNG mide 932×440, exactamente el tamaño de la cancha histórica. El borde interior de 18 px sigue los límites de `src/arena.lua`. Las marcas del suelo son decorativas: no crean obstáculos ni zonas de daño. El juego carga los tres PNG una vez para la cancha y las vistas previas de Ajustes. Si falta el PNG seleccionado o no puede cargarse, se usa el dibujo de cancha anterior.

Patio usa bandas verdes y marco marfil; Taller, baldosas azul verdosas y marco de arena con marcas de taller; Ciudad, bandas azul grisáceo y marco violeta. Son aspectos disponibles en Ajustes, sin desbloqueos ni asignación automática a capítulos todavía.

Regenerar desde la raíz: `python3 tools/build_courts.py`. Python/Pillow no son necesarios para jugar.
