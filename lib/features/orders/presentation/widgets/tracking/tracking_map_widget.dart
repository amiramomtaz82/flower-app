import 'package:easy_localization/easy_localization.dart';
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

  const TrackingMapWidget({
    super.key,
    required this.data,
    required this.onSwitchToTimeline,
  });

  @override
  State<TrackingMapWidget> createState() => _TrackingMapWidgetState();
}

class _TrackingMapWidgetState extends State<TrackingMapWidget> {
  late final MapController _mapController;

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
    final markerBg = colors?.white ?? colorScheme.surface;
    final shadowColor = colorScheme.shadow;

    final destPoint = LatLng(widget.data.userAddress.lat, widget.data.userAddress.lng);
    final driverPoint = widget.data.currentLocation != null
        ? LatLng(widget.data.currentLocation!.lat, widget.data.currentLocation!.lng)
        : null;

    final centerPoint = driverPoint ?? destPoint;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: centerPoint,
            initialZoom: 14.5,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.flower_app',
            ),
            if (driverPoint != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [driverPoint, destPoint],
                    strokeWidth: 4.0,
                    color: primary,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                Marker(
                  point: destPoint,
                  width: 44,
                  height: 44,
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: markerBg,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor.withOpacity(0.18),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(Icons.location_on, color: primary, size: 28),
                  ),
                ),
                if (driverPoint != null)
                  Marker(
                    point: driverPoint,
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: markerBg, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: shadowColor.withOpacity(0.25),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Icon(Icons.directions_car, color: markerBg, size: 20),
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