import 'package:easy_localization/easy_localization.dart';
import 'package:flower_app/core/app_constants/app_assets.dart';
import 'package:flower_app/core/app_constants/app_strings.dart';
import 'package:flower_app/core/app_theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../domain/entities/order_tracking_entity.dart';
import 'driver_info_card.dart';

class TrackingMapWidget extends StatefulWidget {
  final OrderTrackingEntity data;
  final VoidCallback onSwitchToTimeline;
  final LatLng? storeLocation;

  const TrackingMapWidget({
    super.key,
    required this.data,
    required this.onSwitchToTimeline,
    this.storeLocation,
  });

  @override
  State<TrackingMapWidget> createState() => _TrackingMapWidgetState();
}

class _TrackingMapWidgetState extends State<TrackingMapWidget> {
  late final MapController _mapController;

  /// Flowery Store pickup location anchor.
  /// Uses widget.storeLocation if provided, or defaults to an offset (~1.5 km)
  /// northwest of the destination so the route and courier stay clearly visible.
  LatLng get _storePoint {
    if (widget.storeLocation != null) return widget.storeLocation!;
    final dest = widget.data.userAddress;
    return LatLng(dest.lat + 0.012, dest.lng - 0.015);
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void didUpdateWidget(covariant TrackingMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldLoc = oldWidget.data.currentLocation;
    final newLoc = widget.data.currentLocation;
    if (newLoc != null && (oldLoc?.lat != newLoc.lat || oldLoc?.lng != newLoc.lng)) {
      _mapController.move(LatLng(newLoc.lat, newLoc.lng), _mapController.camera.zoom);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LightColors>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final primary = colors?.primary ?? colorScheme.primary;

    final destPoint = LatLng(widget.data.userAddress.lat, widget.data.userAddress.lng);
    final storePoint = _storePoint;
    final driverPoint = widget.data.currentLocation != null
        ? LatLng(widget.data.currentLocation!.lat, widget.data.currentLocation!.lng)
        : null;

    final allPoints = [
      storePoint,
      destPoint,
      if (driverPoint != null) driverPoint,
    ];
    final bounds = LatLngBounds.fromPoints(allPoints);

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
                bottom: 220, // Leaves space so markers stay above the bottom card
              ),
            ),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.flower_app',
            ),
            // Route Polyline: Store -> Driver -> Home
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [
                    storePoint,
                    if (driverPoint != null) driverPoint,
                    destPoint,
                  ],
                  strokeWidth: 4.0,
                  color: primary,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                // 1. Flowery Store Anchor Point
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
                // 2. Home Destination Anchor Point
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
                // 3. Driver Point (Motorcycle moving in between)
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
                    AppStrings.orderDetails.tr(),
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