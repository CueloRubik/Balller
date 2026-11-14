# Lista de publicación de Balller

## Comprobaciones automatizadas

- Comprobación de sintaxis de todos los módulos Lua.
- Carga de sprites, incluidas las imágenes de respaldo generadas por código.
- Prueba de navegación, compras, rondas, guardados y peligro.
- Prueba de economía, mejoras, pulso de rescate, checksum y recuperación.
- Prueba de arranque con LÖVE en un entorno gráfico virtual (GitHub Actions).
- Creación reproducible de `Balller-v5.love` con `python3 tools/package_love.py`.

## Comprobaciones manuales antes de publicar oficialmente

1. Abrir el `.love` en macOS Catalina y Windows, con LÖVE 11.4 o posterior.
2. Probar movimiento diagonal, pulso cercano y pulso fuera de rango.
3. Completar rondas 1–7, incluyendo los tres nuevos peligros.
4. Comprar objetos hasta llenar la mochila y comprobar el coste del nivel 3 de zapatillas.
5. Guardar y salir a mitad de ronda, reiniciar el programa y recuperar.
6. Probar ventana pequeña y pantalla completa; revisar textos e iconos con distintos tamaños.
7. Comprobar que todas las canciones/efectos sean propios y que no haya recursos sin permiso de distribución.
8. Definir la licencia de publicación y los metadatos del proyecto antes de crear la primera distribución pública.

El código no contiene conexión a servidores ni sistemas de anuncios. El juego funciona sin acceso a Internet.
