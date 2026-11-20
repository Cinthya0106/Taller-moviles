import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../widgets/step_counter_widget.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  double _currentDistance = 0.0;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0);

  Future<void> _pickTimeAndSchedule() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });

      String message;
      Color color = const Color(0xFF2E7D32);

      try {
        final ok = await NotificationService.scheduleDailySummary(
          hour: picked.hour,
          minute: picked.minute,
          totalMeters: _currentDistance,
        );
        if (!mounted) return;
        if (ok) {
          message = 'Reporte diario programado a las ${picked.format(context)}';
        } else {
          message =
              'Las notificaciones solo funcionan en el celular Android, no en el navegador.';
          color = Colors.orange.shade800;
        }
      } catch (e) {
        // Si algo falla (p. ej. falta el permiso de alarmas) la app no se congela
        message = 'No se pudo programar la notificación: $e';
        color = Colors.red.shade700;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monitor de Caminata')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StepCounterWidget(
              onDistanceUpdated: (newDistance) {
                _currentDistance = newDistance;
              },
            ),
            const SizedBox(height: 32),
            // ---------- Parte que faltaba en la guía ----------
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.alarm),
              label: const Text(
                'Programar resumen diario',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: _pickTimeAndSchedule,
            ),
            const SizedBox(height: 12),
            Text(
              'Hora seleccionada: ${_selectedTime.format(context)}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
