# Identidad visual de Balller

Balller utiliza una dirección de arte arcade, clara y colorida. Contornos azul marino, superficies iluminadas, colores diferenciados por función y siluetas reconocibles a pequeña escala.

Los recursos están separados por entidad en `assets/sprites/`. Cada PNG contiene una fila horizontal de cuadros de **128 × 128 píxeles** sobre fondo transparente. Se reproducen con el sistema `src/sprites.lua`.

| Archivo | Cuadros | Uso |
|---|---:|---|
| `character.png` | 16 | 4 direcciones × 4 cuadros de caminar |
| `ball.png` | 8 | Giro de la pelota |
| `spikes.png` | 8 | Aparición de pinchos |
| `drain.png` | 8 | Apertura de alcantarilla |
| `shield.png` | 8 | Brillo del escudo |
| `boost.png` | 8 | Pulso del impulsor |
| `lid.png` | 8 | Brillo de la tapa |

## Escala y movimiento

El tamaño de colisión se mantiene **independiente** del sprite. Los sprites se suavizan al reducirse para que las imágenes de alta resolución conserven contornos nítidos. Cada cuadro ocupa exactamente 128 × 128 píxeles, para evitar saltos al animarse.

Las advertencias aparecen **antes** del peligro activo: un anillo de color destaca los pinchos y otro señala la alcantarilla. Durante la fase de advertencia los objetos no causan daño.

Los sonidos, las partículas, los puntos flotantes y los mensajes de racha responden a las acciones del jugador. Se mantienen breves para que no dificulten la lectura de la cancha.

## Edición de recursos

Para reemplazar un sprite, conserva el nombre del PNG, la fila de cuadros, el fondo transparente y las dimensiones. El renderizador de LÖVE lo cargará automáticamente al iniciar.

`tools/build_sprites.py` puede regenerar los seis objetos a partir de ilustraciones vectoriales. Si se proporciona `tools/character_source.png`, también reconstruye el personaje. El juego contiene ilustraciones de respaldo en `src/sprites/` para permitir el arranque incluso sin los PNG.
