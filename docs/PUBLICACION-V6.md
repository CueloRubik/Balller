# Balller v6 · Plan de verificación de publicación

## Diseño de la interfaz

Las referencias visuales se estudiaron por sus características generales, sin copiar gráficos ni marcas:
- Crossy Road: objetivos cortos, información de partida fácil de leer y pocas acciones dominantes.
- Bloons TD 6: selección reconocible por colores y símbolos, categorías de objetos con precios visibles.
- Brawl Stars: ilustración del personaje como foco visual del menú y botones grandes, con estados nítidos.

Balller utiliza una paleta clara, botones con volumen, iconos específicos y sprites propios. Los efectos de celebración son breves. No se añaden anuncios, monetización ni avisos diseñados para presionar a volver.

## Verificación obligatoria antes del lanzamiento público

- [ ] Probar la ejecución del `.love` de principio a fin en LÖVE 11.4+ sobre macOS y Windows.
- [ ] Confirmar que el cursor coincide con los botones en ventanas redimensionadas.
- [ ] Completar el tutorial con teclado y ratón; confirmar que no consume ranura.
- [ ] Crear, continuar, borrar y recrear las tres ranuras; confirmar que un borrado no toca las otras.
- [ ] Cargar una partida antigua de v4 y una de v5 con inventario de seis objetos.
- [ ] Jugar como Novato, Normal, Difícil y Experto, mínimo diez rondas por modo.
- [ ] Revisar compras, mochila llena, colocación inválida, portal, burbuja y recargas del pulso.
- [ ] Revisar visibilidad de advertencias del láser y del martillo.
- [ ] Confirmar lectura de todos los textos y nombres en la tienda y el HUD sin solaparse.
- [ ] Verificar pausas y pérdida de foco de ventana, y recuperación tras cerrar forzadamente.
- [ ] Verificar contraste y evitar destellos demasiado intensos o frecuentes.
- [ ] Aclarar licencia y derechos de distribución antes de publicar un release.

Las pruebas automatizadas sirven como cobertura técnica, no sustituyen las pruebas visuales ni las pruebas de balance.
