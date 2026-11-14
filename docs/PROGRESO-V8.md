# Progreso de Balller v8

Actualizado: entrega D1, 14-11-2026. Estado de implementación en las ramas de desarrollo; las PR se conservan separadas y no implica que estén fusionadas en main ni que exista una publicación final.

**Avance por fases: A, B y C implementadas en desarrollo.** Son 3 de 8 fases con implementación principal terminada. No se convierte este conteo en porcentaje de esfuerzo: capítulos, contenido y audio tienen un alcance mucho mayor que la auditoría inicial.

| Fase | Estado | Hecho / pendiente principal |
|---|---|---|
| A — Referencia y regresión | Implementada | Baseline v7, inventario, dependencias, fixtures v4–v7, ranuras, economía y velocidad en CI. Licencias globales pendientes de decisión para publicación. |
| B — Lenguaje visual | Implementada en desarrollo | PNG/atlas, 32 iconos, fuente con OFL, pantallas principales, tres canchas, barras y HUD despejado; capturas nativas a cinco tamaños. Revisión manual de plataformas pendiente. |
| C — Navegación y uso | Implementada en desarrollo | Cinco destinos, Nueva/Continuar, ranuras y recuperación, pausa/guardar-salir con errores, ocho ayudas y tutorial completo sin premios. Revisión de una persona nueva pendiente. |
| D — Economía y tiendas | Parcial | D1: precios/límites/recompensas en configuración; compras del Taller con registro de recuperación por ranura. D2: premios persistentes, coordinación perfil/partida y desglose de recompensas pendientes. |
| E — Juego y capítulos | Pendiente | Física anterior protegida. Faltan Aprendiz con migración, tres capítulos con objetivos/jefes, cuatro defensas y cinco peligros nuevos. Los aspectos de cancha no son capítulos. |
| F — Progresión | Parcial de base | Logros, hitos y cuatro pelotas anteriores integrados en pantallas nuevas. Faltan cosméticos nuevos, misiones diarias/semanales opcionales, estadísticas ampliadas y medallas. |
| G — Audio y respuesta | Pendiente | Se conserva audio sintetizado v7 y hay modo visual reducido. Faltan assets seleccionados/licenciados, música, buses/volúmenes y feedback ampliado. |
| H — Calidad y publicación | Pendiente | CI, pruebas nativas y paquetes de desarrollo disponibles. Faltan balance/partidas largas, pruebas reales Catalina/Windows, créditos/licencia final y candidato autorizado. |

## Entregas

- Fase A: PR #8, `feature/v8-rework`.
- B1: PR #9, `feature/v8-visual-foundation`.
- B2: PR #10, `feature/v8-screens-b2`.
- B3: PR #11, `feature/v8-courts-hud-b3`.
- C1: PR #12, `feature/v8-run-flow-c1`.
- C2: PR #13, `feature/v8-session-help-c2`.
- D1: `feature/v8-economy-d1`; consultar PR de esa rama y su ejecución.

Cada parte incluye su informe en docs/V8-FASE-*.md. El siguiente informe debe actualizar este archivo con funciones reales y resultados comprobados.

## Próxima parte

D2: proteger premios al cerrar/reabrir, coordinar el progreso compartido con las ranuras y ampliar el desglose de recompensas. Las compras del Taller ya tienen recuperación en D1; la fase D completa sigue en curso. Después siguen E (capítulos y mecánicas nuevas), F (progresión ampliada), G (audio) y H (balance, plataformas y publicación).
