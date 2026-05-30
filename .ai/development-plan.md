# Plan de desarrollo — Echo Bat

Extraído del GDD v4.0 (mayo 2025). Referencia completa: `.ai/GDD_Echo_Bat_v4.docx`.

**Estados:** `[x]` completado · `[ ]` pendiente · `[-]` en progreso · `[~]` bloqueado/decisión pendiente

---

## Fase 0 — Prototipo base (~25 h)
*Objetivo: juego jugable sin crashes en desktop y Android.*

### Infraestructura
- [x] Repositorio GitHub con `.gitignore` Godot
- [x] Estructura de carpetas del proyecto (`scenes/`, `scripts/`, `assets/`, `addons/`)
- [x] Documentación `.ai/` completa (8 archivos según estándar corporativo)
- [x] `project.godot`: viewport 1280×720, escena main, actions `jump` y `wave`, autoload `GameManager`

### Escenas base
- [x] `scenes/Game.tscn` — Node2D + Camera2D + Player + Ground
- [x] `scenes/Player.tscn` — CharacterBody2D + CollisionShape2D + Sprite2D placeholder

### Movimiento del murciélago
- [x] Avance horizontal automático constante (400 px/s)
- [x] Gravedad (1800 px/s²)
- [x] Salto: impulso vertical (−600 px/s)
- [x] Input teclado: `Space` → salto (action `jump` en `project.godot`)
- [x] Input táctil: toque en el 60% derecho → salto
- [x] Input teclado: `Enter` → onda de sonido (action `wave`, physical_keycode 4194309)
- [x] Input táctil: toque en el 40% izquierdo → onda de sonido

### Cámara
- [x] Seguimiento horizontal: 300 px por delante del jugador
- [x] Zona muerta vertical: 32% central (±115 px con viewport 720 h)
- [x] Desplazamiento vertical: 250 px/s con `move_toward` (sin overshoot)
- [x] Clamp superior: `camera.y >= 0` (nunca muestra por encima del techo)

### Mecánica de onda de sonido (básica)
- [x] `scenes/SoundWave.tscn` + `scripts/player/SoundWave.gd`: proyectil que sale del murciélago
- [x] Dirección: hacia la derecha a 800 px/s, se destruye a los 900 px de distancia
- [x] Cooldown entre ondas (1 s, gestionado en `Player.gd`)
- [x] Visual placeholder (círculo degradado blanco semitransparente, 32×32 px)
- [ ] SFX al lanzar (usar `scream.wav` del prototipo convertido a OGG)
- [x] Señal `wave_emitted` en `Player.gd`

### Obstáculos y colisión
- [x] Sección de prueba: 3 pares de estalactitas en `Game.gd` (Polygon2D marrón, gap 210 px)
- [x] Spawn de sección repetida para testing vía bucle de wrap en `Player.gd`
- [x] Hitbox del murciélago detecta grupo `obstacle` → señal `player_died(distance)`
- [x] Al morir: `Player.die()` detiene física, input y emite señal

### Game Over y reinicio
- [x] `scenes/ui/GameOver.tscn` + `scripts/ui/GameOver.gd` — distancia, récord, botón Reintentar
- [x] `scripts/core/GameManager.gd` (autoload): estados `PLAYING` / `GAME_OVER`, récord en disco
- [x] Reinicio: `GameManager.start_game()` recarga `Game.tscn`
- [x] Mostrar distancia en metros y récord histórico en Game Over

### Exportación Android básica
- [ ] Plantilla de exportación Android configurada en el editor
- [ ] APK de debug exportable y ejecutable en dispositivo físico
- [ ] Input táctil verificado en dispositivo real

---

## Fase 1 — Arte y audio del Bioma 1 (~35 h)

### Arte del murciélago
- [ ] Sprite de vuelo con Firefly + Aseprite (ref: 11 frames, ~369×400 px por frame)
- [ ] Sprite de muerte (ref: 10 frames)
- [ ] Reemplazar `_setup_placeholder()` por sprite definitivo en `Player.gd`
- [ ] `AnimatedSprite2D` con estados: `fly`, `die`

