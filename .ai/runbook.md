# Runbook — Echo Bat

## Abrir el proyecto

1. Abrir **Godot 4.6** (no otra versión; el proyecto no es compatible hacia atrás).
2. En el Project Manager, importar la carpeta raíz del repo.
3. Godot regenerará `.godot/` si falta. No commitear esa carpeta (está en `.gitignore`).

## Ejecutar en escritorio (desarrollo rápido)

- Pulsar **F5** (o botón Play) en el editor.
- La escena de entrada es `scenes/Game.tscn` (ya configurada como main scene en `project.godot`).
- En escritorio el salto se activa con `Space` (action `jump` definida en `project.godot`). El toque se simula con clic en el 60% derecho de la ventana.

## Ejecutar en Android (dispositivo físico)

Prerequisitos:
- Android SDK instalado y configurado en Godot → Editor → Export → Android.
- `adb` disponible en PATH.
- Dispositivo con depuración USB activada.
- Plantilla de exportación Android instalada en el editor.

Pasos:
1. Conectar el dispositivo.
2. En Godot: **Project → Export → Android → Export Project** (debug).
3. O usar Remote Debug: en el menú desplegable del botón Play, seleccionar el dispositivo Android detectado.

## Exportar AAB de release (Google Play)

1. Tener el keystore configurado en la plantilla de exportación Android (campo "Keystore").
2. **Project → Export → Android → Export Project** con "Export AAB" marcado y modo Release.
3. El `.aab` firmado sale en la ruta configurada en la plantilla.
4. Subir a Google Play Console: **Testing interno → Alfa → Producción**.

## Firebase — configuración inicial

- Las claves de Firebase (`google-services.json`) van en `android/build/` y **no se commitean** (están en `.gitignore`).
- Obtener el archivo en Firebase Console del proyecto `echo-bat`.
- Remote Config: los valores de desarrollo se sobreescriben localmente con constantes de fallback en `scripts/services/RemoteConfigService.gd`.

## Agregar un plugin Godot

1. Descargar el plugin (AssetLib o manual) y copiarlo en `addons/<nombre>/`.
2. Activarlo en **Project → Project Settings → Plugins**.
3. Actualizar `stack.md` con nombre y versión exacta.
4. Commitear `addons/` completo (los plugins se versionan con el proyecto).

## Secretos y claves

No hay variables de entorno en tiempo de ejecución Godot. Los secretos se gestionan así:

| Secreto | Dónde va |
|---|---|
| `google-services.json` | `android/build/` — NO commitear |
| AdMob App ID | `project.godot` en la sección del plugin AdMob — sí commitear (no es secreto) |
| Keystore de firma | Fuera del repo, referenciado desde la plantilla de exportación |
