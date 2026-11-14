# Arte y animaciones de Balller

## Estilo visual

Arcade luminoso y colorido con materiales satinados, contorno azul marino, reflejos suaves y sombras cortas. El personaje tiene pelo azul, cinta azul/blanca, playera turquesa y tenis blancos. Los paneles de la interfaz usan el mismo azul marino, blanco, verde menta, amarillo y rosa de los sprites, sin degradados oscuros ni texto decorativo difícil de leer.

## Hojas PNG

Cada cuadro mide 128 x 128 px y las hojas son horizontales. Los sprites se cargan por `src/sprites.lua`. Si no existe un PNG, el juego tiene dibujo alternativo desde `src/sprites/`.

| Archivo | Cuadros | Uso |
|---|---:|---|
| character.png | 16 | 4 movimientos en abajo/derecha/arriba/izquierda, 4 cuadros por dirección |
| character_diagonal.png | 16 | 4 movimientos en abajo-derecha, abajo-izquierda, arriba-derecha, arriba-izquierda |
| ball.png | 8 | Giro de la pelota |
| spikes.png | 8 | Pinchos que emergen |
| drain.png | 8 | Alcantarilla que se abre |
| shield.png | 8 | Escudo luminoso |
| boost.png | 8 | Impulsor animado |
| lid.png | 8 | Tapa con reflejos |
| magnet.png | 8 | Imán oscilante |
| fan.png | 8 | Aspas que giran |
| clock.png | 8 | Agujas del reloj |

## Interfaz

- Menú con ilustración del personaje y pelota, botones destacados e indicadores de récord.
- Marcador con iconos de estrella, moneda y reloj.
- Tienda con iconos reales de cada objeto, atajos 1 a 6 y precio con estado de disponibilidad.
- Tarjetas superpuestas para instrucciones, pausa y resultados.
- Fuentes opcionales Rubik (Regular/Bold) con fallback de LÖVE.

## Feedback

Los golpes y rebotes añaden partículas breves, sonidos de distinta altura, números emergentes y rachas. No hay compras reales ni temporizadores para presionar al jugador a volver. Los efectos se pueden desactivar mediante la opción de sonido del menú.
