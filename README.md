# BALLLER · Arcade de rescate (v7)

**Balller** es un arcade cenital creado con Lua y [LÖVE 2D](https://love2d.org/) 11.4+. La pelota siempre se mueve a **velocidad constante** durante una ronda: el personaje y las defensas cambian su **dirección**, mientras que los peligros hacen que el escenario sea cada vez más difícil.

Diseñado para teclado y ratón hoy, con **interfaz de juego móvil en formato panorámico**: botones grandes, un HUD limpio, una tienda de compras simples y solo cuatro defensas visibles a la vez.

## Ejecutar

Abre la carpeta con LÖVE o usa `love .` en su raíz. Para empaquetar: `python3 tools/package_love.py`. El resultado es `dist/Balller-v7.love`.

No requiere conexión, cuentas, compras reales, publicidad ni recursos descargables. Los recursos visuales y el código están incluidos.

## Pantallas

- **Jugar** → Dificultad (Novato, Normal, Difícil, Experto) → una de tres ranuras → tienda → rondas.
- **Mis partidas** → continuar, borrar con confirmación o crear una nueva.
- **Pelotas** → cuatro apariencias animadas; una inicial y tres comprables con gemas ganadas jugando.
- **Logros** → progresión permanente por golpes, estrellas, rondas y partidas.
- **Ajustes** → activar/desactivar sonido y consultar las instrucciones o practicar.

## Cómo funcionan las recompensas

- **Puntuación**: sirve para superar el récord de una partida.
- **Monedas**: se ganan al superar rondas, completar objetivos y golpear la pelota. Se gastan en defensas y mejoras **solo dentro de esa partida**.
- **Gemas**: se obtienen por primera vez al superar cada tercera ronda de una dificultad y al completar logros. Se conservan entre partidas y **únicamente** compran apariencias, sin cajas aleatorias ni pagos reales.
- **Estrellas**: aparecen en la cancha, y recogerlas con la pelota otorga puntos. En ciertas rondas aparecen más.

### Rondas especiales

- **Fiebre estelar** (cada tres rondas): más estrellas.
- **Tormenta** (cada cinco rondas): más peligros y recompensa superior.
- **Rescate** (cada siete rondas): un rescate adicional.
- Cuando coincide más de una, tiene prioridad Rescate, después Tormenta y después Fiebre estelar.

### Velocidad de la pelota

El juego calcula una rapidez al empezar cada ronda según el nivel y dificultad. **Cada actualización normaliza la velocidad** tras las colisiones, el impulso, el remolino, el imán y el ventilador. El reloj ahora reduce el ritmo de los peligros, no la velocidad de la pelota.

## Controles

| Acción | Teclado / ratón |
| --- | --- |
| Mover personaje | WASD o flechas (8 direcciones) |
| Pulso de rescate | Espacio o botón grande **PULSO** |
| Poner defensa | Clic izquierdo en cancha |
| Seleccionar defensa | 1–8, rueda del ratón o tocar una tarjeta |
| Ver siguientes cuatro defensas | Flechas en la barra de inventario |
| Pausa | P o Esc |
| Iniciar ronda | Enter o botón JUGAR RONDA |

## Estructura del proyecto

- `main.lua`: navegación y entrada del usuario.
- `src/v7screens.lua`: menús, colección, logros, tienda y HUD de estilo móvil.
- `src/game.lua`: rondas, economía y progresión durante partidas.
- `src/ball.lua`: velocidad estable.
- `src/rounds.lua`: modificadores por ronda.
- `src/collectibles.lua`: estrellas para recoger.
- `src/progression.lua`: gemas, logros y apariencias independientes de los guardados.
- `src/runfile.lua` y `src/save.lua`: 3 ranuras y compatibilidad con versiones antiguas.
- `assets/sprites`: **21 hojas animadas** incluyendo cuatro pelotas de colores.
- `tests`: pruebas de sintaxis, guardados, menús, economía y física.

## Pruebas

```bash
lua tests/runfile.lua
lua tests/smoke.lua
lua tests/menu_flow.lua
lua tests/experience.lua
lua tests/polish.lua
python3 tests/check_sprites.py
python3 tools/package_love.py
```

Para publicar se recomienda verificar el balance y la legibilidad manualmente en diferentes pantallas y sistemas. Ver `docs/PUBLICACION-V7.md`.

## Desarrollo de v8 por fases

La primera parte protege v7 con fixtures v4–v7, pruebas de tres ranuras, economía, colección y velocidad a 30/60/120 fps. Ver [informe de fase A](docs/V8-FASE-A.md), [inventario de referencia](docs/V8-ASSETS-BASELINE.md) y [plan completo](docs/PLAN-MAESTRO-BALLLER-V8.md).

```bash
lua tests/v8_compatibility.lua
lua tests/v8_economy.lua
lua tests/v8_physics.lua
```

El juego y el paquete siguen identificados como v7 hasta integrar las fases funcionales de v8.

La primera parte visual de B incorpora atlas PNG, 32 iconos, Nunito con licencia y componentes con relieve. Ver [guía visual](docs/V8-GUIA-VISUAL.md) y [pruebas y alcance B1](docs/V8-FASE-B1.md). Paquete de desarrollo: `python3 tools/package_love.py --output Balller-v8-B1.love`. Las capturas del motor se pueden reproducir desde el código fuente con `love . --visual-check`.
