# 🌿 Taller Movilidad

Aplicación móvil desarrollada en **Flutter** como taller final de **Desarrollo Móvil**.
Integra **geolocalización**, **consumo de API**, **sensores** y **notificaciones programadas**, organizada con una **arquitectura modular** (Theme, Services, Widgets y Screens).

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Plataforma-Android-3DDC84?logo=android&logoColor=white)
![OpenStreetMap](https://img.shields.io/badge/Mapas-OpenStreetMap-7EBC6F?logo=openstreetmap&logoColor=white)

---

## 📲 Descargar la app

La APK está disponible en la sección **[Releases](https://github.com/Cinthya0106/Taller-moviles/releases)** → `app-release.apk` (versión **v1.0.0**).

1. Descarga `app-release.apk` desde el celular Android.
2. Ábrela y permite **"Instalar apps de origen desconocido"** si el sistema lo pide.
3. Acepta los permisos de **ubicación** y **notificaciones** al abrir la app.

📘 El paso a paso completo está en el **[Manual de usuario (PDF)](Manual_de_Usuario_Taller_Movilidad.pdf)**.

---

## ✨ Funcionalidades

### 🗺️ Explorar (mapa)
- Mapa interactivo con **OpenStreetMap** (`flutter_map`), sin necesidad de API key.
- Ubicación actual del usuario mediante **GPS**.
- Consulta de **parques reales en un radio de 3 km** usando **Overpass API**.
- Ficha de cada parque con **distancia** y **minutos a pie**.
- Lista de parques ordenada del más cercano al más lejano.
- **Marcadores propios** tocando cualquier punto del mapa.
- Botones flotantes para centrar en mi ubicación, recargar parques y borrar marcadores.

### 🚶 Actividad (sensores)
- Detección de caminata con el **giroscopio** (`sensors_plus`).
- **Vibración** al empezar a caminar.
- **Anillo de progreso** hacia una meta diaria de 2 km.
- Estadísticas estimadas: **pasos, calorías y minutos**.

### 🔔 Resumen diario (notificaciones)
- Notificación **programada todos los días** a la hora que elija el usuario.
- Muestra la distancia recorrida con un **patrón de vibración** personalizado.
- Zona horaria configurada en `America/Bogota`.

---

## 🧱 Arquitectura del proyecto

```
lib/
├── main.dart                      # Arranque, permisos y navegación inferior
├── theme/
│   └── app_theme.dart             # Paleta, tipografía y estilos globales
├── services/
│   ├── park_service.dart          # Consulta de parques (Overpass API)
│   └── notification_service.dart  # Notificación diaria programada
├── widgets/
│   └── step_counter_widget.dart   # Giroscopio + anillo de progreso
└── screens/
    ├── map_screen.dart            # Pantalla Explorar
    └── tracker_screen.dart        # Pantalla Actividad
```

| Capa | Responsabilidad |
|---|---|
| **Theme** | Centraliza colores (verde esmeralda y menta), tipografía y estilos de componentes. |
| **Services** | Comunicación con APIs externas y librerías nativas, separada de la interfaz. |
| **Widgets** | Componentes reutilizables e independientes (contador de pasos). |
| **Screens** | Pantallas completas que ve el usuario. |

---

## 🛠️ Tecnologías

| Paquete | Uso |
|---|---|
| `flutter_map` + `latlong2` | Mapa con OpenStreetMap |
| `geolocator` | Ubicación GPS |
| `http` | Consumo de Overpass API |
| `sensors_plus` | Lectura del giroscopio |
| `vibration` | Retroalimentación háptica |
| `flutter_local_notifications` + `timezone` | Notificaciones programadas |
| `permission_handler` | Permisos de ubicación y notificaciones |

---

## ▶️ Ejecutar el proyecto

**Requisitos:** Flutter SDK, VS Code o Android Studio y un celular Android con depuración USB activada.

```bash
# Clonar el repositorio
git clone https://github.com/Cinthya0106/Taller-moviles.git
cd Taller-moviles

# Instalar dependencias
flutter pub get

# Ejecutar en el celular conectado
flutter run

# Generar la APK de producción
flutter build apk --release
```

> ⚠️ Ejecuta la app en un **dispositivo Android físico**. En el navegador o en el emulador no están disponibles el giroscopio, la vibración ni las notificaciones programadas.

---

## 🔐 Permisos utilizados

| Permiso | Motivo |
|---|---|
| `INTERNET` | Cargar el mapa y consultar parques |
| `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` | Ubicar al usuario en el mapa |
| `VIBRATE` | Vibrar al detectar la caminata y en la notificación |
| `POST_NOTIFICATIONS` | Mostrar el resumen diario (Android 13+) |
| `SCHEDULE_EXACT_ALARM` | Enviar la notificación a la hora exacta |
| `RECEIVE_BOOT_COMPLETED` | Mantener la notificación programada tras reiniciar el celular |

---

## 📝 Notas

- La distancia es una **estimación** (1,2 m por segundo de caminata detectada), no un podómetro de precisión.
- Los parques dependen de los datos registrados en **OpenStreetMap**; algunos parques pequeños pueden no aparecer.
- Se reemplazó Google Maps por OpenStreetMap para no depender de API key ni de facturación.

---

## 👩‍💻 Autora

**Cinthya Kuper**
Ingeniería Multimedia · Desarrollo Móvil · Noviembre 2026

Datos de mapas © colaboradores de [OpenStreetMap](https://www.openstreetmap.org/copyright).
