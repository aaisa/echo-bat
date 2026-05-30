# Assets pendientes — Echo Bat

Lista de todos los assets que necesita el juego con nombre exacto de archivo,
dimensiones y uso. Cuando un archivo esté listo, colocarlo en la ruta indicada
e importarlo en Godot. El código ya referencia estos nombres.

**Prioridades:** 🔴 Fase 1 (Bioma 1) · 🟡 Fase 5 (Skins/Tienda) · 🔵 Fase 6 (Biomas 2–5)

---

## Sprites del jugador — `assets/sprites/player/`

| Archivo | Dimensiones | Fotogramas | Uso | Prioridad |
|---|---|---|---|---|
| `bat_fly.png` | 369×400 px por frame | 11 (horizontal) | Animación de vuelo (loop) — skin por defecto "Nyan Bat" | 🔴 |
| `bat_die.png` | 369×400 px por frame | 10 (horizontal) | Animación de muerte | 🔴 |
| `bat_wave_trail.png` | 64×64 px | 1 | Partícula de estela al emitir onda (opcional Fase 1) | 🔴 |

**Notas de integración:**
- Sustituir `_setup_placeholder()` en `Player.gd` por `AnimatedSprite2D` con estos spritesheets.
- Referencia original (prototipo 2017): `Nyan Bat` con estela arcoíris; replicar estilo.
- Herramienta recomendada: Adobe Firefly para generación + Aseprite para animación.

### Skins gratuitas (mismas dimensiones que bat_fly/die)

| Archivo | Condición de desbloqueo | Prioridad |
|---|---|---|
| `skin_golden_fly.png` + `skin_golden_die.png` | Récord > 1.000 m | 🟡 |
| `skin_ice_fly.png` + `skin_ice_die.png` | Completar La Catarata por primera vez | 🟡 |
| `skin_dark_fly.png` + `skin_dark_die.png` | Sobrevivir 60 s en El Núcleo | 🟡 |
| `skin_rainbow_fly.png` + `skin_rainbow_die.png` | 7 días consecutivos de juego | 🟡 |
| `skin_lava_fly.png` + `skin_lava_die.png` | Alcanzar Ciclo 3 | 🟡 |

### Skins de pago permanentes (0,99–1,49 €)

| Archivo | Descripción |
|---|---|
| `skin_ninja_fly.png` + `skin_ninja_die.png` | Negro, banda roja, estela de shurikens |
| `skin_pirate_fly.png` + `skin_pirate_die.png` | Parche, pañuelo, estela de monedas |
| `skin_ghost_fly.png` + `skin_ghost_die.png` | Translúcido, estela de niebla azulada |
| `skin_astronaut_fly.png` + `skin_astronaut_die.png` | Traje espacial, estela de estrellas |
| `skin_robot_fly.png` + `skin_robot_die.png` | Metálico plateado, estela de circuitos |
| `skin_samurai_fly.png` + `skin_samurai_die.png` | Armadura japonesa, estela de pétalos |
| `skin_viking_fly.png` + `skin_viking_die.png` | Casco con cuernos, estela de rayos |

---

## Obstáculos — `assets/sprites/obstacles/`

| Archivo | Dimensiones | Uso | Bioma | Prioridad |
|---|---|---|---|---|
| `stalactite_top.png` | 60×variable px | Estalactita colgante (desde techo) | 1 La Entrada | 🔴 |
| `stalactite_bottom.png` | 60×variable px | Estalactita ascendente (desde suelo) | 1 La Entrada | 🔴 |
| `stalactite_mossy_top.png` | 60×variable px | Con musgo, semitransparente en zonas oscuras | 2 La Penumbra | 🔵 |
| `stalactite_mossy_bottom.png` | 60×variable px | Con musgo | 2 La Penumbra | 🔵 |
| `water_curtain.png` | 60×variable px | Cortina de agua (obstáculo móvil) | 3 La Catarata | 🔵 |
| `spike_top.png` | 60×variable px | Pincho de obsidiana (extensible) | 4 Las Agujas | 🔵 |
| `spike_bottom.png` | 60×variable px | Pincho extensible | 4 Las Agujas | 🔵 |
| `crystal_black.png` | 60×variable px | Cristal negro (oscuridad total) | 5 El Núcleo | 🔵 |

**Notas de integración:**
- El código actual (`SpawnManager.gd`) usa `Polygon2D` marrón como placeholder.
- Sustituir por `Sprite2D` con estas texturas en `SpawnManager._add_stalactite()`.
- Los obstáculos de biomas 2–5 necesitan shader de oscuridad (Fase 6).

---

## Fondos parallax — `assets/sprites/backgrounds/`

Cada bioma usa **7 capas** de parallax (velocidades distintas: capa 1 más lenta, capa 7 más rápida). Las imágenes deben ser más anchas que la pantalla para el scroll horizontal.

### Bioma 1 — La Entrada (ocres cálidos, luz plena) 🔴

