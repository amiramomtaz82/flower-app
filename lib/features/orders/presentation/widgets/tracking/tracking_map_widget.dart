import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:flower_app/config/di/di.dart';
import 'package:flower_app/core/app_constants/app_assets.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_constants/endpoints.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flower_app/core/services/road_routing_service.dart';
import '../../../domain/entities/order_tracking_entity.dart';
import 'driver_info_card.dart';

class TrackingMapWidget extends StatefulWidget {
  final OrderTrackingEntity data;
  final VoidCallback onSwitchToTimeline;
  final LatLng? storeLocation;
  final RoadRoutingService? routingService;

  const TrackingMapWidget({
    super.key,
    required this.data,
    required this.onSwitchToTimeline,
    this.storeLocation,
    this.routingService,
  });

  @override
  State<TrackingMapWidget> createState() => _TrackingMapWidgetState();
}

class _TrackingMapWidgetState extends State<TrackingMapWidget> {
  late final MapController _mapController;
  late final RoadRoutingService _routingService;
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = false;

  LatLng get _storePoint {
    if (widget.storeLocation != null) return widget.storeLocation!;
    final dest = widget.data.userAddress;
    return LatLng(dest.lat + 0.012, dest.lng - 0.015);
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _routingService = widget.routingService ??
        (getIt.isRegistered<RoadRoutingService>()
            ? getIt<RoadRoutingService>()
            : RoadRoutingService());
    _fetchRoadPolyline();
  }

  /// Calculates actual street-following road path from Store -> Driver -> Home
  Future<void> _fetchRoadPolyline() async {
    if (_isLoadingRoute) return;
    _isLoadingRoute = true;

    final destPoint = LatLng(
      widget.data.userAddress.lat,
      widget.data.userAddress.lng,
    );
    final storePoint = _storePoint;
    final driverLoc = widget.data.currentLocation;
    final driverPoint = driverLoc != null
        ? LatLng(driverLoc.lat, driverLoc.lng)
        : null;

    final waypoints = [
      storePoint,
      if (driverPoint != null) driverPoint,
      destPoint,
    ];

    final roadPoints = await _routingService.getRouteCoordinates(waypoints);

    if (mounted) {
      setState(() {
        _routePoints = roadPoints;
        _isLoadingRoute = false;
      });
    }
  }

  @override
  void didUpdateWidget(covariant TrackingMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldLoc = oldWidget.data.currentLocation;
    final newLoc = widget.data.currentLocation;

    if (newLoc != null &&
        (oldLoc?.lat != newLoc.lat || oldLoc?.lng != newLoc.lng)) {
      _mapController.move(
        LatLng(newLoc.lat, newLoc.lng),
        _mapController.camera.zoom,
      );
      // Recalculate road path as driver position advances
      _fetchRoadPolyline();
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<LightColors>();
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final primary = colors?.primary ?? colorScheme.primary;

    final destPoint = LatLng(
      widget.data.userAddress.lat,
      widget.data.userAddress.lng,
    );
    final storePoint = _storePoint;
    final driverPoint = widget.data.currentLocation != null
        ? LatLng(
      widget.data.currentLocation!.lat,
      widget.data.currentLocation!.lng,
    )
        : null;

    final allPoints = [
      storePoint,
      destPoint,
      if (driverPoint != null) driverPoint,
    ];
    final bounds = LatLngBounds.fromPoints(allPoints);

    // If OSRM points are still loading, fallback to waypoints to avoid empty map
    final polylinePoints = _routePoints.isNotEmpty ? _routePoints : allPoints;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCameraFit: CameraFit.bounds(
              bounds: bounds,
              padding: const EdgeInsets.only(
                left: 45,
                right: 45,
                top: 50,
                bottom: 220,
              ),
            ),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            // 🎯 Solved: Extracted tile URL and package name from Endpoints
            TileLayer(
              urlTemplate: Endpoints.openStreetMapTileUrl,
              userAgentPackageName: Endpoints.mapUserAgent,
            ),
            // 🎯 Solved: Real road-following polyline instead of straight diagonal lines
            PolylineLayer(
              polylines: [
                Polyline(
                  points: polylinePoints,
                  strokeWidth: 4.0,
                  color: primary,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                // 1. Store Marker
                Marker(
                  point: storePoint,
                  width: 64,
                  height: 28,
                  alignment: Alignment.center,
                  child: Image.asset(
                    AppAssets.flowery_location,
                    fit: BoxFit.contain,
                  ),
                ),
                // 2. Home Destination Marker
                Marker(
                  point: destPoint,
                  width: 84,
                  height: 30,
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    AppAssets.user_location,
                    fit: BoxFit.contain,
                  ),
                ),
                // 3. Driver Courier Marker
                if (driverPoint != null)
                  Marker(
                    point: driverPoint,
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    child: Image.asset(
                      AppAssets.motorcycle,
                      fit: BoxFit.contain,
                    ),
                  ),
              ],
            ),
          ],
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DriverInfoCard(
                driver: widget.data.driver,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: widget.onSwitchToTimeline,
                  child: Text(
                    AppStrings.trackOrder.tr(),
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}