// lib/features/land_search/presentation/pages/explorer_dashboard.dart
import 'dart:ui';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controllers/controllers.dart';
import '../../data/models/app_status.dart';
import '../../data/models/site_plan_model.dart';
import '../widgets/custom_map.dart';
import '../widgets/edit_siteplan_data.dart';
import '../widgets/land_details_card.dart';
import '../widgets/upload_siteplan.dart';

class UploadManager extends StatefulWidget {
  const UploadManager({super.key});

  @override
  State<UploadManager> createState() => _UploadManagerState();
}

class _UploadManagerState extends State<UploadManager> {
  final LandSearchController _landSearchController = Get.find();
  GoogleMapController? mapController;
  bool isMapReady = false;
  BitmapDescriptor? dotMarker;

  @override
  void initState() {
    super.initState();
    _createDotMarker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(() {
            if (_landSearchController.managementPageStatus.value !=
                LandSearchManagementPageStatus.success) {
              return const SizedBox(
                height: 0,
                width: 0,
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const FileUploadScreen();
                            });
                      },
                      icon: const Icon(Icons.upload,
                          size: 18, color: Colors.white), // Icon for the button
                      label: const Text(
                        "Upload Documents",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ), // Text color
                        elevation: 5, // Shadow
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Enhanced Map View
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Obx(() {
                      // Handle different search statuses
                      switch (
                          _landSearchController.managementPageStatus.value) {
                        case LandSearchManagementPageStatus.loading:
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          );
                        case LandSearchManagementPageStatus.error:
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_landSearchController.errorMessage.value),
                                ElevatedButton(
                                  onPressed: () =>
                                      _landSearchController.clearError(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        case LandSearchManagementPageStatus.noConnection:
                          return const Center(
                            child: Text('No internet connection'),
                          );

                        case LandSearchManagementPageStatus.empty:
                          return Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("No Site Plans"),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return const FileUploadScreen();
                                        });
                                  },
                                  icon: const Icon(
                                    Icons.upload,
                                    size: 18,
                                    color: Colors.white,
                                  ), // Icon for the button
                                  label: const Text(
                                    "Upload Documents",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ), // Text color
                                    elevation: 5, // Shadow
                                  ),
                                ),
                              ),
                            ],
                          ));
                        case LandSearchManagementPageStatus.success:
                          return Row(
                            children: [
                              Visibility(
                                  visible: _landSearchController
                                          .selectedUnApprovedSitePlan.value !=
                                      null,
                                  child: SizedBox(
                                    width: 400,
                                    child: LandDetailsInfoWidget(
                                      data: _landSearchController
                                          .selectedUnApprovedSitePlan.value,
                                      showEditButton: false,
                                      onSave: (data) {},
                                      onUpdate:
                                          (ProcessedLandData update) async {
                                        _landSearchController
                                            .updateSitePlanCoordinates(update);
                                      },
                                      onDelete: (ProcessedLandData data) async {
                                        await _landSearchController
                                            .deleteUnapprovedSitePlan(data);
                                      },
                                    ),
                                  )),
                              Expanded(
                                child: CoordinatesMap(
                                  coordinates: [
                                    _landSearchController
                                        .selectedUnApprovedSitePlan
                                        .value!
                                        .pointList
                                        .map((point) => latlong2.LatLng(
                                            point.latitude, point.longitude))
                                        .toList()
                                  ],
                                  initialZoom: 5.0,
                                  borderRadius: 0,
                                  mapHeight:
                                      MediaQuery.of(context).size.height *
                                          0.796,
                                  onPolygonTap: (index) {
                                    _landSearchController.setSelectedSitePlan(
                                        _landSearchController
                                            .unApprovedSitePlans[index],
                                        refresh: false);
                                  },
                                ),
                              ),
                              // Expanded(
                              //   child: Stack(
                              //     children: [
                              //       GoogleMap(
                              //         initialCameraPosition:
                              //             _landSearchController
                              //                 .initialCameraPosition2.value!,
                              //         onMapCreated:
                              //             (GoogleMapController controller) {
                              //           setState(() {
                              //             mapController = controller;
                              //             isMapReady = true;
                              //           });
                              //         },
                              //         myLocationEnabled: false,
                              //         myLocationButtonEnabled: false,
                              //         zoomControlsEnabled: false,
                              //         mapType: MapType.normal,
                              //         markers: _buildMarkersFromSearchResults(
                              //             _landSearchController),
                              //         polygons: _buildPolygonsFromSearchResults(
                              //             _landSearchController),
                              //       ),
                              //       if (!isMapReady)
                              //         const Center(
                              //           child: CircularProgressIndicator(
                              //             color: AppColors.primary,
                              //           ),
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
                              //                   mapController?.animateCamera(
                              //                       CameraUpdate.zoomIn()),
                              //             ),
                              //             const SizedBox(height: 8),
                              //             _buildMapControl(
                              //               icon: Icons.remove,
                              //               onTap: () =>
                              //                   mapController?.animateCamera(
                              //                       CameraUpdate.zoomOut()),
                              //             ),
                              //             const SizedBox(height: 8),
                              //             _buildMapControl(
                              //               icon: Icons.my_location,
                              //               onTap: () =>
                              //                   mapController?.animateCamera(
                              //                 CameraUpdate.newCameraPosition(
                              //                     _landSearchController
                              //                         .initialCameraPosition2
                              //                         .value!),
                              //               ),
                              //             ),
                              //           ],
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ],
                          );
                        default:
                          return const Center(child: Text("No Site Plans"));
                      }
                    }),
                  ),
                ),
              ],
            ),
          ),

          Obx(() {
            switch (_landSearchController.managementPageStatus.value) {
              case LandSearchManagementPageStatus.success:
                return Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(),
                      Row(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    _landSearchController.previousSitePlan();
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    size: 18,
                                    color: Colors.grey,
                                  )),
                              const SizedBox(
                                width: 10,
                              ),
                              Obx(() {
                                return Text(
                                    "${_landSearchController.unApprovedSitePlans.isNotEmpty ? _landSearchController.selectedUnApprovedSitePlanIndex.value + 1 : 0} of ${_landSearchController.unApprovedSitePlans.length}");
                              }),
                              const SizedBox(
                                width: 10,
                              ),
                              IconButton(
                                  onPressed: () {
                                    _landSearchController.nextSitePlan();
                                  },
                                  icon: const Icon(
                                    Icons.arrow_forward,
                                    size: 18,
                                    color: Colors.grey,
                                  )),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // ProcessedLandData? landData = _landSearchController.selectedSitePlan.value;
                              if (_landSearchController
                                      .selectedUnApprovedSitePlan.value ==
                                  null) {
                                const AlertDialog(
                                  title: Text("No site plan selected!"),
                                );
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return PlotForm(
                                        validate: true,
                                        actionText: "Save Changes",
                                        landData: _landSearchController
                                            .selectedUnApprovedSitePlan.value!,
                                        onSave:
                                            (ProcessedLandData update) async {
                                          _landSearchController
                                              .updateSitePlanCoordinates(
                                                  update);
                                        },
                                        onUpdate:
                                            (ProcessedLandData update) async {
                                          _landSearchController
                                              .updateSitePlanCoordinates(
                                                  update);
                                        },
                                        onDelete:
                                            (ProcessedLandData data) async {
                                          await _landSearchController
                                              .deleteUnapprovedSitePlan(data);
                                        },
                                      );
                                    });
                              }
                            },
                            icon: const Icon(Icons.edit_outlined,
                                size: 18,
                                color: Colors.white), // Icon for the button
                            label: const Text(
                              "Modify",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ), // Text color
                              elevation: 5, // Shadow
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => const Center(
                                        child: AlertDialog(
                                          // icon: Icon(
                                          //   Icons.save,
                                          //   color: AppColors.primary,
                                          // ),
                                          // title: Text(
                                          //   "",
                                          //   style: TextStyle(
                                          //       fontWeight: FontWeight.bold),
                                          // ),
                                          content: Padding(
                                            padding: EdgeInsets.all(15.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircularProgressIndicator(
                                                  color: AppColors.primary,
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ));
                              await _landSearchController.saveSitePlan();
                              Navigator.pop(context);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Changes saved successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.save,
                                size: 18,
                                color: Colors.white), // Icon for the button
                            label: const Text(
                              "Approve",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ), // Text color
                              elevation: 5, // Shadow
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              default:
                return const SizedBox();
            }
          })
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

  Set<Marker> _buildMarkersFromSearchResults(LandSearchController controller) {
    Set<Marker> markers = {};
    for (var land in _landSearchController.unApprovedSitePlans) {
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

// Helper method to build a detailed snippet for the info window
  String _buildPlotInfoSnippet(dynamic land) {
    final plotInfo = land.plotInfo;
    return '''
       Locality: ${plotInfo?.locality ?? 'N/A'} | \n
          ''';
  }

// Method to show a bottom sheet with full land details
  void _showLandDetailsBottomSheet(dynamic land) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Plot Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                  'Plot Number', land.plotInfo?.plotNumber ?? 'N/A'),
              _buildDetailRow('Locality', land.plotInfo?.locality ?? 'N/A'),
              _buildDetailRow('District', land.plotInfo?.district ?? 'N/A'),
              _buildDetailRow('Region', land.plotInfo?.region ?? 'N/A'),
              _buildDetailRow('Area',
                  '${land.plotInfo?.area ?? 0} ${land.plotInfo?.metric ?? ''}'),
              _buildDetailRow('Date', land.plotInfo?.date ?? 'N/A'),
              _buildDetailRow(
                  'Surveyors Name', land.plotInfo?.surveyorsName ?? 'N/A'),
              const SizedBox(height: 16),
              const Text(
                'Owners',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              ...?land.plotInfo?.owners?.map((owner) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(owner),
                  )),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

// Helper method to build a detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Add this method to create polygons
  Set<Polygon> _buildPolygonsFromSearchResults(
      LandSearchController controller) {
    return _landSearchController.unApprovedSitePlans
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
              controller.setSelectedSitePlan(land, refresh: false);
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
