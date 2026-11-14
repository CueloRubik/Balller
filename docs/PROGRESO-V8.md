# Progreso de Balller v8

Actualizado: entrega C1, 14-11-2026. Estado de implementación en las ramas de desarrollo; las PR se conservan separadas y no implica que estén fusionadas en main ni que exista una publicación final.

**Avance por fases: A y B implementadas; C en curso.** Son 2 de 8 fases con implementación principal terminada. No se convierte este conteo en porcentaje de esfuerzo: capítulos, contenido y audio tienen un alcance mucho mayor que la auditoría inicial.

| Fase | Estado | Hecho / pendiente principal |
|---|---|---|
| A — Referencia y regresión | Implementada | Baseline v7, inventario, dependencias, fixtures v4–v7, ranuras, economía y velocidad en CI. Licencias globales pendientes de decisión para publicación. |
| B — Lenguaje visual | Implementada en desarrollo | PNG/atlas, 32 iconos, fuente con OFL, pantallas principales, tres canchas, barras y HUD despejado; capturas nativas a cinco tamaños. Revisión manual de plataformas pendiente. |
| C — Navegación y uso | En curso: C1 | Cinco destinos, separación Nueva/Continuar, ranuras y recuperación visible. Siguiente: pausa/guardar y salir con fallos visibles, ayudas de objetos y tutorial completo. |
| D — Economía y tiendas | Parcial | Tienda de gemas/Taller separados, compras/equipamiento y circuito anterior probados. Faltan configuración ampliada, resumen completo de recompensas y mayor protección de transacciones. |
| E — Juego y capítulos | Pendiente | Física anterior protegida. Faltan Aprendiz con migración, tres capítulos con objetivos/jefes, cuatro defensas y cinco peligros nuevos. Los aspectos de cancha no son capítulos. |
| F — Progresión | Parcial de base | Logros, hitos y cuatro pelotas anteriores integrados en pantallas nuevas. Faltan cosméticos nuevos, misiones diarias/semanales opcionales, estadísticas ampliadas y medallas. |
| G — Audio y respuesta | Pendiente | Se conserva audio sintetizado v7 y hay modo visual reducido. Faltan assets seleccionados/licenciados, música, buses/volúmenes y feedback ampliado. |
| H — Calidad y publicación | Pendiente | CI, pruebas nativas y paquetes de desarrollo disponibles. Faltan balance/partidas largas, pruebas reales Catalina/Windows, créditos/licencia final y candidato autorizado. |

## Entregas

- Fase A: PR #8, `feature/v8-rework`.
- B1: PR #9, `feature/v8-visual-foundation`.
- B2: PR #10, `feature/v8-screens-b2`.
- B3: PR #11, `feature/v8-courts-hud-b3`.
- C1: `feature/v8-run-flow-c1`; consultar PR de esa rama y su ejecución.

Cada parte incluye su informe en docs/V8-FASE-*.md. El siguiente informe debe actualizar este archivo con funciones reales y resultados comprobados.
