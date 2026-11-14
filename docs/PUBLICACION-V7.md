# Balller v7 · Revisión de publicación

## Completado por pruebas automáticas

- Todos los archivos Lua pasan análisis de sintaxis.
- Hay 21 hojas de sprites individuales del tamaño esperado.
- Menús, dificultades, ranuras, borrado con confirmación, tienda, tutorial, colección, logros y ajustes reciben eventos.
- Los archivos de guardado anteriores se siguen leyendo y hay copias de recuperación.
- Las colisiones y los objetos mantienen una velocidad escalar constante dentro de cada ronda.
- No existen pagos, anuncios, sorteos, cajas aleatorias ni premios por iniciar sesión continuamente.
- `tools/package_love.py` produce un `.love` independiente.

## Pendiente de revisión manual antes de distribuir en tiendas

- Probar las cuatro dificultades durante varias rondas consecutivas.
- Revisar adaptación a resoluciones panorámicas pequeñas y escala de texto.
- Revisar sonido, controles de ratón y teclado en macOS y Windows.
- Comprobar el menú de colección con gemas reales y las recompensas de logros.
- Pedir a al menos una persona que nunca haya jugado que complete el tutorial.
- Añadir política de licencia y créditos definitivos antes de una distribución comercial.

## Criterios de interfaz

Inspiración: recomendaciones públicas de Unity sobre jerarquía y retroalimentación, de Apple sobre menús adaptables, y de Google sobre objetivos de interacción de al menos 48 dp. Estos puntos sirven para tomar decisiones, no para copiar la interfaz de otro juego.

- Una acción principal por pantalla.
- Icono + texto legible, nunca depender solo del color.
- El juego mantiene despejado el centro del campo.
- Las monedas de partida y gemas de colección se distinguen claramente.
- Recompensas permanentes deterministas, sin monetización ni mecanismos de azar.