### Arte Bioma 1 — La Entrada (paleta ocre cálido)
- [ ] Fondo panorámico con Midjourney + Affinity Photo (7 capas parallax, ref: 11.000×2.500 px)
- [ ] Tileset de estalactitas estáticas
- [ ] `ParallaxBackground` con las 7 capas a velocidades distintas

### Audio
- [ ] Convertir SFX del prototipo a OGG: `flap.wav`, `golpe.wav`, `scream.wav`
- [ ] Música Bioma 1: comprimir `ingame.wav` a OGG (~1 MB) o generar con Suno AI
- [ ] `AudioManager` (autoload): canales separados para música y SFX
- [ ] SFX de salto (`flap`), muerte (`golpe`), onda (`scream`)

### Tipografía
- [ ] Importar fuente Coders Crux → HUD (distancia, puntuación, Game Over)
- [ ] Importar fuente Magic School One/Two → menú principal, títulos de eventos

---

## Fase 2 — Endless procedural (~25 h)

### Generador de obstáculos
- [x] `SpawnManager.gd`: generación procedural de pares de estalactitas
- [x] Spawn delante de la cámara (1 spacing más allá del borde derecho), despawn detrás
- [x] Gap vertical aleatorio dentro de límites seguros (margen 50 px de techo/suelo)
- [x] Bioma 1 — La Entrada: gap 210 px, spacing 400 px

### Sistema de biomas y ciclos
- [x] 5 biomas con parámetros propios en `GameManager.BIOME_DATA`
- [x] Orden: La Entrada → La Penumbra → La Catarata → Las Agujas → El Núcleo (y repite)
- [x] Cada bioma dura 1000 m; `GameManager.update_distance()` calcula bioma activo cada frame
- [x] Al completar ciclo: velocidad +10% (cap 550 px/s) via `GameManager.get_speed()`
- [x] Eliminado `LOOP_WIDTH` de `Player.gd` (TD-008 cerrado)

### Sistema de puntuación
- [x] 1 punto por metro recorrido (distancia en metros = puntuación base; 100 px = 1 m)
- [ ] Bonus al cruzar umbral de bioma: +200/+400/+700/+1100/+2000 pts
- [x] Récord local persistido con `FileAccess` en `user://record.dat`
- [x] Mostrar distancia, récord y bioma actual en Game Over
- [ ] HUD en tiempo real: contador de distancia durante la partida

### Cristales de Eco
- [ ] Spawn de cristales en el nivel (interleaved con obstáculos)
- [ ] Colisión murciélago → cristal = señal `crystal_collected(amount)`
- [ ] Ganancia automática: 10 cristales por cada 100 m recorridos
- [ ] `EconomyManager` (autoload): balance de cristales + persistencia local

---

## Fase 3 — Firebase y persistencia (~25 h)

### Integración Firebase
- [ ] Instalar plugin GodotFirebase en `addons/` — actualizar `stack.md`
- [ ] `FirebaseService.gd`: inicialización + auth anónima al arrancar
- [ ] `FirestoreService.gd`: leer/escribir `users/{uid}` según estructura del GDD
- [ ] `AnalyticsService.gd`: eventos `session_start`, `player_died`, `biome_reached`
- [ ] `CrashlyticsService.gd`: reporte de crashes en producción

### Login con Google Play Games
- [ ] Instalar plugin `godot-play-game-services` — actualizar `stack.md`
- [ ] Login **opcional** (no bloquea el juego; mostrar botón en menú)
- [ ] Vincular Google Play Games con Firebase Auth
- [ ] Sincronización de UID entre sesiones

### Persistencia offline-first
- [ ] Guardado local (récord, cristales, skins, habilidades) → `user://save.dat`
- [ ] Sync local → Firestore al detectar conexión
- [ ] Política: local siempre tiene prioridad sobre la nube

