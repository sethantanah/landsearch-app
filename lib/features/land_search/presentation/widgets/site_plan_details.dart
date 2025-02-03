import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import '../../../../core/theme/app_colors.dart';
import '../../data/models/site_plan_model.dart';
import 'custom_map.dart';
import 'land_details_card.dart';

class SitePlanDetails extends StatefulWidget {
  final List<ProcessedLandData> sitePlans;
  final Function(ProcessedLandData data) saveSitePlan;
  final Function(ProcessedLandData data) updateSitePlan;
  final Function(ProcessedLandData data)? deleteSitePlan;
  final Function(List<ProcessedLandData> data) getCameraPosition;
  final bool showEditButton;
  const SitePlanDetails(
      {super.key,
      required this.sitePlans,
      required this.updateSitePlan,
      required this.saveSitePlan,
      required this.getCameraPosition,
      this.showEditButton = false,
      this.deleteSitePlan});

  @override
  State<SitePlanDetails> createState() => _SitePlanDetailsState();
}

class _SitePlanDetailsState extends State<SitePlanDetails> {
  GoogleMapController? mapController;
  late CameraPosition cameraPosition;
  BitmapDescriptor? dotMarker;
  bool isMapReady = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cameraPosition = widget.getCameraPosition(widget.sitePlans);
    _createDotMarker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Site Plan Details'),
      ),
      body: Row(
        children: [
          SizedBox(
            width: 400,
            child: LandDetailsInfoWidget(
              data: widget.sitePlans[0],
              showEditButton: widget.showEditButton,
              onSave: (ProcessedLandData update) async {
                final updatedData = await widget.updateSitePlan(update);
                if (updatedData != null) {
                  await widget.saveSitePlan(updatedData);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Changes saved successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              onUpdate: (ProcessedLandData update) async {
                final updatedData = await widget.updateSitePlan(update);
                return updatedData;
              },
              onDelete: widget.deleteSitePlan != null
                  ? (ProcessedLandData data) async {
                      await widget.deleteSitePlan!(data);
                    }
                  : null,
            ),
          ),

          Expanded(
            child: CoordinatesMap(
              coordinates: [
                widget.sitePlans[0].pointList
                    .map((point) =>
                        latlong2.LatLng(point.latitude, point.longitude))
                    .toList()
              ],
              initialZoom: 17.0,
              borderRadius: 0,
              mapHeight: MediaQuery.of(context).size.height * 0.94,
            ),
          ),
          // Expanded(
          //   child: Stack(
          //     children: [
          //       GoogleMap(
          //         initialCameraPosition: cameraPosition,
          //         onMapCreated: (GoogleMapController controller) {
          //           setState(() {
          //             mapController = controller;
          //             isMapReady = true;
          //           });
          //         },
          //         myLocationEnabled: false,
          //         myLocationButtonEnabled: false,
          //         zoomControlsEnabled: false,
          //         mapType: MapType.normal,
          //         markers:
          //             _buildMarkersFromSearchResults([widget.sitePlans[0]]),
          //         polygons:
          //             _buildPolygonsFromSearchResults([widget.sitePlans[0]]),
          //       ),
          //       if (!isMapReady)
          //         const Center(
          //           child: CircularProgressIndicator(color: AppColors.primary),
          //         ),
          //
          //       // Enhanced Map Controls
          //       Positioned(
          //         right: 16,
          //         bottom: 16,
          //         child: Column(
          //           children: [
          //             _buildMapControl(
          //               icon: Icons.add,
          //               onTap: () =>
          //                   mapController?.animateCamera(CameraUpdate.zoomIn()),
          //             ),
          //             const SizedBox(height: 8),
          //             _buildMapControl(
          //               icon: Icons.remove,
          //               onTap: () => mapController
          //                   ?.animateCamera(CameraUpdate.zoomOut()),
          //             ),
          //             const SizedBox(height: 8),
          //             _buildMapControl(
          //               icon: Icons.my_location,
          //               onTap: () => mapController?.animateCamera(
          //                 CameraUpdate.newCameraPosition(cameraPosition),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildMapControl({
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

  Set<Marker> _buildMarkersFromSearchResults(List<ProcessedLandData> data) {
    Set<Marker> markers = {};
    for (var land in data) {
      // Check if point_list exists and is not empty
      if (land.pointList.isNotEmpty) {
        // Create markers for each point in the point list
        markers.addAll(
          land.pointList.map((point) => Marker(
                markerId: MarkerId('${land.id}_${point.hashCode}'),
                position: LatLng(point.latitude ?? 0, point.longitude ?? 0),
                icon: dotMarker ?? BitmapDescriptor.defaultMarker,
                anchor: const Offset(0.5, 0.5),
                // Center of the marker
                zIndex: 2,
                // Ensure markers appear above polygon
                // Make marker flat against the map
                flat: true,
                onTap: () {},
              )),
        );
      }
    }

    return markers;
  }

  // Add this method to create polygons
  Set<Polygon> _buildPolygonsFromSearchResults(List<ProcessedLandData> data) {
    return data
        .where((land) => land.pointList.isNotEmpty)
        .map((land) => Polygon(
            polygonId: PolygonId(land.id ?? 'polygon'),
            points: land.pointList
                .map((point) =>
                    LatLng(point.latitude ?? 0, point.longitude ?? 0))
                .toList(),
            strokeColor: AppColors.primary.withOpacity(0.7),
            fillColor: AppColors.primary.withOpacity(0.2),
            strokeWidth: 2,
            onTap: () {
              // _showLandDetailsBottomSheet(land);
            }))
        .toSet();
  }

  Future<void> _createDotMarker() async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    // Make size smaller for more precise placement
    const size = Size(8, 8); // Reduced from 16,16

    CircleMarkerPainter(
      color: AppColors.primary,
      radius: 3, // Smaller radius
      withBorder: true,
      borderWidth: 1, // Add border width control
    ).paint(canvas, size);

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final byteData = await image.toByteData(format: ImageByteFormat.png);

    if (byteData != null) {
      final bytes = byteData.buffer.asUint8List();
      setState(() {
        dotMarker = BitmapDescriptor.bytes(bytes);
      });
    }
  }
}

class CircleMarkerPainter extends CustomPainter {
  final Color color;
  final double radius;
  final bool withBorder;
  final double borderWidth;

  CircleMarkerPainter({
    this.color = Colors.blue,
    this.radius = 3, // Smaller default radius
    this.withBorder = true,
    this.borderWidth = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    if (withBorder) {
      // Draw border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius + borderWidth, borderPaint);
    }

    // Draw main circle
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
