import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/park_service.dart';

/// Pantalla de mapa con OpenStreetMap (flutter_map), basada en el ejemplo
/// Talleres/mapas de la clase. No necesita API key de Google.
///
/// - Punto azul: tu ubicación GPS.
/// - Árboles verdes: parques reales a 3 km (Overpass API).
/// - Tocar el mapa: agrega un marcador propio (como en el ejemplo de clase).
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  static const LatLng _bogota = LatLng(4.7110, -74.0721);

  LatLng _currentPosition = _bogota;
  final List<Marker> _parkMarkers = [];
  List<Map<String, dynamic>> _parks = []; // datos de los parques para la lista
  final List<Marker> _userMarkers = []; // marcadores agregados al tocar
  bool _isLoading = true;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _initLocationAndParks();
  }

  Future<void> _initLocationAndParks() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      final Position pos = await Geolocator.getCurrentPosition();
      _currentPosition = LatLng(pos.latitude, pos.longitude);
      // La cámara solo se puede mover cuando el mapa ya está dibujado
      if (_mapReady) _mapController.move(_currentPosition, 15);
    }

    final parks = await ParkService.fetchNearbyParks(
      _currentPosition.latitude,
      _currentPosition.longitude,
    );

    if (!mounted) return;
    setState(() {
      _parks = parks;
      _parkMarkers.clear();
      for (final park in parks) {
        _parkMarkers.add(
          Marker(
            point: LatLng(park['lat'], park['lon']),
            width: 44,
            height: 44,
            child: GestureDetector(
              // Reemplaza al InfoWindow de Google Maps
              onTap: () => _showMessage('${park['name']} · Zona verde cercana'),
              child: const Icon(Icons.park, color: Color(0xFF2E7D32), size: 36),
            ),
          ),
        );
      }
      _isLoading = false;
    });
  }

  /// Igual que _addMarkerAt del ejemplo de clase
  void _addMarkerAt(LatLng point) {
    setState(() {
      _userMarkers.add(
        Marker(
          point: point,
          width: 40,
          height: 40,
          child: Tooltip(
            message:
                '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}',
            child: const Icon(Icons.place, color: Colors.teal, size: 38),
          ),
        ),
      );
    });
  }

  /// Distancia en metros desde tu ubicación hasta un punto
  double _distanceTo(double lat, double lon) {
    return const Distance().as(
      LengthUnit.Meter,
      _currentPosition,
      LatLng(lat, lon),
    );
  }

  /// Abre una lista con los parques encontrados; al tocar uno, el mapa va hacia él
  void _showParksList() {
    if (_parks.isEmpty) {
      _showMessage('No se encontraron parques cerca. Prueba recargar ↻');
      return;
    }

    // Ordena del más cercano al más lejano
    final sorted = [..._parks]
      ..sort((a, b) => _distanceTo(a['lat'], a['lon'])
          .compareTo(_distanceTo(b['lat'], b['lon'])));

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Parques a menos de 3 km',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: sorted.length,
                itemBuilder: (_, i) {
                  final park = sorted[i];
                  final meters = _distanceTo(park['lat'], park['lon']);
                  final distText = meters >= 1000
                      ? '${(meters / 1000).toStringAsFixed(1)} km'
                      : '${meters.round()} m';
                  return ListTile(
                    leading: const Icon(Icons.park, color: Color(0xFF2E7D32)),
                    title: Text(park['name']),
                    subtitle: Text('A $distText de ti'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _mapController.move(LatLng(park['lat'], park['lon']), 17);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: const Color(0xFF2E7D32)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Marker myLocationMarker = Marker(
      point: _currentPosition,
      width: 40,
      height: 40,
      child: const Tooltip(
        message: 'Estás aquí',
        child: Icon(Icons.my_location, color: Colors.blue, size: 32),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parques Cercanos'),
        actions: [
          IconButton(
            tooltip: 'Centrar en mi ubicación',
            icon: const Icon(Icons.my_location),
            onPressed: () => _mapController.move(_currentPosition, 15),
          ),
          IconButton(
            tooltip: 'Recargar parques',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _initLocationAndParks();
            },
          ),
          IconButton(
            tooltip: 'Limpiar marcadores agregados',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => setState(() => _userMarkers.clear()),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 13,
              onMapReady: () {
                _mapReady = true;
                _mapController.move(_currentPosition, 15);
              },
              onTap: (tapPosition, point) => _addMarkerAt(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.taller_movilidad',
              ),
              MarkerLayer(
                markers: [..._parkMarkers, ..._userMarkers, myLocationMarker],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (!_isLoading)
            Positioned(
              left: 16,
              bottom: 24,
              // ActionChip = etiqueta que SÍ se puede tocar
              child: ActionChip(
                avatar: const Icon(Icons.park, color: Colors.white),
                label: Text(
                  '${_parkMarkers.length} parques en 3 km · ver lista',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                onPressed: _showParksList,
              ),
            ),
        ],
      ),
    );
  }
}