### Leaderboard global
- [ ] Colección Firestore `leaderboard_global` con estructura del GDD
- [ ] Pantalla de ranking (top 100 por distancia)
- [ ] Actualizar ranking al superar récord personal

### Logros (Google Play Games)
- [ ] 10 logros definidos en el GDD (Primer vuelo, Explorador, Espeleólogo, etc.)
- [ ] Desbloqueo automático al cumplir condición in-game

---

## Fase 4 — Tutorial, misiones y notificaciones (~20 h)

### Tutorial (solo primera partida, sin texto)
- [ ] Seg. 0–2: icono de mano animado → zona derecha (salto)
- [ ] Seg. 5–15: zona sin obstáculos para practicar salto solo
- [ ] Seg. 15: icono zona izquierda + icono onda
- [ ] Seg. 20: zona oscura breve → onda ilumina (efecto sin instrucción)
- [ ] Seg. 25+: juego normal sin ayudas
- [ ] Si muere antes del seg. 25: mensaje en Game Over sobre la onda

### Sistema de misiones
- [ ] 3 misiones diarias generadas al azar (tabla completa en GDD §6.2)
- [ ] 3 misiones semanales acumulativas (tabla en GDD §6.3)
- [ ] Bonus: +50 cristales al completar las 3 diarias
- [ ] Bonus: +150 cristales + skin de semana al completar las 3 semanales
- [ ] Progreso de misiones sincronizado en Firestore

### Pantalla de Game Over completa (GDD §11)
- [ ] Animación de muerte: murciélago cae
- [ ] Distancia de la partida (número grande, tipografía Coders Crux)
- [ ] Récord personal (confeti + SFX fanfarria si se supera)
- [ ] Puntuación total (distancia + bonus biomas)
- [ ] Bioma alcanzado (icono + nombre)
- [ ] Cristales ganados (animación de conteo)
- [ ] Botón REVIVE (si escudo disponible o ofrece anuncio)
- [ ] Botón REINTENTAR y botón MENÚ
- [ ] Banner de tienda si jugador está cerca de un hito de cristales

### Sistema de compartir (GDD §12)
- [ ] Screenshot automático con datos de la partida
- [ ] Menú nativo de compartir del SO (Android)
- [ ] Deep link con Firebase Dynamic Links para adquisición orgánica

### Notificaciones push (FCM) (GDD §9)
- [ ] Solicitar permiso tras la primera partida completada (no al abrir)
- [ ] 7 tipos de notificaciones con reglas de frecuencia (máx. 1/día, 9:00–22:00)
- [ ] Panel de preferencias en ajustes del juego

---

## Fase 5 — Habilidades, skins y tienda (~35 h)

### Sistema de habilidades (GDD §14.5–14.6)
- [ ] Slot 1 (movimiento): Vuelo estable, Aleteo rápido, Deslizamiento, Corriente de cola, Peso ligero
- [ ] Slot 2 (onda): Onda ancha, Eco persistente, Onda doble, Pulso de emergencia, Onda silenciosa
- [ ] Patrón Strategy: `FlightSkill` como `Resource` con `on_activate()` y `on_tick()`
- [ ] Niveles de habilidad (hasta 3 según tabla del GDD)
- [ ] `SkillSelector.tscn`: selección de 2 habilidades antes de partida

### Sistema de skins (GDD §14.2–14.4)
- [ ] 6 skins gratuitas con condiciones de desbloqueo (tabla en GDD)
- [ ] 7 skins de pago permanentes (0.99–1.49 €)
- [ ] Visual del murciélago cambia según skin equipada
- [ ] Skins de temporada (estructura preparada para Fase 7)

### Tienda (`Shop.tscn`)
- [ ] Sección skins gratuitas (mostrar condición de desbloqueo)
- [ ] Sección skins de pago
- [ ] Sección habilidades (compra con cristales)
- [ ] Sección packs de cristales (IAP)

