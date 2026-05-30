# Echo Bat — punto de entrada para asistentes IA

Endless runner 2D en Godot 4 / GDScript. Un murciélago avanza automáticamente hacia la derecha; el jugador controla el salto y lanza ondas de sonido para iluminar obstáculos en zonas oscuras.

## Mapa rápido

| Campo | Valor |
|---|---|
| Propósito | Juego móvil (Android) free-to-play con monetización por anuncios e IAP |
| Entrypoint de escena | `scenes/Main.tscn` |
| Entrypoint de script | `scripts/core/Main.gd` |
| Inputs del jugador | Toque / espacio → salto; segundo toque → onda de sonido |
| Outputs del sistema | Puntuación, Cristales de Eco, progresión de biomas |
| Package | `com.echobat.game` |
| Repositorio | `github.com/aaisa/echo-bat` |

## Reglas duras locales

1. **Solo GDScript.** El proyecto tiene C# habilitado pero no se usa. Cero archivos `.cs`.
2. **Sin autoloads innecesarios.** Máximo cuatro autoloads: `GameManager`, `AudioManager`, `EconomyManager`, `EventBus`. Si algo puede ser un nodo hijo, es un nodo hijo.
3. **Firebase solo desde la capa de servicios.** La lógica de juego no llama a Firebase directamente; pasa por `scripts/services/`. Ningún script de gameplay conoce Firestore.
4. **Monetización en capa propia.** AdMob e IAP viven en `scripts/monetization/`. El resto del código no los importa directamente.
5. **Nombres en inglés, comentarios en español.** Variables, funciones, señales y archivos en inglés. Los comentarios explicativos en español.
6. **Un script por escena.** Cada `.tscn` tiene su `.gd` con el mismo nombre base. No se reutiliza un script en escenas de naturaleza distinta.

## Documentación disponible

| Archivo | Qué contiene |
|---|---|
| [`overview.md`](overview.md) | Para qué existe el juego y a quién sirve |
| [`stack.md`](stack.md) | Motor, plugins, servicios externos y versiones |
| [`runbook.md`](runbook.md) | Cómo abrir, ejecutar, exportar y desplegar |
| [`conventions.md`](conventions.md) | Naming, estructura de carpetas, commits, ramas |
| [`tech-debt.md`](tech-debt.md) | Deuda técnica conocida |
| [`architecture.md`](architecture.md) | Subsistemas, escenas clave, flujo de datos |
| [`glossary.md`](glossary.md) | Términos del dominio del juego |

## Extensiones

*(Ninguna todavía. Se añadirán aquí cuando el proyecto las necesite.)*
