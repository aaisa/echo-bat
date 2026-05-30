# Arquitectura — Echo Bat

## Visión general

Echo Bat se estructura en subsistemas con responsabilidades bien delimitadas. La comunicación entre subsistemas desacoplados pasa por señales de `EventBus`; la comunicación padre-hijo usa señales directas del árbol de nodos.

```
┌──────────────────────────────────────────────────────────┐
│                      Game.tscn                           │
│                                                          │
│  ┌────────────┐  ┌──────────────┐  ┌─────────────────┐  │
│  │   Player   │  │ SpawnManager │  │   HUD / UI      │  │
│  │  (Bat)     │  │ (nivel proc) │  │   (pendiente)   │  │
│  └────────────┘  └──────────────┘  └─────────────────┘  │
│        │                │                  │             │
│        └────────────── EventBus ───────────┘             │
│                                                          │
│  Autoloads: GameManager · AudioManager (pendiente)       │
│             EconomyManager (pendiente) · EventBus (pend) │
└──────────────────────────────────────────────────────────┘
                           │
          ┌────────────────┼────────────────┐
          │                │                │
    Firebase SDK       AdMob SDK      Play Billing
  (Auth, Firestore,  (anuncios)       (IAP)
   Analytics, etc.)
```

## Subsistemas

### 1. Player (Bat)

**Escena**: `scenes/Player.tscn` *(implementado)*  
**Script**: `scripts/player/Player.gd` *(implementado)*

Responsabilidades:
- Movimiento horizontal automático a `GameManager.get_speed()` px/s (base 400, cap 550).
- Gravedad (`GRAVITY = 1800` px/s²) y salto (`JUMP_VELOCITY = -600` px/s).
- Input: `Space` / toque 60% derecho → salto; `Enter` / toque 40% izquierdo → onda.
- Onda de sonido: instancia `SoundWave.tscn`, cooldown 1 s, señal `wave_emitted`.
- Muerte (`die()`): contacto con grupo `"obstacle"`, `is_on_floor()` (suelo), o `is_on_ceiling()` (techo).
- Tracking de distancia en metros (`distance_meters`); llama `GameManager.update_distance()` cada frame.
- Sprite placeholder: rectángulo CYAN hasta recibir el arte definitivo.

Señales emitidas: `player_died(distance)`, `wave_emitted`.

### 2. Generación procedural (SpawnManager)

**Script**: `scripts/level/SpawnManager.gd` *(implementado)*  
*(Creado dinámicamente por `Game.gd`, no tiene escena propia)*

Responsabilidades:
- Spawn de pares de estalactitas (arriba + abajo) siempre delante de la cámara.
- Posición vertical del gap aleatoria entre límites seguros (margen 50 px de techo/suelo).
- Lee parámetros de bioma de `GameManager.get_biome_params()` cada frame → transición de bioma automática.
- Despawn de pares al quedar fuera del borde izquierdo de la cámara.

Biomas en orden de ciclo (gap px / spacing px):  
**La Entrada** (210/400) → **La Penumbra** (190/380) → **La Catarata** (170/360) → **Las Agujas** (150/340) → **El Núcleo** (130/320) → (repite).

### 2b. GameManager (autoload) *(implementado)*

**Script**: `scripts/core/GameManager.gd`

Responsabilidades:
- Estado global: `PLAYING` / `GAME_OVER`.
- Tracking de bioma actual y ciclo por distancia (1000 m por bioma, 5 biomas por ciclo).
- Velocidad dinámica: `BASE_SPEED * 1.1^(cycle-1)`, cap 550 px/s.
- Récord persistido en `user://record.dat`.
- Modo debug: overlay (CanvasLayer) con bioma/distancia/velocidad que persiste entre escenas. `R` lo muestra/oculta en cualquier escena.
- **`DEBUG_MODE = true`** → cambiar a `false` antes de publicar.

### 3. Obstáculos

**Escenas**: `scenes/game/obstacles/` (una por tipo)  
**Script base**: `scripts/level/Obstacle.gd`

Responsabilidades:
- Cada obstáculo tiene hitbox, visibilidad controlada (visible / oculto en zona oscura) y comportamiento propio.
- El sistema de oscuridad oculta los obstáculos fuera del radio de la onda de sonido.
- Algunos obstáculos tienen movimiento propio (estalactitas que caen, piedras giratorias).

### 4. Onda de sonido (SoundWave)

