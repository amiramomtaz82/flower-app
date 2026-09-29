import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';
import '../app_constants/endpoints.dart';

@lazySingleton
class RoadRoutingService {
  final Dio _dio;

  RoadRoutingService() : _dio = Dio();

  RoadRoutingService.withDio(this._dio);

  /// Fetches real turn-by-turn road coordinates between the given waypoints:
  /// Store -> Driver -> User Destination
  Future<List<LatLng>> getRouteCoordinates(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return waypoints;

    // OSRM expects coordinates in lng,lat format joined by ';'
    final coordsQuery = waypoints
        .map((p) => '${p.longitude},${p.latitude}')
        .join(';');

    final url =
        '${Endpoints.osrmRouteBaseUrl}/$coordsQuery?overview=full&geometries=geojson';

    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : (response.data is String ? json.decode(response.data as String) : null);
        final routes = data?['routes'] as List<dynamic>?;
        if (routes != null && routes.isNotEmpty) {
          final coordinates =
              routes[0]['geometry']['coordinates'] as List<dynamic>;
          return coordinates
              .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
              .toList();
        }
      }
    } catch (_) {
      // Fallback: If network fails, return the waypoints directly
    }

    return waypoints;
  }
}