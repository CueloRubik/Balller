# Balller v8 — B1: recursos gráficos y aplicación inicial

Base: `132ff71e147c8af8a6e3335dc62c4f6284d87a4c` (fase A). Rama `feature/v8-visual-foundation`; PR dirigida a `feature/v8-rework` para mantener revisiones pequeñas y ordenadas.

## Entregado

- Guía visual en V8-GUIA-VISUAL.md y generador reproducible de PNG con Pillow.
- 32 iconos únicos exportados, atlas de iconos, atlas de 24 botones/cinco paneles, fondo y cancha ilustrada.
- Render de nueve segmentos, caché de quads y carga de cuatro texturas. Huella RGBA base de esas cuatro imágenes: aproximadamente 6,51 MiB, sin contar fuentes, sprites anteriores, mipmaps ni buffers del motor.
- Nunito Regular/ExtraBold estáticas, OFL y procedencia incluidas.
- Aplicación a las pantallas existentes; inicio recompuesto manteniendo personaje y animaciones. Compras de ancho completo y etiquetas de Ajustes sin solapamientos.
- Estados normal, pulsado, deshabilitado y destacado; acciones deshabilitadas no se despachan. Game/Progression mantienen la validación de las operaciones.
- Fallback a dibujos anteriores cuando faltan o fallan los PNG de UI; fallback tipográfico si falta/falla la fuente. No se cambian sprites anteriores ni esquema de datos.

## Validación realizada localmente

LÖVE 11.5 AppImage oficial, Mesa por software, SDL offscreen y audio dummy en Linux. No es una ejecución en macOS/Windows ni una prueba auditiva.

- Suites anteriores y fase A pasan con Lua 5.4.8.
- ui_assets.lua comprueba límites de nueve segmentos, 24 variantes de botón, cinco paneles, caché y recursos ausentes/corruptos.
- visual_flow.lua comprueba transformación de clics en cinco resoluciones y que botones no disponibles no llamen a comprar/desbloquear.
- check_ui_assets.py comprueba CRC, descompresión y dimensiones de 36 PNG, unicidad de 32 iconos, TrueType y OFL incluida.
- Arranque/dibujo/pausa nativo del código fuente y del .love pasan con --ci-smoke.
- 55 capturas nativas: diez pantallas existentes + hoja de componentes, en 1000×680, 800×600, 1280×720, 1366×768 y 1920×1080. Revisión de composiciones y muestras grandes/pequeñas; no certificación de cada texto posible con cualquier dato de usuario.
- Comparación visual corrigió transparencias del fondo, compra demasiado pequeña, textos de Ajustes y descripción de Novato. No se cambió su id ni dificultad histórica.
- Se conserva package_love.py sin argumentos para v7; --output permite generar Balller-v8-B1.love como paquete de desarrollo.

## Reproducir

```bash
lua tests/ui_assets.lua
lua tests/visual_flow.lua
python3 tests/check_ui_assets.py
love . --visual-check
python3 tools/package_love.py --output Balller-v8-B1.love
love dist/Balller-v8-B1.love --ci-smoke
```

`--visual-check` es una herramienta del checkout fuente (requiere tools/capture_ui.lua). Usa identidad aislada balller_visual_v8, datos sintéticos y no modifica las tres ranuras del usuario. Escribe en la carpeta de guardado de LÖVE, subcarpeta captures. No se incluye esa herramienta en el paquete jugable. El workflow ejecuta las mismas capturas con LÖVE/Xvfb y las publica como artefacto, además del .love de desarrollo.

## Pendientes para cerrar B

Maquetas/implementación de tienda global, retos opcionales y resultados de ronda; barras ilustradas; fondos y variantes de capítulo; pulido de HUD y espaciados con datos extremos. La revisión manual en Catalina/Windows y el balance siguen pendientes. Esta entrega no anuncia capítulos, defensas nuevas, música ni publicación final.
