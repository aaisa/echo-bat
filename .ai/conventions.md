# Convenciones — Echo Bat

## Naming en GDScript

| Elemento | Convención | Ejemplo |
|---|---|---|
| Variables y parámetros | `snake_case` | `jump_force`, `crystal_count` |
| Constantes | `UPPER_SNAKE_CASE` | `MAX_SPEED`, `WAVE_COOLDOWN` |
| Funciones | `snake_case` | `emit_sound_wave()`, `collect_crystal()` |
| Señales | `snake_case`, verbo en pasado | `crystal_collected`, `biome_changed`, `player_died` |
| Clases (`class_name`) | `PascalCase` | `SoundWave`, `BiomeGenerator` |
| Enums | `PascalCase`; valores `UPPER_SNAKE_CASE` | `enum BiomeType { CAVE, FOREST, RUINS }` |

## Naming de nodos, escenas y archivos

| Elemento | Convención | Ejemplo |
|---|---|---|
| Nodos en el árbol de escena | `PascalCase` | `PlayerBody`, `SoundWaveEmitter` |
| Archivos de escena | `PascalCase.tscn` | `Player.tscn`, `BiomeSection.tscn` |
| Archivos de script | `PascalCase.gd` | `Player.gd`, `BiomeGenerator.gd` |
| Scripts de servicio | `PascalCase + Service` | `FirebaseService.gd`, `EconomyService.gd` |

## Naming de assets

| Tipo | Convención | Ejemplo |
|---|---|---|
| Sprites | `snake_case` con sufijo de estado/frame | `bat_idle.png`, `bat_jump_01.png` |
| Audio SFX | prefijo `sfx_` | `sfx_jump.ogg`, `sfx_wave_emit.ogg` |
| Audio música | prefijo `mus_` | `mus_cave_loop.ogg`, `mus_menu.ogg` |
| Fuentes | nombre original de la fuente | `Roboto-Bold.ttf` |

## Estructura de carpetas

```
scenes/
  ui/           → HUD, menús, shop, game over
  game/         → Player, obstáculos, biomas, efectos in-game
    obstacles/  → una escena por tipo de obstáculo
scripts/
  core/         → GameManager, EventBus, InputMapper
  player/       → Player.gd, SoundWave.gd, habilidades
  level/        → BiomeGenerator.gd, BiomeSection.gd, Obstacle.gd
  services/     → Firebase, Firestore, RemoteConfig, Analytics
  monetization/ → AdMobService.gd, IAPService.gd
  ui/           → controladores de cada escena UI
assets/
  sprites/
  audio/
  fonts/
addons/         → plugins Godot (commiteados con el proyecto)
```

## Señales

- Se declaran en el nodo que las emite, nunca en el receptor.
- Se conectan desde el padre o desde `EventBus`. El emisor no se autoconecta.
- Señales globales (entre subsistemas desacoplados) van por `EventBus.gd`.
- Señales locales (padre-hijo) se conectan directamente en la escena padre.

## Autoloads (solo estos cuatro)

| Autoload | Responsabilidad |
|---|---|
| `GameManager` | Estado global: `MENU / PLAYING / PAUSED / GAME_OVER` |
| `AudioManager` | Reproducción de música y SFX |
| `EconomyManager` | Balance de Cristales de Eco, recompensas, compras |
| `EventBus` | Bus de señales globales desacopladas entre subsistemas |

Si una necesidad no cabe en estos cuatro, discutir antes de crear un quinto.

## Commits

Formato: `tipo: descripción corta en imperativo`

| Tipo | Cuándo |
|---|---|
| `feat` | Nueva funcionalidad jugable |
| `fix` | Corrección de bug |
| `refactor` | Cambio interno sin cambio de comportamiento |
| `assets` | Añadir o modificar assets (sprites, audio, fuentes) |
| `config` | Cambios en `project.godot`, plantillas de exportación, plugins |
| `docs` | Solo documentación (`.ai/`, comentarios de código) |
| `chore` | Mantenimiento (limpieza, `.gitignore`, dependencias) |

Ejemplos:
```
feat: añadir mecánica de onda de sonido con cooldown
fix: corregir colisión del murciélago en bioma cueva
assets: añadir sprite sheet de animación idle del murciélago
config: configurar plantilla de exportación Android
```

## Ramas

| Rama | Propósito |
|---|---|
| `main` | Código estable, siempre exportable |
| `dev` | Integración de features en desarrollo |
| `feat/<nombre>` | Feature individual |
| `fix/<nombre>` | Bugfix individual |
| `release/<versión>` | Preparación de release (bump de versión y changelog únicamente) |

No hacer push directo a `main`. Merge vía PR.

## Tests

Godot no tiene framework de tests integrado robusto. Estrategia del proyecto:

- **GUT (Godot Unit Test)** para lógica pura: `EconomyManager`, algoritmos de `BiomeGenerator`, cálculos de dificultad.
- Los tests viven en `tests/` (crear cuando se añada GUT como plugin).
- La lógica de UI y física no se testea unitariamente; se valida manualmente en dispositivo.
