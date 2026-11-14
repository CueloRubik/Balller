# Balller

**Balller** es un juego arcade cenital creado con Lua y LÖVE 11.4+. Controlas a un pequeño personaje que debe proteger una pelota mientras aparecen pinchos y alcantarillas. Ganas monedas al golpear la pelota y las utilizas para colocar defensas dentro de la cancha.

## Ejecutar

1. Instala [LÖVE](https://love2d.org/) 11.4 o más reciente.
2. Descarga el repositorio y ejecuta `love .` desde su carpeta, o arrastra la carpeta sobre `love.app`.
3. También puedes comprimir **el contenido** de la carpeta como `.love`.

No requiere librerías de terceros para ejecutar el juego. Los sprites PNG ya vienen incluidos.

## Controles

| Control | Función |
|---|---|
| WASD / flechas | Mover al personaje en ocho direcciones |
| Clic izquierdo | Colocar objeto seleccionado |
| Teclas 1 a 6 | Seleccionar un objeto |
| Rueda del ratón | Cambiar de objeto |
| P / Esc | Pausar o reanudar |
| Enter | Iniciar una partida o volver a jugar |

## Objetos

| Objeto | Función |
|---|---|
| Escudo | Devuelve la pelota al chocar |
| Impulso | La lanza con mayor fuerza |
| Tapa | Cubre una alcantarilla |
| Imán | Atrae la pelota cuando está cerca |
| Ventilador | La aleja del punto donde se coloca |
| Reloj | Reduce su velocidad cuando se aproxima |

La tienda muestra los precios y destaca si tienes suficientes monedas. Los objetos tienen duración limitada. El récord y el sonido se guardan localmente.

## Arte y presentación

- `assets/sprites/` contiene **11 PNG independientes** con **104 cuadros de animación** en total.
- El personaje tiene cuatro secuencias cardinales y cuatro secuencias diagonales de cuatro cuadros cada una. La pelota, los peligros y cada objeto tienen animación propia.
- `src/icons.lua` dibuja los iconos de la interfaz con código para que conserven definición a diferentes resoluciones.
- `src/ui.lua` contiene botones, tarjetas, tipografía, etiquetas y marcador.
- Opcional: si colocas las fuentes `Rubik-Regular.ttf` y `Rubik-Bold.ttf` en `assets/fonts/`, el juego las utilizará. Si no, funciona con la fuente interna de LÖVE. **Las fuentes no se incluyen en el repositorio.**

## Organización

- `main.lua`: pantallas, interfaz y eventos de LÖVE.
- `src/game.lua`: estado de la partida, puntuación, monedas y feedback.
- `src/player.lua`, `src/ball.lua`: movimiento y física.
- `src/hazards.lua`, `src/objects.lua`: peligros y defensas.
- `src/art.lua`, `src/sprites.lua`, `src/sprites/`: gráficos y animación.
- `src/icons.lua`, `src/ui.lua`, `src/theme.lua`: lenguaje visual.
- `src/audio.lua`, `src/feedback.lua`, `src/particles.lua`: efectos.
- `src/save.lua`: persistencia local.
- `tests/`: comprobación de sintaxis, arranque simulado y dimensiones de los PNG.

## Pruebas

```bash
python3 tests/check_sprites.py
lua tests/smoke.lua
lua tests/smoke.lua fallback
```

Para recompilar los PNG de los nuevos objetos: `python3 tools/create_extra_sprites.py` (requiere Pillow y CairoSVG). El PNG del personaje diagonal ya está incluido y no requiere recompilarse. El script puede utilizar opcionalmente `assets/source/character_diagonal_4x4.png` como material fuente para rehacerlo.

Las pruebas automáticas verifican la estructura, sintaxis y flujo simulado. No sustituyen una prueba visual interactiva en LÖVE.
