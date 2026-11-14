# Balller v8 — Plan maestro de transformación

> **Estado:** especificación y hoja de ruta. **No implica que estas funciones estén implementadas.**  
> **Fecha:** 14 de noviembre de 2026.  
> **Repositorio:** https://github.com/CueloRubik/Balller  
> **Base de trabajo comprobada:** rama \`main\`, Balller v7, commit \`43f2ada6f2c2e7ac131f89945e67125990269aea\`.  
> **Motor:** LÖVE 2D 11.4+, Lua. Primero escritorio (Windows/macOS); diseño concebido para una futura adaptación Android. **No se promete un APK en v8.**  
> **Alcance de este documento:** instrucciones autónomas para un siguiente chat/agente con acceso a GitHub y herramientas de creación de PNG/audio.

## 0. Qué pidió el creador y qué NO debe cambiar

**Objetivo:** transformar de modo drástico y visible la v7 en un juego arcade casual de calidad publicable, con UI de videojuego móvil (aunque hoy se ejecute en computadora), una identidad gráfica coherente, abundante iconografía PNG, tienda real, economía, progresión, capítulos, desafíos, nuevos objetos/peligros, buenos sonidos y efectos, y mecánicas COMPLETAS y conectadas entre sí.

**Conservar obligatoriamente:**
- Juego cenital dentro de una cancha: personaje humano caricaturesco, mueve/golpea una pelota, debe protegerla de amenazas.
- Partidas de rondas crecientes; tres ranuras guardables; continuar/eliminar con confirmación; cuatro aspectos de pelota y progreso anterior.
- Los sprites del personaje y sus 8 direcciones, y su estilo alegre/cartoon de contornos cuidados, como referencia para todo el arte futuro.
- Interacción básica simple: WASD/flechas, clic para colocar objeto, espacio para pulso, Escape/P para pausa.
- Pelota de **rapidez escalar controlada y estable durante cada ronda**; objetos alteran trayectorias y situaciones, no aceleran aleatoriamente.
- Juego **offline**, sin anuncios, sin dinero real, sin cajas de azar; recompensas claras y desbloqueos deterministas.
- Compatibilidad razonable con computadoras antiguas (incluido macOS Catalina), pocos recursos, ejecución fluida.

**Evitar:** pantallas que parecen una web, paneles genéricos hechos solo de \`love.graphics.rectangle\`, texto excesivo, nombres abstractos sin relación con las mecánicas, tiendas sin funcionalidad, exceso de indicadores durante la ronda, recompensas engañosas, progreso que se borra al actualizar.

**Regla de desarrollo:** ninguna funcionalidad se marca terminada solo por verse bonita. Requiere flujo completo (UI → lógica → economía/guardado → respuesta visual/audio → pruebas).

## 1. Auditoría de v7 antes de tocar código

Estructura confirmada del repositorio:
- \`main.lua\`: entrada, navegación, controles.
- \`src/v7screens.lua\`: menú, selector de dificultad, ranuras, colección, logros, ajustes, tienda y HUD.
- \`src/ui.lua\`, \`src/icons.lua\`, \`src/theme.lua\`, \`src/art.lua\`: widgets, iconos programáticos, paleta, renderizado.
- \`src/game.lua\`, \`src/ball.lua\`, \`src/player.lua\`, \`src/objects.lua\`, \`src/hazards.lua\`, \`src/rounds.lua\`, \`src/collectibles.lua\`: lógica.
- \`src/progression.lua\`, \`src/runfile.lua\`, \`src/save.lua\`, \`src/difficulty.lua\`: economía/progreso/guardados/dificultades.
- \`src/audio.lua\`: actualmente sintetiza una pequeña colección de tonos; necesita motor de audio y assets.
- \`assets/sprites/\`: 21 hojas de sprites en v7 (4 pelotas incluidas).
- \`tests/\`: pruebas de guardados, navegación, física y progresión; \`.github/workflows/lua-checks.yml\`: CI.

**Primero:** inventariar dependencias entre módulos, ejecutar pruebas tal como están en el README y registrar baseline. Crear rama \`feature/v8-rework\` desde el \`main\` ACTUAL, sin borrar v7. Si \`main\` cambió tras escribir este documento, comparar antes de trabajar. Crear una etiqueta de respaldo de v7 solo si la política del repositorio y el dueño lo permiten. Evitar reemplazar todo \`main.lua\` de golpe.

## 2. Producto: mapa de pantallas y flujos completos

### Navegación principal
Diseñar **cinco destinos como máximo**, con icono PNG propio, color de estado, etiqueta breve y una acción dominante:
1. **Jugar**: personaje ilustrado, botón grande JUGAR, continuar, progreso del capítulo.
2. **Tienda**: cosméticos y mejoras permanentes (si están desbloqueadas), separada de la tienda consumible entre rondas.
3. **Colección**: pelotas, personajes/apariencias, rastros, marcos y fondos; equipar inmediatamente.
4. **Retos**: misiones opcionales diarias/semanales, logros, hitos de capítulo, recompensas reclamables claras.
5. **Ajustes**: música/SFX, accesibilidad, tutorial, ayuda, controles y créditos/licencias.

**Forma:** navegación con iconos y nombres, barra inferior cuando sea útil en tamaño compacto y barra lateral o fila inferior ancha en escritorio; no copiar interfaces Android literalmente. Un solo botón principal grande por pantalla, menos texto y más imágenes. Las secciones secundarias usan pestañas o paneles explícitos.

### Flujo de partida
\`Menú → Jugar → [Nueva/Continuar] → [Ranura y dificultad al crear] → Taller previo → Ronda → Recompensa de ronda → Taller → Siguiente ronda\`.
\`Fin de partida → Resumen animado → récord/progreso obtenido → volver al menú o empezar nueva\`.
\`Pausa → seguir / guardar y salir / ajustes de audio\`.
\`Tutorial → práctica guiada → menú\`, sin usar ranura y sin premios duplicables.

### Ranuras
- Mostrar avatar/skin, dificultad, capítulo/ronda, puntuación, monedas e instante de guardado.
- Botones diferenciados: **Continuar**, **Eliminar** (confirmación), **Nueva** solo en ranura vacía.
- Guardado automático y manual, con respaldo y restauración visible si se detecta corrupción.
- Nunca eliminar una partida sin confirmación. Mantener compatibilidad con archivos v4-v7.

## 3. Identidad visual: un juego móvil, no una web

**Dirección:** arcade ilustrado luminoso, energético pero ordenado, con el personaje de Balller como protagonista. Los sprites existentes son el canon estilístico; unificar contornos, sombras, proporciones, saturación y perspectiva cenital.

**Paleta propuesta (ajustable tras pruebas visuales):**
- turquesa/menta = jugar/confirmar
- azul vivo = navegación/acciones secundarias
- oro/naranja = monedas y recompensas
- violeta = gemas y colección
- coral = peligro y borrar
- marfil/azul cielo = fondos respirables
Usar también silueta, icono y texto: nunca depender solo del color.

**Elementos PNG exigidos:**
- Botones en 4 estados (normal, pulsado, deshabilitado, destacado); bordes y sombras consistentes.
- Paneles de tienda, tarjetas de objetos, marcos de ranura, modales y marcadores como arte propio; **9-slice** para estirar sin deformar esquinas.
- Iconos únicos para TODAS las pestañas/monedas/gemas/ronda/reloj/pausa/guardar/borrar/ayuda/objetivo y cada mejora.
- Barras ilustradas de progreso de capítulo, recarga del pulso y objetivo.
- Fondos por pantalla/capítulo, separadores y ornamentos mínimos.
- Tipografía de videojuego amable y muy legible; evaluar Fredoka/Nunito u otra fuente cuya redistribución (OFL u otra licencia válida) esté verificada. Guardar licencia de fuente en el repo. Evitar MAYÚSCULAS para frases largas, desbordamientos y texto diminuto.

**Resoluciones objetivo para probar:** 1000×680 (base actual), 1280×720, 1920×1080, 1366×768 y 800×600; mantener botones clicables al escalar. A futuro controles táctiles sin rediseño desde cero. Emplear coordenadas lógicas, anclajes y áreas seguras.

**Mínimo artístico verificable:** guías de estilo + atlas PNG de UI + al menos 30 iconos PNG identificables + estados gráficos por botón + vista previa y captura de cada pantalla en distintas resoluciones; no sustituir con búsquedas de imágenes externas.

## 4. Economía simple, conectada y sin confusión

| Recurso | Se gana | Se usa | Persistencia |
|---|---|---|---|
| Puntos | Juego y objetivos | Récord/clasificación personal | Historial y récord |
| Monedas | Rondas, metas y habilidad | Defensas consumibles y mejoras de ESA partida | Solo la ranura |
| Gemas | Capítulos, logros, retos; cantidad fija visible | Cosméticos de colección | Perfil global |
| Estrellas recogibles | En cancha | Puntos, objetivos y progreso de reto | Estadística/retos, no una 4.ª moneda de tienda |
| Trofeos/medallas | Capítulos y dificultad | Indicador de dominio/desbloqueo, no otra billetera | Perfil global |

Separar con nombres inequívocos **Tienda de partida** (monedas, se abre entre rondas) de **Tienda de colección** (gemas, desde menú). El jugador debe ver antes de comprar: función, precio, saldo, cantidad, duración, estado comprado/equipado y si la compra es permanente.

Balance definido por tablas de configuración y simulaciones: coste de equipamiento inicial accesible, decisiones interesantes de gasto, dificultad creciente sin obligar a grind. No premiar repetir intencionalmente una ronda infinitas veces; las gemas de hitos se dan una sola vez. La pérdida de una partida termina esa ranura, pero no borra cosméticos, logros ni gemas.

## 5. Nuevo sistema de juego: capítulos y rondas

- Cada **capítulo** tiene 10 rondas y un tema visual; las primeras 9 presentan/mezclan amenazas, la 10 es un **desafío especial de jefe** con patrones telegrafiados.
- Prototipos de capítulos: Patio, Taller y Ciudad. No crear docenas de mapas hasta validar 3 capítulos.
- Tipos de ronda: supervivencia, estrellas, rebotes precisos, uso de defensas, tormenta, rescate y desafío de jefe.
- Cada ronda especifica objetivo, amenazas permitidas, aviso previo, rapidez fija, duración y recompensa. El jugador ve el objetivo y la recompensa **antes** de empezar.
- Cinco modos propuestos: **Aprendiz**, Fácil, Normal, Difícil, Experto. **Migrar sin alterar la dificultad histórica:** v7 id 1 Novato → Fácil, 2 Normal → Normal, 3 Difícil → Difícil, 4 Experto → Experto. El modo Aprendiz nuevo no debe reasignar accidentalmente partidas antiguas.
- Aprendiz: introducción contextual, advertencias largas y peligros reducidos. Evitar que la dificultad base dependa de reflejos extraordinarios.
- Jefes: amenazas ambientales grandes con fases visuales y zonas seguras, sin requerir sistemas de combate complejos. Un patrón jugable y verificable antes de crear nuevos jefes.
- Progreso guardado al inicio y cierre de cada ronda y durante la partida; no duplicar premios por restaurar un archivo.

### Física: invariante obligatoria
\`targetSpeed = velocidadPorDificultadYRonda\`, calculada una vez al inicio de la ronda, limitada y documentada. Luego, si la pelota se mueve, \`sqrt(vx²+vy²) ≈ targetSpeed\` tras aplicar colisiones/fuerzas, salvo pausa y momentos explícitos de teletransporte/rescate. Los objetos repelen, atraen, reflejan, desvían o afectan amenazas; no aceleran aleatoriamente la pelota. Tratar vector cero con dirección de recuperación determinista. Usar paso de física acotado y pruebas a 30/60/120 fps.

## 6. Objetos, peligros y mecánicas verdaderamente completas

**Conservar ocho defensas existentes:** Escudo, Impulso, Tapa, Imán, Ventilador, Reloj, Burbuja y Portal. Revisar su utilidad, precios, duración, posicionamiento y señalización.

**Ampliación candidata a 12 defensas**, cada una con sprite PNG, animación, icono de tienda, efecto visual/sonoro, compra, mochila, colocación y prueba:
1. **Muro temporal:** redirige la pelota; orientación elegible con clic secundario/tecla auxiliar.
2. **Rebotador angular:** rebota con una dirección configurada, sin alterar rapidez escalar.
3. **Gel protector:** crea zona donde las amenazas tardan más en activarse (no ralentiza la pelota).
4. **Faro:** señala y repele durante segundos una amenaza cercana, con radio claramente visible.

**Más habilidades de jugador:** pulso de rescate (actual), indicador de recarga, mejora de alcance del pulso dentro de la partida, una decisión estratégica de emergencia con coste/cooldown visible. No llenar la pantalla de diez botones.

**Siete peligros actuales**: pinchos, alcantarilla, sierra, descarga, remolino, martillo, láser. **Cinco candidatos nuevos**, cada uno con aviso claro, zona segura, comportamiento distinguible y sprite:
1. **Charco pegajoso:** cambia trayectoria/crea desvío de la pelota, pero no reduce permanentemente su rapidez.
2. **Puerta corrediza:** abre/cierra trayectorias con anticipación.
3. **Barrera móvil:** cambia de posición lentamente y modifica rebotes.
4. **Disco saltarín:** amenaza que sigue un patrón repetible, no persigue infaliblemente.
5. **Ráfaga de viento:** empuja dirección sin cambiar rapidez final.

**Regla de justicia:** nunca generar peligros directamente encima de pelota/personaje; dar aviso suficiente, garantizar salida de la zona, limitar simultaneidad por dificultad. Separar peligros que terminan la partida de los que cambian la trayectoria. Enseñar cada amenaza antes de combinarla con otras.

**Rondas especiales y retos:** completar objetivo de capítulo, rescate cercano, recoger estrellas con trayectoria, evitar una zona de riesgo, puntuar con rebotes; recompensas especificadas en tabla, sin premios al azar.

## 7. Progreso y motivación sin mecánicas de presión

Añadir sistemas con principios claros y una experiencia agradable:
- **Colecciones** de pelotas, rastros, marcos, fondos y variantes del personaje. Cosméticos sin ventaja oculta.
- **Misiones** diarias y semanales **opcionales** (se puede jugar indefinidamente sin cumplirlas), además de logros permanentes.
- **Recompensa diaria fija opcional**, sin castigo por faltar un día ni mensajes que presionen a volver.
- **Mapa de capítulos** con medallas de completado por dificultad, premios visibles y desbloqueos.
- **Perfil de estadísticas**: rondas completadas, récord, golpes, rescates, estrellas, defensas favoritas.
- **Resultados de ronda**: resumen claro con objetivo, monedas, gemas del hito, misión completada y próximo desbloqueo.
- **Primeras sesiones**: tutorial guiado interactivo, indicaciones contextuales breves y botón Omitir/Repetir tutorial.

No implementar cajas aleatorias, ruletas, compras reales, anuncios obligatorios, rachas punitivas, timers de escasez artificial o notificaciones insistentes. Una buena sensación de progreso debe salir de decisiones, habilidad y objetivos comprensibles.

## 8. Audio: descarga, licencias y producción

**Sí es posible** descargar sonidos externos y subirlos al repositorio **si la fuente permite su redistribución y uso dentro del juego**. No subir música comercial ni extraer audios de otros juegos. No asumir que “gratis” equivale a “redistribuible”.

**Fuentes candidatas revisadas:**
- Kenney (https://kenney.nl/support): declara assets de sus páginas bajo **CC0**, aptos para proyectos comerciales; comprobar licencia por paquete. Ejemplos: https://kenney.nl/assets/ui-audio y https://kenney.nl/assets/impact-sounds .
- Freesound (https://freesound.org/help/faq/): cada archivo tiene licencia propia; **preferir CC0**. Si se usa CC BY, cumplir créditos y conservar licencia; descartar contenidos NC/no claros.
- Alternativa: SFX/música originales generados por código o compuestos para Balller.

**Proceso obligatorio para cada archivo externo:**
1. Elegir efecto para una interacción real, no descargar paquetes enteros sin revisión.
2. Abrir página oficial del **archivo o paquete específico** y comprobar autor, URL, licencia, uso comercial y redistribución.
3. Descargar, inspeccionar, recortar, normalizar volumen, convertir a \`.ogg\` (música/loops) o \`.ogg\`/\`.wav\` (SFX), validar duración, pico, loop y calidad.
4. Guardar solamente los seleccionados: \`assets/audio/sfx/\`, \`assets/audio/music/\`.
5. Crear \`assets/audio/SOURCES.md\` (archivo, autor, página, licencia, enlace, fecha de revisión, modificaciones) y conservar LICENCIAS aplicables. Para fuentes sin permiso de redistribución, **no subir**.
6. Integrar en \`src/audio.lua\` un bus mezclador sencillo con canales Música, Efectos y UI, volumen por categoría, mute independiente, transiciones y limitación de voces simultáneas.
7. Asegurar que el juego sigue abriendo si un asset de audio falta: fallback silencioso o tono actual; informar en logs, no crashear.

**Inventario objetivo inicial:**
- 12–20 SFX de interacción (clic, atrás, confirmar, comprar, error, recoger moneda/gema, desbloquear, guardar, logro, etc.).
- 10–15 SFX de juego (golpe, rebote, pulso, colocar, defensa rota, aviso, amenaza activa, rescate, pérdida, victoria).
- 3–5 pistas cortas y loopables: menú, partida, tienda/colección, jefe y victoria breve. Evitar música excesivamente intensa.
- Variación pequeña de tono/volumen para evitar repetición, con límite de volumen y mezcla agradable.
- Ajustes Música, Efectos y Reducir estímulos; sonidos de advertencia distinguibles de premios.

**NO se descargan audios como parte de este documento:** son tareas para la fase de producción con verificación de licencias, elección auditiva y pruebas.

## 9. Arquitectura propuesta (con migraciones; no reescritura ciega)

\`\`\`text
main.lua
conf.lua
src/
  core/                 estado, navegación, configuración, eventos
  gameplay/             pelota, jugador, arena, física, objetos, peligros, capítulos, jefes
  economy/              monedas de partida, gemas, recompensas, precios
  progression/          logros, misiones, colección, perfil, estadísticas
  persistence/          esquema versionado, migradores v4-v7, respaldo, validación
  presentation/         widgets con atlas PNG, 9-slice, animación de UI, escalado, iconos
  screens/              inicio, partidas, dificultad, tienda, colección, retos, ajustes,
                        taller, ronda, resultados, tutorial
  audio/                carga de recursos, buses, mezcla, transiciones
  vfx/                  partículas, transiciones, números y avisos de contraste
assets/
  ui/                   atlas y PNG por tipo (botones, paneles, iconos, indicadores)
  sprites/              personaje, pelotas, defensas, peligros, jefes
  backgrounds/          menú, cancha, capítulos, resultados
  fonts/                archivo(s) con licencia confirmada
  audio/sfx/
  audio/music/
  audio/SOURCES.md
data/                   definiciones Lua de precios, dificultad, misiones, capítulos, objetos
tests/                  unitarios, migración, UI, integración, escenarios
tools/                  generadores de PNG, scripts de comprobación y empaquetado
docs/                   plan maestro, guía de arte, audio, publicación y cambios
\`\`\`

**Migración incremental:** los módulos existentes continúan funcionando hasta que los nuevos queden probados. No mover toda la carpeta \`src\` en una sola PR. Mantener un adaptador temporal cuando sea necesario.

**Datos:** usar identificadores estables para objetos, skins, dificultades y peligros; no guardar solo índices numéricos que cambian al insertar contenido. Guardado \`BALLLER_RUN_3\` y perfil \`BALLLER_PROFILE_2\` si se necesitan campos nuevos; lectores de esquemas anteriores y respaldos. Probar que las ranuras no se mezclen ni se borren durante migración.

## 10. Fases de trabajo y criterios de salida

Se debe desarrollar en **PRs pequeñas y comprobables** sobre \`feature/v8-rework\` (o ramas individuales creadas desde \`main\` y luego integradas con orden). Cada fase lleva captura o preview real cuando sea UI. No declarar éxito sin comprobar archivos y commits.

### Fase A — Congelar referencia y documentar
- [ ] Leer última versión del repo, registrar commit, ejecutar las pruebas anteriores.
- [ ] Guardar inventario de assets y mapa de dependencias; definir licencias existentes.
- [ ] Crear pruebas de regresión para 3 ranuras, economía, velocidad constante y colecciones.

**Salida:** v7 se reproduce y pasa pruebas antes de cambios.

### Fase B — Nuevo lenguaje visual
- [ ] Guía gráfica final y maquetas de: inicio, tienda partida, tienda global, colección, retos, juego, resultado.
- [ ] Producir botones/paneles/iconos PNG, 9-slice, fuentes con licencia.
- [ ] Estados pulsado/deshabilitado/equipado/bloqueado; iconografía para todas las acciones.

**Salida:** las pantallas muestran arte coherente y mínimo texto, legibles a 800×600 y 1080p.

### Fase C — Navegación y facilidad de uso
- [ ] Cinco destinos; Nueva/Continuar; gestión de ranuras; pausa y resultados.
- [ ] Tooltip breve opcional en tienda, confirmación de borrado, tutorial guiado y ayuda.
- [ ] Asegurar que el HUD no tapa la pelota ni los peligros; teclado/ratón y diseño táctil futuro.

**Salida:** una persona nueva entiende cómo empezar una partida sin explicación externa.

### Fase D — Economía y tiendas completas
- [ ] Separar tienda de consumibles y tienda de cosméticos.
- [ ] Precios configurables, compra/equipamiento, categorías, stock/inventario, saldo y devolución solo cuando corresponda.
- [ ] Recompensa por ronda y resumen visual; duplicaciones y compras inválidas bloqueadas.

**Salida:** circuito \`jugar → ganar → gastar → colocar/equipar → guardar → continuar\` funciona sin pérdidas/doble gasto.

### Fase E — Núcleo de juego y capítulos
- [ ] Fijar física constante y pruebas para todas las interacciones.
- [ ] Cinco dificultades con migración; 3 capítulos de 10 rondas, objetivos variados y primeros jefes ambientales.
- [ ] Cuatro defensas nuevas y cinco peligros nuevos con arte/sonido/advertencia/colisión/prueba.

**Salida:** escenarios jugables de principio a fin; ningún peligro nace imposible de evitar.

### Fase F — Colección, retos y progresión
- [ ] Cosméticos adicionales e inventario global.
- [ ] Misiones opcionales diarias/semanales, logros y medallas de capítulos; recompensas deterministas.
- [ ] Estadísticas, recompensas una sola vez, guardados y retrocompatibilidad.

**Salida:** cerrar/abrir conserva todo y no duplica gemas ni logros.

### Fase G — Audio y feedback
- [ ] Investigar, seleccionar y descargar audio con licencia; \`SOURCES.md\`.
- [ ] Música y SFX por pantalla/acción, bus de audio, ajustes, fallback.
- [ ] Animación de recompensa, efectos de colisión, UI táctil/pulsación, control Reducir estímulos.

**Salida:** el audio no satura, los efectos no interrumpen y el usuario puede desactivar música y SFX por separado.

### Fase H — Calidad y publicación
- [ ] Pruebas unitarias/integración, simulación de muchas rondas y revisión manual.
- [ ] Test visual y de rendimiento en macOS Catalina/Windows; verificar fuentes, formatos y carga de RAM.
- [ ] Créditos, licencias, documentación, changelog, icono, capturas, zip y \`.love\`.
- [ ] Crear release candidato en GitHub **solo cuando** se apruebe la lista de verificación y el dueño esté de acuerdo.

**Salida:** release candidate con limitaciones conocidas documentadas, no promesa de “sin errores”.

## 11. Pruebas que no se pueden omitir

- [ ] Todos los \`.lua\` pasan \`luac -p\`; pruebas anteriores y nuevas en GitHub Actions.
- [ ] Tests específicos para velocidad: rebote, golpe, impulso, imán, ventilador, remolino, pulso, portal y vector cero.
- [ ] Rondas 1–10 de cada dificultad; casos máximos de peligros simultáneos y jefes.
- [ ] 3 ranuras: crear, continuar, pausar, cierre abrupto, eliminar, recrear, recuperación de respaldo.
- [ ] Migración de partidas v4, v5, v6, v7 y perfil v7 **sin sobrescribir originales hasta validar**.
- [ ] Monedas/gemas: evitar saldos negativos, premios duplicados, comprar sin fondos y llenar la mochila.
- [ ] Misión/objetivo/medalla/cosmético: recompensa única, persistencia, equipamiento.
- [ ] 30/60/120 fps y diferentes resoluciones; clics correctos tras resize, textos sin recorte.
- [ ] Todos los PNG/SFX se cargan o tienen fallback; no bloquear arranque por audio ausente.
- [ ] Efectos suaves y opción Reducir estímulos; señales de peligro distinguibles sin sonido.
- [ ] Test de usuario nuevo: completar tutorial y primera ronda sin instrucciones externas.
- [ ] Revisión real de UI y partidas largas: la CI de Lua no certifica belleza ni balance.

**Comandos base actuales (confirmar luego de refactor):**
\`\`\`bash
lua tests/runfile.lua
lua tests/smoke.lua
lua tests/menu_flow.lua
lua tests/experience.lua
lua tests/polish.lua
lua tests/progression.lua
python3 tests/check_sprites.py
python3 tools/package_love.py
love .
\`\`\`

## 12. Preparación comercial y límites

Antes de publicar fuera de GitHub:
- Confirmar licencia del **código**, de cada sprite, fuente, SFX y música; añadir \`LICENSE\` y \`CREDITS.md\` explícitos con el consentimiento del creador.
- No incorporar obras ajenas sin autorización. Los enlaces de inspiración son referencias de UX, no fuentes de arte para copiar.
- La versión v8 sigue siendo **LÖVE de escritorio con estética móvil**. Adaptación Android (gestos, controles táctiles, pausa por ciclo de vida y paquete APK/AAB) requiere otra fase.
- Evitar sistemas de recompensas que presionen a jugar compulsivamente; priorizar satisfacción por habilidad, claridad y creatividad.

## 13. Qué debe entregar el siguiente chat en cada hito

1. Enlace a la **PR real** y resumen preciso de archivos modificados.
2. Lista explícita de **funciones integradas y probadas**, pendientes y limitaciones.
3. Capturas del juego **realmente ejecutado** o marcadas con claridad como maquetas.
4. \`.love\` jugable y zip de código solo si los archivos existen y funcionan como paquete.
5. Informe de pruebas automatizadas (SHA de commit/ejecución) **sin inventar aprobaciones**.
6. Si se añaden audios: lista de nombres, licencias, fuentes y confirmación de uso/redistribución.
7. No fusionar ramas con CI roja ni declarar publicación final sin revisar las pruebas manuales.

## 14. Instrucción lista para pegar en el siguiente chat

> Trabaja directamente en https://github.com/CueloRubik/Balller. Primero abre y lee **docs/PLAN-MAESTRO-BALLLER-V8.md** en la rama \`main\`. Ese documento define el alcance y el orden de implementación. Verifica el estado actual del repo y ejecuta las pruebas base. Crea una rama de desarrollo para v8 y avanza por fases con commits y pruebas. Prioriza que el cambio visual sea drástico con PNG reales, interfaz de videojuego móvil y mecánicas completas conectadas. Mantén las partidas anteriores, sprites que ya funcionan y velocidad constante de pelota. No te detengas en planes: implementa la primera fase comprobable y entrega una PR con resultados reales. No afirmes haber generado audio o probado LÖVE si no lo hiciste.

## 15. Investigación de referencia (consultada el 14-11-2026)

- Material Design, patrones de navegación: https://developer.android.com/design/ui/mobile/guides/layout-and-content/layout-and-nav-patterns
- Android, contenido inmersivo: https://developer.android.com/design/ui/mobile/guides/layout-and-content/immersive-content
- Material Components, navegación inferior: https://github.com/material-components/material-components-android/blob/master/docs/components/BottomNavigation.md
- Crossy Road, descripción de colección y misiones: https://play.google.com/store/apps/details?id=com.yodo1.crossyroad
- Bloons TD 6, misiones, cosméticos, capítulos, progresión: https://play.google.com/store/apps/details?id=com.ninjakiwi.bloonstd6
- Google Play, guía de power-ups y misiones de Subway Surfers: https://play.google.com/store/apps/editorial?id=mc_games_editorialevergreen_subway_surfers_starter_tips_postinstall_fcp
- Kenney, licencias de assets CC0: https://kenney.nl/support
- Kenney Impact Sounds (CC0): https://kenney.nl/assets/impact-sounds
- Freesound, licencias por recurso: https://freesound.org/help/faq/

---

**Nota final:** Este es el **plan de implementación**, no un anuncio de que Balller v8 ya exista. La prioridad es construir un videojuego agradable, claro y completo; no acumular sistemas decorativos que no funcionen.
