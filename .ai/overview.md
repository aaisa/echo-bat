# Overview — Echo Bat

## Qué es

Echo Bat es un endless runner 2D para móvil en el que el jugador controla un murciélago que avanza automáticamente hacia la derecha. El núcleo de la mecánica es la **ecolocalización**: el jugador lanza ondas de sonido que iluminan temporalmente los obstáculos en zonas de oscuridad total, obligando a memorizar el entorno y a reaccionar con precisión.

## A quién sirve

- **Jugadores casuales móvil**: sesiones cortas de 2-5 minutos, curva de entrada mínima (un toque para saltar, otro para echolocalizar).
- **Jugadores de retención media**: progresión por ciclos de dificultad, desbloqueo de habilidades de vuelo y colección de skins de temporada.
- **Negocio**: juego free-to-play financiado por anuncios (AdMob) e IAP cosméticas; los Cristales de Eco se obtienen jugando o comprando.

## Por qué existe este repo

Repositorio único del juego completo: lógica de juego (Godot/GDScript), integración con backend (Firebase), monetización (AdMob + Google Play Billing) y assets de producción. No existe repo separado de backend.

## Objetivos de producto

1. **Retención D1/D7**: mecánica de ecolocalización diferenciadora + 5 biomas procedurales con dificultad creciente por ciclos.
2. **Monetización**: anuncios intersticiales y recompensados + IAP de Cristales de Eco y skins de tiempo limitado.
3. **Plataforma principal**: Android (Google Play). iOS es fase 2 con Apple Game Center.
4. **Eventos de temporada**: rotación de skins y desafíos limitados para aumentar retención a largo plazo.

## Lo que este repo NO es

- No es un backend independiente: no hay servidor propio, todo el backend es Firebase gestionado.
- No es multiplayer: el juego es completamente offline en su núcleo; Firebase solo gestiona perfil y rankings.