### Monetización (GDD §15)
- [ ] Plugin Google Play Billing instalado — actualizar `stack.md`
- [ ] Pack mínimo: 500 cristales / 0.99 €
- [ ] Pack estándar: 1500 / 1.99 €
- [ ] Pack grande: 4000 / 3.99 €
- [ ] Pack de inicio (solo primera semana): 2000 + skin / 2.99 €
- [ ] Pack "Sin anuncios" (permanente): 4.99 €

### Revive y escudo (GDD §14.7)
- [ ] 1 escudo por cada 10 partidas llegando al menos al Bioma 2
- [ ] Máximo 3 escudos almacenados
- [ ] Anuncio recompensado para revive (máx. 1× por partida)

---

## Fase 6 — Biomas 2–5, arte y audio (~45 h)

### Bioma 2 — La Penumbra (gris azulado, 60% luz)
- [ ] Tileset con musgo y estalactitas
- [ ] Shader de vignette de oscuridad progresiva
- [ ] Onda útil pero no imprescindible; gap 3 bloques
- [ ] Música Bioma 2 (Suno AI, loop seamless)

### Bioma 3 — La Catarata (azul profundo)
- [ ] Tileset con agua y estalactitas mojadas
- [ ] Corrientes verticales que modifican la física del murciélago
- [ ] Obstáculos móviles (cortinas de agua)
- [ ] Shader de distorsión de agua
- [ ] Gap 2.5 bloques; música Bioma 3

### Bioma 4 — Las Agujas (negro/rojo volcánico)
- [ ] Tileset de obsidiana + lava
- [ ] Pinchos extensibles (obstáculos con movimiento propio)
- [ ] Shader de glow de lava
- [ ] Alta densidad, gap 2 bloques; música Bioma 4

### Bioma 5 — El Núcleo (negro absoluto)
- [ ] Shader de oscuridad total (nada visible sin onda)
- [ ] Shader de iluminación radial activado por la onda
- [ ] Cristales negros como obstáculos
- [ ] Velocidad +20% sobre base del ciclo; música Bioma 5

### Audio espacial del eco
- [ ] Intensidad del SFX de eco proporcional a distancia del obstáculo más cercano
- [ ] SFX adicionales: cristal recogido, logro desbloqueado, victoria de ciclo

---

## Fase 7 — Eventos de temporada y publicación (~35 h)

### Eventos de temporada (GDD §13)
- [ ] Arte de los 11 eventos anuales: skins + cambios visuales de bioma
- [ ] Activación/desactivación remota via Firebase Remote Config sin update de app
- [ ] Skin de temporada visible en tienda solo mientras el evento está activo
- [ ] Multiplicador ×1.5 de cristales durante eventos activos

### AdMob (GDD §15.3)
- [ ] Plugin `godot-admob` instalado y configurado — actualizar `stack.md`
- [ ] Intersticial: cada 3 muertes (automático)
- [ ] Anuncio recompensado (voluntario): +50 cristales, máx. 5× por día
- [ ] Anuncio recompensado (voluntario): revive, máx. 1× por partida
- [ ] Configuración COPPA-compliant (`child-directed treatment`)

### Publicación en Google Play (GDD §18)
- [ ] Icono del juego (512×512 px)
- [ ] Capturas de pantalla (mínimo 4, landscape)
- [ ] Feature graphic (1024×500 px)
- [ ] Descripción corta y larga en español e inglés
- [ ] Política de privacidad publicada en URL pública
- [ ] Términos de servicio publicados
- [ ] Botón "Eliminar mi cuenta" en ajustes (RGPD)
- [ ] APK/AAB firmado con keystore de producción
- [ ] Publicación: track interno → alfa → producción

### Legal pre-publicación (GDD §18.4)
- [ ] Verificar disponibilidad de marca "Echo Bat" en EUIPO
- [ ] Registrar dominio `echobatgame.com` o `echobat.game`
- [ ] Crear cuentas en redes sociales (@EchoBatGame)
- [ ] Verificar que ningún asset de arte/música tiene copyright externo
- [ ] Configurar ATT prompt para iOS (cuando llegue la fase iOS)
