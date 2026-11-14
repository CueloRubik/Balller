# Balller

**Balller v5** es un juego arcade cenital hecho con **LÖVE 2D y Lua**. La misión es proteger una pelota de peligros durante una serie de rondas. Entre rondas, compras defensas que puedes colocar libremente en el terreno. Una partida termina cuando la pelota toca un peligro mortal.

## Jugar

Requiere LÖVE 11.4 o posterior:

```bash
love .
```

O abre esta carpeta desde LÖVE Studio. Para generar un `.love`, comprime el contenido de la carpeta (con `main.lua` en la raíz) y cambia `.zip` por `.love`.

## Cómo funcionan las partidas

1. En el menú, pulsa **Nueva partida** y selecciona una de las **tres ranuras**.
2. Empiezas en la **tienda** con 40 monedas, un escudo y una tapa gratis.
3. Compra defensas para tu mochila y pulsa **Jugar ronda 1**.
4. Controla al personaje con WASD o flechas. Golpea la pelota para desviarla y colócales defensas a los peligros con el ratón.
5. Cuando el tiempo llega a cero, ganas la ronda y vuelves a la tienda. Los objetos que no usaste siguen en tu mochila.
6. Cada nueva ronda dura un poco más y añade peligros o aumenta su frecuencia. Si pierdes, la partida finaliza y **se libera solamente su ranura de guardado**.

No hay monedas sueltas durante una ronda ni compras accidentales al colocar defensas. **Las monedas se ganan únicamente al completar una ronda y se gastan únicamente en la tienda.**

## Monedas y puntuación

- **Monedas iniciales:** 40.
- **Recompensa por superar una ronda:** `18 + 6 × número de ronda`.
- **Bonus por golpes:** `2 × mínimo(golpes de la ronda, 15)`.
- **Objetivo opcional variable:** alterna entre golpear la pelota, conseguir rebotes en paredes y colocar defensas. El premio crece gradualmente desde **12 monedas**.
- Ejemplo: en la ronda 1, si golpeas 7 veces, recibes **24 + 14 + 12 = 50 monedas**. En la ronda 2 la meta son los rebotes en paredes.
- El **score** es independiente de las monedas. Aumenta por tiempo sobrevivido, golpes, rachas, defensas y rondas superadas. Sirve para superar el récord.

| Defensa | Precio | Función |
| --- | ---: | --- |
| Escudo | 22 | Rebota la pelota |
| Impulso | 30 | La dispara con más fuerza |
| Tapa | 20 | Cubre una alcantarilla |
| Imán | 38 | La atrae en su radio |
| Ventilador | 35 | La empuja en su radio |
| Reloj | 34 | Reduce su velocidad cercana |

Puedes mejorar tus **zapatillas** hasta el nivel 3 pagando **65, 120 y 175 monedas**. Cada nivel aumenta permanentemente la velocidad del personaje en esa partida.

Puedes almacenar hasta **12 objetos** en total, con un máximo de **5 de cada tipo**. Solo se consume una unidad al colocarla correctamente. Las defensas colocadas duran un tiempo limitado y desaparecen entre rondas.

## Dificultad y peligros

- **Ronda 1:** pinchos que emergen y alcantarillas que se abren.
- **Ronda 2:** se desbloquea una **sierra móvil** que rebota contra los bordes.
- **Ronda 4:** aparece una **descarga eléctrica** intermitente, peligrosa mientras brilla.
- **Ronda 6:** se incorpora el **remolino**, que cambia la dirección y velocidad de la pelota sin destruirla directamente.
- Los peligros tienen un aviso previo antes de activarse. Conforme avanzas, aparecen con mayor frecuencia y puede haber más simultáneamente (con un límite de 7).
- Las rondas duran 28 segundos al empezar y aumentan 2 segundos por ronda, hasta un máximo de 55 segundos.

## Guardado y recuperación

Hay **3 ranuras independientes**. Se guardan automáticamente cada **8 segundos** de juego, cuando empieza o termina una ronda, cuando compras, al pausar y al cerrar la aplicación. También puedes pulsar **Guardar** desde la pausa o **Guardar y salir** desde la tienda.

**Continuar** en el menú restaura la partida, incluyendo ronda, monedas, inventario, posiciones y peligros. Si la ronda estaba en curso, se reabre pausada. La partida perdida deja de poder continuarse. La opción **Reemplazar** pide confirmación antes de borrar otro guardado.

Los guardados se almacenan en la carpeta de datos de LÖVE bajo la identidad `balller`:

- `save.txt`: récord, puntuación histórica, partidas y preferencias de sonido.
- `partida_1.txt`, `partida_2.txt`, `partida_3.txt`: partidas recuperables.

El lector de guardados valida los campos, utiliza una suma de comprobación para nuevas partidas y no ejecuta código desde archivos de guardado. Se conserva un archivo de respaldo `.bak` para recuperar una ranura dañada. Las partidas anteriores siguen siendo compatibles.

## Controles

| Tecla | Acción |
| --- | --- |
| WASD / flechas | Mover al personaje en ocho direcciones |
| Espacio | Pulso de rescate cercano (10 segundos de recarga) |
| Clic izquierdo | Colocar la defensa seleccionada |
| 1–6 | Elegir una defensa de la mochila |
| Rueda del ratón | Cambiar defensa seleccionada |
| P / Escape | Pausar o continuar |
| Enter | Abrir elección de ranura o iniciar ronda desde la tienda |

Se pausa automáticamente al perder el foco de la ventana.

## Gráficos, sonidos y organización

El juego utiliza 14 hojas PNG independientes con **128 cuadros de animación** (128 × 128 por cuadro) y texturas separadas de personaje, pelota, defensas y peligros. Se incluyen dibujos alternativos por código si no se encuentran las imágenes. La interfaz conserva el aspecto claro y colorido de Balller v3.

- `main.lua`: menús, tienda, ranuras, entrada y dibujo de interfaz.
- `src/game.lua`: ciclo de rondas, economía y puntuación.
- `src/hazards.lua`: lógica de los cinco peligros.
- `src/objects.lua`: seis defensas e inventario.
- `src/runfile.lua` y `src/save.lua`: serialización segura y tres ranuras.
- `src/art.lua`, `src/sprites.lua`, `src/icons.lua`, `src/ui.lua`: dibujo y animaciones.
- `assets/sprites/`: PNG separados por tipo.
- `tools/create_hazards.py`: genera las tres nuevas hojas PNG (requiere Pillow y CairoSVG solo para regenerar recursos).
- `tests/`: pruebas de lógica, arranque simulado y sprites.

## Pruebas

En un equipo con Lua 5.4 y Python 3:

```bash
lua tests/smoke.lua
lua tests/smoke.lua fallback
lua tests/verify_directions.lua
python3 tests/check_sprites.py
```

Se pueden ejecutar pruebas de sintaxis con `luac -p`. Estas pruebas no sustituyen una revisión visual dentro de LÖVE.

## Construir versión para compartir

Ejecuta `python3 tools/package_love.py` para generar `dist/Balller-v5.love`. GitHub Actions también comprueba el arranque gráfico con LÖVE y ofrece el `.love` como archivo descargable de la ejecución.

Consulta `docs/PULIDO-V5.md` para conocer las mejoras y `docs/PREPARAR-PUBLICACION.md` para la lista de comprobaciones antes de un lanzamiento oficial.
