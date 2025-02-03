import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';

class CoordinatesMap extends StatefulWidget {
  final List<List<LatLng>> coordinates; // Accept multiple sets of points
  final double initialZoom;
  final double borderRadius;
  final double mapHeight;
  final MapController? externalController; // Accept external controller
  final Function(int)? onPolygonTap; // Callback for polygon tap

  const CoordinatesMap({
    super.key,
    required this.coordinates,
    this.initialZoom = 15.0,
    this.borderRadius = 0,
    this.externalController,
    this.mapHeight = 400,
    this.onPolygonTap, // Make it optional
  });

  @override
  _CoordinatesMapState createState() => _CoordinatesMapState();
}

class _CoordinatesMapState extends State<CoordinatesMap> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = widget.externalController ?? MapController();
  }

  void zoomIn() {
    _mapController.move(_mapController.center, _mapController.zoom + 1);
  }

  void zoomOut() {
    _mapController.move(_mapController.center, _mapController.zoom - 1);
  }

  void centerMap(LatLng newCenter) {
    _mapController.move(newCenter, _mapController.zoom);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: SizedBox(
            height: widget.mapHeight,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: widget.coordinates.isNotEmpty &&
                            widget.coordinates.first.isNotEmpty
                        ? widget.coordinates.first.first
                        : const LatLng(0, 0),
                    zoom: widget.initialZoom,
                    interactiveFlags: InteractiveFlag.all,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    // Draw multiple polygons with tap detection
                    PolygonLayer(
                      polygons: widget.coordinates.asMap().entries.map((entry) {
                        final index = entry.key;
                        final points = entry.value;

                        return Polygon(
                          points: points,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.3),
                          borderColor: Theme.of(context).primaryColor,
                          borderStrokeWidth: 3,
                        );
                      }).toList(),
                    ),
                    // Tap detection using a GestureDetector over the polygon
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (details) {
                        if (widget.onPolygonTap != null) {
                          widget.onPolygonTap!(
                              0); // You may need to determine index dynamically
                        }
                      },
                    ),
                    // Draw multiple polylines
                    PolylineLayer(
                      polylines: widget.coordinates.map((points) {
                        return Polyline(
                          points: [...points, points.first], // Close the loop
                          strokeWidth: 3,
                          color: Theme.of(context).primaryColor,
                        );
                      }).toList(),
                    ),
                    // Draw markers for polygon corners
                    MarkerLayer(
                      markers: widget.coordinates.expand((points) {
                        return points.map((coord) => Marker(
                              point: coord,
                              width: 10,
                              height: 10,
                              builder: (context) => Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ));
                      }).toList(),
                    ),
                  ],
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: Column(
                    children: [
                      buildMapControl(
                        icon: Icons.add,
                        onTap: () => _mapController.move(
                            _mapController.center, _mapController.zoom + 1),
                      ),
                      const SizedBox(height: 8),
                      buildMapControl(
                        icon: Icons.remove,
                        onTap: () => _mapController.move(
                            _mapController.center, _mapController.zoom - 1),
                      ),
                      const SizedBox(height: 8),
                      buildMapControl(
                        icon: Icons.my_location,
                        onTap: () => _mapController.move(
                            LatLng(widget.coordinates.first.first.latitude,
                                widget.coordinates.first.first.longitude),
                            _mapController.zoom),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

Widget buildMapControl({
  required IconData icon,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    elevation: 4,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
      ),
    ),
  );
}
