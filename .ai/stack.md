# Stack — Echo Bat

## Motor y lenguaje

| Componente | Versión / detalle |
|---|---|
| Godot | 4.6 |
| Lenguaje | GDScript (C# habilitado en el proyecto pero no se usa) |
| Renderer | Mobile (D3D12 en Windows editor, Vulkan Mobile en dispositivo Android) |
| Físicas | Jolt Physics (integrado en Godot 4.6) |

## Plugins Godot (`addons/`)

> Aún no instalados. Actualizar esta tabla al añadir cada plugin con nombre exacto y versión.

| Plugin | Propósito |
|---|---|
| `godot-firebase` (GodotFirebase) | Wrapper GDScript para Firebase SDK en Android/iOS |
| `godot-admob` | Integración AdMob para intersticiales y anuncios recompensados |
| `godot-google-play-billing` | Google Play Billing v6+ para IAP |
| `godot-play-game-services` | Google Play Games Services (login, logros, rankings) |

## Backend — Firebase

| Servicio | Uso |
|---|---|
| Firebase Auth | Autenticación anónima + vinculación con Google Play Games |
| Firestore | Perfil del jugador, progresión, inventario de skins |
| Firebase Remote Config | Parámetros de dificultad, precios IAP, flags de features |
| Firebase Analytics | Eventos de sesión, compras, progresión de biomas |
| Firebase Crashlytics | Reporte de crashes en producción |
| FCM (Cloud Messaging) | Notificaciones push para eventos de temporada |

## Monetización

| Servicio | Uso |
|---|---|
| Google AdMob | Intersticiales entre partidas + anuncios recompensados (Cristales de Eco extra) |
| Google Play Billing | IAP: packs de Cristales de Eco, skins de temporada |

## Login / Identidad

| Plataforma | Proveedor |
|---|---|
| Android | Google Play Games Services |
| iOS (fase 2) | Apple Game Center |

## CI/CD

*(Por definir. Candidato: GitHub Actions para export de AAB + subida interna a Google Play Console.)*

## Entornos

| Entorno | Descripción |
|---|---|
| local | Editor Godot + emulador Android o exportación debug por USB |
| producción | Google Play (track interno → alpha → producción) |
