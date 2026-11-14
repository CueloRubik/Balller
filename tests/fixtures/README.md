# Fixtures históricos inmutables

Estas muestras fueron producidas ejecutando los codificadores de los commits indicados, mediante Lua 5.4.8. No se generaron con el lector actual ni se deben regenerar automáticamente durante las pruebas. Son datos sintéticos, sin información personal.

| Archivo | Commit de origen | Productor |
|---|---|---|
| `run-v4.txt` | `61061a0436a2060adf50e072e04770b1eff1307f` | `src/runfile.lua`, encode |
| `run-v5.txt` | `f7a864e650e4d2c41944cffc724498a58738d55f` | `src/runfile.lua`, encode |
| `run-v6.txt` | `54cc03794ab52e40a37746e4d30135b6b0f3d174` | `src/runfile.lua`, encode |
| `run-v7.txt` | `43f2ada6f2c2e7ac131f89945e67125990269aea` | `src/runfile.lua`, encode |
| `profile-v7.txt` | `43f2ada6f2c2e7ac131f89945e67125990269aea` | `src/progression.lua`, save |

La partida de entrada tiene ronda 6, score 1560, 133 monedas, jugador (280,330), pelota (630,313), inventario {1,3,0,2,0,1}, una sierra y un escudo. v5 agrega botas 2, rebotes 4, colocaciones 1 y recarga 3. v6/v7 agregan dificultad 4, rescate 1, invulnerabilidad .75, protección 4, recarga de portal .5 e inventario de burbuja 1/portal 2. Los codificadores anteriores omiten campos aún inexistentes. v6 y v7 comparten formato y pueden producir bytes iguales: no son dos esquemas distintos.

El perfil tiene 24 gemas; estadísticas estrellas 19, golpes 49, rondas 9 y partidas 4; récords {3,6,9,12}; aspectos poseídos {Original, Océano, Galaxia}; equipado Galaxia. Estas cantidades permiten cruzar los cuatro umbrales de logros una vez en la prueba de economía.

`tests/v8_compatibility.lua` comprueba lectura sin escritura, adaptación en memoria, actualización con respaldo byte a byte del original, restauración, aislamiento y borrado/recreación en las tres ranuras. El reinicio de módulos simula recarga del proceso con almacenamiento en memoria; no certifica tolerancia a un corte físico durante una escritura.