| Archivo | Dimensiones | Velocidad parallax | Contenido |
|---|---|---|---|
| `bg_entrada_layer1.png` | 2.560×720 px | 0,05 | Fondo lejano oscuro (roca) |
| `bg_entrada_layer2.png` | 2.560×720 px | 0,10 | Roca media con detalles |
| `bg_entrada_layer3.png` | 2.560×720 px | 0,20 | Paredes de cueva |
| `bg_entrada_layer4.png` | 2.560×720 px | 0,35 | Detalle de rocas medianas |
| `bg_entrada_layer5.png` | 2.560×720 px | 0,50 | Primer plano de piedras |
| `bg_entrada_layer6.png` | 2.560×720 px | 0,70 | Elementos cercanos |
| `bg_entrada_layer7.png` | 2.560×720 px | 1,00 | Techo y suelo de la cueva |

*Referencia: prototipo original usa un panorámico de 11.000×2.500 px en 7 capas. Adaptar a resolución 1280×720.*

### Biomas 2–5 (Fase 6) 🔵

Misma estructura (7 layers), nombres:
- `bg_penumbra_layer1.png` … `bg_penumbra_layer7.png` — gris azulado, neblina
- `bg_catarata_layer1.png` … `bg_catarata_layer7.png` — azul profundo, destellos de agua
- `bg_agujas_layer1.png` … `bg_agujas_layer7.png` — negro/rojo volcánico, puntos de lava
- `bg_nucleo_layer1.png` … `bg_nucleo_layer7.png` — negro absoluto (shader de onda)

---

## Onda de sonido — `assets/sprites/effects/`

| Archivo | Dimensiones | Fotogramas | Uso |
|---|---|---|---|
| `wave_ring.png` | 128×128 px | 8 (horizontal) | Animación de expansión radial de la onda | 🔴 |

**Notas:** Reemplazar el círculo placeholder en `SoundWave.gd._setup_placeholder()`.

---

## Música — `assets/audio/music/`

Formato: **OGG Vorbis, loop seamless** (el punto de loop debe estar marcado con metadata de Godot).

| Archivo | Bioma | Duración aprox. | Herramienta sugerida | Prioridad |
|---|---|---|---|---|
| `music_entrada.ogg` | 1 — La Entrada | 2–3 min | `ingame.wav` del prototipo comprimida a OGG, o Suno AI | 🔴 |
| `music_penumbra.ogg` | 2 — La Penumbra | 2–3 min | Suno AI (tono más oscuro y misterioso) | 🔵 |
| `music_catarata.ogg` | 3 — La Catarata | 2–3 min | Suno AI (agua, tensión) | 🔵 |
| `music_agujas.ogg` | 4 — Las Agujas | 2–3 min | Suno AI (ritmo industrial, lava) | 🔵 |
| `music_nucleo.ogg` | 5 — El Núcleo | 2–3 min | Suno AI (ambient oscuro, minimalista) | 🔵 |

**Notas de integración:**
- Usar `AudioStreamPlayer` con `stream_paused = false` y loop activado en las propiedades de importación de Godot.
- `AudioManager` (a implementar en Fase 1) gestiona la transición entre pistas al cambiar de bioma.

---

## SFX adicionales — `assets/audio/sfx/`

Los SFX del prototipo original ya están en `assets/audio/` (flap.wav, golpe.wav, scream.wav).
Los nuevos SFX van en esta subcarpeta.

| Archivo | Evento | Herramienta sugerida | Prioridad |
|---|---|---|---|
| `sfx_crystal_collect.ogg` | Recoger un Cristal de Eco | ElevenLabs SFX | 🟡 |
| `sfx_achievement.ogg` | Logro desbloqueado | ElevenLabs SFX | 🟡 |
| `sfx_cycle_complete.ogg` | Victoria de ciclo (5 biomas completados) | ElevenLabs SFX | 🟡 |
| `sfx_wave_echo.ogg` | Eco de la onda al rebotar en obstáculo | ElevenLabs SFX | 🔵 |
| `sfx_biome_transition.ogg` | Stinger al entrar en nuevo bioma | ElevenLabs SFX | 🔵 |
| `sfx_record_broken.ogg` | Fanfarria al superar récord | ElevenLabs SFX | 🟡 |
| `sfx_revive.ogg` | Activar revive (escudo o anuncio) | ElevenLabs SFX | 🟡 |

---

## Tipografía — `assets/fonts/`

| Archivo | Uso | Fuente |
|---|---|---|
| `CodersCrux.ttf` | HUD (distancia, puntuación, Game Over) | coderspace.net / itch.io |
| `MagicSchoolOne.ttf` | Menú principal, títulos de eventos | Google Fonts |
| `MagicSchoolTwo.ttf` | Variante de Magic School (opcional) | Google Fonts |

**Notas:** La carpeta `assets/fonts/` no fue creada en esta fase. Crear al añadir los archivos.

---

## UI — `assets/sprites/ui/`

*(Pendiente de diseño. Crear la carpeta al tener los primeros elementos.)*

| Archivo | Uso | Prioridad |
|---|---|---|
| `hud_crystal_icon.png` | Icono de Cristal de Eco en el HUD | 🟡 |
| `hud_wave_cooldown.png` | Indicador visual de cooldown de onda | 🔴 |
| `btn_play.png` | Botón Play del menú principal | 🔴 |
| `btn_retry.png` | Botón Reintentar en Game Over | 🔴 |
| `icon_biome_*.png` | Iconos de cada bioma (Game Over) | 🟡 |
