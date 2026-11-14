# Balller

**Balller** es un videojuego arcade cenital para [LÖVE 2D](https://love2d.org/) 11.4 o posterior. Controla a un personaje y protege una pelota de pinchos y alcantarillas mientras compras y colocas defensas. Cada partida tiene su propia puntuación y puede terminar en cualquier momento.

## Jugar

Desde la carpeta del proyecto ejecuta:

```bash
love .
```

En macOS puedes abrir el proyecto desde LÖVE Studio o arrastrar la carpeta a la aplicación LÖVE.

| Control | Acción |
|---|---|
| WASD / flechas | Moverse libremente por la cancha |
| Clic izquierdo | Colocar la defensa elegida |
| 1, 2, 3 | Elegir escudo, impulsor o tapa |
| P / Escape | Pausar o reanudar |
| Enter | Empezar o repetir partida |

## Arte y animaciones

Cada componente visual tiene **su propio PNG**, en `assets/sprites/`. Las texturas tienen cuadros de **128 × 128 píxeles**: 16 para el personaje (cuatro direcciones) y ocho para cada uno de los seis objetos. Son ilustraciones coloridas con contornos consistentes y animaciones por cuadros, no un único spritesheet compartido.

Si falta un PNG, el juego puede generar una textura de respaldo con el módulo de dibujo de esa entidad. La documentación completa se encuentra en [`docs/ARTE-Y-ANIMACIONES.md`](docs/ARTE-Y-ANIMACIONES.md).

## Mecánicas y efectos

- Pelota cenital con rebotes en las paredes y contra el personaje.
- Pinchos que emergen y alcantarillas que se abren tras una advertencia.
- Tres defensas colocables: escudo, impulsor y tapa.
- Puntuación, monedas, récord, partidas jugadas y sonido configurable.
- Rachas temporales de golpes con multiplicadores moderados de puntuación.
- Texto flotante y pequeñas celebraciones al conseguir hitos, sin interrumpir la partida.
- Guardado local y partidas que pueden reiniciarse rápidamente.

## Código

```text
Balller/
├── main.lua
├── conf.lua
├── assets/sprites/
│   ├── character.png
│   ├── ball.png
│   ├── spikes.png
│   ├── drain.png
│   ├── shield.png
│   ├── boost.png
│   └── lid.png
├── src/
│   ├── sprites.lua
│   ├── sprites/        Archivos individuales de dibujo de respaldo
│   ├── art.lua         Composición de escena y animación
│   ├── feedback.lua    Rachas, puntos flotantes y celebraciones
│   ├── game.lua        Bucle de juego
│   └── ...             Resto de física, audio, datos e interfaz
├── docs/
├── tests/
└── tools/
```

## Verificaciones

`lua tests/smoke.lua` realiza una prueba de arranque simulada. `python3 tests/check_sprites.py` comprueba las dimensiones de las hojas PNG. Las pruebas automatizadas no sustituyen una revisión visual en LÖVE real.
