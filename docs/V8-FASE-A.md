# Balller v8 — Fase A: referencia y regresión

Fecha: 14-11-2026. Rama: `feature/v8-rework`.

Primera entrega de v8: se conserva v7 y se construye su protección de regresión. No implementa todavía el rediseño, los capítulos ni las tiendas nuevas.

## Referencia congelada

- Base examinada: `9df16188acba59641626cd0c8bd1de29acacb47d`, main al comenzar.
- Código jugable v7: `43f2ada6f2c2e7ac131f89945e67125990269aea`.
- La comparación entre ambos commits contiene únicamente `docs/PLAN-MAESTRO-BALLLER-V8.md`.
- Desarrollo aislado; main y el formato `BALLLER_RUN_2` / `BALLLER_PROFILE_1` siguen intactos. No se creó etiqueta ni release.

## Mapa de dependencias

| Área | Dependencias y responsabilidades actuales |
|---|---|
| main.lua | UI, Art, Game, Save, Audio, Objects, Progression y V7Screens; navegación, coordenadas lógicas y entrada |
| v7screens.lua | UI/Icons/Art/Sprites y Game/Save/Progression/Difficulty/Objects/Hazards/Collectibles/Particles/Feedback; presentación y botones |
| game.lua | Player/Ball/Hazards/Objects; Save, Progression, Difficulty, Rounds, Collectibles; coordina reglas y transiciones |
| Física | Ball → Util/Arena; Player → Util/Arena; Objects → Util/Arena y carga diferida de Hazards para el portal; Hazards → Util/Arena |
| Persistencia de ranuras | Game.snapshot → Save → Runfile; archivos partida_1.txt a partida_3.txt y sus .bak |
| Perfil | Progression → love.filesystem; perfil_balller_v7.txt y .bak; gemas, récords, cuatro pelotas y logros |
| Presentación | Art → Theme/UI/Arena/Sprites/Objects/Progression; UI → Theme/Util/Icons; Sprites carga PNG o fábricas Lua |
| Efectos | Game → Audio/Particles/Feedback; Feedback → Theme/UI; Audio genera tonos mediante love.sound/audio |

No hay dependencias de paquetes Lua externos. El motor proporciona gráficos, audio, teclado y filesystem. Las pruebas headless sustituyen esas APIs y no equivalen al motor real. Las herramientas PNG usan Python/Pillow; empaquetado y comprobación usan biblioteca estándar.

Inventario completo y estado de derechos: [V8-ASSETS-BASELINE.md](V8-ASSETS-BASELINE.md). La falta de licencias explícitas queda registrada; esta fase no asigna una licencia sin el creador.

## Baseline local previo a cambios

Lua 5.4.8 compilado del tag oficial v5.4.8 para este entorno, Python 3. Todos los siguientes pasan sobre la base, antes de modificar pruebas o CI:

- runfile, smoke con PNG y fallback, verify_directions, polish, progression, experience y menu_flow.
- Compilación sintáctica de todos los Lua mediante loadfile (misma fase de parseo; CI usa además luac -p).
- check_sprites: 21 hojas y 184 cuadros.
- package_love: ZIP comprobado, 817480 bytes. Es v7 de referencia, no una publicación de v8.

LÖVE/Xvfb no están instalados localmente; no se hizo prueba visual local. El workflow conserva el smoke nativo con LÖVE/Xvfb en Ubuntu y el empaquetado. El resultado remoto debe comprobarse en la PR; no se deduce del resultado headless.

## Regresiones añadidas

| Prueba | Comportamiento protegido |
|---|---|
| tests/v8_compatibility.lua | Fixtures v4–v7 reales de codificadores históricos; tres ranuras; dificultad histórica; no reescribir al leer; respaldo del original al guardar; corrupción; borrado y recreación; recarga de módulos; fallo de escritura de respaldo; perfil v7 |
| tests/v8_economy.lua | Ocho defensas: precio, compra sin fondos, límite por objeto y mochila, rechazo fuera de tienda, colocación válida/inválida, gasto y persistencia; recompensa de ronda una vez por transición; logros una vez al cruzar umbral; cuatro aspectos, compra y equipamiento; pérdida sin borrar perfil |
| tests/v8_physics.lua | 132 combinaciones de 11 interacciones × 4 dificultades × 3 frecuencias: pared, jugador, escudo, impulso, imán, ventilador, reloj, remolino, pulso, portal y vector cero; rapidez tras update, pausa y carga; curva/cota de velocidad hasta ronda 999 |

Ejecutar desde la raíz, cada archivo en un proceso independiente:

```bash
lua tests/v8_compatibility.lua
lua tests/v8_economy.lua
lua tests/v8_physics.lua
```

Se añaden al workflow sin quitar pruebas anteriores. Fixtures y límites de la simulación: [tests/fixtures/README.md](../tests/fixtures/README.md).

## Límites conocidos y siguiente parte

- Cargar un archivo válido no escribe. Recuperar uno corrupto sí copia el respaldo al archivo principal: conducta histórica cubierta.
- Save escribe directamente el archivo final; no hay reemplazo atómico. El respaldo protege la última versión válida, pero no certifica cortes de energía ni fallos del disco real.
- Monedas y perfil son dos archivos: esta fase no garantiza transacciones atómicas entre ambos ni impide manipulación manual de archivos antiguos. No se anuncia una migración nueva.
- Repetir awardRound no entrega gemas del mismo hito; sí incrementa estadísticas de rondas. La prevención de restauraciones deliberadas y recompensas nuevas debe abordarse en las fases D/F.
- La rapidez se normaliza al final del update de Game. Los módulos de fuerzas pueden alterar temporalmente la magnitud dentro del paso. La prueba verifica la frontera del paso, no promete trayectorias idénticas entre fps ni ausencia de tunneling.
- Sin verificación manual en Catalina/Windows, balance de partidas largas ni aprobación visual. El smoke nativo de CI solo certifica arranque, dibujo y una secuencia breve.
- Código de juego, sprites, formatos, nombres de dificultad y controles sin cambios en esta entrega.

La siguiente entrega es la fase B: guía gráfica y maquetas, después recursos PNG y 9-slice. Debe incluir revisión visual real en distintas resoluciones y mantenerse separada de los cambios de economía. No se marcan B–H como terminadas.
