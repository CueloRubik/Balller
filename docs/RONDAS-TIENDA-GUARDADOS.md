# Rondas, tienda y partidas guardadas

## Economía

El dinero está separado del récord y de la puntuación. Los objetos ya no se pagan al ponerlos: cada compra en la tienda añade una unidad al inventario, y colocar un objeto consume la unidad únicamente si el lugar es válido. Se conservan los objetos no utilizados después de una ronda.

`recompensa = 18 + 6*ronda + 2*min(golpes, 15) + (golpes >= min(15, 5+ronda) ? 12 : 0)`

La recompensa solo se otorga cuando se completa el cronómetro. Comprar no aumenta score y golpear no aumenta monedas al instante. La tienda muestra el saldo y la recompensa anterior para evitar confusiones.

## Progresión

La duración empieza en 28 s, aumenta 2 s por ronda y se limita a 55 s. La frecuencia de aparición aumenta y el límite de peligros concurrentes pasa de 2 a 7. Los tipos disponibles aumentan en las rondas 2 (sierra), 4 (descarga) y 6 (remolino). La sierra se mueve; la descarga alterna entre activada y apagada; el remolino ejerce una fuerza perpendicular sobre la trayectoria de la pelota.

## Guardado

Tres archivos independientes en los datos de LÖVE. El formato es de texto plano y versionado (`BALLLER_RUN_2`). Se guardan estado, ronda, tiempo restante, puntuación, monedas, golpes, mochila, jugador, pelota, peligros y defensas. Al recuperar una ronda en curso se abre en pausa. No se ejecutan fragmentos de código desde los archivos: se leen y validan números y etiquetas permitidas.

Se guarda automáticamente al comprar, comenzar y terminar una ronda, al pausar, al salir al menú y al cerrar el juego. Si la pelota se pierde, se borra solo la ranura correspondiente. Reemplazar una ranura necesita confirmación.

## Verificación

Las pruebas comprueban guardado/recuperación, pausa, recompensa, límite de mochila, espacios separados, ocho direcciones, sprites, peligros nuevos y arranque simulado con y sin PNG. La revisión visual con LÖVE sigue siendo necesaria.
