import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:landsearch_platform/features/land_search/data/models/site_plan_model.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import '../../../../core/theme/app_colors.dart';
import '../../controllers/controllers.dart';
import 'custom_map.dart';
import 'land_details_card.dart';

class MapPreview extends StatefulWidget {
  late ProcessedLandData? data;
  MapPreview({super.key, required this.data});

  @override
  State<MapPreview> createState() => _MapViewState();
}

class _MapViewState extends State<MapPreview> {
  final LandSearchController _landSearchController = Get.find();
  GoogleMapController? mapController;
  bool isMapReady = false;
  BitmapDescriptor? dotMarker;

  reloadCoordinates() async {
    if (widget.data != null) {
      final results =
          await _landSearchController.reComputeCoordinates(widget.data!);

      if (results != null) {
        _landSearchController.uploadedSitePlan.value = results;
        setState(() {
          widget.data = results;
        });
      }
    }
  }

  @override
  initState() {
    super.initState();
    reloadCoordinates();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.data != null) {
        _landSearchController
            .computeCenterPoints([widget.data!], whichMap: "preview");
      }
      // Handle different search statuses
      switch (widget.data != null) {
        case true:
          return Row(
            children: [
              Visibility(
                  visible: _landSearchController.uploadedSitePlan.value != null,
                  child: SizedBox(
                    width: 400,
                    child: LandDetailsInfoWidget(
                      data: _landSearchController.uploadedSitePlan.value,
                      showEditButton: false,
                      onSave: (data) {},
                      onUpdate: (ProcessedLandData update) async {
                        _landSearchController.updateSitePlanCoordinates(update);
                      },
                      onDelete: (ProcessedLandData update) async {
                        _landSearchController.deleteSitePlan(update);
                      },
                    ),
                  )),


                Expanded(
                  child: CoordinatesMap(
                    coordinates: [
                      widget.data!.pointList
                          .map((point) =>
                              latlong2.LatLng(point.latitude, point.longitude))
                          .toList()
                    ],
                    initialZoom: 17.0,
                    borderRadius: 0,
                    mapHeight: MediaQuery.of(context).size.height * 0.86,
                  ),
                ),

              // Expanded(
              //   child: Stack(
              //     children: [
              //       GoogleMap(
              //         initialCameraPosition:
              //             _landSearchController.initialCameraPosition4.value!,
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
              //             _buildMarkersFromSearchResults(_landSearchController),
              //         polygons: _buildPolygonsFromSearchResults(
              //             _landSearchController),
              //       ),
              //       if (!isMapReady)
              //         const Center(
              //           child: CircularProgressIndicator(),
              //         ),
              //     ],
              //   ),
              // ),
            ],
          );
        default:
          return const Text("No Preview");
      }
    });
  }

  Set<Marker> _buildMarkersFromSearchResults(LandSearchController controller) {
    Set<Marker> markers = {};
    for (var land in [widget.data!]) {
      // Check if point_list exists and is not empty
      if (land.pointList.isNotEmpty) {
        // Create markers for each point in the point list
        markers.addAll(
          land.pointList.map((point) => Marker(
                markerId: MarkerId('${land.id}_${point.hashCode}'),
                position: LatLng(point.latitude ?? 0, point.longitude ?? 0),
                infoWindow: InfoWindow(
                  title: land.plotInfo.plotNumber != ''
                      ? "Plot Number ${land.plotInfo.plotNumber}"
                      : "${land.plotInfo.locality}, Plot Number ${land.plotInfo.plotNumber}",
                  // snippet: _buildPlotInfoSnippet(land),
                ),
                icon: dotMarker ?? BitmapDescriptor.defaultMarker,
                anchor: const Offset(0.5, 0.5),
                // Center of the marker
                zIndex: 2,
                // Ensure markers appear above polygon
                // Make marker flat against the map
                flat: true,
                onTap: () {
                  // Show detailed land information
                  // _showLandDetailsBottomSheet(land);
                },
              )),
        );
      }
    }

    return markers;
  }

  // Add this method to create polygons
  Set<Polygon> _buildPolygonsFromSearchResults(
      LandSearchController controller) {
    return [widget.data!]
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
              controller.setSelectedUnApprovedSitePlan(land,
                  refresh: false, which: "search");
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
