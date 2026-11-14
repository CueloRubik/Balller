# Balller

Balller es un juego arcade de vista cenital desarrollado en **LÖVE 2D** con Lua. Protege una pelota durante partidas rápidas: golpea, esquiva los pinchos y cubre las alcantarillas antes de que sea demasiado tarde.

## Ejecutar

Instala [LÖVE 11.4](https://love2d.org/) o posterior. Clona este repositorio y ejecuta:

```bash
love .
```

En macOS también se puede arrastrar la carpeta del proyecto a `love.app`, o abrirla desde LÖVE Studio.

## Controles

| Control | Función |
|---|---|
| WASD o flechas | Mover el personaje en todas las direcciones |
| Clic izquierdo | Colocar la defensa seleccionada |
| 1, 2, 3 | Seleccionar escudo, impulso o tapa |
| P o Esc | Pausar o reanudar |
| Enter | Comenzar o reiniciar |

## Características

- Gráficos claros con sprites originales en `assets/sprites.png`.
- Menú principal, instrucciones, controles del sonido, pausa y resultados.
- Pelota con rebotes, movimiento continuo y efectos de colisión.
- Pinchos y alcantarillas que se anuncian antes de activarse.
- Escudos, impulsores y tapas comprables durante cada partida.
- Sistema de monedas, puntuación y récord.
- Sonidos sintetizados en tiempo real, sin archivos de audio externos.
- Persistencia local del récord, puntos acumulados, partidas y preferencias.
- Ventana redimensionable que conserva la proporción del escenario.
- Tests automatizados de sintaxis y arranque simulado mediante GitHub Actions.

## Estructura

```text
Balller/
├── main.lua
├── conf.lua
├── assets/
│   └── sprites.png
├── src/
│   ├── arena.lua
│   ├── art.lua
│   ├── audio.lua
│   ├── ball.lua
│   ├── game.lua
│   ├── hazards.lua
│   ├── objects.lua
│   ├── particles.lua
│   ├── player.lua
│   ├── save.lua
│   ├── theme.lua
│   ├── ui.lua
│   └── util.lua
├── tests/
│   └── smoke.lua
└── .github/workflows/lua-checks.yml
```

## Desarrollo

La lógica está separada de los gráficos para facilitar ampliaciones y correcciones. Los sprites originales se agrupan en una hoja de 4 columnas por 2 filas, de 48 píxeles por celda.

La rama `development` es la versión en pruebas. Revisa los controles, la jugabilidad y los gráficos ejecutando LÖVE antes de etiquetar una versión estable.
