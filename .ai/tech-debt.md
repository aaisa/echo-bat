# Deuda técnica — Echo Bat

> Proyecto en fase inicial. La deuda anotada aquí es prevista por diseño, no acumulada.

## Deuda activa

| ID | Descripción | Motivo | Revisar cuando |
|---|---|---|---|
| TD-001 | C# habilitado en `project.godot` sin usarse | El proyecto Godot se creó con C# activado por defecto | Al estabilizar el stack; desactivar si no se planea usar nunca |
| TD-002 | Sin CI/CD configurado | El proyecto arranca sin pipeline; exportación y firma son manuales | Antes del primer release en Google Play |
| TD-003 | `google-services.json` gestionado manualmente | Sin secrets manager; el archivo se distribuye fuera del repo | Al añadir CI/CD; integrar con GitHub Secrets |
| TD-004 | Plugins de Firebase/AdMob sin versión fijada | Stack aún por decidir; los plugins cambian de API entre versiones de Godot | Al elegir e instalar los plugins; fijar versión exacta en `stack.md` |
| TD-005 | Sin sistema de tests (GUT no instalado) | Sin cobertura de lógica de economía ni generación procedural | Al completar el núcleo jugable; instalar GUT y crear `tests/` |

| TD-006 | `Player.tscn` y `Game.tscn` en `scenes/` raíz en lugar de `scenes/game/` | Creadas antes de definir la estructura de subdirectorios | Al añadir la segunda escena de juego; mover y actualizar rutas en `.tscn` |
| TD-007 | Sprite del murciélago es un rectángulo CYAN generado por código | No hay arte todavía | Al recibir el primer sprite sheet; sustituir `_setup_placeholder()` en `Player.gd` |
| ~~TD-008~~ | ~~`LOOP_WIDTH` hardcodeado en `Player.gd`~~ | **Cerrado** — eliminado al implementar `SpawnManager` en Fase 2 | — |

## Deuda pagada

*(Ninguna todavía.)*

## Regla de trabajo

Al introducir una solución provisional consciente, añadir una fila aquí antes de hacer merge. Sin registro, no hay deuda gestionable.
