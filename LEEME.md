# Taller Movilidad – instrucciones

Mapa con **OpenStreetMap (flutter_map)**, igual que el ejemplo `Talleres/mapas` del profesor.
No necesita API key de Google ni tarjeta.

## Qué archivo va dónde (dentro de tu carpeta flutter_application_1)

| Archivo de este paquete | Qué hacer |
|---|---|
| `pubspec.yaml` | Reemplazar |
| `lib/` (toda la carpeta) | Reemplazar |
| `android/app/src/main/AndroidManifest.xml` | Reemplazar |
| `android/app/build.gradle.kts` | Reemplazar, **pero primero mira el `namespace` y `applicationId` de tu archivo original** y deja esos mismos valores |
| `test/widget_test.dart` de tu proyecto | **Bórralo** (busca un `MyApp` que ya no existe y da error) |

## Comandos (terminal dentro de flutter_application_1)
```
flutter clean
flutter pub get
flutter devices
flutter run
```
Ejecútalo en tu **celular Android** (no en Edge/Chrome): el giroscopio, la vibración
y las notificaciones no existen en el navegador.

## Qué hace la app
**Pestaña "Parques y Mapa"**
- Punto azul: tu ubicación GPS.
- Árboles verdes: parques reales a 3 km (Overpass API). Tócalos para ver el nombre.
- Toca el mapa para agregar un marcador (como en el ejemplo de clase).
- Botones arriba: centrar en mi ubicación · recargar parques · borrar marcadores agregados.

**Pestaña "Sensor y Notificación"**
- Detecta que caminas con el giroscopio, vibra y suma distancia (estimada a 1,2 m/s).
- Botón para programar una notificación diaria con la distancia.
  Pruébala poniéndola 1–2 minutos después de la hora actual.

## Correcciones respecto a la guía PDF
- Google Maps → OpenStreetMap (`flutter_map` + `latlong2`).
- Zona horaria fijada en `America/Bogota` (si no, la notificación llegaba 5 h tarde).
- Se pide el permiso de alarmas exactas (Android 14+).
- Receptores de notificaciones agregados al manifest.
- Desugaring activado en `build.gradle.kts` (sin esto no compila flutter_local_notifications).
- Partes de código que estaban cortadas en el PDF, completadas.
