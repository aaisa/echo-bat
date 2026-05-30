# Arquitectura — Echo Bat

## Visión general

Echo Bat se estructura en subsistemas con responsabilidades bien delimitadas. La comunicación entre subsistemas desacoplados pasa por señales de `EventBus`; la comunicación padre-hijo usa señales directas del árbol de nodos.

```
┌──────────────────────────────────────────────────────────┐
│                      Game.tscn                           │
│                                                          │
│  ┌────────────┐  ┌──────────────┐  ┌─────────────────┐  │
│  │   Player   │  │ BiomeGen     │  │   HUD / UI      │  │
│  │  (Bat)     │  │ (nivel proc) │  │                 │  │
│  └────────────┘  └──────────────┘  └─────────────────┘  │
│        │                │                  │             │
│        └────────────── EventBus ───────────┘             │
│                                                          │
│  Autoloads: GameManager · AudioManager                   │
│             EconomyManager · EventBus                    │
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
- Movimiento automático horizontal (`SPEED = 400` px/s).
- Gravedad (`GRAVITY = 1800` px/s²) y salto (`JUMP_VELOCITY = -600` px/s).
- Salto activado por `Space` (action `jump`) o toque en el 60% derecho de pantalla.
- Bucle de prueba: al superar `LOOP_WIDTH = 1600` px reaparece por la izquierda (se elimina cuando haya generación de nivel real).
- Sprite placeholder: rectángulo CYAN generado por código en `_ready()` hasta tener el arte.
- *(Pendiente)* Emisión de onda de sonido, colisiones con obstáculos/cristales, habilidades de vuelo.

Señales previstas: `player_died`, `crystal_collected(amount)`, `wave_emitted`.

### 2. Generación de biomas (BiomeGenerator)

**Escena**: `scenes/game/BiomeGenerator.tscn`  
**Script**: `scripts/level/BiomeGenerator.gd`

Responsabilidades:
- Generación procedural de secciones de bioma al vuelo (pooling de nodos para evitar instanciación en caliente).
- Encadenamiento infinito de los 5 biomas en bucle con dificultad creciente por ciclo.
- Spawn de obstáculos según el perfil de dificultad del bioma activo.
- Despawn y reciclado de secciones que salen del viewport.

Biomas en orden de ciclo: **Cueva → Bosque → Ruinas → Tormenta → Vacío** → (repite).

Los parámetros de dificultad por ciclo se cargan desde Remote Config vía `RemoteConfigService.gd`.

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
