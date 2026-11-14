# Balller v5 - mejoras de jugabilidad y estabilidad

- **Pulso de rescate:** pulsa Espacio cerca de la pelota para impulsarla lejos del personaje. Rango 175 unidades, recarga 10 segundos, no consume monedas. Se conserva la recarga al guardar.
- **Metas alternas:** ronda 1 golpes, 2 rebotes contra paredes, 3 defensas colocadas, y así sucesivamente. La bonificación por objetivo comienza en 12 monedas y aumenta 2 cada tres rondas, hasta 24.
- **Zapatillas:** mejoras permanentes dentro de cada partida, niveles 1 a 3 a 65/120/175 monedas, +20 de velocidad por nivel. Se conservan al guardar.
- **Guardados:** respaldo `.bak` de la última instantánea válida, recuperación ante datos corruptos y suma de verificación Adler-32 en nuevos guardados. Se admite el formato anterior sin suma.
- **Recuperación automática:** guardado cada 8 segundos mientras se juega.
- **Interfaz:** ayuda y marcadores actualizados, tienda con descripción corta de las defensas, botón de mejora y estado de recarga del pulso.

## Pruebas de versión

`texlua tests/runfile.lua`

`texlua tests/smoke.lua`

`texlua tests/smoke.lua fallback`

`texlua tests/verify_directions.lua`

`python3 tests/check_sprites.py`

Estas pruebas no sustituyen la verificación gráfica manual con LÖVE 2D 11.4+ y el hardware destino.
