import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Las notificaciones programadas solo existen en Android/iOS, no en el navegador.
  static bool get isSupported => !kIsWeb;

  static Future<void> init() async {
    if (!isSupported) return;

    tz.initializeTimeZones();
    // Sin esta línea tz.local queda en UTC y la notificación llegaría 5 h tarde en Colombia.
    tz.setLocalLocation(tz.getLocation('America/Bogota'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);

    // Android 14+: las alarmas exactas vienen desactivadas; esto pide el permiso.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  /// Devuelve true si se programó; lanza excepción si algo falla en el dispositivo.
  static Future<bool> scheduleDailySummary({
    required int hour,
    required int minute,
    required double totalMeters,
  }) async {
    if (!isSupported) return false;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final vibration = Int64List.fromList([0, 400, 200, 400]);

    final androidDetails = AndroidNotificationDetails(
      'walk_summary_channel',
      'Resumen Diario de Caminata',
      channelDescription: 'Notificaciones diarias de distancia recorrida',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      vibrationPattern: vibration,
    );

    await _plugin.zonedSchedule(
      0,
      'Resumen Diario de Actividad',
      'Hoy has caminado aprox. ${totalMeters.toStringAsFixed(1)} metros.',
      scheduled,
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    return true;
  }
}
