# Balller v6

**Balller** es un arcade cenital para LÖVE 2D (11.4+) y Lua: protege una pelota durante rondas cada vez más difíciles, compra defensas y mejora tu habilidad para superar tu récord. El juego es sin conexión, sin compras reales, sin anuncios y sin mecanismos de pago.

## Inicio

Abre la carpeta con LÖVE Studio o ejecuta `love .` dentro del proyecto. Para crear el juego instalable por arrastre en LÖVE, ejecuta `python3 tools/package_love.py`; se genera `dist/Balller-v6.love`.

## Menú y partidas

- **JUGAR:** elige una de cuatro dificultades y crea una partida en una ranura vacía.
- **MIS PARTIDAS:** continúa cualquiera de las tres ranuras, o pulsa **BORRAR** y confirma para liberar esa ranura. No se sobrescribe una partida existente de forma silenciosa.
- **APRENDER:** tutorial práctico, sin riesgos, de movimiento, golpe, pulso de rescate y colocación de defensas. No ocupa ranura.
- **GUÍA:** instrucciones e ilustraciones de los siete peligros.
- **SONIDO:** activa o desactiva los efectos.

### Dificultades

| Modo | Para quién | Ayudas |
| --- | --- | --- |
| **Novato** | Primera vez, dificultad suave | Pelota lenta, avisos largos, dos rescates por ronda |
| **Normal** | Equilibrio clásico | Un rescate por ronda, velocidad estándar |
| **Difícil** | Experiencia arcade | Sin rescates, peligros más rápidos, mejores recompensas |
| **Experto** | Máximo desafío | Más peligros y velocidad, avisos más breves, mejores recompensas |

La dificultad se guarda en la ranura. El progreso y los objetos se mantienen al continuar.

## Economía y rondas

Cada partida empieza con **40 monedas**, un escudo y una tapa. La tienda se abre antes de cada ronda. Puedes almacenar hasta **12 defensas**, máximo **5 de cada clase**. Una unidad se consume únicamente al colocarla correctamente. Comprar no equivale a colocar. Las mejoras de zapatillas aumentan la velocidad y se conservan en esa partida.

La recompensa base por una ronda superada es `18 + 6 × número de ronda`, más hasta 30 monedas por golpes y un premio variable por completar el objetivo. Los modos Difícil y Experto aumentan la recompensa. **Los puntos del récord no se gastan**: las monedas y la puntuación son sistemas separados.

| Objeto | Precio | Función |
| --- | ---: | --- |
| Escudo | 22 | Rebotar la pelota |
| Impulso | 30 | Lanzarla con más fuerza |
| Tapa | 20 | Cubrir una alcantarilla |
| Imán | 38 | Atraerla |
| Ventilador | 35 | Alejarla |
| Reloj | 34 | Reducir su velocidad |
| **Burbuja** | **42** | Dar una protección temporal al contacto |
| **Portal** | **48** | Llevarla a otra zona más segura |

### Peligros

Pinchos, alcantarillas, sierra móvil, descarga eléctrica, remolino, **martillo intermitente** y **láser giratorio**. Todos se anuncian antes de activarse. Se desbloquean conforme avanzan las rondas; el ritmo depende de la dificultad seleccionada.

## Controles

| Control | Función |
| --- | --- |
| WASD o flechas | Mover personaje en ocho direcciones |
| Espacio | Pulso de rescate cuando la pelota está cerca |
| Clic izquierdo | Colocar objeto seleccionado |
| Teclas 1 a 8 o rueda | Seleccionar defensa |
| P o Escape | Pausar y continuar |
| Enter | Abrir dificultades desde el menú o iniciar la ronda desde la tienda |

## Guardados

Se guardan tres partidas independientes, con copias de seguridad y validación de formato. Se conservan las partidas de las versiones v4 y v5. Se guarda al comprar, completar ronda, pausar, salir y periódicamente durante el juego. Una partida perdida libera su ranura pero no afecta las demás. La configuración y el tutorial completado se guardan aparte.

## Código y recursos

- `main.lua`: navegación, menús, HUD y controles.
- `src/game.lua`: ciclo de partidas, economía y tutorial.
- `src/difficulty.lua`: cuatro perfiles de dificultad.
- `src/objects.lua` y `src/hazards.lua`: ocho defensas y siete tipos de peligros.
- `src/runfile.lua` y `src/save.lua`: guardados compatibles y copias de recuperación.
- `src/art.lua`, `src/ui.lua`, `src/sprites.lua`: presentación y animaciones.
- `assets/sprites/`: **18 hojas PNG** separadas con **160 cuadros** de animación.
- `tests/`: pruebas de jugabilidad, menús, guardados, sprites y regresiones.

Todas las imágenes requeridas están en el juego. No es necesario instalar fuentes externas. Hay compatibilidad con fuentes opcionales sin empaquetarlas.

## Comprobación

```bash
lua tests/runfile.lua
lua tests/smoke.lua
lua tests/experience.lua
lua tests/menu_flow.lua
python3 tests/check_sprites.py
python3 tools/package_love.py
```

GitHub Actions ejecuta análisis de Lua, pruebas automáticas y una prueba gráfica de LÖVE en entorno virtual. Antes de distribuir públicamente: comprobar el juego manualmente en macOS y Windows, probar rondas largas en las cuatro dificultades y revisar `docs/PUBLICACION-V6.md`.
