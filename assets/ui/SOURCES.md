# Recursos de interfaz v8 B1

Recursos dibujados mediante el generador reproducible `tools/build_ui_v8.py`, incorporados para Balller. No se descargaron imágenes externas. Son PNG exportados de dibujos geométricos propios del proyecto, siguiendo contornos y paleta del arte existente; no se asigna una licencia global distinta al repositorio.

| Recurso | Uso | Formato |
|---|---|---|
| surfaces.png | 24 variantes de botón y cinco paneles, con nueve segmentos | RGBA 1024×640 |
| icons.png | 32 iconos empaquetados para una sola textura | RGBA 512×256 |
| icons/*.png | Los mismos 32 iconos, editables/reutilizables por separado | RGBA 64×64 |
| backdrop.png | Fondo claro, sin texto incrustado | RGBA 1000×680 |
| home-court.png | Cancha ilustrada del inicio, sin personaje incrustado | RGBA 600×400 |

Regenerar desde la raíz con `python3 tools/build_ui_v8.py` (Pillow 13). El juego usa los PNG ya incluidos y no requiere Python/Pillow. Las fuentes y sus créditos se documentan en `assets/fonts/SOURCES.md`.

B2 añade `meters.png`, RGBA 512×128: cuatro filas de barras (menta, azul, oro, violeta), cada una con pista y relleno de 256×32. Se estiran en tres segmentos horizontales; se conserva la curvatura de los extremos y no se carga un PNG por cada valor de progreso.
