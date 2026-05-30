# Arquitectura — Echo Bat

## Visión general

Echo Bat se estructura en subsistemas con responsabilidades bien delimitadas. La comunicación entre subsistemas desacoplados pasa por señales de `EventBus`; la comunicación padre-hijo usa señales directas del árbol de nodos.

```
┌──────────────────────────────────────────────────────────┐
│                      Main.tscn                           │
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

**Escena**: `scenes/game/Player.tscn`  
**Script**: `scripts/player/Player.gd`

Responsabilidades:
- Movimiento automático horizontal (velocidad constante con aceleración por ciclo).
- Salto vertical: impulso físico con gravedad; un salto en el aire máximo (configurable vía Remote Config).
- Emisión de **onda de sonido**: activa `SoundWave.tscn`, que se expande radialmente e ilumina obstáculos durante N segundos.
- Detección de colisiones con obstáculos (muerte) y cristales (recolección).
- Gestión de las 2 habilidades de vuelo equipadas (patrón Strategy).

Señales emitidas: `player_died`, `crystal_collected(amount)`, `wave_emitted`.

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

## Flujo de una partida

```
MainMenu
  → [Play] → GameManager.start_game()
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
