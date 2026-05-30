# Glosario — Echo Bat

Términos específicos del dominio del juego. Usar estos nombres exactos en código, comentarios y documentación para evitar ambigüedad.

---

**Bioma** (`BiomeType`)  
Sección temática del nivel con estética propia y set de obstáculos característico. Hay 5 biomas: Cueva, Bosque, Ruinas, Tormenta y Vacío. Se encadenan en bucle infinito.

**Ciclo** (`cycle`)  
Vuelta completa a los 5 biomas. Al completar un ciclo, la dificultad global sube: más velocidad, mayor densidad de obstáculos y zonas oscuras más largas. El número de ciclos es el principal vector de dificultad creciente.

**Cristal de Eco** (`EchoCrystal`; en código: `crystal`)  
Moneda interna del juego. Se obtiene recogiéndolos en el nivel, viendo anuncios recompensados o comprando con dinero real (IAP). Se gasta en la tienda en skins y packs de habilidades.

**Ecolocalización** (`echolocation`)  
Mecánica central del juego. El murciélago emite pulsos de sonido que revelan el entorno invisible. En términos de juego: el jugador lanza ondas de sonido para iluminar obstáculos ocultos en zonas oscuras.

**Onda de sonido** (`SoundWave`)  
Proyectil radial emitido por el jugador. Se expande desde la posición del murciélago e ilumina todos los obstáculos dentro de su radio durante un tiempo limitado. Tiene cooldown configurable vía Remote Config.

**Zona oscura** (`dark_zone`)  
Segmento del nivel donde los obstáculos son completamente invisibles hasta que la onda de sonido los ilumina. Es el principal elemento de tensión. La frecuencia y duración de las zonas oscuras aumenta con los ciclos.

**Sección de bioma** (`BiomeSection`)  
Fragmento reutilizable (pooled) de nivel que `BiomeGenerator` instancia, desplaza y recicla al vuelo para crear el scroll infinito sin instanciación en caliente.

**Slot de habilidad** (`skill_slot`)  
Posición (1 o 2) en la que el jugador equipa una habilidad de vuelo. Solo hay 2 slots activos por partida; se configuran en `SkillSelector.tscn` antes de iniciar.

**Habilidad de vuelo** (`FlightSkill`)  
Modificador de comportamiento del murciélago activo durante la partida. El jugador elige 2 de un catálogo de 10. Implementadas como `Resource` con patrón Strategy sobre `Player.gd`. Ejemplos: doble salto, escudo, onda ampliada.

**Skin** (`Skin`)  
Aspecto visual alternativo del murciélago. Puramente cosmético; no afecta a la jugabilidad. Las hay permanentes (tienda) y de tiempo limitado (eventos de temporada).

**Evento de temporada** (`SeasonalEvent`)  
Período de tiempo limitado con skins exclusivas y desafíos especiales. Activado y configurado vía Firebase Remote Config. Clave para la retención a largo plazo.

**Perfil de jugador** (`PlayerProfile`)  
Documento Firestore por usuario que almacena: balance de cristales, inventario de skins, habilidades desbloqueadas, récord de puntuación y número de ciclos completados.

**Dificultad por ciclo** (`cycle_difficulty`)  
Conjunto de parámetros que escalan con cada ciclo completado: velocidad del murciélago, densidad de obstáculos, duración e intensidad de las zonas oscuras. Los valores base se configuran en Remote Config.

**Anuncio recompensado** (`rewarded_ad`)  
Anuncio de AdMob que el jugador ve voluntariamente a cambio de Cristales de Eco extra o de una segunda oportunidad tras morir (revive).

**IAP** (`iap`, `IAPProduct`)  
Compra dentro de la app vía Google Play Billing. Productos disponibles: packs de Cristales de Eco (consumibles) y skins de temporada (no consumibles).

**Remote Config** (`remote_config`)  
Servicio de Firebase que permite cambiar parámetros del juego (dificultad, precios, flags de features) sin publicar una nueva versión en la tienda. Todos los parámetros tienen fallback local en `RemoteConfigService.gd`.
