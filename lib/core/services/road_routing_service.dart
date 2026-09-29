import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import '../app_constants/endpoints.dart';

@lazySingleton
class RoadRoutingService {
  final http.Client _client;

  RoadRoutingService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches real turn-by-turn road coordinates between the given waypoints:
  /// Store -> Driver -> User Destination
  Future<List<LatLng>> getRouteCoordinates(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return waypoints;

    // OSRM expects coordinates in lng,lat format joined by ';'
    final coordsQuery = waypoints
        .map((p) => '${p.longitude},${p.latitude}')
        .join(';');

    final url = Uri.parse(
      '${Endpoints.osrmRouteBaseUrl}/$coordsQuery?overview=full&geometries=geojson',
    );

    try {
      final response = await _client.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List<dynamic>?;
        if (routes != null && routes.isNotEmpty) {
          final coordinates =
          routes[0]['geometry']['coordinates'] as List<dynamic>;
          return coordinates
              .map((c) => LatLng(c[1] as double, c[0] as double))
              .toList();
        }
      }
    } catch (_) {
      // Fallback: If network fails, return the waypoints directly
    }

    return waypoints;
  }
}