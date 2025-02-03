import 'dart:ui';

import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/api/simple_upload_api.dart';
import '../../../../core/theme/app_colors.dart';
import '../../controllers/controllers.dart';
import '../../data/models/app_status.dart';
import '../../data/models/site_plan_model.dart';
import '../widgets/custom_map.dart';
import '../widgets/edit_siteplan_data.dart';
import '../widgets/land_details_card.dart';
import '../widgets/plots_table.dart';

class DocumentSearchDashboard extends StatefulWidget {
  const DocumentSearchDashboard({super.key});

  @override
  State<DocumentSearchDashboard> createState() =>
      _DocumentSearchDashboardState();
}

class _DocumentSearchDashboardState extends State<DocumentSearchDashboard> {
  final LandSearchController _landSearchController = Get.find();
  GoogleMapController? mapController;
  bool isMapReady = false;
  BitmapDescriptor? dotMarker;
  bool singleMatch = false;

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );

    if (result != null) {
      _landSearchController.searchStatus.value = SearchStatus.loading;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
            child: AlertDialog(
          icon: Icon(
            Icons.upload_file,
            color: AppColors.primary,
          ),
          title: Text(
            "Preparing document",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary)
                ]),
          ),
        )),
      );
      final data = await uploadFiles([result.files[0]], store: false);
      Navigator.pop(context);

      if (data.isNotEmpty) {
        var processedData = ProcessedLandData.fromJson(data[0]);
        processedData.id = "search-site-plan";
        _landSearchController.searchStatus.value = SearchStatus.empty;
        _landSearchController.uploadedSitePlan.value = processedData;
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return PlotForm(
                title: "",
                actionText: "Confirm",
                validate: false,
                landData: _landSearchController.uploadedSitePlan.value!,
                onSave: (ProcessedLandData update) async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                        child: AlertDialog(
                      icon: Icon(
                        Icons.upload_file,
                        color: AppColors.primary,
                      ),
                      content: Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  "Searching for matching Documents",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              CircularProgressIndicator(
                                  color: AppColors.primary)
                            ]),
                      ),
                    )),
                  );

                  var sitePlans =
                      await _landSearchController.documentSearch(update);

                  if (sitePlans.length == 1) {
                    if (sitePlans[0].plotInfo.isSearchPlan == true) {
                      setState(() {
                        singleMatch = true;
                      });
                    } else {
                      setState(() {
                        singleMatch = false;
                      });
                    }
                  }

                  _landSearchController.searchStatus.value =
                      SearchStatus.success;
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                onUpdate: (ProcessedLandData update) async {
                  _landSearchController.updateSitePlanCoordinates(update);
                },
                onDelete: (ProcessedLandData data) {},
              );
            });
      } else {
        _landSearchController.searchStatus.value = SearchStatus.error;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _createDotMarker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Land Search Dashboard'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                Obx(() {
                  switch (_landSearchController.searchStatus.value) {
                    case SearchStatus.empty:
                    case SearchStatus.success:
                      return IconButton(
                        onPressed: () async {
                          _pickFiles();
                        },
                        icon: const Icon(Icons.upload_file,
                            color: Colors.white,
                            size: 18), // Icon for the button
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
                      );
                    default:
                      return const SizedBox();
                  }
                })
              ],
            ),
          ),
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
                      switch (_landSearchController.searchStatus.value) {
                        case SearchStatus.loading:
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        case SearchStatus.error:
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
                        case SearchStatus.noConnection:
                          return const Center(
                            child: Text('No internet connection'),
                          );

                        case SearchStatus.empty:
                          return const Center(child: Text("No Matching Plans"));
                        case SearchStatus.success:
                          return Row(
                            children: [
                              Visibility(
                                  visible: _landSearchController
                                          .selectedMatchingSitePlan.value !=
                                      null,
                                  child: SizedBox(
                                    width: 400,
                                    child: LandDetailsInfoWidget(
                                        data: _landSearchController
                                            .selectedMatchingSitePlan.value,
                                        showEditButton: false,
                                        onSave: (data) {},
                                        onUpdate:
                                            (ProcessedLandData update) async {
                                          _landSearchController
                                              .updateSitePlanCoordinates(
                                                  update);
                                        }),
                                  )),
                              Expanded(
                                child: Stack(
                                  children: [
                                    if (_landSearchController
                                        .documentSearchResults.isEmpty)
                                      const Center(
                                        child: Text(
                                            "No matching site plans found!"),
                                      )
                                    else if (_landSearchController
                                                .documentSearchResults.length ==
                                            1 &&
                                        singleMatch == true)
                                      const Center(
                                        child: Text(
                                            "No matching site plans found, except itself!"),
                                      )
                                    else
                                      SearchablePlotTable(
                                          plots: _landSearchController
                                              .documentSearchResults,
                                          updateSitePlan: _landSearchController
                                              .updateSitePlanCoordinatesGeneral,
                                          saveSitePlan: _landSearchController
                                              .saveSitePlanGeneral,
                                          deleteSitePlan: null,
                                          getCameraPosition:
                                              _landSearchController
                                                  .getCenterPoints,
                                          cameraPosition: _landSearchController
                                              .initialCameraPosition3.value!,
                                          hideSearchBar: true,
                                          showEditButton: false,
                                          mapView: CoordinatesMap(
                                            coordinates: _landSearchController
                                                .documentSearchResults
                                                .map((sitePlan) => sitePlan
                                                    .pointList
                                                    .where((point) =>
                                                        point.refPoint == false)
                                                    .map((point) =>
                                                        latlong2.LatLng(
                                                            point.latitude,
                                                            point.longitude))
                                                    .toList())
                                                .toList(),
                                            initialZoom: 17.0,
                                            borderRadius: 0,
                                            mapHeight: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.796,
                                            onPolygonTap: (index) {
                                              _landSearchController
                                                  .setSelectedSitePlan(
                                                      _landSearchController
                                                              .unApprovedSitePlans[
                                                          index],
                                                      refresh: false);
                                            },
                                          )),

                                    // if (!isMapReady)
                                    //   const Center(
                                    //     child: CircularProgressIndicator(
                                    //         color: AppColors.primary),
                                    //   ),
                                    // GoogleMap(
                                    //   initialCameraPosition:
                                    //       _landSearchController
                                    //           .initialCameraPosition3.value!,
                                    //   onMapCreated:
                                    //       (GoogleMapController controller) {
                                    //     setState(() {
                                    //       mapController = controller;
                                    //       isMapReady = true;
                                    //     });
                                    //   },
                                    //   myLocationEnabled: false,
                                    //   myLocationButtonEnabled: false,
                                    //   zoomControlsEnabled: false,
                                    //   mapType: MapType.normal,
                                    //   markers: _buildMarkersFromSearchResults(
                                    //       _landSearchController),
                                    //   polygons: _buildPolygonsFromSearchResults(
                                    //       _landSearchController),
                                    // ),
                                    // if (!isMapReady)
                                    //   const Center(
                                    //     child: CircularProgressIndicator(),
                                    //   ),
                                    //
                                    // // Enhanced Map Controls
                                    // Positioned(
                                    //   right: 16,
                                    //   bottom: 16,
                                    //   child: Column(
                                    //     children: [
                                    //       _buildMapControl(
                                    //         icon: Icons.add,
                                    //         onTap: () =>
                                    //             mapController?.animateCamera(
                                    //                 CameraUpdate.zoomIn()),
                                    //       ),
                                    //       const SizedBox(height: 8),
                                    //       _buildMapControl(
                                    //         icon: Icons.remove,
                                    //         onTap: () =>
                                    //             mapController?.animateCamera(
                                    //                 CameraUpdate.zoomOut()),
                                    //       ),
                                    //       const SizedBox(height: 8),
                                    //       _buildMapControl(
                                    //         icon: Icons.my_location,
                                    //         onTap: () =>
                                    //             mapController?.animateCamera(
                                    //           CameraUpdate.newCameraPosition(
                                    //               _landSearchController
                                    //                   .initialCameraPosition3
                                    //                   .value!),
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        default:
                          return Center(
                              child: ElevatedButton.icon(
                            onPressed: () {
                              _pickFiles();
                            },
                            icon: const Icon(Icons.upload,
                                color: Colors.white,
                                size: 18), // Icon for the button
                            label: const Text(
                              "Choose Document",
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
                          ));
                      }
                    }),
                  ),
                ),
              ],
            ),
          ),

          Obx(() {
            switch (_landSearchController.searchStatus.value) {
              case SearchStatus.success:
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
                                    _landSearchController.previousSitePlan(
                                        which: "search");
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
                                    "${_landSearchController.documentSearchResults.isNotEmpty ? _landSearchController.selectedMatchPlansIndex.value + 1 : 0} of ${_landSearchController.documentSearchResults.length}");
                              }),
                              const SizedBox(
                                width: 10,
                              ),
                              IconButton(
                                  onPressed: () {
                                    _landSearchController.nextSitePlan(
                                        which: "search");
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
                                          title: "",
                                          actionText: "Confirm",
                                          validate: false,
                                          landData: _landSearchController
                                              .uploadedSitePlan.value!,
                                          onSave:
                                              (ProcessedLandData update) async {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (context) =>
                                                  const Center(
                                                      child: AlertDialog(
                                                icon: Icon(
                                                  Icons.upload_file,
                                                  color: AppColors.primary,
                                                ),
                                                content: Padding(
                                                  padding: EdgeInsets.all(15.0),
                                                  child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10.0),
                                                          child: Text(
                                                            "Searching for matching Documents",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                        CircularProgressIndicator(
                                                            color: AppColors
                                                                .primary)
                                                      ]),
                                                ),
                                              )),
                                            );
                                            final results =
                                                await _landSearchController
                                                    .reComputeCoordinates(
                                                        update);
                                            if (results != null) {
                                              await _landSearchController
                                                  .documentSearch(results);
                                            }
                                            if (mounted) {
                                              Navigator.pop(context);
                                            }
                                          },
                                          onUpdate:
                                              (ProcessedLandData update) async {
                                            _landSearchController
                                                .updateSitePlanCoordinates(
                                                    update);
                                          },
                                          onDelete: null);
                                    });
                              }
                            },
                            icon: const Icon(Icons.edit_outlined,
                                color: Colors.white,
                                size: 18), // Icon for the button
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
                            onPressed: () async {},
                            icon: const Icon(Icons.report,
                                color: Colors.white,
                                size: 18), // Icon for the button
                            label: const Text(
                              "Report",
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
    for (var land in _landSearchController.documentSearchResults) {
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
    return _landSearchController.documentSearchResults
        .where((land) => land.pointList.isNotEmpty)
        .map((land) {
      return Polygon(
          polygonId: PolygonId(land.id ?? 'polygon'),
          points: land.pointList
              .map((point) => LatLng(point.latitude ?? 0, point.longitude ?? 0))
              .toList(),
          strokeColor: land.id == "search-site-plan"
              ? Colors.redAccent.withOpacity(0.7)
              : AppColors.primary.withOpacity(0.7),
          fillColor: land.id == "search-site-plan"
              ? Colors.redAccent.withOpacity(0.4)
              : AppColors.primary.withOpacity(0.2),
          strokeWidth: 2,
          onTap: () {
            // controller.setSelectedUnApprovedSitePlan(land,
            //     refresh: false, which: "search");
            // _showLandDetailsBottomSheet(land);
          });
    }).toSet();
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