**Escena**: `scenes/game/SoundWave.tscn`  
**Script**: `scripts/player/SoundWave.gd`

Responsabilidades:
- Expansión radial animada desde la posición del murciélago.
- Detección de obstáculos en el radio → activa su visibilidad temporalmente.
- La onda es stateless; el cooldown lo gestiona `Player.gd`.

### 5. Economía (EconomyManager)

**Autoload**: `scripts/core/EconomyManager.gd`

Responsabilidades:
- Balance de Cristales de Eco: lectura, escritura, validación de fondos.
- Sincronización con Firestore (guardado diferido, no en tiempo real para evitar latencia percibida).
- Registro de compras IAP y asignación de productos al inventario.
- Entrega de recompensas de anuncios recompensados.

### 6. UI

**Escenas**: `scenes/ui/`

| Escena | Propósito |
|---|---|
| `HUD.tscn` | Puntuación en tiempo real, contador de cristales, indicador de cooldown de onda |
| `MainMenu.tscn` | Pantalla de inicio, botón de play, acceso a tienda y selector de habilidades |
| `GameOver.tscn` | Puntuación final, récord, botón de reinicio, disparo de anuncio intersticial |
| `Shop.tscn` | Tienda de skins permanentes, skins de temporada y packs de Cristales de Eco |
| `SkillSelector.tscn` | Selección de las 2 habilidades de vuelo activas antes de iniciar partida |

### 7. Servicios backend

**Carpeta**: `scripts/services/`

| Servicio | Responsabilidad |
|---|---|
| `FirebaseService.gd` | Inicialización del SDK, autenticación anónima, vinculación Play Games |
| `FirestoreService.gd` | CRUD de perfil de jugador y progresión |
| `RemoteConfigService.gd` | Carga y exposición de parámetros de Remote Config con fallbacks locales |
| `AnalyticsService.gd` | Registro de eventos de Analytics (sesión, muerte, compra, bioma) |
| `CrashlyticsService.gd` | Reporte de errores críticos en producción |

### 8. Monetización

**Carpeta**: `scripts/monetization/`

| Script | Responsabilidad |
|---|---|
| `AdMobService.gd` | Precarga y presentación de anuncios intersticiales y recompensados |
| `IAPService.gd` | Flujo de compra con Google Play Billing; verificación y entrega de productos |

## Habilidades de vuelo

El jugador equipa hasta **2 habilidades** de un catálogo de 10, elegidas en `SkillSelector.tscn` antes de cada partida. Las habilidades modifican el comportamiento de `Player.gd` en tiempo de ejecución mediante el patrón Strategy: cada habilidad es un recurso (`Resource`) con métodos `on_activate()` y `on_tick()`.

Ejemplos del catálogo: doble salto, onda de sonido ampliada, escudo de un golpe, velocidad reducida temporal, atracción magnética de cristales.

## Cámara (Game.gd) *(implementado)*

`Game.gd` gestiona la `Camera2D` de `Game.tscn` directamente (no usa el follow built-in de Godot):

- **Horizontal**: `camera.x = player.x + 300` px (adelanto fijo, sin suavizado).
- **Vertical — zona muerta**: el 32% central de la pantalla (±115 px con viewport 720 h). La cámara no se mueve mientras el jugador esté dentro de esa franja.
- **Vertical — seguimiento**: al salir de la zona muerta, la cámara se desplaza a **250 px/s** con `move_toward` (sin overshoot).
- **Clamp**: `camera.y >= 0` — nunca muestra contenido por encima del techo del nivel.

## Flujo de una partida

```
MainMenu (pendiente)
  → [Play] → GameManager.start_game() (pendiente)
    → BiomeGenerator inicia generación de secciones
    → Player se activa y empieza a avanzar
    → HUD se actualiza por señales de EventBus
    → [colisión fatal] → player_died
      → GameManager.end_game()
        → Firestore guarda puntuación y cristales
        → AdMobService.show_interstitial()
        → GameOver.tscn muestra resultados
          → [reintentar] → GameManager.start_game()
          → [menú] → MainMenu
```

## Gestión de estado global

`GameManager` (autoload) mantiene el estado de la partida:

```gdscript
enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }
```

Los subsistemas reaccionan a cambios de estado vía señales de `EventBus`, no consultando `GameManager.state` directamente. Esto mantiene los subsistemas desacoplados del autoload.
